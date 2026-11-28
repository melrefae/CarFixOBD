/// Evaluates Catalytic Converter health and efficiency by analyzing
/// Upstream (B1S1) vs Downstream (B1S2) Oxygen Sensor switching dynamics
enum CatalyticHealthState { insufficientData, excellent, aging, failing }

class CatalyticHealthReport {
  final double efficiencyPercent;
  final double switchingRatio;
  final int upstreamCrossCount;
  final int downstreamCrossCount;
  final double avgDownstreamVoltage;
  final CatalyticHealthState state;
  final String status;
  final String diagnosis;
  final String recommendation;

  const CatalyticHealthReport({
    required this.efficiencyPercent,
    required this.switchingRatio,
    required this.upstreamCrossCount,
    required this.downstreamCrossCount,
    required this.avgDownstreamVoltage,
    required this.state,
    required this.status,
    required this.diagnosis,
    required this.recommendation,
  });

  bool get isHealthy => efficiencyPercent >= 85.0;
  bool get isDegraded => efficiencyPercent < 70.0;
}

class CatalyticHealthAnalyzer {
  static const double midVoltage = 0.45;

  /// Analyze parallel arrays of B1S1 (upstream) and B1S2 (downstream) voltage readings
  static CatalyticHealthReport analyze({
    required List<double> upstreamVolts,
    required List<double> downstreamVolts,
  }) {
    if (upstreamVolts.length < 5 || downstreamVolts.length < 5) {
      return const CatalyticHealthReport(
        efficiencyPercent: 95.0,
        switchingRatio: 0.05,
        upstreamCrossCount: 0,
        downstreamCrossCount: 0,
        avgDownstreamVoltage: 0.65,
        state: CatalyticHealthState.insufficientData,
        status: "Normal / Insufficient Samples",
        diagnosis: "Collecting oxygen sensor telemetry data...",
        recommendation: "Allow engine to idle or cruise steadily for 15 seconds to accumulate sensor waveforms.",
      );
    }

    int upCross = 0;
    for (int i = 1; i < upstreamVolts.length; i++) {
      final prev = upstreamVolts[i - 1];
      final curr = upstreamVolts[i];
      if ((prev < midVoltage && curr >= midVoltage) || (prev >= midVoltage && curr < midVoltage)) {
        upCross++;
      }
    }

    int downCross = 0;
    double downSum = 0.0;
    for (int i = 1; i < downstreamVolts.length; i++) {
      final prev = downstreamVolts[i - 1];
      final curr = downstreamVolts[i];
      downSum += curr;
      if ((prev < midVoltage && curr >= midVoltage) || (prev >= midVoltage && curr < midVoltage)) {
        downCross++;
      }
    }

    final avgDown = downstreamVolts.isNotEmpty ? downSum / downstreamVolts.length : 0.65;
    final ratio = downCross / (upCross == 0 ? 1 : upCross);
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final efficiency = (100.0 - (clampedRatio * 75.0)).clamp(25.0, 99.0);

    CatalyticHealthState state;
    String status;
    String diagnosis;
    String recommendation;

    if (efficiency >= 85.0) {
      state = CatalyticHealthState.excellent;
      status = "Excellent / High Efficiency (OEM Benchmark)";
      diagnosis = "Upstream sensor switches rapidly ($upCross transitions) while downstream sensor remains flat and steady (~${avgDown.toStringAsFixed(2)}V). The catalytic substrate has strong oxygen storage capacity.";
      recommendation = "No service required. Emissions system is operating within optimum Euro 4/5/6 compliance limits.";
    } else if (efficiency >= 70.0) {
      state = CatalyticHealthState.aging;
      status = "Aging Catalytic Converter (Moderate Efficiency)";
      diagnosis = "Downstream sensor is beginning to mimic upstream switching ($downCross transitions vs $upCross). Oxygen storage capacity has degraded by ${(100 - efficiency).toStringAsFixed(0)}%.";
      recommendation = "Inspect for minor exhaust manifold gasket leaks or unburnt fuel from rich misfires. Add high-grade catalytic converter cleaner additive.";
    } else {
      state = CatalyticHealthState.failing;
      status = "Severely Degraded / Catalytic Failure (P0420 Precursor)";
      diagnosis = "Downstream oxygen sensor is mirroring upstream oscillations with high switching ratio (${(clampedRatio * 100).toStringAsFixed(0)}%). The catalytic converter is no longer storing oxygen or reducing emissions.";
      recommendation = "Catalytic converter core is melted, hollowed, or poisoned by leaded/contaminated fuel. Replacement of the converter or cleaning core is required.";
    }

    return CatalyticHealthReport(
      state: state,
      efficiencyPercent: efficiency,
      switchingRatio: clampedRatio,
      upstreamCrossCount: upCross,
      downstreamCrossCount: downCross,
      avgDownstreamVoltage: avgDown,
      status: status,
      diagnosis: diagnosis,
      recommendation: recommendation,
    );
  }
}
