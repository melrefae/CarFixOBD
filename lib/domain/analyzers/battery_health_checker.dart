/// Battery, Cranking, and Alternator Health Result
class BatteryHealthResult {
  final double restingVoltage;
  final double crankingVoltageDrop;
  final double alternatorVoltage;
  final String batteryStatusAr;
  final String alternatorStatusAr;
  final String recommendationAr;
  final String batteryStatusEn;
  final String alternatorStatusEn;
  final String recommendationEn;
  final bool isBatteryGood;
  final bool isAlternatorGood;

  BatteryHealthResult({
    required this.restingVoltage,
    required this.crankingVoltageDrop,
    required this.alternatorVoltage,
    required this.batteryStatusAr,
    required this.alternatorStatusAr,
    required this.recommendationAr,
    required this.batteryStatusEn,
    required this.alternatorStatusEn,
    required this.recommendationEn,
    required this.isBatteryGood,
    required this.isAlternatorGood,
  });

  String get batteryStatus => batteryStatusEn;
  String get alternatorStatus => alternatorStatusEn;
  String get recommendation => recommendationEn;
}

/// Algorithm to evaluate 12V automotive battery and alternator charging system
class BatteryHealthChecker {
  static BatteryHealthResult evaluate({
    required double restingVoltage,
    required double minCrankingVoltage,
    required double runningVoltage,
  }) {
    bool batteryGood = true;
    String batteryStatusAr = "البطارية ممتازة وتحتفظ بكامل شحنتها";
    String batteryStatusEn = "Battery condition is optimal with full charge capacity";

    // Resting voltage evaluation
    if (restingVoltage < 12.0) {
      batteryGood = false;
      batteryStatusAr = "البطارية مفرغة أو رديئة الشحن (< 12.0V)";
      batteryStatusEn = "Battery is deeply discharged or degraded (< 12.0V)";
    } else if (restingVoltage < 12.4) {
      batteryStatusAr = "البطارية متوسطة الشحن (75%)";
      batteryStatusEn = "Battery is moderately charged (~75%)";
    }

    // Cranking voltage drop evaluation (< 9.6V is critical failure)
    if (minCrankingVoltage > 0 && minCrankingVoltage < 9.6) {
      batteryGood = false;
      batteryStatusAr =
          "ضعف شديد في عزم البطارية: هبوط الفولت إلى ${minCrankingVoltage.toStringAsFixed(1)}V أثناء التدوير";
      batteryStatusEn =
          "Severe cranking voltage drop: fell to ${minCrankingVoltage.toStringAsFixed(1)}V during starter crank (< 9.6V threshold)";
    }

    // Alternator output evaluation
    bool alternatorGood = true;
    String alternatorStatusAr = "شحن الدينامو طبيعي ومتوازن";
    String alternatorStatusEn = "Alternator output is normal and stabilized";

    if (runningVoltage > 14.7) {
      alternatorGood = false;
      alternatorStatusAr =
          "تحذير: شحن دينامو زائد (${runningVoltage.toStringAsFixed(1)}V) قد يتلف البطارية ووحدات الكونترول!";
      alternatorStatusEn =
          "Warning: Alternator overcharging (${runningVoltage.toStringAsFixed(1)}V). Risk of boiling electrolyte and damaging vehicle control modules!";
    } else if (runningVoltage < 13.4 && runningVoltage > 0) {
      alternatorGood = false;
      alternatorStatusAr =
          "تحذير: شحن الدينامو ضعيف (${runningVoltage.toStringAsFixed(1)}V) لا يكفي لتغذية أجهزة السيارة.";
      alternatorStatusEn =
          "Warning: Alternator undercharging (${runningVoltage.toStringAsFixed(1)}V). Insufficient to sustain vehicle electrical load.";
    }

    String recAr = "المنظومة الكهربائية تعمل بكفاءة تامة.";
    String recEn = "Electrical charging system is operating at peak efficiency.";

    if (!batteryGood && !alternatorGood) {
      recAr = "يجب شحن أو استبدال البطارية وصيانة كتاوت أو سيور الدينامو فوراً.";
      recEn = "Recharge or replace battery, and inspect alternator belt, diode pack, and voltage regulator immediately.";
    } else if (!batteryGood) {
      recAr = "افحص قواطيش البطارية ونظف الأملاح، واستبدل البطارية إذا تكرر هبوط التدوير.";
      recEn = "Clean battery terminals and cable connections. Replace battery if cranking drop persists.";
    } else if (!alternatorGood) {
      recAr = "افحص شداد سير المجموعة وكتاوت الدينامو والشربونات.";
      recEn = "Inspect serpentine belt tension, alternator carbon brushes, and voltage regulator.";
    }

    return BatteryHealthResult(
      restingVoltage: restingVoltage,
      crankingVoltageDrop: minCrankingVoltage,
      alternatorVoltage: runningVoltage,
      batteryStatusAr: batteryStatusAr,
      alternatorStatusAr: alternatorStatusAr,
      recommendationAr: recAr,
      batteryStatusEn: batteryStatusEn,
      alternatorStatusEn: alternatorStatusEn,
      recommendationEn: recEn,
      isBatteryGood: batteryGood,
      isAlternatorGood: alternatorGood,
    );
  }
}
