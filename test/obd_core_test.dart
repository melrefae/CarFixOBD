import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/utils/hex_parser.dart';
import '../lib/data/models/sensor_pid.dart';
import '../lib/domain/analyzers/fuel_trim_analyzer.dart';
import '../lib/domain/analyzers/battery_health_checker.dart';
import '../lib/data/models/readiness_monitors.dart';
import '../lib/data/models/vehicle_profile.dart';
import '../lib/data/models/dtc_model.dart';
import '../lib/data/models/inspection_report.dart';
import '../lib/core/utils/app_logger.dart';
import '../lib/presentation/providers/obd_state.dart';

void main() {
  group('Hex Parser & OBD-II Protocol Tests', () {
    test('DTC Decoding: Single and Multi DTCs', () {
      final dtc1 = HexParser.decodeSingleDtc(0x01, 0x71);
      expect(dtc1, equals('P0171'));

      final dtc2 = HexParser.decodeSingleDtc(0x03, 0x00);
      expect(dtc2, equals('P0300'));

      final dtc3 = HexParser.decodeSingleDtc(0x01, 0x33);
      expect(dtc3, equals('P0133'));
    });

    test('DTC List Extraction from Mode 03 response', () {
      final bytes = [0x43, 0x01, 0x71, 0x03, 0x00, 0x00, 0x00];
      final dtcs = HexParser.parseDtcs(bytes, 0x03);

      expect(dtcs.length, equals(2));
      expect(dtcs, contains('P0171'));
      expect(dtcs, contains('P0300'));
    });

    test('HexParser isErrorResponse allows BUS INIT: OK and SEARCHING...', () {
      expect(HexParser.isErrorResponse("BUS INIT: OK"), isFalse);
      expect(HexParser.isErrorResponse("BUS INIT: ... OK"), isFalse);
      expect(HexParser.isErrorResponse("SEARCHING..."), isFalse);
      expect(HexParser.isErrorResponse("41 0C 0E 10"), isFalse);

      expect(HexParser.isErrorResponse("UNABLE TO CONNECT"), isTrue);
      expect(HexParser.isErrorResponse("BUS INIT: ERROR"), isTrue);
      expect(HexParser.isErrorResponse("BUS ERROR"), isTrue);
      expect(HexParser.isErrorResponse("NO DATA"), isTrue);
      expect(HexParser.isErrorResponse("CAN ERROR"), isTrue);
      expect(HexParser.isErrorResponse("STOPPED"), isTrue);
    });

    test('VIN Decoding from Mode 09 PID 02 response', () {
      final bytes = [
        0x49, 0x02, 0x01,
        0x4E, 0x4D, 0x41, 0x41, 0x41, 0x31, 0x35, 0x37, 0x4B, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36
      ];
      final vin = HexParser.parseVin(bytes);
      expect(vin, contains('NMAAA157K123456'));
    });

    test('Standard Sensor PID Decoders (RPM, Speed, Coolant)', () {
      final pids = SensorPid.getStandardPids();

      // RPM (PID 0C): ((A*256)+B)/4
      final rpmSensor = pids.firstWhere((p) => p.pid == "0C");
      rpmSensor.decodeAndUpdate([0x0E, 0x10]); // (14 * 256 + 16) / 4 = 900 RPM
      expect(rpmSensor.currentValue, equals(900.0));

      // Speed (PID 0D): A
      final speedSensor = pids.firstWhere((p) => p.pid == "0D");
      speedSensor.decodeAndUpdate([0x3C]); // 60 km/h
      expect(speedSensor.currentValue, equals(60.0));

      // Coolant Temp (PID 05): A - 40
      final tempSensor = pids.firstWhere((p) => p.pid == "05");
      tempSensor.decodeAndUpdate([0x80]); // 128 - 40 = 88 °C
      expect(tempSensor.currentValue, equals(88.0));
    });
  });

  group('Intelligent Diagnostic Analyzers (English & Arabic)', () {
    test('Vacuum Leak Detection with English diagnosis', () {
      final result = FuelTrimAnalyzer.analyze(
        stftIdle: 3.0,
        ltftIdle: 15.0,
        stftLoad: 2.0,
        ltftLoad: 3.0,
      );

      expect(result.statusEn, contains("Vacuum Leak"));
      expect(result.status, contains("Vacuum Leak"));
      expect(result.diagnosisEn, contains("Mixture is significantly lean at idle"));
      expect(result.isSevere, isTrue);
    });

    test('Battery & Alternator Health Checker with English diagnosis', () {
      final result = BatteryHealthChecker.evaluate(
        restingVoltage: 12.2,
        minCrankingVoltage: 8.2,
        runningVoltage: 14.1,
      );

      expect(result.isBatteryGood, isFalse);
      expect(result.batteryStatusEn, contains("Severe cranking voltage drop"));
      expect(result.batteryStatus, contains("Severe cranking voltage drop"));
      expect(result.isAlternatorGood, isTrue);
      expect(result.alternatorStatusEn, contains("normal and stabilized"));
    });

    test('Emissions Readiness Monitors (Mode 01 PID 01) decode', () {
      final bytes = [0x81, 0x07, 0x65, 0x04];
      final monitors = ReadinessMonitors.fromBytes(bytes);

      expect(monitors.milOn, isTrue);
      expect(monitors.dtcCount, equals(1));
      expect(monitors.monitors.length, equals(8));

      final misfire = monitors.monitors.firstWhere((m) => m.nameEn == "Misfire Monitor");
      expect(misfire.isAvailable, isTrue);
      expect(misfire.explanationEn, contains("Continuous monitoring for cylinder ignition misfires"));
    });

    test('DtcModel English titles and descriptions fallback', () {
      final dtc = DtcModel.unknown("P0171");
      expect(dtc.title, equals("System Too Lean (Bank 1)"));
      expect(dtc.description, contains("The ECU air-fuel mixture is excessively lean"));
      expect(dtc.workshopCheck, contains("Perform smoke test"));
    });
  });

  group('Vehicle Database & Report Synchronization', () {
    test('Egyptian Cars Database Presets contains > 60 vehicles across multiple brands and eras', () {
      final file = File('assets/databases/egypt_cars_preset.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final list = jsonDecode(jsonStr) as List;

      expect(list.length, greaterThanOrEqualTo(60));

      // Verify presence of iconic Egyptian market cars
      final models = list.map((e) => "${e['make']} ${e['model']}").toList();
      expect(models.any((m) => m.contains("Verna")), isTrue);
      expect(models.any((m) => m.contains("Sunny")), isTrue);
      expect(models.any((m) => m.contains("128")), isTrue);
      expect(models.any((m) => m.contains("Lanos")), isTrue);
      expect(models.any((m) => m.contains("Optra")), isTrue);
      expect(models.any((m) => m.contains("Corolla")), isTrue);
      expect(models.any((m) => m.contains("Logan")), isTrue);
      expect(models.any((m) => m.contains("Tiggo")), isTrue);
      expect(models.any((m) => m.contains("F3")), isTrue);
      expect(models.any((m) => m.contains("ZS")), isTrue);
      expect(models.any((m) => m.contains("Cerato")), isTrue);
    });

    test('AppLogger records TX, RX, and warning levels', () {
      final logger = AppLogger();
      logger.clear();

      logger.tx("010C");
      logger.rx("41 0C 0E 10");
      logger.warning("High temperature warning");

      expect(logger.logs.length, equals(3));
      expect(logger.logs[0].level, equals(LogLevel.tx));
      expect(logger.logs[1].level, equals(LogLevel.rx));
      expect(logger.logs[2].level, equals(LogLevel.warning));

      final export = logger.exportLogs();
      expect(export, contains("TX -> 010C"));
      expect(export, contains("RX <- 41 0C 0E 10"));
    });

    test('Custom PID Model serializes and deserializes', () {
      final pid = CustomPid(
        name: "حرارة فتيس CVT",
        nameEn: "CVT Temp",
        mode: "21",
        pid: "82",
        formula: "A - 40",
        unit: "°C",
        min: -40,
        max: 160,
      );

      final json = pid.toJson();
      expect(json['mode'], equals('21'));
      expect(json['pid'], equals('82'));
      expect(json['name_en'], equals('CVT Temp'));

      final restored = CustomPid.fromJson(json);
      expect(restored.nameEn, equals("CVT Temp"));
      expect(restored.formula, equals("A - 40"));
    });

    test('Inspection Report JSON Serialization for LAN Hub', () {
      final report = InspectionReport(
        id: "rep-101",
        customerName: "Mohamed Elrefae",
        customerPhone: "01001234567",
        vehicleMakeModel: "Nissan Sunny N17",
        plateNumber: "ABC 1234",
        vin: "NMAAA157K123456",
        timestamp: DateTime.parse("2026-10-26T12:00:00Z"),
        batteryVoltage: 14.2,
        milStatusOn: true,
        dtcsFound: [
          DtcModel(
            code: "P0171",
            titleAr: "الخليط فقير بنزين",
            titleEn: "System Too Lean (Bank 1)",
            category: "Powertrain",
            severity: "High",
            descriptionAr: "تسريب فاكيوم",
            symptomsAr: ["تنتيشة"],
            causesAr: ["شرخ خرطوم العمة"],
            workshopCheckAr: "افحص الفاكيوم",
          ),
        ],
        liveSensorsSnapshot: {"RPM": "850", "Coolant": "89"},
        mechanicNotes: "Throttle cleaned and spark plugs replaced",
      );

      final json = report.toJson();
      expect(json['id'], equals("rep-101"));
      expect(json['customer_name'], equals("Mohamed Elrefae"));
      expect(json['dtcs_found'].length, equals(1));

      final restored = InspectionReport.fromJson(json);
      expect(restored.customerName, equals("Mohamed Elrefae"));
      expect(restored.dtcsFound.first.code, equals("P0171"));
      expect(restored.batteryVoltage, equals(14.2));
    });

    test('isObdDeviceName detects standard and aftermarket OBD adapter names', () {
      expect(ObdState.isObdDeviceName("OBDII"), isTrue);
      expect(ObdState.isObdDeviceName("ELM327 v1.5"), isTrue);
      expect(ObdState.isObdDeviceName("Vgate iCar Pro"), isTrue);
      expect(ObdState.isObdDeviceName("Konnwei KW902"), isTrue);
      expect(ObdState.isObdDeviceName("BAFX Products 3127"), isTrue);
      expect(ObdState.isObdDeviceName("Launch EasyDiag"), isTrue);
      expect(ObdState.isObdDeviceName("Autel MaxiAP"), isTrue);
      expect(ObdState.isObdDeviceName("Topdon OBD"), isTrue);
      expect(ObdState.isObdDeviceName("Vieffcar BT"), isTrue);
      expect(ObdState.isObdDeviceName("HH OBD Mini"), isTrue);
      expect(ObdState.isObdDeviceName("Samsung Galaxy S24"), isFalse);
      expect(ObdState.isObdDeviceName("AirPods Pro"), isFalse);
      expect(ObdState.isObdDeviceName(""), isFalse);
      expect(ObdState.isObdDeviceName(null), isFalse);
    });
  });
}
