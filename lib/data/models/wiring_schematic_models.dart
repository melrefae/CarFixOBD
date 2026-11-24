/// Schematic Electrical Component Model
class SchematicComponent {
  final String id;
  final String nameEn;
  final String nameAr;
  final double x;
  final double y;
  final String typeName;
  final List<String> pins;

  const SchematicComponent({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.x,
    required this.y,
    required this.typeName,
    required this.pins,
  });
}

/// Schematic Color-Coded Harness Wire Model
class SchematicWire {
  final String id;
  final String fromComponentId;
  final String toComponentId;
  final String fromPin;
  final String toPin;
  final String wireColorEn;
  final String wireColorAr;
  final int wireColorHex;
  final String signalType;

  const SchematicWire({
    required this.id,
    required this.fromComponentId,
    required this.toComponentId,
    required this.fromPin,
    required this.toPin,
    required this.wireColorEn,
    required this.wireColorAr,
    required this.wireColorHex,
    required this.signalType,
  });
}

/// ECU Connector Pinout Multimeter Probe Test Guide
class EcuPinoutProbe {
  final int pinNumber;
  final String connectorName;
  final String circuitNameEn;
  final String circuitNameAr;
  final String wireColor;
  final String keyOnVoltage;
  final String runningVoltage;
  final String resistanceToGround;
  final String probeInstructionEn;
  final String probeInstructionAr;

  const EcuPinoutProbe({
    required this.pinNumber,
    required this.connectorName,
    required this.circuitNameEn,
    required this.circuitNameAr,
    required this.wireColor,
    required this.keyOnVoltage,
    required this.runningVoltage,
    required this.resistanceToGround,
    required this.probeInstructionEn,
    required this.probeInstructionAr,
  });
}

/// Complete Electrical Schematic System
class SchematicDiagram {
  final String id;
  final String titleEn;
  final String titleAr;
  final String systemCategory;
  final List<SchematicComponent> components;
  final List<SchematicWire> wires;
  final List<EcuPinoutProbe> pinouts;

  const SchematicDiagram({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.systemCategory,
    required this.components,
    required this.wires,
    required this.pinouts,
  });

