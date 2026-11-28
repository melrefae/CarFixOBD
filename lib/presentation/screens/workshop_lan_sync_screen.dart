import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../data/datasources/workshop_lan_server.dart';
import '../providers/obd_state.dart';

/// Workshop offline LAN server hub & inter-device sync screen
class WorkshopLanSyncScreen extends StatefulWidget {
  const WorkshopLanSyncScreen({Key? key}) : super(key: key);

  @override
  State<WorkshopLanSyncScreen> createState() => _WorkshopLanSyncScreenState();
}

class _WorkshopLanSyncScreenState extends State<WorkshopLanSyncScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _masterIpController = TextEditingController(text: "192.168.1.");
  bool _isSyncing = false;
  String _syncResult = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _masterIpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final server = WorkshopLanServer();
    final state = Provider.of<ObdState>(context);
    final l10n = AppLocalizations.of(context);

    // Link real-time status callbacks
    server.getLiveStatusCallback = () => {
      'isConnected': state.isConnected,
      'batteryVoltage': state.batteryVoltage,
      'vehicleModel': state.selectedVehicle?.model ?? l10n.lanUnspecified,
      'dtcs': state.storedDtcs.map((d) => d.toJson()).toList(),
    };

    server.onReportReceived = (report) {
      state.refreshReports();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.lanNewReport(report.customerName)),
          backgroundColor: AppColors.successGreen,
        ),
      );
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lanTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          tabs: [
            Tab(icon: const Icon(Icons.router), text: l10n.lanTabServer),
            Tab(icon: const Icon(Icons.sync_alt), text: l10n.lanTabSync),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Master Server Tab
          _buildServerTab(server, state),

          // Client Sync Tab
          _buildClientSyncTab(state),
        ],
      ),
    );
  }

  Widget _buildServerTab(WorkshopLanServer server, ObdState state) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Server status card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: server.isRunning ? AppColors.successGreen : AppColors.cardBorder,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  server.isRunning ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                  size: 54,
                  color: server.isRunning ? AppColors.successGreen : AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  server.isRunning ? l10n.lanServerActive : l10n.lanServerStopped,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: server.isRunning ? AppColors.successGreen : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  server.isRunning
                      ? l10n.lanActiveDesc
                      : l10n.lanStoppedDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                if (server.isRunning) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: AppColors.primaryYellow, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SelectableText(
                            server.serverUrl,
                            style: const TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white, size: 20),
                          tooltip: l10n.lanCopyUrl,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: server.serverUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.lanCopied),
                                backgroundColor: AppColors.primaryAmber,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: server.isRunning ? AppColors.dangerRed : AppColors.primaryYellow,
                      foregroundColor: server.isRunning ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(server.isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      server.isRunning ? l10n.lanStop : l10n.lanStart,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (server.isRunning) {
                        await server.stopServer();
                      } else {
                        final ok = await server.startServer();
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.lanStartFail),
                              backgroundColor: AppColors.dangerRed,
                            ),
                          );
                        }
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // How it works card
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
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.electricBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.lanHowTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.lanHowSteps,
                  style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientSyncTab(ObdState state) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lanSyncTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.lanSyncDesc,
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _masterIpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: l10n.lanMasterIp,
                    hintText: "e.g. 192.168.1.50",
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.computer, color: AppColors.electricBlue),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      _isSyncing ? l10n.lanSyncing : l10n.lanSyncAll(state.savedReports.length),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isSyncing ? null : () => _performSync(state),
                  ),
                ),
              ],
            ),
          ),

          if (_syncResult.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
              ),
              child: Text(
                _syncResult,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _performSync(ObdState state) async {
    final ip = _masterIpController.text.trim();
    if (ip.isEmpty || ip.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).lanInvalidIp)),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncResult = "";
    });

    int successCount = 0;
    int failCount = 0;

    for (var report in state.savedReports) {
      final ok = await WorkshopLanServer.pushReportToMaster(masterIp: ip, report: report);
      if (ok) {
        successCount++;
      } else {
        failCount++;
      }
    }

    setState(() {
      _isSyncing = false;
      _syncResult = failCount > 0
              ? AppLocalizations.of(context).lanSyncResultFail(successCount, failCount)
              : AppLocalizations.of(context).lanSyncResultOk(successCount);
    });
  }
}
