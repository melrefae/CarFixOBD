/// Security Gateway (SGW) Pinout Specification
class SgwPinout {
  final String connectorName; // e.g. "12-Pin Plug" or "8-Pin Plug"
  final int pinNumber;
  final String wireColor;
  final String signalName;
  final String description;

  const SgwPinout({
    required this.connectorName,
    required this.pinNumber,
    required this.wireColor,
    required this.signalName,
    required this.description,
  });
}

/// Vehicle Security Gateway Bypass Guide Model
class SgwVehicleGuide {
  final String id;
  final String vehicleName;
  final String vehicleNameAr;
  final String brand;
  final String years;
  final String sgwType;
  final String location;
  final String locationAr;
  final String harnessCable;
  final String harnessCableAr;
  final List<String> symptoms;
  final List<String> symptomsAr;
  final List<String> procedureSteps;
  final List<String> procedureStepsAr;
  final List<SgwPinout> pinouts;

  const SgwVehicleGuide({
    required this.id,
    required this.vehicleName,
    required this.vehicleNameAr,
    required this.brand,
    required this.years,
    required this.sgwType,
    required this.location,
    required this.locationAr,
    required this.harnessCable,
    required this.harnessCableAr,
    required this.symptoms,
    required this.symptomsAr,
    required this.procedureSteps,
    required this.procedureStepsAr,
    required this.pinouts,
  });

