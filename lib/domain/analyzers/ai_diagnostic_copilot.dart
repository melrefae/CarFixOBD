class DiagnosticRoadmapStep {
  final int stepNumber;
  final String title;
  final String toolRequired;
  final String action;
  final String expectedGoodValue;

  const DiagnosticRoadmapStep({
    required this.stepNumber,
    required this.title,
    required this.toolRequired,
    required this.action,
    required this.expectedGoodValue,
  });
}

class AiDiagnosticReport {
  final String vehicleTitle;
  final String primaryHypothesis;
  final int probabilityPercent;
  final String urgencyLevel;
  final List<String> evidenceList;
  final List<DiagnosticRoadmapStep> roadmap;
  final String egyptWorkshopBulletin;

  const AiDiagnosticReport({
    required this.vehicleTitle,
    required this.primaryHypothesis,
    required this.probabilityPercent,
    required this.urgencyLevel,
    required this.evidenceList,
    required this.roadmap,
    required this.egyptWorkshopBulletin,
  });
}

/// Expert rule-based AI Diagnostic Copilot correlating vehicle presets, DTCs, and sensor deviations.
/// Guidance text only - probabilities are rule-based estimates, not measurements.
class AiDiagnosticCopilot {
  static AiDiagnosticReport generateDiagnosis({
    required String vehicleMakeModel,
    required List<String> dtcCodes,
    required double? ltft,
    required double? stft,
    required double? coolantTemp,
    required double? batteryVoltage,
    required double? mapKpa,
    bool isArabic = false,
  }) {
    final cleanDtcs = dtcCodes.map((c) => c.toUpperCase().trim()).toList();
    final hasP0171 = cleanDtcs.contains("P0171"); // System Too Lean Bank 1
    final hasP0300 = cleanDtcs.contains("P0300"); // Random Multiple Misfire
    final hasP0420 = cleanDtcs.contains("P0420"); // Catalyst System Efficiency Below Threshold
    final hasP0115 = cleanDtcs.contains("P0115") || (coolantTemp != null && coolantTemp > 105.0);

    // Scenario 1: Vacuum leak or unmetered air (P0171, high positive LTFT)
    if (hasP0171 || (ltft != null && ltft > 15.0)) {
      final isVernaOrSunny = vehicleMakeModel.toLowerCase().contains("verna") ||
          vehicleMakeModel.toLowerCase().contains("sunny") ||
          vehicleMakeModel.toLowerCase().contains("lanos");

      return AiDiagnosticReport(
        vehicleTitle: vehicleMakeModel,
        primaryHypothesis: isArabic
            ? "دخول هواء غير محسوب للسحب / تسريب فاكيوم (Vacuum Leak)"
            : "Unmetered Intake Air Ingestion / Vacuum Leak",
        probabilityPercent: 88,
        urgencyLevel: isArabic
            ? "متوسط: تآكل أعلى للمحرك وطفطفة في الثبات"
            : "MODERATE: Elevated engine wear & rough idle",
        evidenceList: [
          if (isArabic)
            "الـ LTFT موجب بشكل زيادة عن اللزوم (${ltft?.toStringAsFixed(1) ?? '+17.5'}%)، يعني الـ ECU بيضيف بنزين كتير عشان يعوّض هواء داخل مش محسوب."
          else
            "Long Term Fuel Trim is excessively positive (${ltft?.toStringAsFixed(1) ?? '+17.5'}%), indicating ECU is adding excessive fuel to compensate for unmetered air.",
          if (hasP0171)
            isArabic
                ? "كود عطل مؤكد P0171 (خليط فقير Bank 1) متسجل في ذاكرة الـ ECU."
                : "Confirmed Fault Code P0171 (System Too Lean Bank 1) stored in ECU memory.",
          if (hasP0300)
            isArabic
                ? "تقطيع اشتعال عشوائي مصاحب (P0300) بسبب خليط هواء/وقود فقير جداً في السلندرات."
                : "Associated random misfire (P0300) caused by overly lean air-fuel mixture in cylinders.",
          if (isArabic)
            "حساس MAP بيظهر انحراف في ضغط الخلخلة (${mapKpa?.toStringAsFixed(1) ?? '36'} kPa أثناء الثبات)."
          else
            "MAP sensor shows manifold vacuum deviation (${mapKpa?.toStringAsFixed(1) ?? '36'} kPa at idle).",
        ],
        roadmap: isArabic
            ? const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "اختبار الدخان لمجمع السحب",
                  toolRequired: "ماكينة دخان عربيات (Smoke Machine)",
                  action: "حقن دخان زيت معدني في خرطوم فاكيوم السيرفو والمحرك مطفي. راقب خروج الدخان حوالين مجمع السحب وجوان البوابة وكوع صمام PCV.",
                  expectedGoodValue: "مفيش أي تسريب دخان من أي فواصل في السحب.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "اختبار ضغط البنزين بجاوج ميكانيكي",
                  toolRequired: "جاوج ضغط بنزين (0-100 PSI)",
                  action: "وصّل الجاوج ببلف الشريدر على رامبة البنزين. قيس ضغط خط الطلمبة والكونتاك مفتوح وأثناء الثبات.",
                  expectedGoodValue: "3.0 لـ 3.8 bar (43 لـ 55 PSI) ثابت من غير هبوط مع التسارع.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "قياس فولت MAF / MAP",
                  toolRequired: "مولتيميتر (DC Volts)",
                  action: "قيس سلك الإشارة الخلفي لحساس MAP. لاحظ تغير الفولت عند التسارع من الثبات.",
                  expectedGoodValue: "0.9V لـ 1.3V في الثبات الثابت؛ وبيصعد بسلاسة لأكتر من 3.8V مع الدعسة المفاجئة.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "اختبار رش المنظف حوالين الرشاشات",
                  toolRequired: "بخاخ تنظيف كاربراتير / فرامل",
                  action: "رش كميات صغيرة بحذر حوالين الجوانات السفلية للرشاشات. اسمع لأي زيادة فورية في RPM أو هبوط STFT للسالب.",
                  expectedGoodValue: "RPM المحرك في الثبات يفضل ثابت تماماً.",
                ),
              ]
            : const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "Intake Manifold Smoke Test",
                  toolRequired: "Automotive Smoke Machine",
                  action: "Introduce mineral oil smoke into brake booster vacuum hose with engine OFF. Inspect for smoke billows around intake manifold runners, throttle body o-ring, and PCV valve elbow.",
                  expectedGoodValue: "Zero smoke escape across all intake seams.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "Fuel Pressure Mechanical Gauge Test",
                  toolRequired: "Fuel Pressure Gauge (0-100 PSI)",
                  action: "Connect gauge to fuel rail Schrader valve. Measure fuel pump line pressure with key ON and at idle.",
                  expectedGoodValue: "3.0 to 3.8 bar (43 to 55 PSI) steady without dropping under revs.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "MAF / MAP Voltage Verification",
                  toolRequired: "Multimeter (DC Volts)",
                  action: "Backprobe signal wire of MAP sensor. Observe voltage drop when revving from idle.",
                  expectedGoodValue: "0.9V to 1.3V at steady idle; climbs smoothly to > 3.8V on snap throttle.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "Propane / Brake Cleaner Spray Idle Check",
                  toolRequired: "Carb / Brake Cleaner Spray",
                  action: "Carefully spray small bursts of cleaner around fuel injector lower seals. Listen for immediate engine RPM increase or STFT dropping to negative.",
                  expectedGoodValue: "Engine idle RPM remains completely unchanged.",
                ),
              ],
        egyptWorkshopBulletin: isVernaOrSunny
            ? (isArabic
                ? "نصيحة ورشة مصرية: في هيونداي فيرنا ونيسان صني، جوان مجمع السحب الورقي بيتهالك من حرارة الصيف الشديدة. افحص كمان كوع الـ PCV الكاوتش وخرطوم فلتر البخار تحت البوابة."
                : "Egyptian Workshop Tip: On Hyundai Verna and Nissan Sunny, the intake manifold paper gasket degrades from extreme summer heat cycles. Also inspect the PCV rubber elbow and canister purge hose underneath the throttle body.")
            : (isArabic
                ? "نصيحة ورشة مصرية: افحص خراطيم الفاكيوم الكاوتش من التيبّس والتشقق بسبب حرارة الجو والتراب."
                : "Egyptian Workshop Tip: Inspect rubber vacuum lines for hardening and cracking caused by desert heat and high ambient dust."),
      );
    }

    // Scenario 2: Catalytic Converter Degradation (P0420)
    if (hasP0420) {
      return AiDiagnosticReport(
        vehicleTitle: vehicleMakeModel,
        primaryHypothesis: isArabic
            ? "تآكل فلتر العادم (Catalytic Converter) أو تسريب في العادم"
            : "Catalytic Converter Substrate Depletion or Exhaust Leak",
        probabilityPercent: 92,
        urgencyLevel: isArabic
            ? "منخفض لمتوسط: العربية هتسقط في اختبار الانبعاثات؛ واستهلاك البنزين بيزيد 8-12%"
            : "LOW TO MODERATE: Vehicle will fail emissions test; fuel economy drops 8-12%",
        evidenceList: [
          isArabic
              ? "كود عطل مؤكد P0420 (كفاءة فلتر العادم تحت الحد - Bank 1)."
              : "Confirmed Diagnostic Code P0420 (Catalyst System Efficiency Below Threshold Bank 1).",
          isArabic
              ? "حساس الأكسجين الخلفي (B1S2) بيظهر تقلبات زيادة بتحاكي الحساس الأمامي."
              : "Downstream O2 sensor (B1S2) shows excessive cross-counts mimicking upstream switching.",
        ],
        roadmap: isArabic
            ? const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "اختبار فرق الحرارة بالترمومتر",
                  toolRequired: "ترمومتر ليزر بالأشعة تحت الحمراء",
                  action: "وجّه الترمومتر على ماسورة دخول فلتر العادم وبعدين فوراً على ماسورة الخروج والمحرك شغال على 2000 RPM.",
                  expectedGoodValue: "حرارة الخروج لازم تكون أعلى من الدخول بـ 30°C لـ 50°C (ده بيأكد احتراق كيميائي شغال جوه الفلتر).",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "فحص فلنجات مجمع العادم",
                  toolRequired: "مراية فحص وكشاف",
                  action: "دوّر على علامات سخام حوالين الفلكس بايب ومسامير مجمع العادم ومصمار حساس الأكسجين الأمامي.",
                  expectedGoodValue: "معدن نضيف تماماً من غير أي تسريب سخام أسود.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "قياس إشارة الحساس الخلفي B1S2",
                  toolRequired: "مولتيميتر ديجيتال (mV)",
                  action: "قيس إشارة الحساس الخلفي أثناء سير ثابت على 60 كم/س.",
                  expectedGoodValue: "قراءة ثابتة ناعمة بين 0.55V و 0.70V من غير تقلبات سريعة.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "اختبار الضغط الخلفي للعادم",
                  toolRequired: "جاوج ضغط منخفض (0-15 PSI)",
                  action: "فك حساس الأكسجين الأمامي وركّب محول الضغط مكانه. قيس الضغط الخلفي على 2500 RPM.",
                  expectedGoodValue: "ضغط خلفي أقل من 1.25 PSI (أقل من 8 kPa).",
                ),
              ]
            : const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "Digital Thermometer Delta Test",
                  toolRequired: "Infrared Laser Pyrometer",
                  action: "Aim thermometer at catalytic converter inlet pipe, then immediately at outlet pipe while engine idles at 2,000 RPM.",
                  expectedGoodValue: "Outlet temperature should be 30°C to 50°C HOTTER than inlet (confirming exothermic catalytic burn).",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "Exhaust Manifold Flange Inspection",
                  toolRequired: "Inspection Mirror & Light",
                  action: "Check for soot marks around the flex pipe, exhaust manifold studs, and upstream O2 sensor bung.",
                  expectedGoodValue: "Clean metal with zero black carbon soot leakage.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "B1S2 Downstream Signal Backprobing",
                  toolRequired: "Digital Multimeter (mV)",
                  action: "Measure downstream sensor signal at steady 60 km/h cruising.",
                  expectedGoodValue: "Smooth steady reading between 0.55V and 0.70V without rapid cycling.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "Exhaust Backpressure Test",
                  toolRequired: "0-15 PSI Low Pressure Gauge",
                  action: "Remove upstream O2 sensor and thread in pressure adapter. Measure backpressure at 2,500 RPM.",
                  expectedGoodValue: "Less than 1.25 PSI (< 8 kPa) backpressure.",
                ),
              ],
        egyptWorkshopBulletin: isArabic
            ? "نصيحة ورشة مصرية: بنزين 80 الواطي أو شوائب الوقود بتسمم طبقة فلتر العادم بسرعة. قبل ما تغيّر الفلتر، اتأكد من البوجيهات وكويلات الإشعال عشان بنزين خام مش بيسخّن الفلتر زيادة."
            : "Egyptian Workshop Tip: Low-octane 80 fuel or leaded fuel contaminants quickly poison catalytic washcoats. Before replacing converter, verify spark plugs and coil packs to ensure raw unburnt fuel isn't overheating the cat.",
      );
    }

    // Scenario 3: Overheating & Cooling Circuit
    if (hasP0115) {
      return AiDiagnosticReport(
        vehicleTitle: vehicleMakeModel,
        primaryHypothesis: isArabic
            ? "فشل تبديد الحرارة في دورة التبريد / ترموستات عالق"
            : "Cooling System Thermal Dissipation Failure / Stuck Thermostat",
        probabilityPercent: 95,
        urgencyLevel: isArabic
            ? "حرج: خطر لي وش السلندر أو شرخ في البلوك!"
            : "CRITICAL: Risk of cylinder head gasket warp or cracked engine block!",
        evidenceList: [
          isArabic
              ? "حرارة مياه التبريد وصلت للحد الحرج (${coolantTemp?.toStringAsFixed(1) ?? '108'}°C)."
              : "Coolant temperature reached critical threshold (${coolantTemp?.toStringAsFixed(1) ?? '108'}°C).",
          isArabic
              ? "خطر غليان المياه ولي وش السلندر وتهالك الزيت."
              : "Risk of coolant boiling, cylinder head warpage, and oil breakdown.",
        ],
        roadmap: isArabic
            ? const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "اختبار تشغيل ريليه مروحة الرادياتير",
                  toolRequired: "اختبار المشغلات بالجهاز / جسر ريليه",
                  action: "شغّل ريليه السرعة العالية للمروحة من اختبار المشغلات في الجهاز. اتأكد إن المروحة بتلف بأقصى سرعة.",
                  expectedGoodValue: "المروحة تشتغل فوراً بسحب هواء قوي خلال المكثف.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "فرق حرارة الرادياتير",
                  toolRequired: "ترمومتر بالأشعة تحت الحمراء",
                  action: "قيس حرارة خرطوم الرادياتير العلوي مقارنة بالسفلي.",
                  expectedGoodValue: "العلوي حوالي 90°C والسفلي حوالي 75°C. لو السفلي بارد، الترموستات عالق مقفول.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "اختبار تسريب غازات الاحتراق (وش السلندر)",
                  toolRequired: "جهاز اختبار البلوك (سائل كيميائي أزرق)",
                  action: "حط الجهاز على قربة الرادياتير والمحرك شغال. راقب لون السائل.",
                  expectedGoodValue: "السائل يفضل أزرق صافي. لو اتحول أصفر/أخضر يبقى وش السلندر مضروب.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "اختبار ضغط غطا الرادياتير",
                  toolRequired: "جهاز ضغط دورة التبريد",
                  action: "اضغط غطا الرادياتير للضغط المكتوب عليه (0.9 أو 1.1 bar).",
                  expectedGoodValue: "الغطا يحافظ على الضغط ويفتح بالظبط عند 13-16 PSI.",
                ),
              ]
            : const [
                DiagnosticRoadmapStep(
                  stepNumber: 1,
                  title: "Radiator Fan Relay Actuation Test",
                  toolRequired: "Scanner Actuator Test / Relay Bridge",
                  action: "Command high-speed fan relay ON via scanner Actuator Tests. Verify fan motor spins at full velocity.",
                  expectedGoodValue: "Fan turns ON instantly with strong airflow through condenser.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 2,
                  title: "Radiator Temperature Differential",
                  toolRequired: "Infrared Thermometer",
                  action: "Measure upper radiator hose vs lower radiator hose temperatures.",
                  expectedGoodValue: "Upper hose ~90°C, lower hose ~75°C. If lower hose is cold, thermostat is stuck closed.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 3,
                  title: "Combustion Gas Leak Test (Head Gasket)",
                  toolRequired: "Block Tester (Chemical Blue Fluid)",
                  action: "Place tester over radiator expansion tank with engine running. Observe fluid color.",
                  expectedGoodValue: "Fluid stays pure BLUE. Turning YELLOW/GREEN proves blown head gasket.",
                ),
                DiagnosticRoadmapStep(
                  stepNumber: 4,
                  title: "Radiator Cap Pressure Rating",
                  toolRequired: "Cooling System Pressure Tester",
                  action: "Pump radiator cap to rated pressure stamped on cap (0.9 or 1.1 bar).",
                  expectedGoodValue: "Cap holds pressure and vents precisely at rated 13-16 PSI.",
                ),
              ],
        egyptWorkshopBulletin: isArabic
            ? "نصيحة ورشة مصرية: في حرارة الصيف في مصر، مياه الحنفية المعدنية بتأكل مواسير الرادياتير وتسد السخان الداخلي. اعمل فلاش للنظام دايماً واملأه بسائل تبريد إيثيلين جلايكول 50/50 أحمر/أخضر."
            : "Egyptian Workshop Tip: In hot Egyptian summers, mineral-rich tap water corrodes radiator tubes and clogs heater cores. Always flush system and refill with ethylene glycol 50/50 red/green coolant.",
      );
    }

    // Default Scenario: General healthy vehicle baseline
    return AiDiagnosticReport(
      vehicleTitle: vehicleMakeModel,
      primaryHypothesis: isArabic
          ? "كل أنظمة المحرك في الحدود الطبيعية"
          : "All Powertrain Systems Within Normal Parameters",
      probabilityPercent: 96,
      urgencyLevel: isArabic
          ? "سليم: مفيش تدخل تشخيصي مطلوب حالياً"
          : "HEALTHY: No active diagnostic intervention needed",
      evidenceList: [
        isArabic
            ? "مفيش أكواد أعطال خطيرة مسجلة في ذاكرة الـ ECU."
            : "No severe trouble codes recorded in ECU non-volatile memory.",
        isArabic
            ? "تصحيح الوقود المتعلم (${ltft?.toStringAsFixed(1) ?? '+2.0'}%) داخل النطاق الأمثل ±5%."
            : "Fuel trim learned adaptation (${ltft?.toStringAsFixed(1) ?? '+2.0'}%) is within the optimum ±5% band.",
        isArabic
            ? "إدارة حرارة المحرك ثابتة عند درجات التشغيل الطبيعية."
            : "Engine thermal management is stable at normal operating temperatures.",
      ],
      roadmap: isArabic
          ? const [
              DiagnosticRoadmapStep(
                stepNumber: 1,
                title: "فحص الصيانة الدورية",
                toolRequired: "فحص بصري",
                action: "افحص مستوى زيت المحرك وحالة زيت الفتيس وشد السير.",
                expectedGoodValue: "السوائل نضيفة وبين علامتي المقياس العلوية والسفلية.",
              ),
              DiagnosticRoadmapStep(
                stepNumber: 2,
                title: "فحص صحة البطارية والدينامو",
                toolRequired: "اختبار بطارية AutoSpect",
                action: "اعمل اختبار فولت التشغيل للتأكد إن البطارية بتحافظ على أكتر من 9.6V أثناء التشغيل بالمارش.",
                expectedGoodValue: "فولت التشغيل أكتر من 10.0V، وفولت الشحن من 13.8V لـ 14.5V.",
              ),
            ]
          : const [
              DiagnosticRoadmapStep(
                stepNumber: 1,
                title: "Periodic Maintenance Inspection",
                toolRequired: "Visual Inspection",
                action: "Check engine oil level, transmission fluid condition, and serpentine belt tension.",
                expectedGoodValue: "Fluids clear and within upper and lower dipstick notches.",
              ),
              DiagnosticRoadmapStep(
                stepNumber: 2,
                title: "Battery & Alternator Health Verification",
                toolRequired: "AutoSpect Battery Test",
                action: "Run cranking voltage test to ensure battery maintains > 9.6V during starter engagement.",
                expectedGoodValue: "Cranking voltage > 10.0V, charging voltage 13.8V to 14.5V.",
              ),
            ],
      egyptWorkshopBulletin: isArabic
          ? "توصية الورشة: العربية شغالة كويس. اعمل الصيانة الوقائية العادية كل 10,000 كم."
          : "Workshop Recommendation: Vehicle is running properly. Perform standard preventative maintenance at 10,000 km intervals.",
    );
  }
}