  static List<SchematicDiagram> getAllDiagrams() {
    return [
      // 1. Engine Management & Fuel Injection
      SchematicDiagram(
        id: "engine_mgmt_fuel",
        titleEn: "Engine Management & Fuel Injection",
        titleAr: "إدارة المحرك وحقن الوقود الإلكتروني",
        systemCategory: "Powertrain",
        components: const [
          SchematicComponent(id: "ECM", nameEn: "Engine Control Module (ECM)", nameAr: "كمبيوتر المحرك الرئيسي", x: 0.15, y: 0.5, typeName: "ECU", pins: ["Pin 1", "Pin 2", "Pin 14", "Pin 28", "Pin 42"]),
          SchematicComponent(id: "MAF", nameEn: "Mass Air Flow (MAF)", nameAr: "حساس الهواء وسريان التدفق", x: 0.85, y: 0.2, typeName: "Sensor", pins: ["12V+", "Sig", "GND", "IAT"]),
          SchematicComponent(id: "INJ1", nameEn: "Fuel Injector #1", nameAr: "رشاش الوقود الأسطوانة 1", x: 0.85, y: 0.5, typeName: "Actuator", pins: ["12V+", "PwmGnd"]),
          SchematicComponent(id: "O2_B1S1", nameEn: "Upstream Oxygen Sensor", nameAr: "حساس الشكمان الأمامي قبل البيئة", x: 0.85, y: 0.8, typeName: "Sensor", pins: ["Heater+", "Heater-", "Sig+", "Sig-"]),
        ],
        wires: const [
          SchematicWire(id: "w_maf_sig", fromComponentId: "MAF", toComponentId: "ECM", fromPin: "Sig", toPin: "Pin 28", wireColorEn: "Blue/White", wireColorAr: "أزرق / أبيض", wireColorHex: 0xFF29B6F6, signalType: "Analog 0-5V"),
          SchematicWire(id: "w_inj_pwm", fromComponentId: "INJ1", toComponentId: "ECM", fromPin: "PwmGnd", toPin: "Pin 42", wireColorEn: "Green/Black", wireColorAr: "أخضر / أسود", wireColorHex: 0xFF66BB6A, signalType: "Switched Ground (PWM)"),
          SchematicWire(id: "w_o2_sig", fromComponentId: "O2_B1S1", toComponentId: "ECM", fromPin: "Sig+", toPin: "Pin 14", wireColorEn: "Black/Yellow", wireColorAr: "أسود / أصفر", wireColorHex: 0xFFFFCA28, signalType: "O2 Millivolt (0.1-0.9V)"),
          SchematicWire(id: "w_power_inj", fromComponentId: "INJ1", toComponentId: "ECM", fromPin: "12V+", toPin: "Pin 1", wireColorEn: "Red/White", wireColorAr: "أحمر / أبيض", wireColorHex: 0xFFEF5350, signalType: "+12V Main Relay Power"),
        ],
        pinouts: const [
          EcuPinoutProbe(
            pinNumber: 1,
            connectorName: "Connector A (94-Pin)",
            circuitNameEn: "Main Relay Switched Power (+12V)",
            circuitNameAr: "تغذية كهرباء كتاوت المحرك الرئيسي",
            wireColor: "Red/White",
            keyOnVoltage: "12.4 V",
            runningVoltage: "14.2 V",
            resistanceToGround: "Open (>10MΩ)",
            probeInstructionEn: "Probe back of pin with Key ON. Must show full battery charging voltage. If 0V, check Main Engine Relay #15.",
            probeInstructionAr: "قس ظهر الفيشة والكونتاكت مفتوح. يجب أن يظهر جهد البطارية كاملاً. إذا كان 0 فولت افحص كتاوت المحرك رقم 15.",
          ),
          EcuPinoutProbe(
            pinNumber: 28,
            connectorName: "Connector A (94-Pin)",
            circuitNameEn: "MAF Sensor Flow Signal Input",
            circuitNameAr: "إشارة تدفق كمية الهواء من حساس الماف",
            wireColor: "Blue/White",
            keyOnVoltage: "1.00 V",
            runningVoltage: "1.40 V (Idle) - 4.20 V (WOT)",
            resistanceToGround: "> 100 kΩ",
            probeInstructionEn: "Backprobe with DC voltmeter. Voltage must rise smoothly with throttle snap up to >4.0V without dropouts.",
            probeInstructionAr: "قس الإشارة بالفولتميتر عند كبس البنزين. يجب أن يتصاعد الفولت بسلاسة لأكثر من 4.0 فولت دون تقطيع.",
          ),
          EcuPinoutProbe(
            pinNumber: 42,
            connectorName: "Connector B (60-Pin)",
            circuitNameEn: "Cylinder #1 Injector Ground Control",
            circuitNameAr: "أرضي التحكم المتقطع في رشاش 1",
            wireColor: "Green/Black",
            keyOnVoltage: "12.4 V (floating through coil)",
            runningVoltage: "0.2 V (during dwell) / 65 V peak",
            resistanceToGround: "12.0 Ω (through injector)",
            probeInstructionEn: "Check with oscilloscope or LED noid light. Verify ground pulse duration matches live scanner injector pulse width.",
            probeInstructionAr: "افحص بواسطة أوسيلوسكوب أو لمبة نويد. تأكد من تطابق نبضة الأرضي مع زمن الرش بالجهاز.",
          ),
        ],
      ),

      // 2. Starting, Charging & Alternator Circuit
      SchematicDiagram(
        id: "start_charge_system",
        titleEn: "Starting & Charging System",
        titleAr: "دائرة المارش والدينامو والشحن الذكي",
        systemCategory: "Electrical",
        components: const [
          SchematicComponent(id: "BATT", nameEn: "Vehicle 12V Battery", nameAr: "بطارية السيارة 12 فولت", x: 0.15, y: 0.25, typeName: "Power", pins: ["+B", "-B"]),
          SchematicComponent(id: "ALT", nameEn: "Smart Alternator", nameAr: "دينامو الشحن الذكي", x: 0.85, y: 0.25, typeName: "Charging", pins: ["B+ Post", "LIN Reg", "GND"]),
          SchematicComponent(id: "STR", nameEn: "Starter Motor & Solenoid", nameAr: "مارش التشغيل وأوتوماتيك المارش", x: 0.85, y: 0.75, typeName: "Starting", pins: ["Terminal 30", "Terminal 50", "GND"]),
          SchematicComponent(id: "BCM", nameEn: "Body Control Gateway", nameAr: "كمبيوتر البودي وإذن التشغيل", x: 0.15, y: 0.75, typeName: "ECU", pins: ["IGN Switch", "Starter Relay Out"]),
        ],
        wires: const [
          SchematicWire(id: "w_batt_alt", fromComponentId: "ALT", toComponentId: "BATT", fromPin: "B+ Post", toPin: "+B", wireColorEn: "Solid Red (16mm²)", wireColorAr: "أحمر سميك", wireColorHex: 0xFFD32F2F, signalType: "Charging Current (+14V)"),
          SchematicWire(id: "w_str_crank", fromComponentId: "BCM", toComponentId: "STR", fromPin: "Starter Relay Out", toPin: "Terminal 50", wireColorEn: "Red/Yellow", wireColorAr: "أحمر / أصفر", wireColorHex: 0xFFFFB300, signalType: "Starter Crank Trigger (+12V)"),
          SchematicWire(id: "w_alt_lin", fromComponentId: "ALT", toComponentId: "BCM", fromPin: "LIN Reg", toPin: "IGN Switch", wireColorEn: "Purple/White", wireColorAr: "بنفسجي / أبيض", wireColorHex: 0xFFAB47BC, signalType: "LIN Bus Communication"),
        ],
        pinouts: const [
          EcuPinoutProbe(
            pinNumber: 50,
            connectorName: "Starter Solenoid Plug",
            circuitNameEn: "Terminal 50 Ignition Crank Trigger",
            circuitNameAr: "طرف 50 لقط أوتوماتيك المارش",
            wireColor: "Red/Yellow",
            keyOnVoltage: "0.0 V",
            runningVoltage: "10.5 - 12.0 V (during crank only)",
            resistanceToGround: "1.2 Ω (hold-in coil)",
            probeInstructionEn: "Must show +12V during key crank. If 0V, check Ignition switch, Neutral safety switch, or Starter relay.",
            probeInstructionAr: "يجب أن يعطي 12 فولت أثناء تدوير المفتاح. إذا كان 0 فولت تأكد من سويتش الفتيس ومرحل المارش.",
          ),
        ],
      ),

      // 3. ABS / ESP Brakes & Wheel Sensors
      SchematicDiagram(
        id: "abs_esp_brakes",
        titleEn: "ABS / ESP Hydraulic System",
        titleAr: "دائرة الفرامل المانعة للانغلاق ABS وثبات ESP",
        systemCategory: "Chassis",
        components: const [
          SchematicComponent(id: "ABS_MOD", nameEn: "ABS/ESP Hydraulic Controller", nameAr: "كمبيوتر وبلوك فرامل ABS", x: 0.15, y: 0.5, typeName: "ECU", pins: ["CAN-H", "CAN-L", "FL+", "FR+", "RL+", "RR+"]),
          SchematicComponent(id: "WSS_FL", nameEn: "Front Left Wheel Sensor", nameAr: "حساس سرعة العجلة أمامي يسار", x: 0.85, y: 0.2, typeName: "Sensor", pins: ["Vcc", "Sig"]),
          SchematicComponent(id: "WSS_FR", nameEn: "Front Right Wheel Sensor", nameAr: "حساس سرعة العجلة أمامي يمين", x: 0.85, y: 0.4, typeName: "Sensor", pins: ["Vcc", "Sig"]),
          SchematicComponent(id: "WSS_RL", nameEn: "Rear Left Wheel Sensor", nameAr: "حساس سرعة العجلة خلفي يسار", x: 0.85, y: 0.6, typeName: "Sensor", pins: ["Vcc", "Sig"]),
          SchematicComponent(id: "WSS_RR", nameEn: "Rear Right Wheel Sensor", nameAr: "حساس سرعة العجلة خلفي يمين", x: 0.85, y: 0.8, typeName: "Sensor", pins: ["Vcc", "Sig"]),
        ],
        wires: const [
          SchematicWire(id: "w_wss_fl", fromComponentId: "WSS_FL", toComponentId: "ABS_MOD", fromPin: "Sig", toPin: "FL+", wireColorEn: "Yellow/Green", wireColorAr: "أصفر / أخضر", wireColorHex: 0xFF9CCC65, signalType: "Active Hall Speed Pulse"),
          SchematicWire(id: "w_wss_fr", fromComponentId: "WSS_FR", toComponentId: "ABS_MOD", fromPin: "Sig", toPin: "FR+", wireColorEn: "White/Green", wireColorAr: "أبيض / أخضر", wireColorHex: 0xFF81C784, signalType: "Active Hall Speed Pulse"),
        ],
        pinouts: const [
          EcuPinoutProbe(
            pinNumber: 12,
            connectorName: "ABS 38-Pin Connector",
            circuitNameEn: "Front Left Wheel Speed Sensor (+)",
            circuitNameAr: "طرف إشارة حساس سرعة العجلة الأمامية يسار",
            wireColor: "Yellow/Green",
            keyOnVoltage: "11.5 V (sensor supply)",
            runningVoltage: "0.75V - 1.4V current loop toggle",
            resistanceToGround: "Open circuit (active hall)",
            probeInstructionEn: "Rotate wheel by hand with multimeter on AC volts or frequency. Wave amplitude must toggle regularly across magnetic reluctor ring.",
            probeInstructionAr: "لف العجلة يدوياً مع قياس التردد أو الفولت المتردد. تأكد من سلامة رنجة المغناطيس بالبلية.",
          ),
        ],
      ),

      // 4. Dual Radiator Cooling Fan Circuit
      SchematicDiagram(
        id: "cooling_fan_loop",
        titleEn: "Cooling Fan & Thermostat Control",
        titleAr: "دائرة مراوح التبريد وترموستات الكوع",
        systemCategory: "Cooling",
        components: const [
          SchematicComponent(id: "ECM", nameEn: "Engine ECU", nameAr: "كمبيوتر المحرك", x: 0.15, y: 0.5, typeName: "ECU", pins: ["Fan High", "Fan Low", "ECT Sig"]),
          SchematicComponent(id: "FAN_RELAY", nameEn: "Fan Relays & Resistor", nameAr: "كتاوت ومقاومة سرعات المراوح", x: 0.5, y: 0.5, typeName: "Relay", pins: ["Low In", "High In", "Fan Out"]),
          SchematicComponent(id: "FAN_MOTOR", nameEn: "Dual Radiator Fan Assembly", nameAr: "مروحة الردياتير المزدوجة", x: 0.85, y: 0.5, typeName: "Motor", pins: ["M+", "M-"]),
        ],
        wires: const [
          SchematicWire(id: "w_fan_ctrl", fromComponentId: "ECM", toComponentId: "FAN_RELAY", fromPin: "Fan Low", toPin: "Low In", wireColorEn: "Blue/Black", wireColorAr: "أزرق / أسود", wireColorHex: 0xFF42A5F5, signalType: "Relay Ground Signal (Trigger)"),
          SchematicWire(id: "w_fan_power", fromComponentId: "FAN_RELAY", toComponentId: "FAN_MOTOR", fromPin: "Fan Out", toPin: "M+", wireColorEn: "Red/White (Heavy)", wireColorAr: "أحمر / أبيض عريض", wireColorHex: 0xFFEF5350, signalType: "High Amperage 12V (30A)"),
        ],
        pinouts: const [
          EcuPinoutProbe(
            pinNumber: 18,
            connectorName: "ECM Harness B",
            circuitNameEn: "Low Speed Cooling Fan Relay Control",
            circuitNameAr: "إشارة تشغيل كتاوت السرعة البطيئة للمروحة",
            wireColor: "Blue/Black",
            keyOnVoltage: "12.0 V (inactive)",
            runningVoltage: "0.1 V (grounded when ECT > 96°C)",
            resistanceToGround: "Switched Ground",
            probeInstructionEn: "When coolant temp reaches 96°C or A/C is turned ON, ECM grounds this terminal to click fan relay.",
            probeInstructionAr: "عند وصول الحرارة لـ 96° مئوية أو تشغيل التكييف يقوم الكمبيوتر بتوصيل الأرضي لتلقيط الكتاوت.",
          ),
        ],
      ),
    ];
  }
}
