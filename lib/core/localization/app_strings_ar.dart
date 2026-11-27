/// Egyptian Workshop Arabic localization for AutoSpect OBD2 diagnostic application
class AppStringsAr {
  // Application branding
  static const String appName = "أسبكت أوتو سكان";
  static const String appSubtitle = "نظام الفحص التشخيصي الاحترافي لأعطال السيارات";
  static const String appTagline = "الفحص المتقدم لكنترولات السيارات وقراءة الحساسات";
  static const String defaultWorkshopName = "مركز أسبكت لصيانة وبرمجة السيارات";
  static const String defaultWorkshopPhone = "+201553666635";
  static const String defaultWorkshopAddress = "القاهرة، جمهورية مصر العربية";

  // Navigation & Primary Actions
  static const String quickScan = "فحص سريع شامل (30 ثانية)";
  static const String readDtcs = "أكواد الأعطال (DTCs)";
  static const String dtcEncyclopedia = "موسوعة أكواد الأعطال";
  static const String liveSensors = "البيانات الحية والحساسات";
  static const String liveGraphs = "الرسوم البيانية والإشارات اللحظية";
  static const String freezeFrame = "تجميد بيانات العطل (Freeze Frame)";
  static const String fuelTrimAnalysis = "تحليل تصحيح الوقود وتهريب الهواء";
  static const String batteryTest = "فحص شحن الدينامو واختبار المارش";
  static const String adapterBenchmark = "اختبار كفاءة وسرعة فيشة الـ OBD";
  static const String vehicleProfiles = "قاعدة بيانات السيارات و250+ ماركة";
  static const String inspectionReports = "تقارير فحص العملاء وإيصالات الورشة";
  static const String terminal = "موجه أوامر ELM327 Terminal";
  static const String settings = "إعدادات المركز والتنبيهات الصوتية";

  // Navigation additions matching Diagzone Pro
  static const String diagzoneSpecialFunctions = "وظائف دياجزون الخاصة (37 ريست)";
  static const String diagzoneSubtitle = "ريست الزيت، تيل الكهرباء، البوابة، التبريد، والـ DSG";
  static const String ecuCoding = "تفعيل الخفايا وتكويد الكنترول (ECU Coding)";
  static const String ecuCodingSubtitle = "حركة العدادات، طي المرايات، نهاري DRL، وإلغاء جرس الحزام";
  static const String sgwAssistant = "مساعد تخطي حماية البوابة (SGW Bypass)";
  static const String sgwAssistantSubtitle = "مخطط فيشات فيات 12+8 ورينو ونيسان ومواقع الكنترول";
  static const String actuatorTests = "اختبارات المشغلات الثنائية (Actuator Tests)";
  static const String actuatorSubtitle = "تشغيل مراوح التبريد، طلمبة البنزين، الرشاشات، وبلف الكانستر";
  static const String multiEcuTopology = "طوبولوجيا شبكة الكان ومسح الكنترولات";
  static const String multiEcuSubtitle = "فحص كمبيوتر الموتور، الفتيس، الإيرباج، والـ ABS معاً";
  static const String catalyticAnalyzer = "فحص حساس الشكمان وكفاءة علبة البيئة";
  static const String catalyticSubtitle = "مقارنة إشارة الحساس الأمامي B1S1 مع الخلفي B1S2";
  static const String flightRecorder = "الصندوق الأسود لتسجيل الرحلة والبيانات";
  static const String flightRecorderSubtitle = "تسجيل الحساسات عند السرعات العالية وإعادة العرض";
  static const String performanceDyno = "داينو التسارع وقياس القوة الحصانية";
  static const String performanceSubtitle = "تسارع 0-100 كم/س، وربع ميل، وحساب القدرة الحصانية";
  static const String fuelEconomyEgp = "حاسبة استهلاك البنزين وتكلفة المشوار";
  static const String fuelEconomySubtitle = "حساب اللتر/100كم حسب أسعار بنزين 80/92/95 والسولار بمصر";
  static const String hudNightMode = "شاشة العرض الزجاجي الليلي (HUD)";
  static const String hudSubtitle = "انعكاس مرآتي فائق الوضوح على زجاج السيارة";
  static const String aiCopilot = "المساعد الذكي لتشخيص الأعطال (AI Copilot)";
  static const String aiCopilotSubtitle = "شجرة قرارات الأعطال مرتبة حسب تجارب الورش المصرية";

