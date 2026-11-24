/// أدوات تحويل وتنسيق وحدات القياس الفنية الشائعة في الورش ومراكز الصيانة
class UnitConverter {
  /// تحويل الضغط من كيلو باسكال (kPa) إلى بار (Bar)
  static double kpaToBar(double kpa) => kpa / 100.0;

  /// تحويل الضغط من كيلو باسكال (kPa) إلى رطل/بوصة مربعة (PSI)
  static double kpaToPsi(double kpa) => kpa * 0.145038;

  /// تحويل السرعة من كم/ساعة إلى ميل/ساعة
  static double kmhToMph(double kmh) => kmh * 0.621371;

  /// تحويل الحرارة من مئوية إلى فهرنهايت
  static double celsiusToFahrenheit(double c) => (c * 9 / 5) + 32;

  /// تنسيق الأرقام العشرية مع رمز الوحدة
  static String format(double value, String unit, {int decimals = 1}) {
    return "${value.toStringAsFixed(decimals)} $unit";
  }

  /// تحديد ما إذا كانت حرارة المياه طبيعية لمحركات البنزين (85°C - 105°C)
  static bool isCoolantTempSafe(double tempCelsius) {
    return tempCelsius >= 75 && tempCelsius <= 108;
  }

  /// تقييم فولت شحن الدينامو (طبيعي بين 13.6V و 14.6V عند دوران المحرك)
  static String evaluateAlternatorVoltage(double volts, bool engineRunning) {
    if (!engineRunning) {
      if (volts >= 12.4) return "البطارية مشحونة وممتازة";
      if (volts >= 11.9) return "البطارية متوسطة الشحن";
      return "البطارية ضعيفة ومحتاجة شحن";
    } else {
      if (volts >= 13.6 && volts <= 14.6) return "شحن الدينامو ممتاز وطبيعي";
      if (volts > 14.6) return "تحذير: شحن دينامو زائد (Overcharge) - افحص كتاوت الدينامو";
      return "تحذير: شحن الدينامو ضعيف (Undercharge)";
    }
  }
}
