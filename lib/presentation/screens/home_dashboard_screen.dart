import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/localization/status_localizer.dart';
import '../../data/datasources/elm327_driver.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';
import 'quick_scan_screen.dart';
import 'dtc_scanner_screen.dart';
import 'live_data_screen.dart';
import 'live_graph_screen.dart';
import 'diagnostic_assistant_screen.dart';
import 'reports_screen.dart';
import 'terminal_screen.dart';
import 'vehicle_profiles_screen.dart';
import 'freeze_frame_screen.dart';
import 'readiness_monitors_screen.dart';
import 'ecu_info_screen.dart';
import 'workshop_lan_sync_screen.dart';
import 'dtc_encyclopedia_screen.dart';
import 'adapter_benchmark_screen.dart';
import 'workshop_settings_screen.dart';
import 'o2_cat_analyzer_screen.dart';
import 'flight_recorder_screen.dart';
import 'fuel_cost_calculator_screen.dart';
import 'hud_display_screen.dart';
import 'ai_copilot_screen.dart';
import 'full_vehicle_test_screen.dart';
import 'interactive_can_topology_screen.dart';
import 'used_car_audit_screen.dart';
import 'wiring_schematics_screen.dart';
import 'voice_inspection_assistant_screen.dart';
import 'ar_engine_bay_hud_screen.dart';
import 'customer_dispatch_hub_screen.dart';
import 'offline_vault_protocol_sniffer_screen.dart';
import 'mode06_monitor_screen.dart';
import 'lab_hub_screen.dart';
import 'traffic_log_screen.dart';
import 'lab_pin.dart';
import 'used_car_wizard_screen.dart';
import 'inspection_history_screen.dart';
import 'job_cards_screen.dart';
import 'multi_ecu_topology_screen.dart';

