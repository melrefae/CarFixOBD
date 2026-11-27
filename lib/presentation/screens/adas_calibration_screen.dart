import 'package:flutter/material.dart';
import '../../core/utils/uds_response.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/adas_calibration_models.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen offering ADAS front windshield camera & bumper radar target placement matrix,
/// digital laser level alignment tool, and guided dynamic road calibration wizard
class AdasCalibrationScreen extends StatefulWidget {
  const AdasCalibrationScreen({Key? key}) : super(key: key);

  @override
  State<AdasCalibrationScreen> createState() => _AdasCalibrationScreenState();
}

class _AdasCalibrationScreenState extends State<AdasCalibrationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<AdasTargetPlacement> _presets = AdasTargetPlacement.getAllPresets();
  int _selectedPresetIndex = 0;

  final AdasLaserLevel _laserLevel = const AdasLaserLevel();

  final List<DynamicRoadCalibrationStep> _roadSteps = DynamicRoadCalibrationStep.getDefaultSteps();
  int _currentStepIndex = 1;
  bool _isCalibratingRoad = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _executeNextRoadStep() async {
    if (_currentStepIndex >= _roadSteps.length - 1) return;

    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص بالمركبة قبل بدء المعايرة الحركية على الطريق"
                : "Please connect OBD adapter to vehicle before executing dynamic road calibration.",
          ),
          backgroundColor: AppColors.warningOrange,
          action: SnackBarAction(
            label: isAr ? "اتصال" : "Connect",
            textColor: Colors.black,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen()));
            },
          ),
        ),
      );
      return;
    }

    final targetStep = _roadSteps[_currentStepIndex];
    if (targetStep.targetSpeedKmH > 0 && state.currentSpeed < 30.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "سرعة السيارة الحالية (${state.currentSpeed.toStringAsFixed(0)} كم/س) منخفضة. يجب القيادة بسرعة ${targetStep.targetSpeedKmH} كم/س للمعايرة البصرية."
                : "Current vehicle speed (${state.currentSpeed.toStringAsFixed(0)} km/h) is too slow. Drive at ${targetStep.targetSpeedKmH} km/h on a marked road.",
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    setState(() {
      _isCalibratingRoad = true;
    });

    // Transmit genuine UDS RoutineControl command 31 01 03 10 (StartRoutine: Dynamic Camera/Radar Optical Calibration)
    final raw = await state.sendCommand('31 01 03 10');
    final result = UdsResult.evaluate(raw, 0x31);

    if (!mounted) return;

    setState(() {
      _isCalibratingRoad = false;
      // The step advances only if the ECU accepted the routine.
      if (result.isPositive && _currentStepIndex < _roadSteps.length - 1) _currentStepIndex++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isPositive
            ? (isAr ? "الكمبيوتر قبل أمر المعايرة. الرد: ${result.raw}. تأكد من النتيجة بأداة معايرة معتمدة." : "The ECU accepted the calibration request. Reply: ${result.raw}. Confirm the result with an approved calibration tool.")
            : (isAr ? "الكمبيوتر لم يقبل الأمر. الرد: ${result.raw}" : "The ECU did not accept the request. Reply: ${result.raw}")),
        backgroundColor: result.isPositive ? AppColors.primaryYellow : AppColors.dangerRed,
      ),
    );
  }

  Widget _buildConnectionBanner(BuildContext context, ObdState state, bool isAr) {
    if (state.isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
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
                      ? "قم بتوصيل فيشة الفحص بالسيارة لقراءة سرعة المركبة وتنفيذ معايرة ADAS."
                      : "Connect OBD hardware to vehicle to verify speed and calibrate ADAS.",
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "معايرة رادار وكاميرا مساعدة السائق ADAS" : "ADAS Radar & Camera Calibration"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: [
            Tab(icon: const Icon(Icons.straighten, size: 18), text: isAr ? "مسافات اللوحة" : "Target Placement"),
            Tab(icon: const Icon(Icons.architecture, size: 18), text: isAr ? "ميزان الليزر" : "Laser Level"),
            Tab(icon: const Icon(Icons.add_road, size: 18), text: isAr ? "المعايرة الديناميكية" : "Dynamic Road Test"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTargetPlacementTab(isAr),
          _buildLaserLevelTab(isAr),
          _buildDynamicRoadTab(state, isAr),
        ],
      ),
    );
  }

  // --- TAB 1: Target Board Placement Coordinates ---
  Widget _buildTargetPlacementTab(bool isAr) {
    final preset = _presets[_selectedPresetIndex];

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
                const Text(
                  "Select ADAS Sensor & Vehicle Platform:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedPresetIndex,
                  dropdownColor: AppColors.cardSurface,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: List.generate(_presets.length, (i) {
                    final p = _presets[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text("${p.brandPlatform} (${p.systemName})", style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedPresetIndex = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Visual Target Placement Hero Diagram
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF263238), Color(0xFF1E262C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentCyan),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.systemName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                        ),
                        Text(
                          preset.brandPlatform,
                          style: const TextStyle(fontSize: 11, color: AppColors.accentCyan),
                        ),
                      ],
                    ),
                    const Icon(Icons.center_focus_strong, color: AppColors.primaryYellow, size: 28),
                  ],
                ),
                const SizedBox(height: 16),

                // Dimension Grid
                Row(
                  children: [
                    _buildDimensionCard("Distance (Axle L1)", "${preset.distanceFromFrontAxleMm} mm", Icons.arrow_forward),
                    const SizedBox(width: 8),
                    _buildDimensionCard("Distance (Bumper L2)", "${preset.distanceFromBumperMm} mm", Icons.compress),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDimensionCard("Height (Ground H)", "${preset.heightFromGroundMm} mm", Icons.height),
                    const SizedBox(width: 8),
                    _buildDimensionCard("Lateral Offset (Y)", "${preset.lateralOffsetMm} mm (Center)", Icons.swap_horiz),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Required Target Pattern:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryYellow)),
                  const SizedBox(height: 4),
                  Text(preset.targetPatternType, style: const TextStyle(fontSize: 13, color: AppColors.textWhite, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 6),
                  const Text("Workshop Placement Instructions:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite)),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? preset.notesAr : preset.notesEn,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: Digital Laser Level ---
  Widget _buildLaserLevelTab(bool isAr) {
    final level = _laserLevel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  isAr ? "ميزان التسوية الرقمي لحساس الرادار" : "Digital Radar Bubble Level",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F141A),
                    shape: BoxShape.circle,
                    border: Border.all(color: level.isAligned ? AppColors.successGreen : AppColors.dangerRed, width: 2.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Crosshairs
                      const Divider(color: Colors.white12),
                      const VerticalDivider(color: Colors.white12),
                      // Circle Center
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5), width: 1.5),
                        ),
                      ),
                      // Bubble
                      Positioned(
                        left: 70 + (level.yawAngleDeg * 30),
                        top: 70 - (level.pitchAngleDeg * 30),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: level.isAligned ? AppColors.successGreen : AppColors.dangerRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: (level.isAligned ? AppColors.successGreen : AppColors.dangerRed).withOpacity(0.6), blurRadius: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  level.isAligned ? "RADAR SENSOR MECHANICALLY ALIGNED" : "OUT OF TOLERANCE - ADJUST SCREWS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: level.isAligned ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLevelRow("Pitch Tilt Angle (Vertical):", "${level.pitchAngleDeg > 0 ? "+" : ""}${level.pitchAngleDeg}° (Nominal ±0.5°)", AppColors.successGreen),
                  const Divider(color: AppColors.cardBorder),
                  _buildLevelRow("Roll Horizon Angle (Level):", "${level.rollAngleDeg > 0 ? "+" : ""}${level.rollAngleDeg}°", AppColors.accentCyan),
                  const Divider(color: AppColors.cardBorder),
                  _buildLevelRow("Yaw Azimuth Angle (Horizontal):", "${level.yawAngleDeg > 0 ? "+" : ""}${level.yawAngleDeg}°", AppColors.primaryYellow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: Guided Dynamic Road Calibration ---
  Widget _buildDynamicRoadTab(ObdState state, bool isAr) {
    final step = _roadSteps[_currentStepIndex];
    final isSpeedAdequate = step.targetSpeedKmH == 0 || (state.isConnected && state.currentSpeed >= 30.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionBanner(context, state, isAr),

          // Live Vehicle Speed Monitor Card
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state.isConnected
                    ? (isSpeedAdequate ? AppColors.successGreen : AppColors.warningOrange)
                    : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      color: state.isConnected
                          ? (isSpeedAdequate ? AppColors.successGreen : AppColors.warningOrange)
                          : AppColors.textMuted,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? "سرعة المركبة الحية (OBD Speed)" : "Live Vehicle Speed (OBD)",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                        Text(
                          state.isConnected
                              ? (step.targetSpeedKmH > 0
                                  ? (isSpeedAdequate
                                      ? (isAr ? "السرعة ملائمة لمعايرة الكاميرا" : "Speed meets optical calibration profile")
                                      : (isAr ? "المطلوب: قيادة بسرعة ${step.targetSpeedKmH} كم/س" : "Required: Cruise at ${step.targetSpeedKmH} km/h"))
                                  : (isAr ? "المركبة جاهزة للبدء" : "Ready for calibration"))
                              : (isAr ? "فيشة الفحص غير متصلة" : "Adapter disconnected"),
                          style: TextStyle(
                            fontSize: 10,
                            color: state.isConnected
                                ? (isSpeedAdequate ? AppColors.successGreen : AppColors.warningOrange)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  state.isConnected ? "${state.currentSpeed.toStringAsFixed(0)} km/h" : "-- km/h",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: state.isConnected
                        ? (isSpeedAdequate ? AppColors.successGreen : AppColors.warningOrange)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "معالج المعايرة الديناميكية أثناء القيادة" : "Dynamic Road Learning Wizard",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                    ),
                    Text(
                      "Step ${_currentStepIndex + 1} of ${_roadSteps.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryYellow),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _roadSteps[_currentStepIndex].progressPercent / 100.0,
                  color: AppColors.primaryYellow,
                  backgroundColor: Colors.white12,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ..._roadSteps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isDone = idx < _currentStepIndex;
            final isCurrent = idx == _currentStepIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF263238) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? AppColors.successGreen
                      : (isCurrent ? AppColors.primaryYellow : AppColors.cardBorder),
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: isDone
                        ? AppColors.successGreen
                        : (isCurrent ? AppColors.primaryYellow : Colors.white12),
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.black)
                        : Text(
                            "${step.stepNumber}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.black : Colors.white60,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? step.titleAr : step.titleEn,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isCurrent ? AppColors.primaryYellow : AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? step.instructionAr : step.instructionEn,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        if (step.targetSpeedKmH > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Target Vehicle Speed: ${step.targetSpeedKmH} km/h steady",
                            style: const TextStyle(fontSize: 10, color: AppColors.electricBlue, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _isCalibratingRoad
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.play_arrow),
            label: Text(
              _isCalibratingRoad
                  ? (isAr ? "جارِ تنفيذ المعايرة..." : "Calibrating Sensor...")
                  : (_currentStepIndex >= _roadSteps.length - 1
                      ? (isAr ? "اكتملت معايرة ADAS بنجاح!" : "ADAS Calibration Completed!")
                      : (isAr ? "التقدم للخطوة التالية" : "Advance to Next Step")),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: _isCalibratingRoad || _currentStepIndex >= _roadSteps.length - 1 ? null : _executeNextRoadStep,
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF151B20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted))),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
