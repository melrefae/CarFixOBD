// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get pdfFileNotFound => 'ملف PDF غير موجود';

  @override
  String get deleteThisVisit => 'حذف هذه الزيارة؟';

  @override
  String get theSavedRecordAndIts => 'سيتم حذف السجل وملف PDF من الهاتف.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get carHistory => 'سجل السيارات';

  @override
  String get noSavedVisitsYetFinish =>
      'لا توجد زيارات محفوظة. أكمل فحصاً واضغط \"حفظ الزيارة\".';

  @override
  String get searchPlateCustomerVin => 'بحث: لوحة، عميل، شاسيه';

  @override
  String get noMatch => 'لا توجد نتائج';

  @override
  String get unknownCar => 'سيارة غير معروفة';

  @override
  String get visits => 'زيارات';

  @override
  String get carRead => 'قراءة من السيارة';

  @override
  String get handInspectionOnly => 'فحص يدوي فقط';

  @override
  String get compare2SelectedVisits => 'قارن زيارتين محددتين';

  @override
  String get jobCardsQuotes => 'أوامر الشغل وعروض الأسعار';

  @override
  String get newJobCard => 'أمر شغل جديد';

  @override
  String get noJobCardsYet => 'لا توجد أوامر شغل.';

  @override
  String get searchPlateCustomerPhone => 'بحث: لوحة، عميل، هاتف';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get enterTheCustomerPhoneFirst => 'أدخل رقم العميل أولاً';

  @override
  String get couldNotOpenWhatsapp => 'تعذر فتح واتساب';

  @override
  String get jobCard => 'أمر شغل';

  @override
  String get customer => 'العميل';

  @override
  String get phoneWhatsapp => 'الهاتف (واتساب)';

  @override
  String get plate => 'اللوحة';

  @override
  String get odometerKm => 'العداد كم';

  @override
  String get vehicle => 'السيارة';

  @override
  String get complaint => 'شكوى العميل';

  @override
  String get findingsWorkDone => 'النتائج / الشغل';

  @override
  String get status => 'الحالة';

  @override
  String get partsAndLabourEgp => 'قطع وأجرة (جنيه)';

  @override
  String get part => 'قطعة';

  @override
  String get labour => 'أجرة';

  @override
  String get discountEgp => 'خصم';

  @override
  String get vatIfAny => 'ضريبة % (إن وجدت)';

  @override
  String get parts => 'قطع';

  @override
  String get discount => 'خصم';

  @override
  String get total => 'الإجمالي';

  @override
  String get quotePdf => 'عرض سعر PDF';

  @override
  String get invoicePdf => 'فاتورة PDF';

  @override
  String get whatsappQuote => 'واتساب عرض سعر';

  @override
  String get whatsappInvoice => 'واتساب فاتورة';

  @override
  String get labourDescription => 'وصف الأجرة';

  @override
  String get partName => 'اسم القطعة';

  @override
  String get qty => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get continueSavedDraft => 'متابعة المسودة المحفوظة؟';

  @override
  String get anUnfinishedInspectionWasSaved =>
      'يوجد فحص غير مكتمل محفوظ على الهاتف.';

  @override
  String unfinishedInspectionFor(Object p0) {
    return 'فحص غير مكتمل للوحة $p0.';
  }

  @override
  String get startNew => 'ابدأ جديد';

  @override
  String get continueAction => 'متابعة';

  @override
  String get visitSaved => 'تم حفظ الزيارة';

  @override
  String get connectTheAdapterToThe => 'وصّل الأداة بالسيارة أولاً.';

  @override
  String get s1ReadFromCar => '1. قراءة من السيارة';

  @override
  String get s2InspectionForm => '2. نموذج الفحص';

  @override
  String get s3Report => '3. التقرير';

  @override
  String get usedCarInspection => 'فحص سيارة مستعملة';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get thisStepReadsOnlyWhat =>
      'هذه الخطوة تقرأ فقط ما تبلغ به السيارة: العداد في الوحدات والأعطال وتاريخ المسح والشاسيه وجهد البطارية والـ misfire. باقي الفحص يدوي في الخطوة 2.';

  @override
  String get adapterConnected => 'الأداة متصلة';

  @override
  String get notConnected => 'غير متصل';

  @override
  String get connect => 'اتصال';

  @override
  String get reading => 'جارٍ القراءة...';

  @override
  String get readFromCar => 'اقرأ من السيارة';

  @override
  String get readAgain => 'اقرأ مرة أخرى';

  @override
  String get carReadingsRestoredFromThe =>
      'قراءات السيارة مستعادة من المسودة. اقرأ مرة أخرى لتحديثها.';

  @override
  String get skipNoCarHandInspection => 'تخطي، بدون سيارة (فحص يدوي فقط)';

  @override
  String get odometerEcmTcmAbsCluster => 'العداد';

  @override
  String get codeClearingHistory => 'تاريخ مسح الأعطال';

  @override
  String get vin => 'رقم الشاسيه';

  @override
  String get battery => 'البطارية';

  @override
  String get misfires => 'الـ Misfire';

  @override
  String get valuesTheCarDidNot =>
      'القيم التي لم ترد من السيارة تظهر كغير مقروءة. ليس حكماً نهائياً: أكمل الخطوة 2.';

  @override
  String get handEnteredAnythingLeftEmpty =>
      'إدخال يدوي. أي حقل فارغ أو \"لم يُفحص\" يُطبع كما هو وليس كسليم.';

  @override
  String get odometerShownKm => 'العداد المعروض (كم)';

  @override
  String get paintThicknessUmGaugeNeeded => 'سماكة الدهان (ميكرون) بجهاز قياس';

  @override
  String get bodyNotesDentsPanelGaps =>
      'ملاحظات الهيكل (خبطات، فواصل، صدأ، زجاج)';

  @override
  String get tiresTreadDepthMm => 'الكاوتش: عمق الأخدود (مم)';

  @override
  String get tireNoteAgeUnevenWear => 'ملاحظة الكاوتش';

  @override
  String get brakes => 'الفرامل';

  @override
  String get frontPads => 'تيل أمامي %';

  @override
  String get rearPads => 'تيل خلفي %';

  @override
  String get frontDiscs => 'طنابير/دوائر أمامية';

  @override
  String get rearDiscs => 'طنابير/دوائر خلفية';

  @override
  String get fluids => 'السوائل';

  @override
  String get testDrive => 'تجربة الطريق';

  @override
  String get mechanicalChecklist => 'قائمة الفحص الميكانيكي';

  @override
  String get photos => 'صور';

  @override
  String get camera => 'كاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get technicianNotes => 'ملاحظات الفني';

  @override
  String get notes => 'ملاحظات';

  @override
  String get couldNotOpenTheCamera => 'تعذر فتح الكاميرا أو المعرض';

  @override
  String get ok => 'سليم';

  @override
  String get marginal => 'متوسط';

  @override
  String get fail => 'تالف';

  @override
  String get leak => 'تسريب';

  @override
  String get theReportPrintsCarReadings =>
      'التقرير يطبع قراءات السيارة والبيانات اليدوية في أقسام منفصلة. الدرجة مجرد معادلة بسيطة من قراءات السيارة وليست حكماً.';

  @override
  String get fromTheCar => 'من السيارة';

  @override
  String get fromTheCarSavedReadings => 'من السيارة (قراءات محفوظة)';

  @override
  String get noCarReadingHandInspection =>
      'بدون قراءة من السيارة، فحص يدوي فقط';

  @override
  String get paint => 'الدهان';

  @override
  String get checklist => 'القائمة';

  @override
  String get tiresFluidsTestDrive => 'كاوتش / سوائل / تجربة';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get print => 'طباعة';

  @override
  String get savedSaveAgain => 'تم الحفظ. حفظ مرة أخرى';

  @override
  String get saveVisitToCarHistory => 'احفظ الزيارة في سجل السيارة';

  @override
  String get saveAndCreateJobCard => 'حفظ وإنشاء أمر شغل / عرض سعر';

  @override
  String get logoSavedItPrintsOn => 'تم حفظ الشعار. سيظهر في ملف PDF التالي.';

  @override
  String backupFailed(Object p0) {
    return 'فشل النسخ الاحتياطي: $p0';
  }

  @override
  String get couldNotReadTheFile => 'تعذرت قراءة الملف';

  @override
  String importedVisitsAndJobCards(Object p0, Object p1, Object p2) {
    return 'تم استيراد $p0 زيارة و $p1 أمر شغل. تم تخطي $p2 موجودة بالفعل.';
  }

  @override
  String importFailed(Object p0) {
    return 'فشل الاستيراد: $p0';
  }

  @override
  String get logoOnPdfsOptional => 'الشعار على ملفات PDF (اختياري)';

  @override
  String get choose => 'اختيار';

  @override
  String get remove => 'إزالة';

  @override
  String get backupOfSavedVisitsAnd => 'نسخة احتياطية للزيارات وأوامر الشغل';

  @override
  String get savedDataLivesOnlyOn =>
      'البيانات محفوظة على هذا الهاتف فقط. صدّر ملفاً واحتفظ به في مكان آمن (واتساب لنفسك، درايف، بريد). الاستيراد يضيف السجلات ولا يمسح الموجود.';

  @override
  String get exportBackup => 'تصدير نسخة';

  @override
  String get importBackup => 'استيراد نسخة';

  @override
  String get appName => 'أسبكت أوتو سكان';

  @override
  String get darkWorkshopMode => 'الوضع الليلي للورشة';

  @override
  String get brightDaylightMode => 'وضع النهار الساطع للشمس';

  @override
  String get centerAlarmSettings => 'إعدادات المركز والتنبيهات الصوتية';

  @override
  String get shieldNotTested => 'الأيقونة = لم تُختبر بعد على سيارة حقيقية';

  @override
  String get ecuScanTree => 'مسح الوحدات (شجرة)';

  @override
  String get findModulesGateway => 'اكتشاف الوحدات على البوابة';

  @override
  String get interactiveBusMap => 'خريطة الشبكات التفاعلية';

  @override
  String get canLinGraph => 'رسم بياني لشبكات CAN/LIN';

  @override
  String get daily => 'يومي';

  @override
  String get readClearDtc => 'قراءة/مسح الأعطال';

  @override
  String get liveData => 'بيانات حية';

  @override
  String get liveGraphs => 'رسوم حية';

  @override
  String get freezeFrame => 'لقطة العطل';

  @override
  String get readiness => 'جاهزية الفحص';

  @override
  String get ecuInfo => 'بيانات الكمبيوتر';

  @override
  String get mode06Monitors => 'مونيتورات 06';

  @override
  String get vehicleProfile => 'ملف السيارة';

  @override
  String get inspectionCustomers => 'فحص وعملاء';

  @override
  String get usedCarAudit => 'فحص شراء';

  @override
  String savedReportsCount(Object count) {
    return 'التقارير ($count)';
  }

  @override
  String get whatsappDispatch => 'واتساب العميل';

  @override
  String get lanHub => 'مزامنة الورشة';

  @override
  String get analysisTools => 'تحليل وأدوات';

  @override
  String get networkMap => 'خريطة الشبكة';

  @override
  String get o2Catalyst => 'حساسات الشكمان';

  @override
  String get fuelTrimBattery => 'الوقود والبطارية';

  @override
  String get dtcEncyclopedia => 'موسوعة الأعطال';

  @override
  String get wiring => 'الدوائر';

  @override
  String get canSniffer => 'مراقب CAN';

  @override
  String get adapterTest => 'اختبار الأداة';

  @override
  String get terminal => 'تيرمنال';

  @override
  String get rawLog => 'سجل الأوامر';

  @override
  String get labExperimentalPin => 'المختبر (تجريبي، برقم سري)';

  @override
  String get labFeaturesUnverified =>
      'تصفير وتكويد وإيموبلايزر وأكتيويتور وADAS وDPF وغيرها. غير مثبتة على سيارة.';

  @override
  String get moreTools => 'أدوات إضافية';

  @override
  String get classicAudit9Tabs => 'الفحص القديم';

  @override
  String get voiceAssistant => 'المساعد الصوتي';

  @override
  String get arHud => 'AR HUD';

  @override
  String get aiCopilot => 'المساعد الذكي';

  @override
  String get flightRecorder => 'الصندوق الأسود';

  @override
  String get fuelCost => 'تكلفة البنزين';

  @override
  String get hudDisplay => 'شاشة HUD';

  @override
  String get connectedToEcu => 'متصل بكمبيوتر السيارة';

  @override
  String get adapterReadyTurnKey => 'الفيشة متصلة (افتح كونتاك السيارة ON)';

  @override
  String get connectingObdAdapter => 'جاري الاتصال بفيشة الفحص...';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get switchAdapter => 'تبديل وسيلة الاتصال';

  @override
  String batterySummary(Object summary, Object voltage) {
    return 'البطارية: $voltage فولت | $summary';
  }

  @override
  String batteryVehicle(Object model, Object voltage) {
    return 'البطارية: $voltage فولت | السيارة: $model';
  }

  @override
  String get genericVehicle => 'سيارة عامة';

  @override
  String get fullVehicleTest => 'فحص شامل بضغطة زر واحدة';

  @override
  String selectedProfileNotConnected(Object name) {
    return 'الملف المختار (غير متصل): $name';
  }

  @override
  String get tapToSelectVehicle => 'اضغط لاختيار سيارة وبدء الفحص';

  @override
  String get fullScanSubtitle =>
      'فحص شامل لجميع الكنترولات والأعطال وحفظ تقرير PDF';

  @override
  String get quickScan30s => 'فحص سريع شامل (30 ثانية)';

  @override
  String get quickScanSubtitle =>
      'فحص سريع في 30 ثانية: الأعطال والحساسات ورقم الشاسيه والفولت';

  @override
  String get connectAdapterFirst =>
      'اتصل بفيشة OBD حقيقية الأول (بلوتوث كلاسيك أو BLE أو واي فاي أو USB OTG).';

  @override
  String get workshopSettings => 'إعدادات الورشة والمركز';

  @override
  String get workshopBrandingSaved =>
      'تم حفظ إعدادات الورشة والتنبيهات بنجاح ✅';

  @override
  String get suiteTagline => 'منظومة تشخيص السيارات ومتابعة الأسطول';

  @override
  String get copyNumber => 'نسخ الرقم';

  @override
  String get phoneCopied => 'تم نسخ رقم الهاتف';

  @override
  String get workshopInfoPdf => 'بيانات الورشة (تقارير PDF):';

  @override
  String get workshopCenterName => 'اسم مركز الصيانة';

  @override
  String get workshopAddress => 'عنوان الورشة';

  @override
  String get defaultInspectionEngineer => 'مهندس الفحص الافتراضي';

  @override
  String get standardInspectionFee => 'سعر الفحص الأساسي';

  @override
  String get safetyThresholdsAlarms => 'حدود الأمان والتنبيهات الفورية:';

  @override
  String get enableAlarmSounds => 'تفعيل صوت التنبيه والاهتزاز';

  @override
  String get alarmSoundsSubtitle =>
      'يعرض تنبيه واهتزاز عندما يتجاوز أي حساس الحدود الآمنة';

  @override
  String get engineOverheatLimit => 'حد تنبيه سخونة المحرك:';

  @override
  String get alternatorLowVoltage => 'حد انخفاض فولت الدينامو:';

  @override
  String get cloudBackupSync => 'النسخ الاحتياطي السحابي ومزامنة الأسطول';

  @override
  String get obdAdapterAutoReconnect => 'إعدادات الاتصال التلقائي بالمحول';

  @override
  String get autoReconnectLaunch => 'الاتصال التلقائي عند فتح التطبيق';

  @override
  String get autoReconnectSubtitle =>
      'إعادة الاتصال تلقائياً بآخر فيشة OBD تم الاقتران بها';

  @override
  String get pairedObdAdapter => 'محول OBD المتصل';

  @override
  String get forget => 'مسح المحول';

  @override
  String get noSavedAdapterYet =>
      'لم يتم حفظ أي محول حتى الآن. اتصل بمحولك ليتم حفظه تلقائياً.';

  @override
  String get saveWorkshopSettings => 'حفظ إعدادات الورشة';

  @override
  String get connectionTitle => 'مدير الاتصال بفيشة ELM327';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get autoDetectConnect => 'كشف واتصال تلقائي فوري';

  @override
  String get pairedDevicesOs => 'الأجهزة المقترنة مسبقاً';

  @override
  String get noPairedDevices => 'لا توجد فيشات بلوتوث مقترنة';

  @override
  String get discoveredDevices => 'الأجهزة المكتشفة في النطاق';

  @override
  String get unknownDevice => 'جهاز عام';

  @override
  String get wifiSettingsTitle => 'إعدادات الواي فاي لفيشة ELM327:';

  @override
  String get wifiDescription =>
      'معظم فيشات OBD الواي فاي في مصر تبث شبكة باسم \'WiFi_OBDII\' وتستخدم العنوان الافتراضي 192.168.0.10 على بورت 35000.';

  @override
  String get adapterAddressLabel => 'عنوان الفيشة (IP:Port)';

  @override
  String get connectWifi => 'اتصال عبر الواي فاي';

  @override
  String get protocolPickerLabel => 'البروتوكول: ';

  @override
  String get checkAdapter20s => 'فحص الفيشة (حوالي 20 ثانية)';

  @override
  String get adapterCheckTitle => 'فحص الفيشة';

  @override
  String get readModulesUds => 'قراءة الوحدات UDS (قراءة فقط، CAN فقط)';

  @override
  String get modulesUdsTitle => 'الوحدات (UDS)';

  @override
  String get lastAttempt => 'آخر محاولة:';

  @override
  String get retryEcuHandshake =>
      'إعادة محاولة المصافحة مع الكمبيوتر (الكونتاك ON)';

  @override
  String quickReconnect(Object name, Object type) {
    return 'إعادة اتصال سريعة: $name ($type)';
  }

  @override
  String get autoDetectSubtitle =>
      'يفحص USB وبلوتوث كلاسيك وBLE وواي فاي تلقائياً + يتعرف على رقم شاسيه وموديل السيارة';

  @override
  String get autoDetecting => 'جاري الكشف التلقائي...';

  @override
  String get autoDetectAnyAdapter => 'كشف واتصال تلقائي بأي فيشة OBD';

  @override
  String connectedToAdapter(Object adapter) {
    return 'تم الاتصال بـ $adapter!';
  }

  @override
  String get scanning => 'جاري البحث...';

  @override
  String get scanNearby => 'بحث في النطاق';

  @override
  String get refreshPaired => 'تحديث المقترنة';

  @override
  String get pairedNonAndroidNote =>
      'على اللابتوب أو الأجهزة غير الأندرويد، افحص تبويب USB / Serial لمنافذ البلوتوث المقترنة أو تبويب BLE 5.0.';

  @override
  String get listeningNearby => 'يستمع لفيشات البلوتوث القريبة...';

  @override
  String get pairedBadge => 'مقترن';

  @override
  String get nearbyBadge => 'قريب';

  @override
  String chipLabel(Object chip) {
    return 'الشريحة: $chip';
  }

  @override
  String scoreLabel(Object score) {
    return 'التقييم: $score';
  }

  @override
  String get autoProbeWifi => 'بحث تلقائي عن بوابة OBD الواي فاي النشطة';

  @override
  String get noWifiGateway =>
      'لم تستجب أي بوابة ELM327 واي فاي على المنافذ القياسية.';

  @override
  String get bleTitle => 'بلوتوث منخفض الطاقة (BLE 4.0 / 5.0 GATT)';

  @override
  String get bleDescription =>
      'يفحص أجهزة BLE القريبة التي تدعم Nordic UART (6E400001)، و0xFFF0 (Veepeak/Vgate)، و0x18F0 (OBDLink/vLinker)، وخصائص 0xFFE0 GATT.';

  @override
  String get scanningBle => 'جاري فحص أجهزة BLE القريبة...';

  @override
  String get scanBleAdapters => 'فحص فيشات OBD BLE القريبة';

  @override
  String bleScanResults(Object count) {
    return 'نتائج فحص BLE المباشر ($count)';
  }

  @override
  String get listening => 'يستمع...';

  @override
  String get searchingBle => 'يبحث في إعلانات BLE...';

  @override
  String get tapScanBle =>
      'اضغط \'فحص فيشات OBD BLE القريبة\' بالأعلى لاكتشاف الفيشات العاملة.';

  @override
  String bleIdRssi(Object id, Object rssi) {
    return 'المعرف: $id • الإشارة: $rssi dBm';
  }

  @override
  String get manualBleId => 'معرف/عنوان BLE يدوي:';

  @override
  String get bleIdHint => 'مثال: 00:1B:10:E2:33:44 أو UUID الجهاز';

  @override
  String get usbSerialTitle => 'USB OTG والمنافذ التسلسلية / منافذ COM';

  @override
  String get usbSerialDescription =>
      'تعريفات USB-OTG حقيقية لأندرويد (FTDI، CH340، CP2102، PL2303، CDC-ACM) بالإضافة لمنافذ macOS/Linux والبلوتوث التسلسلي.';

  @override
  String get enumeratingPorts => 'جاري عدّ المنافذ المتصلة...';

  @override
  String get refreshUsbDevices => 'تحديث أجهزة USB / التسلسلي المتصلة';

  @override
  String detectedSerialPorts(Object count) {
    return 'المنافذ التسلسلية المكتشفة ($count):';
  }

  @override
  String get noUsbDetected =>
      'لم يتم اكتشاف كابلات USB OTG أو منافذ OBD تسلسلية الآن. وصّل الكابل أو قم بإقران فيشة البلوتوث ثم اضغط تحديث.';

  @override
  String portLine(Object port, Object transport) {
    return 'المنفذ: $port • $transport';
  }

  @override
  String get manualSerialOverride => 'منفذ تسلسلي / Baud يدوي';

  @override
  String get serialPortPathLabel => 'مسار منفذ USB / التسلسلي أو معرف الجهاز';

  @override
  String get uartBaudRate => 'معدل البود UART: ';

  @override
  String get openSerialPort => 'فتح المنفذ التسلسلي المحدد';

  @override
  String get noDtcsFound =>
      'لا توجد أعطال مسجلة. كنترول المحرك يعمل بحالة ممتازة!';

  @override
  String get vinLabel => 'رقم الشاسيه (VIN):';

  @override
  String get protocolLabel => 'بروتوكول الكان الفعّال:';

  @override
  String get batteryVoltageLabel => 'فولت البطارية:';

  @override
  String get milStatusLabel => 'حالة لمبة المحرك (MIL):';

  @override
  String get milOn => 'مضاءة (توجد أعطال مسجلة)';

  @override
  String get milOff => 'مطفأة (لا توجد أعطال نشطة)';

  @override
  String get saveReport => 'حفظ تقرير الفحص بالورشة';

  @override
  String get rescan => 'إعادة الفحص';

  @override
  String get scanningVinMil =>
      'جاري فحص رقم الشاسيه وحالة لمبة المحرك والأعطال والفولت...';

  @override
  String detectedDtcs(Object count) {
    return 'الأعطال المكتشفة ($count):';
  }

  @override
  String get activeFaults => 'أعطال نشطة';

  @override
  String get optimalHealth => 'المحرك والانبعاثات في حالة ممتازة';

  @override
  String get codesDetectedCel => 'تم اكتشاف أعطال ولمبة المحرك مضاءة!';

  @override
  String get noMisfires =>
      'لا توجد أكواد ميسفاير أو كتاليست أو انبعاثات مسجلة في الكمبيوتر.';

  @override
  String get saveJobCard => 'حفظ أمر شغل الفحص:';

  @override
  String get licensePlateLabel => 'رقم اللوحة (مثال: أ ب ج 1234)';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get phoneWhatsappNumber => 'رقم الهاتف / واتساب';

  @override
  String get enterPlate => 'من فضلك أدخل رقم اللوحة';

  @override
  String get walkInCustomer => 'عميل نقدي (بدون حجز)';

  @override
  String get jobCardSaved => 'تم حفظ أمر الشغل بنجاح!';

  @override
  String get readDtcs => 'أكواد الأعطال (DTCs)';

  @override
  String get storedDtcs => 'المؤكدة (Mode 03)';

  @override
  String get pendingDtcs => 'المعلقة (Mode 07)';

  @override
  String get permanentDtcs => 'الدائمة (Mode 0A)';

  @override
  String get searchDtcHint =>
      'ابحث بكود العطل أو كلمة (مثال: P0300، ميسفاير)...';

  @override
  String get clearDtcsButton => 'مسح جميع الأعطال وإطفاء لمبة المحرك (Mode 04)';

  @override
  String get dtcsClearedSuccess =>
      'تم مسح جميع الأعطال وإطفاء لمبة المحرك بنجاح!';

  @override
  String get dtcsClearedFail =>
      'فشل مسح الأعطال. تأكد أن الكونتاك مفتوح (ON) والمحرك مطفي.';

  @override
  String clearPartialRemaining(Object codes, Object count) {
    return 'الكمبيوتر قبل المسح لكن $count كود لسه مسجلين: $codes. العطل غالباً لسه موجود.';
  }

  @override
  String get clearUnconfirmed =>
      'تم قبول المسح لكن مقدرنش أتأكد، اقرأ الأعطال تاني.';

  @override
  String get noStoredDtcs => 'لا توجد أعطال مؤكدة مسجلة.';

  @override
  String get noPendingDtcs => 'لا توجد أعطال معلقة.';

  @override
  String get noPermanentDtcs => 'لا توجد أعطال دائمة.';

  @override
  String get rescanDtcs => 'إعادة فحص الأعطال';

  @override
  String noDtcsMatching(Object query) {
    return 'لا توجد أكواد أعطال مطابقة لـ \'$query\'';
  }

  @override
  String get liveSensorsTitle => 'البيانات الحية والحساسات';

  @override
  String get liveGraphsTitle => 'الرسوم البيانية والإشارات اللحظية';

  @override
  String get discoverPids => 'اكتشاف الحساسات المدعومة';

  @override
  String get pausePolling => 'إيقاف التحديث المباشر';

  @override
  String get startPolling => 'بدء التحديث المباشر';

  @override
  String get allSensors => 'جميع الحساسات';

  @override
  String get engineSensors => 'المحرك والسرعة';

  @override
  String get coolingSensors => 'دورة التبريد والحرارة';

  @override
  String get electricalSensors => 'الكهرباء والشحن';

  @override
  String get fuelAir => 'الهواء والبنزين';

  @override
  String get railTurbo => 'التوربو والمسطرة';

  @override
  String get transmission => 'الفتيس';

  @override
  String get absSpeeds => 'سرعات العجلات';

  @override
  String get oemCustom => 'حساسات الموديل';

  @override
  String get noSensorsCategory => 'لا توجد حساسات في هذا التصنيف';

  @override
  String get variance5 => 'فرق سرعة > 5 كم/س';

  @override
  String get disableDual => 'إلغاء المقارنة المزدوجة';

  @override
  String get enableDual => 'تفعيل مقارنة إشارتين معاً';

  @override
  String get channel1 => 'القناة الأولى (الأصفر):';

  @override
  String get channel2 => 'القناة الثانية للمقارنة (الأزرق):';

  @override
  String get freezeFrameTitle => 'تجميد بيانات العطل (Freeze Frame)';

  @override
  String get refreshFreezeFrame => 'تحديث لقطة العطل';

  @override
  String get queryingFreezeFrame =>
      'جاري قراءة بيانات لقطة العطل من الكمبيوتر (Mode 02)...';

  @override
  String get noFreezeFrame => 'لا توجد لقطة عطل مسجلة في ذاكرة الكمبيوتر';

  @override
  String get freezeFrameStoredWhen =>
      'تُحفظ بيانات اللقطة فقط عند تسجيل عطل مؤكد لأول مرة';

  @override
  String get triggeringFaultCode => 'كود العطل المسبب:';

  @override
  String get sensorSnapshot => 'لقطة الحساسات لحظة حدوث العطل:';

  @override
  String get engineSpeedRpm => 'سرعة المحرك (RPM):';

  @override
  String get vehicleSpeedLabel => 'سرعة السيارة:';

  @override
  String get coolantTempLabel => 'حرارة مياه التبريد:';

  @override
  String get engineLoadLabel => 'حمل المحرك المحسوب:';

  @override
  String get throttlePositionLabel => 'وضعية الخانق (TPS):';

  @override
  String get manifoldPressureLabel => 'ضغط المانيفولد المطلق:';

  @override
  String get intakeAirTempLabel => 'حرارة هواء السحب (IAT):';

  @override
  String get stftLabel => 'تصحيح الوقود قصير المدى (STFT):';

  @override
  String get ltftLabel => 'تصحيح الوقود طويل المدى (LTFT):';

  @override
  String get workshopAnalysis => 'تحليل الورشة وسياق التشغيل:';

  @override
  String faultContextLine1(Object coolant, Object rpm, Object speed) {
    return 'حدث هذا العطل أثناء القيادة بسرعة $speed كم/س والمحرك يعمل عند $rpm لفة وحرارة المياه $coolant°م.';
  }

  @override
  String faultContextLine2(Object condition, Object ltft) {
    return 'كان تصحيح الوقود طويل المدى ($ltft%)، أي أن الكمبيوتر كان يعوّض $condition لحظة حدوث العطل.';
  }

  @override
  String get leanCondition =>
      'خليط فقير (تسريب هواء بالمانيفولد أو ضغط بنزين منخفض)';

  @override
  String get richCondition => 'خليط غني (رشاش يقطر أو سحب هواء مقيد)';

  @override
  String get normalCondition => 'نسبة هواء/وقود طبيعية';

  @override
  String codesNeedInspection(Object count) {
    return 'تم اكتشاف $count كود عطل يحتاجون فحص فني.';
  }

  @override
  String get absCompareTitle => 'مقارنة سرعات العجلات الأربعة (ABS)';

  @override
  String get targetVsActual =>
      'مقارنة القيم المستهدفة والفعلية (Target vs Actual)';

  @override
  String get railPressure => 'ضغط مسطرة الوقود';

  @override
  String get turboBoost => 'ضغط شاحن التوربو';

  @override
  String actualValue(Object value) {
    return 'الفعلي: $value';
  }

  @override
  String targetValue(Object value) {
    return 'المستهدف: $value';
  }

  @override
  String get inspectionReports => 'تقارير الفحص';

  @override
  String get cloudBackupTooltip => 'النسخ الاحتياطي السحابي والمزامنة';

  @override
  String get searchReportsHint => 'ابحث برقم اللوحة أو الشاسيه أو العميل...';

  @override
  String get noReportsFound => 'لا توجد تقارير فحص محفوظة';

  @override
  String get noReportsHint =>
      'شغّل «الفحص السريع» لإنشاء وحفظ تقارير فحص العملاء';

  @override
  String get deleteReportTooltip => 'حذف التقرير';

  @override
  String reportCustomerLine(String p0, String p1) {
    return 'العميل: $p0 | الهاتف: $p1';
  }

  @override
  String reportDateLine(String p0) {
    return 'التاريخ: $p0';
  }

  @override
  String get allSystemsClear => 'كل الأنظمة سليمة';

  @override
  String troubleCodesCount(String p0) {
    return 'أعطال: $p0';
  }

  @override
  String voltageLine(String p0) {
    return 'الفولت: $p0';
  }

  @override
  String reportNotesLine(String p0) {
    return 'ملاحظات الفني: $p0';
  }

  @override
  String get exportPdf => 'تصدير تقرير PDF';

  @override
  String get shareWhatsapp => 'مشاركة مع العميل عبر واتساب';

  @override
  String get vehicleProfiles => 'ملفات السيارات المصرية';

  @override
  String get searchVehicles =>
      'ابحث عن سيارة (الماركة، الموديل، السنة، المحرك)...';

  @override
  String get tabEgyptianPresets => 'إعدادات مصرية جاهزة';

  @override
  String get tabGlobalBrands => 'أكثر من 250 ماركة عالمية';

  @override
  String noProfilesFound(String p0, String p1) {
    return 'لا توجد ملفات سيارات في \'$p0\' تطابق \'$p1\'';
  }

  @override
  String noBrandsFound(String p0, String p1) {
    return 'لا توجد ماركات في \'$p0\' تطابق \'$p1\'';
  }

  @override
  String get activeProfile => 'الملف النشط';

  @override
  String get activateProfile => 'تفعيل';

  @override
  String get fullTest => 'فحص شامل';

  @override
  String get engineLabel => 'المحرك';

  @override
  String get transmissionLabel => 'الفتيس';

  @override
  String get workshopNote => 'ملاحظة الورشة';

  @override
  String get addCustomPid => 'إضافة PID مخصص';

  @override
  String egyptianPresetsCount(String p0) {
    return '$p0 إعدادات جاهزة';
  }

  @override
  String get genericUdsObd2 => 'UDS / OBD2 عام';

  @override
  String get selectModel => 'اختر الموديل';

  @override
  String activatedGenericProfile(String p0) {
    return 'تم تفعيل ملف الفحص العام لـ $p0';
  }

  @override
  String brandModelsTitle(String p0) {
    return 'طرازات $p0';
  }

  @override
  String get testShort => 'فحص';

  @override
  String get readinessMonitors => 'عدادات جاهزية الانبعاثات';

  @override
  String get refreshReadiness => 'تحديث الجاهزية';

  @override
  String get readinessQuerying =>
      'جاري قراءة عدادات جاهزية دورة القيادة (Mode 01 PID 01)...';

  @override
  String get readinessNoData => 'لا توجد بيانات جاهزية بعد';

  @override
  String get readinessAllReady => 'كل عدادات دورة القيادة جاهزة';

  @override
  String readinessIncomplete(String p0) {
    return 'يوجد عدادات غير مكتملة ($p0)';
  }

  @override
  String readinessSummary(String p0, String p1, String p2) {
    return 'جاهز: $p0 | غير مكتمل: $p1 | لمبة المحرك: $p2';
  }

  @override
  String get readinessTip =>
      'نصيحة فحص قبل الشراء: لو لمبة المحرك مطفية لكن في عدادات «غير مكتملة»، فده معناه إن الأكواد اتمسحت مؤخرًا لإخفاء اللمبة مؤقتًا من غير اكتمال دورة القيادة!';

  @override
  String get readinessSubtitle => 'حالة جاهزية الأنظمة:';

  @override
  String get badgeUnsupported => 'غير مدعوم';

  @override
  String get badgeReady => 'جاهز';

  @override
  String get badgeIncomplete => 'غير مكتمل';

  @override
  String get refreshEcuDetails => 'تحديث بيانات الكمبيوتر';

  @override
  String get ecuQuerying =>
      'جاري قراءة رقم الشاسيه وأرقام المعايرة (Mode 09)...';

  @override
  String get ecuModuleLabel => 'وحدة التحكم الإلكتروني:';

  @override
  String get ecuDefaultName => 'كمبيوتر المحرك (ECM/PCM)';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get notDetected => 'لم يُكتشف';

  @override
  String get calIdLabel => 'رقم المعايرة (CALID):';

  @override
  String get calIdSubtitle =>
      'إصدار السوفتوير والفيرموير المثبت على كمبيوتر المحرك';

  @override
  String get cvnLabel => 'رقم التحقق من المعايرة (CVN):';

  @override
  String get cvnSubtitle => 'بصمة تحقق تضمن سلامة وأصالة معايرة السوفتوير';

  @override
  String get vinSubtitle =>
      'رقم التعريف الإلكتروني القياسي للسيارة المخزن في ذاكرة الكمبيوتر';

  @override
  String get protocolSubtitle =>
      'بروتوكول الاتصال التسلسلي النشط عبر فيشة OBD-II';

  @override
  String get ecuTechNoteTitle => 'ملاحظة للفني (فحص السوفتوير والريماب):';

  @override
  String get ecuTechNoteBody =>
      'أكواد CALID و CVN تستخدمها مراكز الصيانة للتحقق مما إذا كان سوفتوير السيارة اتعدل بريماب خارجي، أو لو محتاج إعادة برمجة وكالة لحل نشرات فنية.';

  @override
  String get terminalTitle => 'شاشة الأوامر';

  @override
  String get clearTerminalTooltip => 'مسح سجل الأوامر';

  @override
  String get terminalReadyHint =>
      'شاشة أوامر ELM327 جاهزة.\nاكتب أمر AT أو OBD بالأسفل أو اضغط اختصار سريع بالأعلى.';

  @override
  String get terminalInputHint =>
      'اكتب أمر AT أو OBD (مثال: AT RV أو 01 0C)...';

  @override
  String get sendCommandTooltip => 'إرسال الأمر';

  @override
  String get connectFirstSnack => 'وصّل فيشة الفحص أولاً';

  @override
  String get qcResetAdapter => 'إعادة تشغيل الفيشة';

  @override
  String get qcReadBattery => 'قراءة البطارية';

  @override
  String get qcActiveProtocol => 'البروتوكول النشط';

  @override
  String get qcSupportedPids => 'الـ PIDs المدعومة 1-20';

  @override
  String get qcEngineRpm => 'دوران المحرك';

  @override
  String get qcVehicleSpeed => 'سرعة السيارة';

  @override
  String get qcReadStoredDtcs => 'قراءة الأعطال المسجلة';

  @override
  String get qcReadPendingDtcs => 'قراءة الأعطال المعلقة';

  @override
  String get qcReadVin => 'قراءة الشاسيه';

  @override
  String get mode06Title => 'اختبارات المكونات والمس فاير (Mode 06)';

  @override
  String get mode06ScanTooltip => 'فحص Mode 06';

  @override
  String mode06Summary(String p0, String p1) {
    return 'نتائج Mode 06: $p0 اختبار ($p1 خارج الحدود)';
  }

  @override
  String get mode06Subtitle =>
      'يكشف عدادات تفويت السلندرات وحالة علبة البيئة والحساسات قبل إضاءة لمبة الأعطال.';

  @override
  String get mode06ConnectFirst =>
      'وصّل فيشة الفحص بالسيارة أولاً لقراءة اختبارات Mode 06.';

  @override
  String get mode06Scanning => 'جاري قراءة اختبارات Mode 06 من الكمبيوتر...';

  @override
  String get mode06NoResults =>
      'لا توجد نتائج Mode 06 من الكمبيوتر لهذا الفلتر.';

  @override
  String get mode06Rescan => 'إعادة فحص Mode 06';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterMisfires => 'المس فاير';

  @override
  String get filterO2Cat => 'الأكسجين وعلبة البيئة';

  @override
  String get filterFailedOnly => 'الفاشلة فقط';

  @override
  String get statusNoResult => 'لا نتيجة بعد';

  @override
  String get statusInfo => 'معلومة';

  @override
  String get statusPass => 'ناجح';

  @override
  String get statusFail => 'فاشل';

  @override
  String minLimitLabel(String p0, String p1) {
    return 'أدنى: $p0 $p1';
  }

  @override
  String maxLimitLabel(String p0, String p1) {
    return 'أقصى: $p0 $p1';
  }

  @override
  String get neverCompleted => 'لم يكتمل منذ مسح الأكواد';

  @override
  String get constantNoLimits => 'قيمة ثابتة (بدون حدود)';

  @override
  String get rawUnit => '(خام)';

  @override
  String get sensorWord => 'حساس';

  @override
  String rawLogTitle(String p0) {
    return 'سجل الأوامر ($p0)';
  }

  @override
  String get exportTooltip => 'تصدير';

  @override
  String get exportEvidenceTooltip => 'تصدير السجل مع حالة الميزات';

  @override
  String get clearTooltip => 'مسح';

  @override
  String get noCommandsYet => 'لا توجد أوامر بعد';

  @override
  String get waitingForData => 'بانتظار البيانات...';

  @override
  String get protocolAutoSearch => 'تلقائي (الفيشة تبحث في كل البروتوكولات)';

  @override
  String get hwChipUsb => 'USB / سيريال';

  @override
  String get hwChipBtClassic => 'بلوتوث كلاسيك SPP';

  @override
  String get hwChipBle => 'بلوتوث BLE 4.0 / 5.0';

  @override
  String get hwChipWifi => 'واي فاي TCP';

  @override
  String get hwChipAutoVin => 'قراءة الشاسيه تلقائيًا';

  @override
  String get statusDisconnected => 'غير متصل بفيشة الفحص';

  @override
  String get statusDisconnectedShort => 'غير متصل';

  @override
  String get regionAll => 'كل المناطق';

  @override
  String get regionAsian => 'آسيوية';

  @override
  String get regionEuropean => 'أوروبية';

  @override
  String get regionAmerican => 'أمريكية';

  @override
  String get regionChinese => 'صينية';

  @override
  String get regionCommercial => 'تجارية';

  @override
  String statusConnectionLost(String p0) {
    return 'انقطع الاتصال ($p0)';
  }

  @override
  String get statusLaunchingSimulator => 'جاري تشغيل محاكي الكمبيوتر...';

  @override
  String get statusSimulatorFailed => 'فشل تشغيل المحاكي';

  @override
  String statusConnectingBluetooth(String p0) {
    return 'جاري الاتصال بفيشة البلوتوث ($p0)...';
  }

  @override
  String get statusBluetoothFailed =>
      'تعذر الاتصال بالفيشة. تأكد من إقران البلوتوث وتوصيل الطاقة.';

  @override
  String statusConnectingWifi(String p0) {
    return 'جاري الاتصال بفيشة الواي فاي ($p0)...';
  }

  @override
  String get statusWifiFailed =>
      'تعذر الاتصال بفيشة الواي فاي. تأكد إنك متصل بشبكتها.';

  @override
  String statusConnectingBle(String p0) {
    return 'جاري الاتصال بفيشة BLE ($p0)...';
  }

  @override
  String get statusBleGattFailed =>
      'تعذر الاتصال بفيشة BLE. تأكد إنها شغالة وقريبة.';

  @override
  String statusOpeningSerial(String p0) {
    return 'جاري فتح منفذ USB/سيريال ($p0)...';
  }

  @override
  String get statusSerialFailed =>
      'تعذر فتح اتصال USB/سيريال. راجع الكابل أو الصلاحيات.';

  @override
  String get statusAutoDetecting =>
      'جاري البحث التلقائي عن فيشة الفحص عبر USB وبلوتوث وBLE وواي فاي...';

  @override
  String statusCheckingRecent(String p0) {
    return 'جاري فحص الفيشة الأخيرة ($p0)...';
  }

  @override
  String get statusCheckingUsb => 'جاري فحص منافذ USB-OTG والسيريال...';

  @override
  String statusProbingSerial(String p0, String p1) {
    return 'جاري فحص سيريال $p0 @ $p1...';
  }

  @override
  String get statusScanningBle => 'جاري البحث عن فيشات BLE القريبة...';

  @override
  String statusConnectingBleNamed(String p0) {
    return 'جاري الاتصال بفيشة BLE: $p0...';
  }

  @override
  String get statusProbingWifi => 'جاري فحص نقاط Wi-Fi ELM327...';

  @override
  String statusFoundWifi(String p0) {
    return 'تم العثور على فيشة واي فاي في $p0. جاري الاتصال...';
  }

  @override
  String get statusNoAdapterFound =>
      'لم يتم العثور على فيشة فحص عبر USB أو بلوتوث أو BLE أو واي فاي. ركّب الفيشة في العربية وحاول تاني.';

  @override
  String statusAutoConnectFailed(String p0) {
    return 'فشل الاتصال التلقائي: $p0';
  }

  @override
  String get statusAuditing =>
      'جاري فحص بيانات وحدات السيارة لتقييم ما قبل الشراء...';

  @override
  String statusAuditDone(String p0) {
    return 'اكتمل فحص السيارة. التقييم العام: $p0/100';
  }

  @override
  String get statusEvaluating =>
      'جاري تقييم الفيشات المتاحة للاتصال التلقائي...';

  @override
  String get statusNoBtDevices =>
      'لا توجد أجهزة بلوتوث متاحة للاتصال التلقائي.';

  @override
  String statusBestMatched(String p0, String p1) {
    return 'أفضل فيشة: $p0 ($p1). جاري الاتصال...';
  }

  @override
  String get statusHandshakeFailed =>
      'تعذر إتمام الاتصال الأولي مع أجهزة البلوتوث المقترنة.';

  @override
  String get statusRequestingBtPerm => 'جاري طلب صلاحيات البلوتوث...';

  @override
  String get statusScanningPaired => 'جاري البحث في أجهزة البلوتوث المقترنة...';

  @override
  String statusFoundAdapter(String p0) {
    return 'تم العثور على فيشة: $p0. جاري الاتصال...';
  }

  @override
  String statusProbingPaired(String p0) {
    return 'جاري فحص الجهاز المقترن: $p0...';
  }

  @override
  String get statusDiscovering => 'جاري البحث عن فيشات بلوتوث قريبة...';

  @override
  String statusFoundNearby(String p0) {
    return 'تم العثور على فيشة قريبة: $p0. جاري الاتصال...';
  }

  @override
  String get statusNoBtAdapter =>
      'لم يتم اكتشاف فيشة بلوتوث. تأكد من الطاقة أو جرّب BLE/USB/واي فاي.';

  @override
  String statusBtError(String p0) {
    return 'خطأ في البحث عن البلوتوث: $p0';
  }

  @override
  String get statusInitProtocol =>
      'جاري تهيئة الفيشة واكتشاف بروتوكول السيارة... العربيات القديمة (K-line) ممكن تاخد لحد ٤٠ ثانية. خلّي المفتاح ON.';

  @override
  String get statusConnectedDetecting =>
      'تم الاتصال بالكمبيوتر | جاري اكتشاف السيارة والـ PIDs المدعومة...';

  @override
  String statusConnectedDetected(String p0, String p1) {
    return 'متصل: $p0 | $p1';
  }

  @override
  String statusConnectedProtocol(String p0) {
    return 'متصل بالكمبيوتر | البروتوكول: $p0';
  }

  @override
  String statusAdapterReadyKeyOff(String p0) {
    return 'الفيشة جاهزة ($p0 فولت) - المفتاح في وضع OFF/ACC. لف المفتاح إلى ON/RUN.';
  }

  @override
  String statusInitFailed(String p0) {
    return 'فشلت تهيئة فيشة ELM327. $p0';
  }

  @override
  String get statusRetrying =>
      'جاري إعادة محاولة الاتصال بالكمبيوتر (لف المفتاح إلى ON)...';

  @override
  String get statusEcuNotResponding =>
      'الكمبيوتر لا يستجيب. تأكد إن المفتاح في وضع ON/RUN.';

  @override
  String get statusReadingVin =>
      'جاري قراءة الشاسيه والتعرف على السيارة وفحص الأعطال...';

  @override
  String get statusQuickScanDone => 'اكتمل الفحص السريع بنجاح';

  @override
  String get fuelEconomyEgp => 'استهلاك الوقود والتكلفة (جنيه)';

  @override
  String get resetTripOdometer => 'تصفير عداد الرحلة';

  @override
  String get fuelGradeTitle => 'نوع الوقود والتسعيرة المصرية:';

  @override
  String get fuel80 => 'بنزين 80 (13.75 ج.م)';

  @override
  String get fuel92 => 'بنزين 92 (15.25 ج.م)';

  @override
  String get fuel95 => 'بنزين 95 (17.00 ج.م)';

  @override
  String get fuelDiesel => 'سولار (13.50 ج.م)';

  @override
  String get instantConsumption => 'استهلاك الوقود اللحظي';

  @override
  String get idleSuffix => '(واقف)';

  @override
  String get avgEconomy => 'متوسط الاستهلاك';

  @override
  String get efficiencyLabel => 'الكفاءة';

  @override
  String get tripDistance => 'مسافة الرحلة';

  @override
  String get tripCostTitle => 'تفاصيل تكلفة الرحلة (بالجنيه المصري):';

  @override
  String get fuelTariffSelected => 'تسعيرة الوقود المختارة:';

  @override
  String egpPerLiter(String p0) {
    return '$p0 ج.م / لتر';
  }

  @override
  String get totalFuelConsumed => 'إجمالي الوقود المستهلك:';

  @override
  String litersValue(String p0) {
    return '$p0 لتر';
  }

  @override
  String get costPerKm => 'تكلفة الكيلومتر:';

  @override
  String egpPerKm(String p0) {
    return '$p0 ج.م / كم';
  }

  @override
  String get totalTripCost => 'إجمالي تكلفة الرحلة:';

  @override
  String egpValue(String p0) {
    return '$p0 ج.م';
  }

  @override
  String get windshieldMirrorOn => 'وضع الزجاج الأمامي: شغال';

  @override
  String get normalMode => 'الوضع العادي';

  @override
  String get hudRpm => 'دوران المحرك';

  @override
  String get hudCoolant => 'مياه التبريد';

  @override
  String get hudBattery => 'البطارية';

  @override
  String get clearWarningTitle => 'تحذير: مسح أكواد الأعطال';

  @override
  String get clearWarningBody =>
      'أنت على وشك مسح كل أكواد الأعطال المسجلة وبيانات اللقطة المتجمدة وإعادة ضبط عدادات الجاهزية. لا يمكن التراجع عن هذا الإجراء. لمبة المحرك ستنطفئ، لكن العطل الميكانيكي قد يكون لا يزال موجودًا وقد تعود اللمبة بعد دورة قيادة.';

  @override
  String get mandatoryPreconditions => 'شروط السلامة الإلزامية:';

  @override
  String get confirmEngineOff => 'أؤكد أن محرك السيارة مطفأ تمامًا (RPM = 0)';

  @override
  String get confirmIgnitionOn =>
      'أؤكد أن الكنتاك مفتوح والطبلون شغال (Key ON / Ignition RUN)';

  @override
  String get confirmClear => 'تأكيد ومسح كل الأكواد';

  @override
  String get customPidTitle => 'إضافة PID مخصص';

  @override
  String get sensorNameLabel => 'اسم الحساس (مثال: حرارة زيت الفتيس)';

  @override
  String get arabicNameOptional => 'الاسم بالعربي (اختياري)';

  @override
  String get modeHexLabel => 'الوضع';

  @override
  String get pidHexLabel => 'PID';

  @override
  String get formulaLabel => 'المعادلة (مثال: A - 40 أو ((A*256)+B)/10)';

  @override
  String get unitLabel => 'الوحدة';

  @override
  String get minValueLabel => 'أدنى';

  @override
  String get maxValueLabel => 'أقصى';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get savePid => 'حفظ PID';

  @override
  String get unitSec => 'ث';

  @override
  String get unitKmh => 'كم/س';

  @override
  String get unitDegC => '°م';

  @override
  String get unitVolt => 'ف';

  @override
  String get unitKpa => 'كيلوباسكال';

  @override
  String get unitMeter => 'م';

  @override
  String get frTitle => 'الصندوق الأسود لتسجيل الرحلة';

  @override
  String get frActive => 'التسجيل نشط';

  @override
  String get frBlackBox => 'مسجل الرحلة (الصندوق الأسود)';

  @override
  String frFramesLogged(int count, String secs) {
    return 'تم تسجيل $count إطار ($secs ث)';
  }

  @override
  String get frRecordsDesc => 'يسجل 10 حساسات أساسية أثناء اختبار الطريق';

  @override
  String get frStop => 'إيقاف وحفظ سجل الرحلة';

  @override
  String get frStart => 'بدء تسجيل رحلة جديدة';

  @override
  String get frVehicleFallback => 'المركبة';

  @override
  String get frSavedLogs => 'سجلات الرحلات المحفوظة (اختبارات الطريق):';

  @override
  String get frNoLogs =>
      'لا توجد سجلات رحلات بعد.\nاضغط «بدء تسجيل رحلة جديدة» أثناء اختبار الطريق لتسجيل البيانات.';

  @override
  String frFramesEntry(String date, int count) {
    return '$date • $count إطار بيانات';
  }

  @override
  String get frExportCsv => 'تصدير CSV (Excel / MegaLogViewer)';

  @override
  String get frDeleteLog => 'حذف السجل';

  @override
  String get frDuration => 'المدة';

  @override
  String get frMaxSpeed => 'أقصى سرعة';

  @override
  String get frMaxRpm => 'أقصى RPM';

  @override
  String get frMaxTemp => 'أقصى حرارة';

  @override
  String get frScrub => 'تصفح وإعادة تشغيل التسجيل';

  @override
  String frTimestamp(String pos, String total) {
    return 'الزمن: $pos ث / $total ث';
  }

  @override
  String get frSpeed => 'السرعة';

  @override
  String get frCoolant => 'حرارة المياه';

  @override
  String get frThrottle => 'الخانق';

  @override
  String get frBattery => 'البطارية';

  @override
  String get topoTitle => 'طوبولوجيا شبكة الكان والكنترولات';

  @override
  String get topoRescan => 'إعادة فحص كل الأنظمة';

  @override
  String get topoBusTitle => 'طوبولوجيا شبكة الـ CAN';

  @override
  String topoModulesOnline(int online, int total, int faults) {
    return '$online / $total كنترول متصل • $faults عطل إجمالي';
  }

  @override
  String get topoScanningBus => 'جاري فحص الشبكة...';

  @override
  String get topoSmartScan => 'الفحص الذكي (كل الكنترولات)';

  @override
  String get topoClearAll => 'مسح الكل';

  @override
  String get topoClearedOk => 'تم مسح أعطال كل الكنترولات!';

  @override
  String get topoClearedFail => 'فشل مسح بعض الكنترولات.';

  @override
  String get topoOpenGraph => 'فتح الرسم التفاعلي للشبكة (CAN/LIN)';

  @override
  String get topoSubsystems => 'أنظمة السيارة المكتشفة:';

  @override
  String get topoScanning => 'جاري الفحص...';

  @override
  String get topoHealthy => 'سليم';

  @override
  String topoFaults(int count) {
    return '$count عطل';
  }

  @override
  String get topoOffline => 'غير موجود / لا يستجيب';

  @override
  String get topoPending => 'في انتظار الفحص';

  @override
  String topoProtocol(String protocol) {
    return 'البروتوكول: $protocol';
  }

  @override
  String topoLatency(int ms) {
    return 'زمن الاستجابة: $ms م.ث';
  }

  @override
  String get topoStoredCodes => 'الأعطال المخزنة:';

  @override
  String get o2Title => 'فحص حساس الشكمان وكفاءة علبة البيئة';

  @override
  String get o2Pause => 'إيقاف الإشارة الحية';

  @override
  String get o2Start => 'تشغيل الإشارة الحية';

  @override
  String get o2HealthTitle => 'حالة علبة البيئة (الكتالايزر)';

  @override
  String o2Efficiency(int pct) {
    return 'كفاءة $pct٪';
  }

  @override
  String get o2Upstream => 'تبدلات الحساس الأمامي';

  @override
  String get o2Downstream => 'تبدلات الحساس الخلفي';

  @override
  String get o2Ratio => 'نسبة التبديل';

  @override
  String get o2Waveforms => 'إشارات حساسي الأكسجين (0.0 - 1.0 فولت)';

  @override
  String get o2UpstreamShort => 'B1S1 (أمامي)';

  @override
  String get o2DownstreamShort => 'B1S2 (خلفي)';

  @override
  String get o2TapPlay =>
      'اضغط زر التشغيل بالأعلى لبدء قراءة حساسات الأكسجين الحية';

  @override
  String get o2Assessment => 'التقييم التشخيصي:';

  @override
  String get o2Guide => 'دليل إجراءات الفني:';

  @override
  String get o2StatusInsufficient => 'طبيعي / عينات غير كافية';

  @override
  String get o2DiagInsufficient => 'جاري جمع بيانات حساسات الأكسجين...';

  @override
  String get o2RecInsufficient =>
      'اترك المحرك على السلست أو بسرعة ثابتة لمدة 15 ثانية لتجميع الإشارات.';

  @override
  String get o2StatusExcellent => 'ممتاز / كفاءة عالية (معيار الوكالة)';

  @override
  String o2DiagExcellent(int upCross, String avgDown) {
    return 'الحساس الأمامي يتبدل بسرعة ($upCross تبدلة) بينما الحساس الخلفي ثابت ومستقر (~$avgDown فولت). علبة البيئة تخزن الأكسجين بكفاءة عالية.';
  }

  @override
  String get o2RecExcellent =>
      'لا تحتاج صيانة. نظام العادم يعمل ضمن الحدود المثلى.';

  @override
  String get o2StatusAging => 'علبة البيئة بدأت في التقادم (كفاءة متوسطة)';

  @override
  String o2DiagAging(int downCross, int upCross, String degradation) {
    return 'الحساس الخلفي بدأ يحاكي تبدلات الأمامي ($downCross مقابل $upCross تبدلة). قدرة تخزين الأكسجين انخفضت بنسبة $degradation٪.';
  }

  @override
  String get o2RecAging =>
      'افحص تسريب وش العادم أو وقود غير محترق من شر. أضف منظف علبة بيئة عالي الجودة.';

  @override
  String get o2StatusFailing => 'تدهور شديد / فشل علبة البيئة (مقدمة P0420)';

  @override
  String o2DiagFailing(String ratio) {
    return 'الحساس الخلفي يحاكي تذبذب الأمامي بنسبة تبديل عالية ($ratio٪). علبة البيئة لم تعد تخزن الأكسجين أو تقلل الانبعاثات.';
  }

  @override
  String get o2RecFailing =>
      'قلب علبة البيئة منصهر أو مفرغ أو متسمم بوقود ملوث. يلزم استبدال العلبة أو تنظيف القلب.';

  @override
  String get dynoTitle => 'داينو التسارع وقياس القوة الحصانية';

  @override
  String get dynoArmed => 'جاهز: أوقف السيارة تمامًا للبدء';

  @override
  String get dynoAccelerating => 'تتسارع: ادعص بنزين!';

  @override
  String get dynoCompleted => 'اكتمل القياس: تم تسجيل 0-100 كم/س!';

  @override
  String get dynoReset => 'إعادة ضبط عدادات الأداء';

  @override
  String get dynoZeroHundred => '0 – 100 كم/س (0 – 62 ميل/س)';

  @override
  String get dynoZeroSixty => 'زمن 0-60 كم/س';

  @override
  String get dynoDistance => 'المسافة المقطوعة';

  @override
  String get dynoMaxSpeed => 'أقصى سرعة';

  @override
  String get dynoQuarter => 'ربع ميل (400 متر)';

  @override
  String dynoTrap(String speed) {
    return 'سرعة النهاية: $speed كم/س';
  }

  @override
  String get dynoBraking => 'فرملة 100 – 0';

  @override
  String get dynoEmergencyStop => 'توقف طارئ';

  @override
  String get dynoEstTitle => 'القوة والعزم التقديرية (داينو):';

  @override
  String dynoWeight(int kg) {
    return 'الوزن: $kg كجم';
  }

  @override
  String get dynoPeakWHP => 'أقصى قوة على العجلات';

  @override
  String get dynoPeakTorque => 'أقصى عزم للمحرك';

  @override
  String dynoAdjustWeight(int kg) {
    return 'اضبط وزن السيارة ($kg كجم):';
  }

  @override
  String get lanTitle => 'مركز مزامنة الورشة (شبكة محلية)';

  @override
  String get lanUnspecified => 'غير محدد';

  @override
  String lanNewReport(String name) {
    return 'تم استلام تقرير فحص جديد لـ: $name';
  }

  @override
  String get lanTabServer => 'الخادم المحلي (رئيسي)';

  @override
  String get lanTabSync => 'مزامنة التقارير (فرعي)';

  @override
  String get lanServerActive => 'الخادم المحلي يعمل';

  @override
  String get lanServerStopped => 'الخادم المحلي متوقف';

  @override
  String get lanActiveDesc =>
      'أي كمبيوتر أو موبايل على شبكة الـ Wi-Fi الخاصة بالورشة يقدر يفتح الرابط بالأسفل';

  @override
  String get lanStoppedDesc =>
      'اضغط الزر بالأسفل لبدء بث التشخيص الحي وكروت الشغل عبر الـ Wi-Fi المحلي';

  @override
  String get lanCopyUrl => 'نسخ الرابط';

  @override
  String get lanCopied => 'تم نسخ رابط الخادم!';

  @override
  String get lanStop => 'إيقاف الخادم';

  @override
  String get lanStart => 'تشغيل خادم الورشة (منفذ 8080)';

  @override
  String get lanStartFail =>
      'تعذر تشغيل الخادم. تأكد أن الجهاز متصل بشبكة Wi-Fi أو نقطة اتصال.';

  @override
  String get lanHowTitle => 'كيف يعمل المركز المحلي بدون إنترنت؟';

  @override
  String get lanHowSteps =>
      '1. تأكد أن تابلت التشخيص وكمبيوتر الاستقبال/الحسابات متصلين بنفس راوتر الـ Wi-Fi الخاص بالورشة أو نقطة اتصال الموبايل.\n2. لا حاجة لإنترنت خارجي أو باقة؛ البيانات تنتقل بالكامل داخل الشبكة المحلية.\n3. افتح Google Chrome على كمبيوتر الاستقبال واكتب الرابط الظاهر بالأعلى.\n4. تظهر شاشة متابعة لحظية تعرض قراءات الحساسات الحية والأعطال وكروت فحص PDF جاهزة للطباعة على ورق A4.';

  @override
  String get lanSyncTitle => 'مزامنة كروت الفحص مع الكمبيوتر الرئيسي';

  @override
  String get lanSyncDesc =>
      'لو تستخدم هذا التابلت تحت السيارة أو في عنبر الصيانة، أرسل كروت الفحص المحفوظة مباشرة إلى كمبيوتر الاستقبال الرئيسي بضغطة واحدة.';

  @override
  String get lanMasterIp => 'عنوان IP للكمبيوتر الرئيسي';

  @override
  String get lanSyncing => 'جاري المزامنة...';

  @override
  String lanSyncAll(int count) {
    return 'مزامنة كل التقارير ($count)';
  }

  @override
  String get lanInvalidIp => 'من فضلك أدخل عنوان IP صحيح للكمبيوتر الرئيسي';

  @override
  String lanSyncResultOk(int success) {
    return 'نتيجة المزامنة: تم إرسال $success تقرير بنجاح بدون أخطاء! ✅';
  }

  @override
  String lanSyncResultFail(int success, int fail) {
    return 'نتيجة المزامنة: تم إرسال $success تقرير بنجاح، وفشل $fail.';
  }
}
