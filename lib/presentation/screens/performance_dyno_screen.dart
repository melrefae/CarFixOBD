import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/analyzers/dyno_performance_calculator.dart';
import '../providers/obd_state.dart';

/// Screen displaying 0-100 km/h acceleration timer, quarter-mile drag strip, and dyno horsepower meter
class PerformanceDynoScreen extends StatefulWidget {
  const PerformanceDynoScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceDynoScreen> createState() => _PerformanceDynoScreenState();
}

class _PerformanceDynoScreenState extends State<PerformanceDynoScreen> {
  double _curbWeightKg = 1200.0;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final dyno = state.dynoCalculator;

    Color runColor = AppColors.primaryYellow;
    String statusTitle = "ARMED: Stop vehicle completely to begin";
    if (dyno.state == PerformanceRunState.accelerating) {
      runColor = AppColors.dangerRed;
      statusTitle = "ACCELERATING: Floor the accelerator!";
    } else if (dyno.state == PerformanceRunState.completed) {
      runColor = AppColors.successGreen;
      statusTitle = "RUN COMPLETED: 0-100 km/h Recorded!";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.performanceDyno),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Performance Timers",
            onPressed: () => setState(() => dyno.reset()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: runColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: runColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: runColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      statusTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: runColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Hero 0-100 Timer Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263238), Color(0xFF192024)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    "0 – 100 km/h (0 – 62 mph)",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dyno.zeroToHundredSec != null ? "${dyno.zeroToHundredSec!.toStringAsFixed(2)}s" : "--.-s",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimerStat("0-60 km/h Split", dyno.zeroToSixtySec != null ? "${dyno.zeroToSixtySec!.toStringAsFixed(2)}s" : "--.-s", AppColors.electricBlue),
                      _buildTimerStat("Distance Covered", "${dyno.distanceMeters.toStringAsFixed(0)} m", AppColors.textWhite),
                      _buildTimerStat("Max Speed", "${dyno.maxRecordedSpeedKmh.toStringAsFixed(0)} km/h", AppColors.accentCyan),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quarter Mile & Braking Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("400m Quarter Mile", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Text(
                          dyno.quarterMileSec != null ? "${dyno.quarterMileSec!.toStringAsFixed(2)}s" : "--.-s",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                        Text(
                          dyno.quarterMileTrapSpeedKmh != null ? "Trap: ${dyno.quarterMileTrapSpeedKmh!.toStringAsFixed(0)} km/h" : "Trap: -- km/h",
                          style: const TextStyle(fontSize: 11, color: AppColors.accentCyan),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("100 – 0 Braking", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 6),
                        Text(
                          dyno.brakingDistanceMeters != null ? "${dyno.brakingDistanceMeters!.toStringAsFixed(1)} m" : "--.- m",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.dangerRed),
                        ),
                        const Text("Emergency Stop", style: TextStyle(fontSize: 11, color: AppColors.textDisabled)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dyno Power & Torque Estimation Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Estimated Dyno Power & Torque:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Weight: ${_curbWeightKg.toInt()} kg",
                          style: const TextStyle(fontSize: 11, color: AppColors.electricBlue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            dyno.peakWheelHp > 0 ? "${dyno.peakWheelHp.toInt()} WHP" : "-- WHP",
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                          ),
                          const SizedBox(height: 2),
                          const Text("Peak Wheel Horsepower", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            dyno.peakTorqueNm > 0 ? "${dyno.peakTorqueNm.toInt()} N·m" : "-- N·m",
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                          ),
                          const SizedBox(height: 2),
                          const Text("Peak Engine Torque", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 8),
                  Text("Adjust Vehicle Weight (${_curbWeightKg.toInt()} kg):", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Slider(
                    value: _curbWeightKg,
                    min: 800.0,
                    max: 2800.0,
                    divisions: 40,
                    activeColor: AppColors.primaryYellow,
                    inactiveColor: Colors.black38,
                    onChanged: (val) => setState(() => _curbWeightKg = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
