import 'dart:async';
import '../datasources/elm327_driver.dart';
import '../models/dtc_model.dart';
import '../models/sensor_pid.dart';
import '../models/freeze_frame.dart';
import '../models/readiness_monitors.dart';
import '../../core/constants/obd_commands.dart';
import '../../core/utils/hex_parser.dart';
import 'dtc_repository.dart';

/// Genuine odometer and distance telemetry result
class GenuineOdometerReading {
  final int totalOdometerKm;
  final int distanceSinceDtcClearedKm;
  final int distanceWithMilKm;
  final bool isClusterOdometerAvailable;
  final String source;

  const GenuineOdometerReading({
    required this.totalOdometerKm,
    required this.distanceSinceDtcClearedKm,
    required this.distanceWithMilKm,
    required this.isClusterOdometerAvailable,
    required this.source,
  });
}

/// Primary OBD repository for diagnostics, DTC scanning, and fast live data polling
class ObdRepository {
  final Elm327Driver driver;
  bool _isPolling = false;
  final Set<String> _unsupportedPids = {};
  final Map<String, int> _consecutiveFailures = {};

  ObdRepository({required this.driver});

  bool get isPolling => _isPolling;

  /// Clear unsupported PIDs cache
  void resetUnsupportedPids() {
    _unsupportedPids.clear();
    _consecutiveFailures.clear();
  }

  /// Scan all types of diagnostic trouble codes (Stored, Pending, Permanent)
  Future<Map<String, List<DtcModel>>> scanAllDtcs(DtcRepository dtcRepo) async {
    final Map<String, List<DtcModel>> results = {
      'stored': [],
      'pending': [],
      'permanent': [],
    };

    try {
      // 1. Confirmed Stored DTCs (Mode 03)
      final storedRaw = await driver.executeCommand(ObdCommands.modeStoredDtcs);
      final storedBytes = HexParser.extractBytes(storedRaw);
      final storedCodes = HexParser.parseDtcs(storedBytes, 0x03);
      results['stored'] = await dtcRepo.resolveDtcs(storedCodes, dtcType: "Stored");

      // 2. Pending DTCs (Mode 07)
      final pendingRaw = await driver.executeCommand(ObdCommands.modePendingDtcs);
      final pendingBytes = HexParser.extractBytes(pendingRaw);
      final pendingCodes = HexParser.parseDtcs(pendingBytes, 0x07);
      results['pending'] = await dtcRepo.resolveDtcs(pendingCodes, dtcType: "Pending");

      // 3. Permanent DTCs (Mode 0A)
      final permRaw = await driver.executeCommand(ObdCommands.modePermanentDtcs);
      final permBytes = HexParser.extractBytes(permRaw);
      final permCodes = HexParser.parseDtcs(permBytes, 0x0A);
      results['permanent'] = await dtcRepo.resolveDtcs(permCodes, dtcType: "Permanent");
    } catch (_) {}

    return results;
  }

