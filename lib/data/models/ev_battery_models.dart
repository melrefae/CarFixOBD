import 'dart:math';

/// Individual Cell Voltage Model for High-Voltage Battery Pack
class CellVoltageData {
  final int cellNumber;
  final double voltage;
  final bool isHighest;
  final bool isLowest;
  final double deltaFromAvgMv;

  const CellVoltageData({
    required this.cellNumber,
    required this.voltage,
    this.isHighest = false,
    this.isLowest = false,
    this.deltaFromAvgMv = 0.0,
  });
}

/// Thermal Zone Sensor Model
class ThermalZoneData {
  final String zoneId;
  final String locationNameEn;
  final String locationNameAr;
  final double tempCelsius;
  final bool isWarning;

  const ThermalZoneData({
    required this.zoneId,
    required this.locationNameEn,
    required this.locationNameAr,
    required this.tempCelsius,
    this.isWarning = false,
  });
}

/// High-Voltage Electrical Isolation & Contactor Relays Safety Model
class HighVoltageSafetyStatus {
  final double isolationResistanceMegaOhms;
  final double isolationThresholdMegaOhms;
  final bool hvilLoopClosed;
  final bool preChargeRelayEngaged;
  final bool mainPositiveContactorEngaged;
  final bool mainNegativeContactorEngaged;
  final bool pyroFuseArmed;
  final double coolantPumpLpm;
  final bool chillerValveOpen;

  const HighVoltageSafetyStatus({
    this.isolationResistanceMegaOhms = 28.5,
    this.isolationThresholdMegaOhms = 2.0,
    this.hvilLoopClosed = true,
    this.preChargeRelayEngaged = true,
    this.mainPositiveContactorEngaged = true,
    this.mainNegativeContactorEngaged = true,
    this.pyroFuseArmed = true,
    this.coolantPumpLpm = 14.8,
    this.chillerValveOpen = true,
  });

  bool get isIsolationSafe => isolationResistanceMegaOhms >= isolationThresholdMegaOhms;
}

/// Comprehensive High-Voltage & Hybrid Battery Pack Diagnostic Summary
class EvBatteryPackSummary {
  final double totalVoltage;
  final double totalCurrentAmps;
  final double socPercent;
  final double sohPercent;
  final double remainingCapacityKwh;
  final double nominalCapacityKwh;
  final int totalDischargeCycles;
  final List<CellVoltageData> cells;
  final List<ThermalZoneData> thermalZones;
  final HighVoltageSafetyStatus safetyStatus;

  const EvBatteryPackSummary({
    required this.totalVoltage,
    required this.totalCurrentAmps,
    required this.socPercent,
    required this.sohPercent,
    required this.remainingCapacityKwh,
    required this.nominalCapacityKwh,
    required this.totalDischargeCycles,
    required this.cells,
    required this.thermalZones,
    required this.safetyStatus,
  });

  double get maxCellVoltage {
    if (cells.isEmpty) return 0.0;
    return cells.map((c) => c.voltage).reduce(max);
  }

  double get minCellVoltage {
    if (cells.isEmpty) return 0.0;
    return cells.map((c) => c.voltage).reduce(min);
  }

  double get deltaMilliVolts {
    return ((maxCellVoltage - minCellVoltage) * 1000.0);
  }

  int get highestCellIndex {
    if (cells.isEmpty) return 1;
    final maxV = maxCellVoltage;
    return cells.firstWhere((c) => c.voltage == maxV).cellNumber;
  }

  int get lowestCellIndex {
    if (cells.isEmpty) return 1;
    final minV = minCellVoltage;
    return cells.firstWhere((c) => c.voltage == minV).cellNumber;
  }

  String get balanceRatingEn {
    final d = deltaMilliVolts;
    if (d <= 15.0) return "Excellent Balance (OEM Nominal)";
    if (d <= 30.0) return "Good Balance (Normal Ageing)";
    if (d <= 50.0) return "Moderate Imbalance (Balancing Advised)";
    return "Critical Imbalance (Weak Cell / Service Required)";
  }

  String get balanceRatingAr {
    final d = deltaMilliVolts;
    if (d <= 15.0) return "توازن ممتاز (مطابق لمعايير المصنع)";
    if (d <= 30.0) return "توازن جيد (استهلاك طبيعي)";
    if (d <= 50.0) return "اختلال متوسط (يُنصح بإعادة الموازنة)";
    return "اختلال حرج (خلية ضعيفة / تتطلب صيانة)";
  }

  /// Generate high-voltage battery pack telemetry derived from live vehicle OBD-II
  /// and BMS parameters.
  static EvBatteryPackSummary fromLiveTelemetry({
    required double batteryVoltage,
    required bool isConnected,
    double? coolantTemp,
  }) {
    // Per-cell voltages, pack voltage and temperatures are NOT available through
    // standard OBD-II (they need brand-specific BMS requests that are not verified).
    // Nothing is estimated or generated here: always return the empty state.
    return empty();
  }


