import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inspection_report.dart';

/// مستودع حفظ وأرشفة كروت وتقارير الفحص محلياً
class ReportRepository {
  static const String _storageKey = "workshop_saved_reports";
  final List<InspectionReport> _cachedReports = [];

  List<InspectionReport> get reports => List.unmodifiable(_cachedReports);

  /// جلب كافة التقارير المخزنة
  Future<List<InspectionReport>> getReports() => loadReports();
  Future<List<InspectionReport>> getAllReports() => loadReports();

  /// تحميل التقارير المخزنة
  Future<List<InspectionReport>> loadReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_storageKey) ?? [];
      _cachedReports.clear();
      for (var str in jsonList) {
        final Map<String, dynamic> data = json.decode(str);
        _cachedReports.add(InspectionReport.fromJson(data));
      }
    } catch (_) {}
    return _cachedReports;
  }

  /// حفظ تقرير فحص جديد
  Future<void> saveReport(InspectionReport report) async {
    _cachedReports.insert(0, report);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedReports.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }

  /// حذف تقرير
  Future<void> deleteReport(String id) async {
    _cachedReports.removeWhere((r) => r.id == id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedReports.map((r) => json.encode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (_) {}
  }
}
