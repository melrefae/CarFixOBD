import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'obd_connection.dart';
import '../../core/utils/app_logger.dart';

/// Bluetooth Low Energy (BLE 4.0 / 5.0) GATT Service Profile for OBD-II Adapters
class BleGattProfile {
  final String serviceUuid;
  final String rxCharacteristicUuid;
  final String txCharacteristicUuid;
  final String adapterBrand;

  const BleGattProfile({
    required this.serviceUuid,
    required this.rxCharacteristicUuid,
    required this.txCharacteristicUuid,
    required this.adapterBrand,
  });

  static const List<BleGattProfile> standardProfiles = [
    // 1. Nordic Semiconductor UART Service (Veepeak, Vgate iCar Pro BLE)
    BleGattProfile(
      serviceUuid: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E",
      rxCharacteristicUuid: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E",
      txCharacteristicUuid: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E",
      adapterBrand: "Veepeak BLE+ / Vgate iCar Pro BLE4.0",
    ),
    // 2. Transparent Serial Service FFF0 (Carista, Tonwon BLE, LELink)
    BleGattProfile(
      serviceUuid: "0000FFF0-0000-1000-8000-00805F9B34FB",
      rxCharacteristicUuid: "0000FFF1-0000-1000-8000-00805F9B34FB",
      txCharacteristicUuid: "0000FFF2-0000-1000-8000-00805F9B34FB",
      adapterBrand: "Carista BLE / LELink OBD-II / Tonwon",
    ),
    // 3. OBDLink CX / MX+ BLE GATT
    BleGattProfile(
      serviceUuid: "000018F0-0000-1000-8000-00805F9B34FB",
      rxCharacteristicUuid: "00002AF1-0000-1000-8000-00805F9B34FB",
      txCharacteristicUuid: "00002AF0-0000-1000-8000-00805F9B34FB",
      adapterBrand: "OBDLink CX / MX+ BLE (BimmerCode certified)",
    ),
    // 4. HM-10 / CC2541 Transparent UART (Generic ELM327 BLE clones)
    BleGattProfile(
      serviceUuid: "0000FFE0-0000-1000-8000-00805F9B34FB",
      rxCharacteristicUuid: "0000FFE1-0000-1000-8000-00805F9B34FB",
      txCharacteristicUuid: "0000FFE1-0000-1000-8000-00805F9B34FB",
      adapterBrand: "Generic HM-10 / CC2541 ELM327 BLE",
    ),
  ];
}

/// Discovered nearby BLE peripheral candidate
class BleScannedDevice {
  final String remoteId;
  final String name;
  final int rssi;
  final List<String> serviceUuids;
  final bool isKnownObd;
  final String matchedProfileBrand;

  const BleScannedDevice({
    required this.remoteId,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
    required this.isKnownObd,
    required this.matchedProfileBrand,
  });
}

/// Abstract BLE GATT transport driver for clean hardware vs test separation
abstract class BleTransportDriver {
  bool get isConnected;
  BleGattProfile? get matchedProfile;
  Stream<Uint8List> get incomingBytesStream;
  void Function()? onDisconnected;

  Future<List<BleScannedDevice>> scanObdDevices({Duration timeout = const Duration(seconds: 4)});
  Future<bool> connect(String target);
  Future<void> writeBytes(Uint8List bytes);
  Future<void> disconnect();
}

/// Production BLE GATT transport backed by `flutter_blue_plus`
class FlutterBluePlusBleTransport implements BleTransportDriver {
  fbp.BluetoothDevice? _device;
  fbp.BluetoothCharacteristic? _writeChar;
  fbp.BluetoothCharacteristic? _notifyChar;
  BleGattProfile? _matchedProfile;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<fbp.BluetoothConnectionState>? _connStateSub;
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _isConnected = false;
  int _chunkSize = 20;

  @override
  bool get isConnected => _isConnected && _device != null && _device!.isConnected;

  @override
  BleGattProfile? get matchedProfile => _matchedProfile;

  @override
  Stream<Uint8List> get incomingBytesStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  static final RegExp _macOrUuidPattern = RegExp(
    r'^([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}$|^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$',
  );

  static String _shortUuid(String fullUuid) {
    final upper = fullUuid.toUpperCase();
    if (upper.startsWith('0000') && upper.endsWith('-0000-1000-8000-00805F9B34FB') && upper.length >= 8) {
      return upper.substring(4, 8);
    }
    return upper;
  }

