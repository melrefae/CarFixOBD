/// RFID Transponder Chip Information Model
class TransponderChipInfo {
  final String chipType;
  final String chipFamily;
  final String frequency;
  final String keyIdHex;
  final bool isLocked;
  final bool isVirgin;
  final String encryptionType;
  final List<String> compatibleVehicles;
  final Map<String, String> pageData;

  const TransponderChipInfo({
    required this.chipType,
    required this.chipFamily,
    required this.frequency,
    required this.keyIdHex,
    required this.isLocked,
    required this.isVirgin,
    required this.encryptionType,
    required this.compatibleVehicles,
    required this.pageData,
  });

  static List<TransponderChipInfo> getPresetTransponders() {
    return [
      const TransponderChipInfo(
        chipType: "ID46",
        chipFamily: "NXP PCF7936 / Hitag 2",
        frequency: "433.92 MHz",
        keyIdHex: "0x7F4B2901",
        isLocked: false,
        isVirgin: false,
        encryptionType: "Hitag 2 Crypto (48-bit)",
        compatibleVehicles: [
          "Nissan Sunny N17 / Sentra",
          "Renault Logan / Sandero / Duster",
          "Peugeot 301 / 208",
          "Hyundai Elantra MD / Accent RB",
          "Kia Cerato / Rio",
        ],
        pageData: {
          "PG0 (Identifier)": "7F 4B 29 01",
          "PG1 (Password)": "4E 4D 53 45",
          "PG2 (Secret Key)": "A1 B2 C3 D4 E5 F6",
          "PG3 (Configuration)": "0E 00",
        },
      ),
      const TransponderChipInfo(
        chipType: "ID48",
        chipFamily: "Megamos Crypto",
        frequency: "433.92 MHz",
        keyIdHex: "0xA3D9812C",
        isLocked: true,
        isVirgin: false,
        encryptionType: "Megamos Crypto (96-bit)",
        compatibleVehicles: [
          "Volkswagen Golf / Passat / Tiguan",
          "Skoda Octavia A5/A7 / Superb",
          "Audi A3 / A4 / A6",
          "Seat Leon / Ibiza",
          "Fiat Tipo (2016-2024)",
        ],
        pageData: {
          "PG0 (CS Low)": "A3 D9 81 2C",
          "PG1 (CS High)": "88 41 90 2A",
          "PG2 (Secret Key)": "FF FF FF FF",
          "PG3 (Lock Byte)": "AA 55",
        },
      ),
      const TransponderChipInfo(
        chipType: "ID8A",
        chipFamily: "Texas Instruments DST-AES 128-Bit",
        frequency: "433.92 MHz",
        keyIdHex: "0x39E054BA",
        isLocked: false,
        isVirgin: true,
        encryptionType: "AES-128 Encryption",
        compatibleVehicles: [
          "Toyota Corolla (2014-2025)",
          "Toyota Yaris / Fortuner / Hilux",
          "Lexus ES / RX",
          "Subaru BRZ / Forester",
        ],
        pageData: {
          "PG0 (TIRIS ID)": "39 E0 54 BA",
          "PG1 (AES Page 1)": "00 00 00 00 00 00",
          "PG2 (Key Code)": "55 AA 55 AA",
          "PG3 (Status)": "00 (Virgin/Ready)",
        },
      ),
      const TransponderChipInfo(
        chipType: "ID8E",
        chipFamily: "Megamos 8E Glass Transponder",
        frequency: "433.92 MHz",
        keyIdHex: "0x5E10884A",
        isLocked: false,
        isVirgin: false,
        encryptionType: "Megamos 8E Crypto",
        compatibleVehicles: [
          "Honda Civic (2006-2015)",
          "Honda CR-V / Accord",
          "Mazda 3 / 6 (Early Generations)",
        ],
        pageData: {
          "PG0 (ID)": "5E 10 88 4A",
          "PG1 (Sync)": "01 23 45 67",
          "PG2 (Crypto)": "8E 8E 8E 8E",
          "PG3 (Config)": "00 01",
        },
      ),
    ];
  }
}

/// PIN Code Calculator Model & Algorithms
class PinCodeCalculation {
  final String systemName;
  final String inputHint;
  final String exampleInput;
  final String descriptionEn;
  final String descriptionAr;

  const PinCodeCalculation({
    required this.systemName,
    required this.inputHint,
    required this.exampleInput,
    required this.descriptionEn,
    required this.descriptionAr,
  });

  // Fabricated VIN-to-PIN calculation removed: the official algorithms are
  // proprietary, and a guessed PIN can lock a car's immobilizer.
  static List<PinCodeCalculation> getSupportedSystems() => const [];
}

/// Guided Step for Key Learning Wizard
class KeyLearningStep {
  final int stepNumber;
  final String titleEn;
  final String titleAr;
  final String instructionEn;
  final String instructionAr;
  final String commandHex;
  final int durationSeconds;
  bool isCompleted;

  KeyLearningStep({
    required this.stepNumber,
    required this.titleEn,
    required this.titleAr,
    required this.instructionEn,
    required this.instructionAr,
    required this.commandHex,
    required this.durationSeconds,
    this.isCompleted = false,
  });