  /// Comprehensive guide database for FCA, Renault, and Nissan SGW models in Egypt
  static const List<SgwVehicleGuide> catalog = [
    SgwVehicleGuide(
      id: "fiat_tipo_sgw",
      vehicleName: "Fiat Tipo / Egea (SGW 12+8)",
      vehicleNameAr: "فيات تيبو / إيجيا (حماية البوابة 12+8)",
      brand: "Fiat",
      years: "2018-2026",
      sgwType: "FCA SGW 12+8 Pin",
      location: "Under driver steering column, behind lower dashboard fuse box trim.",
      locationAr: "أسفل عمود الدركسيون للسائق، خلف فيشة الفيوزات بالتابلوه الداخلي.",
      harnessCable: "FCA 12+8 SGW Universal Bypass Harness",
      harnessCableAr: "كابل تخطي حماية فيات وكرايسلر 12+8 بن القياسي",
      symptoms: [
        "Read Engine/ABS DTCs is ALLOWED",
        "Clear Fault Codes (0x14) REJECTED (Negative Response: 0x33 Security Access Denied)",
        "Service Resets & Throttle Re-learn BLOCKED",
        "Actuator Component Tests BLOCKED",
      ],
      symptomsAr: [
        "قراءة أعطال المحرك والـ ABS مسموحة",
        "مسح الأعطال (كود 14) مرفوض تماماً بكود الخطأ 33 (الحماية مقفولة)",
        "ريست الصيانة وضبط البوابة الإلكترونية مرفوض",
        "اختبارات تشغيل المراوح والرشاشات ومضخة البنزين محظورة",
      ],
      procedureSteps: [
        "1. Turn ignition OFF and remove key fob.",
        "2. Remove the 2 Phillips screws under driver lower dash knee bolster.",
        "3. Locate the SGW security module (small silver/black box with 12-pin and 8-pin plugs).",
        "4. Unclip OEM 12-pin (CAN-C) and 8-pin (CAN-IHS) connectors from module.",
        "5. Plug the 12+8 bypass harness directly into the OEM vehicle harness plugs.",
        "6. Connect the 16-pin OBD2 female end to your OBD scanner / VCI.",
        "7. Turn ignition ON (Engine OFF). Now you have 100% full bidirectional access!",
      ],
      procedureStepsAr: [
        "1. إطفاء الكونتاك تماماً وسحب المفتاح.",
        "2. فك مسمارين غطاء التابلوه السفلي تحت دركسيون السائق.",
        "3. تحديد موقع كنترول السيكيورتي جيت واي (علبة سوداء/فضية بفيشتين 12 بن و8 بن).",
        "4. فصل الفيشة الـ 12 بن والفيشة الـ 8 بن من الكنترول.",
        "5. توصيل كابل التخطي (12+8 Bypass) مباشرة في فيشات الضفيرة المفصولة.",
        "6. تركيب جهاز الفحص OBD2 في الطرف الآخر من الوصلة.",
        "7. فتح الكونتاك. الآن متاح مسح كل الأعطال وعمل الاختبارات والريست بنجاح 100%!",
      ],
      pinouts: [
        SgwPinout(connectorName: "12-Pin Connector", pinNumber: 1, wireColor: "Blue / White", signalName: "CAN-C High", description: "Powertrain CAN Bus High line (500 kbps)"),
        SgwPinout(connectorName: "12-Pin Connector", pinNumber: 2, wireColor: "White / Blue", signalName: "CAN-C Low", description: "Powertrain CAN Bus Low line (500 kbps)"),
        SgwPinout(connectorName: "12-Pin Connector", pinNumber: 3, wireColor: "Brown / Red", signalName: "CAN-IHS High", description: "Interior High Speed CAN High (125 kbps)"),
        SgwPinout(connectorName: "12-Pin Connector", pinNumber: 4, wireColor: "Brown / White", signalName: "CAN-IHS Low", description: "Interior High Speed CAN Low (125 kbps)"),
        SgwPinout(connectorName: "8-Pin Connector", pinNumber: 1, wireColor: "Red / Yellow", signalName: "BATT +12V", description: "Permanent Unswitched Battery 12V Power"),
        SgwPinout(connectorName: "8-Pin Connector", pinNumber: 2, wireColor: "Black", signalName: "GND", description: "Chassis Ground Reference"),
      ],
    ),
    SgwVehicleGuide(
      id: "jeep_renegade_compass_sgw",
      vehicleName: "Jeep Renegade / Compass (SGW 12+8)",
      vehicleNameAr: "جيب رينيجيد / كومباس (حماية البوابة 12+8)",
      brand: "Jeep",
      years: "2018-2026",
      sgwType: "FCA SGW 12+8 Pin",
      location: "Behind center console / lower passenger glove box side panel.",
      locationAr: "خلف درج التابلوه من جانب الراكب الأمامي أو بجوار الكونسول الوسطي.",
      harnessCable: "FCA 12+8 SGW Cable Harness",
      harnessCableAr: "كابل فيشة فيات وكرايسلر وجيب 12+8",
      symptoms: [
        "Live sensor data displays normally",
        "DTC Clear rejected with response 7F 14 33",
        "4x4 / AWD Actuator tests and EPB service mode disabled",
      ],
      symptomsAr: [
        "البيانات الحية تعمل بشكل طبيعي",
        "مسح الأعطال يرفض برسالة الخطأ 7F 14 33",
        "اختبارات الدفع الرباعي 4x4 وفرامل اليد الكهربائية معطلة",
      ],
      procedureSteps: [
        "1. Turn OFF ignition.",
        "2. Drop the glove compartment down by squeezing the side retainer clips.",
        "3. Reach behind the HVAC housing to find the SGW unit.",
        "4. Unplug the 12-pin and 8-pin harness connectors.",
        "5. Mate them with the 12+8 bypass adapter and plug scanner into the adapter.",
      ],
      procedureStepsAr: [
        "1. إطفاء الكونتاك وسحب المفتاح.",
        "2. إنزال درج التابلوه بضغط كلبسات الجوانب.",
        "3. الوصول لكنترول الحماية خلف التابلوه وفصل الفيشتين.",
        "4. شبك كابل 12+8 والتوصيل بجهاز الفحص لمسح الأعطال بالكامل.",
      ],
      pinouts: [
        SgwPinout(connectorName: "12-Pin Plug", pinNumber: 1, wireColor: "Green / White", signalName: "CAN-C High", description: "Chassis/Drivetrain CAN Bus High"),
        SgwPinout(connectorName: "12-Pin Plug", pinNumber: 2, wireColor: "Green", signalName: "CAN-C Low", description: "Chassis/Drivetrain CAN Bus Low"),
        SgwPinout(connectorName: "8-Pin Plug", pinNumber: 1, wireColor: "Red", signalName: "+12V Batt", description: "Constant 12V Power Supply"),
        SgwPinout(connectorName: "8-Pin Plug", pinNumber: 2, wireColor: "Black", signalName: "Ground", description: "Clean Vehicle Earth Ground"),
      ],
    ),
    SgwVehicleGuide(
      id: "alfa_giulia_stelvio_sgw",
      vehicleName: "Alfa Romeo Giulia / Stelvio (SGW 12+8)",
      vehicleNameAr: "ألفا روميو جوليا / ستلفيو (حماية 12+8)",
      brand: "Alfa Romeo",
      years: "2018-2026",
      sgwType: "FCA SGW 12+8 Pin",
      location: "Behind driver side footwell footrest plastic trim, near steering column base.",
      locationAr: "فوق دواسات السائق خلف لوحة القدم البلاستيكية أسفل عمود الدركسيون.",
      harnessCable: "FCA 12+8 SGW Adapter Cable",
      harnessCableAr: "كابل تخطي ألفا روميو وفيات 12+8",
      symptoms: [
        "Maintenance interval reset fails",
        "DNA Mode switch adaptation fails",
        "Active exhaust valve test blocked",
      ],
      symptomsAr: [
        "تصفير عداد صيانة الزيت يرفض",
        "معايرة وضعية القيادة DNA تفشل",
        "اختبارات بلف الشكمان الرياضي محظورة",
      ],
      procedureSteps: [
        "1. Turn ignition OFF.",
        "2. Unclip driver side carpet and under-dash trim panel.",
        "3. Locate SGW module bolted to firewall bracket.",
        "4. Connect 12+8 bypass harness directly to the wiring harness.",
      ],
      procedureStepsAr: [
        "1. إطفاء الكونتاك.",
        "2. إزالة الغطاء البلاستيكي فوق دواسة البنزين.",
        "3. فك فيشتي وحدة SGW وتوصيل وصلة التخطي 12+8.",
      ],
      pinouts: [
        SgwPinout(connectorName: "12-Pin", pinNumber: 1, wireColor: "Blue", signalName: "CAN-C High", description: "High Speed CAN 500k"),
        SgwPinout(connectorName: "12-Pin", pinNumber: 2, wireColor: "White", signalName: "CAN-C Low", description: "High Speed CAN 500k"),
        SgwPinout(connectorName: "8-Pin", pinNumber: 1, wireColor: "Red", signalName: "+12V", description: "Battery Feed"),
        SgwPinout(connectorName: "8-Pin", pinNumber: 2, wireColor: "Black", signalName: "GND", description: "Ground"),
      ],
    ),
    SgwVehicleGuide(
      id: "renault_megane_clio_sgw",
      vehicleName: "Renault Megane IV / Clio V / Captur II (Gateway Red/Black)",
      vehicleNameAr: "رينو ميجان 4 / كليو 5 / كابتشر (بوابة رينو الحمراء/السوداء)",
      brand: "Renault",
      years: "2019-2026",
      sgwType: "Renault Security Gateway (Red & Black Connectors)",
      location: "Behind the passenger glovebox or instrument cluster display.",
      locationAr: "خلف درج التابلوه للراكب أو خلف شاشة العدادات الرقمية.",
      harnessCable: "Renault 16+32 Gateway Bypass Adapter",
      harnessCableAr: "وصلة رينو الخاصة لتخطي فيشات البوابة 16 و32 بن",
      symptoms: [
        "Clearing Renault EDC transmission faults rejected",
        "Electronic Parking Brake service mode blocked",
        "Injector coding and DPF regeneration blocked",
      ],
      symptomsAr: [
        "مسح أعطال فتيس رينو EDC دبل كلتش مرفوض",
        "فتح فرامل اليد الكهربائية لتغيير التيل محظور",
        "تكويد الرشاشات وتجديد فلتر البيئة والجسيمات DPF مقفول",
      ],
      procedureSteps: [
        "1. Switch OFF ignition and wait 3 minutes for CAN sleep mode.",
        "2. Unclip the right dashboard side trim and remove 4 Torx T20 screws holding glovebox.",
        "3. Pull glovebox assembly out to reveal the central gateway unit.",
        "4. Connect Renault gateway bypass adapter inline.",
        "5. Re-run OBD diagnostics with 100% unlocked write privileges.",
      ],
      procedureStepsAr: [
        "1. إطفاء الكونتاك والانتظار 3 دقائق حتى تسكن شبكة الكان.",
        "2. فك مسامير درج التابلوه T20 وسحب الدرج للخارج.",
        "3. ظهور وحدة البوابة الإلكترونية المركزية بفيشتين (حمراء وسوداء).",
        "4. تركيب كابل رينو الوسيط وتوصيل جهاز الفحص.",
        "5. الآن متاح تكويد الرشاشات ومسح كافة الأعطال.",
      ],
      pinouts: [
        SgwPinout(connectorName: "Gateway Red Plug", pinNumber: 6, wireColor: "Yellow", signalName: "CAN-V High", description: "Vehicle CAN High 500k"),
        SgwPinout(connectorName: "Gateway Red Plug", pinNumber: 14, wireColor: "White", signalName: "CAN-V Low", description: "Vehicle CAN Low 500k"),
        SgwPinout(connectorName: "Gateway Black Plug", pinNumber: 1, wireColor: "Red", signalName: "+12V", description: "Direct Protected 12V Power"),
        SgwPinout(connectorName: "Gateway Black Plug", pinNumber: 2, wireColor: "Black", signalName: "GND", description: "Chassis Earth Ground"),
      ],
    ),
    SgwVehicleGuide(
      id: "nissan_sentra_qashqai_sgw",
      vehicleName: "Nissan Sentra B18 / Qashqai J12 (Gateway 16+32)",
      vehicleNameAr: "نيسان سنترا B18 / قاشقاي J12 (بوابة نيسان 16+32)",
      brand: "Nissan",
      years: "2020-2026",
      sgwType: "Nissan Security Gateway 16+32 Pin",
      location: "Behind driver A-pillar trim or under driver dashboard knee bolster.",
      locationAr: "خلف قائم السائق الأمامي أو أسفل غطاء التابلوه السفلي عند الركبة.",
      harnessCable: "Nissan 16+32 Gateway Bypass Harness",
      harnessCableAr: "وصلة نيسان 16+32 بن لتخطي حماية البوابة",
      symptoms: [
        "ECU/TCU active actuator commands blocked",
        "Radar calibration / ADAS resets blocked",
        "Key programming and steering lock matching rejected",
      ],
      symptomsAr: [
        "اختبارات مشغلات المحرك وفتيس CVT محظورة",
        "معايرة رادار النقطة العمياء وتحديد المسار مرفوضة",
        "برمجة المفاتيح وقفل الدركسيون الإلكتروني مرفوض",
      ],
      procedureSteps: [
        "1. Switch vehicle ignition OFF.",
        "2. Remove lower driver trim to reach the gateway ECU.",
        "3. Insert 16+32 bypass cable into harness ports.",
        "4. Plug scanner and perform write/adaptation services seamlessly.",
      ],
      procedureStepsAr: [
        "1. إطفاء كونتاك السيارة.",
        "2. فك الغطاء السفلي أسفل دركسيون السائق.",
        "3. تركيب كابل التخطي 16+32 بين الكنترول والجهاز.",
        "4. تشغيل الكونتاك والبدء في الفحص والتكويد بحرية تامة.",
      ],
      pinouts: [
        SgwPinout(connectorName: "16-Pin Harness", pinNumber: 6, wireColor: "Blue", signalName: "CAN-H", description: "Vehicle Powertrain CAN High"),
        SgwPinout(connectorName: "16-Pin Harness", pinNumber: 14, wireColor: "Pink", signalName: "CAN-L", description: "Vehicle Powertrain CAN Low"),
        SgwPinout(connectorName: "32-Pin Harness", pinNumber: 1, wireColor: "Red", signalName: "V-BATT", description: "12V Battery Power Line"),
        SgwPinout(connectorName: "32-Pin Harness", pinNumber: 16, wireColor: "Black", signalName: "GND", description: "Ground Shield"),
      ],
    ),
  ];
}
