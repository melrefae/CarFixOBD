import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dtc_model.dart';
import '../models/dtc_repair_guide.dart';
import '../datasources/dtc_knowledge_base.dart';

/// Repository for searching and resolving automotive Diagnostic Trouble Codes (DTCs)
class DtcRepository {
  Map<String, dynamic> _database = {};
  bool _isLoaded = false;
  Map<String, dynamic> _openGeneric = {};
  Map<String, dynamic> _openBrand = {};

  /// Open definitions (see NOTICE.md). Loaded lazily; missing asset is not fatal.
  Future<void> _loadOpen() async {
    if (_openGeneric.isNotEmpty) return;
    try {
      final o = json.decode(await rootBundle.loadString('assets/databases/dtc_definitions_open.json')) as Map<String, dynamic>;
      _openGeneric = (o['generic'] as Map<String, dynamic>);
      _openBrand = (o['brand'] as Map<String, dynamic>);
    } catch (_) {}
  }

  /// Load localized database from asset JSON
  Future<void> loadDatabase() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/databases/dtc_codes_ar.json');
      _database = json.decode(jsonString);
      _isLoaded = true;
    } catch (_) {
      _database = {};
    }
  }

  /// Retrieve full DTC details from local JSON or the 500+ offline knowledge base
  Future<DtcModel> getDtcDetails(String code, {String dtcType = "Stored"}) async {
    await loadDatabase();
    final cleanCode = code.trim().toUpperCase();

    // 1. Check offline 500+ comprehensive repair knowledge base first
    final guide = DtcKnowledgeBase.lookup(cleanCode);
    if (guide != null) {
      return _modelFromGuide(guide, dtcType: dtcType);
    }

    // 2. Check JSON database
    if (_database.containsKey(cleanCode)) {
      final data = _database[cleanCode] as Map<String, dynamic>;
      return DtcModel.fromJson(cleanCode, data, dtcType: dtcType);
    }

    // 3. Open definitions (English text only, with attribution in NOTICE.md)
    await _loadOpen();
    final brandDefs = (_openBrand[cleanCode] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? const <String, String>{};
    final generic = _openGeneric[cleanCode]?.toString() ?? (brandDefs.isNotEmpty ? brandDefs.values.first : null);
    if (generic != null) {
      return DtcModel.fromOpenDefinition(cleanCode, generic, brandDefinitions: _openGeneric.containsKey(cleanCode) ? brandDefs : (brandDefs.length > 1 ? brandDefs : const {}), dtcType: dtcType);
    }

    // 4. Fallback generic code with category identification
    return DtcModel.unknown(cleanCode, dtcType: dtcType);
  }

  /// Convert a list of raw DTC code strings into fully resolved DtcModel objects
  Future<List<DtcModel>> resolveDtcs(List<String> codes, {String dtcType = "Stored"}) async {
    final List<DtcModel> result = [];
    for (var code in codes) {
      final model = await getDtcDetails(code, dtcType: dtcType);
      result.add(model);
    }
    return result;
  }

  /// Search codes by keyword across English and Arabic terms
  Future<List<DtcModel>> searchByKeyword(String query, {bool isAr = false}) async {
    await loadDatabase();
    final q = query.trim().toLowerCase();
    final Map<String, DtcModel> resultMap = {};

    // 1. Search in DtcKnowledgeBase (500+ codes)
    final kbGuides = DtcKnowledgeBase.search(q, isAr: isAr);
    for (var g in kbGuides) {
      resultMap[g.code] = _modelFromGuide(g);
    }

    // 2. Search in local JSON asset
    _database.forEach((code, value) {
      final title = (value['title_ar'] ?? '').toString().toLowerCase();
      final desc = (value['description_ar'] ?? '').toString().toLowerCase();
      final check = (value['workshop_check_ar'] ?? '').toString().toLowerCase();

      if (code.toLowerCase().contains(q) || title.contains(q) || desc.contains(q) || check.contains(q)) {
        if (!resultMap.containsKey(code)) {
          resultMap[code] = DtcModel.fromJson(code, value as Map<String, dynamic>);
        }
      }
    });

    return resultMap.values.toList();
  }

  /// Retrieve all DTCs in the knowledge base
  Future<List<DtcModel>> getAllDtcs() async {
    await loadDatabase();
    final Map<String, DtcModel> resultMap = {};

    for (var g in DtcKnowledgeBase.getAllGuides()) {
      resultMap[g.code] = _modelFromGuide(g);
    }

    _database.forEach((code, value) {
      if (!resultMap.containsKey(code)) {
        resultMap[code] = DtcModel.fromJson(code, value as Map<String, dynamic>);
      }
    });

    return resultMap.values.toList();
  }

  static DtcModel _modelFromGuide(DtcRepairGuide guide, {String dtcType = "Stored"}) {
    return DtcModel(
      code: guide.code,
      titleAr: guide.titleAr,
      titleEn: guide.titleEn,
      category: guide.category,
      severity: guide.severity,
      descriptionAr: guide.descriptionAr,
      descriptionEn: guide.descriptionEn,
      symptomsAr: guide.symptomsAr,
      symptomsEn: guide.symptomsEn,
      causesAr: guide.causesAr,
      causesEn: guide.causesEn,
      workshopCheckAr: guide.multimeterChecksAr,
      workshopCheckEn: guide.multimeterChecksEn,
      dtcType: dtcType,
    );
  }
}
