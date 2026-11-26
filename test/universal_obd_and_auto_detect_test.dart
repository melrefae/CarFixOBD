import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:automotive_scanner/core/utils/hex_parser.dart';
import 'package:automotive_scanner/data/datasources/ble_obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/posix_serial_transport.dart';
import 'package:automotive_scanner/data/datasources/usb_serial_obd_connection.dart';
import 'package:automotive_scanner/data/datasources/wifi_obd_connection.dart';
import 'package:automotive_scanner/data/models/sensor_pid.dart';
import 'package:automotive_scanner/data/models/vehicle_profile.dart';
import 'package:automotive_scanner/data/repositories/obd_repository.dart';
import 'package:automotive_scanner/data/repositories/vehicle_repository.dart';
import 'package:automotive_scanner/domain/services/vin_decoder_service.dart';
import 'package:automotive_scanner/presentation/providers/obd_state.dart';
import 'package:automotive_scanner/presentation/screens/mode06_monitor_screen.dart';

/// Scripted in-memory OBD connection for deterministic protocol & repository tests.
class _ScriptedObdConnection implements ObdConnection {
  final StreamController<String> _controller = StreamController<String>.broadcast();
  final Map<String, String> _responses;
  final List<String> sentCommands = [];
  bool _connected = false;

  _ScriptedObdConnection(this._responses);

  @override
  bool get isConnected => _connected;

  @override
  String get connectionType => "Scripted Test Adapter";

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
    final normalized = command.replaceAll('\r', '').trim().toUpperCase();
    sentCommands.add(normalized);
    final reply = _responses[normalized] ??
        (normalized.startsWith('AT ') ? 'OK\r\r>' : 'NO DATA\r\r>');
    scheduleMicrotask(() {
      if (!_controller.isClosed) {
        _controller.add(reply);
      }
    });
  }
}

/// Custom serial transport test double to verify baud parsing and disconnect hooks.
class _FakeSerialTransport implements SerialTransportDriver {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _open = false;
  String? openedPort;
  int? openedBaud;
  final List<String> written = [];

  @override
  bool get isOpen => _open;

  @override
  Stream<Uint8List> get inputStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  @override
  Future<List<SerialDeviceDescriptor>> listDevices() async => const [
        SerialDeviceDescriptor(
          portId: '/dev/bus/usb/001/002',
          displayName: 'FTDI FT232R USB-UART',
          transportKind: 'USB-OTG',
          vid: 0x0403,
          pid: 0x6001,
          chipsetName: 'FTDI',
        ),
      ];

  @override
  Future<bool> open(String targetPort, int baudRate) async {
    openedPort = targetPort;
    openedBaud = baudRate;
    _open = true;
    return true;
  }

  @override
  Future<void> write(Uint8List data) async {
    written.add(String.fromCharCodes(data));
  }

  void simulateDisconnect() {
    _open = false;
    onDisconnected?.call();
  }

  @override
  Future<void> close() async {
    _open = false;
  }
}

/// Custom BLE GATT transport test double verifying scan filters, writes, notifications, and disconnect hooks.
class _FakeBleTransport implements BleTransportDriver {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>.broadcast();
  bool _connected = false;
  String? connectedTarget;

  @override
  bool get isConnected => _connected;

  @override
  BleGattProfile? get matchedProfile => BleGattProfile.standardProfiles.first;

  @override
  Stream<Uint8List> get incomingBytesStream => _controller.stream;

  @override
  void Function()? onDisconnected;

  @override
  Future<List<BleScannedDevice>> scanObdDevices({Duration timeout = const Duration(seconds: 4)}) async => [
        BleScannedDevice(
          remoteId: '00:11:22:33:AA:BB',
          name: 'Vgate iCar Pro BLE4.0',
          rssi: -52,
          serviceUuids: [BleGattProfile.standardProfiles.first.serviceUuid],
          isKnownObd: true,
          matchedProfileBrand: BleGattProfile.standardProfiles.first.adapterBrand,
        ),
      ];

