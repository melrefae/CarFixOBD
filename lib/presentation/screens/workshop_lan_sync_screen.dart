import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
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

    // Link real-time status callbacks
    server.getLiveStatusCallback = () => {
      'isConnected': state.isConnected,
      'batteryVoltage': state.batteryVoltage,
      'vehicleModel': state.selectedVehicle?.model ?? "Unspecified",
      'dtcs': state.storedDtcs.map((d) => d.toJson()).toList(),
    };

    server.onReportReceived = (report) {
      state.refreshReports();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New inspection report received for: ${report.customerName}"),
          backgroundColor: AppColors.successGreen,
        ),
      );
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.workshopLanSync),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          tabs: const [
            Tab(icon: Icon(Icons.router), text: "Local Server (Master)"),
            Tab(icon: Icon(Icons.sync_alt), text: "Sync Reports (Client)"),
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
                  server.isRunning ? "Local LAN Server Active" : "Local LAN Server Stopped",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: server.isRunning ? AppColors.successGreen : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  server.isRunning
                      ? "Any desktop, laptop, or smartphone on workshop Wi-Fi can open the URL below"
                      : "Tap the button below to start broadcasting live diagnostics and job cards over local Wi-Fi",
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
                          tooltip: "Copy URL",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: server.serverUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Server URL copied to clipboard!"),
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
                      server.isRunning ? "Stop LAN Server" : "Start Workshop Server (Port 8080)",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      if (server.isRunning) {
                        await server.stopServer();
                      } else {
                        final ok = await server.startServer();
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unable to start server. Ensure device is connected to Wi-Fi / Hotspot."),
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
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.electricBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "How Does Offline LAN Hub Work?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "1. Ensure the diagnostic tablet and reception/accounting PC are connected to the same workshop Wi-Fi router or phone Hotspot.\n"
                  "2. No external internet or cellular data is required; data communicates entirely offline across local subnet.\n"
                  "3. Open Google Chrome on the reception PC and enter the URL shown above.\n"
                  "4. A real-time dashboard appears displaying live telemetry, trouble codes, and printable PDF inspection job cards for standard A4 printers.",
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
                const Text(
                  "Sync Inspection Job Cards with Master PC",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 8),
                const Text(
                  "If using this tablet under the vehicle or in the service bay, push saved inspection job cards directly to the main reception PC with one tap.",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _masterIpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    labelText: "Master PC IP Address",
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
                      _isSyncing ? "Syncing..." : "Sync All Reports (${state.savedReports.length})",
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
        const SnackBar(content: Text("Please enter a valid IP address for the Master PC")),
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
      _syncResult = "Sync result: Sent $successCount report(s) successfully" +
          (failCount > 0 ? ", $failCount failed." : " without errors! ✅");
    });
  }
}
