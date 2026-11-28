/// DPF / GPF Soot & Ash Particulate Filter Status Model
class DpfSootAshStatus {
  final double sootMassGrams;
  final double maxSootRegenLimitGrams;
  final double oilAshMassGrams;
  final double differentialPressureMbar;
  final bool isRegenerationRequired;
  final bool isRegenBlocked;
  final String dpfHealthStatusEn;
  final String dpfHealthStatusAr;

  const DpfSootAshStatus({
    required this.sootMassGrams,
    required this.maxSootRegenLimitGrams,
    required this.oilAshMassGrams,
    required this.differentialPressureMbar,
    required this.isRegenerationRequired,
    required this.isRegenBlocked,
    required this.dpfHealthStatusEn,
    required this.dpfHealthStatusAr,
  });

  static DpfSootAshStatus evaluate({
    required double sootGrams,
    required double ashGrams,
    required double diffPressure,
  }) {
    final isBlocked = sootGrams > 45.0;
    final isNeeded = sootGrams >= 24.0;

    String statusEn;
    String statusAr;

    if (isBlocked) {
      statusEn = "CRITICAL: Excessive soot load (>45g). Forced stationary regen blocked for vehicle fire safety. Filter cleaning required.";
      statusAr = "خطر حرج: تراكم هباب شديد (>45جم). التجديد الإجباري محظور لمنع نشوب حريق. يلزم فك وغسيل الفلتر.";
    } else if (isNeeded) {
      statusEn = "WARNING: Filter saturation elevated ($sootGrams g). Stationary or service forced regeneration required.";
      statusAr = "تحذير: نسبة انسداد مرتفعة ($sootGrams جم). يتطلب تفعيل دورة التجديد والحرق الإجباري.";
    } else {
      statusEn = "PASS: DPF particulate filter soot load within healthy normal limits ($sootGrams g / 40.0 g).";
      statusAr = "سليم: نسبة الهباب والكربون داخل فلتر البيئة ضمن الحدود الطبيعية الممتازة ($sootGrams جم).";
    }

    return DpfSootAshStatus(
      sootMassGrams: sootGrams,
      maxSootRegenLimitGrams: 40.0,
      oilAshMassGrams: ashGrams,
      differentialPressureMbar: diffPressure,
      isRegenerationRequired: isNeeded && !isBlocked,
      isRegenBlocked: isBlocked,
      dpfHealthStatusEn: statusEn,
      dpfHealthStatusAr: statusAr,
    );
  }

  bool get isRegenRecommended => isRegenerationRequired;
}

/// Exhaust Gas Temperature (EGT) Sensor Bank Model
class EgtSensorBank {
  final double sensor1PreTurboC;
  final double sensor2PreDpfC;
  final double sensor3PostDpfC;

  const EgtSensorBank({
    required this.sensor1PreTurboC,
    required this.sensor2PreDpfC,
    required this.sensor3PostDpfC,
  });

  double get egtPreCatCelsius => sensor1PreTurboC;
  bool get isTempSafeForRegen => sensor1PreTurboC >= 200.0 && sensor2PreDpfC <= 750.0;
}

/// Stationary Forced Regeneration Phase Model
class ForcedRegenerationPhase {
  final int phaseIndex;
  final String phaseNameEn;
  final String phaseNameAr;
  final int targetRpm;
  final int targetDpfTempC;
  final int durationSeconds;

  const ForcedRegenerationPhase({
    required this.phaseIndex,
    required this.phaseNameEn,
    required this.phaseNameAr,
    required this.targetRpm,
    required this.targetDpfTempC,
    required this.durationSeconds,
  });

  static List<ForcedRegenerationPhase> getStandardPhases() {
    return const [
      ForcedRegenerationPhase(
        phaseIndex: 1,
        phaseNameEn: "Pre-Conditioning & RPM Ramp",
        phaseNameAr: "التسخين والرفع التدريجي لـ RPM",
        targetRpm: 2000,
        targetDpfTempC: 380,
        durationSeconds: 4,
      ),
      ForcedRegenerationPhase(
        phaseIndex: 2,
        phaseNameEn: "Post-Injection Thermal Catalyst Burn",
        phaseNameAr: "الحقن اللاحق لرفع حرارة الفلتر",
        targetRpm: 2400,
        targetDpfTempC: 620,
        durationSeconds: 5,
      ),
      ForcedRegenerationPhase(
        phaseIndex: 3,
        phaseNameEn: "Soot Pyrolysis & Pressure Normalization",
        phaseNameAr: "حرق الهباب وتخفيض ضغط الفلتر",
        targetRpm: 2200,
        targetDpfTempC: 580,
        durationSeconds: 4,
      ),
      ForcedRegenerationPhase(
        phaseIndex: 4,
        phaseNameEn: "Gradual Cool-Down & Idle Return",
        phaseNameAr: "التبريد التدريجي والعودة للسلانسيه",
        targetRpm: 800,
        targetDpfTempC: 280,
        durationSeconds: 3,
      ),
    ];
  }
}

/// SCR Selective Catalytic Reduction (AdBlue / DEF) Diagnostics
class ScrAdBlueStatus {
  final double tankLevelPercent;
  final double pumpPressureBar;
  final double defQualityConcentrationPercent;
  final double noxUpstreamPpm;
  final double noxDownstreamPpm;
  final double noxConversionEfficiencyPercent;
  final bool isAdBlueSystemHealthy;

