import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/hex_parser.dart';
import '../providers/obd_state.dart';

/// Live SAE J1979 Mode $06 Non-Continuous Component & Cylinder Misfire Test Monitor
class Mode06MonitorScreen extends StatefulWidget {
  const Mode06MonitorScreen({Key? key}) : super(key: key);

  @override
  State<Mode06MonitorScreen> createState() => _Mode06MonitorScreenState();
}

class _Mode06MonitorScreenState extends State<Mode06MonitorScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<ObdState>(context, listen: false);
      if (state.isConnected && state.mode06Results.isEmpty && !state.isScanningMode06) {
        state.fetchMode06Monitors();
      }
    });
  }

  int _filterIndex = 0;

  List<Mode06TestResult> _applyFilter(List<Mode06TestResult> raw) {
    switch (_filterIndex) {
      case 1:
        return raw.where((r) => r.mid >= 0xA1 && r.mid <= 0xA9).toList();
      case 2:
        return raw.where((r) => (r.mid >= 0x01 && r.mid <= 0x08) || r.mid == 0x21 || r.mid == 0x22).toList();
      case 3:
        return raw.where((r) => !r.isPassed && !r.noResult && r.hasLimits).toList();
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final results = _applyFilter(state.mode06Results);
    final total = state.mode06Results.length;
    final failedCount = state.mode06Results.where((r) => !r.isPassed && !r.noResult && r.hasLimits).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).mode06Title),
        actions: [
          IconButton(
            icon: state.isScanningMode06
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryYellow),
                  )
                : const Icon(Icons.refresh, color: AppColors.primaryYellow),
            tooltip: AppLocalizations.of(context).mode06ScanTooltip,
            onPressed: state.isConnected && !state.isScanningMode06
                ? () => state.fetchMode06Monitors()
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.mode06Note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(state.mode06Note, style: const TextStyle(fontSize: 12, color: AppColors.warningOrange)),
            ),
          // Summary Banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: failedCount > 0 ? AppColors.dangerRed : AppColors.accentCyan.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  failedCount > 0 ? Icons.warning_amber_rounded : Icons.analytics_outlined,
                  color: failedCount > 0 ? AppColors.dangerRed : AppColors.accentCyan,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).mode06Summary('$total', '$failedCount'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        AppLocalizations.of(context).mode06Subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                for (final (i, label) in [AppLocalizations.of(context).filterAll, AppLocalizations.of(context).filterMisfires, AppLocalizations.of(context).filterO2Cat, AppLocalizations.of(context).filterFailedOnly].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filterIndex == i,
                      selectedColor: AppColors.primaryYellow,
                      backgroundColor: AppColors.cardSurface,
                      labelStyle: TextStyle(
                        color: _filterIndex == i ? Colors.black : AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (v) {
                        if (v) setState(() => _filterIndex = i);
                      },
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: !state.isConnected
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppLocalizations.of(context).mode06ConnectFirst,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                : state.isScanningMode06
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(color: AppColors.primaryYellow),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).mode06Scanning,
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.info_outline, size: 42, color: AppColors.textDisabled),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context).mode06NoResults,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: Text(AppLocalizations.of(context).mode06Rescan),
                                    onPressed: () => state.fetchMode06Monitors(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: results.length,
                            itemBuilder: (context, index) => _buildTestCard(results[index]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(Mode06TestResult r) {
    final l10n = AppLocalizations.of(context);
    final String status = r.noResult ? l10n.statusNoResult : (!r.hasLimits ? l10n.statusInfo : (r.isPassed ? l10n.statusPass : l10n.statusFail));
    final color = r.noResult || !r.hasLimits ? AppColors.textMuted : (r.isPassed ? AppColors.successGreen : AppColors.dangerRed);
    String fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : (v.abs() < 1 ? v.toStringAsFixed(4) : v.toStringAsFixed(2));
    final span = (r.maxLimit - r.minLimit).abs();
    final ratio = span > 0 ? ((r.measuredValue - r.minLimit) / span).clamp(0.0, 1.0) : (r.isPassed ? 0.1 : 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(r.noResult || !r.hasLimits ? Icons.info_outline : (r.isPassed ? Icons.check_circle : Icons.error), color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.monitorName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${r.source} • ${r.source == 'Mode 05' ? l10n.sensorWord : 'MID'} ${r.midHex} • TID ${r.tidHex}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  "${fmt(r.measuredValue)} ${r.scalingKnown ? r.unit : l10n.rawUnit}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.cardSurfaceHighlight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.hasLimits ? l10n.minLimitLabel(fmt(r.minLimit), r.unit) : (r.noResult ? l10n.neverCompleted : l10n.constantNoLimits),
                    style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
                Text(r.hasLimits ? l10n.maxLimitLabel(fmt(r.maxLimit), r.unit) : "",
                    style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
