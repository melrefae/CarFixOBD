import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workshop_records.dart';
import 'workshop_profile.dart';
import 'workshop_store.dart';

class BackupResult {
  final int inspections;
  final int jobs;
  final int skipped;
  const BackupResult(this.inspections, this.jobs, this.skipped);
}

/// Export / import of the workshop's own saved data (inspections with their PDFs, job cards,
/// workshop identity and logo) as one JSON file. Import merges: records whose id already
/// exists on the phone are kept as they are and counted as skipped.
class WorkshopBackup {
  static const format = 'autospect-backup';
  static const version = 1;

  static Future<Map<String, dynamic>> buildJson() async {
    final insp = await WorkshopStore.inspections();
    final jobs = await WorkshopStore.jobs();
    final prof = await WorkshopProfile.load();
    final p = await SharedPreferences.getInstance();
    final recs = <Map<String, dynamic>>[];
    for (final r in insp) {
      final m = r.toJson();
      final path = r.pdfPath;
      if (path != null && File(path).existsSync()) {
        m['pdfBase64'] = base64Encode(await File(path).readAsBytes());
      }
      m.remove('pdfPath');
      recs.add(m);
    }
    return {
      'format': format,
      'version': version,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': p.getString('workshop_name') ?? '',
        'phone': p.getString('workshop_phone') ?? '',
        'address': p.getString('workshop_address') ?? '',
        'engineer': p.getString('workshop_engineer') ?? '',
        if (prof.logo != null) 'logoBase64': base64Encode(prof.logo!),
      },
      'inspections': recs,
      'jobs': jobs.map((j) => j.toJson()).toList(),
    };
  }

  /// Writes the backup file to the temp directory and returns its path (share it from there).
  static Future<String> exportToFile() async {
    final data = await buildJson();
    final dir = await getTemporaryDirectory();
    final d = DateTime.now().toIso8601String().substring(0, 10);
    final f = File('${dir.path}/AutoSpect_backup_$d.json');
    await f.writeAsString(jsonEncode(data), flush: true);
    return f.path;
  }

  /// Throws FormatException if the file is not an AutoSpect backup.
  static Future<BackupResult> importJson(String text, {bool restoreProfile = true}) async {
    final dynamic raw;
    try {
      raw = jsonDecode(text);
    } catch (_) {
      throw const FormatException('Not a valid backup file');
    }
    if (raw is! Map || raw['format'] != format) throw const FormatException('Not an AutoSpect backup file');
    if ((raw['version'] ?? 0) is! int || raw['version'] > version) throw const FormatException('Backup is from a newer app version');
    final haveI = (await WorkshopStore.inspections()).map((e) => e.id).toSet();
    final haveJ = (await WorkshopStore.jobs()).map((e) => e.id).toSet();
    int ni = 0, nj = 0, skipped = 0;
    for (final e in (raw['inspections'] ?? const []) as List) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = m['id'] as String;
      if (haveI.contains(id)) { skipped++; continue; }
      String? pdfPath;
      final b64 = m.remove('pdfBase64') as String?;
      if (b64 != null) pdfPath = await WorkshopStore.savePdf(id, base64Decode(b64));
      m['pdfPath'] = pdfPath;
      await WorkshopStore.saveInspection(InspectionRecord.fromJson(m));
      ni++;
    }
    for (final e in (raw['jobs'] ?? const []) as List) {
      final j = JobCard.fromJson(Map<String, dynamic>.from(e as Map));
      if (haveJ.contains(j.id)) { skipped++; continue; }
      await WorkshopStore.saveJob(j);
      nj++;
    }
    final pr = raw['profile'];
    if (restoreProfile && pr is Map) {
      final p = await SharedPreferences.getInstance();
      // Only fill identity fields that are empty on this phone, never overwrite what is set.
      Future<void> fill(String key, String? v) async {
        if ((p.getString(key) ?? '').trim().isEmpty && v != null && v.isNotEmpty) await p.setString(key, v);
      }
      await fill('workshop_name', pr['name'] as String?);
      await fill('workshop_phone', pr['phone'] as String?);
      await fill('workshop_address', pr['address'] as String?);
      await fill('workshop_engineer', pr['engineer'] as String?);
      final lb = pr['logoBase64'] as String?;
      if (lb != null && (await WorkshopProfile.logoPath()) == null) {
        await WorkshopProfile.setLogoBytes(base64Decode(lb), 'png');
      }
    }
    return BackupResult(ni, nj, skipped);
  }
}
