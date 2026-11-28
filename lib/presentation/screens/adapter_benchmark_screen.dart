import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../providers/obd_state.dart';

/// ELM327 adapter authenticity, speed, and latency benchmark screen
class AdapterBenchmarkScreen extends StatefulWidget {
  const AdapterBenchmarkScreen({Key? key}) : super(key: key);

  @override
  State<AdapterBenchmarkScreen> createState() => _AdapterBenchmarkScreenState();
}

class _AdapterBenchmarkScreenState extends State<AdapterBenchmarkScreen> {
  bool _isRunning = false;
  String _firmwareVersion = "--";
  String _chipIdentifier = "--";
  String _voltageReading = "--";
  String _activeProtocol = "--";

  int _avgLatencyMs = 0;
  int _minLatencyMs = 0;
  int _maxLatencyMs = 0;
  double _successRate = 0.0;
  String? _authenticityResult;
  Color _authenticityColor = AppColors.textMuted;

  final List<String> _testLogs = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.benchTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Evaluation & Authenticity Result Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _authenticityColor.withOpacity(0.6), width: 2),
              ),
              child: Column(
                children: [
                  Icon(
                    _authenticityColor == AppColors.successGreen
                        ? Icons.verified
                        : _authenticityColor == AppColors.warningOrange
                            ? Icons.warning_amber
                            : Icons.speed,
                    size: 54,
                    color: _authenticityColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _authenticityResult ?? l10n.benchTapToStart,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _authenticityColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRunning
                        ? l10n.benchRunningDesc
                        : l10n.benchIdleDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Speed & Latency Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricBox(
                    title: l10n.benchAvg,
                    value: _avgLatencyMs > 0 ? "$_avgLatencyMs ${l10n.unitMs}" : "--",
                    color: _avgLatencyMs < 45 && _avgLatencyMs > 0 ? AppColors.successGreen : AppColors.primaryYellow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    title: l10n.benchBest,
                    value: _minLatencyMs > 0 ? "$_minLatencyMs ${l10n.unitMs}" : "--",
                    color: AppColors.electricBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    title: l10n.benchMax,
                    value: _maxLatencyMs > 0 ? "$_maxLatencyMs ${l10n.unitMs}" : "--",
                    color: _maxLatencyMs > 100 ? AppColors.dangerRed : AppColors.accentCyan,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricBox(
                    title: l10n.benchSuccess,
                    value: _successRate > 0 ? "${_successRate.toInt()}%" : "--",
                    color: _successRate >= 90 ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Hardware Profile Details
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
                  Text(
                    l10n.benchHwProfile,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(l10n.benchFirmware, _firmwareVersion),
                  _buildDetailRow(l10n.benchChip, _chipIdentifier),
                  _buildDetailRow(l10n.benchVoltage, _voltageReading),
                  _buildDetailRow(l10n.benchProtocol, _activeProtocol),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Run Benchmark Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isRunning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isRunning ? l10n.benchRunning : l10n.benchStart,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _isRunning || !state.isConnected ? null : () => _runBenchmark(state),
              ),
            ),

            if (!state.isConnected) ...[
              const SizedBox(height: 8),
              Text(
                l10n.benchNeedConnection,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.dangerRed, fontSize: 13),
              ),
            ],

            const SizedBox(height: 20),

            // Benchmark Logs
            if (_testLogs.isNotEmpty) ...[
              Text(
                l10n.benchLogTitle,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ListView.builder(
                  itemCount: _testLogs.length,
                  itemBuilder: (context, i) => Text(
                    _testLogs[i],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.accentCyan),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Future<void> _runBenchmark(ObdState state) async {
    final l10n = AppLocalizations.of(context);
    final driver = state.driver;
    if (driver == null) return;

    setState(() {
      _isRunning = true;
      _testLogs.clear();
      _authenticityResult = l10n.benchLogRunning;
      _authenticityColor = AppColors.primaryYellow;
    });

    try {
      // 1. Identification queries
      _log(l10n.benchLogAti);
      final ati = await driver.sendCommand("ATI");
      _firmwareVersion = ati.trim().isNotEmpty ? ati.trim() : "ELM327 v1.5";
      _log("<- $ati");

      _log(l10n.benchLogAt1);
      final at1 = await driver.sendCommand("AT@1");
      _chipIdentifier = at1.trim().isNotEmpty ? at1.trim() : "OBDII Device";
      _log("<- $at1");

      _log(l10n.benchLogAtrv);
      final atrv = await driver.sendCommand("ATRV");
      _voltageReading = atrv.trim().isNotEmpty ? atrv.trim() : "12.6V";
      _log("<- $atrv");

      _log(l10n.benchLogAtdp);
      final atdp = await driver.sendCommand("ATDP");
      _activeProtocol = atdp.trim().isNotEmpty ? atdp.trim() : "ISO 15765-4 (CAN)";
      _log("<- $atdp");

      // 2. Latency test (10 Pings)
      List<int> latencies = [];
      int successfulPackets = 0;

      for (int i = 1; i <= 10; i++) {
        final stopwatch = Stopwatch()..start();
        final res = await driver.sendCommand("0100");
        stopwatch.stop();

        final elapsed = stopwatch.elapsedMilliseconds;
        latencies.add(elapsed);

        if (res.isNotEmpty && !res.contains("NO DATA") && !res.contains("ERROR")) {
          successfulPackets++;
          _log(l10n.benchPingOk(i, elapsed));
        } else {
          _log(l10n.benchPingFail(i, elapsed));
        }

        await Future.delayed(const Duration(milliseconds: 30));
      }

      latencies.sort();
      _minLatencyMs = latencies.first;
      _maxLatencyMs = latencies.last;
      _avgLatencyMs = (latencies.reduce((a, b) => a + b) / latencies.length).round();
      _successRate = (successfulPackets / 10.0) * 100.0;

      // Evaluation
      if (_avgLatencyMs <= 45 && _successRate >= 90) {
        _authenticityResult = l10n.benchResultExcellent;
        _authenticityColor = AppColors.successGreen;
      } else if (_avgLatencyMs <= 85 && _successRate >= 80) {
        _authenticityResult = l10n.benchResultStandard;
        _authenticityColor = AppColors.primaryYellow;
      } else {
        _authenticityResult = l10n.benchResultClone;
        _authenticityColor = AppColors.dangerRed;
      }
    } catch (e) {
      _log(l10n.benchLogError("$e"));
      _authenticityResult = l10n.benchInterrupted("$e");
      _authenticityColor = AppColors.dangerRed;
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  void _log(String msg) {
    if (mounted) {
      setState(() {
        _testLogs.add(msg);
      });
    }
  }
}
