/// Raw request/response log for every command sent to the adapter.
/// Used as evidence when a feature is tested on a real car.
class TrafficEntry {
  final DateTime time;
  final String request;
  final String response;
  const TrafficEntry(this.time, this.request, this.response);
  @override
  String toString() => '${time.toIso8601String()} > $request | < ${response.replaceAll(RegExp(r"[\r\n]+"), " ")}';
}

class TrafficLog {
  TrafficLog._();
  static final TrafficLog instance = TrafficLog._();
  final List<TrafficEntry> entries = [];
  static const int maxEntries = 5000;

  void add(String request, String response) {
    entries.add(TrafficEntry(DateTime.now(), request, response));
    if (entries.length > maxEntries) entries.removeAt(0);
  }

  String export() => entries.map((e) => e.toString()).join('\n');
  void clear() => entries.clear();
}
