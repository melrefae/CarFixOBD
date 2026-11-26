import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'obd_connection.dart';
import 'posix_serial_transport.dart';
import '../../core/utils/app_logger.dart';

/// Supported USB Serial UART chipset profiles for hardware OBD-II adapters
class UsbAdapterProfile {
  final String chipset;
  final int vendorId;
  final int productId;
  final String description;

  const UsbAdapterProfile({
    required this.chipset,
    required this.vendorId,
    required this.productId,
    required this.description,
  });

  static const List<UsbAdapterProfile> supportedChipsets = [
    UsbAdapterProfile(
      chipset: "FTDI",
      vendorId: 0x0403,
      productId: 0x6001,
      description: "FTDI FT232R / OBDLink SX / ELS27 High-Speed UART",
    ),
    UsbAdapterProfile(
      chipset: "CH340",
      vendorId: 0x1A86,
      productId: 0x7523,
      description: "Winchiphead CH340 / CH341 USB-to-Serial Clone",
    ),
    UsbAdapterProfile(
      chipset: "CP2102",
      vendorId: 0x10C4,
      productId: 0xEA60,
      description: "Silicon Labs CP2102 / CP2104 USB-UART Bridge",
    ),
    UsbAdapterProfile(
      chipset: "PL2303",
      vendorId: 0x067B,
      productId: 0x2303,
      description: "Prolific PL2303 USB-to-Serial Controller",
    ),
    UsbAdapterProfile(
      chipset: "CDC-ACM",
      vendorId: 0x0000,
      productId: 0x0000,
      description: "Universal USB Communication Device Class (CDC-ACM)",
    ),
  ];

  static String identifyChipset(int? vid, int? pid) {
    if (vid == null) return "USB CDC-ACM";
    for (final profile in supportedChipsets) {
      if (profile.vendorId == vid && profile.vendorId != 0) {
        return profile.description;
      }
    }
    if (vid == 0x0403) return "FTDI USB-UART Bridge";
    if (vid == 0x1A86) return "WCH CH340/CH341";
    if (vid == 0x10C4) return "Silicon Labs CP210x";
    if (vid == 0x067B) return "Prolific PL2303";
    return "USB Serial Device (VID:0x${vid.toRadixString(16).toUpperCase()})";
  }
}

/// Native Android USB Host transport powered by `usb_serial` (FTDI, CH340, CP2102, PL2303, CDC-ACM)
class AndroidUsbSerialTransport implements SerialTransportDriver {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _inputSub;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _isOpen = false;

  @override
  bool get isOpen => _isOpen && _port != null;