  static bool _isKnownObdUuid(String uuid) {
    final s = _shortUuid(uuid).toLowerCase();
    for (final p in BleGattProfile.standardProfiles) {
      if (_shortUuid(p.serviceUuid).toLowerCase() == s || p.serviceUuid.toLowerCase() == uuid.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  static bool _looksLikeObdName(String name) {
    final u = name.toUpperCase();
    return u.contains('OBD') ||
        u.contains('ELM') ||
        u.contains('VGATE') ||
        u.contains('VLINKER') ||
        u.contains('V-LINK') ||
        u.contains('IOS-VLINK') ||
        u.contains('OBDLINK') ||
        u.contains('VEEPEAK') ||
        u.contains('CARISTA') ||
        u.contains('VIECAR') ||
        u.contains('KONNWEI') ||
        u.contains('NEXLINK') ||
        u.contains('LELINK') ||
        u.contains('TONWON') ||
        u.contains('UNICARSCAN');
  }

  @override
  Future<List<BleScannedDevice>> scanObdDevices({Duration timeout = const Duration(seconds: 4)}) async {
    final map = <String, BleScannedDevice>{};
    try {
      if (!await fbp.FlutterBluePlus.isSupported) return [];

      // Check already connected / bonded BLE devices on Android first
      if (Platform.isAndroid) {
        try {
          final bonded = await fbp.FlutterBluePlus.bondedDevices;
          for (final d in bonded) {
            final name = d.platformName.isNotEmpty ? d.platformName : d.advName;
            final known = _looksLikeObdName(name);
            map[d.remoteId.str] = BleScannedDevice(
              remoteId: d.remoteId.str,
              name: name.isNotEmpty ? name : d.remoteId.str,
              rssi: -55,
              serviceUuids: const [],
              isKnownObd: known,
              matchedProfileBrand: known ? "Paired BLE OBD Candidate" : "Bonded BLE Device",
            );
          }
        } catch (_) {}
      }

      final sub = fbp.FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final advName = r.advertisementData.advName.isNotEmpty
              ? r.advertisementData.advName
              : r.device.platformName;
          final uuids = r.advertisementData.serviceUuids.map((g) => g.str).toList();
          final hasObdUuid = uuids.any(_isKnownObdUuid);
          final known = hasObdUuid || _looksLikeObdName(advName);

          // Skip completely anonymous unnamed non-OBD beacons
          if (advName.isEmpty && !hasObdUuid) continue;

          String brand = known ? "OBD-II BLE Adapter" : "BLE Device";
          for (final u in uuids) {
            for (final prof in BleGattProfile.standardProfiles) {
              if (_shortUuid(prof.serviceUuid).toLowerCase() == _shortUuid(u).toLowerCase()) {
                brand = prof.adapterBrand;
                break;
              }
            }
          }

          map[r.device.remoteId.str] = BleScannedDevice(
            remoteId: r.device.remoteId.str,
            name: advName.isNotEmpty ? advName : r.device.remoteId.str,
            rssi: r.rssi,
            serviceUuids: uuids,
            isKnownObd: known,
            matchedProfileBrand: brand,
          );
        }
      });

      await fbp.FlutterBluePlus.startScan(timeout: timeout);
      await Future.delayed(timeout + const Duration(milliseconds: 250));
      await fbp.FlutterBluePlus.stopScan();
      await sub.cancel();
    } catch (e) {
      AppLogger().warning("BLE scan error: $e");
    }

    final list = map.values.toList();
    list.sort((a, b) {
      if (a.isKnownObd != b.isKnownObd) return a.isKnownObd ? -1 : 1;
      return b.rssi.compareTo(a.rssi);
    });
    return list;
  }

