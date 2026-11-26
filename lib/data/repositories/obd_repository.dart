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
  bool _batchPollingSupported = true;
  final Set<String> _unsupportedPids = {};
  final Map<String, int> _consecutiveFailures = {};
  Set<String> _discoveredSupportedPids = {};

  ObdRepository({required this.driver});

  bool get isPolling => _isPolling;
  Set<String> get discoveredSupportedPids => Set.unmodifiable(_discoveredSupportedPids);
  Set<String> get unsupportedPids => Set.unmodifiable(_unsupportedPids);

  /// Clear unsupported PIDs cache & protocol flags
  void resetUnsupportedPids() {
    _unsupportedPids.clear();
    _consecutiveFailures.clear();
    _discoveredSupportedPids.clear();
    _batchPollingSupported = true;
  }

  /// Check whether raw ELM response is a genuine ISO 14229/J1979 Negative Response (`7F <sid> <nrc>`),
  /// avoiding false positives when sensor payload bytes happen to equal `0x7F` (e.g. Coolant 87 °C = 41 05 7F).
  static bool _isNegativeResponse(String raw, List<int> bytes, int expectedService) {
    if (bytes.length >= 2 && bytes[0] == 0x7F && bytes[1] == expectedService) {
      return true;
    }
    final upper = raw.toUpperCase().trim();
    return upper.startsWith('7F ');
  }

  /// Sweep SAE J1979 Mode 01 supported PID bitmasks (`0100`, `0120`, `0140`, `0160`, `0180`, `01A0`)
  /// Updates `isSupported` on each Mode `01` SensorPid and records unsupported PIDs immediately.
  Future<Set<String>> discoverSupportedPids(List<SensorPid> sensors) async {
    final discovered = <String>{};
    const ranges = [
      ('0100', 0x00, '20'),
      ('0120', 0x20, '40'),
      ('0140', 0x40, '60'),
      ('0160', 0x60, '80'),
      ('0180', 0x80, 'A0'),
      ('01A0', 0xA0, 'C0'),
    ];

    try {
      for (final (cmd, basePid, nextFlagPid) in ranges) {
        final raw = await driver.executeCommand(cmd, timeout: const Duration(milliseconds: 1200));
        if (raw == "TIMEOUT" || HexParser.isErrorResponse(raw) || raw.contains("?")) {
          break;
        }
        final bytes = HexParser.extractBytes(raw);
        if (_isNegativeResponse(raw, bytes, 0x01)) {
          break;
        }
        final payload = HexParser.extractPayload(bytes, 0x01, basePid);
        if (payload.length < 4) break;

        final chunk = HexParser.parseSupportedPidBitmask(payload.sublist(0, 4), basePid);
        discovered.addAll(chunk);

        if (!chunk.contains(nextFlagPid)) {
          break; // ECU bit 32 is 0 -> no higher PID range supported
        }
      }
    } catch (_) {}

    if (discovered.isNotEmpty) {
      _discoveredSupportedPids = discovered;
      for (final sensor in sensors) {
        if (sensor.mode == "01" && !sensor.isCustom) {
          final p = sensor.pid.toUpperCase();
          final ok = discovered.contains(p);
          sensor.isSupported = ok;
          if (!ok) {
            _unsupportedPids.add("01$p");
          } else {
            _unsupportedPids.remove("01$p");
          }
        }
      }
    }

    return discovered;
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
      // Read VIN (Mode 09 PID 02, then UDS DID F190 fallback)
      final vinRaw = await driver.executeCommand("0902", timeout: const Duration(seconds: 4));
      var vin = HexParser.parseVin(HexParser.extractBytes(vinRaw));
      if (vin.length < 15) {
        final udsVinRaw = await driver.executeCommand("22F190", timeout: const Duration(milliseconds: 1400));
        final udsVin = HexParser.parseVin(HexParser.extractBytes(udsVinRaw));
        if (udsVin.length >= 15) {
          vin = udsVin;
        }
      }
      if (vin.isNotEmpty) {
        data['vin'] = vin;
      }

      // Read MIL and readiness status (Mode 01 PID 01)
      final milRaw = await driver.executeCommand("0101", timeout: const Duration(seconds: 2));
      final milBytes = HexParser.extractBytes(milRaw);
      final milPayload = HexParser.extractPayload(milBytes, 0x01, 0x01);
      if (milPayload.isNotEmpty) {
        final byteA = milPayload[0];
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

  /// Fixed Mode 01 byte payload lengths for safe CAN multi-PID batch framing
  static const Map<int, int> _batchSafePidByteLengths = {
    0x04: 1, 0x05: 1, 0x06: 1, 0x07: 1, 0x0B: 1, 0x0C: 2, 0x0D: 1,
    0x0E: 1, 0x0F: 1, 0x10: 2, 0x11: 1, 0x14: 2, 0x15: 2, 0x1F: 2,
    0x2C: 1, 0x2E: 1, 0x2F: 1, 0x31: 2, 0x32: 2, 0x33: 1, 0x3C: 2,
    0x42: 2, 0x44: 2, 0x46: 1, 0x49: 1, 0x5C: 1, 0x5E: 2,
  };

  /// Query up to 4 standard Mode 01 PIDs in a single CAN ISO 15765-4 frame (`01 0C 0D 05 11`)
  /// Automatically detects clone/protocol refusal and falls back cleanly.
  Future<List<SensorPid>> readBatchMode01Sensors(List<SensorPid> batch) async {
    if (batch.isEmpty) return [];
    final cmdPids = batch.map((s) => s.pid.toUpperCase().padLeft(2, '0')).join();
    final cmd = "01$cmdPids";

    try {
      final raw = await driver.executeCommand(cmd, timeout: const Duration(milliseconds: 900));
      if (raw == "TIMEOUT" || HexParser.isErrorResponse(raw) || raw.contains("?")) {
        _batchPollingSupported = false;
        return [];
      }

      final bytes = HexParser.extractBytes(raw);
      if (_isNegativeResponse(raw, bytes, 0x01)) {
        _batchPollingSupported = false;
        return [];
      }
      final modeIdx = bytes.indexOf(0x41);
      if (modeIdx == -1 || modeIdx + 1 >= bytes.length) {
        _batchPollingSupported = false;
        return [];
      }

      final updated = <SensorPid>[];
      final byPid = {for (final s in batch) int.tryParse(s.pid, radix: 16) ?? -1: s};
      int idx = modeIdx + 1;

      while (idx < bytes.length) {
        final pidNum = bytes[idx];
        final dataLen = _batchSafePidByteLengths[pidNum];
        if (dataLen == null) break;
        if (idx + 1 + dataLen > bytes.length) break;

        final payload = bytes.sublist(idx + 1, idx + 1 + dataLen);
        final sensor = byPid[pidNum];
        if (sensor != null && sensor.decodeAndUpdate(payload)) {
          updated.add(sensor);
        }
        idx += 1 + dataLen;
      }

      if (updated.isEmpty) {
        _batchPollingSupported = false;
      }
      return updated;
    } catch (_) {
      _batchPollingSupported = false;
      return [];
    }
  }

  /// Read single sensor value with dynamic unsupported PID skip and fast NRC / error abort
  Future<bool> readSingleSensor(SensorPid sensor) async {
    final key = "${sensor.mode}${sensor.pid}";
    if (_unsupportedPids.contains(key)) {
      sensor.isSupported = false;
      return false;
    }

    final modeInt = int.tryParse(sensor.mode, radix: 16) ?? 1;
    final pidInt = int.tryParse(sensor.pid, radix: 16) ?? 0;

    try {
      final raw = await driver.executeCommand(key, timeout: const Duration(milliseconds: 700));
      final bytes = HexParser.extractBytes(raw);
      final isNrc = _isNegativeResponse(raw, bytes, modeInt);
      if (raw == "TIMEOUT" || HexParser.isErrorResponse(raw) || isNrc || raw.contains("?")) {
        final fails = (_consecutiveFailures[key] ?? 0) + 1;
        _consecutiveFailures[key] = fails;
        if (fails >= 2 || raw.toUpperCase().contains("NO DATA") || raw.contains("?") || isNrc) {
          _unsupportedPids.add(key);
          sensor.isSupported = false;
        }
        return false;
      }
      _consecutiveFailures[key] = 0;

      // Support 2-byte UDS Mode 22 PID extraction as well as 1-byte Mode 01/21 PIDs
      List<int> payload = [];
      if (modeInt == 0x22 && sensor.pid.length == 4) {
        final pidHi = int.tryParse(sensor.pid.substring(0, 2), radix: 16) ?? 0;
        final pidLo = int.tryParse(sensor.pid.substring(2, 4), radix: 16) ?? 0;
        for (int i = 0; i < bytes.length - 2; i++) {
          if (bytes[i] == 0x62 && bytes[i + 1] == pidHi && bytes[i + 2] == pidLo) {
            payload = bytes.sublist(i + 3);
            break;
          }
        }
      } else {
        payload = HexParser.extractPayload(bytes, modeInt, pidInt);
      }

      if (payload.isNotEmpty) {
        return sensor.decodeAndUpdate(payload);
      }
      return false;
    } catch (_) {
      final fails = (_consecutiveFailures[key] ?? 0) + 1;
      _consecutiveFailures[key] = fails;
      if (fails >= 2) {
        _unsupportedPids.add(key);
        sensor.isSupported = false;
      }
      return false;
    }
  }

  /// High-speed live polling loop skipping unsupported sensors and using CAN multi-PID batching when available
  Future<void> startPolling(List<SensorPid> sensors, Function(SensorPid) onUpdate) async {
    _isPolling = true;

    while (_isPolling && driver.connection.isConnected) {
      final active = sensors.where((s) {
        final key = "${s.mode}${s.pid}";
        return s.isSelected && s.isSupported && !_unsupportedPids.contains(key);
      }).toList();

      if (active.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 250));
        continue;
      }

      final canProtocol = driver.activeProtocol.toUpperCase().contains('CAN') ||
          driver.activeProtocol.contains('15765');

      final batchable = <SensorPid>[];
      final singleQueue = <SensorPid>[];

      for (final s in active) {
        final pidInt = int.tryParse(s.pid, radix: 16);
        if (_batchPollingSupported &&
            canProtocol &&
            s.mode == "01" &&
            !s.isCustom &&
            pidInt != null &&
            _batchSafePidByteLengths.containsKey(pidInt)) {
          batchable.add(s);
        } else {
          singleQueue.add(s);
        }
      }

      // 1. Poll batchable Mode 01 sensors 4 at a time over CAN
      for (int i = 0; i < batchable.length; i += 4) {
        if (!_isPolling || !driver.connection.isConnected) break;
        final chunk = batchable.sublist(i, (i + 4).clamp(0, batchable.length));
        if (_batchPollingSupported && chunk.length > 1) {
          final updatedList = await readBatchMode01Sensors(chunk);
          if (updatedList.isNotEmpty) {
            for (final u in updatedList) {
              onUpdate(u);
            }
          } else {
            // Immediate fallback to individual polling for remaining sensors in chunk
            for (final s in chunk) {
              if (!_isPolling) break;
              if (await readSingleSensor(s)) onUpdate(s);
              await Future.delayed(const Duration(milliseconds: 10));
            }
          }
        } else {
          for (final s in chunk) {
            if (!_isPolling) break;
            if (await readSingleSensor(s)) onUpdate(s);
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        await Future.delayed(const Duration(milliseconds: 12));
      }

      // 2. Poll remaining single/OEM/UDS PIDs individually
      for (final s in singleQueue) {
        if (!_isPolling || !driver.connection.isConnected) break;
        if (await readSingleSensor(s)) {
          onUpdate(s);
        }
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
      final payload = HexParser.extractPayload(bytes, 0x01, 0x31);
      if (payload.length >= 2) {
        distClearedKm = (payload[0] << 8) | payload[1];
      }
    } catch (_) {}

    // 2. Read Distance Traveled With Malfunction Indicator Lamp On (Mode 01 PID 21)
    try {
      final resp = await driver.executeCommand("0121", timeout: const Duration(seconds: 2));
      final bytes = HexParser.extractBytes(resp);
      final payload = HexParser.extractPayload(bytes, 0x01, 0x21);
      if (payload.length >= 2) {
        distMilKm = (payload[0] << 8) | payload[1];
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
      final dtcPayload = HexParser.extractPayload(dtcBytes, 0x02, 0x02);
      if (dtcPayload.length >= 2) {
        final decoded = HexParser.decodeSingleDtc(dtcPayload[0], dtcPayload[1]);
        if (decoded.isNotEmpty) dtcCode = decoded;
      }

      // 2. RPM (PID 0C)
      final rpmRaw = await driver.executeCommand("020C");
      final rpmPayload = HexParser.extractPayload(HexParser.extractBytes(rpmRaw), 0x02, 0x0C);
      double rpm = 0;
      if (rpmPayload.length >= 2) {
        rpm = ((rpmPayload[0] * 256) + rpmPayload[1]) / 4.0;
      }

      // 3. Vehicle Speed (PID 0D)
      final speedRaw = await driver.executeCommand("020D");
      final speedPayload = HexParser.extractPayload(HexParser.extractBytes(speedRaw), 0x02, 0x0D);
      double speed = speedPayload.isNotEmpty ? speedPayload[0].toDouble() : 0;

      // 4. Coolant Temperature (PID 05)
      final tempRaw = await driver.executeCommand("0205");
      final tempPayload = HexParser.extractPayload(HexParser.extractBytes(tempRaw), 0x02, 0x05);
      double temp = tempPayload.isNotEmpty ? (tempPayload[0] - 40).toDouble() : 0;

      // 5. Engine Load (PID 04)
      final loadRaw = await driver.executeCommand("0204");
      final loadPayload = HexParser.extractPayload(HexParser.extractBytes(loadRaw), 0x02, 0x04);
      double load = loadPayload.isNotEmpty ? (loadPayload[0] * 100.0) / 255.0 : 0;

      // 6. Throttle Position (PID 11)
      final tpsRaw = await driver.executeCommand("0211");
      final tpsPayload = HexParser.extractPayload(HexParser.extractBytes(tpsRaw), 0x02, 0x11);
      double tps = tpsPayload.isNotEmpty ? (tpsPayload[0] * 100.0) / 255.0 : 0;

      // 7. Intake Air Temp (PID 0F)
      final iatRaw = await driver.executeCommand("020F");
      final iatPayload = HexParser.extractPayload(HexParser.extractBytes(iatRaw), 0x02, 0x0F);
      double iat = iatPayload.isNotEmpty ? (iatPayload[0] - 40).toDouble() : 0;

      // 8. Manifold Pressure (PID 0B)
      final mapRaw = await driver.executeCommand("020B");
      final mapPayload = HexParser.extractPayload(HexParser.extractBytes(mapRaw), 0x02, 0x0B);
      double map = mapPayload.isNotEmpty ? mapPayload[0].toDouble() : 0;

      // 9. STFT (PID 06)
      final stftRaw = await driver.executeCommand("0206");
      final stftPayload = HexParser.extractPayload(HexParser.extractBytes(stftRaw), 0x02, 0x06);
      double stft = stftPayload.isNotEmpty ? ((stftPayload[0] - 128.0) * 100.0) / 128.0 : 0;

      // 10. LTFT (PID 07)
      final ltftRaw = await driver.executeCommand("0207");
      final ltftPayload = HexParser.extractPayload(HexParser.extractBytes(ltftRaw), 0x02, 0x07);
      double ltft = ltftPayload.isNotEmpty ? ((ltftPayload[0] - 128.0) * 100.0) / 128.0 : 0;

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
      final payload = HexParser.extractPayload(bytes, 0x01, 0x01);
      if (payload.length >= 4) {
        return ReadinessMonitors.fromBytes(payload);
      }
    } catch (_) {}
    return ReadinessMonitors(milOn: false, dtcCount: 0, monitors: []);
  }

  /// Read ECU calibration & system IDs (Mode 09 with proper CALID/CVN/ECU Name parsing + UDS DID fallback)
  Future<Map<String, String>> readEcuDetails() async {
    final Map<String, String> details = {
      'vin': 'N/A',
      'cal_id': 'N/A',
      'cvn': 'N/A',
      'ecu_name': 'Engine Control Module (ECM)',
      'oem_part': 'N/A',
    };

    try {
      // 1. VIN (Mode 09 02 -> UDS 22 F1 90)
      final vinRaw = await driver.executeCommand("0902", timeout: const Duration(seconds: 3));
      var vin = HexParser.parseVin(HexParser.extractBytes(vinRaw));
      if (vin.length < 15) {
        final udsVinRaw = await driver.executeCommand("22F190", timeout: const Duration(milliseconds: 1200));
        final udsVin = HexParser.parseVin(HexParser.extractBytes(udsVinRaw));
        if (udsVin.length >= 15) vin = udsVin;
      }
      if (vin.isNotEmpty) details['vin'] = vin;

      // 2. CALID (Mode 09 04 -> parseAsciiResponse without 17-char truncation)
      final calRaw = await driver.executeCommand("0904", timeout: const Duration(seconds: 3));
      final calBytes = HexParser.extractBytes(calRaw);
      final calId = HexParser.parseAsciiResponse(calBytes, 0x09, 0x04);
      if (calId.isNotEmpty) details['cal_id'] = calId;

      // 3. CVN (Mode 09 06 -> either printable ASCII or 4-byte hex verification checksum)
      final cvnRaw = await driver.executeCommand("0906", timeout: const Duration(seconds: 3));
      final cvnBytes = HexParser.extractBytes(cvnRaw);
      final cvnAscii = HexParser.parseAsciiResponse(cvnBytes, 0x09, 0x06);
      if (cvnAscii.isNotEmpty && cvnAscii.length >= 4) {
        details['cvn'] = cvnAscii;
      } else {
        final cvnPayload = HexParser.extractPayload(cvnBytes, 0x09, 0x06);
        if (cvnPayload.length >= 4) {
          final start = cvnPayload[0] <= 0x04 && cvnPayload.length >= 5 ? 1 : 0;
          final hexStr = cvnPayload
              .skip(start)
              .take(4)
              .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
              .join();
          if (hexStr.isNotEmpty) details['cvn'] = hexStr;
        }
      }

      // 4. ECU Name (Mode 09 0A -> parseAsciiResponse)
      final nameRaw = await driver.executeCommand("090A", timeout: const Duration(seconds: 3));
      final nameBytes = HexParser.extractBytes(nameRaw);
      final ecuName = HexParser.parseAsciiResponse(nameBytes, 0x09, 0x0A);
      if (ecuName.isNotEmpty) details['ecu_name'] = ecuName;

      // 5. UDS OEM Spare Part Number / SW Version fallback (22 F1 87 / 22 F1 89)
      final partRaw = await driver.executeCommand("22F187", timeout: const Duration(milliseconds: 1000));
      final partStr = HexParser.parseUdsAsciiDid(HexParser.extractBytes(partRaw), 0xF1, 0x87);
      if (partStr.isNotEmpty) {
        details['oem_part'] = partStr;
        if (details['cal_id'] == 'N/A') details['cal_id'] = partStr;
      }
    } catch (_) {}

    return details;
  }

  /// Scan SAE J1979 Mode $06 Non-Continuous Component Monitors (Misfires, O2, Catalyst, EVAP, EGR)
  Future<List<Mode06TestResult>> readMode06Monitors() async {
    final results = <Mode06TestResult>[];
    final seen = <String>{};

    // Standard high-value MIDs: 01..04 (O2), 21 (Catalyst), 31 (EGR/VVT), 3A..3C (EVAP), A1..A9 (Misfires)
    final midsToProbe = <int>[0x01, 0x02, 0x21, 0x31, 0x3A, 0x3B, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6];

    // Discover supported MIDs via 06 00 if supported by ECU
    try {
      final raw00 = await driver.executeCommand("0600", timeout: const Duration(milliseconds: 1400));
      if (!HexParser.isErrorResponse(raw00) && raw00.contains("46")) {
        final bytes00 = HexParser.extractBytes(raw00);
        // Also parse in case clone returns a test record directly
        for (final r in HexParser.parseMode06Results(bytes00)) {
          final k = '${r.mid}_${r.tid}';
          if (seen.add(k)) results.add(r);
        }
        final payload00 = HexParser.extractPayload(bytes00, 0x06, 0x00);
        if (payload00.length >= 4 && !payload00.every((b) => b == 0)) {
          final supported00 = HexParser.parseSupportedPidBitmask(payload00.sublist(0, 4), 0x00);
          if (supported00.isNotEmpty) {
            final extraMids = supported00
                .map((h) => int.tryParse(h, radix: 16) ?? 0)
                .where((m) => m > 0 && m != 0x20 && m != 0x40 && m != 0x60 && m != 0x80 && m != 0xA0)
                .take(8);
            for (final m in extraMids) {
              if (!midsToProbe.contains(m)) midsToProbe.add(m);
            }
          }
        }
      }
    } catch (_) {}

    for (final mid in midsToProbe) {
      final midHex = mid.toRadixString(16).toUpperCase().padLeft(2, '0');
      try {
        final raw = await driver.executeCommand("06$midHex", timeout: const Duration(milliseconds: 1100));
        final bytes = HexParser.extractBytes(raw);
        if (raw == "TIMEOUT" || HexParser.isErrorResponse(raw) || _isNegativeResponse(raw, bytes, 0x06)) {
          continue;
        }
        for (final item in HexParser.parseMode06Results(bytes)) {
          final key = '${item.mid}_${item.tid}';
          if (seen.add(key)) {
            results.add(item);
          }
        }
      } catch (_) {}
    }

    return results;
  }
}
