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

  /// Negotiate ECU protocol (Auto protocol or prioritized fast fallback cycle)
  Future<bool> connectToEcu({String? specificProtocolCmd}) async {
    // If vehicle profile has a specific protocol (e.g. Nissan/Elantra AT SP 6 or Verna AT SP 3/5)
    if (specificProtocolCmd != null && specificProtocolCmd.isNotEmpty && specificProtocolCmd != "AT SP 0") {
      await _sendAtCommandSafe(specificProtocolCmd, timeout: const Duration(milliseconds: 800));
      await Future.delayed(const Duration(milliseconds: 60));
      final resp = await executeCommand("0100", timeout: const Duration(seconds: 2));
      if (_isEcuResponseValid(resp)) {
        await _resolveActiveProtocol();
        _isEcuConnected = true;
        _state = ElmDriverState.ready;
        return true;
      }
    }

    // Try Auto Protocol (AT SP 0)
    await _sendAtCommandSafe(ObdCommands.autoProtocol, timeout: const Duration(milliseconds: 800));
    await Future.delayed(const Duration(milliseconds: 60));

    // First attempt on 0100 (triggers ELM327 protocol search)
    var ecuCheck = await executeCommand("0100", timeout: const Duration(seconds: 3));
    if (_isEcuResponseValid(ecuCheck)) {
      await _resolveActiveProtocol();
      _isEcuConnected = true;
      _state = ElmDriverState.ready;
      return true;
    }

    // Second fast attempt if searching was actively reported
    if (ecuCheck.contains("SEARCHING")) {
      await Future.delayed(const Duration(milliseconds: 150));
      ecuCheck = await executeCommand("0100", timeout: const Duration(seconds: 2));
      if (_isEcuResponseValid(ecuCheck)) {
        await _resolveActiveProtocol();
        _isEcuConnected = true;
        _state = ElmDriverState.ready;
        return true;
      }
    }

    // Prioritized fast fallback cycle: CAN 11/500, CAN 29/500, KWP Fast, ISO 9141
    final fallbackProtocols = [
      ("AT SP 6", const Duration(milliseconds: 1200)), // ISO 15765-4 CAN 11/500 (>85% of modern vehicles)
      ("AT SP 7", const Duration(milliseconds: 1200)), // ISO 15765-4 CAN 29/500 (Euro & heavy CAN)
      ("AT SP 5", const Duration(milliseconds: 1500)), // ISO 14230-4 KWP Fast Init (Hyundai Verna, Lanos, Aveo)
      ("AT SP 3", const Duration(milliseconds: 1500)), // ISO 9141-2 (Japanese/Asian imports)
      ("AT SP 8", const Duration(milliseconds: 1000)), // ISO 15765-4 CAN 11/250
      ("AT SP 9", const Duration(milliseconds: 1000)), // ISO 15765-4 CAN 29/250
      ("AT SP 4", const Duration(milliseconds: 1500)), // ISO 14230-4 KWP 5-Baud Init
      ("AT SP 1", const Duration(milliseconds: 1000)), // SAE J1850 PWM (Ford)
      ("AT SP 2", const Duration(milliseconds: 1000)), // SAE J1850 VPW (GM)
    ];

    for (final entry in fallbackProtocols) {
      final proto = entry.$1;
      final protoTimeout = entry.$2;
      await _sendAtCommandSafe(proto, timeout: const Duration(milliseconds: 600));
      await Future.delayed(const Duration(milliseconds: 40));
      final testResp = await executeCommand("0100", timeout: protoTimeout);
      if (_isEcuResponseValid(testResp)) {
        await _resolveActiveProtocol();
        _isEcuConnected = true;
        _state = ElmDriverState.ready;
        return true;
      }
    }

    return false;
  }

  /// Check if 0100 response indicates a valid ECU response
  bool _isEcuResponseValid(String response) {
    if (response == "TIMEOUT" || HexParser.isErrorResponse(response)) {
      return false;
    }
    // Mode 01 response starts with 41
    final clean = response.toUpperCase();
    return clean.contains("41") || clean.contains("4100") || clean.contains("41 00");
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