/// Main Workshop Dashboard Screen for Automotive Diagnostic Center
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 26,
                height: 26,
                errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // 1-Click Dual Language Toggle (English <-> Egyptian Arabic)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
            ),
            onPressed: () {
              state.toggleLanguage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryYellow, width: 1.2),
              ),
              child: Text(
                isAr ? "English" : "Arabic",
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(state.isSunlightMode ? Icons.dark_mode : Icons.wb_sunny_outlined),
            tooltip: state.isSunlightMode ? l10n.darkWorkshopMode : l10n.brightDaylightMode,
            onPressed: () {
              state.toggleSunlightMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.centerAlarmSettings,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkshopSettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Banner
            _buildConnectionBanner(context, state),

            if (state.hasSafetyAlarm) ...[
              const SizedBox(height: 12),
              _buildSafetyAlertBanner(context, state),
            ],

            const SizedBox(height: 16),

            // 1-Click Full Vehicle Test Hero Card
            _buildFullTestHeroCard(context, state),

            const SizedBox(height: 12),

            // 30-Second Quick Scan Hero Action Button
            _buildQuickScanButton(context, state),

            const SizedBox(height: 20),

            _buildLegend(context),
            const SizedBox(height: 8),
            ..._buildSections(context, state, isTablet),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 13, color: AppColors.warningOrange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              AppLocalizations.of(context).shieldNotTested,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _go(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _openNetworkMap(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final pick = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_tree),
              title: Text(l10n.ecuScanTree),
              subtitle: Text(l10n.findModulesGateway),
              onTap: () => Navigator.pop(ctx, 0),
            ),
            ListTile(
              leading: const Icon(Icons.hub),
              title: Text(l10n.interactiveBusMap),
              subtitle: Text(l10n.canLinGraph),
              onTap: () => Navigator.pop(ctx, 1),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || pick == null) return;
    _go(context, pick == 0 ? const MultiEcuTopologyScreen() : const InteractiveCanTopologyScreen());
  }

  List<Widget> _buildSections(BuildContext context, ObdState state, bool isTablet) {
    final cols = isTablet ? 4 : 3;
    final l10n = AppLocalizations.of(context);
    // t(title, icon, color, onTap, {unverified, badge})
    Widget t(String title, IconData icon, Color color, VoidCallback onTap, {bool unv = true, String? badge}) =>
        _buildTile(title, icon, color, onTap, unverified: unv, badge: badge);

    final dtcCount = state.storedDtcs.length;
    final sections = <List<dynamic>>[
      [
        l10n.daily, Icons.bolt, AppColors.primaryYellow,
        <Widget>[
          _buildTile(l10n.readClearDtc, Icons.error_outline,
              dtcCount > 0 ? AppColors.dangerRed : AppColors.primaryAmber, () => _go(context, const DtcScannerScreen()),
              badge: dtcCount > 0 ? "$dtcCount" : null),
          t(l10n.liveData, Icons.speed, AppColors.accentCyan, () => _go(context, const LiveDataScreen())),
          t(l10n.liveGraphs, Icons.show_chart, AppColors.successGreen, () => _go(context, const LiveGraphScreen())),
          t(l10n.freezeFrame, Icons.ac_unit, AppColors.electricBlue, () => _go(context, const FreezeFrameScreen())),
          t(l10n.readiness, Icons.fact_check, AppColors.primaryAmber, () => _go(context, const ReadinessMonitorsScreen())),
          t(l10n.ecuInfo, Icons.memory, AppColors.accentCyan, () => _go(context, const EcuInfoScreen())),
          t(l10n.mode06Monitors, Icons.rule, AppColors.primaryAmber, () => _go(context, const Mode06MonitorScreen())),
          t(l10n.vehicleProfile, Icons.directions_car_filled, AppColors.primaryAmber, () => _go(context, const VehicleProfilesScreen()), unv: false),
        ],
      ],
      [
        l10n.inspectionCustomers, Icons.assignment, AppColors.accentCyan,
        <Widget>[
          t(l10n.usedCarAudit, Icons.fact_check_outlined, AppColors.warningOrange, () => _go(context, const UsedCarWizardScreen())),
          t(l10n.carHistory, Icons.history, AppColors.accentCyan, () => _go(context, const InspectionHistoryScreen()), unv: false),
          t(l10n.jobCardsQuotes, Icons.request_quote, AppColors.successGreen, () => _go(context, const JobCardsScreen()), unv: false),
          t(l10n.savedReportsCount(state.savedReports.length), Icons.folder_open, AppColors.electricBlue, () => _go(context, const ReportsScreen()), unv: false),
          t(l10n.whatsappDispatch, Icons.chat, AppColors.successGreen, () => _go(context, const CustomerDispatchHubScreen()), unv: false),
          t(l10n.lanHub, Icons.router, AppColors.electricBlue, () => _go(context, const WorkshopLanSyncScreen()), unv: false),
        ],
      ],
      [
        l10n.analysisTools, Icons.analytics, AppColors.electricBlue,
        <Widget>[
          _buildTile(l10n.networkMap, Icons.account_tree, AppColors.successGreen, () => _openNetworkMap(context)),
          t(l10n.o2Catalyst, Icons.air, AppColors.accentCyan, () => _go(context, const O2CatAnalyzerScreen())),
          t(l10n.fuelTrimBattery, Icons.battery_charging_full, AppColors.primaryAmber, () => _go(context, const DiagnosticAssistantScreen())),
          t(l10n.dtcEncyclopedia, Icons.menu_book, AppColors.primaryAmber, () => _go(context, const DtcEncyclopediaScreen()), unv: false),
          t(l10n.wiring, Icons.cable, AppColors.successGreen, () => _go(context, const WiringSchematicsScreen()), unv: false),
          t(l10n.canSniffer, Icons.sensors, AppColors.accentCyan, () => _go(context, const OfflineVaultProtocolSnifferScreen())),
          t(l10n.adapterTest, Icons.usb, AppColors.electricBlue, () => _go(context, const AdapterBenchmarkScreen())),
          t(l10n.terminal, Icons.terminal, AppColors.textMuted, () => _go(context, const TerminalScreen())),
          t(l10n.rawLog, Icons.receipt_long, AppColors.warningOrange, () => _go(context, const TrafficLogScreen()), unv: false),
        ],
      ],
    ];

    final out = <Widget>[];
    for (final sec in sections) {
      out.add(const SizedBox(height: 12));
      out.add(_buildSectionHeader(sec[0] as String, sec[1] as IconData, sec[2] as Color));
      out.add(const SizedBox(height: 6));
      out.add(GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
        children: sec[3] as List<Widget>,
      ));
    }

    // Lab (PIN) and collapsed "More tools"
    out.add(const SizedBox(height: 12));
    out.add(Card(
      color: AppColors.warningOrange.withOpacity(0.12),
      child: ListTile(
        leading: const Icon(Icons.science, color: AppColors.warningOrange),
        title: Text(l10n.labExperimentalPin),
        subtitle: Text(l10n.labFeaturesUnverified),
        trailing: const Icon(Icons.lock_outline),
        onTap: () async {
          if (await LabPin.check(context, state.isArabic) && context.mounted) _go(context, const LabHubScreen());
        },
      ),
    ));
    out.add(Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: const Icon(Icons.more_horiz, color: AppColors.textMuted),
        title: Text(l10n.moreTools, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
        children: [
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
            children: [
              t(l10n.classicAudit9Tabs, Icons.fact_check_outlined, AppColors.textMuted, () => _go(context, const UsedCarAuditScreen())),
              t(l10n.voiceAssistant, Icons.mic, AppColors.primaryYellow, () => _go(context, const VoiceInspectionAssistantScreen())),
              t(l10n.arHud, Icons.view_in_ar, AppColors.accentCyan, () => _go(context, const ArEngineBayHudScreen())),
              t(l10n.aiCopilot, Icons.auto_awesome, AppColors.primaryYellow, () => _go(context, const AiCopilotScreen()), unv: false),
              t(l10n.flightRecorder, Icons.fiber_manual_record, state.isFlightRecording ? AppColors.dangerRed : AppColors.primaryYellow, () => _go(context, const FlightRecorderScreen()), badge: state.isFlightRecording ? "REC" : null),
              t(l10n.fuelCost, Icons.local_gas_station, AppColors.successGreen, () => _go(context, const FuelCostCalculatorScreen())),
              t(l10n.hudDisplay, Icons.nights_stay, AppColors.accentCyan, () => _go(context, const HudDisplayScreen())),
            ],
          ),
        ],
      ),
    ));
    return out;
  }

  Widget _buildTile(String title, IconData icon, Color color, VoidCallback onTap, {bool unverified = true, String? badge}) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textWhite),
                    ),
                  ),
                ],
              ),
            ),
            if (unverified)
              const Positioned(top: 6, right: 6, child: Icon(Icons.shield_outlined, size: 13, color: AppColors.warningOrange)),
            if (badge != null)
              Positioned(
                top: 4,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(8)),
                  child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyAlertBanner(BuildContext context, ObdState state) {
    if (state.activeAlarms.isEmpty) return const SizedBox.shrink();
    final firstAlarm = state.activeAlarms.first;
    final isCritical = state.hasCriticalAlarm;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCritical ? AppColors.dangerRed : AppColors.warningOrange).withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? AppColors.dangerRed : AppColors.warningOrange,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.crisis_alert : Icons.warning_amber_rounded,
            color: isCritical ? AppColors.dangerRed : AppColors.warningOrange,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstAlarm.titleEn,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCritical ? AppColors.dangerRed : AppColors.warningOrange,
                    fontSize: 14,
                  ),
                ),
                Text(
                  firstAlarm.messageEn,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => state.clearSafetyAlarms(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(BuildContext context, ObdState state) {
    final l10n = AppLocalizations.of(context);
    Color statusColor = AppColors.statusDisconnected;
    String statusTitle = l10n.disconnected;

    if (state.connectionState == ElmDriverState.ready) {
      statusColor = AppColors.statusConnected;
      statusTitle = "${l10n.connectedToEcu} (${state.activeProtocol})";
    } else if (state.connectionState == ElmDriverState.adapterConnected) {
      statusColor = AppColors.warningOrange;
      statusTitle = l10n.adapterReadyTurnKey;
    } else if (state.isConnecting) {
      statusColor = AppColors.statusConnecting;
      statusTitle = l10n.connectingObdAdapter;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              state.isConnected ? Icons.check_circle : Icons.bluetooth_searching,
              color: statusColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        statusTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (state.isVehicleAutoDetected && state.detectedVehicleInfo != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.successGreen.withOpacity(0.5)),
                        ),
                        child: const Text(
                          "AUTO-DETECTED",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  state.isConnected
                      ? (state.isVehicleAutoDetected && state.detectedVehicleInfo != null
                          ? l10n.batterySummary(state.batteryVoltage.toStringAsFixed(1), state.detectedVehicleInfo!.displaySummary)
                          : l10n.batteryVehicle(state.batteryVoltage.toStringAsFixed(1), state.selectedVehicle?.model ?? l10n.genericVehicle))
                      : localizedObdStatus(context, state),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isConnected ? AppColors.cardSurfaceHighlight : AppColors.primaryYellow,
              foregroundColor: state.isConnected ? AppColors.textWhite : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen()));
            },
            child: Text(state.isConnected ? l10n.switchAdapter : l10n.connect, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTestHeroCard(BuildContext context, ObdState state) {
    final l10n = AppLocalizations.of(context);
    final isAr = state.isArabic;
    final vehicle = state.selectedVehicle;
    final vehicleTitle = vehicle != null
        ? (state.isConnected
            ? vehicle.getDisplayName(isAr)
            : l10n.selectedProfileNotConnected(vehicle.getDisplayName(isAr)))
        : l10n.tapToSelectVehicle;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentCyan.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FullVehicleTestScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.speed, color: AppColors.accentCyan, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.fullVehicleTest,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "1-CLICK",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicleTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.fullScanSubtitle,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickScanButton(BuildContext context, ObdState state) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFFF9100)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!state.isConnected) {
              _showConnectPrompt(context);
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickScanScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.black, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.quickScan30s,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        l10n.quickScanSubtitle,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor.withOpacity(0.6), width: 1),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showConnectPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).connectAdapterFirst),
        backgroundColor: AppColors.warningOrange,
        action: SnackBarAction(
          label: AppLocalizations.of(context).connect,
          textColor: Colors.black,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen()));
          },
        ),
      ),
    );
  }
}
