import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/analyzers/catalytic_health_analyzer.dart';
import '../providers/obd_state.dart';

/// Screen displaying real-time dual-waveform O2 sensor comparison and catalytic converter efficiency
class O2CatAnalyzerScreen extends StatelessWidget {
  const O2CatAnalyzerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final upVolts = state.o2B1S1History;
    final downVolts = state.o2B1S2History;

    final report = CatalyticHealthAnalyzer.analyze(
      upstreamVolts: upVolts,
      downstreamVolts: downVolts,
    );

    final upSpots = <FlSpot>[];
    for (int i = 0; i < upVolts.length; i++) {
      upSpots.add(FlSpot(i.toDouble(), upVolts[i]));
    }

    final downSpots = <FlSpot>[];
    for (int i = 0; i < downVolts.length; i++) {
      downSpots.add(FlSpot(i.toDouble(), downVolts[i]));
    }

    Color healthColor = AppColors.successGreen;
    if (report.efficiencyPercent < 70.0) {
      healthColor = AppColors.dangerRed;
    } else if (report.efficiencyPercent < 85.0) {
      healthColor = AppColors.primaryYellow;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.catalyticAnalyzer),
        actions: [
          IconButton(
            icon: Icon(state.isPolling ? Icons.pause_circle : Icons.play_circle),
            tooltip: state.isPolling ? "Pause Live Waveform" : "Start Live Waveform",
            onPressed: !state.isConnected ? null : () => state.toggleLivePolling(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Efficiency Gauge Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: healthColor.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Catalytic Converter Health",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.status,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: healthColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: healthColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: healthColor),
                        ),
                        child: Text(
                          "${report.efficiencyPercent.toInt()}% Efficiency",
                          style: TextStyle(color: healthColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: report.efficiencyPercent / 100.0,
                      minHeight: 10,
                      backgroundColor: Colors.black38,
                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricStat("Upstream Transitions", "${report.upstreamCrossCount}", AppColors.primaryYellow),
                      _buildMetricStat("Downstream Transitions", "${report.downstreamCrossCount}", AppColors.accentCyan),
                      _buildMetricStat("Switching Ratio", report.switchingRatio.toStringAsFixed(2), AppColors.electricBlue),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Waveform Comparison Chart
            Container(
              height: 240,
              padding: const EdgeInsets.fromLTRB(10, 16, 16, 10),
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
                        "Dual O2 Waveforms (0.0V - 1.0V)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.circle, color: AppColors.primaryYellow, size: 10),
                          SizedBox(width: 4),
                          Text("B1S1 (Upstream)", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          SizedBox(width: 10),
                          Icon(Icons.circle, color: AppColors.accentCyan, size: 10),
                          SizedBox(width: 4),
                          Text("B1S2 (Downstream)", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: upSpots.isEmpty
                        ? const Center(
                            child: Text(
                              "Tap Play button above to start live O2 sensor telemetry",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minY: 0.0,
                              maxY: 1.0,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 0.25,
                                getDrawingHorizontalLine: (val) => FlLine(color: Colors.white10, strokeWidth: 1),
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval: 0.25,
                                    getTitlesWidget: (val, meta) => Text(
                                      "${val.toStringAsFixed(2)}V",
                                      style: const TextStyle(color: AppColors.textDisabled, fontSize: 9),
                                    ),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: upSpots,
                                  isCurved: true,
                                  color: AppColors.primaryYellow,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                ),
                                LineChartBarData(
                                  spots: downSpots,
                                  isCurved: true,
                                  color: AppColors.accentCyan,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Diagnostic Narrative & Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Diagnostic Assessment:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow)),
                  const SizedBox(height: 6),
                  Text(report.diagnosis, style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.3)),
                  const SizedBox(height: 12),
                  const Text("Technician Action Guide:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan)),
                  const SizedBox(height: 6),
                  Text(report.recommendation, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
