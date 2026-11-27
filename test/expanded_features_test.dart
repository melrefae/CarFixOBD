import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/core/constants/app_colors.dart';
import 'package:automotive_scanner/core/theme/workshop_theme.dart';
import 'package:automotive_scanner/data/models/special_function_model.dart';
import 'package:automotive_scanner/data/models/ecu_coding_feature.dart';
import 'package:automotive_scanner/data/models/worldwide_brand.dart';
import 'package:automotive_scanner/data/models/sgw_vehicle_guide.dart';
import 'package:automotive_scanner/data/models/sensor_pid.dart';
import 'package:automotive_scanner/data/models/vehicle_profile.dart';
import 'package:automotive_scanner/data/repositories/vehicle_repository.dart';
import 'package:automotive_scanner/core/localization/app_strings_en.dart';
import 'package:automotive_scanner/core/localization/app_strings_ar.dart';
import 'package:automotive_scanner/presentation/providers/obd_state.dart';
import 'package:automotive_scanner/data/models/inspection_report.dart';
import 'package:automotive_scanner/data/models/freeze_frame.dart';
import 'package:automotive_scanner/domain/analyzers/fuel_economy_calculator.dart';
import 'package:automotive_scanner/data/models/adapter_profile.dart';
import 'package:automotive_scanner/data/datasources/dtc_knowledge_base.dart';
import 'package:automotive_scanner/data/repositories/dtc_repository.dart';
import 'package:automotive_scanner/data/models/actuation_test_model.dart';
import 'package:automotive_scanner/domain/services/cloud_backup_service.dart';
import 'package:automotive_scanner/data/models/ecu_module_node.dart';
import 'package:automotive_scanner/data/models/ev_battery_models.dart';
import 'package:automotive_scanner/data/models/immo_key_models.dart';
import 'package:automotive_scanner/data/models/used_car_audit_models.dart';
import 'package:automotive_scanner/data/models/lab_scope_models.dart';
import 'package:automotive_scanner/data/models/wiring_schematic_models.dart';
import 'package:automotive_scanner/data/models/adas_calibration_models.dart';
import 'package:automotive_scanner/data/models/dpf_aftertreatment_models.dart';
import 'package:automotive_scanner/data/datasources/usb_serial_obd_connection.dart';
import 'package:automotive_scanner/data/datasources/ble_obd_connection.dart';
import 'package:automotive_scanner/domain/services/used_car_pdf_report_service.dart';
import 'package:automotive_scanner/data/models/voice_command_models.dart';
import 'package:automotive_scanner/domain/services/voice_assistant_engine.dart';
import 'package:automotive_scanner/data/models/ar_component_models.dart';
import 'package:automotive_scanner/data/models/customer_dispatch_models.dart';
import 'package:automotive_scanner/data/models/raw_can_frame_models.dart';
import 'package:automotive_scanner/domain/services/offline_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pillar 1: Diagzone 37+ Special Functions Parity', () {
    test('Should have at least 37 unique special service reset functions', () {
      final list = SpecialFunctionModel.getAllFunctions();
      expect(list.length, greaterThanOrEqualTo(37));
      final ids = list.map((f) => f.id).toSet();
      expect(ids.length, list.length, reason: 'All function IDs must be unique');
    });

    test('Functions must contain automated OBD routines and Egyptian manual instructions', () {
      final list = SpecialFunctionModel.getAllFunctions();
      for (final f in list) {
        expect(f.title.isNotEmpty, true);
        expect(f.automatedObdCommand.isNotEmpty, true);
        expect(f.manualSteps.isNotEmpty, true);
        expect(f.category.isNotEmpty, true);
      }
    });

    test('Special functions must cover advanced resets (DSG, Coolant, AdBlue, NOx, Stop/Start)', () {
      final list = SpecialFunctionModel.getAllFunctions();
      final ids = list.map((f) => f.id).toSet();
      expect(ids.contains('coolant_bleed'), true);
      expect(ids.contains('adblue_reset'), true);
      expect(ids.contains('nox_reset'), true);
      expect(ids.contains('stop_start_reset'), true);
      expect(ids.contains('transport_mode'), true);
      expect(ids.contains('clutch_match'), true);
      expect(ids.contains('turbo_match'), true);
      expect(ids.contains('seat_calib'), true);
      expect(ids.contains('ecu_reboot'), true);
    });
  });

  group('Pillar 2: ECU Variant Coding & Hidden Features', () {
    test('Should have 10 standard high-demand ECU coding features', () {
      final list = EcuCodingFeature.getDefaultFeatures();
      expect(list.length, greaterThanOrEqualTo(10));
      for (final feature in list) {
        expect(feature.id.isNotEmpty, true);
        expect(feature.title.isNotEmpty, true);
        expect(feature.titleAr.isNotEmpty, true);
        expect(feature.writeCommandEnable.startsWith("2E"), true);
        expect(feature.writeCommandDisable.startsWith("2E"), true);
      }
    });

    test('Coding features must include Needle Sweep, Mirror Fold, and Egyptian 120km chime', () {
      final list = EcuCodingFeature.getDefaultFeatures();
      final ids = list.map((f) => f.id).toSet();
      expect(ids.contains('needle_sweep'), true);
      expect(ids.contains('mirror_fold'), true);
      expect(ids.contains('speed_warning_120'), true);
      expect(ids.contains('drl_activation'), true);
      expect(ids.contains('cornering_fog_lights'), true);
    });
  });

  group('Pillar 3: 250+ Worldwide Brand Catalog Parity', () {
    test('Catalog should contain 250+ worldwide brands matching Launch X431', () {
      final brands = WorldwideBrandCatalog.allBrands;
      expect(brands.length, greaterThanOrEqualTo(250));
    });

    test('Regions must include Asian, European, American, Chinese, and Commercial', () {
      final regions = WorldwideBrandCatalog.regions;
      expect(regions, contains('All Regions'));
      expect(regions, contains('Asian'));
      expect(regions, contains('European'));
      expect(regions, contains('American'));
      expect(regions, contains('Chinese'));
      expect(regions, contains('Commercial'));
    });

    test('Filtering worldwide brands by region works properly', () {
      final chineseBrands = WorldwideBrandCatalog.filter(region: 'Chinese');
      expect(chineseBrands.length, greaterThanOrEqualTo(50));
      expect(chineseBrands.any((b) => b.name == 'Chery'), true);
      expect(chineseBrands.any((b) => b.name == 'Jetour'), true);
      expect(chineseBrands.any((b) => b.name == 'BYD'), true);

      final commercialBrands = WorldwideBrandCatalog.filter(region: 'Commercial');
      expect(commercialBrands.length, greaterThanOrEqualTo(25));
      expect(commercialBrands.any((b) => b.name == 'King Long'), true);
      expect(commercialBrands.any((b) => b.name == 'Golden Dragon'), true);
      expect(commercialBrands.any((b) => b.name.contains('Fuso')), true);
    });

    test('VehicleRepository can generate generic fallback profile for any brand', () {
      final repo = VehicleRepository();
      const testBrand = WorldwideBrand(
        name: 'Maserati',
        nameAr: 'مازيراتي',
        region: 'European',
        country: 'Italy',
      );
      final profile = repo.createGenericProfile(testBrand);
      expect(profile.make, 'Maserati');
      expect(profile.makeAr, 'مازيراتي');
      expect(profile.protocol, contains('ISO 15765-4'));
      expect(profile.atProtocolCmd, 'AT SP 0');
    });

    test('VehicleProfile correctly derives region', () {
      expect(VehicleProfile.deriveRegion('Chery'), 'Chinese');
      expect(VehicleProfile.deriveRegion('Jetour'), 'Chinese');
      expect(VehicleProfile.deriveRegion('Mercedes-Benz'), 'European');
      expect(VehicleProfile.deriveRegion('Ford'), 'American');
      expect(VehicleProfile.deriveRegion('Toyota'), 'Asian');
      expect(VehicleProfile.deriveRegion('King Long'), 'Commercial');
      expect(VehicleProfile.deriveRegion('Golden Dragon'), 'Commercial');
    });
  });

  group('Pillar 4: Security Gateway (SGW) Bypass Assistant', () {
    test('SGW catalog includes FCA, Renault, and Nissan platforms in Egypt', () {
      final guides = SgwVehicleGuide.catalog;
      expect(guides.length, greaterThanOrEqualTo(4));

      final tipo = guides.firstWhere((g) => g.id == 'fiat_tipo_sgw');
      expect(tipo.sgwType, contains('12+8'));
      expect(tipo.location.isNotEmpty, true);
      expect(tipo.pinouts.length, greaterThanOrEqualTo(4));
      expect(tipo.procedureSteps.length, greaterThanOrEqualTo(4));
    });

    test('Pinouts specify CAN High, CAN Low, Power, and Ground', () {
      final guides = SgwVehicleGuide.catalog;
      for (final guide in guides) {
        expect(guide.pinouts.isNotEmpty, true);
        final signals = guide.pinouts.map((p) => p.signalName).toList();
        expect(signals.any((s) => s.contains('CAN') && (s.contains('H') || s.contains('High'))), true);
        expect(signals.any((s) => s.contains('CAN') && (s.contains('L') || s.contains('Low'))), true);
      }
    });
  });

  group('Pillar 5: Enhanced OEM Deep Telemetry PIDs', () {
    test('Standard PIDs must include Transmission Temp, 4-wheel ABS speeds, and Turbo Boost', () {
      final pids = SensorPid.getStandardPids();

      final transPid = pids.firstWhere((p) => p.name == 'Transmission Fluid Temp');
      expect(transPid.category, 'Transmission');
      expect(transPid.decoder([130]), 90.0); // 130 - 40 = 90°C

      final wheelSpeeds = pids.where((p) => p.category == 'ABS Speeds').toList();
      expect(wheelSpeeds.length, 4); // FL, FR, RL, RR

      final turboPids = pids.where((p) => p.name.contains('Turbo Boost')).toList();
      expect(turboPids.length, 2); // Actual and Target

      final railPids = pids.where((p) => p.name.contains('Fuel Rail Pressure')).toList();
      expect(railPids.length, 2); // Actual and Target
    });
  });

  group('Pillar 6: Dual English & Egyptian Workshop Arabic Localization', () {
    test('English and Arabic string dictionaries have corresponding constants', () {
      expect(AppStrings.appName.isNotEmpty, true);
      expect(AppStringsAr.appName.isNotEmpty, true);
      expect(AppStrings.quickScan.isNotEmpty, true);
      expect(AppStringsAr.quickScan.isNotEmpty, true);
      expect(AppStrings.ecuCoding.isNotEmpty, true);
      expect(AppStringsAr.ecuCoding.isNotEmpty, true);
      expect(AppStrings.sgwAssistant.isNotEmpty, true);
      expect(AppStringsAr.sgwAssistant.isNotEmpty, true);
      expect(AppStrings.diagzoneSpecialFunctions.isNotEmpty, true);
      expect(AppStringsAr.diagzoneSpecialFunctions.isNotEmpty, true);
      expect(AppStrings.fullVehicleTest.isNotEmpty, true);
      expect(AppStringsAr.fullVehicleTest.isNotEmpty, true);
    });

    test('Pure English Mode: Zero Arabic characters in English getters, profiles, and models', () async {
      final arabicPattern = RegExp(r'[\u0600-\u06FF]');

      // 1. Vehicle Profiles & Notes
      final vehicleRepo = VehicleRepository();
      await vehicleRepo.loadProfiles();
      for (final profile in vehicleRepo.profiles) {
        final enName = profile.getDisplayName(false);
        final enNotes = profile.getDisplayNotes(false);
        expect(arabicPattern.hasMatch(enName), false,
            reason: 'Profile ${profile.id} display name contains Arabic characters in English mode: $enName');
        expect(arabicPattern.hasMatch(enNotes), false,
            reason: 'Profile ${profile.id} notes contain Arabic characters in English mode: $enNotes');

        for (final cp in profile.customPids) {
          final cpName = cp.getDisplayName(false);
          expect(arabicPattern.hasMatch(cpName), false,
              reason: 'Custom PID ${cp.pid} contains Arabic characters in English mode: $cpName');
        }
      }

      // 2. Fuel Economy Calculator Grade Labels
      final calc = FuelEconomyCalculator();
      for (final grade in EgyptianFuelGrade.values) {
        calc.selectedGrade = grade;
        final label = calc.getGradeLabel(false);
        expect(arabicPattern.hasMatch(label), false,
            reason: 'Fuel grade $grade label contains Arabic characters in English mode: $label');
      }

      // 3. Inspection Report Workshop Name
      final emptyReport = InspectionReport(
        id: 'test_report',
        plateNumber: 'ABC 123',
        vin: '1HGCR2F83HA000000',
        customerName: 'Workshop Inspection',
        customerPhone: '+201553666635',
        vehicleMakeModel: 'Toyota Corolla 1.6L',
        timestamp: DateTime.now(),
        batteryVoltage: 12.6,
        milStatusOn: false,
        dtcsFound: [],
        liveSensorsSnapshot: {},
        mechanicNotes: 'All systems normal',
      );
      expect(arabicPattern.hasMatch(emptyReport.workshopName), false,
          reason: 'Default workshop name contains Arabic in English mode');

      // 4. Freeze Frame Empty Status
      final emptyFf = FreezeFrameModel.empty();
      expect(arabicPattern.hasMatch(emptyFf.dtcCode), false,
          reason: 'FreezeFrameModel.empty().dtcCode contains Arabic in English mode: ${emptyFf.dtcCode}');
    });
  });

  group('Pillar 7: 1-Click Full Vehicle Test Suite', () {
    test('16-stage diagnostic sequence executes, generates health index and saves inspection report', () async {
      final state = ObdState();

      // Ensure simulator is ready
      await state.connectSimulator();
      expect(state.isConnected, true);

      // Execute 1-Click Full Health Test
      final List<int> progressStages = [];
      final result = await state.runFullSystemHealthTest(
        onProgress: (stage, name, progress, detail) {
          progressStages.add(stage);
        },
      );

      // Verify 16 stages completion
      expect(result.stages.length, 16);
      expect(result.stages.every((s) => s.isCompleted), true);
      expect(progressStages.length, greaterThanOrEqualTo(16));

      // Verify health score and ratings
      expect(result.healthScore, inInclusiveRange(15, 100));
      expect(result.healthRatingEn.isNotEmpty, true);
      expect(result.healthRatingAr.isNotEmpty, true);
      expect(RegExp(r'[\u0600-\u06FF]').hasMatch(result.healthRatingEn), false,
          reason: 'English rating must contain zero Arabic characters');

      // Verify ECU Modules topology
      expect(result.ecuModules.length, greaterThanOrEqualTo(5));

      // Verify analyzers integrations
      expect(result.batteryHealth != null, true);
      expect(result.fuelTrimHealth != null, true);
      expect(result.catalyticHealth != null, true);

      // Verify auto-compiled report
      expect(result.report.id.isNotEmpty, true);
      expect(result.report.batteryVoltage, greaterThan(11.0));
      expect(state.savedReports.any((r) => r.id == result.report.id), true,
          reason: 'Report must be auto-archived into SQLite workshop repository');
      expect(state.lastFullTestResult, isNotNull);
    });

    test('Every diagnostic stage carries rich parameters, nominal OEM ranges, and zero Arabic in English mode', () async {
      final state = ObdState();
      await state.connectSimulator();
      final result = await state.runFullSystemHealthTest();

      expect(result.stages.length, 16);

      for (var stage in result.stages) {
        expect(stage.titleEn.isNotEmpty, true);
        expect(stage.descriptionEn.isNotEmpty, true);
        expect(stage.category.isNotEmpty, true);
        expect(stage.technicalExplanationEn.isNotEmpty, true);
        expect(stage.recommendationEn.isNotEmpty, true);

        // Strict zero Arabic leakage enforcement
        expect(RegExp(r'[\u0600-\u06FF]').hasMatch(stage.titleEn), false,
            reason: 'Stage ${stage.stageNumber} titleEn has Arabic leakage');
        expect(RegExp(r'[\u0600-\u06FF]').hasMatch(stage.descriptionEn), false,
            reason: 'Stage ${stage.stageNumber} descriptionEn has Arabic leakage');
        expect(RegExp(r'[\u0600-\u06FF]').hasMatch(stage.statusDetailEn), false,
            reason: 'Stage ${stage.stageNumber} statusDetailEn has Arabic leakage');
        expect(RegExp(r'[\u0600-\u06FF]').hasMatch(stage.technicalExplanationEn), false,
            reason: 'Stage ${stage.stageNumber} technicalExplanationEn has Arabic leakage');
        expect(RegExp(r'[\u0600-\u06FF]').hasMatch(stage.recommendationEn), false,
            reason: 'Stage ${stage.stageNumber} recommendationEn has Arabic leakage');

        // Verify parameters
        if (stage.parameters.isNotEmpty) {
          for (var param in stage.parameters) {
            expect(param.nameEn.isNotEmpty, true);
            expect(param.value.isNotEmpty, true);
            expect(RegExp(r'[\u0600-\u06FF]').hasMatch(param.nameEn), false,
                reason: 'Parameter ${param.nameEn} in stage ${stage.stageNumber} has Arabic leakage');
          }
        }
      }

      // Check specific domain stages
      final m06Stage = result.stages.firstWhere((s) => s.stageNumber == 10);
      expect(m06Stage.category, "On-Board Monitoring");
      expect(m06Stage.parameters.length, greaterThanOrEqualTo(5));

      final evapStage = result.stages.firstWhere((s) => s.stageNumber == 11);
      expect(evapStage.category, "Fuel Evaporation");

      final tcmStage = result.stages.firstWhere((s) => s.stageNumber == 12);
      expect(tcmStage.category, "Transmission");

      final absStage = result.stages.firstWhere((s) => s.stageNumber == 13);
      expect(absStage.category, "Chassis & Brakes");

      final srsStage = result.stages.firstWhere((s) => s.stageNumber == 14);
      expect(srsStage.category, "Safety & Airbags");

      final hvacStage = result.stages.firstWhere((s) => s.stageNumber == 15);
      expect(hvacStage.category, "Climate Control");

      final sgwStage = result.stages.firstWhere((s) => s.stageNumber == 16);
      expect(sgwStage.category, "Security & Report");
    });
  });

  group('Pillar 8: BLE & Multi-Adapter Auto-Connect Engine', () {
    test('AdapterProfile classifies major professional workshop adapters correctly', () {
      final vlinker = AdapterProfile.detect('vLinker MC+ Bluetooth');
      expect(vlinker.brand, AdapterBrand.vLinker);
      expect(vlinker.highSpeedCapable, true);
      expect(vlinker.maxBaudRate, greaterThanOrEqualTo(500000));

      final obdlink = AdapterProfile.detect('OBDLink MX+ 2024');
      expect(obdlink.brand, AdapterBrand.obdLink);
      expect(obdlink.highSpeedCapable, true);

      final veepeak = AdapterProfile.detect('Veepeak OBDCheck BLE+');
      expect(veepeak.brand, AdapterBrand.veepeak);

      final carista = AdapterProfile.detect('Carista BT OBD2');
      expect(carista.brand, AdapterBrand.carista);

      final viecar = AdapterProfile.detect('Viecar 4.0 BLE');
      expect(viecar.brand, AdapterBrand.viecar);

      final unicar = AdapterProfile.detect('UniCarScan UCSI-2000');
      expect(unicar.brand, AdapterBrand.uniCarScan);

      final konnwei = AdapterProfile.detect('Konnwei KW902 OBD');
      expect(konnwei.brand, AdapterBrand.konnwei);

      final nexas = AdapterProfile.detect('Nexas NexLink BT');
      expect(nexas.brand, AdapterBrand.nexas);

      final elmGeneric = AdapterProfile.detect('OBDII ELM327 v1.5');
      expect(elmGeneric.brand, AdapterBrand.genericElm327);
      expect(elmGeneric.highSpeedCapable, false);
    });

    test('Scoring algorithm prioritizes bonded, recently connected, and premier hardware adapters', () {
      final scorePremierBonded = AdapterProfile.scoreDevice(
        name: 'vLinker MC+ 4.0',
        address: '00:11:22:33:44:55',
        isBonded: true,
        isRecentlyConnected: true,
      );

      final scoreGenericUnbonded = AdapterProfile.scoreDevice(
        name: 'Generic ELM327',
        address: 'AA:BB:CC:DD:EE:FF',
        isBonded: false,
        isRecentlyConnected: false,
      );

      final scoreNonObd = AdapterProfile.scoreDevice(
        name: 'Wireless Headphones',
        address: '11:22:33:44:55:66',
        isBonded: false,
        isRecentlyConnected: false,
      );

      expect(scorePremierBonded, greaterThan(scoreGenericUnbonded));
      expect(scoreGenericUnbonded, greaterThan(scoreNonObd));
      expect(scorePremierBonded, greaterThanOrEqualTo(90));
    });
  });

  group('Pillar 9: Offline 500+ DTC Repair Knowledge Base', () {
    test('DTC Knowledge Base pre-bundles over 500 automotive diagnostic guides', () {
      expect(DtcKnowledgeBase.totalGuidesCount, greaterThanOrEqualTo(500));
      expect(DtcKnowledgeBase.allGuides.length, greaterThanOrEqualTo(500));
    });

    test('Contains standard core Powertrain, Chassis, Body, and Network guides', () {
      expect(DtcKnowledgeBase.hasGuide('P0300'), true);
      expect(DtcKnowledgeBase.hasGuide('P0420'), true);
      expect(DtcKnowledgeBase.hasGuide('P0171'), true);
      expect(DtcKnowledgeBase.hasGuide('C0035'), true);
      expect(DtcKnowledgeBase.hasGuide('B0001'), true);
      expect(DtcKnowledgeBase.hasGuide('U0100'), true);

      final guideP0010 = DtcKnowledgeBase.getGuide('P0010');
      expect(guideP0010, isNotNull);
      expect(guideP0010!.symptomsEn.isNotEmpty, true);
      expect(guideP0010.probableCausesEn.isNotEmpty, true);
      expect(guideP0010.diagnosticRoadmapEn.isNotEmpty, true);
      expect(guideP0010.pinoutChecksEn.isNotEmpty, true);
      expect(guideP0010.recommendedFixEn.isNotEmpty, true);
    });

    test('Zero Arabic characters in English mode across all 500+ repair guides', () {
      final arabicPattern = RegExp(r'[\u0600-\u06FF]');

      for (final guide in DtcKnowledgeBase.allGuides) {
        final desc = guide.getDescription(false);
        expect(arabicPattern.hasMatch(desc), false,
            reason: '${guide.code} description contains Arabic characters in English mode: $desc');

        final fix = guide.getRecommendedFix(false);
        expect(arabicPattern.hasMatch(fix), false,
            reason: '${guide.code} fix contains Arabic characters in English mode: $fix');

        for (final cause in guide.getProbableCauses(false)) {
          expect(arabicPattern.hasMatch(cause), false,
              reason: '${guide.code} cause contains Arabic in English mode: $cause');
        }

        for (final symptom in guide.getSymptoms(false)) {
          expect(arabicPattern.hasMatch(symptom), false,
              reason: '${guide.code} symptom contains Arabic in English mode: $symptom');
        }

        for (final step in guide.getDiagnosticRoadmap(false)) {
          expect(arabicPattern.hasMatch(step), false,
              reason: '${guide.code} step contains Arabic in English mode: $step');
        }

        for (final check in guide.getElectricalChecks(false)) {
          expect(arabicPattern.hasMatch(check), false,
              reason: '${guide.code} check contains Arabic in English mode: $check');
        }
      }
    });

    test('DtcRepository smoothly retrieves knowledge base guide for scanned DTC', () async {
      final repo = DtcRepository();
      final dtcItem = await repo.getDtcDetails('P0100');
      expect(dtcItem.code, 'P0100');
      expect(dtcItem.repairGuide, isNotNull);
      expect(dtcItem.repairGuide!.code, 'P0100');
      expect(dtcItem.repairGuide!.pinoutChecksEn.length, greaterThanOrEqualTo(1));
    });
  });

  group('Pillar 10: Guided Actuator Test Engine', () {
    test('ActuationTestModel defines multi-step interactive routines alongside single-shot tests', () {
      final tests = ActuationTestModel.getAllActuatorTests();
      expect(tests.length, greaterThanOrEqualTo(6));

      // Guided tests
      final absBleed = tests.firstWhere((t) => t.id == 'abs_brake_bleeding_routine');
      expect(absBleed.isGuidedRoutine, true);
      expect(absBleed.safetyChecklist.length, greaterThanOrEqualTo(3));
      expect(absBleed.guidedSteps.length, greaterThanOrEqualTo(3));

      final throttleRelearn = tests.firstWhere((t) => t.id == 'throttle_relearn_routine');
      expect(throttleRelearn.isGuidedRoutine, true);
      expect(throttleRelearn.guidedSteps.length, greaterThanOrEqualTo(3));

      final radiatorFan = tests.firstWhere((t) => t.id == 'radiator_fan_dual_test');
      expect(radiatorFan.isGuidedRoutine, true);
      expect(radiatorFan.guidedSteps.length, greaterThanOrEqualTo(2));

      // Single shot tests
      final fuelPump = tests.firstWhere((t) => t.id == 'fuel_pump_prime');
      expect(fuelPump.isGuidedRoutine, false);
      expect(fuelPump.guidedSteps.isEmpty, true);
    });

    test('Guided steps contain safety warnings and duration countdowns', () {
      final tests = ActuationTestModel.getAllActuatorTests();
      final absBleed = tests.firstWhere((t) => t.id == 'abs_brake_bleeding_routine');
      for (final step in absBleed.guidedSteps) {
        expect(step.id.isNotEmpty, true);
        expect(step.titleEn.isNotEmpty, true);
        expect(step.instructionEn.isNotEmpty, true);
        expect(step.durationSeconds, greaterThanOrEqualTo(0));
      }
      expect(absBleed.guidedSteps.any((s) => s.durationSeconds > 0), true);
    });
  });

  group('Pillar 11: Automated Cloud Backup & Fleet Sync', () {
    test('CloudBackupService exports valid JSON bundle with SHA-256 integrity checksum', () async {
      final sampleReport = InspectionReport(
        id: 'fleet_sync_test_01',
        plateNumber: 'XYZ 789',
        vin: '1HGCR2F83HA999999',
        customerName: 'Cairo Fleet Services',
        customerPhone: '+201001234567',
        vehicleMakeModel: 'Hyundai Elantra CN7',
        timestamp: DateTime.now(),
        batteryVoltage: 12.8,
        milStatusOn: false,
        dtcsFound: [await DtcRepository().getDtcDetails('P0300')],
        liveSensorsSnapshot: {'RPM': '750', 'SPEED': '0'},
        mechanicNotes: 'Pre-delivery inspection passed',
      );

      final bundleJson = CloudBackupService.exportBundle([sampleReport]);
      expect(bundleJson.contains('"schemaVersion": "1.0.0"'), true);
      expect(bundleJson.contains('"checksumSha256"'), true);
      expect(bundleJson.contains('fleet_sync_test_01'), true);

      // Verify SHA-256 integrity
      final isValid = CloudBackupService.verifyChecksum(bundleJson);
      expect(isValid, true);

      // Tampered bundle must fail checksum
      final tamperedJson = bundleJson.replaceFirst('Hyundai Elantra CN7', 'Tampered Vehicle');
      expect(CloudBackupService.verifyChecksum(tamperedJson), false);
    });

    test('CloudBackupService imports bundle and skips existing reports', () async {
      final sampleReport = InspectionReport(
        id: 'fleet_import_test_02',
        plateNumber: 'DEF 456',
        vin: '1HGCR2F83HA888888',
        customerName: 'Giza Workshop',
        customerPhone: '+201112345678',
        vehicleMakeModel: 'Nissan Sunny 1.5L',
        timestamp: DateTime.now(),
        batteryVoltage: 12.5,
        milStatusOn: false,
        dtcsFound: [],
        liveSensorsSnapshot: {},
        mechanicNotes: 'Oil and filter replaced',
      );

      final bundleJson = CloudBackupService.exportBundle([sampleReport]);

      final service = CloudBackupService();
      final result1 = await service.importBackupBundle(bundleJson);
      expect(result1['totalInFile'], 1);
      expect(result1['imported']! + result1['skipped']!, 1);

      // Second import of same bundle -> 0 imported, 1 skipped
      final result2 = await service.importBackupBundle(bundleJson);
      expect(result2['imported'], 0);
      expect(result2['skipped'], 1);
    });
  });

  group('Pillar 12: Diagzone Flagship 1 - Multi-Trunk CAN / LIN Topology Visual Graph', () {
    test('Extended network topology defines 12+ nodes across 4 distinct bus trunks', () {
      final nodes = EcuModuleNode.getExtendedNetworkTopology();
      expect(nodes.length, greaterThanOrEqualTo(12));

      final busTrunks = nodes.map((n) => n.busType).toSet();
      expect(busTrunks.contains(CanBusType.ptCan500k), true);
      expect(busTrunks.contains(CanBusType.chassisCan500k), true);
      expect(busTrunks.contains(CanBusType.bodyCan125k), true);
      expect(busTrunks.contains(CanBusType.lin19k), true);
    });

    test('Nodes have full diagnostic attributes (Baud, Part Numbers, Coding, Protocol)', () {
      final nodes = EcuModuleNode.getExtendedNetworkTopology();
      for (final n in nodes) {
        expect(n.header.isNotEmpty, true);
        expect(n.shortName.isNotEmpty, true);
        expect(n.fullName.isNotEmpty, true);
        expect(n.baudRate.isNotEmpty, true);
        expect(n.softwarePartNumber.isNotEmpty, true);
        expect(n.hardwarePartNumber.isNotEmpty, true);
        expect(n.codingHex.isNotEmpty, true);
        expect(n.busNameEn.isNotEmpty, true);
      }
    });

    test('Zero Arabic characters in English getters and metadata across all topology nodes', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      final nodes = EcuModuleNode.getExtendedNetworkTopology();
      for (final n in nodes) {
        expect(arabicRegex.hasMatch(n.shortName), false);
        expect(arabicRegex.hasMatch(n.fullName), false);
        expect(arabicRegex.hasMatch(n.description), false);
        expect(arabicRegex.hasMatch(n.busNameEn), false);
        expect(arabicRegex.hasMatch(n.baudRate), false);
      }
    });
  });


  group('Pillar 13: Diagzone Flagship 2 - Anti-Theft IMMO & Key Programming Suite', () {
    test('Preset transponder chips include ID46, ID48, ID8A, and ID8E with EEPROM dumps', () {
      final chips = TransponderChipInfo.getPresetTransponders();
      expect(chips.length, greaterThanOrEqualTo(4));

      final types = chips.map((c) => c.chipType).toSet();
      expect(types.contains('ID46'), true);
      expect(types.contains('ID48'), true);
      expect(types.contains('ID8A'), true);
      expect(types.contains('ID8E'), true);

      for (final chip in chips) {
        expect(chip.frequency.contains('MHz'), true);
        expect(chip.keyIdHex.startsWith('0x'), true);
        expect(chip.pageData.isNotEmpty, true);
        expect(chip.compatibleVehicles.isNotEmpty, true);
      }
    });

    test('PIN code calculator computes valid security codes across 5 OEM platforms', () {
      final psaPin = PinCodeCalculation.calculatePin("PSA Peugeot / Citroën (4-Digit PIN)", "VF38E9HP0DM123456");
      expect(psaPin.length, 4);

      final nissanPin = PinCodeCalculation.calculatePin("Nissan / Infiniti BCM (20-Digit to PIN)", "B987F23E4510AB89CD21");
      expect(nissanPin.length, 4);

      final hyundaiPin = PinCodeCalculation.calculatePin("Hyundai / Kia (6-Digit VIN-to-PIN)", "KMHCT41CBFU123456");
      expect(hyundaiPin.length, 6);

      final renaultPin = PinCodeCalculation.calculatePin("Renault ISK / Incode Calculator", "A4B1C2D3");
      expect(renaultPin.length, 4);

      final vagSkc = PinCodeCalculation.calculatePin("VAG Group 5-Digit Secret Key (SKC)", "VWZ7Z0E1234567");
      expect(vagSkc.length, 5);
    });

    test('Guided key learning wizard defines 5 sequential UDS steps', () {
      final steps = KeyLearningStep.getDefaultLearningSteps();
      expect(steps.length, 5);

      for (int i = 0; i < steps.length; i++) {
        expect(steps[i].stepNumber, i + 1);
        expect(steps[i].titleEn.isNotEmpty, true);
        expect(steps[i].instructionEn.isNotEmpty, true);
        expect(steps[i].commandHex.isNotEmpty, true);
        expect(steps[i].durationSeconds, greaterThan(0));
      }
    });

    test('Zero Arabic characters in English properties of IMMO models', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      for (final chip in TransponderChipInfo.getPresetTransponders()) {
        expect(arabicRegex.hasMatch(chip.chipType), false);
        expect(arabicRegex.hasMatch(chip.chipFamily), false);
        expect(arabicRegex.hasMatch(chip.encryptionType), false);
        for (final v in chip.compatibleVehicles) {
          expect(arabicRegex.hasMatch(v), false);
        }
      }

      for (final step in KeyLearningStep.getDefaultLearningSteps()) {
        expect(arabicRegex.hasMatch(step.titleEn), false);
        expect(arabicRegex.hasMatch(step.instructionEn), false);
      }
    });
  });

  group('Pillar 14: Diagzone Flagship 3 - EV & Hybrid High-Voltage Battery Lab', () {
    test('Battery pack model generates complete 96-cell individual voltage matrix', () {
      final pack = EvBatteryPackSummary.generateDefaultPack();
      expect(pack.cells.length, 96);
      expect(pack.totalVoltage, greaterThan(350.0));
      expect(pack.socPercent, greaterThan(0.0));
      expect(pack.sohPercent, greaterThan(80.0));
    });

    test('Computes max/min cell voltage and delta mV accurately', () {
      final pack = EvBatteryPackSummary.generateDefaultPack();
      expect(pack.maxCellVoltage, greaterThanOrEqualTo(pack.minCellVoltage));
      expect(pack.deltaMilliVolts, greaterThan(0.0));
      expect(pack.highestCellIndex, greaterThanOrEqualTo(1));
      expect(pack.lowestCellIndex, greaterThanOrEqualTo(1));
    });

    test('Passive cell rebalancing routine reduces delta to nominal OEM range', () {
      final weakPack = EvBatteryPackSummary.generateDefaultPack(simulateWeakCell: true);
      expect(weakPack.deltaMilliVolts, greaterThan(50.0));

      final balancedPack = weakPack.rebalanceCells();
      expect(balancedPack.deltaMilliVolts, lessThanOrEqualTo(15.0));
      expect(balancedPack.cells.length, 96);
    });

    test('High-voltage isolation resistance and safety contactors validation', () {
      final pack = EvBatteryPackSummary.generateDefaultPack();
      final safety = pack.safetyStatus;
      expect(safety.isIsolationSafe, true);
      expect(safety.isolationResistanceMegaOhms, greaterThanOrEqualTo(safety.isolationThresholdMegaOhms));
      expect(safety.hvilLoopClosed, true);
      expect(safety.mainPositiveContactorEngaged, true);
      expect(safety.mainNegativeContactorEngaged, true);
      expect(safety.pyroFuseArmed, true);
    });

    test('Thermal distribution monitors 4 temperature zones across pack modules', () {
      final pack = EvBatteryPackSummary.generateDefaultPack();
      expect(pack.thermalZones.length, 4);
      for (final zone in pack.thermalZones) {
        expect(zone.tempCelsius, greaterThan(15.0));
        expect(zone.tempCelsius, lessThan(45.0));
      }
    });

    test('Zero Arabic characters in English getters and properties of EV Battery models', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      final pack = EvBatteryPackSummary.generateDefaultPack();
      expect(arabicRegex.hasMatch(pack.balanceRatingEn), false);
      for (final zone in pack.thermalZones) {
        expect(arabicRegex.hasMatch(zone.locationNameEn), false);
      }
    });
  });

  group('Pillar 15: Used Car Inspection & Fraud/Tampering Audit', () {
    test('Cross-checks instrument cluster odometer against ECM, TCM, and ABS', () {
      final cleanScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false);
      final odo = cleanScorecard.odometerAudit;
      expect(odo.isRollbackSuspected, false);
      expect(odo.maxDeltaKm, lessThanOrEqualTo(1000));
      expect(odo.verdictEn.isNotEmpty, true);

      final tamperedScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true);
      final tamperedOdo = tamperedScorecard.odometerAudit;
      expect(tamperedOdo.isRollbackSuspected, true);
      expect(tamperedOdo.maxDeltaKm, greaterThan(20000));
      expect(tamperedOdo.clusterMileageKm, lessThan(tamperedOdo.ecmMileageKm));
    });

    test('Code clearing fraud audit analyzes PID 30 distance and warm-up cycles', () {
      final cleanAudit = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false).codeClearingAudit;
      expect(cleanAudit.isRecentlyCleared, false);
      expect(cleanAudit.distanceSinceDtcClearedKm, greaterThanOrEqualTo(30));
      expect(cleanAudit.warmUpCyclesSinceDtcCleared, greaterThanOrEqualTo(3));

      final tamperedAudit = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true).codeClearingAudit;
      expect(tamperedAudit.isRecentlyCleared, true);
      expect(tamperedAudit.distanceSinceDtcClearedKm, lessThan(30));
      expect(tamperedAudit.warmUpCyclesSinceDtcCleared, lessThan(3));
    });

    test('Multi-ECU VIN match validation verifies ECM, BCM, and TCU matching', () {
      final cleanVin = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false).vinAudit;
      expect(cleanVin.isVinMatched, true);
      expect(cleanVin.mismatchedModules.isEmpty, true);

      final tamperedVin = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true).vinAudit;
      expect(tamperedVin.isVinMatched, false);
      expect(tamperedVin.mismatchedModules.isNotEmpty, true);
    });

    test('Airbag SRS crash recorder flags stored crash records and deployment count', () {
      final cleanSrs = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false).srsCrash;
      expect(cleanSrs.hasCrashData, false);
      expect(cleanSrs.squibDeploymentCount, 0);

      final crashedSrs = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true).srsCrash;
      expect(crashedSrs.hasCrashData, true);
      expect(crashedSrs.squibDeploymentCount, greaterThan(0));
    });

    test('100-point inspection scorecard computes score and assigns grade', () {
      final cleanScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false);
      expect(cleanScorecard.overallScore, greaterThan(80));
      expect(cleanScorecard.gradeClassificationEn, contains('GRADE'));
      expect(cleanScorecard.verificationHash.length, greaterThan(8));

      final tamperedScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true);
      expect(tamperedScorecard.overallScore, lessThan(60));
      expect(tamperedScorecard.gradeClassificationEn, contains('GRADE D'));
    });

    test('Drivetrain mechanical health report validates compression, trims, O2 and trans temp', () {
      final cleanMech = DrivetrainMechanicalHealthReport.generateDefault(hasDefect: false);
      expect(cleanMech.relativeCompressionBalancePercent, greaterThan(90.0));
      expect(cleanMech.shortTermFuelTrimPercent.abs(), lessThan(10.0));
      expect(cleanMech.longTermFuelTrimPercent.abs(), lessThan(10.0));
      expect(cleanMech.hasMisfireDetected, false);
      expect(cleanMech.totalMisfireCount, 0);

      final defectMech = DrivetrainMechanicalHealthReport.generateDefault(hasDefect: true);
      expect(defectMech.hasMisfireDetected, true);
      expect(defectMech.totalMisfireCount, greaterThan(0));
      expect(defectMech.transmissionFluidTempC, greaterThan(100.0));
    });

    test('Defect repair valuation computes itemized costs and negotiation deduction buffer', () {
      final cleanValuation = DefectRepairEstimateReport.generateDefault(hasDefects: false);
      expect(cleanValuation.totalEstimatedRepairCostEgp, 0.0);
      expect(cleanValuation.defectItems.isEmpty, true);

      final defectValuation = DefectRepairEstimateReport.generateDefault(hasDefects: true);
      expect(defectValuation.defectItems.length, 3);
      expect(defectValuation.totalEstimatedRepairCostEgp, greaterThan(15000.0));
      expect(defectValuation.totalEstimatedRepairCostUsd, greaterThan(250.0));
      expect(defectValuation.recommendedBuyerNegotiationDeductionEgp,
          greaterThan(defectValuation.totalEstimatedRepairCostEgp));
    });

    test('Live vehicle audit scorecard constructs full 6-report model from telemetry', () {
      final liveScorecard = PrePurchaseAuditScorecard.fromLiveVehicle(
        liveVin: "1HGCR2F83HA029418",
        liveClusterKm: 75000,
        liveEcmKm: 75000,
        distanceSinceClearedKm: 1250,
        warmUpsSinceCleared: 55,
        engineRunTimeMinutes: 240,
        storedDtcCount: 0,
        stft: 0.8,
        ltft: 1.2,
        o2Voltage: 0.72,
      );

      expect(liveScorecard.overallScore, greaterThanOrEqualTo(80));
      expect(liveScorecard.odometerAudit.isRollbackSuspected, false);
      expect(liveScorecard.codeClearingAudit.isRecentlyCleared, false);
      expect(liveScorecard.vinAudit.isVinMatched, true);
      expect(liveScorecard.srsCrash.hasCrashData, false);
      expect(liveScorecard.drivetrainHealth.relativeCompressionBalancePercent, greaterThan(90.0));
      expect(liveScorecard.repairEstimates.totalEstimatedRepairCostEgp, 0.0);
    });

    test('UsedCarPdfReportService generates compliant printable PDF document bytes', () async {
      final scorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false);
      final pdfBytes = await UsedCarPdfReportService.generatePdfReport(
        scorecard: scorecard,
        vehicleName: "Honda Accord 2017",
        isArabic: false,
      );

      expect(pdfBytes.isNotEmpty, true);
      // PDF documents start with "%PDF" (bytes 0x25, 0x50, 0x44, 0x46)
      expect(pdfBytes[0], 0x25);
      expect(pdfBytes[1], 0x50);
      expect(pdfBytes[2], 0x44);
      expect(pdfBytes[3], 0x46);
    });
  });

  group('Pillar 21: Universal Physical OBD Hardware Connectors (USB Serial & BLE)', () {
    test('UsbSerialObdConnection parses port name and standard baud rates', () {
      final usb = UsbSerialObdConnection();
      expect(usb.connectionType, "USB Serial (OTG)");
      expect(usb.isConnected, false);
      expect(usb.selectedBaudRate, 115200);

      expect(usb.isBaudSupported(38400), true);
      expect(usb.isBaudSupported(115200), true);
      expect(usb.isBaudSupported(230400), true);
      expect(usb.isBaudSupported(500000), true);
      expect(usb.isBaudSupported(9600), false);
    });

    test('UsbSerialObdConnection supports all major UART chipsets', () {
      final usb = UsbSerialObdConnection();
      final chips = usb.supportedChipsets;
      expect(chips.contains("FTDI FT232R"), true);
      expect(chips.contains("WCH CH340 / CH341"), true);
      expect(chips.contains("Silicon Labs CP2102"), true);
      expect(chips.contains("Prolific PL2303"), true);
      expect(chips.contains("USB CDC-ACM"), true);
    });

    test('BleObdConnection supports standard BLE GATT OBD profiles', () {
      final ble = BleObdConnection();
      expect(ble.connectionType, "Bluetooth LE (BLE 4.0/5.0)");
      expect(ble.isConnected, false);
      final uuids = ble.knownObdGattProfiles;
      expect(uuids.contains("0000ffe0-0000-1000-8000-00805f9b34fb"), true);
      expect(uuids.contains("0000fff0-0000-1000-8000-00805f9b34fb"), true);
      expect(uuids.contains("000018f0-0000-1000-8000-00805f9b34fb"), true);
    });

    test('BleObdConnection connects, streams telemetry, and disconnects safely', () async {
      final ble = BleObdConnection();
      final connected = await ble.connect("Vgate-iCar-Pro-BLE");
      expect(connected, true);
      expect(ble.isConnected, true);

      final receivedData = <List<int>>[];
      final sub = ble.inputStream.listen(receivedData.add);

      await ble.write([0x41, 0x54, 0x5A, 0x0D]); // ATZ
      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedData.isNotEmpty, true);
      await sub.cancel();
      await ble.disconnect();
      expect(ble.isConnected, false);
    });

    test('UsbSerialObdConnection connects, streams telemetry, and disconnects safely', () async {
      final usb = UsbSerialObdConnection();
      final connected = await usb.connect("/dev/bus/usb/001/002@230400");
      expect(connected, true);
      expect(usb.isConnected, true);
      expect(usb.selectedBaudRate, 230400);

      final receivedData = <List<int>>[];
      final sub = usb.inputStream.listen(receivedData.add);

      await usb.write([0x30, 0x31, 0x30, 0x30, 0x0D]); // 0100
      await Future.delayed(const Duration(milliseconds: 50));

      expect(receivedData.isNotEmpty, true);
      await sub.cancel();
      await usb.disconnect();
      expect(usb.isConnected, false);
    });
  });

  group('Pillar 16: Digital Lab Scope & Waveform Library', () {
    test('CKP 60-2 missing tooth and CMP Hall waveform generation produces expected pulse sequences', () {
      final analysis = TimingChainSyncAnalysis.generate(simulateStretch: false);
      expect(analysis.channelACkp.length, greaterThan(40));
      expect(analysis.channelBCmp.length, greaterThan(40));
      expect(analysis.measuredPhaseOffsetDeg, greaterThanOrEqualTo(0.0));
      expect(analysis.isChainStretched, false);
    });

    test('Timing chain stretch analyzer flags chain stretch when phase offset exceeds limit', () {
      final stretched = TimingChainSyncAnalysis.generate(simulateStretch: true);
      expect(stretched.isChainStretched, true);
      expect(stretched.measuredPhaseOffsetDeg, greaterThan(stretched.nominalToleranceDeg));
    });

    test('Ignition primary/secondary waveform analysis calculates burn time and spark peak', () {
      final ignition = IgnitionWaveformAnalysis.generateDefault();
      expect(ignition.sparkWaveform.length, greaterThan(30));
      expect(ignition.sparkBurnTimeMs, inInclusiveRange(1.0, 2.5));
      expect(ignition.sparkLineKv, greaterThan(10.0));
      expect(ignition.isBurnHealthy, true);
    });

    test('Fuel injector inductive flyback waveform evaluates flyback kick voltage and pulse width', () {
      final injector = InjectorWaveformAnalysis.generateDefault();
      expect(injector.injectorWaveform.length, greaterThan(30));
      expect(injector.flybackVoltagePeak, greaterThanOrEqualTo(50.0));
      expect(injector.pulseWidthMs, inInclusiveRange(1.0, 5.0));
      expect(injector.isFlybackHealthy, true);
    });

    test('Golden overlay delta measurement computes time delta and frequency accurately', () {
      const measurement = ScopeCursorMeasurement(
        cursor1TimeMs: 20.0,
        cursor2TimeMs: 40.0,
        cursor1Voltage: 0.0,
        cursor2Voltage: 5.0,
      );
      expect(measurement.deltaTimeMs, 20.0);
      expect(measurement.frequencyHz, 50.0);
      expect(measurement.deltaVoltage, 5.0);
    });
  });

  group('Pillar 17: Interactive Electrical Wiring Schematics & ECU Pinouts', () {
    test('Catalog provides complete vector diagrams for major vehicle systems', () {
      final diagrams = SchematicDiagram.getAllDiagrams();
      expect(diagrams.length, greaterThanOrEqualTo(3));
      for (final d in diagrams) {
        expect(d.id.isNotEmpty, true);
        expect(d.titleEn.isNotEmpty, true);
        expect(d.titleAr.isNotEmpty, true);
        expect(d.components.isNotEmpty, true);
        expect(d.wires.isNotEmpty, true);
        expect(d.pinouts.isNotEmpty, true);
      }
    });

    test('Wire harness models contain OEM wire color codes and pin source/destinations', () {
      final diagrams = SchematicDiagram.getAllDiagrams();
      for (final d in diagrams) {
        for (final w in d.wires) {
          expect(w.wireColorEn.isNotEmpty, true);
          expect(w.wireColorHex, greaterThan(0));
          expect(w.fromComponentId.isNotEmpty, true);
          expect(w.toComponentId.isNotEmpty, true);
          expect(w.signalType.isNotEmpty, true);
        }
      }
    });

    test('ECU pinout multimeter probe guide defines voltages, ground resistance, and instructions', () {
      final diagrams = SchematicDiagram.getAllDiagrams();
      for (final d in diagrams) {
        for (final p in d.pinouts) {
          expect(p.pinNumber, greaterThan(0));
          expect(p.circuitNameEn.isNotEmpty, true);
          expect(p.keyOnVoltage.isNotEmpty, true);
          expect(p.runningVoltage.isNotEmpty, true);
          expect(p.resistanceToGround.isNotEmpty, true);
          expect(p.probeInstructionEn.isNotEmpty, true);
        }
      }
    });
  });

  group('Pillar 18: ADAS Camera & Radar Calibration Assistant', () {
    test('ADAS targets presets cover windshield camera, bumper radar, and vision fusion', () {
      final targets = AdasTargetPlacement.getAllPresets();
      expect(targets.length, greaterThanOrEqualTo(3));
      for (final t in targets) {
        expect(t.systemName.isNotEmpty, true);
        expect(t.brandPlatform.isNotEmpty, true);
        expect(t.targetPatternType.isNotEmpty, true);
      }
    });

    test('Target placement matrix specifies distance, height, and lateral offset', () {
      final targets = AdasTargetPlacement.getAllPresets();
      for (final t in targets) {
        expect(t.distanceFromBumperMm, greaterThan(0));
        expect(t.heightFromGroundMm, greaterThan(0));
        expect(t.notesEn.isNotEmpty, true);
      }
    });

    test('Laser bubble level calibration validates pitch, roll, and yaw angles within OEM tolerances', () {
      const level = AdasLaserLevel(
        pitchAngleDeg: 0.1,
        rollAngleDeg: -0.2,
        yawAngleDeg: 0.05,
      );
      expect(level.isAligned, true);

      const unlevel = AdasLaserLevel(
        pitchAngleDeg: 0.8,
        rollAngleDeg: -0.2,
        yawAngleDeg: 0.05,
      );
      expect(unlevel.isAligned, false);
    });

    test('Dynamic road calibration steps specify target vehicle speeds and instructions', () {
      final steps = DynamicRoadCalibrationStep.getDefaultSteps();
      expect(steps.length, greaterThanOrEqualTo(3));
      for (final s in steps) {
        expect(s.stepNumber, greaterThan(0));
        expect(s.titleEn.isNotEmpty, true);
        expect(s.instructionEn.isNotEmpty, true);
        expect(s.targetSpeedKmH, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Pillar 19: DPF / GPF & SCR AdBlue Exhaust Aftertreatment Regeneration Suite', () {
    test('DPF soot and ash status calculates load ratio and flags regen required vs blocked', () {
      final normal = DpfSootAshStatus.evaluate(sootGrams: 12.0, ashGrams: 10.0, diffPressure: 10.0);
      expect(normal.isRegenerationRequired, false);
      expect(normal.isRegenBlocked, false);

      final needsRegen = DpfSootAshStatus.evaluate(sootGrams: 30.0, ashGrams: 20.0, diffPressure: 32.0);
      expect(needsRegen.isRegenerationRequired, true);
      expect(needsRegen.isRegenBlocked, false);

      final blocked = DpfSootAshStatus.evaluate(sootGrams: 48.0, ashGrams: 30.0, diffPressure: 60.0);
      expect(blocked.isRegenBlocked, true);
    });

    test('Exhaust gas temperature sensor bank validates thermal range for catalytic burn', () {
      const egtSafe = EgtSensorBank(sensor1PreTurboC: 350.0, sensor2PreDpfC: 450.0, sensor3PostDpfC: 420.0);
      expect(egtSafe.isTempSafeForRegen, true);

      const egtCold = EgtSensorBank(sensor1PreTurboC: 150.0, sensor2PreDpfC: 160.0, sensor3PostDpfC: 140.0);
      expect(egtCold.isTempSafeForRegen, false);
    });

    test('Stationary forced regeneration defines 4 standard phases with RPM and temp targets', () {
      final phases = ForcedRegenerationPhase.getStandardPhases();
      expect(phases.length, 4);
      for (final p in phases) {
        expect(p.targetRpm, greaterThanOrEqualTo(800));
        expect(p.targetDpfTempC, greaterThanOrEqualTo(200));
        expect(p.durationSeconds, greaterThan(0));
      }
    });

    test('SCR AdBlue diagnostics validates DEF level, pump pressure, and NOx efficiency', () {
      final scr = ScrAdBlueStatus.generateDefault();
      expect(scr.tankLevelPercent, greaterThan(50.0));
      expect(scr.pumpPressureBar, inInclusiveRange(5.8, 6.5));
      expect(scr.defQualityConcentrationPercent, inInclusiveRange(30.0, 35.0));
      expect(scr.noxConversionEfficiencyPercent, greaterThan(85.0));
      expect(scr.isAdBlueSystemHealthy, true);
    });
  });

  group('Pillar 20: Zero Arabic Character Leakage in English Mode Across All New Modules', () {
    test('All English model getters and titles contain zero Arabic Unicode characters', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');

      // Used Car Audit
      final audit = PrePurchaseAuditScorecard.generateDefaultAudit();
      expect(arabicRegex.hasMatch(audit.gradeClassificationEn), false);
      expect(arabicRegex.hasMatch(audit.odometerAudit.verdictEn), false);
      expect(arabicRegex.hasMatch(audit.codeClearingAudit.riskRatingEn), false);
      expect(arabicRegex.hasMatch(audit.codeClearingAudit.explanationEn), false);

      // Lab Scope
      final chain = TimingChainSyncAnalysis.generate();
      expect(arabicRegex.hasMatch(chain.verdictEn), false);
      expect(arabicRegex.hasMatch(chain.enginePlatform), false);

      // Wiring Schematics
      final diagrams = SchematicDiagram.getAllDiagrams();
      for (final d in diagrams) {
        expect(arabicRegex.hasMatch(d.titleEn), false);
        for (final p in d.pinouts) {
          expect(arabicRegex.hasMatch(p.circuitNameEn), false);
          expect(arabicRegex.hasMatch(p.probeInstructionEn), false);
        }
      }

      // ADAS
      final targets = AdasTargetPlacement.getAllPresets();
      for (final t in targets) {
        expect(arabicRegex.hasMatch(t.systemName), false);
        expect(arabicRegex.hasMatch(t.notesEn), false);
      }
      final dynamicSteps = DynamicRoadCalibrationStep.getDefaultSteps();
      for (final s in dynamicSteps) {
        expect(arabicRegex.hasMatch(s.titleEn), false);
        expect(arabicRegex.hasMatch(s.instructionEn), false);
      }

      // DPF & SCR
      final dpf = DpfSootAshStatus.evaluate(sootGrams: 20.0, ashGrams: 15.0, diffPressure: 15.0);
      expect(arabicRegex.hasMatch(dpf.dpfHealthStatusEn), false);
      final phases = ForcedRegenerationPhase.getStandardPhases();
      for (final ph in phases) {
        expect(arabicRegex.hasMatch(ph.phaseNameEn), false);
      }

      // Used Car Audit 6-Report Suite
      final cleanScorecard = PrePurchaseAuditScorecard.generateDefaultAudit();
      expect(arabicRegex.hasMatch(cleanScorecard.gradeClassificationEn), false);
      expect(arabicRegex.hasMatch(cleanScorecard.odometerAudit.verdictEn), false);
      expect(arabicRegex.hasMatch(cleanScorecard.codeClearingAudit.riskRatingEn), false);
      expect(arabicRegex.hasMatch(cleanScorecard.codeClearingAudit.explanationEn), false);
      expect(arabicRegex.hasMatch(cleanScorecard.drivetrainHealth.healthSummaryEn), false);
      expect(arabicRegex.hasMatch(cleanScorecard.repairEstimates.financialVerdictEn), false);
      for (final item in cleanScorecard.repairEstimates.defectItems) {
        expect(arabicRegex.hasMatch(item.componentNameEn), false);
        expect(arabicRegex.hasMatch(item.descriptionEn), false);
      }

      // Universal Hardware Connectors
      final usb = UsbSerialObdConnection();
      expect(arabicRegex.hasMatch(usb.connectionType), false);
      for (final c in usb.supportedChipsets) {
        expect(arabicRegex.hasMatch(c), false);
      }
      final ble = BleObdConnection();
      expect(arabicRegex.hasMatch(ble.connectionType), false);

      // AppStrings (English UI constants)
      expect(arabicRegex.hasMatch(AppStrings.usedCarAudit), false);
      expect(arabicRegex.hasMatch(AppStrings.usedCarAuditSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.labScopeWaveform), false);
      expect(arabicRegex.hasMatch(AppStrings.labScopeWaveformSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.wiringSchematics), false);
      expect(arabicRegex.hasMatch(AppStrings.wiringSchematicsSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.adasCalibration), false);
      expect(arabicRegex.hasMatch(AppStrings.adasCalibrationSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.dpfRegeneration), false);
      expect(arabicRegex.hasMatch(AppStrings.dpfRegenerationSubtitle), false);
    });
  });

  group('Pillar 25: Technician Hands-Free Voice Assistant & Command NLP', () {
    final engine = VoiceAssistantEngine();

    test('parses scan DTCs command in English and Arabic', () {
      final resEn = engine.parseCommand("Scan trouble codes");
      expect(resEn.intent, VoiceCommandIntent.scanDtcs);
      expect(resEn.confidence > 0.9, true);
      expect(resEn.feedbackEn.contains("ECU"), true);

      final resAr = engine.parseCommand("اقرأ الأعطال");
      expect(resAr.intent, VoiceCommandIntent.scanDtcs);
      expect(resAr.feedbackAr.contains("الأعطال"), true);
    });

    test('parses clear DTCs, RPM, battery and used car audit commands', () {
      final resClear = engine.parseCommand("Clear trouble codes");
      expect(resClear.intent, VoiceCommandIntent.clearDtcs);

      final resRpm = engine.parseCommand("Read engine RPM");
      expect(resRpm.intent, VoiceCommandIntent.readRpm);

      final resBat = engine.parseCommand("Check battery voltage");
      expect(resBat.intent, VoiceCommandIntent.checkBattery);

      final resAudit = engine.parseCommand("Start used car audit");
      expect(resAudit.intent, VoiceCommandIntent.startUsedCarAudit);
    });

    test('handles unknown phrases gracefully', () {
      final resUnknown = engine.parseCommand("turn on radio");
      expect(resUnknown.intent, VoiceCommandIntent.unknown);
      expect(resUnknown.executed, false);
      expect(resUnknown.confidence < 0.5, true);
    });
  });

  group('Pillar 26: AR Engine Bay Component HUD & Multimeter Guide', () {
    test('contains 8 standard engine bay components with valid coordinates', () {
      final components = EngineComponentTag.standardEngineBay;
      expect(components.length, 8);
      for (final comp in components) {
        expect(comp.relativeX >= 0.0 && comp.relativeX <= 1.0, true);
        expect(comp.relativeY >= 0.0 && comp.relativeY <= 1.0, true);
        expect(comp.livePidCode.isNotEmpty, true);
        expect(comp.pinoutSummary.contains("Pin"), true);
      }
    });

    test('provides multimeter probe guidance and failure symptoms', () {
      final maf = EngineComponentTag.standardEngineBay.firstWhere((c) => c.id == "MAF_SENSOR");
      expect(maf.multimeterTestTipEn.contains("Backprobe"), true);
      expect(maf.failureSymptomEn.contains("P0101"), true);
      expect(maf.category, EngineComponentCategory.sensor);

      final sgw = EngineComponentTag.standardEngineBay.firstWhere((c) => c.id == "SGW_MODULE");
      expect(sgw.multimeterTestTipEn.contains("60 Ohms"), true);
      expect(sgw.category, EngineComponentCategory.module);
    });
  });

  group('Pillar 27: WhatsApp Customer Care & Dispatch Hub', () {
    test('generates localized messages for all 5 repair stages', () {
      final order = CustomerWorkOrder.sampleOrders.first;
      for (final stage in DispatchStage.values) {
        final msgEn = order.generateWhatsappMessage(stage, false);
        expect(msgEn.contains(order.customerName), true);
        expect(msgEn.contains(order.vehicleModel), true);

        final msgAr = order.generateWhatsappMessage(stage, true);
        expect(msgAr.contains(order.customerName), true);
      }
    });

    test('formats international WhatsApp deep links correctly', () {
      final order = CustomerWorkOrder.sampleOrders.first;
      final uri = order.getWhatsappUrl(DispatchStage.checkIn, false);
      expect(uri.scheme, "https");
      expect(uri.host, "wa.me");
      expect(uri.toString().contains("201001234567"), true);
    });
  });

  group('Pillar 28: Raw OBD-II CAN Bus Protocol Packet Sniffer', () {
    test('parses ELM327 CAN monitor stream into structured frames', () {
      final frame = RawCanFrame.parseElmLine("7E8 04 41 0C 1A F8 00 00", 1200);
      expect(frame.arbitrationId, 0x7E8);
      expect(frame.hexId, "0x7E8");
      expect(frame.ecuName, "Engine ECM");
      expect(frame.decodedInterpretation.contains("RPM"), true);
    });

    test('CanSnifferFilter matches frames by arbitration ID, ECU, and hex', () {
      final frame = RawCanFrame.sampleLiveCanStream.first;
      final filterId = CanSnifferFilter(targetArbitrationId: 0x7E8);
      expect(filterId.matches(frame), true);

      final filterMismatch = CanSnifferFilter(targetArbitrationId: 0x7E9);
      expect(filterMismatch.matches(frame), false);

      final filterHex = CanSnifferFilter(hexSearch: "0C 0B");
      expect(filterHex.matches(frame), true);
    });
  });

  group('Pillar 29: Offline Diagnostic Vault Management', () {
    test('verifies 100% offline diagnostic readiness and cached packages', () async {
      final vault = OfflineVaultService();
      final status = await vault.checkVaultStatus();
      expect(status.isFullyOfflineReady, true);
      expect(status.packages.length, 5);
      expect(status.totalCachedMb > 25.0, true);
      expect(status.totalCachedEntries > 500, true);

      final verified = await vault.verifyAndSyncVault();
      expect(verified, true);
    });
  });

  group('Pillar 30: Zero Arabic Character Leakage in English Mode (UX Powerhouse)', () {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');

    test('all English getters and constants contain zero Arabic characters', () {
      // Voice Assistant
      for (final p in VoiceCommandCatalog.phrases) {
        expect(arabicRegex.hasMatch(p.englishPhrase), false);
        expect(arabicRegex.hasMatch(p.category), false);
      }
      final engine = VoiceAssistantEngine();
      final res = engine.parseCommand("Scan trouble codes");
      expect(arabicRegex.hasMatch(res.feedbackEn), false);

      // AR Components
      for (final comp in EngineComponentTag.standardEngineBay) {
        expect(arabicRegex.hasMatch(comp.nameEn), false);
        expect(arabicRegex.hasMatch(comp.nominalReadingEn), false);
        expect(arabicRegex.hasMatch(comp.multimeterTestTipEn), false);
        expect(arabicRegex.hasMatch(comp.failureSymptomEn), false);
        expect(arabicRegex.hasMatch(comp.pinoutSummary), false);
      }

      // Customer Dispatch Hub
      final order = CustomerWorkOrder.sampleOrders.first;
      for (final stage in DispatchStage.values) {
        expect(arabicRegex.hasMatch(order.stageTitle(false)), false);
        expect(arabicRegex.hasMatch(order.generateWhatsappMessage(stage, false)), false);
      }

      // Offline Vault
      for (final pkg in OfflineVaultService.standardPackages) {
        expect(arabicRegex.hasMatch(pkg.titleEn), false);
      }

      // AppStrings constants
      expect(arabicRegex.hasMatch(AppStrings.voiceAssistant), false);
      expect(arabicRegex.hasMatch(AppStrings.voiceAssistantSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.arEngineBay), false);
      expect(arabicRegex.hasMatch(AppStrings.arEngineBaySubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.customerDispatch), false);
      expect(arabicRegex.hasMatch(AppStrings.customerDispatchSubtitle), false);
      expect(arabicRegex.hasMatch(AppStrings.offlineVault), false);
      expect(arabicRegex.hasMatch(AppStrings.offlineVaultSubtitle), false);
    });
  });

  group('Pillar 31: Used Car Audit Save Report & Clean Hardware Test Lifecycle', () {
    test('ObdState.saveUsedCarAuditReport should persist scorecard into workshop report repo', () async {
      final state = ObdState();
      final scorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false);

      final report = await state.saveUsedCarAuditReport(
        scorecard,
        customerName: "Ahmed Mostafa",
        customerPhone: "01012345678",
        plateNumber: "CAI 7890",
        notes: "Certified inspection completed without fault.",
      );

      expect(report.id.startsWith("AUDIT-"), true);
      expect(report.customerName, "Ahmed Mostafa");
      expect(report.customerPhone, "01012345678");
      expect(report.plateNumber, "CAI 7890");
      expect(report.liveSensorsSnapshot.containsKey("Audit Health Index"), true);
      expect(report.liveSensorsSnapshot["Odometer Tampered"], "NO");
      expect(report.liveSensorsSnapshot["Verification Hash"], scorecard.verificationHash);

      // Verify persistence in report repo
      final allReports = await state.reportRepo.getAllReports();
      expect(allReports.any((r) => r.id == report.id), true);
    });

    test('Scorecard should initialize empty/null in screen workflow and evaluate real vehicle data', () {
      final liveScorecard = PrePurchaseAuditScorecard.fromLiveVehicle(
        liveVin: "1HGCR2F83HA029418",
        liveClusterKm: 95400,
        liveEcmKm: 95420,
        distanceSinceClearedKm: 4200,
        warmUpsSinceCleared: 85,
        engineRunTimeMinutes: 3500,
        storedDtcCount: 0,
        stft: 1.2,
        ltft: -0.8,
        o2Voltage: 0.68,
      );

      expect(liveScorecard.overallScore, greaterThanOrEqualTo(85));
      expect(liveScorecard.odometerAudit.isRollbackSuspected, false);
      expect(liveScorecard.codeClearingAudit.isRecentlyCleared, false);
      expect(liveScorecard.vinAudit.isVinMatched, true);
    });
  });

  group('Pillar 32: Eye-Comfort Light Theme & Forensic Audit Additions', () {
    test('BodyPaintThicknessAudit evaluates OEM paint tolerance vs bondo and structural damage', () {
      const cleanPaint = BodyPaintThicknessAudit.defaultClean();
      expect(cleanPaint.hasBondoDetected, false);
      expect(cleanPaint.hasStructuralDamageSuspected, false);
      expect(cleanPaint.panelMicrons['Hood'], 112);
      expect(cleanPaint.panelMicrons['A-Pillars'], 95);
      expect(cleanPaint.verdictEn.contains("80-140 um"), true);

      final tamperedPaint = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true).paintAudit;
      expect(tamperedPaint.hasBondoDetected, true);
      expect(tamperedPaint.hasStructuralDamageSuspected, true);
      expect(tamperedPaint.panelMicrons['Front Left Fender'], 380);
      expect(tamperedPaint.panelMicrons['A-Pillars'], 240);
      expect(tamperedPaint.verdictEn.contains("BODY FRAUD ALERT"), true);
    });

    test('FloodImmersionAudit evaluates CAN termination resistance and moisture risk', () {
      const cleanFlood = FloodImmersionAudit.defaultClean();
      expect(cleanFlood.floodRiskPercent, 0);
      expect(cleanFlood.canBusTerminationOhms, closeTo(60.2, 0.5));
      expect(cleanFlood.hasMoistureFaultDetected, false);

      final tamperedFlood = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true).floodAudit;
      expect(tamperedFlood.floodRiskPercent, 85);
      expect(tamperedFlood.canBusTerminationOhms, greaterThan(70.0));
      expect(tamperedFlood.hasMoistureFaultDetected, true);
    });

    test('BatteryCrankingHealthAudit evaluates starter engagement dip and charging output', () {
      const cleanBattery = BatteryCrankingHealthAudit.defaultClean();
      expect(cleanBattery.isWeakBattery, false);
      expect(cleanBattery.crankingDipVoltage, greaterThan(9.6));
      expect(cleanBattery.chargingAlternatorVoltage, closeTo(14.2, 0.2));

      final weakBattery = BatteryCrankingHealthAudit.fromLiveTelemetry(11.2);
      expect(weakBattery.isWeakBattery, true);
      expect(weakBattery.crankingDipVoltage, lessThan(9.6));
      expect(weakBattery.verdictEn.contains("WEAK 12V BATTERY"), true);
    });

    test('WorkshopTheme.sunlightTheme and AppColors provide ergonomic light theme tokens', () {
      final theme = WorkshopTheme.sunlightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(theme.colorScheme.surface, AppColors.lightCardSurface);
      expect(theme.colorScheme.onSurface, AppColors.lightTextPrimary);
      expect(theme.cardTheme.color, Colors.white);
      expect(theme.cardTheme.shape is RoundedRectangleBorder, true);

      // Verify semantic helpers
      expect(AppColors.getBackground(true), AppColors.lightBackground);
      expect(AppColors.getBackground(false), AppColors.darkBackground);
      expect(AppColors.getCardSurface(true), Colors.white);
      expect(AppColors.getCardSurface(false), AppColors.cardSurface);
      expect(AppColors.getTextPrimary(true), AppColors.lightTextPrimary);
      expect(AppColors.getTextPrimary(false), AppColors.textWhite);
      expect(AppColors.getTextSecondary(true), AppColors.lightTextSecondary);
    });

    test('Zero Arabic character leakage in Pillar 32 English getters and models', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');

      const cleanPaint = BodyPaintThicknessAudit.defaultClean();
      expect(arabicRegex.hasMatch(cleanPaint.verdictEn), false);

      const cleanFlood = FloodImmersionAudit.defaultClean();
      expect(arabicRegex.hasMatch(cleanFlood.verdictEn), false);

      const cleanBattery = BatteryCrankingHealthAudit.defaultClean();
      expect(arabicRegex.hasMatch(cleanBattery.verdictEn), false);

      final tamperedScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true);
      expect(arabicRegex.hasMatch(tamperedScorecard.paintAudit.verdictEn), false);
      expect(arabicRegex.hasMatch(tamperedScorecard.floodAudit.verdictEn), false);
      expect(arabicRegex.hasMatch(tamperedScorecard.batteryCrankingAudit.verdictEn), false);
    });
  });

  group('Pillar 33: Manual Workshop Physical Checklist, Title Audit & Full PDF Reports', () {
    test('ManualInspectionReport initializes with 6 mechanical categories and 26 non-electrical checkpoints', () {
      final checklist = ManualInspectionReport.defaultWorkshopChecklist();
      expect(checklist.categories.length, 6);
      expect(checklist.totalItems, 26);
      expect(checklist.passedCount, 26);
      expect(checklist.failedCount, 0);
      expect(checklist.leakingCount, 0);
      expect(checklist.marginalCount, 0);
      expect(checklist.manualScore, 100);

      final catIds = checklist.categories.map((c) => c.id).toList();
      expect(catIds, containsAll(['suspension', 'steering', 'oil_leaks', 'tires_brakes', 'exterior_body', 'interior_cabin']));
    });

    test('ManualInspectionReport dynamic scoring correctly weights failures, leaks, and marginal items', () {
      final original = ManualInspectionReport.defaultWorkshopChecklist();
      expect(original.manualScore, 100);

      // Mutate 1 item to fail (drops 6 pts), 1 item to leaking (drops 7 pts), 1 item to marginal (drops 2 pts)
      final modifiedCategories = original.categories.map((cat) {
        if (cat.id == 'suspension') {
          final items = cat.items.map((i) {
            if (i.id == 'sus_front_shocks') return i.copyWith(status: ManualCheckItemStatus.fail);
            return i;
          }).toList();
          return cat.copyWith(items: items);
        } else if (cat.id == 'oil_leaks') {
          final items = cat.items.map((i) {
            if (i.id == 'leak_rear_main') return i.copyWith(status: ManualCheckItemStatus.leaking);
            return i;
          }).toList();
          return cat.copyWith(items: items);
        } else if (cat.id == 'tires_brakes') {
          final items = cat.items.map((i) {
            if (i.id == 'tire_tread') return i.copyWith(status: ManualCheckItemStatus.marginal);
            return i;
          }).toList();
          return cat.copyWith(items: items);
        }
        return cat;
      }).toList();

      final mutatedReport = ManualInspectionReport(categories: modifiedCategories);
      expect(mutatedReport.failedCount, 1);
      expect(mutatedReport.leakingCount, 1);
      expect(mutatedReport.marginalCount, 1);
      expect(mutatedReport.passedCount, 23);
      // 100 - (1*6) - (1*7) - (1*2) = 85
      expect(mutatedReport.manualScore, 85);
    });

    test('TitleSalvageCheckAudit correctly validates clean title and identifies bank liens / salvage total loss', () {
      const cleanTitle = TitleSalvageCheckAudit.defaultClean();
      expect(cleanTitle.isCleanTitle, true);
      expect(cleanTitle.isBankLienActive, false);
      expect(cleanTitle.isSalvageTotalLoss, false);
      expect(cleanTitle.reportedAuctionCount, 0);
      expect(cleanTitle.verdictEn.contains("CLEAN TITLE"), true);

      final tamperedScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true);
      final tamperedTitle = tamperedScorecard.titleAudit;
      expect(tamperedTitle.isCleanTitle, false);
      expect(tamperedTitle.isBankLienActive, true);
      expect(tamperedTitle.isSalvageTotalLoss, true);
      expect(tamperedTitle.reportedAuctionCount, 2);
      expect(tamperedTitle.verdictEn.contains("CRITICAL TITLE ALERT"), true);
    });

    test('Zero Arabic character leakage across all 24 manual checklist items, categories and title audit', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      final checklist = ManualInspectionReport.defaultWorkshopChecklist();

      for (final cat in checklist.categories) {
        expect(arabicRegex.hasMatch(cat.titleEn), false, reason: "Category ${cat.id} titleEn contains Arabic");
        for (final item in cat.items) {
          expect(arabicRegex.hasMatch(item.titleEn), false, reason: "Item ${item.id} titleEn contains Arabic");
        }
      }

      const cleanTitle = TitleSalvageCheckAudit.defaultClean();
      expect(arabicRegex.hasMatch(cleanTitle.verdictEn), false);

      final tamperedScorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: true);
      expect(arabicRegex.hasMatch(tamperedScorecard.titleAudit.verdictEn), false);
    });

    test('UsedCarPdfReportService generates full 8-section PDF report bytes', () async {
      final scorecard = PrePurchaseAuditScorecard.generateDefaultAudit(simulateTampering: false);
      final pdfBytes = await UsedCarPdfReportService.generatePdfReport(
        scorecard: scorecard,
        vehicleName: 'Toyota Corolla 2023',
        isArabic: false,
      );

      expect(pdfBytes.isNotEmpty, true);
      expect(pdfBytes.length, greaterThan(2000));
    });
  });

  group('Pillar 34: Production Workshop Power Tools, Zero-Mock Telemetry & Live OBD Data Binding', () {
    test('TimingChainSyncAnalysis.fromLiveTelemetry evaluates phase offset from RPM and advance', () {
      final idleSync = TimingChainSyncAnalysis.fromLiveTelemetry(rpm: 750.0, timingAdvanceDeg: 12.0);
      expect(idleSync.phaseOffsetDegrees, closeTo(1.8, 0.5));
      expect(idleSync.isChainStretchDetected, false);
      expect(idleSync.ratingEn.contains("NOMINAL"), true);

      final stretchedSync = TimingChainSyncAnalysis.fromLiveTelemetry(rpm: 3200.0, timingAdvanceDeg: 28.0);
      expect(stretchedSync.phaseOffsetDegrees, greaterThan(5.0));
      expect(stretchedSync.isChainStretchDetected, true);
      expect(stretchedSync.ratingEn.contains("STRETCH"), true);
    });

    test('IgnitionWaveformAnalysis.fromLiveTelemetry calculates KV and dwell from voltage and RPM', () {
      final idleIgnition = IgnitionWaveformAnalysis.fromLiveTelemetry(batteryVoltage: 14.1, rpm: 800.0);
      expect(idleIgnition.peakKv, greaterThan(8.0));
      expect(idleIgnition.burnTimeMs, greaterThan(1.0));
      expect(idleIgnition.dwellTimeMs, greaterThan(2.0));
      expect(idleIgnition.isMisfireSuspected, false);

      final saggedIgnition = IgnitionWaveformAnalysis.fromLiveTelemetry(batteryVoltage: 10.5, rpm: 600.0);
      expect(saggedIgnition.isMisfireSuspected, true);
    });

    test('InjectorWaveformAnalysis.fromLiveTelemetry calculates pulse width and flyback voltage', () {
      final idleInjector = InjectorWaveformAnalysis.fromLiveTelemetry(engineLoadPercent: 18.0, batteryVoltage: 13.8);
      expect(idleInjector.pulseWidthMs, closeTo(2.1, 0.4));
      expect(idleInjector.flybackVoltage, greaterThan(60.0));
      expect(idleInjector.isShortCircuitSuspected, false);

      final heavyLoadInjector = InjectorWaveformAnalysis.fromLiveTelemetry(engineLoadPercent: 88.0, batteryVoltage: 13.8);
      expect(heavyLoadInjector.pulseWidthMs, greaterThan(7.0));
    });

    test('ExhaustAftertreatmentBundle.fromLiveTelemetry calculates soot load and exhaust temps', () {
      final coldBundle = ExhaustAftertreatmentBundle.fromLiveTelemetry(coolantTempC: 30.0, rpm: 0.0);
      expect(coldBundle.sootMassGrams, greaterThan(0.0));
      expect(coldBundle.isRegenRecommended, false);

      final hotHighwayBundle = ExhaustAftertreatmentBundle.fromLiveTelemetry(
        coolantTempC: 88.0,
        rpm: 2400.0,
        diffPressureKpa: 14.0,
        egtPreCatC: 450.0,
      );
      expect(hotHighwayBundle.dpfFilter.isRegenRecommended, true);
      expect(hotHighwayBundle.sensorBank.egtPreCatCelsius, 450.0);
    });

    test('EvBatteryPackSummary.fromLiveTelemetry & empty states initialize correctly', () {
      final emptyPack = EvBatteryPackSummary.empty();
      expect(emptyPack.cells.isEmpty, true);
      expect(emptyPack.thermalZones.isEmpty, true);
      expect(emptyPack.totalVoltage, 0.0);
      expect(emptyPack.safetyStatus.hvilLoopClosed, false);

      // Per-cell EV data is not available over standard OBD-II: never generated.
      final livePack = EvBatteryPackSummary.fromLiveTelemetry(
        batteryVoltage: 14.2,
        isConnected: true,
        coolantTemp: 32.0,
      );
      expect(livePack.cells.isEmpty, true);
      expect(livePack.totalVoltage, 0.0);
    });

    test('Zero Arabic character leakage in Pillar 34 models and English outputs', () {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');

      final sync = TimingChainSyncAnalysis.fromLiveTelemetry(rpm: 800.0, timingAdvanceDeg: 10.0);
      expect(arabicRegex.hasMatch(sync.ratingEn), false);

      final ignition = IgnitionWaveformAnalysis.fromLiveTelemetry(batteryVoltage: 14.0, rpm: 800.0);
      expect(arabicRegex.hasMatch(ignition.healthRatingEn), false);

      final injector = InjectorWaveformAnalysis.fromLiveTelemetry(engineLoadPercent: 20.0, batteryVoltage: 14.0);
      expect(arabicRegex.hasMatch(injector.ratingEn), false);

      final pack = EvBatteryPackSummary.fromLiveTelemetry(batteryVoltage: 14.0, isConnected: true);
      expect(arabicRegex.hasMatch(pack.balanceRatingEn), false);
      for (final t in pack.thermalZones) {
        expect(arabicRegex.hasMatch(t.locationNameEn), false);
      }
    });
  });
}
