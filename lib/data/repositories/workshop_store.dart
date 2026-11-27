import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workshop_records.dart';

/// Local storage for saved inspections, the wizard draft and job cards.
/// Data stays on the phone (SharedPreferences JSON plus PDF files in app documents).
class WorkshopStore {
  static const _kInspections = 'ws_inspections_v1';
  static const _kJobs = 'ws_jobcards_v1';
  static const _kDraft = 'ws_wizard_draft_v1';

  static Future<List<InspectionRecord>> inspections() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kInspections) ?? const [];
    final out = <InspectionRecord>[];
    for (final s in raw) {
      try {
        out.add(InspectionRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  static Future<void> saveInspection(InspectionRecord r) async {
    final p = await SharedPreferences.getInstance();
    final raw = List<String>.from(p.getStringList(_kInspections) ?? const []);
    raw.removeWhere((s) {
      try { return (jsonDecode(s) as Map)['id'] == r.id; } catch (_) { return false; }
    });
    raw.add(jsonEncode(r.toJson()));
    await p.setStringList(_kInspections, raw);
  }

  static Future<void> deleteInspection(String id) async {
    final p = await SharedPreferences.getInstance();
    final raw = List<String>.from(p.getStringList(_kInspections) ?? const []);
    String? pdf;
    raw.removeWhere((s) {
      try {
        final m = jsonDecode(s) as Map;
        if (m['id'] == id) { pdf = m['pdfPath'] as String?; return true; }
      } catch (_) {}
      return false;
    });
    await p.setStringList(_kInspections, raw);
    if (pdf != null) { try { await File(pdf!).delete(); } catch (_) {} }
  }

  static Future<String> savePdf(String id, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final d = Directory('${dir.path}/inspections');
    if (!await d.exists()) await d.create(recursive: true);
    final f = File('${d.path}/$id.pdf');
    await f.writeAsBytes(bytes, flush: true);
    return f.path;
  }

  // ---- wizard draft ----
  static Future<Map<String, dynamic>?> loadDraft() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kDraft);
    if (s == null) return null;
    try { return jsonDecode(s) as Map<String, dynamic>; } catch (_) { return null; }
  }

  static Future<void> saveDraft(Map<String, dynamic> d) async =>
      (await SharedPreferences.getInstance()).setString(_kDraft, jsonEncode(d));

  static Future<void> clearDraft() async => (await SharedPreferences.getInstance()).remove(_kDraft);

  // ---- job cards ----
  static Future<List<JobCard>> jobs() async {
    final p = await SharedPreferences.getInstance();
    final out = <JobCard>[];
    for (final s in p.getStringList(_kJobs) ?? const <String>[]) {
      try { out.add(JobCard.fromJson(jsonDecode(s) as Map<String, dynamic>)); } catch (_) {}
    }
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  static Future<void> saveJob(JobCard j) async {
    final p = await SharedPreferences.getInstance();
    final raw = List<String>.from(p.getStringList(_kJobs) ?? const []);
    raw.removeWhere((s) {
      try { return (jsonDecode(s) as Map)['id'] == j.id; } catch (_) { return false; }
    });
    raw.add(jsonEncode(j.toJson()));
    await p.setStringList(_kJobs, raw);
  }

  static Future<void> deleteJob(String id) async {
    final p = await SharedPreferences.getInstance();
    final raw = List<String>.from(p.getStringList(_kJobs) ?? const []);
    raw.removeWhere((s) {
      try { return (jsonDecode(s) as Map)['id'] == id; } catch (_) { return false; }
    });
    await p.setStringList(_kJobs, raw);
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
