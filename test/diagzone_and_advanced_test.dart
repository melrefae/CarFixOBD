import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/analyzers/catalytic_health_analyzer.dart';
import '../lib/domain/analyzers/dyno_performance_calculator.dart';
import '../lib/domain/analyzers/fuel_economy_calculator.dart';
import '../lib/domain/analyzers/ai_diagnostic_copilot.dart';
import '../lib/domain/services/flight_recorder_service.dart';
import '../lib/data/models/special_function_model.dart';
import '../lib/data/models/actuation_test_model.dart';
import '../lib/data/models/ecu_module_node.dart';
import '../lib/data/models/flight_record_model.dart';

void main() {
  group('Diagzone Pro Special Functions & Actuation Tests', () {
    test('16 Diagzone Pro Resets are properly defined with commands and procedures', () {
      final resets = SpecialFunctionModel.getAllFunctions();
      expect(resets.length, greaterThanOrEqualTo(16));

      final ids = resets.map((r) => r.id).toSet();
      expect(ids.length, equals(resets.length), reason: 'Each reset must have a unique ID');

      // Check key resets exist
      expect(ids, contains('oil_reset'));
      expect(ids, contains('epb_reset'));
      expect(ids, contains('sas_reset'));
      expect(ids, contains('bms_reset'));
      expect(ids, contains('abs_bleed'));
      expect(ids, contains('throttle_relearn'));
      expect(ids, contains('dpf_regen'));
      expect(ids, contains('tpms_reset'));
      expect(ids, contains('injector_coding'));
      expect(ids, contains('gear_learn'));
      expect(ids, contains('gearbox_match'));
      expect(ids, contains('immo_keys'));
      expect(ids, contains('suspension_reset'));
      expect(ids, contains('sunroof_init'));
      expect(ids, contains('afs_reset'));
      expect(ids, contains('egr_adaptation'));

      for (final reset in resets) {
        expect(reset.title.isNotEmpty, isTrue);
        expect(reset.description.isNotEmpty, isTrue);
        expect(reset.prerequisites.isNotEmpty, isTrue);
        expect(reset.manualSteps.isNotEmpty, isTrue);
        expect(reset.automatedObdCommand.isNotEmpty, isTrue);
        expect(reset.ecuHeader.length, equals(3), reason: 'Header should be 3 hex chars e.g. 7E0');
      }
    });

    test('Bi-Directional Actuator Tests are properly configured', () {
      final tests = ActuationTestModel.getAllActuatorTests();
      expect(tests.length, greaterThanOrEqualTo(6));

      final fanTest = tests.firstWhere((t) => t.id == 'radiator_fan_high');
      expect(fanTest.onCommand, contains('2F'));
      expect(fanTest.offCommand, contains('2F'));
      expect(fanTest.targetEcuHeader, equals('7E0'));
      expect(fanTest.activeDuration.inSeconds, equals(12));

      final pumpTest = tests.firstWhere((t) => t.id == 'fuel_pump_prime');
      expect(pumpTest.onCommand, contains('2F 01 20'));
      expect(pumpTest.targetEcuHeader, equals('7E0'));

      final sweepTest = tests.firstWhere((t) => t.id == 'instrument_cluster_sweep');
      expect(sweepTest.targetEcuHeader, equals('7E4'));
    });

    test('ECU Module Topology nodes definition', () {
      final modules = EcuModuleNode.getStandardCanTopology();
      expect(modules.length, equals(5));

      final tcm = modules.firstWhere((m) => m.header == '7E1');
      expect(tcm.shortName, equals('TCM'));
      expect(tcm.fullName, contains('Transmission'));

      final abs = modules.firstWhere((m) => m.header == '7E2');
      expect(abs.shortName, equals('ABS/ESP'));

      final srs = modules.firstWhere((m) => m.header == '7E3');
      expect(srs.shortName, equals('SRS'));

      final bcm = modules.firstWhere((m) => m.header == '7E4');
      expect(bcm.shortName, equals('BCM'));
    });
  });

  group('Catalytic Converter & Dual O2 Waveform Analyzer', () {
    test('Healthy Catalytic Converter: High efficiency, low switching ratio', () {
      // B1S1 switching rapidly between 0.1V and 0.85V
      final upstream = [0.1, 0.8, 0.15, 0.85, 0.2, 0.78, 0.12, 0.82, 0.18, 0.8];
      // B1S2 flat steady post-cat storage (~0.65V)
      final downstream = [0.65, 0.66, 0.64, 0.65, 0.65, 0.66, 0.65, 0.64, 0.65, 0.65];

      final report = CatalyticHealthAnalyzer.analyze(
        upstreamVolts: upstream,
        downstreamVolts: downstream,
      );

      expect(report.upstreamCrossCount, greaterThanOrEqualTo(8));
      expect(report.downstreamCrossCount, equals(0));
      expect(report.switchingRatio, equals(0.0));
      expect(report.efficiencyPercent, equals(99.0));
      expect(report.isHealthy, isTrue);
      expect(report.isDegraded, isFalse);
      expect(report.status, contains('Benchmark'));
    });

    test('Degraded Catalytic Converter: Downstream mirrors upstream (P0420)', () {
      // Both upstream and downstream switching across 0.45V threshold
      final upstream = [0.1, 0.8, 0.15, 0.85, 0.2, 0.78, 0.12, 0.82, 0.18, 0.8];
      final downstream = [0.15, 0.75, 0.2, 0.8, 0.25, 0.7, 0.18, 0.76, 0.22, 0.75];

      final report = CatalyticHealthAnalyzer.analyze(
        upstreamVolts: upstream,
        downstreamVolts: downstream,
      );

      expect(report.upstreamCrossCount, greaterThanOrEqualTo(8));
      expect(report.downstreamCrossCount, greaterThanOrEqualTo(8));
      expect(report.switchingRatio, greaterThan(0.7));
      expect(report.efficiencyPercent, lessThan(70.0));
      expect(report.isDegraded, isTrue);
      expect(report.isHealthy, isFalse);
      expect(report.status, contains('P0420'));
      expect(report.recommendation, contains('Replacement of the converter'));
    });

    test('Insufficient samples returns fallback diagnostic state', () {
      final report = CatalyticHealthAnalyzer.analyze(
        upstreamVolts: [0.5, 0.5],
        downstreamVolts: [0.5, 0.5],
      );

      expect(report.status, contains('Insufficient Samples'));
      expect(report.efficiencyPercent, equals(95.0));
    });
  });

  group('Dyno Performance & Acceleration Calculator', () {
    test('0-100 km/h acceleration run state machine', () {
      final dyno = DynoPerformanceCalculator();
      expect(dyno.state, equals(PerformanceRunState.standstillReady));

      int time = 1000;
      // Step 1: Standstill
      dyno.ingestSample(speedKmh: 0.0, rpm: 800, timestampMs: time);

      // Smooth acceleration simulation in 200ms intervals
      for (int i = 1; i <= 50; i++) {
        time += 200;
        final currentSpeed = (i / 50.0) * 105.0; // reaches 105 km/h at 10 seconds
        dyno.ingestSample(speedKmh: currentSpeed, rpm: 1000 + (i * 90), timestampMs: time);
      }

      expect(dyno.state, equals(PerformanceRunState.completed));
      expect(dyno.zeroToSixtySec, isNotNull);
      expect(dyno.zeroToHundredSec, isNotNull);
      expect(dyno.zeroToHundredSec!, greaterThan(5.0));
      expect(dyno.peakWheelHp, greaterThan(0.0));
    });

    test('Braking distance 100-0 km/h calculation', () {
      final dyno = DynoPerformanceCalculator();
      int time = 1000;
      dyno.ingestSample(speedKmh: 0.0, rpm: 800, timestampMs: time);

      // Ramp up to 105 km/h in 200ms increments
      for (int i = 1; i <= 20; i++) {
        time += 200;
        dyno.ingestSample(speedKmh: i * 5.25, rpm: 4000, timestampMs: time);
      }

      // Now braking to 0 in 200ms increments
      for (int i = 1; i <= 15; i++) {
        time += 200;
        final speed = (105.0 - (i * 8.0)).clamp(0.0, 105.0);
        dyno.ingestSample(speedKmh: speed, rpm: 800, timestampMs: time);
      }

      expect(dyno.brakingDistanceMeters, isNotNull);
      expect(dyno.brakingDistanceMeters!, greaterThan(0.0));
    });
  });

  group('Egyptian Fuel Economy & Cost Calculator', () {
    test('Calculates fuel tariffs accurately for Egypt grades', () {
      final calc = FuelEconomyCalculator();

      calc.selectedGrade = EgyptianFuelGrade.octane80;
      expect(calc.pricePerLiter, equals(13.75));

      calc.selectedGrade = EgyptianFuelGrade.octane92;
      expect(calc.pricePerLiter, equals(15.25));

      calc.selectedGrade = EgyptianFuelGrade.octane95;
      expect(calc.pricePerLiter, equals(17.00));

      calc.selectedGrade = EgyptianFuelGrade.diesel;
      expect(calc.pricePerLiter, equals(13.50));
    });

    test('Calculates trip cost and L/100km from distance and fuel consumed', () {
      final calc = FuelEconomyCalculator();
      calc.selectedGrade = EgyptianFuelGrade.octane92;
      calc.totalDistanceKm = 200.0;
      calc.totalFuelConsumedLiters = 14.0;

      // 14 L for 200 km = 7.0 L / 100 km
      expect(calc.averageLitersPer100Km, closeTo(7.0, 0.01));
      expect(calc.averageKmPerLiter, closeTo(14.28, 0.02));

      // Trip cost = 14 L * 15.25 EGP = 213.50 EGP
      expect(calc.totalTripCostEgp, closeTo(213.50, 0.01));
    });

    test('Computes instant consumption from MAF and speed', () {
      final calc = FuelEconomyCalculator();
      int time = 1000;
      calc.ingestSample(mafGramsPerSec: 5.0, speedKmh: 60.0, rpm: 2000, mapKpa: 35.0, timestampMs: time);
      time += 1000;
      calc.ingestSample(mafGramsPerSec: 10.0, speedKmh: 80.0, rpm: 2500, mapKpa: 45.0, timestampMs: time);

      expect(calc.instantLitersPerHour, greaterThan(0.0));
      expect(calc.instantLitersPer100Km, greaterThan(0.0));
      expect(calc.totalDistanceKm, greaterThan(0.0));
      expect(calc.totalFuelConsumedLiters, greaterThan(0.0));
    });
  });

  group('AI Diagnostic Copilot', () {
    test('Generates lean diagnosis roadmap with smoke test for P0171 / high LTFT', () {
      final report = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Hyundai Verna 1.6L',
        dtcCodes: ['P0171'],
        ltft: 18.5,
        stft: 3.2,
        coolantTemp: 88.0,
        batteryVoltage: 13.8,
        mapKpa: 36.0,
      );

      expect(report.primaryHypothesis, contains('Vacuum Leak'));
      expect(report.probabilityPercent, greaterThanOrEqualTo(80));
      expect(report.evidenceList.any((e) => e.contains('P0171')), isTrue);
      expect(report.roadmap.length, equals(4));
      expect(report.roadmap.any((s) => s.toolRequired.contains('Smoke Machine')), isTrue);
      expect(report.egyptWorkshopBulletin, contains('Verna'));
    });

    test('Generates catalyst efficiency diagnosis for P0420', () {
      final report = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Nissan Sunny N17',
        dtcCodes: ['P0420'],
        ltft: 2.0,
        stft: 1.0,
        coolantTemp: 90.0,
        batteryVoltage: 14.1,
        mapKpa: 30.0,
      );

      expect(report.primaryHypothesis, contains('Catalytic Converter'));
      expect(report.probabilityPercent, greaterThanOrEqualTo(80));
      expect(report.roadmap.any((s) => s.toolRequired.contains('Multimeter')), isTrue);
      expect(report.egyptWorkshopBulletin, contains('80 fuel'));
    });

    test('Arabic locale returns fully Arabic report content with Latin tech tokens', () {
      final report = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Hyundai Verna 1.6L',
        dtcCodes: ['P0171'],
        ltft: 18.5,
        stft: 3.2,
        coolantTemp: 88.0,
        batteryVoltage: 13.8,
        mapKpa: 36.0,
        isArabic: true,
      );

      expect(report.primaryHypothesis, contains('فاكيوم'));
      expect(report.urgencyLevel, contains('متوسط'));
      expect(report.evidenceList.every((e) => !RegExp(r'[a-z]{4,}\s[a-z]{4,}\s[a-z]{4,}').hasMatch(e.replaceAll(RegExp(r'(ECU|LTFT|STFT|MAP|Bank|Sensor|Long Term Fuel Trim)'), ''))), isTrue);
      expect(report.roadmap.length, equals(4));
      expect(report.roadmap.first.title, contains('اختبار'));
      expect(report.roadmap.every((s) => s.action.isNotEmpty && s.expectedGoodValue.isNotEmpty), isTrue);
      expect(report.egyptWorkshopBulletin, contains('نصيحة ورشة مصرية'));
      expect(report.egyptWorkshopBulletin, contains('فيرنا'));
      // Tech tokens stay Latin
      expect(report.evidenceList.join(' '), contains('LTFT'));
      expect(report.evidenceList.join(' '), contains('P0171'));
    });

    test('No invented values: null sensor data yields honest not-read evidence', () {
      final report = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Hyundai Verna 1.6L',
        dtcCodes: [],
        ltft: null,
        stft: null,
        coolantTemp: null,
        batteryVoltage: null,
        mapKpa: null,
      );
      final joined = report.evidenceList.join(' ');
      expect(joined.contains('+2.0'), isFalse); // old fabricated default is gone
      expect(report.evidenceList.any((e) => e.contains('not read from the vehicle')), isTrue);

      final lean = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Hyundai Verna 1.6L',
        dtcCodes: ['P0171'],
        ltft: null, stft: null, coolantTemp: null, batteryVoltage: null, mapKpa: null,
        isArabic: true,
      );
      expect(lean.evidenceList.join(' ').contains('+17.5'), isFalse);
      expect(lean.evidenceList.join(' ').contains('36 kPa'), isFalse);
      expect(lean.evidenceList.any((e) => e.contains('لم تُقرأ')), isTrue);
    });

    test('Provides fallback roadmap for normal operating telemetry', () {
      final report = AiDiagnosticCopilot.generateDiagnosis(
        vehicleMakeModel: 'Toyota Corolla 1.6L',
        dtcCodes: [],
        ltft: 1.5,
        stft: -0.8,
        coolantTemp: 89.0,
        batteryVoltage: 14.2,
        mapKpa: 28.0,
      );

      expect(report.primaryHypothesis, contains('Normal Parameters'));
      expect(report.probabilityPercent, greaterThanOrEqualTo(90));
      expect(report.roadmap.isNotEmpty, isTrue);
    });
  });

  group('Flight Recorder Model & Service', () {
    test('Telemetry frame serialization to JSON', () {
      const frame = FlightTelemetryFrame(
        timestampMs: 123456,
        speed: 85.0,
        rpm: 3200.0,
        coolantTemp: 90.0,
        throttlePercent: 45.0,
        ltft: 3.5,
        stft: 1.2,
        batteryVoltage: 14.1,
        o2B1S1: 0.75,
        o2B1S2: 0.65,
        mapKpa: 55.0,
      );

      final json = frame.toJson();
      expect(json['speed'], equals(85.0));
      expect(json['rpm'], equals(3200.0));
      expect(json['batteryVoltage'], equals(14.1));
    });

    test('Flight recorder service start, record, stop, and CSV export', () {
      final service = FlightRecorderService();
      expect(service.isRecording, isFalse);

      service.startRecording(vehicleTitle: 'Fiat Tipo 1.4L');
      expect(service.isRecording, isTrue);

      service.captureFrame(
        speed: 40.0,
        rpm: 2000.0,
        coolantTemp: 85.0,
        throttlePercent: 20.0,
        ltft: 1.0,
        stft: 0.5,
        batteryVoltage: 14.0,
        o2B1S1: 0.6,
        o2B1S2: 0.65,
        mapKpa: 40.0,
      );

      expect(service.currentSession!.frames.length, equals(1));

      final session = service.stopRecording();
      expect(service.isRecording, isFalse);
      expect(session, isNotNull);
      expect(session!.frameCount, equals(1));
      expect(session.vehicleTitle, equals('Fiat Tipo 1.4L'));

      final csv = session.toCsv();
      expect(csv, contains('Time_ms'));
      expect(csv, contains('Speed_kmh'));
      expect(csv, contains('RPM'));
    });
  });
}
