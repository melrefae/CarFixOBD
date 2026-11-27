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
}
