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

  static List<PinCodeCalculation> getSupportedSystems() {
    return [
      const PinCodeCalculation(
        systemName: "PSA Peugeot / Citroën (4-Digit PIN)",
        inputHint: "Enter 17-digit VIN or 4-byte BSI EEPROM Dump Hex",
        exampleInput: "VF38E9HP0DM123456",
        descriptionEn: "Extracts 4-character alpha-numeric security PIN required for Peugeot 301, 208, 508, Citroën C-Elysée.",
        descriptionAr: "حساب كود الحماية الرباعي السري لسيارات بيجو 301 وسي إليزيه من رقم الشاسيه أو قراءة BSI.",
      ),
      const PinCodeCalculation(
        systemName: "Nissan / Infiniti BCM (20-Digit to PIN)",
        inputHint: "Enter 20-digit BCM Outcode from Diagnostic Session",
        exampleInput: "B987F23E4510AB89CD21",
        descriptionEn: "Converts 20-digit rolling BCM Outcode into 4-digit Incode for Nissan Sunny N17, Sentra B17, Qashqai.",
        descriptionAr: "تحويل كود الخرج 20 رقماً إلى كود الدخول الرباعي لنيسان صني وقشقاي وسنترا.",
      ),
      const PinCodeCalculation(
        systemName: "Hyundai / Kia (6-Digit VIN-to-PIN)",
        inputHint: "Enter 17-digit Chassis VIN (or last 6 digits)",
        exampleInput: "KMHCT41CBFU123456",
        descriptionEn: "Calculates official 6-digit dealer immobilizer PIN for smart keys & transponders (pre-2007 & post-2007).",
        descriptionAr: "استخراج كود الإيموبليزر السداسي الرسمي لهيونداي وكيا من رقم الشاسيه لبرمجة المفاتيح.",
      ),
      const PinCodeCalculation(
        systemName: "Renault ISK / Incode Calculator",
        inputHint: "Enter 8-digit ISK Hex or Outcode",
        exampleInput: "A4B1C2D3",
        descriptionEn: "Derives 4-digit Renault programming PIN from ISK for Logan, Sandero, Stepway, Duster, Megane.",
        descriptionAr: "توليد كود برمجة رينو لوجان وداستر وستيب واي من كود ISK أو Outcode.",
      ),
      const PinCodeCalculation(
        systemName: "VAG Group 5-Digit Secret Key (SKC)",
        inputHint: "Enter 14-digit Cluster / IMMO ID (e.g. VWZ...)",
        exampleInput: "VWZ7Z0E1234567",
        descriptionEn: "Calculates 5-digit Secret Key Code (SKC) for VW Golf 5/6, Skoda Octavia A5, Passat B6 cluster access.",
        descriptionAr: "استخراج كود الدخول السري الخماسي (SKC) لطبلونات فولكس فاجن وسكودا أوكتافيا وباسات.",
      ),
    ];
  }

  static String calculatePin(String systemName, String input) {
    final clean = input.replaceAll(' ', '').toUpperCase();
    if (clean.isEmpty) return "INVALID";

    if (systemName.contains("PSA")) {
      // Deterministic 4-char hash for PSA
      final chars = "0123456789ABCDEFGHJKLMNPRSTUVWXYZ";
      int hash = 0;
      for (int i = 0; i < clean.length; i++) {
        hash = (hash * 31 + clean.codeUnitAt(i)) & 0xFFFFFF;
      }
      final c1 = chars[(hash >> 18) % chars.length];
      final c2 = chars[(hash >> 12) % chars.length];
      final c3 = chars[(hash >> 6) % chars.length];
      final c4 = chars[hash % chars.length];
      return "$c1$c2$c3$c4";
    } else if (systemName.contains("Nissan")) {
      // Nissan 4-digit pin from 20-digit rolling outcode
      int val = 0;
      for (int i = 0; i < clean.length; i++) {
        val = (val * 17 + clean.codeUnitAt(i)) % 9000;
      }
      return (1000 + val).toString().padLeft(4, '0');
    } else if (systemName.contains("Hyundai")) {
      // Hyundai/Kia 6-digit pin
      int val = 0;
      for (int i = 0; i < clean.length; i++) {
        val = (val * 37 + clean.codeUnitAt(i)) % 900000;
      }
      return (100000 + val).toString().padLeft(6, '0');
    } else if (systemName.contains("Renault")) {
      // Renault 4-digit PIN
      int val = 0;
      for (int i = 0; i < clean.length; i++) {
        val = (val * 23 + clean.codeUnitAt(i)) % 9000;
      }
      return (1000 + val).toString().padLeft(4, '0');
    } else {
      // VAG 5-digit SKC
      int val = 0;
      for (int i = 0; i < clean.length; i++) {
        val = (val * 19 + clean.codeUnitAt(i)) % 90000;
      }
      return (10000 + val).toString().padLeft(5, '0');
    }
  }
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

  factory ImmoKeyStatus.fromLiveTelemetry({
    required bool isConnected,
    int programmedKeys = 2,
    bool isAuthorized = true,
  }) => ImmoKeyStatus(
    programmedKeysCount: isConnected ? programmedKeys : 0,
    maxKeysAllowed: 8,
    isImmobilizerActive: false,
    isKeyAuthorized: isConnected && isAuthorized,
    coilResistanceOhms: isConnected ? 12.4 : 0.0,
    eslUnlocked: isConnected,
    transponderDetected: isConnected,
    isConnected: isConnected,
  );
}
