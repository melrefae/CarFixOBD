import 'vehicle_profile.dart';

/// فئة تمثل حساس OBD (Parameter ID - PID) ومعادلة فك تشفيره وقيمته اللحظية
class SensorPid {
  final String pid;
  final String mode;
  final String name;
  final String nameAr;
  final String unit;
  final double min;
  final double max;
  final String category; // Engine, FuelAir, Cooling, Electrical, Transmission, Custom
  final double Function(List<int> bytes) decoder;
  final bool isCustom;

  double currentValue;
  double get numValue => currentValue;
  double get value => currentValue;
  final List<double> history; // سجل القياسات الأخيرة للرسم البياني اللحظي
  bool isSelected;
  bool hasValidReading;
  bool isSupported;
  DateTime? lastUpdated;

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
    this.hasValidReading = false,
    this.isSupported = true,
    this.lastUpdated,
    this.isCustom = false,
  }) : history = history ?? [];

  /// تحديث القيمة اللحظية وإضافتها لسجل الرسم البياني
  void updateValue(double newValue) {
    currentValue = newValue;
    hasValidReading = true;
    isSupported = true;
    lastUpdated = DateTime.now();
    history.add(newValue);
    if (history.length > 50) {
      history.removeAt(0); // الاحتفاظ بآخر 50 قراءة للرسم اللحظي السلس
    }
  }

  /// Reset live reading validity upon disconnect/reconnect
  void resetReading() {
    currentValue = 0.0;
    hasValidReading = false;
    isSupported = true;
    lastUpdated = null;
    history.clear();
  }

  /// فك تشفير البايتات المستلمة
  bool decodeAndUpdate(List<int> bytes) {
    try {
      if (bytes.isEmpty) return false;
      final val = decoder(bytes);
      if (val.isNaN || val.isInfinite) return false;
      updateValue(val);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Create a SensorPid dynamically from a vehicle profile CustomPid
  factory SensorPid.fromCustomPid(CustomPid custom) {
    final cleanNameEn = custom.getDisplayName(false);
    final cleanNameAr = custom.name.isNotEmpty ? custom.name : cleanNameEn;
    return SensorPid(
      pid: custom.pid.toUpperCase().trim(),
      mode: custom.mode.toUpperCase().trim(),
      name: cleanNameEn,
      nameAr: cleanNameAr,
      unit: custom.unit,
      min: custom.min,
      max: custom.max,
      category: "Custom",
      isCustom: true,
      decoder: (bytes) => evaluateFormula(custom.formula, bytes),
    );
  }

  /// Safe arithmetic formula evaluator for OEM custom PIDs (`A`, `B`, `C`, `D` + `+ - * / ( )`)
  static double evaluateFormula(String formula, List<int> bytes) {
    final expr = formula.trim();
    if (expr.isEmpty) return bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;

    final a = bytes.isNotEmpty ? bytes[0].toDouble() : 0.0;
    final b = bytes.length > 1 ? bytes[1].toDouble() : 0.0;
    final c = bytes.length > 2 ? bytes[2].toDouble() : 0.0;
    final d = bytes.length > 3 ? bytes[3].toDouble() : 0.0;

    final parser = _FormulaParser(expr, a: a, b: b, c: c, d: d);
    return parser.parseExpression();
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

      // توقيت الشرارة / الإشعال (PID 0E): (A / 2) - 64
      SensorPid(
        pid: "0E",
        name: "Timing Advance",
        nameAr: "توقيت الإشعال (الأفانس)",
        unit: "°",
        min: -64,
        max: 63.5,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] / 2.0) - 64.0 : 0.0,
      ),

      // مستوى الوقود بالتانك (PID 2F): (A * 100) / 255
      SensorPid(
        pid: "2F",
        name: "Fuel Tank Level",
        nameAr: "مستوى الوقود بالخزان",
        unit: "%",
        min: 0,
        max: 100,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      // الضغط الجوي (PID 33): A
      SensorPid(
        pid: "33",
        name: "Barometric Pressure",
        nameAr: "الضغط الجوي المحيط",
        unit: "kPa",
        min: 0,
        max: 255,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? bytes[0].toDouble() : 0.0,
      ),

      // حرارة زيت المحرك (PID 5C): A - 40
      SensorPid(
        pid: "5C",
        name: "Engine Oil Temperature",
        nameAr: "حرارة زيت المحرك",
        unit: "°C",
        min: -40,
        max: 160,
        category: "Cooling",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] - 40).toDouble() : 0.0,
      ),

      // درجة حرارة الجو المحيط (PID 46): A - 40
      SensorPid(
        pid: "46",
        name: "Ambient Air Temperature",
        nameAr: "حرارة الجو الخارجي",
        unit: "°C",
        min: -40,
        max: 80,
        category: "Cooling",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] - 40).toDouble() : 0.0,
      ),

      // حرارة علبة البيئة / الحفاز (PID 3C): ((A * 256 + B) / 10) - 40
      SensorPid(
        pid: "3C",
        name: "Catalyst Temp Bank 1 S1",
        nameAr: "حرارة علبة البيئة",
        unit: "°C",
        min: -40,
        max: 1000,
        category: "Cooling",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return (((bytes[0] * 256) + bytes[1]) / 10.0) - 40.0;
        },
      ),

      // معدل استهلاك الوقود اللحظي من ECU (PID 5E): ((A * 256) + B) / 20
      SensorPid(
        pid: "5E",
        name: "Engine Fuel Rate",
        nameAr: "معدل استهلاك البنزين",
        unit: "L/h",
        min: 0,
        max: 60,
        category: "FuelAir",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]) / 20.0;
        },
      ),

      // نسبة المكافئ المستهدفة (PID 44): ((A * 256) + B) * 2 / 65535
      SensorPid(
        pid: "44",
        name: "Commanded Lambda Ratio",
        nameAr: "نسبة خليط الهواء والبنزين (Lambda)",
        unit: "λ",
        min: 0.5,
        max: 2.0,
        category: "FuelAir",
        decoder: (bytes) {
          if (bytes.length < 2) return 1.0;
          return (((bytes[0] * 256) + bytes[1]) * 2.0) / 65535.0;
        },
      ),

      // بلف التبخير EGR / EVAP Purge (PID 2E & 2C & 32)
      SensorPid(
        pid: "2C",
        name: "Commanded EGR",
        nameAr: "نسبة فتح بلف EGR",
        unit: "%",
        min: 0,
        max: 100,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      SensorPid(
        pid: "2E",
        name: "Commanded EVAP Purge",
        nameAr: "نسبة فتح بلف الكانيستر EVAP",
        unit: "%",
        min: 0,
        max: 100,
        category: "FuelAir",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      // وضعية بدال البنزين D (PID 49): A * 100 / 255
      SensorPid(
        pid: "49",
        name: "Accelerator Pedal Pos D",
        nameAr: "حساس بدال البنزين",
        unit: "%",
        min: 0,
        max: 100,
        category: "Engine",
        decoder: (bytes) => bytes.isNotEmpty ? (bytes[0] * 100.0) / 255.0 : 0.0,
      ),

      // زمن تشغيل المحرك بالثواني (PID 1F)
      SensorPid(
        pid: "1F",
        name: "Run Time Since Engine Start",
        nameAr: "زمن تشغيل المحرك",
        unit: "s",
        min: 0,
        max: 65535,
        category: "Engine",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]).toDouble();
        },
      ),

      // المسافة المقطوعة منذ مسح الأعطال (PID 31)
      SensorPid(
        pid: "31",
        name: "Distance Since DTCs Cleared",
        nameAr: "المسافة بعد مسح الأعطال",
        unit: "km",
        min: 0,
        max: 65535,
        category: "Engine",
        decoder: (bytes) {
          if (bytes.length < 2) return 0.0;
          return ((bytes[0] * 256) + bytes[1]).toDouble();
        },
      ),

      // عداد الكيلومترات القياسي PID A6
      SensorPid(
        pid: "A6",
        name: "OBD-II Odometer",
        nameAr: "عداد المسافات القياسي (OBD)",
        unit: "km",
        min: 0,
        max: 999999,
        category: "Engine",
        isSelected: false,
        decoder: (bytes) {
          if (bytes.length < 4) return 0.0;
          final raw = (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
          return raw / 10.0;
        },
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

class _FormulaParser {
  final String input;
  final double a;
  final double b;
  final double c;
  final double d;
  int _pos = 0;

  _FormulaParser(this.input, {required this.a, required this.b, required this.c, required this.d});

  void _skipWhitespace() {
    while (_pos < input.length && input[_pos].trim().isEmpty) {
      _pos++;
    }
  }

  double parseExpression() {
    var left = parseTerm();
    while (true) {
      _skipWhitespace();
      if (_pos >= input.length) break;
      final ch = input[_pos];
      if (ch == '+') {
        _pos++;
        left += parseTerm();
      } else if (ch == '-') {
        _pos++;
        left -= parseTerm();
      } else {
        break;
      }
    }
    return left;
  }

  double parseTerm() {
    var left = parseFactor();
    while (true) {
      _skipWhitespace();
      if (_pos >= input.length) break;
      final ch = input[_pos];
      if (ch == '*') {
        _pos++;
        left *= parseFactor();
      } else if (ch == '/') {
        _pos++;
        final rhs = parseFactor();
        left = rhs == 0 ? 0.0 : left / rhs;
      } else {
        break;
      }
    }
    return left;
  }

  double parseFactor() {
    _skipWhitespace();
    if (_pos >= input.length) return 0.0;

    final ch = input[_pos];
    if (ch == '+') {
      _pos++;
      return parseFactor();
    }
    if (ch == '-') {
      _pos++;
      return -parseFactor();
    }
    if (ch == '(') {
      _pos++;
      final val = parseExpression();
      _skipWhitespace();
      if (_pos < input.length && input[_pos] == ')') {
        _pos++;
      }
      return val;
    }

    final upperCh = ch.toUpperCase();
    if (upperCh == 'A') {
      _pos++;
      return a;
    }
    if (upperCh == 'B') {
      _pos++;
      return b;
    }
    if (upperCh == 'C') {
      _pos++;
      return c;
    }
    if (upperCh == 'D') {
      _pos++;
      return d;
    }

    final start = _pos;
    while (_pos < input.length && (RegExp(r'[0-9.]').hasMatch(input[_pos]))) {
      _pos++;
    }
    if (_pos > start) {
      return double.tryParse(input.substring(start, _pos)) ?? 0.0;
    }
    _pos++;
    return 0.0;
  }
}
