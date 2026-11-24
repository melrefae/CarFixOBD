import 'package:flutter/services.dart';

enum AlarmSeverity { warning, critical }

class SafetyAlarm {
  final String id;
  final String titleAr;
  final String messageAr;
  final String titleEn;
  final String messageEn;
  final AlarmSeverity severity;
  final DateTime timestamp;

  SafetyAlarm({
    required this.id,
    required this.titleAr,
    required this.messageAr,
    String? titleEn,
    String? messageEn,
    required this.severity,
    DateTime? timestamp,
  })  : titleEn = titleEn ?? titleAr,
        messageEn = messageEn ?? messageAr,
        timestamp = timestamp ?? DateTime.now();
}

/// Real-time engine safety alarm monitor
class SafetyAlarmService {
  static final SafetyAlarmService _instance = SafetyAlarmService._internal();
  factory SafetyAlarmService() => _instance;
  SafetyAlarmService._internal();

  // Safety threshold defaults
  double maxCoolantTemp = 103.0; // °C
  double minBatteryVoltage = 11.8; // V
  double maxBatteryVoltage = 15.2; // V
  double maxSafeRpm = 5500.0; // RPM

  bool isAudioEnabled = true;
  bool isHapticEnabled = true;

  final List<SafetyAlarm> _activeAlarms = [];
  List<SafetyAlarm> get activeAlarms => List.unmodifiable(_activeAlarms);
  bool get hasCriticalAlarm => _activeAlarms.any((a) => a.severity == AlarmSeverity.critical);

  /// Evaluate live sensors and trigger safety alarms
  List<SafetyAlarm> evaluateSensors({
    required double? coolantTemp,
    required double? batteryVoltage,
    required double? rpm,
  }) {
    _activeAlarms.clear();

    // 1. Coolant temperature check
    if (coolantTemp != null && coolantTemp >= maxCoolantTemp) {
      _activeAlarms.add(
        SafetyAlarm(
          id: 'high_coolant',
          titleAr: "خطر: سخونة مفرطة في المحرك!",
          messageAr: "حرارة المياه وصلت $coolantTemp°C (الحد الآمن: $maxCoolantTemp°C). أوقف المحرك فوراً لتفادي تلف جوان وش السلندر.",
          titleEn: "CRITICAL: Engine Overheating!",
          messageEn: "Coolant temperature reached $coolantTemp°C (safe limit: $maxCoolantTemp°C). Shut off engine immediately to prevent cylinder head damage.",
          severity: AlarmSeverity.critical,
        ),
      );
    }

    // 2. Battery charging system check (under-voltage)
    if (batteryVoltage != null && batteryVoltage > 0 && batteryVoltage < minBatteryVoltage) {
      _activeAlarms.add(
        SafetyAlarm(
          id: 'low_voltage',
          titleAr: "تحذير: ضعف شحن منظومة الكهرباء",
          messageAr: "جهد الشبكة $batteryVoltage V (الدينامو قاطع أو البطارية فارغة).",
          titleEn: "WARNING: Electrical System Low Voltage",
          messageEn: "System voltage dropped to $batteryVoltage V (Alternator undercharging or battery depleted).",
          severity: AlarmSeverity.warning,
        ),
      );
    }

    // 3. Alternator over-charging check (over-voltage)
    if (batteryVoltage != null && batteryVoltage > maxBatteryVoltage) {
      _activeAlarms.add(
        SafetyAlarm(
          id: 'over_voltage',
          titleAr: "خطر: شحن دينامو مفرط (Overvoltage)!",
          messageAr: "الجهد وصل $batteryVoltage V مما قد يتلف كمبيوتر السيارة والحساسات فوراً.",
          titleEn: "CRITICAL: Alternator Overvoltage Detected!",
          messageEn: "System voltage reached $batteryVoltage V. Alternator voltage regulator failure may fry ECU modules.",
          severity: AlarmSeverity.critical,
        ),
      );
    }

    // 4. Over-rev check
    if (rpm != null && rpm > maxSafeRpm) {
      _activeAlarms.add(
        SafetyAlarm(
          id: 'over_rpm',
          titleAr: "تحذير: دوران محرك مرتفع (Over-Rev)",
          messageAr: "سرعة الدوران $rpm RPM تجاوزت الحد الآمن أثناء الاختبار.",
          titleEn: "WARNING: High Engine Speed (Over-Rev)",
          messageEn: "Engine speed reached $rpm RPM, exceeding workshop safety limit.",
          severity: AlarmSeverity.warning,
        ),
      );
    }

    if (_activeAlarms.isNotEmpty && isHapticEnabled) {
      _triggerHaptic();
    }

    return _activeAlarms;
  }

  void _triggerHaptic() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  void clearAlarms() {
    _activeAlarms.clear();
  }
}
