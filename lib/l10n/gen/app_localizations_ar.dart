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
}