  @override
  Future<bool> connect(String target) async {
    connectedTarget = target;
    _connected = true;
    return true;
  }

  @override
  Future<void> writeBytes(Uint8List bytes) async {
    if (!_connected) throw Exception('Not connected');
    _controller.add(Uint8List.fromList('OK\r\r>'.codeUnits));
  }

  void simulateDisconnect() {
    _connected = false;
    onDisconnected?.call();
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VIN & ECU Fingerprint Auto-Detection Tests', () {
    test('Decodes Japanese Toyota VIN with valid ISO 3779 check digit X and year 2011', () {
      const vin = 'JTDBU4EEXB9123456';
      expect(VinDecoderService.validateCheckDigit(vin), isTrue);

      final decoded = VinDecoderService.decodeVin(vin, source: 'Mode 09 02');
      expect(decoded, isNotNull);
      expect(decoded!.vin, vin);
      expect(decoded.make, 'Toyota');
      expect(decoded.country, 'Japan');
      expect(decoded.year, 2011);
      expect(decoded.isValidVin, isTrue);
      expect(decoded.displaySummary, contains('2011 Toyota'));
    });

    test('Decodes Korean Hyundai VIN with numeric check digit and year 2019', () {
      const vin = 'KMHDN46D4KU123456';
      expect(VinDecoderService.validateCheckDigit(vin), isTrue);

      final decoded = VinDecoderService.decodeVin(vin);
      expect(decoded, isNotNull);
      expect(decoded!.make, 'Hyundai');
      expect(decoded.year, 2019);
      expect(decoded.country, contains('Korea'));
      expect(decoded.region, 'Asian');
    });

    test('Decodes Egyptian CKD Nissan and Chinese Chery WMIs reliably', () {
      final nissanCkD = VinDecoderService.decodeVin('NMAA00000L0001234');
      expect(nissanCkD, isNotNull);
      expect(nissanCkD!.make, 'Nissan');
      expect(nissanCkD.country, 'Egypt CKD');
      expect(nissanCkD.modelHint, contains('Sunny'));

      final chery = VinDecoderService.decodeVin('LVVDB11B5KD000123');
      expect(chery, isNotNull);
      expect(chery!.make, 'Chery');
      expect(chery.country, 'China');
    });

    test('Falls back cleanly to ECU Fingerprint detection when VIN Mode 09 is missing', () {
      final nissanFp = VinDecoderService.decodeFromEcuFingerprint(
        calId: '23710-1KA0A',
        ecuName: 'ECM-EngineControl',
      );
      expect(nissanFp, isNotNull);
      expect(nissanFp!.make, 'Nissan');
      expect(nissanFp.detectionSource, contains('ECU Fingerprint'));

      final cheryFp = VinDecoderService.decodeFromEcuFingerprint(
        oemPartNumber: 'DELPHI MT62',
        ecuName: 'CHERY TIGGO ECM',
      );
      expect(cheryFp, isNotNull);
      expect(cheryFp!.make, 'Chery');
    });

    test('VehicleRepository autoMatchOrCreateProfile matches preset or creates fallback profile', () async {
      final repo = VehicleRepository();
      await repo.loadProfiles();

      final decodedNissan = VinDecoderService.decodeVin('NMAA00000L0001234')!;
      final matched = repo.autoMatchOrCreateProfile(decodedNissan);
      expect(matched.make.toLowerCase(), 'nissan');
      expect(repo.selectedProfile?.id, matched.id);

      // Unknown / uncommon make creates a clean non-Arabic auto-generated profile
      const rareDecoded = DecodedVehicleInfo(
        vin: 'YV1BZ985681000001',
        make: 'Volvo',
        modelHint: 'XC60',
        year: 2008,
        country: 'Sweden',
        region: 'European',
        detectionSource: 'Mode 09 02',
        isValidVin: true,
      );
      final created = repo.autoMatchOrCreateProfile(rareDecoded);
      expect(created.make, 'Volvo');
      expect(created.getDisplayName(false).contains(RegExp(r'[\u0600-\u06FF]')), isFalse);
    });
  });

  group('HexParser Mode 01 Bitmasks, UDS & Mode 06 Tests', () {
    test('parseSupportedPidBitmask decodes BE 3F B8 13 and 0120 ranges accurately', () {
      // BE 3F B8 13 = PIDs 01,03,04,05,06,07,0C,0D,0E,0F,10,11,13,14,15,1C,1F,20
      final pids00 = HexParser.parseSupportedPidBitmask([0xBE, 0x3F, 0xB8, 0x13], 0x00);
      expect(pids00, containsAll(['01', '04', '05', '0C', '0D', '11', '1F', '20']));
      expect(pids00, isNot(contains('02')));

      // Next block 0x20: 80 01 00 01 -> 21, 30, 40
      final pids20 = HexParser.parseSupportedPidBitmask([0x80, 0x01, 0x00, 0x01], 0x20);
      expect(pids20, containsAll(['21', '30', '40']));
    });

    test('parseAsciiResponse decodes Mode 09 CALID & ECU Name longer than 17 chars', () {
      // "49 04 01" + ASCII for "CALID1234567890123456" (21 chars)
      final calidAscii = 'CALID1234567890123456'.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ');
      final raw = '0: 49 04 01 $calidAscii';
      final parsed = HexParser.parseAsciiResponse(HexParser.extractBytes(raw), 0x09, 0x04);
      expect(parsed, 'CALID1234567890123456');
    });

    test('parseUdsDtcs & parseUdsAsciiDid decode non-engine ISO 14229 frames', () {
      // UDS 19 02 -> 59 02 FF | C0 12 16 09 (confirmed+current)
      final bytes = [0x59, 0x02, 0xFF, 0x41, 0x23, 0x16, 0x09, 0x03, 0x01, 0x00, 0x04];
      final udsDtcs = HexParser.parseUdsDtcs(bytes);
      expect(udsDtcs.length, 2);
      expect(udsDtcs[0].isConfirmed, isTrue);
      expect(udsDtcs[0].isCurrent, isTrue);
      expect(udsDtcs[1].isPending, isTrue);

      // UDS 22 F1 90 -> 62 F1 90 + VIN
      final vinHex = 'KMHDN46D4KU123456'.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join(' ');
      final vinFromUds = HexParser.parseVin(HexParser.extractBytes('62 F1 90 $vinHex'));
      expect(vinFromUds, 'KMHDN46D4KU123456');
    });

    test('parseMode06Results parses passed and failed cylinder misfire monitors', () {
      final bytes = [
        // Record 1: MID A2 (Misfire Cyl 1), TID 0C, UASID 24, Val 0, Min 0, Max 10 => PASS
        0x46, 0xA2, 0x0C, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0A,
        // Record 2: MID A3 (Misfire Cyl 2), TID 0B, UASID 24, Val 37, Min 0, Max 10 => FAIL
        0x46, 0xA3, 0x0B, 0x24, 0x00, 0x25, 0x00, 0x00, 0x00, 0x0A,
      ];
      final results = HexParser.parseMode06Results(bytes);
      expect(results.length, 2);
      expect(results[0].mid, 0xA2);
      expect(results[0].isPassed, isTrue);
      expect(results[1].mid, 0xA3);
      expect(results[1].isPassed, isFalse);
      expect(results[1].measuredValue, 37.0);
      expect(results[1].maxLimit, 10.0);
    });
  });

  group('ObdRepository CAN Batching, NRC Handling, Custom PIDs & Mode 06', () {
    test('discoverSupportedPids, valid 0x7F coolant byte, and CAN 4-PID batch polling work together', () async {
      final scripted = _ScriptedObdConnection({
        'AT Z': 'ELM327 v1.5\r\r>',
        'AT I': 'ELM327 v1.5\r\r>',
        'AT E0': 'OK\r\r>',
        'AT L0': 'OK\r\r>',
        'AT S0': 'OK\r\r>',
        'AT H0': 'OK\r\r>',
        'AT AT1': 'OK\r\r>',
        'AT SP0': 'OK\r\r>',
        'AT RV': '13.8V\r\r>',
        'AT DPN': 'ISO 15765-4 (CAN 11/500)\r\r>',
        // 0100: supports 05 (Coolant), 0C (RPM), 0D (Speed), 11 (TPS), 14 (O2), 20 (next block)
        '0100': '41 00 08 19 90 01\r\r>',
        '0120': '41 20 00 00 00 00\r\r>',
        // Coolant = 0x7F (127 - 40 = 87.0°C) — must NOT be falsely rejected as NRC!
        '0105': '41 05 7F\r\r>',
        // Batch query 010C0D0511 -> RPM (0x1A 0xF8 = 1726.0), Speed (0x46 = 70), Coolant (0x7F = 87), TPS (0x40 = 25.1%)
        '010C0D0511': '41 0C 1A F8 0D 46 05 7F 11 40\r\r>',
        // Real NRC test on O2 sensor
        '0114': '7F 01 12\r\r>',
        // Mode 06 monitors
        '0600': '46 00 00 00 00 00\r\r>',
        '06A2': '46 A2 0B 24 00 02 00 00 00 0F\r\r>',
      });

      await scripted.connect('SCRIPTED');
      final driver = Elm327Driver(connection: scripted);
      await driver.initialize();
      expect(driver.state, ElmDriverState.ready);

      final repo = ObdRepository(driver: driver);
      final sensors = SensorPid.getStandardPids();
      final supported = await repo.discoverSupportedPids(sensors);
      expect(supported, containsAll(['05', '0C', '0D', '11', '14']));

      final coolantSensor = sensors.firstWhere((s) => s.mode == '01' && s.pid == '05');
      final coolantOk = await repo.readSingleSensor(coolantSensor);
      expect(coolantOk, isTrue);
      expect(coolantSensor.hasValidReading, isTrue);
      expect(coolantSensor.currentValue, closeTo(87.0, 0.01));

      // Verify true 7F 01 12 NRC rejects sensor instead of updating
      final o2Sensor = sensors.firstWhere((s) => s.mode == '01' && s.pid == '14');
      final o2Ok = await repo.readSingleSensor(o2Sensor);
      expect(o2Ok, isFalse);
      expect(o2Sensor.hasValidReading, isFalse);

      // Verify 4-PID CAN batch polling
      final batchTargets = ['0C', '0D', '05', '11']
          .map((pid) => sensors.firstWhere((s) => s.mode == '01' && s.pid == pid))
          .toList();
      final updatedBatch = await repo.readBatchMode01Sensors(batchTargets);
      expect(updatedBatch.length, 4);
      expect(sensors.firstWhere((s) => s.mode == '01' && s.pid == '0C').currentValue, closeTo(1726.0, 0.01));
      expect(sensors.firstWhere((s) => s.mode == '01' && s.pid == '0D').currentValue, closeTo(70.0, 0.01));
      expect(sensors.firstWhere((s) => s.mode == '01' && s.pid == '11').currentValue, closeTo(25.1, 0.1));

      // Mode 06 monitors
      final m06 = await repo.readMode06Monitors();
      expect(m06.any((r) => r.mid == 0xA2 && r.measuredValue == 2.0), isTrue);
    });

    test('SensorPid.fromCustomPid evaluates OEM arithmetic expressions cleanly', () {
      final cvtTemp = SensorPid.fromCustomPid(CustomPid(
        name: 'حرارة الفتيس',
        nameEn: 'CVT Fluid Temp',
        mode: '22',
        pid: '1005',
        formula: '((A*256)+B)/10 - 40',
        unit: '°C',
        min: -40,
        max: 160,
      ));
      expect(cvtTemp.isCustom, isTrue);
      expect(cvtTemp.hasValidReading, isFalse);
      // [0x04, 0xB0] = 1200 -> 1200/10 - 40 = 80.0 °C
      cvtTemp.updateValue(cvtTemp.decoder([0x04, 0xB0]));
      expect(cvtTemp.hasValidReading, isTrue);
      expect(cvtTemp.currentValue, closeTo(80.0, 0.01));
    });
  });

  group('Universal Transport Layers (BLE GATT, USB Serial, Wi-Fi TCP)', () {
    test('BleObdConnection scans, connects, sends/receives GATT frames, and fires disconnect callback', () async {
      // Default test transport must not invent fake hardware adapters
      final defaultScan = await BleObdConnection.scanObdDevices();
      expect(defaultScan, isEmpty);

      final fakeBle = _FakeBleTransport();
      final devices = await BleObdConnection.scanObdDevices(transport: fakeBle);
      expect(devices, isNotEmpty);
      expect(devices.any((d) => d.isKnownObd), isTrue);

      final ble = BleObdConnection(transport: fakeBle);
      bool disconnectedFired = false;
      ble.onDisconnected = () => disconnectedFired = true;

      final ok = await ble.connect('00:11:22:33:AA:BB');
      expect(ok, isTrue);
      expect(ble.isConnected, isTrue);
      expect(ble.activeGattProfile, isNotNull);

      final replyFuture = ble.responseStream.first;
      await ble.send('AT Z');
      final reply = await replyFuture;
      expect(reply, contains('OK'));

      fakeBle.simulateDisconnect();
      expect(disconnectedFired, isTrue);
      expect(ble.isConnected, isFalse);

      await ble.disconnect();
      expect(ble.isConnected, isFalse);
    });

    test('UsbSerialObdConnection parses baud suffixes (@230400) and invokes onDisconnected', () async {
      final fakeDriver = _FakeSerialTransport();
      final serial = UsbSerialObdConnection(transport: fakeDriver);
      bool disconnectedCalled = false;
      serial.onDisconnected = () => disconnectedCalled = true;

      final ok = await serial.connect('/dev/cu.987696098341@230400');
      expect(ok, isTrue);
      expect(fakeDriver.openedPort, '/dev/cu.987696098341');
      expect(fakeDriver.openedBaud, 230400);
      expect(serial.baudRate, 230400);

      await serial.send('AT RV');
      expect(fakeDriver.written.last, 'AT RV\r');

      fakeDriver.simulateDisconnect();
      expect(disconnectedCalled, isTrue);
      expect(serial.isConnected, isFalse);
    });

    test('WifiObdConnection exchanges real TCP ELM327 frames over loopback ServerSocket', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final serverConnSub = server.listen((client) {
        client.listen((bytes) {
          final cmd = String.fromCharCodes(bytes).trim();
          if (cmd == 'AT Z') {
            client.write('ELM327 v1.5\r\r>');
          }
        });
      });

      final wifi = WifiObdConnection();
      final target = '${server.address.address}:${server.port}';
      final connected = await wifi.connect(target);
      expect(connected, isTrue);

      final futureReply = wifi.responseStream.first;
      await wifi.send('AT Z');
      final reply = await futureReply;
      expect(reply, contains('ELM327 v1.5'));

      await wifi.disconnect();
      await serverConnSub.cancel();
      await server.close();
    });
  });

  group('ObdState Real-Data Guards & Mode 06 Screen Widget Test', () {
    testWidgets('ObdState initializes without fake live data and Mode06MonitorScreen renders zero Arabic in EN',
        (WidgetTester tester) async {
      final state = ObdState();
      expect(state.isVehicleAutoDetected, isFalse);
      expect(state.sensors.every((s) => !s.hasValidReading), isTrue);

      await tester.pumpWidget(
        ChangeNotifierProvider<ObdState>.value(
          value: state,
          child: const MaterialApp(
            home: Mode06MonitorScreen(),
          ),
        ),
      );
      await tester.pump();

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      for (final t in textWidgets) {
        final content = t.data ?? '';
        expect(content.contains(RegExp(r'[\u0600-\u06FF]')), isFalse,
            reason: 'English Mode06 UI must never contain Arabic text: "$content"');
      }
      expect(find.textContaining('Mode \$06'), findsWidgets);
    });
  });
}
