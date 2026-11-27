/// Saved inspection visit (one per inspection, grouped per car by plate or VIN).
class InspectionRecord {
  final String id;
  final DateTime createdAt;
  final String plate;
  final String customer;
  final String vehicleName;
  final String vin; // from the car, may be empty
  final bool carRead; // false = "no car" inspection
  final Map<String, String> carSnapshot; // facts read from the car (strings, 'not read' when missing)
  final Map<String, dynamic> extra; // InspectionExtra.toJson()
  final Map<String, int> checklist; // item id -> ManualCheckItemStatus index
  final String? pdfPath;

  const InspectionRecord({
    required this.id,
    required this.createdAt,
    required this.plate,
    required this.customer,
    required this.vehicleName,
    required this.vin,
    required this.carRead,
    required this.carSnapshot,
    required this.extra,
    required this.checklist,
    this.pdfPath,
  });

  /// Cars are matched by VIN if known, else by plate (upper-case, no spaces).
  String get carKey {
    final p = plate.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (p.isNotEmpty) return 'PLATE:$p';
    if (vin.isNotEmpty) return 'VIN:$vin';
    return 'UNKNOWN';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'plate': plate,
        'customer': customer,
        'vehicleName': vehicleName,
        'vin': vin,
        'carRead': carRead,
        'carSnapshot': carSnapshot,
        'extra': extra,
        'checklist': checklist,
        'pdfPath': pdfPath,
      };

  factory InspectionRecord.fromJson(Map<String, dynamic> j) => InspectionRecord(
        id: j['id'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        plate: (j['plate'] ?? '') as String,
        customer: (j['customer'] ?? '') as String,
        vehicleName: (j['vehicleName'] ?? '') as String,
        vin: (j['vin'] ?? '') as String,
        carRead: (j['carRead'] ?? false) as bool,
        carSnapshot: Map<String, String>.from((j['carSnapshot'] ?? {}) as Map),
        extra: Map<String, dynamic>.from((j['extra'] ?? {}) as Map),
        checklist: Map<String, int>.from((j['checklist'] ?? {}) as Map),
        pdfPath: j['pdfPath'] as String?,
      );
}

class JobLineItem {
  String description;
  bool isLabour; // false = part
  double qty;
  double unitPrice; // EGP

  JobLineItem({this.description = '', this.isLabour = false, this.qty = 1, this.unitPrice = 0});

  double get total => qty * unitPrice;

  Map<String, dynamic> toJson() => {'d': description, 'l': isLabour, 'q': qty, 'p': unitPrice};
  factory JobLineItem.fromJson(Map<String, dynamic> j) => JobLineItem(
        description: (j['d'] ?? '') as String,
        isLabour: (j['l'] ?? false) as bool,
        qty: ((j['q'] ?? 1) as num).toDouble(),
        unitPrice: ((j['p'] ?? 0) as num).toDouble(),
      );
}

enum JobStatus { quote, approved, inProgress, done, delivered }

class JobCard {
  final String id;
  DateTime createdAt;
  String plate;
  String customer;
  String phone; // international format digits for WhatsApp, e.g. 201001234567
  String vehicle;
  String odometerKm;
  String complaint;
  String findings;
  JobStatus status;
  double discount; // EGP
  double vatPercent; // 0 by default; only what the user enters
  final List<JobLineItem> items;
  String? inspectionId;

  JobCard({
    required this.id,
    DateTime? createdAt,
    this.plate = '',
    this.customer = '',
    this.phone = '',
    this.vehicle = '',
    this.odometerKm = '',
    this.complaint = '',
    this.findings = '',
    this.status = JobStatus.quote,
    this.discount = 0,
    this.vatPercent = 0,
    List<JobLineItem>? items,
    this.inspectionId,
  })  : createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  double get subtotal => items.fold(0.0, (a, i) => a + i.total);
  double get partsTotal => items.where((i) => !i.isLabour).fold(0.0, (a, i) => a + i.total);
  double get labourTotal => items.where((i) => i.isLabour).fold(0.0, (a, i) => a + i.total);
  double get afterDiscount => (subtotal - discount).clamp(0, double.infinity).toDouble();
  double get vat => afterDiscount * vatPercent / 100.0;
  double get total => afterDiscount + vat;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'plate': plate,
        'customer': customer,
        'phone': phone,
        'vehicle': vehicle,
        'odometerKm': odometerKm,
        'complaint': complaint,
        'findings': findings,
        'status': status.index,
        'discount': discount,
        'vatPercent': vatPercent,
        'items': items.map((i) => i.toJson()).toList(),
        'inspectionId': inspectionId,
      };

  factory JobCard.fromJson(Map<String, dynamic> j) {
    final s = (j['status'] ?? 0) as int;
    return JobCard(
      id: j['id'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      plate: (j['plate'] ?? '') as String,
      customer: (j['customer'] ?? '') as String,
      phone: (j['phone'] ?? '') as String,
      vehicle: (j['vehicle'] ?? '') as String,
      odometerKm: (j['odometerKm'] ?? '') as String,
      complaint: (j['complaint'] ?? '') as String,
      findings: (j['findings'] ?? '') as String,
      status: JobStatus.values[s.clamp(0, JobStatus.values.length - 1)],
      discount: ((j['discount'] ?? 0) as num).toDouble(),
      vatPercent: ((j['vatPercent'] ?? 0) as num).toDouble(),
      items: ((j['items'] ?? const []) as List).map((e) => JobLineItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      inspectionId: j['inspectionId'] as String?,
    );
  }
}
