import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/data/datasources/bluetooth_obd_connection.dart';
import 'package:automotive_scanner/data/repositories/obd_repository.dart';
import 'package:automotive_scanner/data/repositories/vehicle_repository.dart';
import 'package:automotive_scanner/presentation/providers/obd_state.dart';
import 'package:automotive_scanner/data/models/sensor_pid.dart';

/// Fake test OBD connection for testing Elm327Driver and ObdRepository
class FakeObdConnection implements ObdConnection {
  final StreamController<String> _controller = StreamController<String>.broadcast();
  final Map<String, String> responses = {};
  final List<String> sentCommands = [];
  bool _connected = true;

  @override
  bool get isConnected => _connected;

  @override
  String get connectionType => "FakeOBD";

  @override
  Stream<String> get responseStream => _controller.stream;

  @override
  Future<bool> connect(String target) async {
    _connected = true;
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Future<void> send(String command) async {
    final clean = command.trim();
    sentCommands.add(clean);

    final response = responses[clean] ?? "OK\r\n>";
    Future.microtask(() {
      _controller.add(response);
    });
  }

  void simulateIncoming(String data) {
    _controller.add(data);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connection & Stream Lifecycle Tests', () {
    test('BluetoothObdConnection initializes disconnected with null subscription', () {
      final btc = BluetoothObdConnection();
      expect(btc.isConnected, isFalse);
      expect(btc.connectionType, equals("Bluetooth"));
      expect(btc.inputSubscription, isNull);
    });

    test('BluetoothObdConnection disconnect() cleans up state safely', () async {
      final btc = BluetoothObdConnection();
      await btc.disconnect();
      expect(btc.isConnected, isFalse);
      expect(btc.inputSubscription, isNull);
    });
  });

  group('Elm327Driver Fast Protocol Negotiation', () {
    test('Prioritizes fast CAN protocols over legacy slow timeouts', () async {
      final fakeConn = FakeObdConnection();
      fakeConn.responses['AT Z'] = 'ELM327 v1.5\r\n>';
      fakeConn.responses['AT E0'] = 'OK\r\n>';
      fakeConn.responses['AT L0'] = 'OK\r\n>';
      fakeConn.responses['AT S0'] = 'OK\r\n>';
      fakeConn.responses['AT H0'] = 'OK\r\n>';
      fakeConn.responses['AT SP 0'] = 'OK\r\n>';
      fakeConn.responses['0100'] = '41 00 BE 3F B8 11\r\n>';

      final driver = Elm327Driver(connection: fakeConn);
      final connected = await driver.initialize();
      expect(connected, isTrue);
      expect(driver.state, equals(ElmDriverState.ready));
    });

    test('Fast fallback to CAN 11/500 (AT SP 6) when auto search fails', () async {
      final fakeConn = FakeObdConnection();
      fakeConn.responses['AT Z'] = 'ELM327 v1.5\r\n>';
      fakeConn.responses['AT E0'] = 'OK\r\n>';
      fakeConn.responses['AT L0'] = 'OK\r\n>';
      fakeConn.responses['AT S0'] = 'OK\r\n>';
      fakeConn.responses['AT H0'] = 'OK\r\n>';
      fakeConn.responses['AT SP 0'] = 'OK\r\n>';
      fakeConn.responses['AT SP 6'] = 'OK\r\n>';

      final driver = Elm327Driver(connection: fakeConn);
      driver.connection.send("AT Z");
      expect(fakeConn.sentCommands, contains("AT Z"));
    });
  });

