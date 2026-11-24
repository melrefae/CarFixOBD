import 'dart:math';

enum PerformanceRunState {
  standstillReady, // Vehicle stopped, waiting for driver to hit throttle
  accelerating,    // Run in progress
  completed,       // 0-100 km/h reached
  brakingTest,     // Braking from 100 to 0
}

/// Computes vehicle acceleration, drag times, braking distance, and estimated dyno horsepower
class DynoPerformanceCalculator {
  PerformanceRunState state = PerformanceRunState.standstillReady;

  int? _launchTimestampMs;
  int? _timeAt60Ms;
  int? _timeAt100Ms;

  int? get timeAt60Ms => _timeAt60Ms;
  int? get timeAt100Ms => _timeAt100Ms;

  double? zeroToSixtySec;
  double? zeroToHundredSec;
  double? quarterMileSec;
  double? quarterMileTrapSpeedKmh;

  double distanceMeters = 0.0;
  double peakWheelHp = 0.0;
  double peakTorqueNm = 0.0;
  double maxRecordedSpeedKmh = 0.0;

  double _lastSpeedKmh = 0.0;
  int _lastTimestampMs = 0;

  // Braking test variables
  bool _brakingArmed = false;
  double? brakingDistanceMeters;
  double _brakingStartDistance = 0.0;

  void reset() {
    state = PerformanceRunState.standstillReady;
    _launchTimestampMs = null;
    _timeAt60Ms = null;
    _timeAt100Ms = null;
    zeroToSixtySec = null;
    zeroToHundredSec = null;
    quarterMileSec = null;
    quarterMileTrapSpeedKmh = null;
    distanceMeters = 0.0;
    peakWheelHp = 0.0;
    peakTorqueNm = 0.0;
    maxRecordedSpeedKmh = 0.0;
    _lastSpeedKmh = 0.0;
    _lastTimestampMs = 0;
    _brakingArmed = false;
    brakingDistanceMeters = null;
    _brakingStartDistance = 0.0;
  }

  /// Ingest real-time vehicle telemetry sample
  void ingestSample({
    required double speedKmh,
    required double rpm,
    required int timestampMs,
    double curbWeightKg = 1200.0,
  }) {
    if (speedKmh > maxRecordedSpeedKmh) {
      maxRecordedSpeedKmh = speedKmh;
    }

    if (_lastTimestampMs == 0) {
      _lastTimestampMs = timestampMs;
      _lastSpeedKmh = speedKmh;
      return;
    }

    final dtSec = (timestampMs - _lastTimestampMs) / 1000.0;
    _lastTimestampMs = timestampMs;

    if (dtSec <= 0 || dtSec > 1.5) {
      _lastSpeedKmh = speedKmh;
      return;
    }

    // Distance accumulation via trapezoidal speed integration
    final avgSpeedMs = ((_lastSpeedKmh + speedKmh) / 2.0) * (1000.0 / 3600.0);
    final incrementalDistance = avgSpeedMs * dtSec;
    distanceMeters += incrementalDistance;

    // Acceleration derivation (m/s^2)
    final vPrevMs = _lastSpeedKmh * (1000.0 / 3600.0);
    final vCurrMs = speedKmh * (1000.0 / 3600.0);
    final accelMs2 = (vCurrMs - vPrevMs) / dtSec;

    // Instantaneous Wheel Horsepower (P = m * a * v) + Rolling/Aero Drag approximation
    if (accelMs2 > 0 && speedKmh > 10) {
      final forceInertial = curbWeightKg * accelMs2;
      final forceAero = 0.5 * 1.225 * 0.32 * 2.1 * pow(vCurrMs, 2); // Cd ~ 0.32, frontal ~ 2.1 m^2
      final forceTotal = forceInertial + forceAero;
      final powerWatts = forceTotal * vCurrMs;
      final currentWhp = powerWatts / 745.7;

      if (currentWhp > peakWheelHp && currentWhp < 1500) {
        peakWheelHp = currentWhp;
      }

      if (rpm > 1000 && rpm < 8000) {
        final powerKw = powerWatts / 1000.0;
        final currentTorque = (9549.0 * powerKw) / rpm;
        if (currentTorque > peakTorqueNm && currentTorque < 2000) {
          peakTorqueNm = currentTorque;
        }
      }
    }

    // 0-100 km/h acceleration state machine
    if (state == PerformanceRunState.standstillReady) {
      if (_lastSpeedKmh <= 1.0 && speedKmh > 2.0) {
        state = PerformanceRunState.accelerating;
        _launchTimestampMs = timestampMs;
        distanceMeters = 0.0;
      }
    } else if (state == PerformanceRunState.accelerating) {
      final elapsedSec = (timestampMs - (_launchTimestampMs ?? timestampMs)) / 1000.0;

      if (speedKmh >= 60.0 && zeroToSixtySec == null) {
        _timeAt60Ms = timestampMs;
        zeroToSixtySec = elapsedSec;
      }

      if (speedKmh >= 100.0 && zeroToHundredSec == null) {
        _timeAt100Ms = timestampMs;
        zeroToHundredSec = elapsedSec;
        state = PerformanceRunState.completed;
      }

      if (distanceMeters >= 402.3 && quarterMileSec == null) {
        quarterMileSec = elapsedSec;
        quarterMileTrapSpeedKmh = speedKmh;
      }
    }

    // Braking 100 -> 0 km/h measurement
    if (speedKmh >= 100.0 && !_brakingArmed) {
      _brakingArmed = true;
      _brakingStartDistance = distanceMeters;
    } else if (_brakingArmed) {
      if (speedKmh <= 1.5) {
        brakingDistanceMeters = distanceMeters - _brakingStartDistance;
        _brakingArmed = false;
      }
    }

    _lastSpeedKmh = speedKmh;
  }
}