  static List<KeyLearningStep> getDefaultLearningSteps() {
    return [
      KeyLearningStep(
        stepNumber: 1,
        titleEn: "Pre-Learning Safety & Battery Check",
        titleAr: "فحص الأمان المسبق وجهد البطارية",
        instructionEn: "Ensure vehicle battery voltage is ≥ 12.2V. Connect battery maintainer. Close all vehicle doors and turn hazard emergency flashers ON.",
        instructionAr: "تأكد من أن جهد بطارية السيارة 12.2 فولت على الأقل. أغلق جميع الأبواب وشغّل إشارات الانتظار الرباعية.",
        commandHex: "01 42",
        durationSeconds: 3,
      ),
      KeyLearningStep(
        stepNumber: 2,
        titleEn: "UDS Security Access Seed/Key Handshake",
        titleAr: "مصافحة الأمان المشفرة لطلب مفتاح الصلاحية",
        instructionEn: "Requesting security access level 01 from immobilizer/BCM gateway. Calculating crypto response key and unlocking EEPROM authorization.",
        instructionAr: "طلب مستوى الوصول الأمني 01 من كمبيوتر الإيموبليزر وفك تشفير الصلاحية لكتابة الشريحة.",
        commandHex: "27 01",
        durationSeconds: 4,
      ),
      KeyLearningStep(
        stepNumber: 3,
        titleEn: "Ignition Antenna Coil Transponder Read",
        titleAr: "قراءة شريحة المفتاح عبر هوائي مفتاح الإشعال",
        instructionEn: "Insert Key #1 into the ignition slot. Switch ignition ON for 5 seconds. The immobilizer antenna coil reads the transponder chip ID.",
        instructionAr: "ضع المفتاح رقم 1 في كونتاكت الإشعال. افتح الكونتاكت لمدة 5 ثوانٍ ليقرأ ملف الهوائي شريحة المفتاح.",
        commandHex: "22 F1 90",
        durationSeconds: 5,
      ),
      KeyLearningStep(
        stepNumber: 4,
        titleEn: "Write Transponder ID to Immobilizer Memory",
        titleAr: "كتابة وحفظ معرف الشريحة في ذاكرة الإيموبليزر",
        instructionEn: "Writing the validated transponder crypto ID into the vehicle's non-volatile BCM/IMMO EEPROM table.",
        instructionAr: "برمجة وحفظ شفرة المفتاح في جدول المفاتيح المعتمدة بذاكرة كمبيوتر السيارة BCM/IMMO.",
        commandHex: "2E F1 A0",
        durationSeconds: 4,
      ),
      KeyLearningStep(
        stepNumber: 5,
        titleEn: "Engine Start Authorization & Final Verification",
        titleAr: "التحقق النهائي واختبار تصريح تشغيل المحرك",
        instructionEn: "Switch ignition OFF, wait 5 seconds, then crank and start the engine. Verify the immobilizer key light turns OFF on instrument cluster.",
        instructionAr: "أغلق الكونتاكت 5 ثوانٍ ثم شغّل المحرك. تأكد من انطفاء لمبة مفتاح الإيموبليزر في لوحة العدادات.",
        commandHex: "22 01 00",
        durationSeconds: 3,
      ),
    ];
  }
}

/// Anti-Theft IMMO Live Diagnostic Status
class ImmoKeyStatus {
  final int programmedKeysCount;
  final int maxKeysAllowed;
  final bool isImmobilizerActive;
  final bool isKeyAuthorized;
  final double coilResistanceOhms;
  final bool eslUnlocked;
  final bool transponderDetected;
  final TransponderChipInfo? activeTransponder;
  final bool isConnected;

  const ImmoKeyStatus({
    this.programmedKeysCount = 0,
    this.maxKeysAllowed = 8,
    this.isImmobilizerActive = false,
    this.isKeyAuthorized = false,
    this.coilResistanceOhms = 0.0,
    this.eslUnlocked = false,
    this.transponderDetected = false,
    this.activeTransponder,
    this.isConnected = false,
  });

  const ImmoKeyStatus.disconnected()
      : programmedKeysCount = 0,
        maxKeysAllowed = 8,
        isImmobilizerActive = false,
        isKeyAuthorized = false,
        coilResistanceOhms = 0.0,
        eslUnlocked = false,
        transponderDetected = false,
        activeTransponder = null,
        isConnected = false;

  /// Nothing is read from the car here, so no values are invented:
  /// keys, authorization, coil resistance and transponder are reported as not read (0/false).
  factory ImmoKeyStatus.fromLiveTelemetry({
    required bool isConnected,
    int programmedKeys = 0,
    bool isAuthorized = false,
  }) => ImmoKeyStatus(
    programmedKeysCount: 0,
    maxKeysAllowed: 8,
    isImmobilizerActive: false,
    isKeyAuthorized: false,
    coilResistanceOhms: 0.0,
    eslUnlocked: false,
    transponderDetected: false,
    isConnected: isConnected,
  );
}
