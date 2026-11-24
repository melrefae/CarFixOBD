import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/inspection_report.dart';
import '../../data/repositories/report_repository.dart';

/// Backup archive payload structure
class BackupArchive {
  final String schemaVersion;
  final DateTime exportedAt;
  final String workshopName;
  final List<InspectionReport> reports;
  final Map<String, dynamic> settings;
  final String checksum;

  const BackupArchive({
    required this.schemaVersion,
    required this.exportedAt,
    required this.workshopName,
    required this.reports,
    required this.settings,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'workshopName': workshopName,
    'reportsCount': reports.length,
    'reports': reports.map((r) => r.toJson()).toList(),
    'settings': settings,
    'checksum': checksum,
    'checksumSha256': checksum,
  };

  factory BackupArchive.fromJson(Map<String, dynamic> json) {
    final rawReports = (json['reports'] as List? ?? []);
    final List<InspectionReport> parsedReports = [];
    for (var r in rawReports) {
      if (r is Map<String, dynamic>) {
        parsedReports.add(InspectionReport.fromJson(r));
      }
    }

    return BackupArchive(
      schemaVersion: json['schemaVersion'] ?? '1.0.0',
      exportedAt: DateTime.tryParse(json['exportedAt'] ?? '') ?? DateTime.now(),
      workshopName: json['workshopName'] ?? 'Workshop',
      reports: parsedReports,
      settings: (json['settings'] as Map<String, dynamic>?) ?? {},
      checksum: json['checksumSha256'] ?? json['checksum'] ?? '',
    );
  }
}

/// Service managing workshop data backup, JSON archive export/import, and fleet cloud webhook sync
class CloudBackupService {
  static const String _lastBackupKey = "workshop_last_backup_time";
  static const String _webhookUrlKey = "workshop_cloud_webhook_url";
  static const String _webhookApiKey = "workshop_cloud_webhook_key";

  final ReportRepository reportRepo;

  CloudBackupService({ReportRepository? repo}) : reportRepo = repo ?? ReportRepository();

  static String _generateReportsFingerprint(List<dynamic> rawReports) {
    return rawReports.map((r) {
      if (r is InspectionReport) {
        return "${r.id}:${r.vin}:${r.vehicleMakeModel}:${r.timestamp.toIso8601String()}";
      } else if (r is Map<String, dynamic>) {
        final id = r['id'] ?? '';
        final vin = r['vin'] ?? '';
        final makeModel = r['vehicle_make_model'] ?? r['vehicleMakeModel'] ?? '';
        final ts = r['timestamp'] ?? '';
        return "$id:$vin:$makeModel:$ts";
      }
      return '';
    }).join("|");
  }

  /// Static helper to export a JSON bundle from a list of reports
  static String exportBundle(
    List<InspectionReport> reports, {
    String workshopName = "Aspect Auto Care",
    Map<String, dynamic>? settings,
  }) {
    final now = DateTime.now();
    final fp = _generateReportsFingerprint(reports);
    final rawContent = "${now.toIso8601String()}_${reports.length}_${workshopName}_$fp";
    final checksum = _computeSimpleHash(rawContent);

    final archive = BackupArchive(
      schemaVersion: "1.0.0",
      exportedAt: now,
      workshopName: workshopName,
      reports: reports,
      settings: settings ?? {},
      checksum: checksum,
    );

    return const JsonEncoder.withIndent('  ').convert(archive.toJson());
  }

  /// Verify integrity checksum of a backup archive
  static bool verifyChecksum(String bundleJson) {
    try {
      final Map<String, dynamic> data = json.decode(bundleJson);
      final checksum = data['checksumSha256'] ?? data['checksum'];
      if (checksum == null || checksum.toString().isEmpty) return false;
      final exportedAt = data['exportedAt'] ?? '';
      final rawReports = (data['reports'] as List? ?? []);
      final workshopName = data['workshopName'] ?? '';
      final fp = _generateReportsFingerprint(rawReports);
      final expected = _computeSimpleHash("${exportedAt}_${rawReports.length}_${workshopName}_$fp");
      return checksum == expected;
    } catch (_) {
      return false;
    }
  }

