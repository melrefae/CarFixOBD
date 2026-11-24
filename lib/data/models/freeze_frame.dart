/// نموذج بيانات اللحظة المجمدة (Freeze Frame - Mode 02)
/// يمثل لقطة فوتوغرافية لحالة المحرك وجميع الحساسات في اللحظة المحددة التي سجل فيها الكمبيوتر كود العطل
class FreezeFrameModel {
  final String dtcCode;
  final double engineRpm;
  final double vehicleSpeed;
  final double coolantTemp;
  final double engineLoad;
  final double throttlePosition;
  final double intakeAirTemp;
  final double manifoldPressure;
  final double shortTermFuelTrim;
  final double longTermFuelTrim;
  final DateTime timestamp;

  FreezeFrameModel({
    required this.dtcCode,
    required this.engineRpm,
    required this.vehicleSpeed,
    required this.coolantTemp,
    required this.engineLoad,
    required this.throttlePosition,
    required this.intakeAirTemp,
    required this.manifoldPressure,
    required this.shortTermFuelTrim,
    required this.longTermFuelTrim,
    required this.timestamp,
  });

  factory FreezeFrameModel.empty() {
    return FreezeFrameModel(
      dtcCode: "No DTC Recorded",
      engineRpm: 0,
      vehicleSpeed: 0,
      coolantTemp: 0,
      engineLoad: 0,
      throttlePosition: 0,
      intakeAirTemp: 0,
      manifoldPressure: 0,
      shortTermFuelTrim: 0,
      longTermFuelTrim: 0,
      timestamp: DateTime.now(),
    );
  }
}
