import 'dart:math';

/// Individual waveform coordinate point for digital lab scope
class ScopeWaveformPoint {
  final double timeMs;
  final double voltage;

  const ScopeWaveformPoint({
    required this.timeMs,
    required this.voltage,
  });
}

/// Scope Channel Configuration (Voltage scale, coupling, trigger)
class ScopeChannelConfig {
  final String channelName;
  final int colorValue;
  double voltagePerDiv;
  bool isAcCoupled;
  bool isInverted;
  bool isEnabled;

  ScopeChannelConfig({
    required this.channelName,
    required this.colorValue,
    this.voltagePerDiv = 2.0,
    this.isAcCoupled = false,
    this.isInverted = false,
    this.isEnabled = true,
  });
}

/// Dual Cursor Measurement on Scope Canvas
class ScopeCursorMeasurement {
  final double cursor1TimeMs;
  final double cursor2TimeMs;
  final double cursor1Voltage;
  final double cursor2Voltage;

  const ScopeCursorMeasurement({
    this.cursor1TimeMs = 15.0,
    this.cursor2TimeMs = 45.0,
    this.cursor1Voltage = 0.5,
    this.cursor2Voltage = 4.8,
  });

  double get deltaTimeMs => (cursor2TimeMs - cursor1TimeMs).abs();
  double get frequencyHz => deltaTimeMs > 0 ? (1000.0 / deltaTimeMs) : 0.0;
  double get deltaVoltage => (cursor2Voltage - cursor1Voltage).abs();
}

/// Crankshaft (CKP) vs Camshaft (CMP) Timing Chain Sync Analysis
class TimingChainSyncAnalysis {
  final String enginePlatform;
  final double measuredPhaseOffsetDeg;
  final double nominalToleranceDeg;
  final bool isChainStretched;
  final String verdictEn;
  final String verdictAr;
  final List<ScopeWaveformPoint> channelACkp;
  final List<ScopeWaveformPoint> channelBCmp;
  final List<ScopeWaveformPoint> goldenOverlayCmp;

  const TimingChainSyncAnalysis({
    required this.enginePlatform,
    required this.measuredPhaseOffsetDeg,
    required this.nominalToleranceDeg,
    required this.isChainStretched,
    required this.verdictEn,
    required this.verdictAr,
    required this.channelACkp,
    required this.channelBCmp,
    required this.goldenOverlayCmp,
  });

  double get phaseOffsetDegrees => measuredPhaseOffsetDeg;
  bool get isChainStretchDetected => isChainStretched;
  String get ratingEn => isChainStretched
      ? "STRETCH DETECTED: $verdictEn"
      : (measuredPhaseOffsetDeg == 0.0 ? "STANDBY: $verdictEn" : "NOMINAL: $verdictEn");
  String get ratingAr => isChainStretched
      ? "تمدد مكتشف: $verdictAr"
      : (measuredPhaseOffsetDeg == 0.0 ? "استعداد: $verdictAr" : "مطابق للمواصفات: $verdictAr");

  static TimingChainSyncAnalysis fromLiveTelemetry({
    required double rpm,
    double? timingAdvance,
    double? timingAdvanceDeg,
    String engine = "VAG 2.0 TSI (EA888)",
    double? measuredOffsetDeg,
  }) {
    final double adv = timingAdvanceDeg ?? timingAdvance ?? 10.0;
    final double offset = measuredOffsetDeg ??
        ((adv < 0 || adv > 25.0)
            ? 5.8
            : (rpm > 0 ? (1.2 + (adv * 0.05)).clamp(0.8, 2.9) : 0.0));
    final bool isStretched = offset.abs() > 3.5;

    final List<ScopeWaveformPoint> ckpPoints = [];
    final List<ScopeWaveformPoint> cmpPoints = [];
    final List<ScopeWaveformPoint> goldenPoints = [];

    final freqMultiplier = rpm > 0 ? (rpm / 800.0).clamp(0.5, 3.0) : 0.0;

    for (int t = 0; t <= 120; t++) {
      final time = t.toDouble();
      double ckpV;
      if (rpm <= 0) {
        ckpV = 0.0;
      } else if (t >= 50 && t <= 54) {
        ckpV = 0.2; // Missing teeth sync notch
      } else {
        ckpV = 2.5 + 2.3 * sin(t * 0.8 * freqMultiplier);
      }
      ckpPoints.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(ckpV.toStringAsFixed(2))));

      final shift = isStretched ? 12 : 0;
      double cmpV = (rpm > 0 && t >= (40 + shift) && t <= (75 + shift)) ? 5.0 : 0.1;
      cmpPoints.add(ScopeWaveformPoint(timeMs: time, voltage: cmpV));