  /// Export a complete JSON backup archive bundle
  Future<String> exportFullBackupBundle() async {
    final reports = await reportRepo.getReports();
    final prefs = await SharedPreferences.getInstance();

    final workshopName = prefs.getString('workshop_name') ?? "Aspect Auto Care";
    final settings = {
      'workshop_name': workshopName,
      'workshop_phone': prefs.getString('workshop_phone') ?? "",
      'workshop_address': prefs.getString('workshop_address') ?? "",
      'workshop_engineer': prefs.getString('workshop_engineer') ?? "",
      'inspection_fee': prefs.getString('inspection_fee') ?? "",
      'alarm_max_coolant': prefs.getDouble('alarm_max_coolant') ?? 103.0,
      'alarm_min_voltage': prefs.getDouble('alarm_min_voltage') ?? 11.8,
      'alarm_max_voltage': prefs.getDouble('alarm_max_voltage') ?? 15.2,
      'alarm_audio_enabled': prefs.getBool('alarm_audio_enabled') ?? true,
    };

    final now = DateTime.now();
    final fp = _generateReportsFingerprint(reports);
    final rawContent = "${now.toIso8601String()}_${reports.length}_${workshopName}_$fp";
    final checksum = _computeSimpleHash(rawContent);

    final archive = BackupArchive(
      schemaVersion: "1.0.0",
      exportedAt: now,
      workshopName: workshopName,
      reports: reports,
      settings: settings,
      checksum: checksum,
    );

    await prefs.setString(_lastBackupKey, now.toIso8601String());

    return const JsonEncoder.withIndent('  ').convert(archive.toJson());
  }

  /// Import and merge reports from a JSON backup bundle
  Future<Map<String, int>> importBackupBundle(String jsonString) async {
    final Map<String, dynamic> data = json.decode(jsonString);
    final archive = BackupArchive.fromJson(data);

    final existingReports = await reportRepo.getReports();
    final existingIds = existingReports.map((r) => r.id).toSet();

    int importedCount = 0;
    int skippedCount = 0;

    for (final report in archive.reports) {
      if (!existingIds.contains(report.id)) {
        await reportRepo.saveReport(report);
        existingIds.add(report.id);
        importedCount++;
      } else {
        skippedCount++;
      }
    }

    return {
      'imported': importedCount,
      'skipped': skippedCount,
      'totalInFile': archive.reports.length,
    };
  }

  /// Transmit pending reports to external workshop cloud endpoint or webhook
  Future<Map<String, dynamic>> syncWithWebhook(String endpointUrl, {String? apiKey}) async {
    final uri = Uri.tryParse(endpointUrl);
    if (uri == null || !uri.hasScheme) {
      return {'success': false, 'message': 'Invalid webhook URL provided'};
    }

    final reports = await reportRepo.getReports();
    final prefs = await SharedPreferences.getInstance();
    final workshopName = prefs.getString('workshop_name') ?? "Aspect Auto Care";

    final payload = {
      'timestamp': DateTime.now().toIso8601String(),
      'workshop': workshopName,
      'reportCount': reports.length,
      'reports': reports.map((r) => r.toJson()).toList(),
    };

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);

    try {
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      if (apiKey != null && apiKey.trim().isNotEmpty) {
        request.headers.set('Authorization', 'Bearer ${apiKey.trim()}');
      }

      request.write(json.encode(payload));
      final response = await request.close();

      final respBody = await response.transform(utf8.decoder).join();
      final isOk = response.statusCode >= 200 && response.statusCode < 300;

      if (isOk) {
        await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
        await saveWebhookConfig(endpointUrl, apiKey ?? "");
      }

      return {
        'success': isOk,
        'statusCode': response.statusCode,
        'response': respBody,
        'message': isOk ? 'Synced ${reports.length} reports successfully!' : 'HTTP Error ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    } finally {
      client.close();
    }
  }

  /// Get workshop cloud backup stats and last sync timestamp
  Future<Map<String, dynamic>> getBackupSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await reportRepo.getReports();
    final lastBackupStr = prefs.getString(_lastBackupKey);
    final webhookUrl = prefs.getString(_webhookUrlKey) ?? "";
    final webhookKey = prefs.getString(_webhookApiKey) ?? "";

    DateTime? lastBackup;
    if (lastBackupStr != null && lastBackupStr.isNotEmpty) {
      lastBackup = DateTime.tryParse(lastBackupStr);
    }

    return {
      'reportsCount': reports.length,
      'lastBackup': lastBackup,
      'webhookUrl': webhookUrl,
      'webhookKey': webhookKey,
    };
  }

  /// Save configured webhook credentials
  Future<void> saveWebhookConfig(String url, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webhookUrlKey, url.trim());
    await prefs.setString(_webhookApiKey, key.trim());
  }

  static String _computeSimpleHash(String input) {
    int hash = 5381;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash) + input.codeUnitAt(i);
    }
    return hash.toRadixString(16);
  }
}
