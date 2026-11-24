import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/analyzers/fuel_trim_analyzer.dart';
import '../../domain/analyzers/battery_health_checker.dart';
import '../providers/obd_state.dart';

/// Intelligent diagnostic assistant screen (Fuel trim matrix, vacuum leak detection, battery health)
class DiagnosticAssistantScreen extends StatefulWidget {
  const DiagnosticAssistantScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticAssistantScreen> createState() => _DiagnosticAssistantScreenState();
}

class _DiagnosticAssistantScreenState extends State<DiagnosticAssistantScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Fuel trim test values
  double _stftIdle = 3.5;
  double _ltftIdle = 16.0;
  double _stftLoad = 2.0;
  double _ltftLoad = 4.0;

  // Battery test values
  double _restingVoltage = 12.5;
  double _crankingVoltage = 10.2;
  double _runningVoltage = 14.2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.diagnosticAssistant),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.tune), text: "Fuel Trim & Vacuum"),
            Tab(icon: Icon(Icons.battery_charging_full), text: "Battery & Alternator"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Fuel Trim & Vacuum Diagnostic Matrix
          _buildFuelTrimTab(),

          // 2. Electrical System Diagnostic Tab
          _buildBatteryTab(state.batteryVoltage),
        ],
      ),
    );
  }

  Widget _buildFuelTrimTab() {
    final result = FuelTrimAnalyzer.analyze(
      stftIdle: _stftIdle,
      ltftIdle: _ltftIdle,
      stftLoad: _stftLoad,
      ltftLoad: _ltftLoad,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Diagnostic Method: Record Fuel Trims (STFT + LTFT) at idle, then hold engine at 2500 RPM under load. Observe how trim values change to instantly distinguish between vacuum leaks and fuel pump starvation.",
              style: TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          // Idle Trims
          const Text("Idle Trims (STFT + LTFT):", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryYellow)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSliderTile(
                  label: "Idle STFT (%)",
                  value: _stftIdle,
                  min: -25,
                  max: 25,
                  onChanged: (v) => setState(() => _stftIdle = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSliderTile(
                  label: "Idle LTFT (%)",
                  value: _ltftIdle,
                  min: -25,
                  max: 25,
                  onChanged: (v) => setState(() => _ltftIdle = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2500 RPM Trims
          const Text("2500 RPM Trims (Under Load):", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.electricBlue)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSliderTile(
                  label: "Load STFT (%)",
                  value: _stftLoad,
                  min: -25,
                  max: 25,
                  onChanged: (v) => setState(() => _stftLoad = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSliderTile(
                  label: "Load LTFT (%)",
                  value: _ltftLoad,
                  min: -25,
                  max: 25,
                  onChanged: (v) => setState(() => _ltftLoad = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Diagnostic result card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isSevere ? AppColors.dangerRed.withOpacity(0.15) : AppColors.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: result.isSevere ? AppColors.dangerRed : AppColors.successGreen, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(result.isSevere ? Icons.warning_rounded : Icons.check_circle,
                        color: result.isSevere ? AppColors.dangerRed : AppColors.successGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: result.isSevere ? AppColors.dangerRed : AppColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(result.diagnosis, style: const TextStyle(fontSize: 13, color: AppColors.textWhite, height: 1.4)),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF37474F)),
                const Text(
                  "Workshop Recommended Action:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 4),
                Text(result.recommendation, style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTab(double liveVoltage) {
    final result = BatteryHealthChecker.evaluate(
      restingVoltage: _restingVoltage,
      minCrankingVoltage: _crankingVoltage,
      runningVoltage: _runningVoltage,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cardSurfaceHighlight, borderRadius: BorderRadius.circular(10)),
            child: const Text(
              "This diagnostic evaluates key 12V automotive battery stages: resting open-circuit voltage, starter motor cranking drop (<9.6V indicates failing plates), and alternator regulation under load.",
              style: TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),

          _buildSliderTile(
            label: "Resting Battery Voltage (Engine OFF): ${_restingVoltage.toStringAsFixed(1)}V",
            value: _restingVoltage,
            min: 10.0,
            max: 13.5,
            onChanged: (v) => setState(() => _restingVoltage = v),
          ),
          const SizedBox(height: 12),

          _buildSliderTile(
            label: "Min Cranking Voltage Drop (Starter Crank): ${_crankingVoltage.toStringAsFixed(1)}V",
            value: _crankingVoltage,
            min: 7.0,
            max: 12.0,
            onChanged: (v) => setState(() => _crankingVoltage = v),
          ),
          const SizedBox(height: 12),

          _buildSliderTile(
            label: "Alternator Output Voltage (Engine Running): ${_runningVoltage.toStringAsFixed(1)}V",
            value: _runningVoltage,
            min: 11.5,
            max: 16.0,
            onChanged: (v) => setState(() => _runningVoltage = v),
          ),
          const SizedBox(height: 24),

          // Electrical health result card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isBatteryGood && result.isAlternatorGood
                  ? AppColors.successGreen.withOpacity(0.15)
                  : AppColors.dangerRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: result.isBatteryGood && result.isAlternatorGood ? AppColors.successGreen : AppColors.dangerRed,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Battery Health: ${result.batteryStatus}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                ),
                const SizedBox(height: 6),
                Text(
                  "Alternator Health: ${result.alternatorStatus}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF37474F)),
                Text(
                  "Recommendation: ${result.recommendation}",
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryYellow, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppColors.primaryYellow,
            inactiveColor: AppColors.cardSurfaceHighlight,
            onChanged: onChanged,
          ),
          Center(
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
