import 'dart:collection';

/// مستوى سجل الأحداث
enum LogLevel { info, tx, rx, warning, error }

/// كائن سجل الحدث
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  LogEntry({required this.level, required this.message}) : timestamp = DateTime.now();

  String get formattedTime {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}";
  }

  @override
  String toString() {
    final lvl = level.name.toUpperCase().padRight(5);
    return "[$formattedTime] [$lvl] $message";
  }
}

/// الصندوق الأسود لتسجيل حركة البيانات والأخطاء (Diagnostic Blackbox Logger)
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  final Queue<LogEntry> _logs = Queue<LogEntry>();
  static const int maxCapacity = 500;

  List<LogEntry> get logs => _logs.toList();

  void log(LogLevel level, String message) {
    if (_logs.length >= maxCapacity) {
      _logs.removeFirst();
    }
    _logs.add(LogEntry(level: level, message: message));
  }

  void tx(String cmd) => log(LogLevel.tx, "TX -> $cmd");
  void rx(String reply) => log(LogLevel.rx, "RX <- $reply");
  void info(String msg) => log(LogLevel.info, msg);
  void warning(String msg) => log(LogLevel.warning, msg);
  void error(String msg) => log(LogLevel.error, msg);

  /// تصدير كامل السجل كنص متصل لمشاركته عند وجود مشكلة
  String exportLogs() {
    return _logs.map((e) => e.toString()).join('\n');
  }

  void clear() {
    _logs.clear();
  }
}
