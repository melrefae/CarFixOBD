import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../core/localization/app_strings_ar.dart';
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
import 'multi_ecu_topology_screen.dart';
import 'o2_cat_analyzer_screen.dart';
import 'flight_recorder_screen.dart';
import 'performance_dyno_screen.dart';
import 'fuel_cost_calculator_screen.dart';
import 'hud_display_screen.dart';
import 'ai_copilot_screen.dart';
import 'full_vehicle_test_screen.dart';
import 'interactive_can_topology_screen.dart';
import 'used_car_audit_screen.dart';
import 'lab_scope_waveform_screen.dart';
import 'wiring_schematics_screen.dart';
import 'voice_inspection_assistant_screen.dart';
import 'ar_engine_bay_hud_screen.dart';
import 'customer_dispatch_hub_screen.dart';
import 'offline_vault_protocol_sniffer_screen.dart';
import 'mode06_monitor_screen.dart';
import 'lab_hub_screen.dart';

/// Main Workshop Dashboard Screen for Automotive Diagnostic Center
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final gridCount = isTablet ? 3 : 2;

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
                isAr ? AppStringsAr.appName : AppStrings.appName,
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
            icon: const Icon(Icons.mic, color: AppColors.primaryYellow),
            tooltip: isAr ? "المساعد الصوتي الناطق" : "Hands-Free Voice Assistant",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceInspectionAssistantScreen()));
            },
          ),
          IconButton(
            icon: Icon(state.isSunlightMode ? Icons.dark_mode : Icons.wb_sunny_outlined),
            tooltip: state.isSunlightMode ? "Dark Workshop Mode" : "Bright Daylight Sunlight Mode",
            onPressed: () {
              state.toggleSunlightMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            tooltip: "Workshop LAN Hub Server",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkshopLanSyncScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.directions_car),
            tooltip: isAr ? AppStringsAr.vehicleProfiles : AppStrings.vehicleProfiles,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleProfilesScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.terminal),
            tooltip: AppStrings.terminal,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppStrings.settings,
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

            // SECTION 1: Diagzone Special Resets, Coding & SGW Core
            _buildSectionHeader(
              isAr ? "وظائف دياجزون، التكويد وحماية البوابة" : "Diagzone Resets, ECU Coding & SGW",
              Icons.construction,
              AppColors.primaryYellow,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: isAr ? "المختبر (تجريبي)" : "Lab (experimental)",
                  subtitle: isAr ? "ميزات قيد التطوير وغير مثبتة على سيارة حقيقية" : "Features under development, not verified on a real car",
                  icon: Icons.science,
                  accentColor: AppColors.warningOrange,
                  badgeText: "LAB",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LabHubScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.multiEcuTopology : AppStrings.multiEcuTopology,
                  subtitle: isAr ? AppStringsAr.multiEcuSubtitle : "CAN Gateway Bus Tree (ECM, TCM, ABS, BCM)",
                  icon: Icons.account_tree,
                  accentColor: AppColors.successGreen,
                  badgeText: "CAN Tree",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MultiEcuTopologyScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.readDtcs : AppStrings.readDtcs,
                  subtitle: state.storedDtcs.isEmpty
                      ? (isAr ? "فحص كمبيوتر المحرك" : "Check Engine Diagnostics")
                      : (isAr ? "${state.storedDtcs.length} أعطال نشطة" : "${state.storedDtcs.length} Active DTCs"),
                  icon: Icons.error_outline,
                  accentColor: state.storedDtcs.isNotEmpty ? AppColors.dangerRed : AppColors.primaryAmber,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DtcScannerScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 1.5: Diagzone Pro Heavyweight Diagnostics (CAN Graph, IMMO, EV Lab)
            _buildSectionHeader(
              isAr ? "وظائف دياجزون الاحترافية (CAN، المفاتيح، والهايبرد)" : "Diagzone Pro Heavyweight Suite",
              Icons.stars,
              AppColors.primaryYellow,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: isAr ? "خريطة شبكات CAN/LIN" : "CAN Topology Graph",
                  subtitle: isAr ? "رسم بياني تفاعلي لشجرة الشبكات وسرعة الاستجابة" : "Interactive Multi-Trunk Bus Map & Node Inspection",
                  icon: Icons.hub,
                  accentColor: AppColors.primaryYellow,
                  badgeText: "CAN 500k",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InteractiveCanTopologyScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 1.6: Workshop Power Modules & Calibration Suite
            _buildSectionHeader(
              isAr ? "أدوات الورشة الاحترافية والتدقيق الشامل" : "Workshop Power Tools & Inspection Suite",
              Icons.precision_manufacturing,
              AppColors.electricBlue,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.usedCarAudit : AppStrings.usedCarAudit,
                  subtitle: isAr ? AppStringsAr.usedCarAuditSubtitle : AppStrings.usedCarAuditSubtitle,
                  icon: Icons.fact_check,
                  accentColor: AppColors.primaryYellow,
                  badgeText: "AUDIT",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UsedCarAuditScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.wiringSchematics : AppStrings.wiringSchematics,
                  subtitle: isAr ? AppStringsAr.wiringSchematicsSubtitle : AppStrings.wiringSchematicsSubtitle,
                  icon: Icons.account_tree,
                  accentColor: AppColors.successGreen,
                  badgeText: "PINOUT",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WiringSchematicsScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 1.7: Smart Workshop Experience & Field Ops
            _buildSectionHeader(
              isAr ? "تجربة الورشة الذكية والميدانية" : "Smart Workshop Experience & Field Ops",
              Icons.smart_toy,
              AppColors.primaryYellow,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.voiceAssistant : AppStrings.voiceAssistant,
                  subtitle: isAr ? AppStringsAr.voiceAssistantSubtitle : AppStrings.voiceAssistantSubtitle,
                  icon: Icons.mic,
                  accentColor: AppColors.primaryYellow,
                  badgeText: "VOICE",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceInspectionAssistantScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.arEngineBay : AppStrings.arEngineBay,
                  subtitle: isAr ? AppStringsAr.arEngineBaySubtitle : AppStrings.arEngineBaySubtitle,
                  icon: Icons.view_in_ar,
                  accentColor: AppColors.accentCyan,
                  badgeText: "AR HUD",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ArEngineBayHudScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.customerDispatch : AppStrings.customerDispatch,
                  subtitle: isAr ? AppStringsAr.customerDispatchSubtitle : AppStrings.customerDispatchSubtitle,
                  icon: Icons.chat,
                  accentColor: AppColors.successGreen,
                  badgeText: "DISPATCH",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerDispatchHubScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: isAr ? AppStringsAr.offlineVault : AppStrings.offlineVault,
                  subtitle: isAr ? AppStringsAr.offlineVaultSubtitle : AppStrings.offlineVaultSubtitle,
                  icon: Icons.inventory_2,
                  accentColor: AppColors.electricBlue,
                  badgeText: "CAN/OFFLINE",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineVaultProtocolSnifferScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 2: Component Analyzers & AI Copilot
            _buildSectionHeader(
              isAr ? "المحللات الذكية ومساعد الذكاء الاصطناعي" : "Intelligent Analyzers & AI Copilot",
              Icons.psychology,
              AppColors.accentCyan,
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: AppStrings.aiCopilot,
                  subtitle: "Rule-Based AI Diagnosis & Egyptian Bulletins",
                  icon: Icons.auto_awesome,
                  accentColor: AppColors.primaryYellow,
                  badgeText: "AI",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCopilotScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.catalyticAnalyzer,
                  subtitle: "Dual O2 Waveforms (B1S1/B1S2) & Efficiency",
                  icon: Icons.show_chart,
                  accentColor: AppColors.successGreen,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const O2CatAnalyzerScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: "Fuel Trim & Battery",
                  subtitle: "Vacuum Leak Matrix & Alternator Checker",
                  icon: Icons.psychology_outlined,
                  accentColor: AppColors.warningOrange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticAssistantScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: "Mode \$06 Misfires",
                  subtitle: "On-Board Monitors & Misfire Counters",
                  icon: Icons.monitor_heart_outlined,
                  accentColor: AppColors.accentCyan,
                  badgeText: "\$06",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Mode06MonitorScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.liveSensors,
                  subtitle: "Real-Time Sensor Monitoring Gauges",
                  icon: Icons.speed,
                  accentColor: AppColors.electricBlue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveDataScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.liveGraphs,
                  subtitle: "Multi-Channel Live Oscilloscope",
                  icon: Icons.stacked_line_chart,
                  accentColor: AppColors.accentCyan,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveGraphScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.freezeFrame,
                  subtitle: "ECU Snapshot at Fault Event",
                  icon: Icons.camera_alt_outlined,
                  accentColor: AppColors.dangerRed,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FreezeFrameScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 3: Road Test, Track & HUD Suite
            _buildSectionHeader("Road Test, Track & Night HUD", Icons.speed, AppColors.electricBlue),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: AppStrings.flightRecorder,
                  subtitle: state.isFlightRecording
                      ? "Recording (${state.flightTelemetryFrames.length} frames)..."
                      : "Black Box Telemetry & Timeline Scrubber",
                  icon: Icons.fiber_manual_record,
                  accentColor: state.isFlightRecording ? AppColors.dangerRed : AppColors.primaryYellow,
                  badgeText: state.isFlightRecording ? "REC" : null,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FlightRecorderScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.fuelCostCalculator,
                  subtitle: "L/100km & 80/92/95 Octane EGP Tariffs",
                  icon: Icons.local_gas_station,
                  accentColor: AppColors.successGreen,
                  badgeText: "EGP",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelCostCalculatorScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.hudDisplayMode,
                  subtitle: "Mirrored Windshield Projection Display",
                  icon: Icons.nightlight_round,
                  accentColor: AppColors.accentCyan,
                  badgeText: "HUD",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HudDisplayScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SECTION 4: Workshop Management & Diagnostics Library
            _buildSectionHeader("Workshop Tools & Reference Library", Icons.library_books, AppColors.textMuted),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context: context,
                  title: AppStrings.vehicleProfiles,
                  subtitle: state.selectedVehicle != null
                      ? "${state.selectedVehicle!.make} ${state.selectedVehicle!.model}"
                      : "70+ Egyptian Models",
                  icon: Icons.directions_car_filled,
                  accentColor: AppColors.primaryAmber,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleProfilesScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.dtcEncyclopedia,
                  subtitle: "Instant Lookups & Multimeter Guide",
                  icon: Icons.menu_book,
                  accentColor: AppColors.primaryYellow,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DtcEncyclopediaScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: "Readiness Monitors",
                  subtitle: "Emissions Drive Cycle (I/M)",
                  icon: Icons.fact_check_outlined,
                  accentColor: AppColors.electricBlue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadinessMonitorsScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: "ECU Information",
                  subtitle: "VIN, CALID & CVN Firmware",
                  icon: Icons.memory,
                  accentColor: AppColors.accentCyan,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EcuInfoScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.adapterBenchmark,
                  subtitle: "Verify PIC18F25K80 Chip",
                  icon: Icons.speed_outlined,
                  accentColor: AppColors.warningOrange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdapterBenchmarkScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: AppStrings.inspectionReports,
                  subtitle: "${state.savedReports.length} Saved Records",
                  icon: Icons.receipt_long,
                  accentColor: AppColors.successGreen,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: "Workshop LAN Hub",
                  subtitle: "Local Wi-Fi Report Sync",
                  icon: Icons.router,
                  accentColor: AppColors.electricBlue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkshopLanSyncScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),
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
    Color statusColor = AppColors.statusDisconnected;
    String statusTitle = AppStrings.disconnected;

    if (state.connectionState == ElmDriverState.ready) {
      statusColor = AppColors.statusConnected;
      statusTitle = "${AppStrings.connected} (${state.activeProtocol})";
    } else if (state.connectionState == ElmDriverState.adapterConnected) {
      statusColor = AppColors.warningOrange;
      statusTitle = AppStrings.adapterOnlyConnected;
    } else if (state.isConnecting) {
      statusColor = AppColors.statusConnecting;
      statusTitle = AppStrings.connecting;
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
                          ? "Battery: ${state.batteryVoltage.toStringAsFixed(1)}V | ${state.detectedVehicleInfo!.displaySummary}"
                          : "Battery: ${state.batteryVoltage.toStringAsFixed(1)}V | Vehicle: ${state.selectedVehicle?.model ?? 'Generic'}")
                      : state.statusMessage,
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
            child: Text(state.isConnected ? AppStrings.switchMode : "Connect", style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTestHeroCard(BuildContext context, ObdState state) {
    final isAr = state.isArabic;
    final vehicle = state.selectedVehicle;
    final vehicleTitle = vehicle != null
        ? vehicle.getDisplayName(isAr)
        : (isAr ? "اضغط لاختيار سيارة وبدء الفحص" : "Tap to select vehicle & start full test");

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
                              isAr ? AppStringsAr.fullVehicleTest : AppStrings.fullVehicleTest,
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
                        isAr
                            ? "فحص شامل لجميع الكنترولات والأعطال وحفظ تقرير PDF"
                            : "10-stage full network scan, deep health index & PDF report",
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
              children: const [
                Icon(Icons.bolt, color: Colors.black, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.quickScan,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        "Instant 30s vehicle scan: DTCs, Live Sensors, VIN & Voltage",
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black, size: 20),
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
        content: const Text("Please connect to a real OBD adapter (Bluetooth Classic, BLE, Wi-Fi, or USB OTG) first."),
        backgroundColor: AppColors.warningOrange,
        action: SnackBarAction(
          label: "Connect",
          textColor: Colors.black,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen()));
          },
        ),
      ),
    );
  }
}
