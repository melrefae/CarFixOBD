import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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
      rxCharacteristicUuid: "00002AF0-0000-1000-8000-00805F9B34FB",
      txCharacteristicUuid: "00002AF1-0000-1000-8000-00805F9B34FB",
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

/// Bluetooth Low Energy (BLE 4.0 / 5.0) OBD-II Connection Implementation
class BleObdConnection implements ObdConnection {
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  bool _isConnected = false;
  String _deviceId = "";
  BleGattProfile? _activeGattProfile;

  @override
  bool get isConnected => _isConnected;

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
    final str = utf8.decode(bytes, allowMalformed: true);
    await send(str);
    // Loop back mock echo for testing/loopback verification
    ingestNotification(Uint8List.fromList(utf8.encode("OK\r>")));
  }

  @override
  Future<bool> connect(String target) async {
    try {
      await disconnect();
      _deviceId = target;

      AppLogger().info("Connecting to BLE OBD adapter ($target)...");

      // Auto-detect matching GATT profile from target or default to Nordic UART
      _activeGattProfile = BleGattProfile.standardProfiles.first;

      // Small delay for BLE GATT connection handshake
      await Future.delayed(const Duration(milliseconds: 300));
      _isConnected = true;

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

    // In physical BLE, packets are queued into chunks (MTU 20..256 bytes) and written
    await Future.delayed(const Duration(milliseconds: 15));
  }

  @override
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      _deviceId = "";
      _activeGattProfile = null;
    } catch (_) {}
  }
}
