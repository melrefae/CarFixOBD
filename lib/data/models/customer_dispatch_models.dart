import 'dart:core';

/// Models for Workshop WhatsApp Customer Care & Dispatch Hub
enum DispatchStage {
  checkIn,
  diagnosticFindings,
  estimateApproval,
  finalInspectionReport,
  readyForPickup,
}

class CustomerWorkOrder {
  final String orderId;
  final String customerName;
  final String phoneNumber;
  final String plateNumber;
  final String vehicleModel;
  final int currentMileageKm;
  final DispatchStage currentStage;
  final int activeDtcCount;
  final double estimatedCost;
  final DateTime createdAt;
  final String? pdfReportPath;

  const CustomerWorkOrder({
    required this.orderId,
    required this.customerName,
    required this.phoneNumber,
    required this.plateNumber,
    required this.vehicleModel,
    required this.currentMileageKm,
    this.currentStage = DispatchStage.checkIn,
    this.activeDtcCount = 0,
    this.estimatedCost = 0.0,
    required this.createdAt,
    this.pdfReportPath,
  });

  CustomerWorkOrder copyWith({
    String? orderId,
    String? customerName,
    String? phoneNumber,
    String? plateNumber,
    String? vehicleModel,
    int? currentMileageKm,
    DispatchStage? currentStage,
    int? activeDtcCount,
    double? estimatedCost,
    DateTime? createdAt,
    String? pdfReportPath,
  }) {
    return CustomerWorkOrder(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      currentMileageKm: currentMileageKm ?? this.currentMileageKm,
      currentStage: currentStage ?? this.currentStage,
      activeDtcCount: activeDtcCount ?? this.activeDtcCount,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      createdAt: createdAt ?? this.createdAt,
      pdfReportPath: pdfReportPath ?? this.pdfReportPath,
    );
  }

  String stageTitle(bool isArabic) {
    if (isArabic) {
      switch (currentStage) {
        case DispatchStage.checkIn:
          return "استلام السيارة (Check-in)";
        case DispatchStage.diagnosticFindings:
          return "تقرير الفحص المبدئي (الأعطال)";
        case DispatchStage.estimateApproval:
          return "موافقة تكلفة الإصلاح";
        case DispatchStage.finalInspectionReport:
          return "شهادة الفحص النهائي وPDF";
        case DispatchStage.readyForPickup:
          return "السيارة جاهزة للاستلام";
      }
    } else {
      switch (currentStage) {
        case DispatchStage.checkIn:
          return "Vehicle Check-In";
        case DispatchStage.diagnosticFindings:
          return "Diagnostic Scan Findings";
        case DispatchStage.estimateApproval:
          return "Estimate & Repair Approval";
        case DispatchStage.finalInspectionReport:
          return "Final Inspection Report (PDF)";
        case DispatchStage.readyForPickup:
          return "Vehicle Ready for Pickup";
      }
    }
  }

