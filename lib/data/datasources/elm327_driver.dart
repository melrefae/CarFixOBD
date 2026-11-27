import '../../core/utils/traffic_log.dart';
import 'dart:async';
import 'obd_connection.dart';
import '../../core/constants/obd_commands.dart';
import '../../core/utils/hex_parser.dart';
import '../../core/utils/app_logger.dart';

/// ELM327 adapter driver and ECU protocol state
enum ElmDriverState {
  disconnected,
  connecting,
  initializing,
  adapterConnected, // Hardware adapter is online, waiting for ECU (ignition key ON)
  ready,            // ECU is communicating and responding to OBD PIDs
  error,
}

/// Robust ELM327 protocol driver with queue management, auto-protocol fallback & clone tolerance
class Elm327Driver {
  final ObdConnection connection;
  ElmDriverState _state = ElmDriverState.disconnected;
  String _activeProtocol = "Unknown";
  double _lastBatteryVoltage = 12.6;
  String _elmVersion = "ELM327 v1.5";
  bool _isEcuConnected = false;

  Completer<String>? _currentCommandCompleter;
  final StringBuffer _receiveBuffer = StringBuffer();
  StreamSubscription<String>? _streamSub;

  Elm327Driver({required this.connection}) {
    _setupStreamListener();
  }

  ElmDriverState get state => _state;
  String get activeProtocol => _activeProtocol;
  double get lastBatteryVoltage => _lastBatteryVoltage;
  String get elmVersion => _elmVersion;
  bool get isEcuConnected => _isEcuConnected;

  /// Listen for responses and accumulate chunks until prompt character `>`
  void _setupStreamListener() {
    _streamSub?.cancel();
    _streamSub = connection.responseStream.listen((chunk) {
      _receiveBuffer.write(chunk);

      // Prompt character `>` indicates ELM327 has finished transmitting response
      if (_receiveBuffer.toString().contains('>')) {
        final fullResponse = _receiveBuffer.toString();
        _receiveBuffer.clear();

        if (_currentCommandCompleter != null && !_currentCommandCompleter!.isCompleted) {
          _currentCommandCompleter!.complete(fullResponse);
        }
      }
    }, onError: (err) {
      _state = ElmDriverState.error;
      if (_currentCommandCompleter != null && !_currentCommandCompleter!.isCompleted) {
        _currentCommandCompleter!.completeError(err);
      }
    });
  }

  /// Send command alias for diagnostic screens
  Future<String> sendCommand(String command, {Duration timeout = const Duration(seconds: 4)}) =>
      executeCommand(command, timeout: timeout);

  /// Send raw command string
  Future<String> sendRaw(String command, {Duration timeout = const Duration(seconds: 4)}) =>
      executeCommand(command, timeout: timeout);

  /// Synchronized command execution with safe timeout handling and desynchronization prevention
  Future<String> executeCommand(String command, {Duration timeout = const Duration(seconds: 4)}) async {
    if (!connection.isConnected) {
      throw Exception("OBD adapter is not connected");
    }

    // Wait for any active in-flight command
    while (_currentCommandCompleter != null && !_currentCommandCompleter!.isCompleted) {
      await Future.delayed(const Duration(milliseconds: 25));
    }

    _receiveBuffer.clear();
    final completer = Completer<String>();
    _currentCommandCompleter = completer;

    AppLogger().tx(command);
    await connection.send(command);

    try {
      final response = await completer.future.timeout(
        timeout,
        onTimeout: () {
          AppLogger().warning("Command TIMEOUT -> $command");
          return "TIMEOUT";
        },
      );

      // Prevent delayed responses from completing a timed-out command in future cycles
      if (!completer.isCompleted) {
        completer.complete("TIMEOUT");
      }

      final clean = HexParser.cleanRawResponse(response);
      AppLogger().rx(clean);
      TrafficLog.instance.add(command, clean);
      return clean;
    } finally {
      if (_currentCommandCompleter == completer) {
        _currentCommandCompleter = null;
      }
    }
  }