  // Connection & Hardware States
  static const String connectionTitle = "مدير الاتصال بفيشة ELM327";
  static const String connected = "متصل بكمبيوتر السيارة";
  static const String adapterOnlyConnected = "الفيشة متصلة (افتح كونتاك السيارة ON)";
  static const String connecting = "جاري الاتصال بفيشة الفحص...";
  static const String disconnected = "غير متصل";
  static const String simulationMode = "وضع المحاكاة (بدون سيارة)";
  static const String switchMode = "تبديل وسيلة الاتصال";
  static const String disconnect = "قطع الاتصال";
  static const String connect = "اتصال";
  static const String autoDetect = "كشف واتصال تلقائي فوري";
  static const String autoDetectSubtitle = "البحث الذكي عن أي فيشة بلوتوث والربط المباشر";
  static const String scanningBluetooth = "جاري مسح أجهزة البلوتوث المجاورة...";
  static const String pairedDevices = "الأجهزة المقترنة مسبقاً";
  static const String discoveredDevices = "الأجهزة المكتشفة في النطاق";
  static const String noPairedDevices = "لا توجد فيشات بلوتوث مقترنة";
  static const String pairDevicePrompt = "تأكد من تركيب الفيشة بمخرج الـ OBD واقترانها في إعدادات البلوتوث (الرمز غالباً 1234 أو 0000).";
  static const String obdCandidate = "فيشة فحص OBD";
  static const String unknownDevice = "جهاز عام";

  // Diagnostic Trouble Codes
  static const String storedDtcs = "الأعطال المؤكدة المسجلة (Mode 03)";
  static const String pendingDtcs = "الأعطال المعلقة قيد التحقق (Mode 07)";
  static const String permanentDtcs = "الأعطال الدائمة غير القابلة للمسح (Mode 0A)";
  static const String noDtcsFound = "لا توجد أعطال مسجلة. كنترول المحرك يعمل بحالة ممتازة!";
  static const String clearDtcsButton = "مسح جميع الأعطال وإطفاء لمبة المحرك (Mode 04)";
  static const String clearWarningTitle = "تأكيد أمان الفحص الهام";
  static const String clearWarningBody = "تأكد من إيقاف تشغيل المحرك تماماً مع فتح الكونتاك (Key ON, Engine OFF).\n\nمسح الأعطال سيقوم بإطفاء لمبة التشك، وإعادة ضبط قيم تصحيح الوقود المتعلمة، وتصفير جاهزية الانبعاثات. هل تريد المتابعة؟";
  static const String confirmClear = "نعم، المحرك مطفأ والكونتاك مفتوح";
  static const String cancel = "إلغاء";
  static const String dtcsClearedSuccess = "تم مسح جميع الأعطال وإطفاء لمبة المحرك بنجاح!";
  static const String dtcSeverityHigh = "عطل حرج";
  static const String dtcSeverityMedium = "عطل متوسط";
  static const String dtcSeverityLow = "عطل بسيط";
  static const String possibleCauses = "الأسباب الشائعة المحتملة:";
  static const String symptoms = "أعراض العطل على أداء السيارة:";
  static const String workshopCheck = "خطوات الفحص في الورشة واستخدام الآفوميتر:";

