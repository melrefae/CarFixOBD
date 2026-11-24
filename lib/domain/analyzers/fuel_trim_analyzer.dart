/// Fuel Trim Analysis Result
class FuelTrimAnalysisResult {
  final double totalTrimIdle; // STFT + LTFT at idle
  final double totalTrimLoad; // STFT + LTFT at 2500 RPM
  final String statusAr;
  final String diagnosisAr;
  final String recommendationAr;
  final String statusEn;
  final String diagnosisEn;
  final String recommendationEn;
  final bool isSevere;

  FuelTrimAnalysisResult({
    required this.totalTrimIdle,
    required this.totalTrimLoad,
    required this.statusAr,
    required this.diagnosisAr,
    required this.recommendationAr,
    required this.statusEn,
    required this.diagnosisEn,
    required this.recommendationEn,
    required this.isSevere,
  });

  // Default display getters
  String get status => statusEn;
  String get diagnosis => diagnosisEn;
  String get recommendation => recommendationEn;
}

/// Intelligent Fuel Trim Diagnostic Matrix
/// Helps diagnose lean/rich conditions without random part replacement
class FuelTrimAnalyzer {
  static FuelTrimAnalysisResult analyze({
    required double stftIdle,
    required double ltftIdle,
    required double stftLoad,
    required double ltftLoad,
  }) {
    final idleTotal = stftIdle + ltftIdle;
    final loadTotal = stftLoad + ltftLoad;

    // 1. Normal and balanced (-8% to +8%)
    if (idleTotal.abs() <= 8.0 && loadTotal.abs() <= 8.0) {
      return FuelTrimAnalysisResult(
        totalTrimIdle: idleTotal,
        totalTrimLoad: loadTotal,
        statusAr: "دورة الوقود والهواء ممتازة ومتوازنة",
        diagnosisAr: "نسب البنزين والهواء في المعدلات المثالية، لا يوجد أي تسريب فاكيوم ولا مشكلة في التغذية.",
        recommendationAr: "لا يلزم أي تدخل.",
        statusEn: "Fuel and air mixture is excellent and balanced",
        diagnosisEn: "Air-fuel trims are within optimal ranges (±8%). No vacuum leaks or fuel delivery issues detected.",
        recommendationEn: "No intervention needed.",
        isSevere: false,
      );
    }

    // 2. Idle lean, improves at load (>12% idle, drops by >6% at load) -> Vacuum Leak!
    if (idleTotal > 12.0 && loadTotal < (idleTotal - 6.0)) {
      return FuelTrimAnalysisResult(
        totalTrimIdle: idleTotal,
        totalTrimLoad: loadTotal,
        statusAr: "تسريب هواء فاكيوم (Vacuum Leak)",
        diagnosisAr:
            "نسبة الوقود فقيرة جداً على السلانسيه ($idleTotal%) وتتحسن ملحوظاً عند 2500 RPM ($loadTotal%). هذا دليل قاطع على سحب هواء زائف.",
        recommendationAr:
            "افحص خراطيم الفاكيوم، خرطوم سيرفو الفرامل، جوان المانيفولد، بلف تبخير زيت الماكينة (PCV)، وأولسيهات الرشاشات.",
        statusEn: "Intake Vacuum Leak",
        diagnosisEn:
            "Mixture is significantly lean at idle (${idleTotal.toStringAsFixed(1)}%) but improves at 2500 RPM (${loadTotal.toStringAsFixed(1)}%). Indicates unmetered false air entering downstream of MAF.",
        recommendationEn:
            "Inspect vacuum hoses, brake booster hose, intake manifold gasket, PCV valve, and fuel injector O-rings.",
        isSevere: true,
      );
    }

    // 3. Worse at load (Lean worsens or stays high at load) -> Fuel Delivery Issue!
    if (loadTotal > 12.0 && loadTotal >= idleTotal) {
      return FuelTrimAnalysisResult(
        totalTrimIdle: idleTotal,
        totalTrimLoad: loadTotal,
        statusAr: "ضعف تغذية دورة البنزين (Fuel Delivery Issue)",
        diagnosisAr:
            "الخليط يزداد فقراً كلما زاد طلب المحرك للوقود ($loadTotal%). الكونترول يحاول تعويض نقص البنزين برفع زمن فتح الرشاشات.",
        recommendationAr:
            "قس ضغط طلمبة البنزين بساعة ضغط تحت الحمل، استبدل فلتر البنزين، وافحص انسداد مسطرة الرشاشات.",
        statusEn: "Fuel Delivery Deficiency",
        diagnosisEn:
            "Mixture leans out further under engine load (${loadTotal.toStringAsFixed(1)}%). ECU is attempting to compensate by maximizing injector pulse width.",
        recommendationEn:
            "Measure fuel pump pressure with gauge under load, replace fuel filter, and inspect injectors/fuel rail for restrictions.",
        isSevere: true,
      );
    }

    // 4. System Too Rich (Negative trims below -10%)
    if (idleTotal < -10.0 || loadTotal < -10.0) {
      return FuelTrimAnalysisResult(
        totalTrimIdle: idleTotal,
        totalTrimLoad: loadTotal,
        statusAr: "خليط غني بالبنزين (System Too Rich)",
        diagnosisAr:
            "كمية البنزين أكبر من الهواء المطلوب ($idleTotal%). الكونترول يحاول تقليل زمن الحقن لتفادي الدخان الأسود وتلف علبة البيئة.",
        recommendationAr:
            "افحص تسييل أحد الرشاشات، تأكد من نظافة فلتر الهواء وبوابة السلانسيه، وافحص بلف تبخير التانك (EVAP Purge Valve).",
        statusEn: "System Too Rich",
        diagnosisEn:
            "Fuel delivery exceeds required air mass (${idleTotal.toStringAsFixed(1)}%). ECU is cutting injector pulse width to prevent soot and catalytic converter damage.",
        recommendationEn:
            "Inspect for leaking/dripping fuel injectors, check air filter and throttle body cleanliness, and test EVAP purge solenoid valve.",
        isSevere: true,
      );
    }

    // 5. Mild deviation
    return FuelTrimAnalysisResult(
      totalTrimIdle: idleTotal,
      totalTrimLoad: loadTotal,
      statusAr: "انحراف طفيف في نسب الوقود",
      diagnosisAr: "توجد نسبة تعويض طفيفة من الكونترول لكنها ما تزال ضمن الحدود المقبولة.",
      recommendationAr: "نظف حساس الهواء MAF وافحص البوجيهات.",
      statusEn: "Slight Fuel Trim Deviation",
      diagnosisEn: "Minor ECU compensation observed, but still within allowable tolerance limits.",
      recommendationEn: "Clean MAF sensor wire and inspect spark plugs.",
      isSevere: false,
    );
  }
}
