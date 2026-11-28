import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../domain/analyzers/catalytic_health_analyzer.dart';
import '../providers/obd_state.dart';

/// Screen displaying real-time dual-waveform O2 sensor comparison and catalytic converter efficiency
class O2CatAnalyzerScreen extends StatelessWidget {
  const O2CatAnalyzerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        title: Text(l10n.o2Title),
        actions: [
          IconButton(
            icon: Icon(state.isPolling ? Icons.pause_circle : Icons.play_circle),
            tooltip: state.isPolling ? l10n.o2Pause : l10n.o2Start,
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
                          Text(
                            l10n.o2HealthTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _o2StatusText(l10n, report),
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
                          l10n.o2Efficiency(report.efficiencyPercent.toInt()),
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
                      _buildMetricStat(l10n.o2Upstream, "${report.upstreamCrossCount}", AppColors.primaryYellow),
                      _buildMetricStat(l10n.o2Downstream, "${report.downstreamCrossCount}", AppColors.accentCyan),
                      _buildMetricStat(l10n.o2Ratio, report.switchingRatio.toStringAsFixed(2), AppColors.electricBlue),
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
                      Text(
                        l10n.o2Waveforms,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.circle, color: AppColors.primaryYellow, size: 10),
                          const SizedBox(width: 4),
                          Text(l10n.o2UpstreamShort, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(width: 10),
                          const Icon(Icons.circle, color: AppColors.accentCyan, size: 10),
                          const SizedBox(width: 4),
                          Text(l10n.o2DownstreamShort, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: upSpots.isEmpty
                        ? Center(
                            child: Text(
                              l10n.o2TapPlay,
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
                  Text(l10n.o2Assessment, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow)),
                  const SizedBox(height: 6),
                  Text(_o2DiagnosisText(l10n, report), style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.3)),
                  const SizedBox(height: 12),
                  Text(l10n.o2Guide, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan)),
                  const SizedBox(height: 6),
                  Text(_o2RecText(l10n, report), style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.3)),
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

String _o2StatusText(AppLocalizations l10n, CatalyticHealthReport r) {
  switch (r.state) {
    case CatalyticHealthState.insufficientData:
      return l10n.o2StatusInsufficient;
    case CatalyticHealthState.excellent:
      return l10n.o2StatusExcellent;
    case CatalyticHealthState.aging:
      return l10n.o2StatusAging;
    case CatalyticHealthState.failing:
      return l10n.o2StatusFailing;
  }
}

String _o2DiagnosisText(AppLocalizations l10n, CatalyticHealthReport r) {
  switch (r.state) {
    case CatalyticHealthState.insufficientData:
      return l10n.o2DiagInsufficient;
    case CatalyticHealthState.excellent:
      return l10n.o2DiagExcellent(r.upstreamCrossCount, r.avgDownstreamVoltage.toStringAsFixed(2));
    case CatalyticHealthState.aging:
      return l10n.o2DiagAging(r.downstreamCrossCount, r.upstreamCrossCount, (100 - r.efficiencyPercent).toStringAsFixed(0));
    case CatalyticHealthState.failing:
      return l10n.o2DiagFailing((r.switchingRatio * 100).toStringAsFixed(0));
  }
}

String _o2RecText(AppLocalizations l10n, CatalyticHealthReport r) {
  switch (r.state) {
    case CatalyticHealthState.insufficientData:
      return l10n.o2RecInsufficient;
    case CatalyticHealthState.excellent:
      return l10n.o2RecExcellent;
    case CatalyticHealthState.aging:
      return l10n.o2RecAging;
    case CatalyticHealthState.failing:
      return l10n.o2RecFailing;
  }
}