  /// Send command to a specific CAN ECU module by setting header (e.g., 7E0=ECM, 7E1=TCM, 7E2=ABS, 7E3=SRS, 7E4=BCM)
  Future<String> sendToModule(
    String moduleHeaderHex,
    String command, {
    Duration timeout = const Duration(seconds: 3),
    bool setRxFilter = true,
  }) async {
    final cleanHeader = moduleHeaderHex.trim().toUpperCase();
    final rxHeader = _deriveCanRxHeader(cleanHeader);
    try {
      await executeCommand("AT SH $cleanHeader", timeout: const Duration(milliseconds: 600));
      if (setRxFilter && rxHeader != null && (_activeProtocol.isEmpty || _activeProtocol.toUpperCase().contains('CAN') || _activeProtocol.contains('15765') || _activeProtocol == 'Unknown')) {
        await _sendAtCommandSafe("AT CRA $rxHeader", timeout: const Duration(milliseconds: 500));
      }
      final resp = await executeCommand(command, timeout: timeout);
      return resp;
    } finally {
      // Restore broadcast header and clear CAN receive filter
      try {
        await _sendAtCommandSafe("AT AR", timeout: const Duration(milliseconds: 400));
        await executeCommand("AT SH 7DF", timeout: const Duration(milliseconds: 400));
      } catch (_) {}
    }
  }

  static String? _deriveCanRxHeader(String txHeaderHex) {
    final clean = txHeaderHex.replaceAll('0X', '').trim();
    if (clean.length != 3) return null;
    final txVal = int.tryParse(clean, radix: 16);
    if (txVal == null) return null;
    // Standard 11-bit OBD/UDS physical addressing: RX = TX + 8 (7E0->7E8, 7E1->7E9, 720->728, 760->768)
    if (txVal >= 0x700 && txVal <= 0x7F7) {
      return (txVal + 8).toRadixString(16).toUpperCase().padLeft(3, '0');
    }
    return null;
  }

  /// Gentle AT command sequence with clone tolerance
  Future<String> _sendAtCommandSafe(String atCmd, {Duration timeout = const Duration(seconds: 2)}) async {
    try {
      return await executeCommand(atCmd, timeout: timeout);
    } catch (_) {
      return "";
    }
  }

  /// Professional ELM327 handshake with auto-fallback for all Egyptian vehicles
  Future<bool> initialize({String? specificProtocolCmd}) async {
    _state = ElmDriverState.initializing;
    _setupStreamListener();

    try {
      // 1. Clear any pending UART line garbage
      await connection.send("\r\r\r");
      await Future.delayed(const Duration(milliseconds: 120));

      bool adapterResponded = false;

      // 2. Warm start / Reset ELM327
      final resetResp = await _sendAtCommandSafe(ObdCommands.reset, timeout: const Duration(milliseconds: 1800));
      if (resetResp.isNotEmpty && resetResp != "TIMEOUT") {
        adapterResponded = true;
        _elmVersion = resetResp;
        await Future.delayed(const Duration(milliseconds: 220));
      } else {
        // Fallback fast identity probe (AT I) if AT Z reset didn't wake a sleeping chip
        final idResp = await _sendAtCommandSafe("AT I", timeout: const Duration(milliseconds: 1000));
        if (idResp.isNotEmpty && idResp != "TIMEOUT") {
          adapterResponded = true;
          _elmVersion = idResp;
        }
      }

      // 3. Disable echo, linefeeds, and headers for high parsing speed
      final echoResp = await _sendAtCommandSafe(ObdCommands.echoOff, timeout: const Duration(milliseconds: 900));
      if (echoResp.isNotEmpty && echoResp != "TIMEOUT") {
        adapterResponded = true;
      }

      if (!adapterResponded) {
        _state = ElmDriverState.error;
        return false;
      }

      await _sendAtCommandSafe(ObdCommands.linefeedsOff, timeout: const Duration(milliseconds: 800));
      await _sendAtCommandSafe(ObdCommands.headersOff, timeout: const Duration(milliseconds: 800));
      // Adaptive timing - some clones return '?' on AT AT 1 so we tolerate it
      await _sendAtCommandSafe(ObdCommands.adaptiveTimingOn, timeout: const Duration(milliseconds: 800));
      // Set reasonable ELM timeout (64 = ~400ms, prevents slow freezes)
      await _sendAtCommandSafe("AT ST 64", timeout: const Duration(milliseconds: 800));

      // 4. Read battery voltage (AT RV)
      final voltResp = await _sendAtCommandSafe(ObdCommands.readVoltage, timeout: const Duration(milliseconds: 1200));
      final parsedVolt = HexParser.parseVoltage(voltResp);
      if (parsedVolt != null && parsedVolt > 5.0) {
        _lastBatteryVoltage = parsedVolt;
      }

      // Mark hardware adapter as successfully connected
      _state = ElmDriverState.adapterConnected;

      // 5. Connect to vehicle ECU
      final ecuOk = await connectToEcu(specificProtocolCmd: specificProtocolCmd);
      if (ecuOk) {
        _state = ElmDriverState.ready;
        _isEcuConnected = true;
      } else {
        // Adapter is working, but ECU is not responding (Key might be in OFF/ACC)
        _state = ElmDriverState.adapterConnected;
        _isEcuConnected = false;
      }

      return true;
    } catch (e) {
      _state = ElmDriverState.error;
      return false;
    }
  }

