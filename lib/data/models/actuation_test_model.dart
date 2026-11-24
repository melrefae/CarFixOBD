import 'package:flutter/material.dart';

/// Single interactive stage within a guided bidirectional actuator routine
class ActuationStep {
  final String id;
  final String title;
  final String titleAr;
  final String instruction;
  final String instructionAr;
  final String promptAction;
  final String promptActionAr;
  final int durationSeconds;
  final bool requiresUserConfirmation;
  final String commandToSend;
  final String stopCommand;
  final String monitoredPid;
  final String monitoredUnit;

  const ActuationStep({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.instruction,
    required this.instructionAr,
    required this.promptAction,
    required this.promptActionAr,
    this.durationSeconds = 10,
    this.requiresUserConfirmation = false,
    this.commandToSend = "",
    this.stopCommand = "",
    this.monitoredPid = "",
    this.monitoredUnit = "",
  });

  String getTitle(bool isAr) => isAr ? titleAr : title;
  String getInstruction(bool isAr) => isAr ? instructionAr : instruction;
  String getPromptAction(bool isAr) => isAr ? promptActionAr : promptAction;

  String get titleEn => title;
  String get instructionEn => instruction;
  String get promptActionEn => promptAction;
}

/// Defines an active bidirectional actuator test (Mode 08 / UDS Mode 2F)
class ActuationTestModel {
  final String id;
  final String title;
  final String titleAr;
  final String systemCategory;
  final String description;
  final String descriptionAr;
  final String targetEcuHeader;
  final String onCommand;
  final String offCommand;
  final Duration activeDuration;
  final String audibleFeedbackNotice;
  final String audibleFeedbackNoticeAr;
  final String liveMonitoringPid;
  final String liveMonitoringUnit;
  final IconData icon;
  final List<String> preConditionsEn;
  final List<String> preConditionsAr;
  final List<ActuationStep> steps;

  const ActuationTestModel({
    required this.id,
    required this.title,
    this.titleAr = "",
    required this.systemCategory,
    required this.description,
    this.descriptionAr = "",
    required this.targetEcuHeader,
    required this.onCommand,
    required this.offCommand,
    this.activeDuration = const Duration(seconds: 10),
    required this.audibleFeedbackNotice,
    this.audibleFeedbackNoticeAr = "",
    this.liveMonitoringPid = "",
    this.liveMonitoringUnit = "",
    required this.icon,
    this.preConditionsEn = const [
      "Ignition key in ON position (Engine OFF)",
      "Battery voltage >= 12.0V",
      "Vehicle in Park (P) or Neutral (N)",
    ],
    this.preConditionsAr = const [
      "فتح الكونتاكت على ON (المحرك مطفأ)",
      "فولتية البطارية أكبر من 12.0 فولت",
      "الفتيس على وضع الفضاوة P أو N",
    ],
    this.steps = const [],
  });

  bool get isGuidedProcedure => steps.isNotEmpty;
  bool get isGuidedRoutine => steps.isNotEmpty;
  List<ActuationStep> get guidedSteps => steps;
  List<String> get safetyChecklist => preConditionsEn;

  String getTitle(bool isAr) => isAr && titleAr.isNotEmpty ? titleAr : title;
  String getDescription(bool isAr) => isAr && descriptionAr.isNotEmpty ? descriptionAr : description;
  String getNotice(bool isAr) => isAr && audibleFeedbackNoticeAr.isNotEmpty ? audibleFeedbackNoticeAr : audibleFeedbackNotice;
  List<String> getPreConditions(bool isAr) => isAr ? preConditionsAr : preConditionsEn;