  // Quick Scan & Summary
  static const String vinLabel = "رقم الشاسيه (VIN):";
  static const String protocolLabel = "بروتوكول الكان الفعّال:";
  static const String batteryVoltageLabel = "فولت البطارية:";
  static const String milStatusLabel = "حالة لمبة المحرك (Check Engine):";
  static const String milOn = "مضاءة (توجد أعطال مسجلة)";
  static const String milOff = "مطفأة (لا توجد أعطال نشطة)";
  static const String readinessMonitors = "جاهزية اختبارات الانبعاثات:";
  static const String quickScanTitle = "فحص سريع شامل في 30 ثانية";
  static const String runQuickScan = "بدء الفحص السريع";
  static const String scanningVinMil = "قراءة رقم الشاسيه وبروتوكول الاتصال وحالة اللمبة...";
  static const String quickScanComplete = "اكتمل الفحص السريع بنجاح";

  // Common Sensors (PIDs)
  static const String allSensors = "جميع الحساسات";
  static const String engineSensors = "المحرك والسرعة";
  static const String fuelAirSensors = "منظومة الوقود والهواء";
  static const String coolingSensors = "دورة التبريد والحرارة";
  static const String electricalSensors = "الكهرباء والشحن";
  static const String rpmName = "دوران المحرك (RPM)";
  static const String speedName = "سرعة السيارة";
  static const String coolantTempName = "حرارة مياه التبريد";
  static const String intakeTempName = "حرارة الهواء الداخل";
  static const String mapName = "ضغط المانيفولد (حساس الماب)";
  static const String mafName = "تدفق الهواء (حساس الماف)";
  static const String throttleName = "فتحة البوابة (حساس الدعسة TPS)";
  static const String stftName = "تصحيح الوقود اللحظي (STFT)";
  static const String ltftName = "تصحيح الوقود التراكمي (LTFT)";
  static const String o2Bank1Sensor1Name = "حساس الشكمان الأمامي (B1S1)";
  static const String o2Bank1Sensor2Name = "حساس الشكمان الخلفي (B1S2)";
  static const String fuelPressureName = "ضغط مسطرة الوقود (Common Rail)";
  static const String moduleVoltageName = "فولت تغذية الكنترول";

  // Vehicle Profiles Screen
  static const String searchVehicles = "البحث عن سيارة (الماركة، الموديل، سنة الصنع)...";
  static const String activeProfile = "السيارة المفعلة حالياً";
  static const String activateProfile = "تفعيل الفحص";
  static const String engineSpec = "المحرك:";
  static const String transmissionSpec = "الفتيس:";
  static const String engineLabel = "المحرك";
  static const String transmissionLabel = "الفتيس";
  static const String protocolSpec = "بروتوكول الاتصال:";
  static const String technicianNotes = "ملاحظات الفني والورشة:";
  static const String workshopNote = "ملاحظة فنية هامة";
  static const String customPidsCount = "الحساسات المخصصة:";
  static const String addCustomPid = "إضافة حساس خاص";

  // Inspection Report
  static const String plateNumber = "رقم اللوحة / النمرة:";
  static const String customerName = "اسم العميل:";
  static const String customerPhone = "رقم الهاتف:";
  static const String mechanicNotes = "تقرير المهندس والتوصيات:";
  static const String saveReport = "حفظ تقرير الفحص بالورشة";
  static const String exportPdf = "تصدير تقرير PDF احترافي";
  static const String shareWhatsapp = "إرسال التقرير للعميل عبر واتساب";
  static const String printReport = "طباعة التقرير";
  static const String savedReports = "سجلات الفحص المحفوظة";
  static const String noSavedReports = "لا توجد تقارير فحص سابقة";

  // Safety Alarms
  static const String coolantAlarmTitle = "خطر حرج: سخونة شديدة في المحرك!";
  static const String coolantAlarmBody = "حرارة مياه التبريد تجاوزت الحد الآمن (>105° مئوية). أوقف المحرك فوراً!";
  static const String batteryAlarmTitle = "تحذير: انخفاض فولت البطارية!";
  static const String batteryAlarmBody = "الجهد الكهربائي أقل من 11.8 فولت. افحص كفاءة الدينامو أو شحن البطارية.";
  static const String clearAlarms = "إغلاق التنبيهات";

