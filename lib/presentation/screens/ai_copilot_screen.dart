import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/analyzers/ai_diagnostic_copilot.dart';
import '../providers/obd_state.dart';
import 'actuator_tests_screen.dart';
import 'o2_cat_analyzer_screen.dart';
import 'live_graph_screen.dart';
import 'vehicle_profiles_screen.dart';

/// Screen displaying AI Diagnostic Copilot recommendations, hypothesis, and mechanic roadmap
class AiCopilotScreen extends StatelessWidget {
  const AiCopilotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    final vehicleName = state.selectedVehicle != null
        ? "${state.selectedVehicle!.make} ${state.selectedVehicle!.model} (${state.selectedVehicle!.years})"
        : "Generic OBD-II Vehicle";

    final dtcList = state.storedDtcs.map((d) => d.code).toList();
    final ltft = state.getSensor('0107')?.numValue ?? state.getSensor('0106')?.numValue;
    final stft = state.getSensor('0106')?.numValue;
    final coolantTemp = state.getSensor('0105')?.numValue;
    final batteryVolts = state.batteryVoltage;
    final mapKpa = state.getSensor('010B')?.numValue;

    final report = AiDiagnosticCopilot.generateDiagnosis(
      vehicleMakeModel: vehicleName,
      dtcCodes: dtcList,
      ltft: ltft,
      stft: stft,
      coolantTemp: coolantTemp,
      batteryVoltage: batteryVolts > 0 ? batteryVolts : null,
      mapKpa: mapKpa,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aiCopilot),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: "Copy Report Summary",
            onPressed: () {
              final text = StringBuffer();
              text.writeln("=== AI DIAGNOSTIC COPILOT REPORT ===");
              text.writeln("Vehicle: ${report.vehicleTitle}");
              text.writeln("Primary Hypothesis: ${report.primaryHypothesis} (${report.probabilityPercent}% Confidence)");
              text.writeln("Urgency: ${report.urgencyLevel}");
              text.writeln("\nKey Evidence:");
              for (final ev in report.evidenceList) {
                text.writeln(" - $ev");
              }
              text.writeln("\nMechanic Roadmap:");
              for (final step in report.roadmap) {
                text.writeln(" Step ${step.stepNumber}: ${step.title} [Tool: ${step.toolRequired}]");
                text.writeln("   Action: ${step.action}");
                text.writeln("   Expected Good Value: ${step.expectedGoodValue}");
              }
              text.writeln("\nEgyptian Workshop Bulletin:\n${report.egyptWorkshopBulletin}");

              Clipboard.setData(ClipboardData(text: text.toString()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("AI Diagnostic Report copied to clipboard"),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Context Banner
            _buildVehicleBanner(context, state, vehicleName),

            const SizedBox(height: 16),

            // Primary Hypothesis Card
            _buildHypothesisCard(report),

            const SizedBox(height: 16),

            // Key Evidence Card
            _buildEvidenceCard(report),

            const SizedBox(height: 16),

            // Step-by-Step Diagnostic Roadmap
            _buildRoadmapSection(report),

            const SizedBox(height: 16),

            // Egyptian Workshop Bulletin Card
            _buildEgyptianBulletinCard(report),

            const SizedBox(height: 16),

            // Quick Diagnostic Action Shortcuts
            _buildDiagnosticShortcuts(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleBanner(BuildContext context, ObdState state, String vehicleName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: AppColors.primaryYellow, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  state.isConnected
                      ? "Live Telemetry Connected • ${state.storedDtcs.length} Active DTCs"
                      : "Offline Mode • Connect OBD adapter for live streaming",
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VehicleProfilesScreen()),
              );
            },
            child: const Text("CHANGE", style: TextStyle(color: AppColors.primaryYellow, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHypothesisCard(AiDiagnosticReport report) {
    Color probColor = AppColors.successGreen;
    if (report.probabilityPercent < 60) {
      probColor = AppColors.textMuted;
    } else if (report.probabilityPercent < 80) {
      probColor = AppColors.primaryYellow;
    } else {
      probColor = AppColors.dangerRed;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryYellow, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Primary Diagnostic Hypothesis",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: probColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: probColor),
                ),
                child: Text(
                  "${report.probabilityPercent}% Match",
                  style: TextStyle(
                    color: probColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.primaryHypothesis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warningOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.urgencyLevel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.warningOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(AiDiagnosticReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist, color: AppColors.electricBlue, size: 20),
              SizedBox(width: 8),
              Text(
                "Correlated Live Evidence & Telemetry",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...report.evidenceList.map(
            (evidence) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.primaryAmber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      evidence,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection(AiDiagnosticReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: AppColors.successGreen, size: 20),
              SizedBox(width: 8),
              Text(
                "4-Step Workshop Diagnostic Roadmap",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...report.roadmap.map((step) => _buildRoadmapStepTile(step)),
        ],
      ),
    );
  }

  Widget _buildRoadmapStepTile(DiagnosticRoadmapStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryYellow,
                child: Text(
                  "${step.stepNumber}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.handyman, size: 11, color: AppColors.electricBlue),
                    const SizedBox(width: 4),
                    Text(
                      step.toolRequired,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.action,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.successGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Expected Good Value: ${step.expectedGoodValue}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEgyptianBulletinCard(AiDiagnosticReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryAmber.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.build_circle, color: AppColors.primaryAmber, size: 20),
              SizedBox(width: 8),
              Text(
                "Egyptian Workshop Technical Bulletin",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.egyptWorkshopBulletin,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Next Workshop Actions:",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text("Actuator Tests", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ActuatorTestsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.speed, size: 16),
                label: const Text("Cat Analyzer", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const O2CatAnalyzerScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.show_chart, size: 16),
                label: const Text("Live Graphs", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LiveGraphScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
