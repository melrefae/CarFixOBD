import 'dtc_repair_guide.dart';
import '../datasources/dtc_knowledge_base.dart';

/// Diagnostic Trouble Code (DTC) model with bilingual support and workshop inspection guides
class DtcModel {
  final String code;
  final String titleAr;
  final String? titleEn;
  final String category; // Powertrain (P), Chassis (C), Body (B), Network (U)
  final String severity; // Low, Medium, High, Critical
  final String descriptionAr;
  final String? descriptionEn;
  final List<String> symptomsAr;
  final List<String> symptomsEn;
  final List<String> causesAr;
  final List<String> causesEn;
  final String workshopCheckAr; // Practical multimeter inspection steps
  final String? workshopCheckEn;
  final String dtcType; // Stored, Pending, Permanent

  DtcModel({
    required this.code,
    required this.titleAr,
    this.titleEn,
    required this.category,
    required this.severity,
    required this.descriptionAr,
    this.descriptionEn,
    required this.symptomsAr,
    this.symptomsEn = const [],
    required this.causesAr,
    this.causesEn = const [],
    required this.workshopCheckAr,
    this.workshopCheckEn,
    this.dtcType = "Stored",
  });

  /// Offline comprehensive DTC repair guide (symptoms, causes, roadmap, electrical checks)
  DtcRepairGuide? get repairGuide => DtcKnowledgeBase.lookup(code);

  /// English title with standard OBD-II fallback definitions
  String get title {
    if (titleEn != null && titleEn!.isNotEmpty) return titleEn!;
    return _standardEnglishTitles[code] ?? titleAr;
  }

  /// English description with standard OBD-II fallback
  String get description {
    if (descriptionEn != null && descriptionEn!.isNotEmpty) return descriptionEn!;
    return _standardEnglishDescriptions[code] ?? descriptionAr;
  }

  List<String> get symptoms {
    if (symptomsEn.isNotEmpty) return symptomsEn;
    return symptomsAr;
  }

  List<String> get causes {
    if (causesEn.isNotEmpty) return causesEn;
    return causesAr;
  }

  String get workshopCheck {
    if (workshopCheckEn != null && workshopCheckEn!.isNotEmpty) return workshopCheckEn!;
    return _standardWorkshopChecks[code] ?? workshopCheckAr;
  }

  factory DtcModel.fromJson(String code, Map<String, dynamic> json, {String dtcType = "Stored"}) {
    return DtcModel(
      code: code,
      titleAr: json['title_ar'] ?? "عطل غير مصنف ($code)",
      titleEn: json['title_en'],
      category: json['category'] ?? "Powertrain",
      severity: json['severity'] ?? "Medium",
      descriptionAr: json['description_ar'] ?? "كود عطل OBD قياسي.",
      descriptionEn: json['description_en'],
      symptomsAr: List<String>.from(json['symptoms_ar'] ?? []),
      symptomsEn: List<String>.from(json['symptoms_en'] ?? []),
      causesAr: List<String>.from(json['causes_ar'] ?? []),
      causesEn: List<String>.from(json['causes_en'] ?? []),
      workshopCheckAr: json['workshop_check_ar'] ?? "افحص التوصيلات والفيشة الكهربائية ومقاومة المكون المعني.",
      workshopCheckEn: json['workshop_check_en'],
      dtcType: dtcType,
    );
  }