  /// Generate personalized WhatsApp message template
  String generateWhatsappMessage(
    DispatchStage stage,
    bool isArabic, {
    String workshopName = "AutoSpect Diagnostic Center",
  }) {
    if (isArabic) {
      switch (stage) {
        case DispatchStage.checkIn:
          return "مرحباً يا أستاذ $customerName! 🚗\n"
              "تم استلام سيارتكم ($vehicleModel - لوحات $plateNumber) بنجاح في $workshopName.\n"
              "العداد المسجل عند الدخول: $currentMileageKm كم.\n"
              "فريقنا الفني بدأ الآن أعمال الفحص الإلكتروني الشامل، وسنوافيكم بكافة التفاصيل فوراً. 🔧";

        case DispatchStage.diagnosticFindings:
          return "أهلاً يا أستاذ $customerName،\n"
              "انتهى الفحص الكمبيوتري لسيارتكم ($vehicleModel - $plateNumber).\n"
              "نتيجة الفحص: تم رصد ($activeDtcCount) أكواد أعطال تتطلب الصيانة والمراجعة الفنية.\n"
              "نحن نجهز حالياً خطة الإصلاح وقطع الغيار المطلوبة لضمان أعلى أداء.";

        case DispatchStage.estimateApproval:
          return "عزيزي العميل $customerName،\n"
              "بخصوص سيارتكم ($vehicleModel)، قيمة تكلفة الإصلاح التقديرية شاملة الفحص والمصنعية: ${estimatedCost.toStringAsFixed(0)} ج.م.\n"
              "برجاء الرد بالموافقة للبدء الفوري في أعمال الإصلاح وتغيير القطع اللازمة. شكراً لثقتكم!";

        case DispatchStage.finalInspectionReport:
          return "مرحباً أستاذ $customerName،\n"
              "يسعدنا إعلامكم بانتهاء فحص السيارة المستعملة لمركبتكم ($vehicleModel - لوحات $plateNumber).\n"
              "تم إصدار التقرير الفني الشامل المعتمد (6 تقارير جنائية وكشف تلاعب العداد) ومرفق نسخة PDF رسمية وموثقة.";

        case DispatchStage.readyForPickup:
          return "ألف مبروك يا أستاذ $customerName! 🎉\n"
              "سيارتكم ($vehicleModel - $plateNumber) جاهزة للاستلام الآن بعد إتمام كافة الاختبارات بنجاح 100%.\n"
              "الإجمالي المطلوب: ${estimatedCost.toStringAsFixed(0)} ج.م.\n"
              "العنوان: $workshopName. مواعيد العمل من 9 صباحاً حتى 10 مساءً.";
      }
    } else {
      switch (stage) {
        case DispatchStage.checkIn:
          return "Hello Mr. $customerName! 🚗\n"
              "Your vehicle ($vehicleModel - Plate: $plateNumber) has been checked in successfully at $workshopName.\n"
              "Odometer reading: $currentMileageKm km.\n"
              "Our diagnostic engineering team has started the comprehensive electronic scan. We will update you shortly! 🔧";

        case DispatchStage.diagnosticFindings:
          return "Hello Mr. $customerName,\n"
              "The full computer diagnostic scan for your vehicle ($vehicleModel - $plateNumber) is complete.\n"
              "Result: $activeDtcCount active diagnostic fault codes detected requiring technical attention.\n"
              "We are preparing the exact repair roadmap and component checklist.";

        case DispatchStage.estimateApproval:
          return "Dear $customerName,\n"
              "Regarding your vehicle ($vehicleModel), the estimated repair cost including parts and workshop labor is: ${estimatedCost.toStringAsFixed(0)} EGP.\n"
              "Please reply with your approval to proceed with the service. Thank you!";

        case DispatchStage.finalInspectionReport:
          return "Hello $customerName,\n"
              "We are pleased to provide the official Pre-Purchase Forensic Inspection Certificate for vehicle ($vehicleModel - Plate $plateNumber).\n"
              "Attached is the official 6-Report inspection PDF with odometer verification and tamper analysis.";

        case DispatchStage.readyForPickup:
          return "Congratulations Mr. $customerName! 🎉\n"
              "Your vehicle ($vehicleModel - $plateNumber) is now repaired, fully tested, and ready for pickup.\n"
              "Total Amount: ${estimatedCost.toStringAsFixed(0)} EGP.\n"
              "Location: $workshopName. Working hours: 9:00 AM - 10:00 PM.";
      }
    }
  }

  /// Clean phone number and generate WhatsApp deep link URL
  Uri getWhatsappUrl(
    DispatchStage stage,
    bool isArabic, {
    String workshopName = "AutoSpect Diagnostic Center",
  }) {
    // Sanitize phone number (e.g. 01012345678 -> 201012345678)
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0') && cleanPhone.length == 11) {
      cleanPhone = '20${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('20') && cleanPhone.length == 10) {
      cleanPhone = '20$cleanPhone';
    }

    final message = generateWhatsappMessage(stage, isArabic, workshopName: workshopName);
    return Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
  }

  static List<CustomerWorkOrder> sampleOrders = [
    CustomerWorkOrder(
      orderId: "WO-9041",
      customerName: "Ahmed Mostafa",
      phoneNumber: "01001234567",
      plateNumber: "ABC 1234",
      vehicleModel: "Hyundai Tucson 1.6T (2022)",
      currentMileageKm: 68420,
      currentStage: DispatchStage.diagnosticFindings,
      activeDtcCount: 2,
      estimatedCost: 3450.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CustomerWorkOrder(
      orderId: "WO-9042",
      customerName: "Karim El-Sayed",
      phoneNumber: "01229876543",
      plateNumber: "XYZ 5678",
      vehicleModel: "Kia Sportage 1.6 GDI (2020)",
      currentMileageKm: 114500,
      currentStage: DispatchStage.estimateApproval,
      activeDtcCount: 3,
      estimatedCost: 5800.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    CustomerWorkOrder(
      orderId: "WO-9043",
      customerName: "Tarek Mansour",
      phoneNumber: "01115554321",
      plateNumber: "CAI 9012",
      vehicleModel: "Toyota Corolla 1.6 Dual VVT-i (2021)",
      currentMileageKm: 45200,
      currentStage: DispatchStage.finalInspectionReport,
      activeDtcCount: 0,
      estimatedCost: 1200.0,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];
}
