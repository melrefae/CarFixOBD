import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/readiness_monitors.dart';
import '../providers/obd_state.dart';

/// I/M Readiness Monitors screen (OBD-II Mode 01 PID 01)
/// Critical inspection indicator to verify drive cycle completion and detect recent DTC clears
class ReadinessMonitorsScreen extends StatefulWidget {
  const ReadinessMonitorsScreen({Key? key}) : super(key: key);

  @override
  State<ReadinessMonitorsScreen> createState() => _ReadinessMonitorsScreenState();
}

class _ReadinessMonitorsScreenState extends State<ReadinessMonitorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObdState>(context, listen: false).fetchReadinessMonitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final rm = state.readinessMonitors;

    int completedCount = 0;
    int incompleteCount = 0;

    if (rm != null) {
      for (var m in rm.monitors) {
        if (m.isAvailable) {
          if (m.isComplete) {
            completedCount++;
          } else {
            incompleteCount++;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).readinessMonitors),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).refreshReadiness,
            onPressed: state.isScanning ? null : () => state.fetchReadinessMonitors(),
          ),
        ],
      ),
      body: state.isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryYellow),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context).readinessQuerying, style: TextStyle(color: AppColors.textWhite)),
                ],
              ),
            )
          : rm == null || rm.monitors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.rule_folder_outlined, size: 64, color: AppColors.textDisabled),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context).readinessNoData, style: TextStyle(color: AppColors.textWhite)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Readiness summary banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: incompleteCount == 0 ? AppColors.successGreen.withOpacity(0.15) : AppColors.warningOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: incompleteCount == 0 ? AppColors.successGreen : AppColors.warningOrange,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              incompleteCount == 0 ? Icons.check_circle : Icons.pending_actions,
                              color: incompleteCount == 0 ? AppColors.successGreen : AppColors.warningOrange,
                              size: 40,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    incompleteCount == 0 ? AppLocalizations.of(context).readinessAllReady : AppLocalizations.of(context).readinessIncomplete('$incompleteCount'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: incompleteCount == 0 ? AppColors.successGreen : AppColors.warningOrange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context).readinessSummary('$completedCount', '$incompleteCount', rm.milOn ? AppLocalizations.of(context).milOn : AppLocalizations.of(context).milOff),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Inspection Tip Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceHighlight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primaryYellow, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).readinessTip,
                                style: TextStyle(fontSize: 11, color: AppColors.textWhite, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        AppLocalizations.of(context).readinessSubtitle,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
                      ),
                      const SizedBox(height: 10),

                      ...rm.monitors.map((m) => _buildMonitorCard(m)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMonitorCard(MonitorStatus m) {
    Color badgeColor = AppColors.textDisabled;
    String badgeText = AppLocalizations.of(context).badgeUnsupported;

    if (m.isAvailable) {
      if (m.isComplete) {
        badgeColor = AppColors.successGreen;
        badgeText = AppLocalizations.of(context).badgeReady;
      } else {
        badgeColor = AppColors.warningOrange;
        badgeText = AppLocalizations.of(context).badgeIncomplete;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              m.isAvailable && m.isComplete ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              color: badgeColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite)),
                  Text(m.explanation, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor),
              ),
              child: Text(
                badgeText,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