  /// Empty / offline state when hardware interface is not connected
  static EvBatteryPackSummary empty() {
    return const EvBatteryPackSummary(
      totalVoltage: 0.0,
      totalCurrentAmps: 0.0,
      socPercent: 0.0,
      sohPercent: 0.0,
      remainingCapacityKwh: 0.0,
      nominalCapacityKwh: 0.0,
      totalDischargeCycles: 0,
      cells: [],
      thermalZones: [],
      safetyStatus: HighVoltageSafetyStatus(
        isolationResistanceMegaOhms: 0.0,
        isolationThresholdMegaOhms: 2.0,
        hvilLoopClosed: false,
        preChargeRelayEngaged: false,
        mainPositiveContactorEngaged: false,
        mainNegativeContactorEngaged: false,
        pyroFuseArmed: false,
        coolantPumpLpm: 0.0,
        chillerValveOpen: false,
      ),
    );
  }

  static EvBatteryPackSummary generateDefaultPack({bool simulateWeakCell = false}) {
    const totalCells = 96;
    const baseVoltage = 3.985;
    final List<CellVoltageData> cellList = [];

    final random = Random(42);
    double sumVoltage = 0.0;

    final tempVoltages = List<double>.generate(totalCells, (i) {
      if (simulateWeakCell && i == 16) {
        // Cell #17 simulated weak cell
        return 3.921;
      }
      if (i == 41) {
        // Cell #42 peak cell
        return 3.998;
      }
      final jitter = (random.nextDouble() - 0.5) * 0.016; // +/- 8mV
      return double.parse((baseVoltage + jitter).toStringAsFixed(3));
    });

    final avg = tempVoltages.reduce((a, b) => a + b) / totalCells;
    final maxV = tempVoltages.reduce(max);
    final minV = tempVoltages.reduce(min);

    for (int i = 0; i < totalCells; i++) {
      final v = tempVoltages[i];
      sumVoltage += v;
      cellList.add(
        CellVoltageData(
          cellNumber: i + 1,
          voltage: v,
          isHighest: v == maxV,
          isLowest: v == minV,
          deltaFromAvgMv: double.parse(((v - avg) * 1000).toStringAsFixed(1)),
        ),
      );
    }

    final thermalZones = [
      const ThermalZoneData(
        zoneId: "T1",
        locationNameEn: "Module 1-4 (Front Left)",
        locationNameAr: "مصفوفة 1-4 (أمامي يسار)",
        tempCelsius: 26.4,
      ),
      const ThermalZoneData(
        zoneId: "T2",
        locationNameEn: "Module 5-8 (Front Right)",
        locationNameAr: "مصفوفة 5-8 (أمامي يمين)",
        tempCelsius: 27.2,
      ),
      const ThermalZoneData(
        zoneId: "T3",
        locationNameEn: "Module 9-12 (Rear Left)",
        locationNameAr: "مصفوفة 9-12 (خلفي يسار)",
        tempCelsius: 26.8,
      ),
      const ThermalZoneData(
        zoneId: "T4",
        locationNameEn: "Module 13-16 (Rear Right)",
        locationNameAr: "مصفوفة 13-16 (خلفي يمين)",
        tempCelsius: 27.6,
      ),
    ];

    return EvBatteryPackSummary(
      totalVoltage: double.parse(sumVoltage.toStringAsFixed(1)),
      totalCurrentAmps: 14.2,
      socPercent: 78.4,
      sohPercent: 94.2,
      remainingCapacityKwh: 60.3,
      nominalCapacityKwh: 64.0,
      totalDischargeCycles: 412,
      cells: cellList,
      thermalZones: thermalZones,
      safetyStatus: const HighVoltageSafetyStatus(),
    );
  }

  /// Simulates active/passive cell balancing routine reducing cell delta
  EvBatteryPackSummary rebalanceCells() {
    final targetVoltage = minCellVoltage + 0.006;
    final List<CellVoltageData> newCells = [];
    double newSum = 0.0;

    for (final c in cells) {
      double newV = c.voltage;
      if (newV > targetVoltage) {
        newV = targetVoltage + 0.002;
      }
      newV = double.parse(newV.toStringAsFixed(3));
      newSum += newV;
      newCells.add(
        CellVoltageData(
          cellNumber: c.cellNumber,
          voltage: newV,
          isHighest: false,
          isLowest: false,
          deltaFromAvgMv: 1.2,
        ),
      );
    }

    final maxV = newCells.map((c) => c.voltage).reduce(max);
    final minV = newCells.map((c) => c.voltage).reduce(min);

    final finalCells = newCells.map((c) {
      return CellVoltageData(
        cellNumber: c.cellNumber,
        voltage: c.voltage,
        isHighest: c.voltage == maxV,
        isLowest: c.voltage == minV,
        deltaFromAvgMv: 0.8,
      );
    }).toList();

    return EvBatteryPackSummary(
      totalVoltage: double.parse(newSum.toStringAsFixed(1)),
      totalCurrentAmps: 2.1,
      socPercent: socPercent,
      sohPercent: sohPercent + 0.5,
      remainingCapacityKwh: remainingCapacityKwh,
      nominalCapacityKwh: nominalCapacityKwh,
      totalDischargeCycles: totalDischargeCycles,
      cells: finalCells,
      thermalZones: thermalZones,
      safetyStatus: safetyStatus,
    );
  }
}
