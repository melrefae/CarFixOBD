import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/services/cloud_backup_service.dart';
import '../providers/obd_state.dart';

/// Screen for managing offline JSON archive backups, restores, and fleet cloud webhook synchronization
class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({Key? key}) : super(key: key);

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  final CloudBackupService _backupService = CloudBackupService();
  final TextEditingController _webhookUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _importJsonController = TextEditingController();

  bool _isLoading = true;
  bool _isSyncing = false;
  int _reportsCount = 0;
  DateTime? _lastBackupTime;
  String _syncStatusMessage = "";

  @override
  void initState() {
    super.initState();
    _loadBackupSummary();
  }

  @override
  void dispose() {
    _webhookUrlController.dispose();
    _apiKeyController.dispose();
    _importJsonController.dispose();
    super.dispose();
  }

  Future<void> _loadBackupSummary() async {
    final summary = await _backupService.getBackupSummary();
    if (mounted) {
      setState(() {
        _reportsCount = summary['reportsCount'] ?? 0;
        _lastBackupTime = summary['lastBackup'];
        _webhookUrlController.text = summary['webhookUrl'] ?? "";
        _apiKeyController.text = summary['webhookKey'] ?? "";
        _isLoading = false;
      });
    }
  }

  Future<void> _exportBackup() async {
    setState(() => _isLoading = true);
    try {
      final jsonBundle = await _backupService.exportFullBackupBundle();
      await Share.share(
        jsonBundle,
        subject: "AutoSpect_Workshop_Backup_${DateTime.now().millisecondsSinceEpoch}.json",
      );
      await _loadBackupSummary();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Backup archive generated and shared successfully! 💾"),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to export backup: $e"),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImportDialog(bool isAr) {
    _importJsonController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(
          isAr ? "استرجاع كروت الفحص من نسخة احتياطية" : "Restore Reports from JSON Backup",
          style: const TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr
                    ? "الصق كود الـ JSON للنسخة الاحتياطية هنا. سيتم دمج التقارير الجديدة تلقائياً بدون تكرار:"
                    : "Paste the JSON backup package text below. Non-duplicate inspection reports will be merged seamlessly:",
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _importJsonController,
                maxLines: 8,
                style: const TextStyle(fontSize: 12, color: AppColors.textWhite, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: '{"schemaVersion": "1.0.0", "reports": [...]}',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? "إلغاء" : "Cancel", style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.file_download, size: 16),
            label: Text(isAr ? "بدء الاسترجاع" : "Restore Archive"),
            onPressed: () async {
              final text = _importJsonController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);

              setState(() => _isLoading = true);
              try {
                final result = await _backupService.importBackupBundle(text);
                final state = Provider.of<ObdState>(context, listen: false);
                await state.refreshReports();
                await _loadBackupSummary();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? "تم استرجاع ${result['imported']} تقرير جديد! (تم تخطي ${result['skipped']} مكرر)"
                            : "Restored ${result['imported']} new reports! (Skipped ${result['skipped']} duplicates)",
                      ),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to parse backup package: $e"),
                      backgroundColor: AppColors.dangerRed,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _syncToCloud(bool isAr) async {
    final url = _webhookUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? "يرجى إدخال رابط Webhook أولاً" : "Please enter a valid webhook URL first"),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatusMessage = isAr ? "جاري مزامنة التقارير مع سيرفر الورشة..." : "Syncing reports to workshop cloud server...";
    });

    final res = await _backupService.syncWithWebhook(url, apiKey: _apiKeyController.text.trim());
    await _loadBackupSummary();

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _syncStatusMessage = res['message'] ?? "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? ""),
          backgroundColor: res['success'] == true ? AppColors.successGreen : AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "النسخ الاحتياطي والمزامنة السحابية" : "Cloud Backup & Fleet Sync"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Status Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentBlue.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_done, color: AppColors.accentBlue, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? "أرشيف تقارير الورشة السحابي" : "Workshop Cloud & Fleet Archive",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                                ),
                                Text(
                                  isAr ? "حماية كروت الفحص ومزامنة غرف الصيانة" : "Multi-bay inspection sync & disaster recovery",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatPill(
                            icon: Icons.receipt_long,
                            label: isAr ? "التقارير المخزنة" : "Saved Reports",
                            value: "$_reportsCount",
                          ),
                          const SizedBox(width: 12),
                          _buildStatPill(
                            icon: Icons.access_time,
                            label: isAr ? "آخر نسخ" : "Last Backup",
                            value: _lastBackupTime != null
                                ? "${_lastBackupTime!.hour.toString().padLeft(2, '0')}:${_lastBackupTime!.minute.toString().padLeft(2, '0')}"
                                : (isAr ? "لا يوجد" : "Never"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // JSON Backup & Restore Actions
                Text(
                  isAr ? "إدارة النسخ الاحتياطية المحلية" : "Offline Package Operations",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.share, size: 18),
                        label: Text(
                          isAr ? "تصدير نسخة JSON" : "Export Backup Bundle",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: _exportBackup,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentCyan,
                          side: const BorderSide(color: AppColors.accentCyan),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.file_download, size: 18),
                        label: Text(
                          isAr ? "استرجاع نسخة" : "Restore Archive",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () => _showImportDialog(isAr),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Multi-Bay Workshop Cloud Webhook Sync
                Text(
                  isAr ? "مزامنة السيرفر السحابي والـ Webhook" : "Multi-Bay Cloud Webhook Sync",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? "رابط الـ Webhook الخاص بالورشة (POST endpoint):" : "Workshop Webhook URL (POST endpoint):",
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _webhookUrlController,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "https://garage.example.com/api/v1/sync",
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          prefixIcon: const Icon(Icons.link, color: AppColors.primaryYellow, size: 18),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        isAr ? "مفتاح المصادقة API Bearer Token (اختياري):" : "API Bearer Token (Optional):",
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Bearer token or secret key",
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          prefixIcon: const Icon(Icons.vpn_key, color: AppColors.primaryYellow, size: 18),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_syncStatusMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.accentCyan),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_syncStatusMessage, style: const TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isSyncing
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                            _isSyncing
                                ? (isAr ? "جاري المزامنة..." : "Syncing to Cloud...")
                                : (isAr ? "مزامنة جميع التقارير الآن" : "Sync All Reports Now"),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _isSyncing ? null : () => _syncToCloud(isAr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatPill({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryYellow),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