  /// Definition from the open DTC database (English only). Nothing else is invented:
  /// no symptoms or causes are listed because the source has none.
  factory DtcModel.fromOpenDefinition(String code, String definitionEn, {Map<String, String> brandDefinitions = const {}, String dtcType = "Stored"}) {
    final brands = brandDefinitions.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    return DtcModel(
      code: code,
      titleAr: "التعريف (بالإنجليزية): $definitionEn",
      titleEn: definitionEn,
      category: code.isNotEmpty ? code[0] : "P",
      severity: "Unknown",
      descriptionAr: "التعريف من قاعدة بيانات أكواد مفتوحة (MIT). لا توجد أسباب أو أعراض موثقة لهذا الكود في التطبيق." + (brands.isEmpty ? "" : "\nتعريفات حسب الماركة:\n$brands"),
      descriptionEn: "Definition from an open DTC database (MIT). No verified symptoms or causes for this code in the app." + (brands.isEmpty ? "" : "\nBy brand:\n$brands"),
      symptomsAr: const [],
      symptomsEn: const [],
      causesAr: const [],
      causesEn: const [],
      workshopCheckAr: "",
      workshopCheckEn: "",
      dtcType: dtcType,
    );
  }

  /// Fallback code when code is not in local database
  factory DtcModel.unknown(String code, {String dtcType = "Stored"}) {
    String categoryNameAr = "Powertrain (محرك / فتيس)";
    String categoryNameEn = "Powertrain (Engine / Transmission)";
    if (code.startsWith('C')) {
      categoryNameAr = "Chassis (فرامل / شاسيه)";
      categoryNameEn = "Chassis (ABS / Suspension / Steering)";
    } else if (code.startsWith('B')) {
      categoryNameAr = "Body (بودي / إيرباج / تكييف)";
      categoryNameEn = "Body (Airbag / BCM / HVAC)";
    } else if (code.startsWith('U')) {
      categoryNameAr = "Network (شبكة كنترولات)";
      categoryNameEn = "Network (CAN Bus / Inter-module Communication)";
    }

    return DtcModel(
      code: code,
      titleAr: "كود عطل $categoryNameAr",
      titleEn: _standardEnglishTitles[code] ?? "Diagnostic Trouble Code - $categoryNameEn",
      category: code.isNotEmpty ? code[0] : "P",
      severity: "Medium",
      descriptionAr: "كود عطل قياسي مسجل في كونترول السيارة. تفحص الدائرة الكهربائية للمنظومة.",
      descriptionEn: _standardEnglishDescriptions[code] ??
          "Standard OBD-II fault code logged by vehicle ECU. Inspect circuit wiring and component signals.",
      symptomsAr: const ["إضاءة لمبة الأعطال Check Engine"],
      symptomsEn: const ["Check Engine MIL illuminated"],
      causesAr: const ["تلف الحساس أو المشغل", "خلل في ضفيرة الأسلاك أو الفيشة"],
      causesEn: const ["Faulty sensor or actuator", "Wiring harness open/short circuit", "Loose or corroded connector"],
      workshopCheckAr: "قم بقياس الفولت المغذي والأرضي والتأكد من عدم وجود قطع أو التماس بالضفيرة.",
      workshopCheckEn: _standardWorkshopChecks[code] ??
          "Check reference voltage (5V/12V), ground circuit continuity, and wiring harness resistance using a multimeter.",
      dtcType: dtcType,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title_ar': titleAr,
      'title_en': titleEn,
      'category': category,
      'severity': severity,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'symptoms_ar': symptomsAr,
      'symptoms_en': symptomsEn,
      'causes_ar': causesAr,
      'causes_en': causesEn,
      'workshop_check_ar': workshopCheckAr,
      'workshop_check_en': workshopCheckEn,
      'dtc_type': dtcType,
    };
  }

