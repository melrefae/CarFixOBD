import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

/// Descriptor for an attached physical USB-OTG or Desktop Serial/RFCOMM port
class SerialDeviceDescriptor {
  final String portId;
  final String displayName;
  final String transportKind; // "USB-OTG", "Bluetooth Serial", "Desktop Serial"
  final int? vid;
  final int? pid;
  final String? chipsetName;
  final String? serialNumber;

  const SerialDeviceDescriptor({
    required this.portId,
    required this.displayName,
    required this.transportKind,
    this.vid,
    this.pid,
    this.chipsetName,
    this.serialNumber,
  });

  bool get isLikelyBluetoothSerial =>
      transportKind.toLowerCase().contains('bluetooth') ||
      (Platform.isMacOS && portId.startsWith('/dev/cu.') && !portId.contains('usb'));
}

/// Abstract serial hardware transport driver for USB-OTG and POSIX serial links
abstract class SerialTransportDriver {
  bool get isOpen;
  Stream<Uint8List> get inputStream;
  void Function()? onDisconnected;

  Future<List<SerialDeviceDescriptor>> listDevices();
  Future<bool> open(String targetPort, int baudRate);
  Future<void> write(Uint8List data);
  Future<void> close();
}

/// Pure Dart FFI POSIX serial transport for macOS and Linux serial/BT SPP devices (`/dev/cu.*`, `/dev/ttyUSB*`, `/dev/ttyACM*`)
class PosixSerialTransport implements SerialTransportDriver {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  int _fd = -1;
  bool _isOpen = false;
  Timer? _readTimer;
  ffi.DynamicLibrary? _libc;

  @override
  bool get isOpen => _isOpen && _fd >= 0;

  @override
  Stream<Uint8List> get inputStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  ffi.DynamicLibrary _loadLibc() {
    if (_libc != null) return _libc!;
    if (Platform.isMacOS) {
      _libc = ffi.DynamicLibrary.open('/usr/lib/libSystem.B.dylib');
    } else if (Platform.isLinux) {
      _libc = ffi.DynamicLibrary.open('libc.so.6');
    } else {
      _libc = ffi.DynamicLibrary.process();
    }
    return _libc!;
  }

  static const Set<String> _ignoredMacPorts = {
    '/dev/cu.Bluetooth-Incoming-Port',
    '/dev/cu.debug-console',
    '/dev/cu.wlan-debug',
  };

  @override
  Future<List<SerialDeviceDescriptor>> listDevices() async {
    if (!Platform.isMacOS && !Platform.isLinux) return [];
    final results = <SerialDeviceDescriptor>[];
    try {
      final devDir = Directory('/dev');
      if (!await devDir.exists()) return [];

      await for (final entity in devDir.list(followLinks: false)) {
        final path = entity.path;
        if (Platform.isMacOS) {
          if (!path.startsWith('/dev/cu.')) continue;
          if (_ignoredMacPorts.contains(path)) continue;
          final shortName = path.replaceFirst('/dev/cu.', '');
          final isUsb = shortName.toLowerCase().contains('usb') ||
              shortName.toLowerCase().contains('slab') ||
              shortName.toLowerCase().contains('wch');
          results.add(SerialDeviceDescriptor(
            portId: path,
            displayName: isUsb ? "USB Serial ($shortName)" : "Mac Serial / BT ($shortName)",
            transportKind: isUsb ? "Desktop USB Serial" : "Bluetooth Serial (macOS)",
            chipsetName: isUsb ? "USB-UART Bridge" : "RFCOMM SPP",
          ));
        } else if (Platform.isLinux) {
          if (path.startsWith('/dev/ttyUSB') ||
              path.startsWith('/dev/ttyACM') ||
              path.startsWith('/dev/rfcomm')) {
            final isBt = path.startsWith('/dev/rfcomm');
            results.add(SerialDeviceDescriptor(
              portId: path,
              displayName: path,
              transportKind: isBt ? "Bluetooth Serial (rfcomm)" : "Linux USB Serial",
              chipsetName: isBt ? "RFCOMM SPP" : "USB-UART",
            ));
          }
        }
      }
    } catch (_) {}
    return results;
  }