  /// One line per protocol tried during the last connection attempt (for the user and the log).
  final List<String> protocolAttempts = [];

  /// Slow-init buses (ISO 9141-2 / KWP 5-baud) need several seconds for the ECU handshake.
  /// KWP fast-init needs about 3 s. CAN answers or fails within about 1.5 s.
  /// The adapter returns to the prompt as soon as it has an answer or an error,
  /// so a long timeout costs nothing when the car answers quickly.
  static const Map<String, Duration> _protocolTimeouts = {
    "AT SP 0": Duration(seconds: 20), // adapter's own search can try every protocol in turn
    "AT SP 1": Duration(seconds: 4),
    "AT SP 2": Duration(seconds: 4),
    "AT SP 3": Duration(seconds: 10),
    "AT SP 4": Duration(seconds: 10),
    "AT SP 5": Duration(seconds: 6),
    "AT SP 6": Duration(seconds: 3),
    "AT SP 7": Duration(seconds: 3),
    "AT SP 8": Duration(seconds: 3),
    "AT SP 9": Duration(seconds: 3),
  };

  static String _normalizeSp(String cmd) {
    final c = cmd.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (c.startsWith('ATSP') && c.length >= 5) return 'AT SP ${c.substring(4, 5)}';
    return cmd;
  }

  static bool _isKLine(String sp) => const ["AT SP 3", "AT SP 4", "AT SP 5"].contains(sp);

  Future<bool> _tryProtocol(String sp) async {
    sp = _normalizeSp(sp);
    final timeout = _protocolTimeouts[sp] ?? const Duration(seconds: 5);
    final sw = Stopwatch()..start();
    // Wake the adapter if the previous attempt left it busy, then select the protocol.
    await _sendAtCommandSafe("AT SP ${sp.substring(sp.length - 1)}", timeout: const Duration(milliseconds: 900));
    await Future.delayed(const Duration(milliseconds: 60));
    final resp = await executeCommand("0100", timeout: timeout);
    final ok = _isEcuResponseValid(resp);
    protocolAttempts.add("$sp: ${ok ? 'ECU answered' : resp.replaceAll(RegExp(r'\s+'), ' ')} (${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)} s)");
    if (ok) {
      await _resolveActiveProtocol();
      if (_isKLine(sp)) {
        // slow ECUs: allow a longer answer window per request
        await _sendAtCommandSafe("AT ST 96", timeout: const Duration(milliseconds: 800));
      }
      _isEcuConnected = true;
      _state = ElmDriverState.ready;
    }
    return ok;
  }