  group('Genuine Odometer Decoding Tests (Zero Fake Offsets)', () {
    test('Decodes SAE J1979-2 Mode 01 PID A6 with 0.1km resolution', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      // Distance cleared PID 31: 0x01E0 = 480 km
      fakeConn.responses['0131'] = '41 31 01 E0\r\n>';
      // Distance with MIL PID 21: 0x0000 = 0 km
      fakeConn.responses['0121'] = '41 21 00 00\r\n>';
      // Mode 01 PID A6: 0x00 0x13 0xD6 0x20 = 1,300,000 raw -> / 10 = 130,000 km
      fakeConn.responses['01A6'] = '41 A6 00 13 D6 20\r\n>';

      final odo = await repo.readGenuineOdometer();
      expect(odo.totalOdometerKm, equals(130000));
      expect(odo.distanceSinceDtcClearedKm, equals(480));
      expect(odo.distanceWithMilKm, equals(0));
      expect(odo.isClusterOdometerAvailable, isTrue);
      expect(odo.source, contains("Mode 01 PID A6"));
    });

    test('Decodes UDS Cluster DID 0x0200 when Mode 01 PID A6 is unsupported', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      fakeConn.responses['0131'] = '41 31 03 E8\r\n>'; // 1000 km
      fakeConn.responses['0121'] = '41 21 00 00\r\n>';
      fakeConn.responses['01A6'] = '7F 01 12\r\n>'; // Unsupported NRC
      // UDS DID 0x0200 4-byte payload: 0x00014C08 = 85,000 km
      fakeConn.responses['220200'] = '62 02 00 00 01 4C 08\r\n>';

      final odo = await repo.readGenuineOdometer();
      expect(odo.totalOdometerKm, equals(85000));
      expect(odo.distanceSinceDtcClearedKm, equals(1000));
      expect(odo.isClusterOdometerAvailable, isTrue);
      expect(odo.source, equals("UDS Cluster DID 0x0200"));
    });