  @override
  Future<bool> open(String targetPort, int baudRate) async {
    if (!Platform.isMacOS && !Platform.isLinux) return false;
    await close();

    if (!targetPort.startsWith('/dev/')) return false;
    final entityType = FileSystemEntity.typeSync(targetPort, followLinks: true);
    if (entityType == FileSystemEntityType.notFound) {
      return false;
    }

    try {
      // Open in a worker isolate so BT RFCOMM wake-up does not block the UI thread
      final openedFd = await Isolate.run(() => _openNativePortSync(targetPort)).timeout(
        const Duration(seconds: 7),
        onTimeout: () => -1,
      );

      if (openedFd < 0) {
        return false;
      }

      _fd = openedFd;
      if (!_configurePort(_fd, baudRate)) {
        await close();
        return false;
      }

      _isOpen = true;
      _startPollingFd();
      return true;
    } catch (_) {
      await close();
      return false;
    }
  }

  static int _openNativePortSync(String portPath) {
    final lib = Platform.isMacOS
        ? ffi.DynamicLibrary.open('/usr/lib/libSystem.B.dylib')
        : ffi.DynamicLibrary.open('libc.so.6');
    final openFn = lib.lookupFunction<
        ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Int32),
        int Function(ffi.Pointer<Utf8>, int)>('open');

