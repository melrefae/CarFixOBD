/// Vehicle I/M Readiness Monitors (Mode 01 PID 01)
/// Essential for emissions inspection and pre-purchase vehicle verification
class MonitorStatus {
  final String nameEn;
  final String nameAr;
  final bool isAvailable;
  final bool isComplete;
  final String explanationAr;
  final String explanationEn;

  MonitorStatus({
    required this.nameEn,
    required this.nameAr,
    required this.isAvailable,
    required this.isComplete,
    required this.explanationAr,
    required this.explanationEn,
  });

  String get name => nameEn;
  String get explanation => explanationEn;
  bool get isReady => isComplete;
}

class ReadinessMonitors {
  final bool milOn;
  final int dtcCount;
  final List<MonitorStatus> monitors;

  ReadinessMonitors({
    required this.milOn,
    required this.dtcCount,
    required this.monitors,
  });

  /// Decode Mode 01 PID 01 payload bytes (4 bytes: A, B, C, D)
  factory ReadinessMonitors.fromBytes(List<int> bytes) {
    if (bytes.length < 4) {
      return ReadinessMonitors(milOn: false, dtcCount: 0, monitors: []);
    }

    final byteA = bytes[0];
    final byteB = bytes[1];
    final byteC = bytes[2];
    final byteD = bytes[3];

    final milOn = (byteA & 0x80) != 0;
    final dtcCount = byteA & 0x7F;

    final List<MonitorStatus> list = [
      // Continuous Monitors (Byte B)
      MonitorStatus(
        nameEn: "Misfire Monitor",
        nameAr: "مراقبة فقد الإشعال (Misfire)",
        isAvailable: (byteB & 0x01) != 0,
        isComplete: (byteB & 0x10) == 0,
        explanationAr: "مراقبة مستمرة لرصد أي تنتيشة أو غياب حريق بالسلندرات.",
        explanationEn: "Continuous monitoring for cylinder ignition misfires and crankshaft deceleration.",
      ),
      MonitorStatus(
        nameEn: "Fuel System Monitor",
        nameAr: "مراقبة دورة الوقود (Fuel System)",
        isAvailable: (byteB & 0x02) != 0,
        isComplete: (byteB & 0x20) == 0,
        explanationAr: "مراقبة توازن نسب الهواء والبنزين وحلقة التحكم المغلقة (Closed Loop).",
        explanationEn: "Continuous monitoring of air-fuel feedback trims and closed loop fuel control.",
      ),
      MonitorStatus(
        nameEn: "Comprehensive Component",
        nameAr: "مراقبة المكونات الشاملة (Sensors)",
        isAvailable: (byteB & 0x04) != 0,
        isComplete: (byteB & 0x40) == 0,
        explanationAr: "فحص مستمر لجميع الحساسات الكهربائية (TPS, ECT, MAP...).",
        explanationEn: "Continuous electrical and rational check of engine powertrain sensors and actuators.",
      ),

      // Non-Continuous Monitors (Bytes C & D)
      MonitorStatus(
        nameEn: "Catalyst Monitor",
        nameAr: "اختبار علبة البيئة (Catalyst)",
        isAvailable: (byteC & 0x01) != 0,
        isComplete: (byteD & 0x01) == 0,
        explanationAr: "فحص كفاءة التحويل الكيميائي لغازات العادم بعلبة البيئة.",
        explanationEn: "Evaluates catalytic converter oxygen storage efficiency against exhaust emissions standards.",
      ),
      MonitorStatus(
        nameEn: "Evaporative System",
        nameAr: "اختبار تبخير التانك (EVAP)",
        isAvailable: (byteC & 0x04) != 0,
        isComplete: (byteD & 0x04) == 0,
        explanationAr: "فحص عدم وجود تسريب لأبخرة البنزين من التانك والكانستر.",
        explanationEn: "Inspects fuel tank vapor leaks and EVAP canister purge flow integrity.",
      ),
      MonitorStatus(
        nameEn: "Oxygen Sensor Monitor",
        nameAr: "اختبار حساسات الشكمان (O2 Sensor)",
        isAvailable: (byteC & 0x20) != 0,
        isComplete: (byteD & 0x20) == 0,
        explanationAr: "اختبار سرعة استجابة وتردد حساسات الأكسجين الأمامية والخلفية.",
        explanationEn: "Verifies O2 sensor voltage oscillation rate, response time, and switching frequency.",
      ),
      MonitorStatus(
        nameEn: "Oxygen Sensor Heater",
        nameAr: "سخان حساس الشكمان (O2 Heater)",
        isAvailable: (byteC & 0x40) != 0,
        isComplete: (byteD & 0x40) == 0,
        explanationAr: "فحص سلامة سخانات حساسات الشكمان للوصول السريع لدرجة العمل.",
        explanationEn: "Checks the internal resistance and heating element circuit of heated oxygen sensors.",
      ),
      MonitorStatus(
        nameEn: "EGR / VVT System",
        nameAr: "منظومة تدوير العادم والصمامات (EGR/VVT)",
        isAvailable: (byteC & 0x80) != 0,
        isComplete: (byteD & 0x80) == 0,
        explanationAr: "فحص بلف EGR وصمامات التحكم في توقيت الكامات المتغير VVT.",
        explanationEn: "Tests exhaust gas recirculation flow rates and variable valve timing actuator response.",
      ),
    ];

    return ReadinessMonitors(milOn: milOn, dtcCount: dtcCount, monitors: list);
  }
}
