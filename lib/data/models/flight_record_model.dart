/// Single snapshot frame recorded during a black box flight log
class FlightTelemetryFrame {
  final int timestampMs;
  final double speed;
  final double rpm;
  final double coolantTemp;
  final double batteryVoltage;
  final double mapKpa;
  final double throttlePercent;
  final double stft;
  final double ltft;
  final double o2B1S1;
  final double o2B1S2;

  const FlightTelemetryFrame({
    required this.timestampMs,
    required this.speed,
    required this.rpm,
    required this.coolantTemp,
    required this.batteryVoltage,
    required this.mapKpa,
    required this.throttlePercent,
    required this.stft,
    required this.ltft,
    required this.o2B1S1,
    required this.o2B1S2,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'speed': speed,
        'rpm': rpm,
        'coolantTemp': coolantTemp,
        'batteryVoltage': batteryVoltage,
        'mapKpa': mapKpa,
        'throttlePercent': throttlePercent,
        'stft': stft,
        'ltft': ltft,
        'o2B1S1': o2B1S1,
        'o2B1S2': o2B1S2,
      };

  factory FlightTelemetryFrame.fromJson(Map<String, dynamic> json) => FlightTelemetryFrame(
        timestampMs: json['timestampMs'] ?? 0,
        speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
        rpm: (json['rpm'] as num?)?.toDouble() ?? 0.0,
        coolantTemp: (json['coolantTemp'] as num?)?.toDouble() ?? 0.0,
        batteryVoltage: (json['batteryVoltage'] as num?)?.toDouble() ?? 0.0,
        mapKpa: (json['mapKpa'] as num?)?.toDouble() ?? 0.0,
        throttlePercent: (json['throttlePercent'] as num?)?.toDouble() ?? 0.0,
        stft: (json['stft'] as num?)?.toDouble() ?? 0.0,
        ltft: (json['ltft'] as num?)?.toDouble() ?? 0.0,
        o2B1S1: (json['o2B1S1'] as num?)?.toDouble() ?? 0.0,
        o2B1S2: (json['o2B1S2'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Black Box recorded driving flight session
class FlightRecordingSession {
  final String id;
  final String vehicleTitle;
  final DateTime recordedAt;
  final List<FlightTelemetryFrame> frames;

  FlightRecordingSession({
    required this.id,
    required this.vehicleTitle,
    required this.recordedAt,
    List<FlightTelemetryFrame>? frames,
  }) : frames = frames ?? [];

  int get durationMs => frames.isEmpty ? 0 : frames.last.timestampMs;
  int get frameCount => frames.length;

  double get maxSpeed =>
      frames.isEmpty ? 0.0 : frames.map((f) => f.speed).reduce((a, b) => a > b ? a : b);

  double get maxRpm =>
      frames.isEmpty ? 0.0 : frames.map((f) => f.rpm).reduce((a, b) => a > b ? a : b);

  double get maxCoolant =>
      frames.isEmpty ? 0.0 : frames.map((f) => f.coolantTemp).reduce((a, b) => a > b ? a : b);

  /// Convert flight log to standard CSV compatible with Excel & MegaLogViewer
  String toCsv() {
    final sb = StringBuffer();
    sb.writeln("Time_ms,Speed_kmh,RPM,Coolant_C,Voltage_V,MAP_kPa,Throttle_pct,STFT_pct,LTFT_pct,O2_B1S1_V,O2_B1S2_V");
    for (final f in frames) {
      sb.writeln(
        "${f.timestampMs},"
        "${f.speed.toStringAsFixed(1)},"
        "${f.rpm.toStringAsFixed(0)},"
        "${f.coolantTemp.toStringAsFixed(1)},"
        "${f.batteryVoltage.toStringAsFixed(2)},"
        "${f.mapKpa.toStringAsFixed(1)},"
        "${f.throttlePercent.toStringAsFixed(1)},"
        "${f.stft.toStringAsFixed(1)},"
        "${f.ltft.toStringAsFixed(1)},"
        "${f.o2B1S1.toStringAsFixed(3)},"
        "${f.o2B1S2.toStringAsFixed(3)}",
      );
    }
    return sb.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleTitle': vehicleTitle,
        'recordedAt': recordedAt.toIso8601String(),
        'frames': frames.map((f) => f.toJson()).toList(),
      };

  factory FlightRecordingSession.fromJson(Map<String, dynamic> json) => FlightRecordingSession(
        id: json['id'] ?? '',
        vehicleTitle: json['vehicleTitle'] ?? 'Vehicle',
        recordedAt: DateTime.tryParse(json['recordedAt'] ?? '') ?? DateTime.now(),
        frames: (json['frames'] as List<dynamic>?)
                ?.map((item) => FlightTelemetryFrame.fromJson(item))
                .toList() ??
            [],
      );
}