    final pathPtr = portPath.toNativeUtf8();
    try {
      // macOS: O_RDWR (0x2) | O_NOCTTY (0x20000); Linux: O_RDWR (0x2) | O_NOCTTY (0x100)
      final int flags = Platform.isMacOS ? (0x0002 | 0x20000) : (0x0002 | 0x0100);
      return openFn(pathPtr, flags);
    } finally {
      calloc.free(pathPtr);
    }
  }

  bool _configurePort(int fd, int baudRate) {
    try {
      final lib = _loadLibc();

      final fcntlFn = lib.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32),
          int Function(int, int, int)>('fcntl');
      final tcgetattrFn = lib.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Pointer<ffi.Uint8>),
          int Function(int, ffi.Pointer<ffi.Uint8>)>('tcgetattr');
      final tcsetattrFn = lib.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Pointer<ffi.Uint8>),
          int Function(int, int, ffi.Pointer<ffi.Uint8>)>('tcsetattr');
      final cfsetspeedFn = lib.lookupFunction<
          ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.UnsignedLong),
          int Function(ffi.Pointer<ffi.Uint8>, int)>('cfsetspeed');
      final tcflushFn = lib.lookupFunction<
          ffi.Int32 Function(ffi.Int32, ffi.Int32),
          int Function(int, int)>('tcflush');

      // Switch fd to non-blocking mode for asynchronous Dart event polling
      final curFlags = fcntlFn(fd, 3 /* F_GETFL */, 0);
      final int oNonBlock = Platform.isMacOS ? 0x0004 : 0x0800;
      if (curFlags >= 0) {
        fcntlFn(fd, 4 /* F_SETFL */, curFlags | oNonBlock);
      }

      final termiosPtr = calloc<ffi.Uint8>(128);
      try {
        if (tcgetattrFn(fd, termiosPtr) != 0) {
          return false;
        }

        if (Platform.isMacOS) {
          final bytes = termiosPtr.asTypedList(72).buffer;
          final bd = ByteData.view(bytes);
          // Clear c_iflag, c_oflag, c_lflag for raw mode
          bd.setUint64(0, 0, Endian.host);
          bd.setUint64(8, 0, Endian.host);
          bd.setUint64(24, 0, Endian.host);

          // Set 8N1 + CREAD + CLOCAL on c_cflag
          var cflag = bd.getUint64(16, Endian.host);
          cflag &= ~(0x0300 | 0x1000 | 0x0400); // ~CSIZE, ~PARENB, ~CSTOPB
          cflag |= (0x0300 | 0x0800 | 0x8000);  // CS8 | CREAD | CLOCAL
          bd.setUint64(16, cflag, Endian.host);

          // Set VMIN=0, VTIME=1 in c_cc (offset 32 + 16/17)
          termiosPtr[32 + 16] = 0;
          termiosPtr[32 + 17] = 1;
        } else {
          final bytes = termiosPtr.asTypedList(64).buffer;
          final bd = ByteData.view(bytes);
          bd.setUint32(0, 0, Endian.host);
          bd.setUint32(4, 0, Endian.host);
          bd.setUint32(12, 0, Endian.host);
          var cflag = bd.getUint32(8, Endian.host);
          cflag &= ~(0x0030 | 0x0100 | 0x0040); // ~CSIZE, ~PARENB, ~CSTOPB
          cflag |= (0x0030 | 0x0080 | 0x0800);  // CS8 | CREAD | CLOCAL
          bd.setUint32(8, cflag, Endian.host);
        }

        // Apply baud rate using standard libc cfsetspeed (supports 9600/38400/115200/230400 on macOS)
        final speedVal = Platform.isMacOS ? baudRate : _linuxBaudConstant(baudRate);
        cfsetspeedFn(termiosPtr, speedVal);

        if (tcsetattrFn(fd, 0 /* TCSANOW */, termiosPtr) != 0) {
          return false;
        }
        tcflushFn(fd, 3 /* TCIOFLUSH */);
        return true;
      } finally {
        calloc.free(termiosPtr);
      }
    } catch (_) {
      return false;
    }
  }

  int _linuxBaudConstant(int baud) {
    switch (baud) {
      case 9600:
        return 13; // B9600
      case 38400:
        return 15; // B38400
      case 115200:
        return 4098; // B115200
      case 230400:
        return 4099; // B230400
      default:
        return 4098;
    }
  }

  void _startPollingFd() {
    _readTimer?.cancel();
    final lib = _loadLibc();
    final readFn = lib.lookupFunction<
        ffi.IntPtr Function(ffi.Int32, ffi.Pointer<ffi.Uint8>, ffi.Size),
        int Function(int, ffi.Pointer<ffi.Uint8>, int)>('read');

    final readBuf = calloc<ffi.Uint8>(512);
    _readTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!_isOpen || _fd < 0) {
        timer.cancel();
        calloc.free(readBuf);
        return;
      }

      final n = readFn(_fd, readBuf, 512);
      if (n > 0) {
        final copy = Uint8List.fromList(readBuf.asTypedList(n));
        if (!_controller.isClosed) {
          _controller.add(copy);
        }
      } else if (n == 0) {
        // EOF on serial stream (peer closed)
        _isOpen = false;
        timer.cancel();
        calloc.free(readBuf);
        close();
        onDisconnected?.call();
      }
    });
  }

  @override
  Future<void> write(Uint8List data) async {
    if (!isOpen) throw Exception("Serial port is not open.");
    final lib = _loadLibc();
    final writeFn = lib.lookupFunction<
        ffi.IntPtr Function(ffi.Int32, ffi.Pointer<ffi.Uint8>, ffi.Size),
        int Function(int, ffi.Pointer<ffi.Uint8>, int)>('write');

    final buf = calloc<ffi.Uint8>(data.length);
    try {
      buf.asTypedList(data.length).setAll(0, data);
      int written = 0;
      int attempts = 0;
      while (written < data.length && attempts < 20) {
        final n = writeFn(_fd, buf + written, data.length - written);
        if (n > 0) {
          written += n;
        } else {
          attempts++;
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }
    } finally {
      calloc.free(buf);
    }
  }

  @override
  Future<void> close() async {
    _isOpen = false;
    _readTimer?.cancel();
    _readTimer = null;
    if (_fd >= 0) {
      final fdToClose = _fd;
      _fd = -1;
      try {
        final lib = _loadLibc();
        final closeFn = lib.lookupFunction<
            ffi.Int32 Function(ffi.Int32),
            int Function(int)>('close');
        closeFn(fdToClose);
      } catch (_) {}
    }
  }
}
