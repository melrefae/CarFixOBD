/// Models for Augmented Reality (AR) Engine Bay Component HUD
enum EngineComponentCategory {
  sensor,
  actuator,
  ignition,
  module,
  harness,
}

class EngineComponentTag {
  final String id;
  final String nameEn;
  final String nameAr;
  final EngineComponentCategory category;
  final double relativeX;
  final double relativeY;
  final String livePidCode;
  final String nominalReadingEn;
  final String nominalReadingAr;
  final String liveUnits;
  final double defaultLiveValue;
  final String multimeterTestTipEn;
  final String multimeterTestTipAr;
  final String failureSymptomEn;
  final String failureSymptomAr;
  final String pinoutSummary;

  const EngineComponentTag({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.relativeX,
    required this.relativeY,
    required this.livePidCode,
    required this.nominalReadingEn,
    required this.nominalReadingAr,
    required this.liveUnits,
    required this.defaultLiveValue,
    required this.multimeterTestTipEn,
    required this.multimeterTestTipAr,
    required this.failureSymptomEn,
    required this.failureSymptomAr,
    required this.pinoutSummary,
  });

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String nominalReading(bool isArabic) => isArabic ? nominalReadingAr : nominalReadingEn;
  String multimeterTestTip(bool isArabic) => isArabic ? multimeterTestTipAr : multimeterTestTipEn;
  String failureSymptom(bool isArabic) => isArabic ? failureSymptomAr : failureSymptomEn;