  /// Clear diagnostic trouble codes and reset Check Engine light (Mode 04)
  Future<bool> clearDiagnosticCodes() async {
    try {
      final resp = await driver.executeCommand(ObdCommands.modeClearDtcs, timeout: const Duration(seconds: 5));
      final bytes = HexParser.extractBytes(resp);

      if (resp.contains("44") || resp.contains("OK") || (bytes.isNotEmpty && bytes[0] == 0x44)) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Read core vehicle data (VIN, MIL status, DTC count, battery voltage)
  Future<Map<String, dynamic>> readQuickScanData() async {
    final Map<String, dynamic> data = {
      'vin': 'N/A',
      'mil_on': false,
      'dtc_count': 0,
      'voltage': driver.lastBatteryVoltage,
      'protocol': driver.activeProtocol,
    };

    try {
      // Read VIN (Mode 09 PID 02)
      final vinRaw = await driver.executeCommand("0902", timeout: const Duration(seconds: 4));
      final vinBytes = HexParser.extractBytes(vinRaw);
      final vin = HexParser.parseVin(vinBytes);
      if (vin.isNotEmpty) {
        data['vin'] = vin;
      }

      // Read MIL and readiness status (Mode 01 PID 01)
      final milRaw = await driver.executeCommand("0101", timeout: const Duration(seconds: 2));
      final milBytes = HexParser.extractBytes(milRaw);
      if (milBytes.length >= 3 && milBytes[0] == 0x41 && milBytes[1] == 0x01) {
        final byteA = milBytes[2];
        final isMilOn = (byteA & 0x80) != 0;
        final dtcCount = byteA & 0x7F;
        data['mil_on'] = isMilOn;
        data['dtc_count'] = dtcCount;
      }

      // Refresh voltage
      final v = await driver.refreshBatteryVoltage();
      data['voltage'] = v;
      data['protocol'] = driver.activeProtocol;
    } catch (_) {}

    return data;
  }

  /// Read single sensor value with dynamic unsupported PID skip and fast NRC / error abort
  Future<bool> readSingleSensor(SensorPid sensor) async {
    final key = "${sensor.mode}${sensor.pid}";
    if (_unsupportedPids.contains(key)) return false;

    try {
      final raw = await driver.executeCommand(key, timeout: const Duration(milliseconds: 700));
      if (raw == "TIMEOUT" || HexParser.isErrorResponse(raw) || raw.contains("7F") || raw.contains("?")) {
        final fails = (_consecutiveFailures[key] ?? 0) + 1;
        _consecutiveFailures[key] = fails;
        if (fails >= 2 || raw.toUpperCase().contains("NO DATA") || raw.contains("?") || raw.contains("7F")) {
          _unsupportedPids.add(key);
        }
        return false;
      }
      _consecutiveFailures[key] = 0;

      final bytes = HexParser.extractBytes(raw);
      final modeInt = int.tryParse(sensor.mode, radix: 16) ?? 1;
      final pidInt = int.tryParse(sensor.pid, radix: 16) ?? 0;

      final payload = HexParser.extractPayload(bytes, modeInt, pidInt);
      if (payload.isNotEmpty) {
        sensor.decodeAndUpdate(payload);
        return true;
      }
      return false;
    } catch (_) {
      final fails = (_consecutiveFailures[key] ?? 0) + 1;
      _consecutiveFailures[key] = fails;
      if (fails >= 2) {
        _unsupportedPids.add(key);
      }
      return false;
    }
  }

  /// High-speed live polling loop skipping unsupported sensors
  Future<void> startPolling(List<SensorPid> sensors, Function(SensorPid) onUpdate) async {
    _isPolling = true;

    while (_isPolling && driver.connection.isConnected) {
      for (var sensor in sensors) {
        if (!_isPolling) break;
        if (!sensor.isSelected) continue;

        final key = "${sensor.mode}${sensor.pid}";
        if (_unsupportedPids.contains(key)) continue;

        final updated = await readSingleSensor(sensor);
        if (updated) {
          onUpdate(sensor);
        }

        // Inter-command pause for ELM UART buffer stability
        await Future.delayed(const Duration(milliseconds: 10));
      }
      await Future.delayed(const Duration(milliseconds: 15));
    }
  }

  /// Stop polling
  void stopPolling() {
    _isPolling = false;
  }

  /// Read genuine vehicle odometer & distance telemetry across Mode 01 PID A6, UDS cluster DIDs, and Mode 01 PID 31
  Future<GenuineOdometerReading> readGenuineOdometer() async {
    int totalOdoKm = 0;
    int distClearedKm = 0;
    int distMilKm = 0;
    bool isClusterFound = false;
    String odoSource = "Standard OBD-II";

    // 1. Read Distance Traveled Since Codes Cleared (Mode 01 PID 31)
    try {
      final resp = await driver.executeCommand("0131", timeout: const Duration(seconds: 2));
      final bytes = HexParser.extractBytes(resp);
      if (bytes.length >= 4 && bytes[0] == 0x41 && bytes[1] == 0x31) {
        distClearedKm = (bytes[2] << 8) | bytes[3];
      }
    } catch (_) {}

    // 2. Read Distance Traveled With Malfunction Indicator Lamp On (Mode 01 PID 21)
    try {
      final resp = await driver.executeCommand("0121", timeout: const Duration(seconds: 2));
      final bytes = HexParser.extractBytes(resp);
      if (bytes.length >= 4 && bytes[0] == 0x41 && bytes[1] == 0x21) {
        distMilKm = (bytes[2] << 8) | bytes[3];
      }
    } catch (_) {}

    // 3. Primary: Try SAE J1979-2 Mode 01 PID A6 (Odometer - 4 bytes, 0.1 km resolution)
    try {
      final resp = await driver.executeCommand("01A6", timeout: const Duration(seconds: 2));
      final bytes = HexParser.extractBytes(resp);
      final payload = HexParser.extractPayload(bytes, 0x01, 0xA6);
      if (payload.length >= 4) {
        final rawOdo = ((payload[0] << 24) | (payload[1] << 16) | (payload[2] << 8) | payload[3]);
        final km = (rawOdo / 10.0).round();
        if (km > 0 && km < 2000000) {
          totalOdoKm = km;
          isClusterFound = true;
          odoSource = "SAE J1979-2 Mode 01 PID A6 (ECU)";
        }
      }
    } catch (_) {}

    // 4. Secondary: If PID A6 is unsupported on older ECU, query UDS Cluster DIDs
    if (!isClusterFound) {
      // Try UDS DID 0x0200 (Common on GM, Ford, PSA, Hyundai)
      try {
        final resp = await driver.executeCommand("220200", timeout: const Duration(milliseconds: 1200));
        final bytes = HexParser.extractBytes(resp);
        if (bytes.length >= 6 && bytes[0] == 0x62 && bytes[1] == 0x02 && bytes[2] == 0x00) {
          final int rawVal = (bytes.length >= 7)
              ? ((bytes[3] << 24) | (bytes[4] << 16) | (bytes[5] << 8) | bytes[6])
              : ((bytes[3] << 16) | (bytes[4] << 8) | bytes[5]);
          final km = (rawVal > 10000000) ? (rawVal / 10.0).round() : rawVal;
          if (km > 0 && km < 2000000) {
            totalOdoKm = km;
            isClusterFound = true;
            odoSource = "UDS Cluster DID 0x0200";
          }
        }
      } catch (_) {}
    }

    if (!isClusterFound) {
      // Try UDS DID 0xF1A0 (Standard VAG / BMW Total Distance)
      try {
        final resp = await driver.executeCommand("22F1A0", timeout: const Duration(milliseconds: 1200));
        final bytes = HexParser.extractBytes(resp);
        if (bytes.length >= 6 && bytes[0] == 0x62 && bytes[1] == 0xF1 && bytes[2] == 0xA0) {
          final int rawVal = (bytes.length >= 7)
              ? ((bytes[3] << 24) | (bytes[4] << 16) | (bytes[5] << 8) | bytes[6])
              : ((bytes[3] << 16) | (bytes[4] << 8) | bytes[5]);
          final km = (rawVal > 10000000) ? (rawVal / 10.0).round() : rawVal;
          if (km > 0 && km < 2000000) {
            totalOdoKm = km;
            isClusterFound = true;
            odoSource = "UDS Cluster DID 0xF1A0";
          }
        }
      } catch (_) {}
    }

    if (!isClusterFound) {
      // Try UDS DID 0x0204 (Toyota / Nissan cluster odometer)
      try {
        final resp = await driver.executeCommand("220204", timeout: const Duration(milliseconds: 1200));
        final bytes = HexParser.extractBytes(resp);
        if (bytes.length >= 6 && bytes[0] == 0x62 && bytes[1] == 0x02 && bytes[2] == 0x04) {
          final int rawVal = (bytes.length >= 7)
              ? ((bytes[3] << 24) | (bytes[4] << 16) | (bytes[5] << 8) | bytes[6])
              : ((bytes[3] << 16) | (bytes[4] << 8) | bytes[5]);
          final km = (rawVal > 10000000) ? (rawVal / 10.0).round() : rawVal;
          if (km > 0 && km < 2000000) {
            totalOdoKm = km;
            isClusterFound = true;
            odoSource = "UDS Cluster DID 0x0204";
          }
        }
      } catch (_) {}
    }

    if (!isClusterFound && distClearedKm > 0) {
      totalOdoKm = distClearedKm;
      odoSource = "Standard OBD-II (Mode 01 PID 31)";
    }

    return GenuineOdometerReading(
      totalOdometerKm: totalOdoKm,
      distanceSinceDtcClearedKm: distClearedKm,
      distanceWithMilKm: distMilKm,
      isClusterOdometerAvailable: isClusterFound,
      source: odoSource,
    );
  }

  /// Read freeze frame snapshot (Mode 02)
  Future<FreezeFrameModel> readFreezeFrame() async {
    try {
      // 1. DTC that triggered freeze frame (PID 02)
      final dtcRaw = await driver.executeCommand("0202");
      final dtcBytes = HexParser.extractBytes(dtcRaw);
      String dtcCode = "None Recorded";
      if (dtcBytes.length >= 4 && dtcBytes[0] == 0x42 && dtcBytes[1] == 0x02) {
        dtcCode = HexParser.decodeSingleDtc(dtcBytes[2], dtcBytes[3]);
      }

      // 2. RPM (PID 0C)
      final rpmRaw = await driver.executeCommand("020C");
      final rpmBytes = HexParser.extractBytes(rpmRaw);
      double rpm = 0;
      if (rpmBytes.length >= 4 && rpmBytes[0] == 0x42 && rpmBytes[1] == 0x0C) {
        rpm = ((rpmBytes[2] * 256) + rpmBytes[3]) / 4.0;
      }

      // 3. Vehicle Speed (PID 0D)
      final speedRaw = await driver.executeCommand("020D");
      final speedBytes = HexParser.extractBytes(speedRaw);
      double speed = 0;
      if (speedBytes.length >= 3 && speedBytes[0] == 0x42 && speedBytes[1] == 0x0D) {
        speed = speedBytes[2].toDouble();
      }

      // 4. Coolant Temperature (PID 05)
      final tempRaw = await driver.executeCommand("0205");
      final tempBytes = HexParser.extractBytes(tempRaw);
      double temp = 0;
      if (tempBytes.length >= 3 && tempBytes[0] == 0x42 && tempBytes[1] == 0x05) {
        temp = (tempBytes[2] - 40).toDouble();
      }

      // 5. Engine Load (PID 04)
      final loadRaw = await driver.executeCommand("0204");
      final loadBytes = HexParser.extractBytes(loadRaw);
      double load = 0;
      if (loadBytes.length >= 3 && loadBytes[0] == 0x42 && loadBytes[1] == 0x04) {
        load = (loadBytes[2] * 100.0) / 255.0;
      }

      // 6. Throttle Position (PID 11)
      final tpsRaw = await driver.executeCommand("0211");
      final tpsBytes = HexParser.extractBytes(tpsRaw);
      double tps = 0;
      if (tpsBytes.length >= 3 && tpsBytes[0] == 0x42 && tpsBytes[1] == 0x11) {
        tps = (tpsBytes[2] * 100.0) / 255.0;
      }

      // 7. Intake Air Temp (PID 0F)
      final iatRaw = await driver.executeCommand("020F");
      final iatBytes = HexParser.extractBytes(iatRaw);
      double iat = 0;
      if (iatBytes.length >= 3 && iatBytes[0] == 0x42 && iatBytes[1] == 0x0F) {
        iat = (iatBytes[2] - 40).toDouble();
      }

      // 8. Manifold Pressure (PID 0B)
      final mapRaw = await driver.executeCommand("020B");
      final mapBytes = HexParser.extractBytes(mapRaw);
      double map = 0;
      if (mapBytes.length >= 3 && mapBytes[0] == 0x42 && mapBytes[1] == 0x0B) {
        map = mapBytes[2].toDouble();
      }

      // 9. STFT (PID 06)
      final stftRaw = await driver.executeCommand("0206");
      final stftBytes = HexParser.extractBytes(stftRaw);
      double stft = 0;
      if (stftBytes.length >= 3 && stftBytes[0] == 0x42 && stftBytes[1] == 0x06) {
        stft = ((stftBytes[2] - 128.0) * 100.0) / 128.0;
      }

      // 10. LTFT (PID 07)
      final ltftRaw = await driver.executeCommand("0207");
      final ltftBytes = HexParser.extractBytes(ltftRaw);
      double ltft = 0;
      if (ltftBytes.length >= 3 && ltftBytes[0] == 0x42 && ltftBytes[1] == 0x07) {
        ltft = ((ltftBytes[2] - 128.0) * 100.0) / 128.0;
      }

      return FreezeFrameModel(
        dtcCode: dtcCode,
        engineRpm: rpm,
        vehicleSpeed: speed,
        coolantTemp: temp,
        engineLoad: load,
        throttlePosition: tps,
        intakeAirTemp: iat,
        manifoldPressure: map,
        shortTermFuelTrim: stft,
        longTermFuelTrim: ltft,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return FreezeFrameModel.empty();
    }
  }

  /// Read emissions readiness monitors (Mode 01 PID 01)
  Future<ReadinessMonitors> readReadinessMonitors() async {
    try {
      final raw = await driver.executeCommand("0101");
      final bytes = HexParser.extractBytes(raw);
      if (bytes.length >= 6 && bytes[0] == 0x41 && bytes[1] == 0x01) {
        return ReadinessMonitors.fromBytes(bytes.sublist(2));
      }
    } catch (_) {}
    return ReadinessMonitors(milOn: false, dtcCount: 0, monitors: []);
  }

  /// Read ECU calibration & system IDs (Mode 09)
  Future<Map<String, String>> readEcuDetails() async {
    final Map<String, String> details = {
      'vin': 'N/A',
      'cal_id': 'N/A',
      'cvn': 'N/A',
      'ecu_name': 'Engine Control Module (ECM)',
    };

    try {
      // VIN
      final vinRaw = await driver.executeCommand("0902", timeout: const Duration(seconds: 4));
      final vin = HexParser.parseVin(HexParser.extractBytes(vinRaw));
      if (vin.isNotEmpty) details['vin'] = vin;

      // CALID
      final calRaw = await driver.executeCommand("0904", timeout: const Duration(seconds: 4));
      final calBytes = HexParser.extractBytes(calRaw);
      final calId = HexParser.parseVin(calBytes);
      if (calId.isNotEmpty) details['cal_id'] = calId;

      // CVN
      final cvnRaw = await driver.executeCommand("0906", timeout: const Duration(seconds: 4));
      final cvnBytes = HexParser.extractBytes(cvnRaw);
      final cvn = HexParser.parseVin(cvnBytes);
      if (cvn.isNotEmpty) details['cvn'] = cvn;

      // ECU Name
      final nameRaw = await driver.executeCommand("090A", timeout: const Duration(seconds: 4));
      final nameBytes = HexParser.extractBytes(nameRaw);
      final ecuName = HexParser.parseVin(nameBytes);
      if (ecuName.isNotEmpty) details['ecu_name'] = ecuName;
    } catch (_) {}

    return details;
  }
}