  // Standard OBD-II English Dictionaries for commonly scanned automotive codes
  static final Map<String, String> _standardEnglishTitles = {
    'P0100': 'Mass or Volume Air Flow Circuit Malfunction',
    'P0101': 'Mass or Volume Air Flow Circuit Range/Performance Problem',
    'P0102': 'Mass or Volume Air Flow Circuit Low Input',
    'P0103': 'Mass or Volume Air Flow Circuit High Input',
    'P0105': 'Manifold Absolute Pressure/Barometric Pressure Circuit Malfunction',
    'P0106': 'Manifold Absolute Pressure Circuit Range/Performance Problem',
    'P0107': 'Manifold Absolute Pressure/Barometric Pressure Circuit Low Input',
    'P0108': 'Manifold Absolute Pressure/Barometric Pressure Circuit High Input',
    'P0110': 'Intake Air Temperature Circuit Malfunction',
    'P0115': 'Engine Coolant Temperature Circuit Malfunction',
    'P0117': 'Engine Coolant Temperature Circuit Low Input',
    'P0118': 'Engine Coolant Temperature Circuit High Input',
    'P0120': 'Throttle/Pedal Position Sensor/Switch A Circuit Malfunction',
    'P0122': 'Throttle/Pedal Position Sensor/Switch A Circuit Low Input',
    'P0123': 'Throttle/Pedal Position Sensor/Switch A Circuit High Input',
    'P0128': 'Coolant Thermostat (Coolant Temp Below Regulating Temp)',
    'P0130': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 1)',
    'P0131': 'O2 Sensor Circuit Low Voltage (Bank 1 Sensor 1)',
    'P0132': 'O2 Sensor Circuit High Voltage (Bank 1 Sensor 1)',
    'P0133': 'O2 Sensor Circuit Slow Response (Bank 1 Sensor 1)',
    'P0134': 'O2 Sensor Circuit No Activity Detected (Bank 1 Sensor 1)',
    'P0135': 'O2 Sensor Heater Circuit Malfunction (Bank 1 Sensor 1)',
    'P0136': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 2)',
    'P0141': 'O2 Sensor Heater Circuit Malfunction (Bank 1 Sensor 2)',
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',
    'P0200': 'Injector Circuit Malfunction',
    'P0300': 'Random/Multiple Cylinder Misfire Detected',
    'P0301': 'Cylinder 1 Misfire Detected',
    'P0302': 'Cylinder 2 Misfire Detected',
    'P0303': 'Cylinder 3 Misfire Detected',
    'P0304': 'Cylinder 4 Misfire Detected',
    'P0325': 'Knock Sensor 1 Circuit Malfunction (Bank 1)',
    'P0335': 'Crankshaft Position Sensor A Circuit Malfunction',
    'P0336': 'Crankshaft Position Sensor A Circuit Range/Performance',
    'P0340': 'Camshaft Position Sensor A Circuit Malfunction (Bank 1)',
    'P0400': 'Exhaust Gas Recirculation Flow Malfunction',
    'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
    'P0440': 'Evaporative Emission Control System Malfunction',
    'P0442': 'Evaporative Emission Control System Leak Detected (Small Leak)',
    'P0443': 'EVAP Purge Control Valve Circuit Malfunction',
    'P0500': 'Vehicle Speed Sensor Malfunction',
    'P0505': 'Idle Air Control System Malfunction',
    'P0562': 'System Voltage Low',
    'P0563': 'System Voltage High',
    'P0606': 'ECM/PCM Processor Fault',
    'P0700': 'Transmission Control System Malfunction (MIL Request)',
    'P0705': 'Transmission Range Sensor Circuit Malfunction (PRNDL Input)',
    'P0730': 'Incorrect Gear Ratio',
    'P0740': 'Torque Converter Clutch Circuit Malfunction',
    'U0001': 'High Speed CAN Communication Bus',
    'U0100': 'Lost Communication With ECM/PCM',
    'U0101': 'Lost Communication with TCM',
    'U0121': 'Lost Communication With Anti-Lock Brake System (ABS) Control Module',
  };

  static final Map<String, String> _standardEnglishDescriptions = {
    'P0100': 'The ECU detects an abnormal or missing signal from the Mass Air Flow (MAF) sensor circuit.',
    'P0101': 'The MAF sensor signal is inconsistent with throttle position and engine RPM speed.',
    'P0105': 'The ECU detected a circuit open, short, or invalid signal from the Manifold Absolute Pressure (MAP) sensor.',
    'P0115': 'Abnormal voltage reading from the Engine Coolant Temperature (ECT) sensor circuit.',
    'P0120': 'The Throttle Position Sensor (TPS) signal voltage is outside normal operating specifications.',
    'P0128': 'Engine temperature did not reach operating threshold within the expected warm-up timeframe (stuck open thermostat).',
    'P0130': 'Upstream Oxygen Sensor (O2S) circuit in Bank 1 is malfunctioning or disconnected.',
    'P0135': 'The internal heating element circuit in upstream oxygen sensor Bank 1 Sensor 1 has failed.',
    'P0171': 'The ECU air-fuel mixture is excessively lean. STFT and LTFT exceed positive compensation limits (+15% to +25%).',
    'P0172': 'The ECU air-fuel mixture is excessively rich. ECU is pulling fuel trim to minimum pulse width.',
    'P0300': 'The crankshaft sensor detected erratic acceleration indicating combustion misfire across multiple cylinders.',
    'P0301': 'Cylinder #1 combustion misfire detected.',
    'P0302': 'Cylinder #2 combustion misfire detected.',
    'P0303': 'Cylinder #3 combustion misfire detected.',
    'P0304': 'Cylinder #4 combustion misfire detected.',
    'P0335': 'The ECU is not receiving a reliable rotational synchronization pulse from the Crankshaft Position (CKP) sensor.',
    'P0340': 'The ECU lost the camshaft synchronization pulse needed for sequential fuel injection and ignition timing.',
    'P0420': 'Downstream O2 sensor indicates catalytic converter oxygen storage capacity has degraded below threshold.',
    'P0500': 'Missing vehicle speed signal from VSS sensor or ABS wheel speed module.',
    'P0505': 'The ECU cannot stabilize engine idle speed using the Idle Air Control (IAC) stepper valve or electronic throttle.',
    'U0100': 'Instrument cluster or body control module lost CAN bus serial data communication with the Engine Control Module.',
  };

  static final Map<String, String> _standardWorkshopChecks = {
    'P0100': 'Measure 5V reference and ground at MAF harness connector. Spray wire element with dedicated MAF cleaner.',
    'P0101': 'Check intake boot accordion duct for cracks and leaks. Clean electronic throttle body butterfly plate.',
    'P0105': 'Inspect vacuum port to MAP sensor for carbon clogging. Check 5V ref and signal wire with multimeter.',
    'P0115': 'Measure sensor resistance across terminals (cold ~2500-3000 ohms, hot ~200-300 ohms). Verify 5V feed.',
    'P0128': 'Replace coolant thermostat and bleed cooling system. Verify coolant level and sensor reading.',
    'P0130': 'Check sensor harness for melting against exhaust manifold. Measure O2 sensor signal wire oscillating between 0.1V and 0.9V.',
    'P0135': 'Measure resistance of O2 sensor heater wires (typically 6 to 14 ohms). Check 12V supply fuse and relay.',
    'P0171': 'Perform smoke test on intake manifold, PCV valve, and brake booster. Measure fuel pump pressure under load.',
    'P0172': 'Check for leaking fuel injectors, contaminated engine oil with fuel, high fuel rail pressure, or restricted air filter.',
    'P0300': 'Check ignition coils, spark plug gaps and fouling, injector pulse with noid light, and cylinder compression.',
    'P0301': 'Swap ignition coil 1 with cylinder 2 to verify if misfire moves. Inspect spark plug #1 and injector #1.',
    'P0335': 'Measure sensor resistance (typically 500-900 ohms for magnetic type). Check reluctor ring teeth and air gap.',
    'P0340': 'Check 12V/5V power, ground, and sensor waveform. Verify engine mechanical timing belt/chain alignment.',
    'P0420': 'Inspect exhaust for pre-cat leaks. Compare upstream vs downstream O2 sensor waveforms with live graph.',
    'P0500': 'Check speed sensor gear drive on transmission, wiring harness continuity to ECU/cluster, or ABS wheel sensors.',
    'P0505': 'Clean IAC valve carbon buildup and throttle passage. Check stepper motor winding resistance (typically 40-55 ohms).',
  };
}