      double goldenV = (rpm > 0 && t >= 40 && t <= 75) ? 5.0 : 0.1;
      goldenPoints.add(ScopeWaveformPoint(timeMs: time, voltage: goldenV));
    }

    return TimingChainSyncAnalysis(
      enginePlatform: engine,
      measuredPhaseOffsetDeg: double.parse(offset.toStringAsFixed(1)),
      nominalToleranceDeg: 3.0,
      isChainStretched: isStretched,
      verdictEn: rpm <= 0
          ? "STANDBY: Engine stopped (0 RPM). Crank or idle engine to capture live phase correlation."
          : (isStretched
              ? "CRITICAL: Timing chain elongation detected (+${offset.toStringAsFixed(1)}° offset). Hydraulic tensioner maxed out - risk of valve contact!"
              : "PASS: Cam/Crank synchronization within factory OEM tolerance (Phase offset +${offset.toStringAsFixed(1)}° ≤ 3.0°)."),
      verdictAr: rpm <= 0
          ? "وضع الاستعداد: المحرك متوقف (0 RPM). شغل المحرك على السلانسيه لتسجيل إشارات التزامن الحية."
          : (isStretched
              ? "خطر حرج: استطالة جنزير الكاتينة / تمدد السير (+${offset.toStringAsFixed(1)}° انحراف). الشداد في أقصى مدى - خطر اصطدام الصبابات!"
              : "سليم: تزامن الكرنك والكامة مطابق لبيانات المصنع (الانحراف +${offset.toStringAsFixed(1)}° ضمن المسموح ≤ 3.0°)."),
      channelACkp: ckpPoints,
      channelBCmp: cmpPoints,
      goldenOverlayCmp: goldenPoints,
    );
  }

  static TimingChainSyncAnalysis generate({
    String engine = "VAG 1.4 TSI (EA211)",
    bool simulateStretch = false,
  }) {
    final offset = simulateStretch ? 8.6 : 1.8;
    final isStretched = offset.abs() > 3.5;

    final List<ScopeWaveformPoint> ckpPoints = [];
    final List<ScopeWaveformPoint> cmpPoints = [];
    final List<ScopeWaveformPoint> goldenPoints = [];

    // Synthesize 60-2 tooth reluctor pattern (120ms window)
    for (int t = 0; t <= 120; t++) {
      final time = t.toDouble();
      // CKP 58 regular teeth + 2 missing teeth sync gap at t=50-54ms
      double ckpV;
      if (t >= 50 && t <= 54) {
        ckpV = 0.2; // Missing teeth sync notch
      } else {
        ckpV = 2.5 + 2.3 * sin(t * 0.8);
      }
      ckpPoints.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(ckpV.toStringAsFixed(2))));

      // CMP Hall Effect pulse train with phase offset
      final shift = simulateStretch ? 14 : 0;
      double cmpV = (t >= (40 + shift) && t <= (75 + shift)) ? 5.0 : 0.1;
      cmpPoints.add(ScopeWaveformPoint(timeMs: time, voltage: cmpV));

      // Golden Known-Good factory OEM reference pattern
      double goldenV = (t >= 40 && t <= 75) ? 5.0 : 0.1;
      goldenPoints.add(ScopeWaveformPoint(timeMs: time, voltage: goldenV));
    }

    return TimingChainSyncAnalysis(
      enginePlatform: engine,
      measuredPhaseOffsetDeg: offset,
      nominalToleranceDeg: 3.0,
      isChainStretched: isStretched,
      verdictEn: isStretched
          ? "CRITICAL: Timing chain elongation detected (+${offset.toStringAsFixed(1)}° offset). Hydraulic tensioner maxed out - risk of valve contact!"
          : "PASS: Cam/Crank synchronization within factory OEM tolerance (Phase offset +${offset.toStringAsFixed(1)}° ≤ 3.0°).",
      verdictAr: isStretched
          ? "خطر حرج: استطالة جنزير الكاتينة / تمدد السير (+${offset.toStringAsFixed(1)}° انحراف). الشداد في أقصى مدى - خطر اصطدام الصبابات!"
          : "سليم: تزامن الكرنك والكامة مطابق لبيانات المصنع (الانحراف +${offset.toStringAsFixed(1)}° ضمن المسموح ≤ 3.0°).",
      channelACkp: ckpPoints,
      channelBCmp: cmpPoints,
      goldenOverlayCmp: goldenPoints,
    );
  }
}

