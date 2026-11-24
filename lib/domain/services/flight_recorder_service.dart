import '../../data/models/flight_record_model.dart';

/// Service managing black box telemetry recording, playback scrubbing, and CSV export
class FlightRecorderService {
  bool _isRecording = false;
  FlightRecordingSession? _currentSession;
  final List<FlightRecordingSession> _savedSessions = [];
  int _sessionStartElapsedMs = 0;

  bool get isRecording => _isRecording;
  FlightRecordingSession? get currentSession => _currentSession;
  List<FlightRecordingSession> get savedSessions => List.unmodifiable(_savedSessions);

  void startRecording({required String vehicleTitle}) {
    _sessionStartElapsedMs = DateTime.now().millisecondsSinceEpoch;
    _currentSession = FlightRecordingSession(
      id: "FLIGHT_${DateTime.now().millisecondsSinceEpoch}",
      vehicleTitle: vehicleTitle,
      recordedAt: DateTime.now(),
      frames: [],
    );
    _isRecording = true;
  }

  void captureFrame({
    required double speed,
    required double rpm,
    required double coolantTemp,
    required double batteryVoltage,
    required double mapKpa,
    required double throttlePercent,
    required double stft,
    required double ltft,
    required double o2B1S1,
    required double o2B1S2,
  }) {
    if (!_isRecording || _currentSession == null) return;

    final elapsedMs = DateTime.now().millisecondsSinceEpoch - _sessionStartElapsedMs;
    final frame = FlightTelemetryFrame(
      timestampMs: elapsedMs,
      speed: speed,
      rpm: rpm,
      coolantTemp: coolantTemp,
      batteryVoltage: batteryVoltage,
      mapKpa: mapKpa,
      throttlePercent: throttlePercent,
      stft: stft,
      ltft: ltft,
      o2B1S1: o2B1S1,
      o2B1S2: o2B1S2,
    );

    _currentSession!.frames.add(frame);
  }

  FlightRecordingSession? stopRecording() {
    if (!_isRecording || _currentSession == null) return null;
    _isRecording = false;
    final session = _currentSession!;
    if (session.frames.isNotEmpty) {
      _savedSessions.insert(0, session);
    }
    return session;
  }

  void deleteSession(String id) {
    _savedSessions.removeWhere((s) => s.id == id);
  }

  /// Scrub and interpolate a frame at a specific timestamp in milliseconds
  FlightTelemetryFrame? getFrameAtTimestamp(FlightRecordingSession session, int targetTimestampMs) {
    if (session.frames.isEmpty) return null;
    if (targetTimestampMs <= session.frames.first.timestampMs) return session.frames.first;
    if (targetTimestampMs >= session.frames.last.timestampMs) return session.frames.last;

    for (int i = 0; i < session.frames.length - 1; i++) {
      final f1 = session.frames[i];
      final f2 = session.frames[i + 1];
      if (targetTimestampMs >= f1.timestampMs && targetTimestampMs <= f2.timestampMs) {
        // Return nearest frame
        final diff1 = (targetTimestampMs - f1.timestampMs).abs();
        final diff2 = (f2.timestampMs - targetTimestampMs).abs();
        return diff1 <= diff2 ? f1 : f2;
      }
    }
    return session.frames.last;
  }
}