  // 1-Click Full Vehicle Test
  static const String fullVehicleTest = "فحص شامل بضغطة زر (1-Click Test)";
  static const String fullVehicleTestSubtitle = "فحص متكامل لجميع الكنترولات والأعطال والفيشات والبطارية والحساسات";
  static const String startFullTest = "بدء الفحص الشامل للسيارة";
  static const String testingInProgress = "جاري الفحص الشامل لجميع المنظومات...";
  static const String testCompleted = "اكتمل الفحص الفني الشامل للسيارة";
  static const String overallHealthIndex = "مؤشر الكفاءة والحالة الفنية";
  static const String pass = "سليم";
  static const String fail = "يوجد عطل";
  static const String warning = "تحذير";
  static const String runFullTestNow = "بدء الفحص الشامل بضغطة زر";
  static const String viewInspectionReport = "عرض تقرير الفحص الفني";
  static const String selectVehicleFirst = "يرجى اختيار أو تأكيد موديل السيارة أولاً";
  static const String vehicleHealthSummary = "ملخص الحالة الفنية للسيارة";
  static const String cancelTest = "إلغاء الفحص";

  // Diagzone Pro Flagship Extensions
  static const String canTopologyVisual = "خريطة شبكات CAN/LIN";
  static const String canTopologyVisualSubtitle = "رسم بياني تفاعلي لشجرة الشبكات وسرعة الاستجابة";
  static const String immoKeySuite = "برمجة المفاتيح والإيموبليزر";
  static const String immoKeySuiteSubtitle = "قراءة الترانسبوندر، فحص التردد، وحساب كود PIN";
  static const String evHybridBatteryLab = "مختبر بطاريات EV والهايبرد";
  static const String evHybridBatteryLabSubtitle = "مصفوفة 96 خلية، فارق الفولتية، وعزل الجهد العالي";

  // Workshop Power Modules
  static const String usedCarAudit = "فحص سيارات الشراء وكشف التلاعب";
  static const String usedCarAuditSubtitle = "كشف تلاعب العداد، تاريخ تصفير الأعطال وتقرير 100 نقطة";
  static const String labScopeWaveform = "مختبر الأوسيلوسكوب وإشارات التزامن";
  static const String labScopeWaveformSubtitle = "كشف استطالة سير الكاتينة ورسم إشارات الكرنك والكامة";
  static const String wiringSchematics = "الدوائر الكهربائية وأطراف الفيش Pinouts";
  static const String wiringSchematicsSubtitle = "مخططات تفاعلية ملونة ودليل فحص أطراف الكنترول بالملتيميتر";
  static const String adasCalibration = "معايرة رادار وكاميرا مساعدة السائق ADAS";
  static const String adasCalibrationSubtitle = "مصفوفة مسافات اللوحات وضبط ميزان الليزر والقيادة الديناميكية";
  static const String dpfRegeneration = "منظومة فلتر البيئة DPF وحقن الأدبلو SCR";
  static const String dpfRegenerationSubtitle = "الحرق الإجباري للهباب ومراقبة درجات حرارة العادم وحساس NOx";

  // Workshop UX Powerhouse Suite
  static const String voiceAssistant = "المساعد الصوتي بدون استخدام اليدين";
  static const String voiceAssistantSubtitle = "فحص ناطق بالأوامر الصوتية ونطق قراءات الحساسات بالأرقام";
  static const String arEngineBay = "نظارة الواقع المعزز لحوض المحرك AR";
  static const String arEngineBaySubtitle = "تحديد مواقع الحساسات بالكاميرا ودليل الفحص وقياس الفولت الحي";
  static const String customerDispatch = "مركز خدمة ومراسلة العملاء واتساب";
  static const String customerDispatchSubtitle = "مراحل الصيانة الخمس وإرسال شهادة الفحص PDF بنقرة واحدة";
  static const String offlineVault = "الخزنة المحلية ومراقب بروتوكول CAN";
  static const String offlineVaultSubtitle = "تشغيل 100% بدون إنترنت ومحلل حزم الأكواد الهيدرولية الخام CAN Bus";
}
