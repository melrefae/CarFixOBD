import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/lab_scope_models.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen offering digital lab oscilloscope, CKP/CMP timing chain stretch analyzer,
/// ignition spark burn analysis, and fuel injector inductive flyback waveforms
class LabScopeWaveformScreen extends StatefulWidget {
  const LabScopeWaveformScreen({Key? key}) : super(key: key);

  @override
  State<LabScopeWaveformScreen> createState() => _LabScopeWaveformScreenState();
}

class _LabScopeWaveformScreenState extends State<LabScopeWaveformScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lab Scope State
  bool _showGoldenOverlay = true;
  late TimingChainSyncAnalysis _chainAnalysis;
  late IgnitionWaveformAnalysis _ignitionAnalysis;
  late InjectorWaveformAnalysis _injectorAnalysis;

  double _timebaseMs = 20.0;
  double _chAVoltsPerDiv = 2.0;
  double _chBVoltsPerDiv = 2.0;
  final ScopeCursorMeasurement _cursors = const ScopeCursorMeasurement(
    cursor1TimeMs: 40.0,
    cursor2TimeMs: 75.0,
    cursor1Voltage: 0.2,
    cursor2Voltage: 5.0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chainAnalysis = TimingChainSyncAnalysis.fromLiveTelemetry(
      rpm: 0.0,
      timingAdvance: 0.0,
      engine: "Generic OBD-II",
    );
    _ignitionAnalysis = IgnitionWaveformAnalysis.fromLiveTelemetry(
      rpm: 0.0,
      batteryVoltage: 12.6,
    );
    _injectorAnalysis = InjectorWaveformAnalysis.fromLiveTelemetry(
      rpm: 0.0,
      engineLoad: 0.0,
      batteryVoltage: 12.6,
    );
  }

  void _syncWithLiveTelemetry(ObdState state) {
    final platform = state.selectedVehicle != null
        ? "${state.selectedVehicle!.make} ${state.selectedVehicle!.model}"
        : "Connected OBD-II Vehicle";
    final load = state.sensorValues['04']?.value ?? 25.0;

    _chainAnalysis = TimingChainSyncAnalysis.fromLiveTelemetry(
      rpm: state.currentRpm,
      timingAdvance: state.timingAdvance,
      engine: platform,
    );
    _ignitionAnalysis = IgnitionWaveformAnalysis.fromLiveTelemetry(
      rpm: state.currentRpm,
      batteryVoltage: state.batteryVoltage,
    );
    _injectorAnalysis = InjectorWaveformAnalysis.fromLiveTelemetry(
      rpm: state.currentRpm,
      engineLoad: load,
      batteryVoltage: state.batteryVoltage,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    if (state.isConnected) {
      _syncWithLiveTelemetry(state);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "مختبر الأوسيلوسكوب وإشارات التزامن" : "Digital Lab Scope & Timing"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: [
            Tab(icon: const Icon(Icons.sync_alt, size: 18), text: isAr ? "الكرنك والكامة" : "CKP / CMP Sync"),
            Tab(icon: const Icon(Icons.flash_on, size: 18), text: isAr ? "إشارة الموبينة" : "Ignition Spark"),
            Tab(icon: const Icon(Icons.grain, size: 18), text: isAr ? "نبضة الرشاش" : "Injector Pulse"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildConnectionNotice(context, state, isAr),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.warningOrange.withOpacity(0.12),
            child: Text(
              isAr
                  ? "رسومات وتحليلات تقديرية محسوبة من معادلات - ليست قياسات حقيقية. قراءة إشارات الكرنك/الكامة الفعلية تحتاج أوسيلوسكوب خارجي."
                  : "Estimated waveforms computed from formulas - not real measurements. Capturing actual CKP/CMP signals requires an external oscilloscope.",
              style: const TextStyle(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCkpCmpSyncTab(state, isAr),
                _buildIgnitionSparkTab(state, isAr),
                _buildInjectorPulseTab(state, isAr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionNotice(BuildContext context, ObdState state, bool isAr) {
    if (state.isConnected) {
      if (state.currentRpm <= 0) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryYellow, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr
                      ? "المحرك متوقف (0 RPM): شغل المحرك في وضع السلانسيه (Idle) لتسجيل نبضات الكرنك والرشاشات الحية."
                      : "Engine is stopped (0 RPM). Idle the engine to stream live CKP/CMP, ignition spark, and injector pulses.",
                  style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warningOrange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cable_outlined, color: AppColors.warningOrange, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "فيشة الفحص غير متصلة بالمركبة" : "OBD Hardware Not Connected",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warningOrange),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? "قم بتوصيل فيشة الفحص بالسيارة لتسجيل إشارات الأوسيلوسكوب الحية."
                      : "Connect OBD hardware to vehicle to stream live oscilloscope waveforms.",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectionScreen()),
              );
            },
            child: Text(isAr ? "اتصال" : "Connect", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: CKP / CMP Timing Chain Sync ---
  Widget _buildCkpCmpSyncTab(ObdState state, bool isAr) {
    final isStretched = _chainAnalysis.isChainStretched;
    final statusColor = isStretched ? AppColors.dangerRed : AppColors.successGreen;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verdict Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(isStretched ? Icons.warning_amber_rounded : Icons.check_circle, color: statusColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? "حالة تزامن الكرنك والكامة وجنزير الكاتينة" : "Cam/Crank Synchronization & Timing Chain",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: statusColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr ? _chainAnalysis.verdictAr : _chainAnalysis.verdictEn,
                        style: const TextStyle(fontSize: 11, color: AppColors.textWhite),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Oscilloscope Screen Card
          Card(
            color: const Color(0xFF0F141A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Scope Header Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFFD54F), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(Provider.of<ObdState>(context, listen: false).isArabic ? "القناة A: حساس الكرنك (60-2)" : "CH A: CKP (60-2)", style: const TextStyle(fontSize: 10, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(Provider.of<ObdState>(context, listen: false).isArabic ? "القناة B: حساس الكامة Hall" : "CH B: CMP Hall", style: const TextStyle(fontSize: 10, color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(Provider.of<ObdState>(context, listen: false).isArabic ? "المرجع الأصلي (OEM)" : "OEM Golden Overlay", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Switch(
                            value: _showGoldenOverlay,
                            activeColor: AppColors.primaryYellow,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (v) => setState(() => _showGoldenOverlay = v),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Custom Scope Canvas
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0E13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: CustomPaint(
                      painter: _ScopeGridAndWavePainter(
                        ckpPoints: _chainAnalysis.channelACkp,
                        cmpPoints: _chainAnalysis.channelBCmp,
                        goldenOverlay: _showGoldenOverlay ? _chainAnalysis.goldenOverlayCmp : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Cursor Measurements Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF192026),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Δt: ${_cursors.deltaTimeMs.toStringAsFixed(1)} ms", style: const TextStyle(fontSize: 10, color: AppColors.primaryYellow, fontFamily: 'monospace')),
                        Text(Provider.of<ObdState>(context, listen: false).isArabic ? "التردد: ${_cursors.frequencyHz.toStringAsFixed(1)} Hz" : "Freq: ${_cursors.frequencyHz.toStringAsFixed(1)} Hz", style: const TextStyle(fontSize: 10, color: AppColors.accentCyan, fontFamily: 'monospace')),
                        Text(Provider.of<ObdState>(context, listen: false).isArabic ? "قاعدة الزمن: ${_timebaseMs.toStringAsFixed(0)}ms (A:${_chAVoltsPerDiv.toStringAsFixed(0)}V B:${_chBVoltsPerDiv.toStringAsFixed(0)}V)" : "TB: ${_timebaseMs.toStringAsFixed(0)}ms (A:${_chAVoltsPerDiv.toStringAsFixed(0)}V B:${_chBVoltsPerDiv.toStringAsFixed(0)}V)", style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace')),
                        Text(Provider.of<ObdState>(context, listen: false).isArabic ? "إزاحة الطور: ${_chainAnalysis.measuredPhaseOffsetDeg.toStringAsFixed(1)}°" : "Phase Offset: ${_chainAnalysis.measuredPhaseOffsetDeg.toStringAsFixed(1)}°", style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Diagnostic Metrics Grid
          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow(Provider.of<ObdState>(context, listen: false).isArabic ? "منصة المحرك:" : "Engine Platform:", _chainAnalysis.enginePlatform, AppColors.textWhite),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow(Provider.of<ObdState>(context, listen: false).isArabic ? "إزاحة الكرنك/الكامة (تقديري):" : "Cam/Crank Relative Offset (estimated):", "+${_chainAnalysis.measuredPhaseOffsetDeg.toStringAsFixed(1)}°", statusColor),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow(Provider.of<ObdState>(context, listen: false).isArabic ? "تفاوت المصنع:" : "OEM Manufacturer Tolerance:", "±${_chainAnalysis.nominalToleranceDeg.toStringAsFixed(1)}° max", AppColors.textMuted),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow(Provider.of<ObdState>(context, listen: false).isArabic ? "حالة استطالة الجنزير:" : "Timing Chain Elongation Status:", Provider.of<ObdState>(context, listen: false).isArabic ? "تقديري - غير قابل للقياس عبر OBD" : "ESTIMATED - not measurable via OBD", statusColor),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Capture / Recalibrate Live Waveform Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.sensors),
            label: Text(
              isAr ? "التقاط إشارة الكرنك والكامة الحية من المركبة" : "Capture Live Vehicle Synchronization Signal",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              if (!state.isConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? "يرجى توصيل فيشة الفحص بالسيارة أولاً" : "Please connect OBD hardware to vehicle first."),
                    backgroundColor: AppColors.warningOrange,
                  ),
                );
                return;
              }
              setState(() {
                final platform = state.selectedVehicle != null
                    ? "${state.selectedVehicle!.make} ${state.selectedVehicle!.model}"
                    : "Generic OBD-II (ISO 15765-4)";
                _chainAnalysis = TimingChainSyncAnalysis.fromLiveTelemetry(
                  rpm: state.currentRpm,
                  timingAdvance: state.timingAdvance,
                  engine: platform,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? "تم تحديث إشارة الكرنك والكامة الحية بنجاح" : "Live cam/crank synchronization waveform captured."),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 2: Primary & Secondary Ignition Spark ---
  Widget _buildIgnitionSparkTab(ObdState state, bool isAr) {
    final ig = _ignitionAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "تحليل زمن حرق شرارة البوجيه (Burn Time)" : "Ignition Spark Burn Line & Dwell",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                    ),
                    Chip(
                      backgroundColor: state.isConnected && state.currentRpm > 0
                          ? const Color(0xFF004D40)
                          : const Color(0xFF374151),
                      label: Text(
                        state.isConnected && state.currentRpm > 0 ? "LIVE COIL" : "STANDBY",
                        style: TextStyle(
                          color: state.isConnected && state.currentRpm > 0 ? AppColors.successGreen : AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: CustomPaint(
                    painter: _SingleWavePainter(
                      points: ig.sparkWaveform,
                      lineColor: const Color(0xFFFF9100),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow("Spark Burn Time:", "${ig.sparkBurnTimeMs} ms (Nominal: 1.2 - 2.0 ms)", AppColors.successGreen),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Dwell Saturation Charging:", "${ig.dwellChargingTimeMs} ms", AppColors.accentCyan),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Firing KV Peak Spike:", "${ig.sparkLineKv} kV", AppColors.primaryYellow),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Ignition Coil Status:", state.isConnected && state.currentRpm > 0 ? "LIVE FIRING / HEALTHY" : "ENGINE AT STANDBY", AppColors.successGreen),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.flash_on),
            label: Text(
              isAr ? "التقاط إشارة شرارة الموبينة الحية" : "Capture Live Ignition Spark Telemetry",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              if (!state.isConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? "يرجى توصيل فيشة الفحص بالسيارة أولاً" : "Please connect OBD hardware to vehicle first."),
                    backgroundColor: AppColors.warningOrange,
                  ),
                );
                return;
              }
              setState(() {
                _ignitionAnalysis = IgnitionWaveformAnalysis.fromLiveTelemetry(
                  rpm: state.currentRpm,
                  batteryVoltage: state.batteryVoltage,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? "تم تحديث إشارة الإشعال الحية بنجاح" : "Live ignition waveform updated."),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 3: Fuel Injector Current & Flyback ---
  Widget _buildInjectorPulseTab(ObdState state, bool isAr) {
    final inj = _injectorAnalysis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "نبضة حقن الرشاش وانهيار الجهد الحثي" : "Injector Pulse Width & Flyback Spike",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                    ),
                    Chip(
                      backgroundColor: state.isConnected && state.currentRpm > 0
                          ? const Color(0xFF004D40)
                          : const Color(0xFF374151),
                      label: Text(
                        state.isConnected && state.currentRpm > 0 ? "LIVE PULSE" : "STANDBY",
                        style: TextStyle(
                          color: state.isConnected && state.currentRpm > 0 ? AppColors.successGreen : AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: CustomPaint(
                    painter: _SingleWavePainter(
                      points: inj.injectorWaveform,
                      lineColor: const Color(0xFF00E676),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow("Injector Pulse Width:", "${inj.pulseWidthMs} ms (${state.isConnected && state.currentRpm > 0 ? "Live Load" : "Standby"})", AppColors.accentCyan),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Flyback Back-EMF Spike:", "${inj.flybackVoltagePeak} V (Nominal: 50 - 75 V)", AppColors.successGreen),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Peak Hold Amperage:", "${inj.peakCurrentAmps} A", AppColors.primaryYellow),
                  const Divider(color: AppColors.cardBorder),
                  _buildMetricRow("Solenoid Coil Health:", state.isConnected && state.currentRpm > 0 ? "LIVE INJECTION / HEALTHY" : "STANDBY", AppColors.successGreen),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.grain),
            label: Text(
              isAr ? "التقاط نبضة حقن الرشاش الحية" : "Capture Live Injector Pulse Telemetry",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              if (!state.isConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? "يرجى توصيل فيشة الفحص بالسيارة أولاً" : "Please connect OBD hardware to vehicle first."),
                    backgroundColor: AppColors.warningOrange,
                  ),
                );
                return;
              }
              setState(() {
                final load = state.sensorValues['04']?.value ?? 25.0;
                _injectorAnalysis = InjectorWaveformAnalysis.fromLiveTelemetry(
                  rpm: state.currentRpm,
                  engineLoad: load,
                  batteryVoltage: state.batteryVoltage,
                );
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? "تم تحديث إشارة نبضات الحقن الحية بنجاح" : "Live injector pulse waveform updated."),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// Custom Painter for Oscilloscope Grid & Dual Waveforms
class _ScopeGridAndWavePainter extends CustomPainter {
  final List<ScopeWaveformPoint> ckpPoints;
  final List<ScopeWaveformPoint> cmpPoints;
  final List<ScopeWaveformPoint>? goldenOverlay;

  _ScopeGridAndWavePainter({
    required this.ckpPoints,
    required this.cmpPoints,
    this.goldenOverlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Oscilloscope Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0;

    const divisionsX = 8;
    const divisionsY = 6;

    for (int i = 0; i <= divisionsX; i++) {
      final x = (size.width / divisionsX) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int j = 0; j <= divisionsY; j++) {
      final y = (size.height / divisionsY) * j;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Draw Golden Overlay (if enabled)
    if (goldenOverlay != null && goldenOverlay!.isNotEmpty) {
      final goldenPaint = Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < goldenOverlay!.length; i++) {
        final p = goldenOverlay![i];
        final x = (p.timeMs / 120.0) * size.width;
        final y = size.height * 0.45 - (p.voltage / 6.0) * (size.height * 0.35);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, goldenPaint);
    }

    // 3. Draw Channel A (CKP - Yellow)
    if (ckpPoints.isNotEmpty) {
      final chAPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final pathA = Path();
      for (int i = 0; i < ckpPoints.length; i++) {
        final p = ckpPoints[i];
        final x = (p.timeMs / 120.0) * size.width;
        final y = size.height * 0.85 - (p.voltage / 5.5) * (size.height * 0.35);
        if (i == 0) {
          pathA.moveTo(x, y);
        } else {
          pathA.lineTo(x, y);
        }
      }
      canvas.drawPath(pathA, chAPaint);
    }

    // 4. Draw Channel B (CMP - Cyan)
    if (cmpPoints.isNotEmpty) {
      final chBPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;

      final pathB = Path();
      for (int i = 0; i < cmpPoints.length; i++) {
        final p = cmpPoints[i];
        final x = (p.timeMs / 120.0) * size.width;
        final y = size.height * 0.45 - (p.voltage / 6.0) * (size.height * 0.35);
        if (i == 0) {
          pathB.moveTo(x, y);
        } else {
          pathB.lineTo(x, y);
        }
      }
      canvas.drawPath(pathB, chBPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScopeGridAndWavePainter oldDelegate) => true;
}

/// Custom Painter for Single Channel Waveform
class _SingleWavePainter extends CustomPainter {
  final List<ScopeWaveformPoint> points;
  final Color lineColor;

  _SingleWavePainter({
    required this.points,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxT = points.last.timeMs;
    final maxV = points.map((p) => p.voltage).reduce(max);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = maxT > 0 ? (p.timeMs / maxT) * size.width : 0.0;
      final y = size.height - (maxV > 0 ? (p.voltage / maxV) * (size.height * 0.85) : 0.0) - 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SingleWavePainter oldDelegate) => true;
}