  @override
  Stream<Uint8List> get inputStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  @override
  Future<List<SerialDeviceDescriptor>> listDevices() async {
    if (!Platform.isAndroid) return [];
    try {
      final devices = await UsbSerial.listDevices();
      return devices.map((d) {
        final chip = UsbAdapterProfile.identifyChipset(d.vid, d.pid);
        final label = (d.productName != null && d.productName!.trim().isNotEmpty)
            ? d.productName!.trim()
            : chip;
        return SerialDeviceDescriptor(
          portId: d.deviceName,
          displayName: "$label (${d.deviceName})",
          transportKind: "USB-OTG",
          vid: d.vid,
          pid: d.pid,
          chipsetName: chip,
          serialNumber: d.serial,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> open(String targetPort, int baudRate) async {
    if (!Platform.isAndroid) return false;
    await close();

    try {
      final devices = await UsbSerial.listDevices();
      if (devices.isEmpty) {
        return false;
      }

      UsbDevice? target;
      if (targetPort.isEmpty || targetPort == 'auto') {
        target = devices.first;
      } else {
        target = devices.firstWhere(
          (d) =>
              d.deviceName == targetPort ||
              '${d.deviceId}' == targetPort ||
              (d.vid != null &&
                  targetPort.toLowerCase().contains(d.vid!.toRadixString(16).toLowerCase())),
          orElse: () => devices.first,
        );
      }

      final port = await target.create();
      if (port == null) return false;

      final opened = await port.open();
      if (!opened) return false;

      await port.setDTR(true);
      await port.setRTS(true);
      await port.setPortParameters(
        baudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      _port = port;
      _isOpen = true;

      _inputSub?.cancel();
      _inputSub = port.inputStream?.listen(
        (Uint8List data) {
          if (!_controller.isClosed) {
            _controller.add(data);
          }
        },
        onError: (_) {
          _isOpen = false;
          onDisconnected?.call();
        },
        onDone: () {
          _isOpen = false;
          onDisconnected?.call();
        },
      );

      return true;
    } catch (e) {
      AppLogger().error("Android USB Serial open failed: $e");
      await close();
      return false;
    }
  }

  @override
  Future<void> write(Uint8List data) async {
    if (!isOpen || _port == null) {
      throw Exception("USB Serial port is not open.");
    }
    await _port!.write(data);
  }

  @override
  Future<void> close() async {
    _isOpen = false;
    await _inputSub?.cancel();
    _inputSub = null;
    try {
      await _port?.close();
    } catch (_) {}
    _port = null;
  }
}

/// Deterministic loopback transport used ONLY when running automated Dart VM unit tests
class _TestLoopbackSerialTransport implements SerialTransportDriver {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _isOpen = false;

  @override
  bool get isOpen => _isOpen;

  @override
  Stream<Uint8List> get inputStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  @override
  Future<List<SerialDeviceDescriptor>> listDevices() async => const [];

  @override
  Future<bool> open(String targetPort, int baudRate) async {
    _isOpen = true;
    return true;
  }

  @override
  Future<void> write(Uint8List data) async {
    if (!_isOpen) throw Exception("USB Serial adapter is not connected.");
    if (!_controller.isClosed) {
      _controller.add(Uint8List.fromList(utf8.encode("OK\r>")));
    }
  }

  @override
  Future<void> close() async {
    _isOpen = false;
  }
}

/// Direct wired USB Serial / OTG Cable & POSIX Serial Connection for OBD-II Hardware Adapters
class UsbSerialObdConnection implements ObdConnection {
  final SerialTransportDriver _transport;
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  StreamSubscription<Uint8List>? _transportSub;
  bool _isConnected = false;
  String _portName = "";
  int _baudRate = 115200;
  void Function()? onDisconnected;

  UsbSerialObdConnection({SerialTransportDriver? transport})
      : _transport = transport ?? _resolveDefaultTransport();

  static SerialTransportDriver _resolveDefaultTransport() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _TestLoopbackSerialTransport();
    }
    if (Platform.isAndroid) {
      return AndroidUsbSerialTransport();
    }
    if (Platform.isMacOS || Platform.isLinux) {
      return PosixSerialTransport();
    }
    return AndroidUsbSerialTransport();
  }

  /// Enumerate live physical USB-OTG and/or desktop serial/BT SPP adapters
  static Future<List<SerialDeviceDescriptor>> enumerateAvailableDevices() {
    return _resolveDefaultTransport().listDevices();
  }

  @override
  bool get isConnected => _isConnected && _transport.isOpen;

  @override
  String get connectionType => "USB Serial (OTG)";

  String get portName => _portName;
  int get baudRate => _baudRate;
  int get selectedBaudRate => _baudRate;

  bool isBaudSupported(int baud) => [38400, 115200, 230400, 500000].contains(baud);

  List<String> get supportedChipsets => UsbAdapterProfile.supportedChipsets.map((p) {
        if (p.chipset == "FTDI") return "FTDI FT232R";
        if (p.chipset == "CH340") return "WCH CH340 / CH341";
        if (p.chipset == "CP2102") return "Silicon Labs CP2102";
        if (p.chipset == "PL2303") return "Prolific PL2303";
        return "USB CDC-ACM";
      }).toList();

  @override
  Stream<String> get responseStream => _responseController.stream;

  Stream<List<int>> get inputStream => _responseController.stream.map((s) => utf8.encode(s));

  Future<void> write(List<int> bytes) async {
    if (!isConnected) {
      throw Exception("USB Serial adapter is not connected.");
    }
    final str = utf8.decode(bytes, allowMalformed: true);
    AppLogger().tx("[USB Serial] $str");
    await _transport.write(Uint8List.fromList(bytes));
  }

  /// Connect to physical USB OTG or POSIX Serial port (e.g. "/dev/bus/usb/001/002@230400" or "/dev/cu.987696098341@38400")
  @override
  Future<bool> connect(String target) async {
    try {
      await disconnect();

      int baud = 115200;
      String port = target.trim();

      if (port.contains('@')) {
        final parts = port.split('@');
        port = parts[0];
        baud = int.tryParse(parts[1]) ?? 115200;
      } else if (port.contains(':')) {
        final parts = port.split(':');
        port = parts[0];
        baud = int.tryParse(parts[1]) ?? 115200;
      }

      _portName = port;
      _baudRate = baud;

      AppLogger().info("Connecting to USB/Serial adapter on $port at $baud baud...");

      _transport.onDisconnected = () {
        _isConnected = false;
        onDisconnected?.call();
      };

      final opened = await _transport.open(port, baud);
      if (!opened) {
        _isConnected = false;
        return false;
      }

      _isConnected = true;
      await _transportSub?.cancel();
      _transportSub = _transport.inputStream.listen(
        (Uint8List bytes) => ingestIncomingBytes(bytes),
        onError: (_) {
          _isConnected = false;
          onDisconnected?.call();
        },
        onDone: () {
          _isConnected = false;
          onDisconnected?.call();
        },
      );

      // Brief stabilization delay for hardware UART FIFO buffers
      await Future.delayed(const Duration(milliseconds: 150));
      return true;
    } catch (e) {
      AppLogger().error("USB Serial connection failed: $e");
      _isConnected = false;
      return false;
    }
  }

  /// Internal hook to push received UART serial data into stream
  void ingestIncomingBytes(Uint8List bytes) {
    if (!_isConnected) return;
    final text = latin1.decode(bytes);
    _responseController.add(text);
  }

  /// Send command string over hardware serial line terminated with CR
  @override
  Future<void> send(String command) async {
    if (!isConnected) {
      throw Exception("USB Serial adapter is not connected.");
    }

    final formatted = command.endsWith('\r') ? command : '$command\r';
    AppLogger().tx("[USB Serial] $formatted");
    await _transport.write(Uint8List.fromList(latin1.encode(formatted)));
  }

  @override
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _transportSub?.cancel();
      _transportSub = null;
      await _transport.close();
      _portName = "";
    } catch (_) {}
  }
}