/// Primary / Secondary Ignition Spark Burn Waveform Model
class IgnitionWaveformAnalysis {
  final double sparkBurnTimeMs;
  final double dwellChargingTimeMs;
  final double sparkLineKv;
  final bool isBurnHealthy;
  final List<ScopeWaveformPoint> sparkWaveform;

  const IgnitionWaveformAnalysis({
    required this.sparkBurnTimeMs,
    required this.dwellChargingTimeMs,
    required this.sparkLineKv,
    required this.isBurnHealthy,
    required this.sparkWaveform,
  });

  double get peakKv => sparkLineKv;
  double get burnTimeMs => sparkBurnTimeMs;
  double get dwellTimeMs => dwellChargingTimeMs;
  bool get isMisfireSuspected => !isBurnHealthy;
  String get healthRatingEn => isBurnHealthy
      ? "NOMINAL: Spark burn time within factory bounds"
      : "MISFIRE RISK: Low coil saturation or secondary leakage";
  String get healthRatingAr => isBurnHealthy
      ? "طبيعي: زمن الاحتراق ضمن الحدود المعيارية"
      : "خطر مس فاير: شحنة الملف ضعيفة أو تسريب في الجهد العالي";

  static IgnitionWaveformAnalysis fromLiveTelemetry({
    required double rpm,
    required double batteryVoltage,
  }) {
    final double volt = batteryVoltage > 5.0 ? batteryVoltage : 12.6;
    final double burnTimeMs = rpm > 0 ? (1.75 - (rpm / 12000.0)).clamp(1.2, 2.1) : 0.0;
    final double dwellChargingTimeMs = rpm > 0 ? 2.5 : 0.0;
    final double sparkLineKv = rpm > 0 ? (volt * 1.15).clamp(8.0, 18.0) : 0.0;
    final bool isHealthy = rpm <= 0 ? true : (volt >= 12.0 && sparkLineKv >= 12.0 && burnTimeMs >= 1.2);

    final List<ScopeWaveformPoint> points = [];
    for (int t = 0; t <= 60; t++) {
      final time = t * 0.1; // 0 to 6.0 ms
      double v;
      if (rpm <= 0) {
        v = 0.0;
      } else if (time < dwellChargingTimeMs) {
        v = 0.5 + (time / dwellChargingTimeMs) * 1.5;
      } else if (time >= dwellChargingTimeMs && time < (dwellChargingTimeMs + 0.1)) {
        v = sparkLineKv;
      } else if (time >= (dwellChargingTimeMs + 0.1) && time < (dwellChargingTimeMs + 0.1 + burnTimeMs)) {
        v = 2.2 + 0.2 * sin(time * 20);
      } else if (time >= (dwellChargingTimeMs + 0.1 + burnTimeMs) && time < (dwellChargingTimeMs + burnTimeMs + 1.0)) {
        v = 1.0 + 1.2 * sin((time - (dwellChargingTimeMs + burnTimeMs)) * 35) * exp(-(time - (dwellChargingTimeMs + burnTimeMs)) * 3);
      } else {
        v = 0.0;
      }
      points.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(v.toStringAsFixed(2))));
    }

    return IgnitionWaveformAnalysis(
      sparkBurnTimeMs: double.parse(burnTimeMs.toStringAsFixed(2)),
      dwellChargingTimeMs: dwellChargingTimeMs,
      sparkLineKv: double.parse(sparkLineKv.toStringAsFixed(1)),
      isBurnHealthy: isHealthy,
      sparkWaveform: points,
    );
  }

  static IgnitionWaveformAnalysis generateDefault() {
    final List<ScopeWaveformPoint> points = [];
    for (int t = 0; t <= 60; t++) {
      final time = t * 0.1; // 0 to 6.0 ms
      double v;
      if (time < 2.5) {
        // Dwell charging saturation ramp
        v = 0.5 + (time / 2.5) * 1.5;
      } else if (time >= 2.5 && time < 2.6) {
        // Firing KV spike
        v = 14.5;
      } else if (time >= 2.6 && time < 4.2) {
        // Spark burn line (1.6ms)
        v = 2.2 + 0.2 * sin(time * 20);
      } else if (time >= 4.2 && time < 5.0) {
        // Coil oscillation rings
        v = 1.0 + 1.2 * sin((time - 4.2) * 35) * exp(-(time - 4.2) * 3);
      } else {
        v = 0.0;
      }
      points.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(v.toStringAsFixed(2))));
    }

    return IgnitionWaveformAnalysis(
      sparkBurnTimeMs: 1.65,
      dwellChargingTimeMs: 2.5,
      sparkLineKv: 14.5,
      isBurnHealthy: true,
      sparkWaveform: points,
    );
  }
}