  static const List<EngineComponentTag> standardEngineBay = [
    EngineComponentTag(
      id: "MAF_SENSOR",
      nameEn: "Mass Air Flow (MAF) Sensor",
      nameAr: "حساس كتلة الهواء المتدفق (MAF)",
      category: EngineComponentCategory.sensor,
      relativeX: 0.25,
      relativeY: 0.35,
      livePidCode: "0110",
      nominalReadingEn: "2.0 - 5.5 g/s at idle (1.0V - 1.4V)",
      nominalReadingAr: "2.0 إلى 5.5 جم/ثانية على السلانسيه (1.0 إلى 1.4 فولت)",
      liveUnits: "g/s",
      defaultLiveValue: 3.4,
      multimeterTestTipEn: "Backprobe Pin 3 with DC Volts against engine ground. Voltage should sweep smoothly from 1.0V to 4.5V during wide open throttle snap.",
      multimeterTestTipAr: "قس الفولت بالطرف 3 ضد الأرضي. يجب أن يرتفع الفولت بسلاسة من 1.0 إلى 4.5 فولت مع الدوسة الفجائية.",
      failureSymptomEn: "Black exhaust smoke, hesitation, P0101, P0171 lean bank 1.",
      failureSymptomAr: "دخان أسود من الشكمان، تقطيع في السحب، كود P0101 أو P0171 خليط فقير.",
      pinoutSummary: "Pin 1: 12V B+ | Pin 2: Ground | Pin 3: Signal (0-5V) | Pin 4: IAT Sensor",
    ),
    EngineComponentTag(
      id: "O2_UPSTREAM",
      nameEn: "Upstream Oxygen Sensor (B1S1)",
      nameAr: "حساس الشكمان الأمامي (بنك 1 قبل البيئة)",
      category: EngineComponentCategory.sensor,
      relativeX: 0.72,
      relativeY: 0.32,
      livePidCode: "0114",
      nominalReadingEn: "Rapid cycle 0.1V - 0.9V (1-2 Hz switching)",
      nominalReadingAr: "تردد سريع وموجات بين 0.1 إلى 0.9 فولت (1-2 هيرتز)",
      liveUnits: "V",
      defaultLiveValue: 0.65,
      multimeterTestTipEn: "Measure heater element pins with Ohmmeter: 8-16 Ohms cold. Signal pin toggles rapidly between 0.1V (lean) and 0.9V (rich).",
      multimeterTestTipAr: "قس مقاومة سخان الحساس بالأومميتر: 8 إلى 16 أوم. طرف الإشارة يتأرجح بين 0.1 و 0.9 فولت.",
      failureSymptomEn: "High fuel consumption, sulfur smell, P0130, P0133 slow response.",
      failureSymptomAr: "استهلاك بنزين عالي جداً، رائحة كبريت عادمة، كود P0130 أو P0133 بطء استجابة.",
      pinoutSummary: "Pin 1: Heater + | Pin 2: Heater - (PWM) | Pin 3: Sensor Ground | Pin 4: Signal Out",
    ),
    EngineComponentTag(
      id: "O2_DOWNSTREAM",
      nameEn: "Downstream Oxygen Sensor (B1S2)",
      nameAr: "حساس الشكمان الخلفي (بعد علبة البيئة)",
      category: EngineComponentCategory.sensor,
      relativeX: 0.82,
      relativeY: 0.60,
      livePidCode: "0115",
      nominalReadingEn: "Steady 0.6V - 0.75V when catalytic converter is healthy",
      nominalReadingAr: "فولتية شبه ثابتة 0.6 إلى 0.75 فولت عند سلامة علبة البيئة",
      liveUnits: "V",
      defaultLiveValue: 0.68,
      multimeterTestTipEn: "If downstream signal mirrors upstream sinusoidal switching, catalytic converter has degraded or was gutted.",
      multimeterTestTipAr: "إذا أصبحت قراءة الحساس الخلفي متذبذبة مثل الأمامي، فعلبة البيئة مسدودة أو مفرغة تماماً.",
      failureSymptomEn: "P0420 catalytic converter efficiency below threshold.",
      failureSymptomAr: "كود P0420 كفاءة المحول الحفاز أقل من الحد الأدنى.",
      pinoutSummary: "Pin 1: Heater + | Pin 2: Heater Ground | Pin 3: Signal Ground | Pin 4: 0.45V Bias",
    ),
    EngineComponentTag(
      id: "IGNITION_COIL_BANK",
      nameEn: "Direct Ignition Coils (COP)",
      nameAr: "موبينات الإشعال المباشرة وشمعات الاحتراق",
      category: EngineComponentCategory.ignition,
      relativeX: 0.52,
      relativeY: 0.28,
      livePidCode: "010C",
      nominalReadingEn: "Primary dwell: 2.2 - 2.8 ms, Spark burn: 1.4 - 1.8 ms",
      nominalReadingAr: "زمن شحن الموبينة: 2.2 إلى 2.8 مللي ثانية، زمن الشرارة: 1.4 إلى 1.8 مللي ثانية",
      liveUnits: "ms",
      defaultLiveValue: 2.4,
      multimeterTestTipEn: "Check 12V supply pin with test light. Verify 5V square-wave trigger pulse from ECM using scope or logic probe.",
      multimeterTestTipAr: "تأكد من وصول 12 فولت باللمبة الفاحصة. قس نبضة إشارة الكنترول 5 فولت بمسبار التردد.",
      failureSymptomEn: "Engine shake under acceleration, P0300, P0301-P0304 single cylinder misfires.",
      failureSymptomAr: "رجة شديدة بالمحرك مع التسارع، كود P0300 تفتفة عشوائية، أو P0301 تفتفة سلندر.",
      pinoutSummary: "Pin 1: +12V Ignition | Pin 2: Cylinder Head Ground | Pin 3: ECM 5V Trigger Pulse",
    ),
    EngineComponentTag(
      id: "THROTTLE_BODY",
      nameEn: "Electronic Throttle Body (Drive-by-Wire)",
      nameAr: "البوابة الإلكترونية (الأكسراتير الكهربائي)",
      category: EngineComponentCategory.actuator,
      relativeX: 0.38,
      relativeY: 0.45,
      livePidCode: "0111",
      nominalReadingEn: "TPS1: 0.5V - 4.5V, TPS2: 4.5V - 0.5V (Sum = 5.0V)",
      nominalReadingAr: "TPS1: من 0.5 إلى 4.5 فولت، TPS2: عكسي من 4.5 إلى 0.5 فولت (مجموعهما = 5 فولت)",
      liveUnits: "%",
      defaultLiveValue: 12.8,
      multimeterTestTipEn: "TPS1 and TPS2 potentiometer voltages must always sum to 5.0V within +/-0.2V. Motor resistance should be 2.5 - 6.0 Ohms.",
      multimeterTestTipAr: "مجموع جهد TPS1 و TPS2 يجب أن يساوي 5.0 فولت بالضبط. مقاومة موتور البوابة بين 2.5 إلى 6 أوم.",
      failureSymptomEn: "Limp mode, pedal dead band, P2135 TPS correlation mismatch.",
      failureSymptomAr: "دخول السيارة في وضع العرجان وحماية السرعة، كود P2135 عدم تطابق بوابات الأكسراتير.",
      pinoutSummary: "Pin 1: Motor + | Pin 2: Motor - | Pin 3: 5V Ref | Pin 4: TPS1 Sig | Pin 5: Ground | Pin 6: TPS2 Sig",
    ),
    EngineComponentTag(
      id: "HPFP_PUMP",
      nameEn: "High-Pressure Common Rail Pump (GDI)",
      nameAr: "طلمبة الضغط العالي بالرش المباشر (GDI / Diesel)",
      category: EngineComponentCategory.actuator,
      relativeX: 0.65,
      relativeY: 0.42,
      livePidCode: "0123",
      nominalReadingEn: "Idle: 35 - 50 Bar, Acceleration: 140 - 200 Bar",
      nominalReadingAr: "السلانسيه: 35 إلى 50 بار، التسارع القوي: 140 إلى 200 بار",
      liveUnits: "Bar",
      defaultLiveValue: 45.0,
      multimeterTestTipEn: "Measure spill control solenoid valve coil resistance: 0.5 to 1.5 Ohms. Never loosen high-pressure fuel lines while engine is running!",
      multimeterTestTipAr: "قس مقاومة بلف التحكم في الضغط: 0.5 إلى 1.5 أوم. احذر فك خراطيم الضغط العالي أثناء الدوران!",
      failureSymptomEn: "Extended cranking, cut-out above 3000 RPM, P0087 fuel rail pressure low.",
      failureSymptomAr: "تأخير طويل في المارش، تقطيع فوق 3000 لفة، كود P0087 انخفاض ضغط مسطرة الرشاشات.",
      pinoutSummary: "Pin 1: 12V Switched Power | Pin 2: ECM High-Side Current Drive Pulse",
    ),
    EngineComponentTag(
      id: "ECT_SENSOR",
      nameEn: "Engine Coolant Temperature (ECT) Sensor",
      nameAr: "حساس درجة حرارة مياه التبريد (كوعة الثرموستات)",
      category: EngineComponentCategory.sensor,
      relativeX: 0.48,
      relativeY: 0.65,
      livePidCode: "0105",
      nominalReadingEn: "Cold (20 deg C): 2.5k - 3.0k Ohms; Hot (90 deg C): 200 - 300 Ohms",
      nominalReadingAr: "بارد (20 مئوية): 2.5 إلى 3 كيلو أوم؛ ساخن (90 مئوية): 200 إلى 300 أوم",
      liveUnits: "deg C",
      defaultLiveValue: 88.0,
      multimeterTestTipEn: "Verify 5.0V reference voltage with sensor disconnected. As engine warms from cold to 90 deg C, signal voltage should drop smoothly from 3.5V to 0.6V.",
      multimeterTestTipAr: "تأكد من وجود 5.0 فولت بالفيشة مفصولة. مع سخونة المحرك ينخفض الفولت بسلاسة من 3.5 إلى 0.6 فولت.",
      failureSymptomEn: "Cooling radiator fan stays ON continuously on high speed, hard start when cold, P0117/P0118.",
      failureSymptomAr: "مراوح التبريد تعمل باستمرار بأعلى سرعة، صعوبة في التشغيل الصباحي، كود P0117/P0118.",
      pinoutSummary: "Pin 1: 5.0V Pull-Up Reference | Pin 2: Low-Noise Sensor Ground",
    ),
    EngineComponentTag(
      id: "SGW_MODULE",
      nameEn: "Security Gateway (SGW) & DLC Port",
      nameAr: "بوابة الحماية الإلكترونية (SGW) وفيشة الفحص OBD2",
      category: EngineComponentCategory.module,
      relativeX: 0.15,
      relativeY: 0.75,
      livePidCode: "0000",
      nominalReadingEn: "CAN-H Pin 6: 2.5V - 3.5V, CAN-L Pin 14: 1.5V - 2.5V (60 Ohms terminating)",
      nominalReadingAr: "CAN-H طرف 6: 2.5 إلى 3.5 فولت، CAN-L طرف 14: 1.5 إلى 2.5 فولت (مقاومة 60 أوم)",
      liveUnits: "V",
      defaultLiveValue: 2.5,
      multimeterTestTipEn: "Disconnect battery and measure resistance between Pin 6 and Pin 14: exactly 60 Ohms (two 120-Ohm resistors in parallel).",
      multimeterTestTipAr: "افصل البطارية وقس المقاومة بين طرف 6 وطرف 14: يجب أن تظهر 60 أوم بالضبط (مقاومتي إنهاء 120 أوم).",
      failureSymptomEn: "Diagnostic tool unable to communicate with vehicle or unable to clear fault codes (ECU Security Access Denied).",
      failureSymptomAr: "الجهاز لا يستطيع الاتصال بالسيارة أو لا يستطيع مسح الأعطال بسبب قفل البوابة الأمنية.",
      pinoutSummary: "Pin 4: Chassis Ground | Pin 5: Signal Ground | Pin 6: CAN High | Pin 14: CAN Low | Pin 16: +12V Battery Constant",
    ),
  ];
}