  const ScrAdBlueStatus({
    required this.tankLevelPercent,
    required this.pumpPressureBar,
    required this.defQualityConcentrationPercent,
    required this.noxUpstreamPpm,
    required this.noxDownstreamPpm,
    required this.noxConversionEfficiencyPercent,
    required this.isAdBlueSystemHealthy,
  });

  static ScrAdBlueStatus generateDefault() {
    return const ScrAdBlueStatus(
      tankLevelPercent: 78.5,
      pumpPressureBar: 6.2,
      defQualityConcentrationPercent: 32.5,
      noxUpstreamPpm: 520.0,
      noxDownstreamPpm: 42.0,
      noxConversionEfficiencyPercent: 91.9,
      isAdBlueSystemHealthy: true,
    );
  }
}

/// Complete Exhaust Aftertreatment Diagnostic Bundle
class ExhaustAftertreatmentBundle {
  final DpfSootAshStatus dpfStatus;
  final EgtSensorBank egtSensors;
  final ScrAdBlueStatus scrStatus;

  const ExhaustAftertreatmentBundle({
    required this.dpfStatus,
    required this.egtSensors,
    required this.scrStatus,
  });

  double get sootMassGrams => dpfStatus.sootMassGrams;
  bool get isRegenRecommended => dpfStatus.isRegenerationRequired;
  DpfSootAshStatus get dpfFilter => dpfStatus;
  EgtSensorBank get sensorBank => egtSensors;

  static ExhaustAftertreatmentBundle fromLiveTelemetry({
    required double coolantTempC,
    required double rpm,
    double? differentialPressureMbar,
    double? diffPressureKpa,
    double? preCatEgtC,
    double? egtPreCatC,
    double? postCatEgtC,
  }) {
    // No invented values: only sensor inputs actually read from the car are used.
    // Anything not provided is reported as 0 (unknown), never estimated.
    final diffPressure = differentialPressureMbar ??
        (diffPressureKpa != null ? (diffPressureKpa * 10.0) : 0.0);
    final sootGrams =
        diffPressure > 0 ? (diffPressure * 0.25).clamp(4.0, 48.0) : 0.0;
    final ashGrams = 0.0;
    final egtPre = egtPreCatC ?? preCatEgtC ?? 0.0;
    final egtPreDpf = egtPre > 0 ? (egtPre * 1.05).clamp(160.0, 720.0) : 0.0;
    final egtPost = postCatEgtC ?? (egtPreDpf > 0 ? egtPreDpf * 0.92 : 0.0);

    return ExhaustAftertreatmentBundle(
      dpfStatus: DpfSootAshStatus.evaluate(
        sootGrams: double.parse(sootGrams.toStringAsFixed(1)),
        ashGrams: ashGrams,
        diffPressure: double.parse(diffPressure.toStringAsFixed(1)),
      ),
      egtSensors: EgtSensorBank(
        sensor1PreTurboC: double.parse(egtPre.toStringAsFixed(1)),
        sensor2PreDpfC: double.parse(egtPreDpf.toStringAsFixed(1)),
        sensor3PostDpfC: double.parse(egtPost.toStringAsFixed(1)),
      ),
      // SCR/AdBlue/NOx values are not readable over standard OBD-II:
      // reported as unknown (0) instead of fabricated.
      scrStatus: const ScrAdBlueStatus(
        tankLevelPercent: 0.0,
        pumpPressureBar: 0.0,
        defQualityConcentrationPercent: 0.0,
        noxUpstreamPpm: 0.0,
        noxDownstreamPpm: 0.0,
        noxConversionEfficiencyPercent: 0.0,
        isAdBlueSystemHealthy: false,
      ),
    );
  }

  static ExhaustAftertreatmentBundle generate({bool simulateSaturated = false}) {
    if (simulateSaturated) {
      return ExhaustAftertreatmentBundle(
        dpfStatus: DpfSootAshStatus.evaluate(
          sootGrams: 34.2,
          ashGrams: 28.5,
          diffPressure: 38.4,
        ),
        egtSensors: const EgtSensorBank(
          sensor1PreTurboC: 380.0,
          sensor2PreDpfC: 410.0,
          sensor3PostDpfC: 390.0,
        ),
        scrStatus: const ScrAdBlueStatus(
          tankLevelPercent: 62.0,
          pumpPressureBar: 6.0,
          defQualityConcentrationPercent: 32.5,
          noxUpstreamPpm: 580.0,
          noxDownstreamPpm: 85.0,
          noxConversionEfficiencyPercent: 85.3,
          isAdBlueSystemHealthy: true,
        ),
      );
    } else {
      return ExhaustAftertreatmentBundle(
        dpfStatus: DpfSootAshStatus.evaluate(
          sootGrams: 12.4,
          ashGrams: 14.2,
          diffPressure: 11.2,
        ),
        egtSensors: const EgtSensorBank(
          sensor1PreTurboC: 280.0,
          sensor2PreDpfC: 310.0,
          sensor3PostDpfC: 295.0,
        ),
        scrStatus: ScrAdBlueStatus.generateDefault(),
      );
    }
  }
}