  @override
  Future<bool> connect(String target) async {
    await disconnect();

    try {
      if (!await fbp.FlutterBluePlus.isSupported) return false;

      fbp.BluetoothDevice? targetDevice;
      final trimmed = target.trim();

      if (_macOrUuidPattern.hasMatch(trimmed)) {
        targetDevice = fbp.BluetoothDevice.fromId(trimmed);
      } else {
        // Resolve friendly name or keyword from active BLE scan
        final scanned = await scanObdDevices(timeout: const Duration(seconds: 4));
        BleScannedDevice? match;
        for (final d in scanned) {
          if (d.name.toLowerCase() == trimmed.toLowerCase() ||
              d.name.toLowerCase().contains(trimmed.toLowerCase()) ||
              d.remoteId.toLowerCase() == trimmed.toLowerCase()) {
            match = d;
            break;
          }
        }
        match ??= scanned.where((d) => d.isKnownObd).isNotEmpty
            ? scanned.firstWhere((d) => d.isKnownObd)
            : null;
        if (match == null) return false;
        targetDevice = fbp.BluetoothDevice.fromId(match.remoteId);
      }

      await targetDevice.connect(
        timeout: const Duration(seconds: 8),
        mtu: null,
        autoConnect: false,
      );

      _device = targetDevice;

      // Best-effort MTU negotiation for faster CAN/ISO-TP responses
      int mtu = 23;
      if (Platform.isAndroid) {
        try {
          mtu = await targetDevice.requestMtu(247).timeout(const Duration(seconds: 2));
        } catch (_) {
          mtu = targetDevice.mtuNow;
        }
      } else {
        mtu = targetDevice.mtuNow;
      }
      _chunkSize = (mtu - 3).clamp(20, 240);

      final services = await targetDevice.discoverServices();
      if (!_selectUartCharacteristics(services)) {
        await disconnect();
        return false;
      }

      _isConnected = true;

      _connStateSub?.cancel();
      _connStateSub = targetDevice.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected && _isConnected) {
          _isConnected = false;
          onDisconnected?.call();
        }
      });

      _notifySub?.cancel();
      _notifySub = _notifyChar!.onValueReceived.listen((bytes) {
        if (bytes.isNotEmpty && !_controller.isClosed) {
          _controller.add(Uint8List.fromList(bytes));
        }
      });

      await _notifyChar!.setNotifyValue(true);
      await Future.delayed(const Duration(milliseconds: 120));
      return true;
    } catch (e) {
      AppLogger().error("BLE GATT connect failed: $e");
      await disconnect();
      return false;
    }
  }

  bool _selectUartCharacteristics(List<fbp.BluetoothService> services) {
    // Pass 1: Match known OBD GATT profiles (handling swapped RX/TX characteristics cleanly)
    for (final profile in BleGattProfile.standardProfiles) {
      final targetSvcShort = _shortUuid(profile.serviceUuid).toLowerCase();
      for (final svc in services) {
        final svcShort = _shortUuid(svc.serviceUuid.str).toLowerCase();
        if (svcShort != targetSvcShort &&
            svc.serviceUuid.str.toLowerCase() != profile.serviceUuid.toLowerCase()) {
          continue;
        }

        fbp.BluetoothCharacteristic? writer;
        fbp.BluetoothCharacteristic? notifier;

        for (final c in svc.characteristics) {
          final canWrite = c.properties.write || c.properties.writeWithoutResponse;
          final canNotify = c.properties.notify || c.properties.indicate;
          final cShort = _shortUuid(c.characteristicUuid.str).toLowerCase();
          final rxShort = _shortUuid(profile.rxCharacteristicUuid).toLowerCase();
          final txShort = _shortUuid(profile.txCharacteristicUuid).toLowerCase();

          if (cShort == rxShort && canWrite) writer = c;
          if (cShort == txShort && canNotify) notifier = c;
        }

        // Some adapters reverse FFF1/FFF2 roles — auto-detect by GATT properties inside the service
        if (writer == null || notifier == null) {
          for (final c in svc.characteristics) {
            if (writer == null && (c.properties.write || c.properties.writeWithoutResponse)) {
              writer = c;
            }
            if (notifier == null && (c.properties.notify || c.properties.indicate)) {
              notifier = c;
            }
          }
        }

        if (writer != null && notifier != null) {
          _writeChar = writer;
          _notifyChar = notifier;
          _matchedProfile = profile;
          return true;
        }
      }
    }

    // Pass 2: Dynamic fallback — pick any custom non-SIG service offering Write + Notify
    const ignoredSigServices = {'1800', '1801', '180A', '180F'};
    for (final svc in services) {
      final short = _shortUuid(svc.serviceUuid.str);
      if (ignoredSigServices.contains(short)) continue;

      fbp.BluetoothCharacteristic? writer;
      fbp.BluetoothCharacteristic? notifier;
      for (final c in svc.characteristics) {
        if (writer == null && (c.properties.write || c.properties.writeWithoutResponse)) {
          writer = c;
        }
        if (notifier == null && (c.properties.notify || c.properties.indicate)) {
          notifier = c;
        }
      }

      if (writer != null && notifier != null) {
        _writeChar = writer;
        _notifyChar = notifier;
        _matchedProfile = BleGattProfile(
          serviceUuid: svc.serviceUuid.str,
          rxCharacteristicUuid: writer.characteristicUuid.str,
          txCharacteristicUuid: notifier.characteristicUuid.str,
          adapterBrand: "Dynamic BLE OBD GATT",
        );
        return true;
      }
    }

    return false;
  }

  @override
  Future<void> writeBytes(Uint8List bytes) async {
    if (!isConnected || _writeChar == null) {
      throw Exception("BLE GATT adapter is not connected.");
    }

    final useWithoutResponse =
        _writeChar!.properties.writeWithoutResponse && !_writeChar!.properties.write;

    for (int offset = 0; offset < bytes.length; offset += _chunkSize) {
      final end = (offset + _chunkSize < bytes.length) ? offset + _chunkSize : bytes.length;
      final chunk = bytes.sublist(offset, end);
      await _writeChar!.write(chunk, withoutResponse: useWithoutResponse);
      if (end < bytes.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    await _notifySub?.cancel();
    _notifySub = null;
    await _connStateSub?.cancel();
    _connStateSub = null;
    _writeChar = null;
    _notifyChar = null;
    _matchedProfile = null;
    try {
      await _device?.disconnect();
    } catch (_) {}
    _device = null;
  }
}

/// Deterministic loopback BLE transport used ONLY inside Dart VM automated unit tests
class _TestLoopbackBleTransport implements BleTransportDriver {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  BleGattProfile? get matchedProfile => BleGattProfile.standardProfiles.first;

  @override
  Stream<Uint8List> get incomingBytesStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  @override
  Future<List<BleScannedDevice>> scanObdDevices({Duration timeout = const Duration(seconds: 4)}) async =>
      const [];

  @override
  Future<bool> connect(String target) async {
    _connected = true;
    return true;
  }

  @override
  Future<void> writeBytes(Uint8List bytes) async {
    if (!_connected) throw Exception("BLE adapter is not connected.");
    if (!_controller.isClosed) {
      _controller.add(Uint8List.fromList(utf8.encode("OK\r>")));
    }
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }
}

/// Bluetooth Low Energy (BLE 4.0 / 5.0) OBD-II Connection Implementation
class BleObdConnection implements ObdConnection {
  final BleTransportDriver _transport;
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  StreamSubscription<Uint8List>? _transportSub;
  bool _isConnected = false;
  String _deviceId = "";
  BleGattProfile? _activeGattProfile;
  void Function()? onDisconnected;

  BleObdConnection({BleTransportDriver? transport})
      : _transport = transport ?? _resolveDefaultTransport();

  static BleTransportDriver _resolveDefaultTransport() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return _TestLoopbackBleTransport();
    }
    return FlutterBluePlusBleTransport();
  }

  /// Scan for nearby physical BLE 4.0/5.0 OBD-II adapters
  static Future<List<BleScannedDevice>> scanObdDevices({
    Duration timeout = const Duration(seconds: 4),
    BleTransportDriver? transport,
  }) {
    return (transport ?? _resolveDefaultTransport()).scanObdDevices(timeout: timeout);
  }

  @override
  bool get isConnected => _isConnected && _transport.isConnected;

  @override
  String get connectionType => "Bluetooth LE (BLE 4.0/5.0)";

  String get deviceId => _deviceId;
  BleGattProfile? get activeGattProfile => _activeGattProfile;

  List<String> get knownObdGattProfiles =>
      BleGattProfile.standardProfiles.map((p) => p.serviceUuid.toLowerCase()).toList();

  @override
  Stream<String> get responseStream => _responseController.stream;

  Stream<List<int>> get inputStream => _responseController.stream.map((s) => utf8.encode(s));

  Future<void> write(List<int> bytes) async {
    if (!isConnected) {
      throw Exception("BLE adapter is not connected.");
    }
    final str = utf8.decode(bytes, allowMalformed: true);
    AppLogger().tx("[BLE GATT] $str");
    await _transport.writeBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<bool> connect(String target) async {
    try {
      await disconnect();
      _deviceId = target;

      AppLogger().info("Connecting to BLE OBD adapter ($target)...");

      _transport.onDisconnected = () {
        _isConnected = false;
        onDisconnected?.call();
      };

      final ok = await _transport.connect(target);
      if (!ok) {
        _isConnected = false;
        return false;
      }

      _activeGattProfile = _transport.matchedProfile ?? BleGattProfile.standardProfiles.first;
      _isConnected = true;

      await _transportSub?.cancel();
      _transportSub = _transport.incomingBytesStream.listen(
        (Uint8List data) => ingestNotification(data),
        onError: (_) {
          _isConnected = false;
          onDisconnected?.call();
        },
        onDone: () {
          _isConnected = false;
          onDisconnected?.call();
        },
      );

      return true;
    } catch (e) {
      AppLogger().error("BLE connection failed: $e");
      _isConnected = false;
      return false;
    }
  }

  /// Ingest incoming notifications / indications from BLE characteristic
  void ingestNotification(Uint8List value) {
    if (!_isConnected) return;
    final text = utf8.decode(value, allowMalformed: true);
    _responseController.add(text);
  }

  /// Alias for ingestNotification
  void ingestIncomingBytes(Uint8List value) => ingestNotification(value);

  @override
  Future<void> send(String command) async {
    if (!isConnected) {
      throw Exception("BLE adapter is not connected.");
    }

    final formatted = command.endsWith('\r') ? command : '$command\r';
    AppLogger().tx("[BLE GATT] $formatted");
    await _transport.writeBytes(Uint8List.fromList(utf8.encode(formatted)));
  }

  @override
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _transportSub?.cancel();
      _transportSub = null;
      await _transport.disconnect();
      _deviceId = "";
      _activeGattProfile = null;
    } catch (_) {}
  }
}
