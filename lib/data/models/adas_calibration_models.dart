/// ADAS Target Board Placement Coordinates Model
class AdasTargetPlacement {
  final String systemName;
  final String brandPlatform;
  final int distanceFromFrontAxleMm;
  final int distanceFromBumperMm;
  final int heightFromGroundMm;
  final int lateralOffsetMm;
  final String targetPatternType;
  final String notesEn;
  final String notesAr;

  const AdasTargetPlacement({
    required this.systemName,
    required this.brandPlatform,
    required this.distanceFromFrontAxleMm,
    required this.distanceFromBumperMm,
    required this.heightFromGroundMm,
    required this.lateralOffsetMm,
    required this.targetPatternType,
    required this.notesEn,
    required this.notesAr,
  });

  static List<AdasTargetPlacement> getAllPresets() {
    return [
      const AdasTargetPlacement(
        systemName: "Front Windshield Camera (Lane Keep)",
        brandPlatform: "Toyota / Lexus (TSS 2.0 / 3.0)",
        distanceFromFrontAxleMm: 3000,
        distanceFromBumperMm: 1600,
        heightFromGroundMm: 1250,
        lateralOffsetMm: 0,
        targetPatternType: "Dual Round High-Contrast Circles (Target Board A)",
        notesEn: "Park vehicle on level ground. Ensure tire pressures are nominal and fuel tank is full. Align center laser with vehicle emblem.",
        notesAr: "أوقف السيارة على أرض مستوية تماماً. تأكد من ضغط الإطارات وضبط خط الليزر مع منتصف علامة السيارة.",
      ),
      const AdasTargetPlacement(
        systemName: "Front Bumper Radar (Adaptive Cruise ACC)",
        brandPlatform: "VAG Group (VW / Skoda / Audi)",
        distanceFromFrontAxleMm: 1200,
        distanceFromBumperMm: 800,
        heightFromGroundMm: 480,
        lateralOffsetMm: 0,
        targetPatternType: "Trihedral Doppler Corner Reflector Target",
        notesEn: "Level radar sensor bubble level to 0.0°. Use 4mm hex socket adjuster to zero mechanical pitch and yaw screws.",
        notesAr: "اضبط ميزان مياه الرادار على 0.0 درجة بواسطة مفتاح ألن 4 مم لضبط زوايا الميل الأفقية والرأسية.",
      ),
      const AdasTargetPlacement(
        systemName: "Front Monocular Camera",
        brandPlatform: "Hyundai / Kia (SmartSense)",
        distanceFromFrontAxleMm: 2800,
        distanceFromBumperMm: 1450,
        heightFromGroundMm: 1300,
        lateralOffsetMm: 0,
        targetPatternType: "Triple Checkerboard Target Board",
        notesEn: "Ensure windshield camera bracket is locked. Avoid direct high-intensity sunlight shining directly into the camera lens.",
        notesAr: "تأكد من إحكام تثبيت الكاميرا في الزجاج وتجنب أشعة الشمس المباشرة الحادة في عدسة الكاميرا أثناء المعايرة.",
      ),
      const AdasTargetPlacement(
        systemName: "Front Radar & Camera Fusion",
        brandPlatform: "Chery / MG / Haval Pilot",
        distanceFromFrontAxleMm: 2500,
        distanceFromBumperMm: 1350,
        heightFromGroundMm: 1100,
        lateralOffsetMm: 0,
        targetPatternType: "Standard Optical High-Contrast Pattern",
        notesEn: "Calibrate steering angle sensor zero-point before commencing optical camera alignment routine.",
        notesAr: "قم بمعايرة نقطة الصفر لحساس زاوية الدريكسيون SAS قبل بدء ضبط لوحة الكاميرا.",
      ),
    ];
  }
}

/// Digital Laser Level Alignment (Pitch, Roll, Yaw)
class AdasLaserLevel {
  final double pitchAngleDeg;
  final double rollAngleDeg;
  final double yawAngleDeg;

  const AdasLaserLevel({
    this.pitchAngleDeg = 0.15,
    this.rollAngleDeg = -0.05,
    this.yawAngleDeg = 0.20,
  });

  bool get isAligned =>
      pitchAngleDeg.abs() <= 0.5 &&
      rollAngleDeg.abs() <= 0.5 &&
      yawAngleDeg.abs() <= 0.5;
}

/// Dynamic Road Test Calibration Step Model
class DynamicRoadCalibrationStep {
  final int stepNumber;
  final String titleEn;
  final String titleAr;
  final String instructionEn;
  final String instructionAr;
  final int targetSpeedKmH;
  final int progressPercent;
  final bool isCompleted;

  const DynamicRoadCalibrationStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleAr,
    required this.instructionEn,
    required this.instructionAr,
    required this.targetSpeedKmH,
    required this.progressPercent,
    this.isCompleted = false,
  });

  static List<DynamicRoadCalibrationStep> getDefaultSteps() {
    return const [
      DynamicRoadCalibrationStep(
        stepNumber: 1,
        titleEn: "Pre-Drive Sensor Initialization",
        titleAr: "التهيئة المسبقة للحساسات قبل القيادة",
        instructionEn: "Turn ignition ON. Clear all pre-existing DTCs. Verify camera lens and radar dome are completely clean and dry.",
        instructionAr: "افتح الكونتاكت وامسح كافة الأعطال السابقة. تأكد من نظافة زجاج الكاميرا ورادار الإكصدام تماماً.",
        targetSpeedKmH: 0,
        progressPercent: 25,
        isCompleted: true,
      ),
      DynamicRoadCalibrationStep(
        stepNumber: 2,
        titleEn: "Straight Lane Markings Acquisition",
        titleAr: "التقاط خطوط الحارة المرورية المستقيمة",
        instructionEn: "Drive vehicle on highway or straight road with visible white/yellow lane markings at steady 50-70 km/h.",
        instructionAr: "قم بقيادة السيارة على طريق مستقيم بخطوط بيضاء أو صفراء واضحة بسرعة ثابتة بين 50 إلى 70 كم/س.",
        targetSpeedKmH: 60,
        progressPercent: 55,
      ),
      DynamicRoadCalibrationStep(
        stepNumber: 3,
        titleEn: "Lead Vehicle Radar Target Tracking",
        titleAr: "تتبع ومزامنة السيارة الأمامية بالرادار",
        instructionEn: "Follow a vehicle ahead at 30-50 meters distance. Radar builds reflection map and calculates millimeter-wave phase offset.",
        instructionAr: "اتبع سيارة أمامك على مسافة 30 إلى 50 متراً ليقوم الرادار ببناء خريطة الانعكاس وحساب زوايا التتبع.",
        targetSpeedKmH: 60,
        progressPercent: 85,
      ),
      DynamicRoadCalibrationStep(
        stepNumber: 4,
        titleEn: "Learning Confirmation & EEPROM Save",
        titleAr: "تأكيد المعايرة وحفظ المعاملات بالذاكرة",
        instructionEn: "Camera and radar report 'CALIBRATION_COMPLETED'. Safe stopping and key cycle to commit parameters to non-volatile memory.",
        instructionAr: "ظهور رسالة اكتمال المعايرة بنجاح. أوقف السيارة وأغلق المفتاح لتثبيت المعاملات في الذاكرة الدائمة.",
        targetSpeedKmH: 0,
        progressPercent: 100,
      ),
    ];
  }
}