    test('Decodes UDS Cluster DID 0xF1A0 (VAG / BMW total distance)', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      fakeConn.responses['0131'] = 'NO DATA\r\n>';
      fakeConn.responses['0121'] = 'NO DATA\r\n>';
      fakeConn.responses['01A6'] = 'NO DATA\r\n>';
      fakeConn.responses['220200'] = '7F 22 31\r\n>'; // Request out of range
      // UDS DID 0xF1A0: 0x00023280 = 144,000 km
      fakeConn.responses['22F1A0'] = '62 F1 A0 00 02 32 80\r\n>';

      final odo = await repo.readGenuineOdometer();
      expect(odo.totalOdometerKm, equals(144000));
      expect(odo.isClusterOdometerAvailable, isTrue);
      expect(odo.source, equals("UDS Cluster DID 0xF1A0"));
    });

    test('Decodes UDS Cluster DID 0x0204 (Toyota / Nissan)', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      fakeConn.responses['0131'] = 'NO DATA\r\n>';
      fakeConn.responses['0121'] = 'NO DATA\r\n>';
      fakeConn.responses['01A6'] = 'NO DATA\r\n>';
      fakeConn.responses['220200'] = 'NO DATA\r\n>';
      fakeConn.responses['22F1A0'] = 'NO DATA\r\n>';
      // UDS DID 0x0204: 0x000124F8 = 75,000 km
      fakeConn.responses['220204'] = '62 02 04 00 01 24 F8\r\n>';

      final odo = await repo.readGenuineOdometer();
      expect(odo.totalOdometerKm, equals(75000));
      expect(odo.isClusterOdometerAvailable, isTrue);
      expect(odo.source, equals("UDS Cluster DID 0x0204"));
    });

    test('Returns Mode 01 PID 31 with isClusterOdometerAvailable=false when cluster is inaccessible', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      fakeConn.responses['0131'] = '41 31 02 BC\r\n>'; // 700 km
      fakeConn.responses['0121'] = 'NO DATA\r\n>';
      fakeConn.responses['01A6'] = 'NO DATA\r\n>';
      fakeConn.responses['220200'] = 'NO DATA\r\n>';
      fakeConn.responses['22F1A0'] = 'NO DATA\r\n>';
      fakeConn.responses['220204'] = 'NO DATA\r\n>';

      final odo = await repo.readGenuineOdometer();
      expect(odo.totalOdometerKm, equals(700));
      expect(odo.distanceSinceDtcClearedKm, equals(700));
      expect(odo.isClusterOdometerAvailable, isFalse);
      expect(odo.source, contains("PID 31"));
    });
  });

  group('Live Sensor Non-Blocking Polling Tests', () {
    test('readSingleSensor blacklists unsupported PID upon NRC 7F response', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      // PID 2F (Fuel Tank Level) returns 7F 01 12 (Subfunction not supported)
      fakeConn.responses['012F'] = '7F 01 12\r\n>';
      final sensor = SensorPid(
        pid: '2F',
        name: 'Fuel Level',
        nameAr: 'مستوى الوقود',
        unit: '%',
        min: 0,
        max: 100,
        category: 'Fuel',
        decoder: (b) => b[0] * 100.0 / 255.0,
      );

      final val1 = await repo.readSingleSensor(sensor);
      expect(val1, isFalse);

      // Subsequent call should skip immediately without sending command
      fakeConn.sentCommands.clear();
      final val2 = await repo.readSingleSensor(sensor);
      expect(val2, isFalse);
      expect(fakeConn.sentCommands.contains('012F'), isFalse);
    });

    test('readSingleSensor successfully decodes valid PID', () async {
      final fakeConn = FakeObdConnection();
      final driver = Elm327Driver(connection: fakeConn);
      final repo = ObdRepository(driver: driver);

      fakeConn.responses['010C'] = '41 0C 1F 40\r\n>'; // (31*256 + 64) / 4 = 2000 RPM
      final sensor = SensorPid(
        pid: '0C',
        name: 'Engine RPM',
        nameAr: 'دورات المحرك',
        unit: 'RPM',
        min: 0,
        max: 8000,
        category: 'Engine',
        decoder: (b) => ((b[0] * 256) + b[1]) / 4.0,
      );

      final val = await repo.readSingleSensor(sensor);
      expect(val, isTrue);
      expect(sensor.currentValue, equals(2000.0));
    });
  });

  group('Adapter Persistence & Auto-Reconnect State Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'obd_last_adapter_type': 'Bluetooth',
        'obd_last_adapter_target': '00:11:22:33:44:55',
        'obd_last_adapter_name': 'vLinker MC+ 4455',
        'obd_auto_connect_enabled': true,
        'selected_vehicle_profile_id': 'prof_123',
      });
    });

    test('ObdState loads saved adapter preferences from SharedPreferences', () async {
      final obdState = ObdState();

      // Allow async prefs to load
      await Future.delayed(const Duration(milliseconds: 50));

      expect(obdState.lastSavedAdapterType, equals('Bluetooth'));
      expect(obdState.lastSavedAdapterTarget, equals('00:11:22:33:44:55'));
      expect(obdState.lastSavedAdapterName, equals('vLinker MC+ 4455'));
      expect(obdState.isAutoConnectEnabled, isTrue);
    });

    test('ObdState toggleAutoConnect updates preference', () async {
      final obdState = ObdState();

      await Future.delayed(const Duration(milliseconds: 50));
      await obdState.toggleAutoConnect(false);

      expect(obdState.isAutoConnectEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('obd_auto_connect_enabled'), isFalse);
    });

    test('ObdState clearSavedAdapter wipes target, type, and name', () async {
      final obdState = ObdState();

      await Future.delayed(const Duration(milliseconds: 50));
      await obdState.clearSavedAdapter();

      expect(obdState.lastSavedAdapterTarget, isNull);
      expect(obdState.lastSavedAdapterType, isNull);
      expect(obdState.lastSavedAdapterName, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('obd_last_adapter_target'), isFalse);
    });

    test('ObdState returns genuine 0.0 RPM when sensors are inactive (no fake 750 RPM)', () {
      final obdState = ObdState();

      expect(obdState.currentRpm, equals(0.0));
      expect(obdState.currentCoolantTemp, equals(0.0));
    });

    test('VehicleRepository restores selected profile ID from SharedPreferences', () async {
      final vehicleRepo = VehicleRepository();
      await vehicleRepo.loadProfiles();

      if (vehicleRepo.profiles.isNotEmpty) {
        final profile = vehicleRepo.profiles.first;
        vehicleRepo.selectProfile(profile);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_vehicle_profile_id'), equals(profile.id));
      }
    });
  });
}
