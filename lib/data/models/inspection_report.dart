import 'dtc_model.dart';

/// نموذج تقرير فحص السيارة وكارت العمل الفني للورشة
class InspectionReport {
  final String id;
  final String plateNumber; // رقم اللوحة
  final String vin; // رقم الشاسيه
  final String customerName;
  final String customerPhone;
  final String vehicleMakeModel;
  final DateTime timestamp;
  final double batteryVoltage;
  final bool milStatusOn; // هل لمبة الأعطال كانت منورة
  final List<DtcModel> dtcsFound;
  final Map<String, String> liveSensorsSnapshot;
  final String mechanicNotes;
  final String workshopName;

  InspectionReport({
    required this.id,
    required this.plateNumber,
    required this.vin,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleMakeModel,
    required this.timestamp,
    required this.batteryVoltage,
    required this.milStatusOn,
    required this.dtcsFound,
    required this.liveSensorsSnapshot,
    required this.mechanicNotes,
    this.workshopName = "Aspect Auto Care Diagnostic Center",
  });

  String get vehicleModel => vehicleMakeModel;
  String get vehicleMake => vehicleMakeModel.split(' ').first;
  List<DtcModel> get dtcCodes => dtcsFound;
  List<DtcModel> get dtcs => dtcsFound;
  int get mileageKm => 0;
  bool get milStatus => milStatusOn;
  String get technicianNotes => mechanicNotes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'vin': vin,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'vehicle_make_model': vehicleMakeModel,
      'timestamp': timestamp.toIso8601String(),
      'battery_voltage': batteryVoltage,
      'mil_status_on': milStatusOn,
      'dtcs_found': dtcsFound.map((d) => d.toMap()).toList(),
      'live_sensors_snapshot': liveSensorsSnapshot,
      'mechanic_notes': mechanicNotes,
      'workshop_name': workshopName,
    };
  }

  factory InspectionReport.fromJson(Map<String, dynamic> json) {
    return InspectionReport(
      id: json['id'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      vin: json['vin'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      vehicleMakeModel: json['vehicle_make_model'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      batteryVoltage: (json['battery_voltage'] as num?)?.toDouble() ?? 12.6,
      milStatusOn: json['mil_status_on'] ?? false,
      dtcsFound: (json['dtcs_found'] as List<dynamic>?)
              ?.map((item) => DtcModel.fromJson(item['code'] ?? '', item))
              .toList() ??
          [],
      liveSensorsSnapshot: Map<String, String>.from(json['live_sensors_snapshot'] ?? {}),
      mechanicNotes: json['mechanic_notes'] ?? '',
      workshopName: json['workshop_name'] ?? "Aspect Auto Care Diagnostic Center",
    );
  }
}