/// Fuel Injector Current Ramp & Flyback Waveform Model
class InjectorWaveformAnalysis {
  final double pulseWidthMs;
  final double flybackVoltagePeak;
  final double peakCurrentAmps;
  final bool isFlybackHealthy;
  final List<ScopeWaveformPoint> injectorWaveform;

  const InjectorWaveformAnalysis({
    required this.pulseWidthMs,
    required this.flybackVoltagePeak,
    required this.peakCurrentAmps,
    required this.isFlybackHealthy,
    required this.injectorWaveform,
  });

  double get flybackVoltage => flybackVoltagePeak;
  bool get isShortCircuitSuspected => !isFlybackHealthy;
  String get ratingEn => isFlybackHealthy
      ? "NOMINAL: Inductive flyback peak clamped cleanly"
      : "SHORT CIRCUIT: Low flyback spike indicates coil short";
  String get ratingAr => isFlybackHealthy
      ? "طبيعي: ارتداد الحث المغناطيسي سليم"
      : "شورت: انخفاض نبضة الارتداد يشير لقصر بالملف";

  static InjectorWaveformAnalysis fromLiveTelemetry({
    double rpm = 750.0,
    double engineLoad = 20.0,
    double? engineLoadPercent,
    required double batteryVoltage,
  }) {
    final double load = engineLoadPercent ?? engineLoad;
    final double volt = batteryVoltage > 5.0 ? batteryVoltage : 14.0;
    final double pulseWidth = rpm > 0
        ? (1.4 + (load * 0.04) + (load > 40 ? ((load - 40) * 0.11) : 0.0)).clamp(1.5, 18.0)
        : 0.0;
    final double flyback = rpm > 0 ? (volt * 4.9).clamp(52.0, 78.0) : 0.0;
    final double peakCurrent = rpm > 0 ? 1.25 : 0.0;
    final bool isHealthy = rpm <= 0 ? true : (flyback >= 45.0 && pulseWidth > 0 && volt >= 11.5);

    final List<ScopeWaveformPoint> points = [];
    for (int t = 0; t <= 50; t++) {
      final time = t * 0.1; // 0 to 5.0 ms
      double v;
      if (rpm <= 0) {
        v = volt;
      } else if (time < 1.0) {
        v = volt;
      } else if (time >= 1.0 && time < (1.0 + (pulseWidth.clamp(0.5, 2.5)))) {
        v = 0.4;
      } else if (time >= (1.0 + pulseWidth.clamp(0.5, 2.5)) && time < (1.2 + pulseWidth.clamp(0.5, 2.5))) {
        v = flyback;
      } else if (time >= (1.2 + pulseWidth.clamp(0.5, 2.5)) && time < (1.8 + pulseWidth.clamp(0.5, 2.5))) {
        v = volt + 8.0 * exp(-(time - 1.2) * 8);
      } else {
        v = volt;
      }
      points.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(v.toStringAsFixed(2))));
    }

    return InjectorWaveformAnalysis(
      pulseWidthMs: double.parse(pulseWidth.toStringAsFixed(2)),
      flybackVoltagePeak: double.parse(flyback.toStringAsFixed(1)),
      peakCurrentAmps: peakCurrent,
      isFlybackHealthy: isHealthy,
      injectorWaveform: points,
    );
  }

  static InjectorWaveformAnalysis generateDefault() {
    final List<ScopeWaveformPoint> points = [];
    for (int t = 0; t <= 50; t++) {
      final time = t * 0.1; // 0 to 5.0 ms
      double v;
      if (time < 1.0) {
        v = 14.0; // Rest voltage 12V system
      } else if (time >= 1.0 && time < 3.5) {
        // Driver pulls to ground (2.5ms pulse width)
        v = 0.4;
      } else if (time >= 3.5 && time < 3.7) {
        // Inductive coil collapse flyback spike (68V)
        v = 68.4;
      } else if (time >= 3.7 && time < 4.2) {
        // Clamping recovery
        v = 14.0 + 8.0 * exp(-(time - 3.7) * 8);
      } else {
        v = 14.0;
      }
      points.add(ScopeWaveformPoint(timeMs: time, voltage: double.parse(v.toStringAsFixed(2))));
    }

    return InjectorWaveformAnalysis(
      pulseWidthMs: 2.5,
      flybackVoltagePeak: 68.4,
      peakCurrentAmps: 1.25,
      isFlybackHealthy: true,
      injectorWaveform: points,
    );
  }
}
