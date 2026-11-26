import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../core/utils/hex_parser.dart';
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
  bool _isCapturingTrims = false;
  String? _trimCaptureNote;

  // Battery test values
  double _restingVoltage = 12.5;
  double _crankingVoltage = 10.2;
  double _runningVoltage = 14.2;
  bool _isSamplingBattery = false;
  Timer? _batteryTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _batteryTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _captureLiveTrims(ObdState state, {required bool isLoad}) async {
    if (!state.isConnected) return;
    setState(() {
      _isCapturingTrims = true;
      _trimCaptureNote = isLoad ? "Reading 2500 RPM STFT / LTFT from ECU..." : "Reading Idle STFT / LTFT from ECU...";
    });

    try {
      double? stft;
      double? ltft;
      final stftRaw = await state.sendCommand("0106");
      final stftP = HexParser.extractPayload(HexParser.extractBytes(stftRaw), 0x01, 0x06);
      if (stftP.isNotEmpty) stft = ((stftP[0] - 128.0) * 100.0) / 128.0;

      final ltftRaw = await state.sendCommand("0107");
      final ltftP = HexParser.extractPayload(HexParser.extractBytes(ltftRaw), 0x01, 0x07);
      if (ltftP.isNotEmpty) ltft = ((ltftP[0] - 128.0) * 100.0) / 128.0;

      if (!mounted) return;
      if (stft != null || ltft != null) {
        setState(() {
          if (isLoad) {
            if (stft != null) _stftLoad = stft.clamp(-25.0, 25.0);
            if (ltft != null) _ltftLoad = ltft.clamp(-25.0, 25.0);
          } else {
            if (stft != null) _stftIdle = stft.clamp(-25.0, 25.0);
            if (ltft != null) _ltftIdle = ltft.clamp(-25.0, 25.0);
          }
          _trimCaptureNote =
              "Captured live (${state.currentRpm.round()} RPM): STFT ${stft?.toStringAsFixed(1) ?? 'N/A'}%, LTFT ${ltft?.toStringAsFixed(1) ?? 'N/A'}%";
        });
      } else {
        setState(() {
          _trimCaptureNote = "ECU returned no 0106/0107 Fuel Trim data.";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturingTrims = false);
      }
    }
  }

  void _toggleLiveCrankingTest(ObdState state) {
    if (_isSamplingBattery) {
      _batteryTimer?.cancel();
      _batteryTimer = null;
      setState(() => _isSamplingBattery = false);
      return;
    }

    if (!state.isConnected || state.driver == null) return;
    double lowestSeen = state.batteryVoltage;
    double highestSeen = state.batteryVoltage;

    setState(() {
      _isSamplingBattery = true;
      _restingVoltage = state.batteryVoltage.clamp(10.0, 13.5);
      _crankingVoltage = state.batteryVoltage.clamp(7.0, 12.0);
      _runningVoltage = state.batteryVoltage.clamp(11.5, 16.0);
    });

    _batteryTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) async {
      if (!mounted || !state.isConnected || state.driver == null) {
        timer.cancel();
        if (mounted) setState(() => _isSamplingBattery = false);
        return;
      }
      final v = await state.driver!.refreshBatteryVoltage();
      if (!mounted || v <= 5.0) return;

      if (v < lowestSeen) lowestSeen = v;
      if (v > highestSeen) highestSeen = v;

      setState(() {
        if (lowestSeen < 12.0) {
          _crankingVoltage = lowestSeen.clamp(7.0, 12.0);
        }
        if (v >= 13.2 || highestSeen >= 13.2) {
          _runningVoltage = v.clamp(11.5, 16.0);
        } else {
          _restingVoltage = v.clamp(10.0, 13.5);
        }
      });
    });
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
          _buildFuelTrimTab(state),

          // 2. Electrical System Diagnostic Tab
          _buildBatteryTab(state),
        ],
      ),
    );
  }

  Widget _buildFuelTrimTab(ObdState state) {
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
          const SizedBox(height: 12),

          // Live ECU Capture Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.sensors, size: 18),
                  label: const Text("Capture Idle Live", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: state.isConnected && !_isCapturingTrims
                      ? () => _captureLiveTrims(state, isLoad: false)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.speed, size: 18),
                  label: const Text("Capture 2500 RPM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: state.isConnected && !_isCapturingTrims
                      ? () => _captureLiveTrims(state, isLoad: true)
                      : null,
                ),
              ),
            ],
          ),
          if (_trimCaptureNote != null) ...[
            const SizedBox(height: 8),
            Text(
              _trimCaptureNote!,
              style: const TextStyle(fontSize: 11, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
            ),
          ],
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

  Widget _buildBatteryTab(ObdState state) {
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
            child: Text(
              "Live Adapter Voltage: ${state.batteryVoltage.toStringAsFixed(2)}V • Start Live Cranking Test with engine off, then crank starter & let engine idle to automatically record sag & charging output.",
              style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSamplingBattery ? AppColors.dangerRed : AppColors.successGreen,
              foregroundColor: _isSamplingBattery ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: Icon(_isSamplingBattery ? Icons.stop_circle : Icons.bolt),
            label: Text(
              _isSamplingBattery
                  ? "Stop Live Cranking & Alternator Sampling (${state.batteryVoltage.toStringAsFixed(2)}V)"
                  : "Start Live 12V Cranking & Alternator Test",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: state.isConnected ? () => _toggleLiveCrankingTest(state) : null,
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
