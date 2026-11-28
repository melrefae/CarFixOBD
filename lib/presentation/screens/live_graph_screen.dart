import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../data/models/sensor_pid.dart';
import '../providers/obd_state.dart';

/// راسم الإشارة اللحظي (Oscilloscope) ومقارنة إشارات الحساسات المزدوجة
class LiveGraphScreen extends StatefulWidget {
  final String? initialSensorPid;

  const LiveGraphScreen({Key? key, this.initialSensorPid}) : super(key: key);

  @override
  State<LiveGraphScreen> createState() => _LiveGraphScreenState();
}

class _LiveGraphScreenState extends State<LiveGraphScreen> {
  late String _channel1Pid;
  String? _channel2Pid; // القناة الثانية للمقارنة المزدوجة
  bool _dualChannelMode = false;

  @override
  void initState() {
    super.initState();
    _channel1Pid = widget.initialSensorPid ?? "0C"; // RPM افتراضياً
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    final sensor1 = state.sensors.firstWhere(
      (s) => s.pid == _channel1Pid,
      orElse: () => state.sensors.first,
    );

    final sensor2 = _channel2Pid != null
        ? state.sensors.firstWhere(
            (s) => s.pid == _channel2Pid,
            orElse: () => state.sensors[1],
          )
        : null;

    final isAr = state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).liveGraphsTitle),
        actions: [
          IconButton(
            icon: Icon(
              _dualChannelMode ? Icons.splitscreen : Icons.crop_square,
              color: _dualChannelMode ? AppColors.primaryYellow : AppColors.textMuted,
            ),
            tooltip: _dualChannelMode
                ? AppLocalizations.of(context).disableDual
                : AppLocalizations.of(context).enableDual,
            onPressed: () {
              setState(() {
                _dualChannelMode = !_dualChannelMode;
                if (_dualChannelMode && _channel2Pid == null) {
                  // Auto suggest comparison sensor
                  if (_channel1Pid == "14") {
                    _channel2Pid = "15";
                  } else if (_channel1Pid == "11") {
                    _channel2Pid = "0B"; // TPS with MAP
                  } else {
                    _channel2Pid = "0D"; // Speed with RPM
                  }
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sensor selector 1
            _buildSensorSelector(
              label: AppLocalizations.of(context).channel1,
              currentPid: _channel1Pid,
              sensors: state.sensors,
              color: AppColors.primaryYellow,
              isAr: isAr,
              onChanged: (newPid) {
                if (newPid != null) {
                  setState(() {
                    _channel1Pid = newPid;
                  });
                }
              },
            ),

            if (_dualChannelMode) ...[
              const SizedBox(height: 8),
              // Sensor selector 2
              _buildSensorSelector(
                label: AppLocalizations.of(context).channel2,
                currentPid: _channel2Pid ?? state.sensors.last.pid,
                sensors: state.sensors,
                color: AppColors.electricBlue,
                isAr: isAr,
                onChanged: (newPid) {
                  if (newPid != null) {
                    setState(() {
                      _channel2Pid = newPid;
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 16),

            // Metric badges
            Row(
              children: [
                Expanded(
                  child: _buildMetricBadge(
                    sensor: sensor1,
                    color: AppColors.primaryYellow,
                    isAr: isAr,
                  ),
                ),
                if (_dualChannelMode && sensor2 != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricBadge(
                      sensor: sensor2,
                      color: AppColors.electricBlue,
                      isAr: isAr,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // مساحة راسم الإشارة (Waveform Chart)
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 20, 10),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF263238)),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 5,
                      getDrawingHorizontalLine: (val) => const FlLine(color: Color(0xFF1E2838), strokeWidth: 1),
                      getDrawingVerticalLine: (val) => const FlLine(color: Color(0xFF1E2838), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(color: AppColors.textDisabled, fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // خط القناة الأولى
                      _buildLineBarData(sensor1.history, AppColors.primaryYellow),
                      // خط القناة الثانية إن كانت مفعلة
                      if (_dualChannelMode && sensor2 != null)
                        _buildLineBarData(sensor2.history, AppColors.electricBlue),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<double> history, Color color) {
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i]));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.8,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.08),
      ),
    );
  }

  Widget _buildSensorSelector({
    required String label,
    required String currentPid,
    required List<SensorPid> sensors,
    required Color color,
    required bool isAr,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceHighlight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentPid,
                isExpanded: true,
                dropdownColor: AppColors.cardSurface,
                items: sensors.map((s) {
                  final name = isAr ? s.nameAr : s.name;
                  return DropdownMenuItem<String>(
                    value: s.pid,
                    child: Text("$name (${s.unit})", style: const TextStyle(fontSize: 12, color: Colors.white)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBadge({required SensorPid sensor, required Color color, required bool isAr}) {
    final name = isAr ? sensor.nameAr : sensor.name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(
            "${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
