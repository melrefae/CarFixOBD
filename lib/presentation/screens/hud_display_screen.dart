import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/obd_state.dart';

/// Night Heads-Up Display (HUD) Mode with windshield reflection mirror flip
class HudDisplayScreen extends StatefulWidget {
  const HudDisplayScreen({Key? key}) : super(key: key);

  @override
  State<HudDisplayScreen> createState() => _HudDisplayScreenState();
}

class _HudDisplayScreenState extends State<HudDisplayScreen> {
  bool _isMirrored = true;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    double speed = 0.0;
    double rpm = 0.0;
    double coolant = 85.0;
    double voltage = state.batteryVoltage;

    for (var s in state.sensors) {
      if (s.pid == "0D") speed = s.currentValue;
      if (s.pid == "0C") rpm = s.currentValue;
      if (s.pid == "05") coolant = s.currentValue;
      if (s.pid == "42") voltage = s.currentValue;
    }

    final isCoolantCritical = coolant >= 105.0;
    final isVoltageCritical = voltage <= 11.8;

    Widget hudContent = Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Controls Bar (Non-mirrored or mirrored with toggle)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow),
                      backgroundColor: Colors.black,
                    ),
                    icon: Icon(_isMirrored ? Icons.flip : Icons.smartphone, size: 18),
                    label: Text(_isMirrored ? "Windshield Mirror: ON" : "Normal Mode"),
                    onPressed: () => setState(() => _isMirrored = !_isMirrored),
                  ),
                ],
              ),

              // Giant Speed Display
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    speed.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 140,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                      fontFamily: 'monospace',
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    "KM / H",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              // Bottom Gauges (RPM, Coolant, Voltage)
              Column(
                children: [
                  // RPM Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (rpm / 7000.0).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        rpm >= 5500 ? AppColors.dangerRed : AppColors.accentCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric(
                        label: "ENGINE RPM",
                        value: rpm.toInt().toString(),
                        color: rpm >= 5500 ? AppColors.dangerRed : AppColors.accentCyan,
                      ),
                      _buildMetric(
                        label: "COOLANT",
                        value: "${coolant.toInt()}°C",
                        color: isCoolantCritical ? AppColors.dangerRed : Colors.white,
                      ),
                      _buildMetric(
                        label: "BATTERY",
                        value: "${voltage.toStringAsFixed(1)}V",
                        color: isVoltageCritical ? AppColors.dangerRed : AppColors.successGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (_isMirrored) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationX(3.1415926535), // Invert vertically for windshield glass reflection
        child: hudContent,
      );
    }

    return hudContent;
  }

  Widget _buildMetric({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white54, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