  /// Negotiate ECU protocol. A chosen protocol is tried first, then the adapter's own
  /// automatic search, then every protocol one by one with a protocol-appropriate wait
  /// (old cars first: slow-init K-line and J1850 before CAN).
  Future<bool> connectToEcu({String? specificProtocolCmd}) async {
    protocolAttempts.clear();
    if (specificProtocolCmd != null && specificProtocolCmd.isNotEmpty && _normalizeSp(specificProtocolCmd) != "AT SP 0") {
      if (await _tryProtocol(specificProtocolCmd)) return true;
    }

    // Adapter's own automatic search (AT SP 0). It prints SEARCHING... and may take 10+ s on old cars.
    final swAuto = Stopwatch()..start();
    await _sendAtCommandSafe(ObdCommands.autoProtocol, timeout: const Duration(milliseconds: 900));
    await Future.delayed(const Duration(milliseconds: 60));
    final auto = await executeCommand("0100", timeout: _protocolTimeouts["AT SP 0"]!);
    final autoOk = _isEcuResponseValid(auto);
    protocolAttempts.add("AT SP 0 (auto): ${autoOk ? 'ECU answered' : auto.replaceAll(RegExp(r'\s+'), ' ')} (${(swAuto.elapsedMilliseconds / 1000).toStringAsFixed(1)} s)");
    if (autoOk) {
      await _resolveActiveProtocol();
      if (_isKLine("AT SP ${_activeProtocolNumber()}")) {
        await _sendAtCommandSafe("AT ST 96", timeout: const Duration(milliseconds: 800));
      }
      _isEcuConnected = true;
      _state = ElmDriverState.ready;
      return true;
    }

    const order = [
      "AT SP 5", // ISO 14230-4 KWP fast init (many Hyundai/Kia/Daewoo/Suzuki)
      "AT SP 3", // ISO 9141-2 (Toyota, Mitsubishi, older Hyundai/Kia, Renault, Peugeot)
      "AT SP 4", // ISO 14230-4 KWP 5-baud init
      "AT SP 2", // SAE J1850 VPW (older GM)
      "AT SP 1", // SAE J1850 PWM (older Ford)
      "AT SP 6", // CAN 11-bit 500k
      "AT SP 7", // CAN 29-bit 500k
      "AT SP 8", // CAN 11-bit 250k
      "AT SP 9", // CAN 29-bit 250k
    ];
    for (final sp in order) {
      if (specificProtocolCmd != null && _normalizeSp(specificProtocolCmd) == sp) continue;
      if (await _tryProtocol(sp)) return true;
    }
    return false;
  }

  String _activeProtocolNumber() {
    final u = _activeProtocol.toUpperCase();
    if (u.contains('14230') && u.contains('FAST')) return '5';
    if (u.contains('14230')) return '4';
    if (u.contains('9141')) return '3';
    if (u.contains('VPW')) return '2';
    if (u.contains('PWM')) return '1';
    return '0';
  }

  /// Check that a 0100 reply is a real positive answer: "41 00" followed by 4 data bytes.
  bool _isEcuResponseValid(String response) {
    if (response == "TIMEOUT" || HexParser.isErrorResponse(response)) return false;
    return RegExp(r'(?<![0-9A-F])41\s?00(\s?[0-9A-F]{2}){4}', caseSensitive: false).hasMatch(response);
  }

  /// Resolve current active OBD protocol name from ELM327
  Future<void> _resolveActiveProtocol() async {
    try {
      final protocolResp = await executeCommand(ObdCommands.readProtocol, timeout: const Duration(seconds: 2));
      if (protocolResp.isNotEmpty && !HexParser.isErrorResponse(protocolResp)) {
        _activeProtocol = protocolResp;
      }
    } catch (_) {}
  }

  /// Refresh battery voltage (AT RV)
  Future<double> refreshBatteryVoltage() async {
    try {
      final resp = await executeCommand(ObdCommands.readVoltage, timeout: const Duration(seconds: 2));
      final v = HexParser.parseVoltage(resp);
      if (v != null && v > 5.0) {
        _lastBatteryVoltage = v;
      }
    } catch (_) {}
    return _lastBatteryVoltage;
  }

  /// Close and dispose resources
  void dispose() {
    _streamSub?.cancel();
    _streamSub = null;
    _state = ElmDriverState.disconnected;
  }
}