  static List<ActuationTestModel> getAllActuatorTests() {
    return [
      // Standard Radiator Fan High Speed test
      const ActuationTestModel(
        id: "radiator_fan_high",
        title: "Radiator Fan Relay High Speed",
        titleAr: "مروحة تبريد الردياتير (السرعة العالية)",
        systemCategory: "Cooling System",
        description: "Engages cooling fan high-speed relay to check current draw and high CFM airflow.",
        descriptionAr: "تشغيل ريليه مروحة التبريد على السرعة العالية للتأكد من تدفق الهواء وسلامة الموتور.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 10 03 01",
        offCommand: "2F 01 10 00",
        activeDuration: Duration(seconds: 12),
        audibleFeedbackNotice: "Listen for high-pitched airflow and check battery voltage under load.",
        audibleFeedbackNoticeAr: "استمع لصوت اندفاع الهواء وتأكد من استقرار فولت البطارية.",
        liveMonitoringPid: "0105",
        liveMonitoringUnit: "°C",
        icon: Icons.wind_power,
      ),

      // 1. ABS Automated Brake Bleeding Routine (Guided Procedure)
      const ActuationTestModel(
        id: "abs_brake_bleeding_routine",
        title: "ABS Hydraulic Pump Auto-Bleed Routine",
        titleAr: "تفريغ هواء فرامل ABS الآلي للمحاور الأربعة",
        systemCategory: "Braking System (ABS)",
        description: "Automated step-by-step hydraulic pump cycling and solenoid valve pulsation to purge trapped air from ABS hydraulic control unit.",
        descriptionAr: "إجراء تفاعلي متعدد الخطوات لتشغيل طلمبة وبلوف الـ ABS الهيدروليكية لطرد الهواء المحبوس من دورة الفرامل.",
        targetEcuHeader: "7E2",
        onCommand: "2F 02 01 03 01",
        offCommand: "2F 02 01 00",
        activeDuration: Duration(seconds: 40),
        audibleFeedbackNotice: "Listen for ABS pump motor buzzing and feel pulsing under brake pedal.",
        audibleFeedbackNoticeAr: "استمع لصوت زن موتور طلمبة الـ ABS واستشعر النبضات أسفل بدال الفرامل.",
        liveMonitoringPid: "0142",
        liveMonitoringUnit: "V",
        icon: Icons.album_outlined,
        steps: [
          ActuationStep(
            id: "prep_bleed",
            title: "Pre-Bleed Inspection & Brake Fluid",
            titleAr: "تجهيز خزان زيت الفرامل",
            instruction: "Ensure brake fluid reservoir is filled to MAX line with fresh DOT4 brake fluid. Connect clear bleeder hose to Front-Left caliper bleeder screw.",
            instructionAr: "تأكد من ملء خزان زيت الفرامل حتى علامة MAX بزيت DOT4 أصلي وتوصيل خرطوم شفاف بمسمار تفريغ هوا العجلة الأمامية اليسرى.",
            promptAction: "Press Ready to begin pedal pressurization",
            promptActionAr: "اضغط جاهز لبدء تحضير البدال",
            durationSeconds: 0,
            requiresUserConfirmation: true,
          ),
          ActuationStep(
            id: "pedal_press_fl",
            title: "Front-Left Caliper Pressure Hold",
            titleAr: "كبس بدال الفرامل - العجلة الأمامية اليسرى",
            instruction: "Depress brake pedal firmly 3 times and HOLD down firmly. Open bleeder screw half a turn.",
            instructionAr: "اضغط على بدال الفرامل 3 مرات بقوة واستمر في الضغط للأسفل، ثم افتح مسمار تفريغ الهواء نصف لفة.",
            promptAction: "Holding pedal firmly down",
            promptActionAr: "مستمر في الضغط على البدال",
            durationSeconds: 0,
            requiresUserConfirmation: true,
          ),
          ActuationStep(
            id: "cycle_pump_fl",
            title: "ABS Pump Motor & Solenoid Cycle (FL)",
            titleAr: "تفعيل طلمبة وبلوف الـ ABS للعجلة الأمامية اليسرى",
            instruction: "ABS pump is now cycling pressurized fluid through Front-Left internal valve channels. Close bleeder screw when fluid runs bubble-free.",
            instructionAr: "طلمبة الـ ABS تدور وتضخ الزيت الآن لطرد الفقاعات. أحكم غلق مسمار تفريغ الهواء فور خروج زيت صافٍ بدون هواء.",
            promptAction: "Pumping in progress...",
            promptActionAr: "جاري الضخ الهيدروليكي...",
            durationSeconds: 12,
            requiresUserConfirmation: false,
            commandToSend: "2F 02 10 03 01",
            stopCommand: "2F 02 10 00",
            monitoredPid: "0142",
            monitoredUnit: "V",
          ),
          ActuationStep(
            id: "cycle_pump_fr",
            title: "Front-Right Caliper Pump Cycle",
            titleAr: "تفعيل طلمبة وبلوف الـ ABS للعجلة الأمامية اليمنى",
            instruction: "Move bleeder tube to Front-Right caliper. Hold pedal firmly. Cycling ABS solenoids.",
            instructionAr: "انقل الخرطوم لمسمار العجلة الأمامية اليمنى. استمر في الضغط على البدال أثناء تفعيل الطلمبة.",
            promptAction: "Bleeding Front-Right caliper...",
            promptActionAr: "جاري تفريغ هواء العجلة الأمامية اليمنى...",
            durationSeconds: 12,
            requiresUserConfirmation: false,
            commandToSend: "2F 02 11 03 01",
            stopCommand: "2F 02 11 00",
            monitoredPid: "0142",
            monitoredUnit: "V",
          ),
          ActuationStep(
            id: "cycle_rear_axle",
            title: "Rear Axle ABS Valves Bleed Cycle",
            titleAr: "تفريغ هواء بلوف المحور الخلفي",
            instruction: "Cycling Rear-Left and Rear-Right ABS return circuits. Verify pedal returns firm and high.",
            instructionAr: "تفعيل دوائر الراجع للعجلات الخلفية. تأكد من عودة البدال للأعلى وتحجيره بقوة بدون أي إسفنجية.",
            promptAction: "Finalizing ABS hydraulic circuit purge...",
            promptActionAr: "جاري استكمال طرد الهواء بالكامل...",
            durationSeconds: 12,
            requiresUserConfirmation: false,
            commandToSend: "2F 02 12 03 01",
            stopCommand: "2F 02 12 00",
            monitoredPid: "0142",
            monitoredUnit: "V",
          ),
        ],
      ),

      // 2. Throttle Body Adaptive Calibration Routine (Guided Procedure)
      const ActuationTestModel(
        id: "throttle_relearn_routine",
        title: "Electronic Throttle Body (ETB) Calibration",
        titleAr: "معايرة وإعادة تكويد بوابة الهواء الإلكترونية (ثروتل)",
        systemCategory: "Air & Intake System",
        description: "Commands electronic throttle plate to sweep zero-point and full-throttle spring return to calibrate TPS sensor potentiometers.",
        descriptionAr: "معايرة دقيقة لحركة فراشة البوابة الكهربائية من الصفر حتى الفتح الكامل لضبط حساسات الـ TPS.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 45 03 01",
        offCommand: "2F 01 45 00",
        activeDuration: Duration(seconds: 25),
        audibleFeedbackNotice: "Listen for high-pitched motor whine and throttle plate snap in intake manifold.",
        audibleFeedbackNoticeAr: "استمع لصوت تصفير موتور البوابة وتكة قفل الفراشة داخل مانيفولد السحب.",
        liveMonitoringPid: "0145", // Relative Throttle Position
        liveMonitoringUnit: "%",
        icon: Icons.tune,
        steps: [
          ActuationStep(
            id: "tb_prep",
            title: "Pre-Condition & Safety Check",
            titleAr: "فحص شروط الأمان للمعايرة",
            instruction: "Ensure throttle body bore is clean of carbon sludge. Engine must be OFF, Key ON, and accelerator pedal completely released.",
            instructionAr: "تأكد من تنظيف البوابة من الكربون. المحرك مطفأ تماماً، الكونتاكت مفتوح، ودواسة الوقود محررة بالكامل.",
            promptAction: "Pedal released and ready",
            promptActionAr: "الدواسة محررة وجاهز للبدء",
            durationSeconds: 0,
            requiresUserConfirmation: true,
          ),
          ActuationStep(
            id: "tb_zero_point",
            title: "Resting Idle Zero-Point Sweep (0% -> 15%)",
            titleAr: "معايرة نقطة الصفر للسلانسيه (0% -> 15%)",
            instruction: "Commanding throttle plate to resting mechanical stop. Monitoring TPS sensor voltage baseline.",
            instructionAr: "الكنترول يوجه البوابة لمصد السلانسيه الميكانيكي ومطابقة فولتية حساس الـ TPS الابتدائية.",
            promptAction: "Zero-point calibration in progress...",
            promptActionAr: "جاري معايرة نقطة الصفر...",
            durationSeconds: 8,
            requiresUserConfirmation: false,
            commandToSend: "2F 01 45 03 0F",
            stopCommand: "2F 01 45 00",
            monitoredPid: "0145",
            monitoredUnit: "%",
          ),
          ActuationStep(
            id: "tb_full_sweep",
            title: "Full Stroke & Spring Return (100% -> 0%)",
            titleAr: "اختبار الفتح الكامل وسوستة الإرجاع (100% -> 0%)",
            instruction: "Driving throttle valve to wide-open throttle (100%) and releasing motor power to verify return spring snap.",
            instructionAr: "فتح البوابة بنسبة 100% وفصل الكهرباء فجأة لاختبار سرعة ارتداد سوستة البوابة وإحكام الغلق.",
            promptAction: "Full stroke return verification...",
            promptActionAr: "جاري فحص ارتداد السوستة...",
            durationSeconds: 8,
            requiresUserConfirmation: false,
            commandToSend: "2F 01 45 03 64",
            stopCommand: "2F 01 45 00",
            monitoredPid: "0145",
            monitoredUnit: "%",
          ),
        ],
      ),

      // 3. Dual-Speed Radiator Cooling Fan Routine (Guided Procedure)
      const ActuationTestModel(
        id: "radiator_fan_dual_test",
        title: "Radiator Fan Dual-Speed Step-Test",
        titleAr: "اختبار مراوح التبريد بسرعتيها (منخفضة / عالية)",
        systemCategory: "Cooling System",
        description: "Two-stage step test verifying low-speed resistor circuit followed by high-speed relay contact and fan motor amp draw.",
        descriptionAr: "فحص مرحلي لمقاومة السرعة البطيئة ثم تشغيل ريليه السرعة القصوى مع مراقبة هبوط فولت البطارية.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 10 03 01",
        offCommand: "2F 01 10 00",
        activeDuration: Duration(seconds: 24),
        audibleFeedbackNotice: "Listen for distinct low fan hum followed by loud aerodynamic rush on high speed.",
        audibleFeedbackNoticeAr: "استمع لصوت الدوران البطيء الهادئ يعقبه هدير الهواء القوي على السرعة العالية.",
        liveMonitoringPid: "0105", // Coolant Temp
        liveMonitoringUnit: "°C",
        icon: Icons.wind_power,
        steps: [
          ActuationStep(
            id: "fan_low_stage",
            title: "Stage 1: Low-Speed Fan Circuit",
            titleAr: "المرحلة الأولى: سرعة المروحة المنخفضة",
            instruction: "Energizing low-speed cooling fan relay. Verifies low-speed resistor and relay contacts.",
            instructionAr: "تشغيل ريليه السرعة البطيئة للتأكد من سلامة كتاوت ومقاومة السرعة الأولى لمروحة الردياتير.",
            promptAction: "Low-speed running (10s)...",
            promptActionAr: "السرعة البطيئة تعمل (10 ثوان)...",
            durationSeconds: 10,
            requiresUserConfirmation: false,
            commandToSend: "2F 01 11 03 01",
            stopCommand: "2F 01 11 00",
            monitoredPid: "0105",
            monitoredUnit: "°C",
          ),
          ActuationStep(
            id: "fan_pause_stage",
            title: "Inter-Stage Coasting Pause",
            titleAr: "فترة تهدئة بين السرعتين",
            instruction: "Allowing fan motor armature to coast down before energizing high-speed winding to avoid inrush surge.",
            instructionAr: "فصل الكهرباء لثوانٍ لتهدئة عزم دوران المروحة قبل إعطاء السرعة العالية لحماية الفيوزات.",
            promptAction: "Coasting down...",
            promptActionAr: "جاري التهدئة...",
            durationSeconds: 4,
            requiresUserConfirmation: false,
          ),
          ActuationStep(
            id: "fan_high_stage",
            title: "Stage 2: High-Speed Fan Circuit",
            titleAr: "المرحلة الثانية: سرعة المروحة العالية",
            instruction: "Energizing high-speed direct relay. Check for strong airflow forward through condenser and radiator.",
            instructionAr: "تشغيل ريليه السرعة العالية المباشر. تأكد من خروج هواء ساخن قوي عبر الردياتير وسربنتينة التكييف.",
            promptAction: "High-speed running (10s)...",
            promptActionAr: "السرعة العالية تعمل (10 ثوان)...",
            durationSeconds: 10,
            requiresUserConfirmation: false,
            commandToSend: "2F 01 10 03 01",
            stopCommand: "2F 01 10 00",
            monitoredPid: "0142",
            monitoredUnit: "V",
          ),
        ],
      ),

      // 4. Fuel Pump Relay & Pressure Prime
      const ActuationTestModel(
        id: "fuel_pump_prime",
        title: "Fuel Pump Relay Prime",
        titleAr: "تشغيل وتحضير طلمبة البنزين",
        systemCategory: "Fuel System",
        description: "Energizes the in-tank electric fuel pump relay to pressurize the fuel rail without cranking the starter motor.",
        descriptionAr: "تشغيل ريليه طلمبة البنزين الكهربائية داخل التانك لتحضير ضغط الوقود بمسطرة الرشاشات.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 20 03 01",
        offCommand: "2F 01 20 00",
        activeDuration: Duration(seconds: 8),
        audibleFeedbackNotice: "Listen for distinct electric humming buzz under rear passenger seat / fuel tank.",
        audibleFeedbackNoticeAr: "استمع لصوت زن وضخ طلمبة البنزين بوضوح أسفل الكنبة الخلفية / التانك.",
        liveMonitoringPid: "010A", // Fuel Pressure
        liveMonitoringUnit: "kPa",
        icon: Icons.local_gas_station,
      ),

      // 5. A/C Compressor Magnetic Clutch
      const ActuationTestModel(
        id: "ac_compressor_clutch",
        title: "A/C Compressor Magnetic Clutch",
        titleAr: "تفعيل كلتش كمبروسر التكييف",
        systemCategory: "HVAC & Climate",
        description: "Engages and disengages the electromagnetic clutch on the front of the air conditioning compressor pulley.",
        descriptionAr: "تلقيط وفصل الكلتش المغناطيسي لطنبورة كمبروسر التكييف لاختبار المغناطيس وسير التكييف.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 30 03 01",
        offCommand: "2F 01 30 00",
        activeDuration: Duration(seconds: 8),
        audibleFeedbackNotice: "Listen for metallic 'CLICK' sound from the A/C compressor pulley hub.",
        audibleFeedbackNoticeAr: "استمع لصوت تكة معدنية قوية (CLICK) عند تلقيط طنبورة الكمبروسر.",
        liveMonitoringPid: "0142",
        liveMonitoringUnit: "V",
        icon: Icons.ac_unit,
      ),

      // 6. EVAP Canister Purge Solenoid Pulse Test
      const ActuationTestModel(
        id: "evap_purge_solenoid",
        title: "EVAP Canister Purge Solenoid (Click Test)",
        titleAr: "نبضات بلف تفريغ الكانستر EVAP (تكتكة سريعة)",
        systemCategory: "Emissions",
        description: "Pulses the evaporative emission canister purge valve at 10Hz to verify magnetic coil and plunger movement.",
        descriptionAr: "إرسال نبضات كهربائية سريعة 10Hz لبلف الكانستر لاختبار حركة الإبرة وسماع التكتكة.",
        targetEcuHeader: "7E0",
        onCommand: "08 01 00",
        offCommand: "08 00 00",
        activeDuration: Duration(seconds: 10),
        audibleFeedbackNotice: "Touch the EVAP valve near intake manifold and feel/listen for rapid mechanical clicking.",
        audibleFeedbackNoticeAr: "المس بلف الكانستر عند المانيفولد واستشعر التكتكة الميكانيكية السريعة بيدك.",
        liveMonitoringPid: "010B",
        liveMonitoringUnit: "kPa",
        icon: Icons.filter_vintage,
      ),

      // 7. Cylinder Cut-off / Injector Buzz
      const ActuationTestModel(
        id: "cylinder_cut_off",
        title: "Cylinder Power Balance (Injector Buzz)",
        titleAr: "اختبار زن ونبضات رشاشات البنزين",
        systemCategory: "Powertrain",
        description: "Sends test pulse commands to individual fuel injector solenoids to detect weak cylinders or clogged pintles.",
        descriptionAr: "إرسال نبضات اختبارية لسولينويدات رشاشات الوقود لاكتشاف الرشاشات المكتومة أو المعطوبة.",
        targetEcuHeader: "7E0",
        onCommand: "2F 01 40 03 01",
        offCommand: "2F 01 40 00",
        activeDuration: Duration(seconds: 6),
        audibleFeedbackNotice: "Place screwdriver tip or stethoscope against injector body and listen for crisp tapping sound.",
        audibleFeedbackNoticeAr: "ضع سن مفك أو سماعة فحص على جسم الرشاش واستمع لنقرات الفتح والإغلاق الحادة.",
        liveMonitoringPid: "010C",
        liveMonitoringUnit: "RPM",
        icon: Icons.speed,
      ),

      // 8. Instrument Cluster Gauge Sweep
      const ActuationTestModel(
        id: "instrument_cluster_sweep",
        title: "Instrument Cluster Gauge Sweep",
        titleAr: "حركة عقارب الطبلون (عداد السرعة والـ RPM)",
        systemCategory: "Instrument Cluster",
        description: "Commands speedometer, tachometer, fuel level, and temperature needle gauges to sweep 0% -> 50% -> 100% -> 0% to test stepper motors.",
        descriptionAr: "تحريك عقارب السرعة والـ RPM والحرارة والبنزين بالكامل لاختبار مواتير العدادات الدقيقة.",
        targetEcuHeader: "7E4",
        onCommand: "2F 01 50 03 01",
        offCommand: "2F 01 50 00",
        activeDuration: Duration(seconds: 10),
        audibleFeedbackNotice: "Watch instrument panel dials swing to maximum scale and return smoothly.",
        audibleFeedbackNoticeAr: "شاهد عقارب الطبلون وهي تتحرك لأقصى المدى ثم تعود بنعومة لمكانها.",
        liveMonitoringPid: "010D",
        liveMonitoringUnit: "km/h",
        icon: Icons.dashboard,
      ),
    ];
  }
}
