/// فئة تمثل حساس OBD (Parameter ID - PID) ومعادلة فك تشفيره وقيمته اللحظية
class SensorPid {
  final String pid;
  final String mode;
  final String name;
  final String nameAr;
  final String unit;
  final double min;
  final double max;
  final String category; // Engine, FuelAir, Cooling, Electrical, Transmission
  final double Function(List<int> bytes) decoder;

  double currentValue;
  double get numValue => currentValue;
  double get value => currentValue;
  final List<double> history; // سجل القياسات الأخيرة للرسم البياني اللحظي
  bool isSelected;

  SensorPid({
    required this.pid,
    this.mode = "01",
    required this.name,
    required this.nameAr,
    required this.unit,
    required this.min,
    required this.max,
    required this.category,
    required this.decoder,
    this.currentValue = 0.0,
    List<double>? history,
    this.isSelected = true,
  }) : history = history ?? [];

  /// تحديث القيمة اللحظية وإضافتها لسجل الرسم البياني
  void updateValue(double newValue) {
    currentValue = newValue;
    history.add(newValue);
    if (history.length > 50) {
      history.removeAt(0); // الاحتفاظ بآخر 50 قراءة للرسم اللحظي السلس
    }
  }

  /// فك تشفير البايتات المستلمة
  bool decodeAndUpdate(List<int> bytes) {
    try {
      if (bytes.isEmpty) return false;
      final val = decoder(bytes);
      updateValue(val);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تعريف الحساسات القياسية الأكثر أهمية للفني (Standard SAE J1979 PIDs)
  static List<SensorPid> getStandardPids() {
    return [
      // دوران المحرك RPM (PID 0C): ((A * 256) + B) / 4
      SensorPid(
        pid: "0C",
        name: "Engine RPM",
        nameAr: "دوران المحرك (RPM)",
        unit: "RPM",
        min: 0,
        max: 8000,
        category: "Engine",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 4.0;
        },
      ),

      // سرعة السيارة (PID 0D): A
      SensorPid(
        pid: "0D",
        name: "Vehicle Speed",
        nameAr: "سرعة السيارة",
        unit: "km/h",
        min: 0,
        max: 240,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? bytes[0].toDouble() : 0.0,
      ),

      // حرارة مياه التبريد (PID 05): A - 40
      SensorPid(
        pid: "05",
        name: "Coolant Temperature",
        nameAr: "حرارة مياه التبريد",
        unit: "°C",
        min: -40,
        max: 130,
        category: "Cooling",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] - 40).toDouble() : 0.0,
      ),

      // فتحة البوابة / حساس الدعسة (PID 11): (A * 100) / 255
      SensorPid(
        pid: "11",
        name: "Throttle Position (TPS)",
        nameAr: "فتحة البوابة (حساس الدعسة)",
        unit: "%",
        min: 0,
        max: 100,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      // تصحيح الوقود اللحظي (PID 06): (A - 128) * 100 / 128
      SensorPid(
        pid: "06",
        name: "Short Term Fuel Trim B1",
        nameAr: "تصحيح الوقود اللحظي (STFT)",
        unit: "%",
        min: -30,
        max: 30,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? ((bytes[0] - 128.0) * 100.0) / 128.0 : 0.0,
      ),

      // تصحيح الوقود التراكمي (PID 07): (A - 128) * 100 / 128
      SensorPid(
        pid: "07",
        name: "Long Term Fuel Trim B1",
        nameAr: "تصحيح الوقود التراكمي (LTFT)",
        unit: "%",
        min: -30,
        max: 30,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? ((bytes[0] - 128.0) * 100.0) / 128.0 : 0.0,
      ),

      // ضغط المانيفولد (حساس الماب) (PID 0B): A
      SensorPid(
        pid: "0B",
        name: "Intake Manifold Pressure (MAP)",
        nameAr: "ضغط المانيفولد (حساس الماب)",
        unit: "kPa",
        min: 0,
        max: 255,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? bytes[0].toDouble() : 0.0,
      ),

      // تدفق الهواء (حساس الماف) (PID 10): ((A * 256) + B) / 100
      SensorPid(
        pid: "10",
        name: "MAF Air Flow Rate",
        nameAr: "تدفق الهواء (حساس الماف)",
        unit: "g/s",
        min: 0,
        max: 200,
        category: "FuelAir",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 100.0;
        },
      ),

      // حرارة الهواء الداخل (PID 0F): A - 40
      SensorPid(
        pid: "0F",
        name: "Intake Air Temp (IAT)",
        nameAr: "حرارة الهواء الداخل",
        unit: "°C",
        min: -40,
        max: 100,
        category: "Cooling",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] - 40).toDouble() : 0.0,
      ),

      // حساس الشكمان الأمامي (PID 14): A / 200 (فولت)
      SensorPid(
        pid: "14",
        name: "O2 Sensor 1 Voltage",
        nameAr: "حساس الشكمان الأمامي (B1S1)",
        unit: "V",
        min: 0.0,
        max: 1.1,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? bytes[0] / 200.0 : 0.0,
      ),

      // حساس الشكمان الخلفي (PID 15): A / 200 (فولت)
      SensorPid(
        pid: "15",
        name: "O2 Sensor 2 Voltage",
        nameAr: "حساس الشكمان الخلفي (B1S2)",
        unit: "V",
        min: 0.0,
        max: 1.1,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? bytes[0] / 200.0 : 0.0,
      ),

      // فولت الكونترول (PID 42): ((A * 256) + B) / 1000
      SensorPid(
        pid: "42",
        name: "Control Module Voltage",
        nameAr: "فولت تغذية الكونترول",
        unit: "V",
        min: 9.0,
        max: 16.0,
        category: "Electrical",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 1000.0;
        },
      ),

      // حمل المحرك النسبي (PID 04): (A * 100) / 255
      SensorPid(
        pid: "04",
        name: "Calculated Engine Load",
        nameAr: "حمل المحرك النسبي",
        unit: "%",
        min: 0,
        max: 100,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      // حرارة زيت الفتيس الأوتوماتيك / CVT / DSG (PID 2101): A - 40
      SensorPid(
        pid: "01",
        mode: "21",
        name: "Transmission Fluid Temp",
        nameAr: "حرارة زيت الفتيس",
        unit: "°C",
        min: -40,
        max: 160,
        category: "Transmission",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] - 40).toDouble() : 0.0,
      ),

      // سرعة العجلة الأمامية يسار (FL)
      SensorPid(
        pid: "01",
        mode: "22",
        name: "Wheel Speed Front-Left (FL)",
        nameAr: "سرعة العجلة الأمامية يسار (FL)",
        unit: "km/h",
        min: 0,
        max: 260,
        category: "ABS Speeds",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 16.0;
        },
      ),

      // سرعة العجلة الأمامية يمين (FR)
      SensorPid(
        pid: "02",
        mode: "22",
        name: "Wheel Speed Front-Right (FR)",
        nameAr: "سرعة العجلة الأمامية يمين (FR)",
        unit: "km/h",
        min: 0,
        max: 260,
        category: "ABS Speeds",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 16.0;
        },
      ),

      // سرعة العجلة الخلفية يسار (RL)
      SensorPid(
        pid: "03",
        mode: "22",
        name: "Wheel Speed Rear-Left (RL)",
        nameAr: "سرعة العجلة الخلفية يسار (RL)",
        unit: "km/h",
        min: 0,
        max: 260,
        category: "ABS Speeds",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 16.0;
        },
      ),

      // سرعة العجلة الخلفية يمين (RR)
      SensorPid(
        pid: "04",
        mode: "22",
        name: "Wheel Speed Rear-Right (RR)",
        nameAr: "سرعة العجلة الخلفية يمين (RR)",
        unit: "km/h",
        min: 0,
        max: 260,
        category: "ABS Speeds",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 16.0;
        },
      ),

      // ضغط مسطرة الوقود الفعلي (Common Rail Fuel Pressure Actual)
      SensorPid(
        pid: "23",
        mode: "01",
        name: "Fuel Rail Pressure (Actual)",
        nameAr: "ضغط مسطرة الوقود الفعلي",
        unit: "bar",
        min: 0,
        max: 2200,
        category: "Fuel & Turbo",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) * 0.1;
        },
      ),

      // ضغط مسطرة الوقود المستهدف (Common Rail Target)
      SensorPid(
        pid: "24",
        mode: "01",
        name: "Fuel Rail Pressure (Target)",
        nameAr: "ضغط مسطرة الوقود المستهدف",
        unit: "bar",
        min: 0,
        max: 2200,
        category: "Fuel & Turbo",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) * 0.1;
        },
      ),

      // ضغط شاحن التوربو الفعلي (Turbo Boost Actual)
      SensorPid(
        pid: "70",
        mode: "01",
        name: "Turbo Boost Pressure (Actual)",
        nameAr: "ضغط التوربو الفعلي",
        unit: "bar",
        min: 0.0,
        max: 3.5,
        category: "Fuel & Turbo",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0] / 100.0 : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 1000.0;
        },
      ),

      // ضغط شاحن التوربو المستهدف (Turbo Boost Target)
      SensorPid(
        pid: "71",
        mode: "01",
        name: "Turbo Boost Pressure (Target)",
        nameAr: "ضغط التوربو المستهدف",
        unit: "bar",
        min: 0.0,
        max: 3.5,
        category: "Fuel & Turbo",
        decoder: (bytes) {
          if (bytes.length < 2) return bytes.isNotEmpty ? bytes[0] / 100.0 : 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 1000.0;
        },
      ),
    ];
  }
}
