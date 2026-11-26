import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/sensor_pid.dart';

/// High-contrast live gauge tile for an OBD-II sensor PID
class SensorGaugeCard extends StatelessWidget {
  final SensorPid sensor;
  final VoidCallback? onTap;

  const SensorGaugeCard({Key? key, required this.sensor, this.onTap}) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Engine':
        return AppColors.primaryYellow;
      case 'Cooling':
        return AppColors.electricBlue;
      case 'FuelAir':
        return AppColors.warningOrange;
      case 'Electrical':
        return AppColors.successGreen;
      default:
        return AppColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = !sensor.isSupported
        ? AppColors.textDisabled
        : _getCategoryColor(sensor.category);
    final range = (sensor.max - sensor.min).clamp(1.0, 99999.0);
    final normalized = sensor.hasValidReading
        ? ((sensor.currentValue - sensor.min) / range).clamp(0.0, 1.0)
        : 0.0;

    final String readoutText = !sensor.isSupported
        ? "N/A"
        : (!sensor.hasValidReading
            ? "--"
            : sensor.currentValue.toStringAsFixed(sensor.unit == "RPM" ? 0 : 1));

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sensor name and category indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: sensor.isSupported ? AppColors.textWhite : AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          sensor.isSupported
                              ? "Mode ${sensor.mode} 0x${sensor.pid} • ${sensor.category}"
                              : "0x${sensor.pid} • Unsupported by ECU",
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: sensor.hasValidReading
                          ? AppColors.successGreen
                          : (sensor.isSupported ? catColor.withOpacity(0.5) : AppColors.textDisabled),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Large numeric readout and unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    readoutText,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: sensor.hasValidReading ? catColor : AppColors.textDisabled,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sensor.isSupported ? (sensor.hasValidReading ? sensor.unit : "Waiting...") : "",
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Relative progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: normalized,
                  backgroundColor: AppColors.cardSurfaceHighlight,
                  valueColor: AlwaysStoppedAnimation<Color>(catColor),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 4),

              // Min and max range values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${sensor.min.toInt()} ${sensor.unit}", style: const TextStyle(fontSize: 9, color: AppColors.textDisabled)),
                  Text("${sensor.max.toInt()} ${sensor.unit}", style: const TextStyle(fontSize: 9, color: AppColors.textDisabled)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
