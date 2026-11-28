import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_ar.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/full_test_result.dart';
import '../../domain/exporters/pdf_report_generator.dart';
import '../providers/obd_state.dart';
import 'vehicle_profiles_screen.dart';
import 'reports_screen.dart';
import '../widgets/dtc_repair_guide_modal.dart';
import '../widgets/stage_detail_modal.dart';

/// 1-Click Comprehensive Vehicle Health & Diagnostics Screen
class FullVehicleTestScreen extends StatefulWidget {
  const FullVehicleTestScreen({Key? key}) : super(key: key);

  @override
  State<FullVehicleTestScreen> createState() => _FullVehicleTestScreenState();
}

class _FullVehicleTestScreenState extends State<FullVehicleTestScreen> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _startTest(ObdState state) async {
    try {
      await state.runFullSystemHealthTest(
        onProgress: (stage, name, progress, detail) {
          if (mounted) setState(() {});
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text(
              state.isArabic
                  ? "اكتمل الفحص الشامل بنجاح وتم حفظ التقرير بسجلات المركز!"
                  : "Full system test completed and saved to workshop reports!",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.errorRed,
            content: Text(
              state.isArabic
                  ? "حدث خطأ أثناء الفحص: $e"
                  : "Diagnostic scan encountered an error: $e",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final selectedVehicle = state.selectedVehicle;
    final lastResult = state.lastFullTestResult;
    final isRunning = state.isRunningFullTest;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? AppStringsAr.fullVehicleTest : AppStrings.fullVehicleTest),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: isAr ? AppStringsAr.inspectionReports : AppStrings.inspectionReports,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Vehicle Profile Header Card
          _buildVehicleCard(context, state, isAr, selectedVehicle),
          const SizedBox(height: 16),

          // Hero CTA Action Area
          _buildHeroCta(context, state, isAr, isRunning),
          const SizedBox(height: 16),

          // Health Index Summary (if test finished or available)
          if (lastResult != null && !isRunning) ...[
            _buildHealthScoreCard(context, lastResult, isAr),
            const SizedBox(height: 16),
            _buildSubsystemsGrid(context, lastResult, isAr),
            const SizedBox(height: 16),
            _buildActionButtons(context, state, lastResult, isAr),
            const SizedBox(height: 20),
          ],

          // 10-Stage Diagnostic Matrix
          _buildStageMatrixHeader(isAr, isRunning, state.fullTestProgress),
          const SizedBox(height: 8),
          _buildStagesList(state, isAr, isRunning),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    ObdState state,
    bool isAr,
    dynamic vehicle,
  ) {
    final vehicleTitle = vehicle != null
        ? vehicle.getDisplayName(isAr)
        : (isAr ? "سيارة عامة (OBD-II القياسي)" : "Generic Vehicle (Standard OBD-II)");
    final engine = vehicle?.engine ?? "All Engines";
    final transmission = vehicle?.transmission ?? "Manual / Auto";
    final protocol = vehicle?.protocol ?? (state.isConnected ? state.activeProtocol : "Auto-Detect");

    return Card(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.accentBlue.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car, color: AppColors.accentBlue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$engine • $transmission",
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: Text(
                    isAr ? "تغيير" : "Change",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehicleProfilesScreen()),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cable, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      protocol,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: state.isConnected
                        ? AppColors.successGreen.withOpacity(0.2)
                        : AppColors.warningAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.isConnected ? Icons.check_circle : Icons.sensors,
                        size: 12,
                        color: state.isConnected ? AppColors.successGreen : AppColors.warningAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.isConnected
                            ? (isAr ? "الفيشة متصلة" : "OBD Connected")
                            : (isAr ? "غير متصل بالفيشة" : "OBD Disconnected"),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: state.isConnected ? AppColors.successGreen : AppColors.warningAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCta(
    BuildContext context,
    ObdState state,
    bool isAr,
    bool isRunning,
  ) {
    if (isRunning) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryYellow.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? AppStringsAr.testingInProgress : AppStrings.testingInProgress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${(state.fullTestProgress * 100).toInt()}% • ${state.fullTestStatusMessage}",
                        style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  Provider.of<ObdState>(context, listen: false).isArabic ? "المرحلة ${state.fullTestCurrentStage}/10" : "Stage ${state.fullTestCurrentStage}/10",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: state.fullTestProgress,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFE5A919), Color(0xFFD48806)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startTest(state),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, color: Colors.black, size: 26),
                const SizedBox(width: 12),
                Text(
                  isAr ? AppStringsAr.startFullTest : AppStrings.startFullTest,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(
    BuildContext context,
    FullTestResult result,
    bool isAr,
  ) {
    Color scoreColor;
    if (result.healthScore >= 90) {
      scoreColor = AppColors.successGreen;
    } else if (result.healthScore >= 70) {
      scoreColor = AppColors.warningAmber;
    } else {
      scoreColor = AppColors.errorRed;
    }

    return Card(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scoreColor.withOpacity(0.5), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Circular score gauge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 4),
                    color: scoreColor.withOpacity(0.12),
                  ),
                  child: Center(
                    child: Text(
                      "${result.healthScore}",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? AppStringsAr.overallHealthIndex : AppStrings.overallHealthIndex,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.getHealthRating(isAr),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Provider.of<ObdState>(context, listen: false).isArabic ? "VIN: ${result.vin} • الجهد: ${result.batteryVoltage.toStringAsFixed(1)} فولت" : "VIN: ${result.vin} • Voltage: ${result.batteryVoltage.toStringAsFixed(1)}V",
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: result.isMilOn
                        ? AppColors.errorRed.withOpacity(0.2)
                        : AppColors.successGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        result.isMilOn ? Icons.warning : Icons.check_circle,
                        color: result.isMilOn ? AppColors.errorRed : AppColors.successGreen,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.isMilOn ? "MIL ON" : "MIL OFF",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: result.isMilOn ? AppColors.errorRed : AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsystemsGrid(
    BuildContext context,
    FullTestResult result,
    bool isAr,
  ) {
    final ecmFaults = result.allDtcs.where((d) => d.code.startsWith('P')).length;
    final absFaults = result.allDtcs.where((d) => d.code.startsWith('C')).length;
    final srsFaults = result.allDtcs.where((d) => d.code.startsWith('B')).length;
    final readyMonitors = result.readiness?.monitors.where((m) => m.isReady).length ?? 0;
    final totalMonitors = result.readiness?.monitors.length ?? 0;

    FullTestStageResult? findStage(int stageNum) {
      try {
        return result.stages.firstWhere((s) => s.stageNumber == stageNum);
      } catch (_) {
        return null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? "تفاصيل المنظومات الإلكترونية" : "Subsystem Diagnostic Breakdown",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              isAr ? "اضغط لعرض القياسات" : "Tap for Details",
              style: const TextStyle(fontSize: 11, color: AppColors.primaryYellow),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _buildSubsystemCard(
              title: isAr ? "المحرك (ECM)" : "Powertrain (ECM)",
              status: ecmFaults == 0
                  ? (isAr ? "سليم (0 أعطال)" : "Healthy (0 DTC)")
                  : "$ecmFaults ${isAr ? 'أعطال' : 'Faults'}",
              isOk: ecmFaults == 0,
              icon: Icons.engineering,
              onTap: () {
                final s = findStage(6) ?? findStage(4);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
            _buildSubsystemCard(
              title: isAr ? "الفرامل (ABS/ESP)" : "Brakes (ABS/ESP)",
              status: absFaults == 0
                  ? (isAr ? "سليم (0 أعطال)" : "Healthy (0 DTC)")
                  : "$absFaults ${isAr ? 'أعطال' : 'Faults'}",
              isOk: absFaults == 0,
              icon: Icons.radio_button_checked,
              onTap: () {
                final s = findStage(13);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
            _buildSubsystemCard(
              title: isAr ? "الإيرباج (SRS)" : "Airbags (SRS)",
              status: srsFaults == 0
                  ? (isAr ? "سليم (0 أعطال)" : "Healthy (0 DTC)")
                  : "$srsFaults ${isAr ? 'أعطال' : 'Faults'}",
              isOk: srsFaults == 0,
              icon: Icons.airline_seat_recline_extra,
              onTap: () {
                final s = findStage(14);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
            _buildSubsystemCard(
              title: isAr ? "شحن الدينامو والبطارية" : "Battery & Alternator",
              status: result.batteryHealth?.isBatteryGood == true
                  ? (isAr ? "شحن سليم" : "Charging Normal")
                  : (isAr ? "انخفاض جهد" : "Voltage Low"),
              isOk: result.batteryHealth?.isBatteryGood == true,
              icon: Icons.battery_charging_full,
              onTap: () {
                final s = findStage(7);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
            _buildSubsystemCard(
              title: isAr ? "جاهزية الانبعاثات" : "I/M Emissions",
              status: "$readyMonitors/$totalMonitors ${isAr ? 'جاهز' : 'Ready'}",
              isOk: readyMonitors >= (totalMonitors > 1 ? totalMonitors - 1 : 0),
              icon: Icons.eco,
              onTap: () {
                final s = findStage(5);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
            _buildSubsystemCard(
              title: isAr ? "حفاز البيئة (Catalyst)" : "Catalytic Converter",
              status: result.catalyticHealth != null
                  ? "${result.catalyticHealth!.efficiencyPercent.toStringAsFixed(0)}% ${isAr ? 'كفاءة' : 'Efficiency'}"
                  : "Normal",
              isOk: result.catalyticHealth?.isHealthy ?? true,
              icon: Icons.speed,
              onTap: () {
                final s = findStage(9);
                if (s != null) StageDetailModal.show(context, s, isArabic: isAr);
              },
            ),
          ],
        ),
        if (result.allDtcs.isNotEmpty) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.build_circle, color: AppColors.errorRed, size: 18),
              const SizedBox(width: 6),
              Text(
                isAr ? "الأعطال المرصودة (اضغط للكشف ودليل الإصلاح):" : "Detected Trouble Codes (Tap for Offline Repair Guide):",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.allDtcs.map((dtc) {
              return ActionChip(
                avatar: const Icon(Icons.build, size: 14, color: AppColors.errorRed),
                backgroundColor: AppColors.errorRed.withOpacity(0.15),
                side: const BorderSide(color: AppColors.errorRed),
                label: Text(
                  "${dtc.code} • ${isAr ? dtc.titleAr : dtc.title}",
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () => DtcRepairGuideModal.show(context, dtc.code, isArabic: isAr),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubsystemCard({
    required String title,
    required String status,
    required bool isOk,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOk ? AppColors.successGreen.withOpacity(0.3) : AppColors.errorRed.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isOk ? AppColors.successGreen : AppColors.errorRed,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        color: isOk ? AppColors.successGreen : AppColors.errorRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 14, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ObdState state,
    FullTestResult result,
    bool isAr,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: Text(
                  isAr ? "طباعة / تصدير PDF" : "Export / Print PDF",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final pdfBytes = await PdfReportGenerator.generatePdf(result.report);
                  await Printing.layoutPdf(onLayout: (_) => pdfBytes);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.share, size: 18),
                label: Text(
                  isAr ? "إرسال واتساب" : "Share WhatsApp",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final pdfBytes = await PdfReportGenerator.generatePdf(result.report);
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: "Inspection_Report_${result.report.plateNumber}.pdf",
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryYellow,
                  side: const BorderSide(color: AppColors.primaryYellow),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.folder_shared, size: 16),
                label: Text(
                  isAr ? "عرض سجل التقارير" : "View Saved Reports",
                  style: const TextStyle(fontSize: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                },
              ),
            ),
            if (result.dtcCount > 0) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  label: Text(
                    isAr ? "مسح الأعطال" : "Clear All DTCs",
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () async {
                    final cleared = await state.clearAllEcuDtcs();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: cleared ? AppColors.successGreen : AppColors.errorRed,
                          content: Text(
                            cleared
                                ? (isAr ? "تم إرسال أمر مسح الأعطال لجميع الكنترولات" : "DTC clear command sent to all ECUs")
                                : (isAr ? "فشل مسح الأعطال" : "Failed to clear DTCs"),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStageMatrixHeader(bool isAr, bool isRunning, double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? "مراحل الفحص الشامل (16 فحصاً متقدماً)" : "16-Stage Diagnostic Sequence",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isAr ? "اضغط على أي مرحلة لعرض التفاصيل والحزم البرمجية" : "Tap any stage to inspect deep telemetry & hex frames",
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        if (isRunning)
          Text(
            "${(progress * 100).toInt()}% Completed",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryYellow,
            ),
          ),
      ],
    );
  }

  Widget _buildStagesList(ObdState state, bool isAr, bool isRunning) {
    final stages = state.fullTestStages.isNotEmpty
        ? state.fullTestStages
        : _getDefaultStages();

    return Column(
      children: stages.map((stage) {
        final isCurrentScanning = isRunning && state.fullTestCurrentStage == stage.stageNumber;

        Color badgeColor;
        IconData badgeIcon;
        String statusLabel;

        if (isCurrentScanning) {
          badgeColor = AppColors.primaryYellow;
          badgeIcon = Icons.hourglass_top;
          statusLabel = isAr ? "جاري الفحص..." : "SCANNING";
        } else if (stage.isCompleted) {
          if (!stage.isPassed) {
            badgeColor = AppColors.errorRed;
            badgeIcon = Icons.cancel;
            statusLabel = isAr ? "يوجد عطل" : "FAULT";
          } else if (stage.hasWarning) {
            badgeColor = AppColors.warningAmber;
            badgeIcon = Icons.warning_amber;
            statusLabel = isAr ? "تحذير" : "WARN";
          } else {
            badgeColor = AppColors.successGreen;
            badgeIcon = Icons.check_circle;
            statusLabel = isAr ? "سليم" : "PASS";
          }
        } else {
          badgeColor = AppColors.textDisabled;
          badgeIcon = Icons.schedule;
          statusLabel = isAr ? "في الانتظار" : "PENDING";
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrentScanning
                  ? AppColors.primaryYellow
                  : (stage.isCompleted
                      ? badgeColor.withOpacity(0.3)
                      : Colors.white10),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => StageDetailModal.show(context, stage, isArabic: isAr),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: badgeColor.withOpacity(0.2),
                  child: isCurrentScanning
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primaryYellow)),
                        )
                      : Icon(badgeIcon, size: 16, color: badgeColor),
                ),
                title: Text(
                  "${stage.stageNumber}. ${stage.getTitle(isAr)}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCurrentScanning ? AppColors.primaryYellow : AppColors.textWhite,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.getDescription(isAr),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    if (stage.getStatusDetail(isAr).isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        stage.getStatusDetail(isAr),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white24),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<FullTestStageResult> _getDefaultStages() {
    return const [
      FullTestStageResult(
        stageNumber: 1,
        titleEn: "OBD Protocol & Voltage Baseline",
        titleAr: "بروتوكول الاتصال وفولت البطارية",
        descriptionEn: "Validating ELM327 UART baudrate, CAN bus protocol and battery level.",
        descriptionAr: "التحقق من استقرار اتصال فيشة الفحص وجهد البطارية.",
        category: "Protocol & Voltage",
      ),
      FullTestStageResult(
        stageNumber: 2,
        titleEn: "Vehicle Identification & Calibration",
        titleAr: "رقم الشاسيه (VIN) ومعايرة الكنترول",
        descriptionEn: "Extracting Mode 09 VIN, Calibration ID (CALID) and Verification (CVN).",
        descriptionAr: "قراءة رقم الشاسيه وكود معايرة كمبيوتر المحرك.",
        category: "Identification",
      ),
      FullTestStageResult(
        stageNumber: 3,
        titleEn: "Multi-ECU CAN Network Topology",
        titleAr: "مسح طوبولوجيا كنترولات السيارة (CAN Bus)",
        descriptionEn: "Interrogating ECM, TCM, ABS, SRS airbag and Body BCM gateway nodes.",
        descriptionAr: "فحص استجابة كمبيوتر الموتور، الفتيس، الفرامل، الإيرباج والشبكة.",
        category: "Network Topology",
      ),
      FullTestStageResult(
        stageNumber: 4,
        titleEn: "Comprehensive DTC Fault Extraction",
        titleAr: "استخراج جميع أكواد الأعطال (DTCs)",
        descriptionEn: "Scanning Mode 03 Stored, Mode 07 Pending, Mode 0A Permanent & Mode 02 Freeze Frame.",
        descriptionAr: "مسح الأعطال المسجلة والمعلقة والمؤكدة وبيانات التجميد.",
        category: "Fault Memory",
      ),
      FullTestStageResult(
        stageNumber: 5,
        titleEn: "Emissions & I/M Readiness Drive Cycle",
        titleAr: "جاهزية اختبار الانبعاثات وفحص المرور",
        descriptionEn: "Evaluating 11 I/M readiness monitors (Catalyst, O2, EVAP, Misfire).",
        descriptionAr: "فحص جاهزية دورة القيادة والانبعاثات وحالة لمبة الموتور.",
        category: "Emissions",
      ),
      FullTestStageResult(
        stageNumber: 6,
        titleEn: "Live OEM Telemetry Sensor Sweep",
        titleAr: "مسح الحساسات والبيانات الحية المباشرة",
        descriptionEn: "Sampling critical telemetry: RPM, Coolant Temp, Speed, MAF/MAP, Fuel Trims, O2.",
        descriptionAr: "قراءة قيم الحساسات الرئيسية اللحظية وسرعة الدوران والحرارة.",
        category: "Telemetry",
      ),
      FullTestStageResult(
        stageNumber: 7,
        titleEn: "Battery & Alternator Charging Analysis",
        titleAr: "تحليل كفاءة البطارية ومنظومة الشحن",
        descriptionEn: "Automated analysis of resting voltage, cranking sag and charging output.",
        descriptionAr: "تقييم كفاءة شحن الدينامو وهبوط الجهد أثناء تشغيل المارش.",
        category: "Electrical & Charging",
      ),
      FullTestStageResult(
        stageNumber: 8,
        titleEn: "Fuel Trim & Vacuum Leak Matrix",
        titleAr: "تحليل تصحيح الوقود وتهريب الهواء",
        descriptionEn: "Diagnosing Short/Long Term fuel trim ratios at idle vs load.",
        descriptionAr: "كشف تهريب الهواء في المنافول ومشاكل تغذية البنزين.",
        category: "Fuel Mixture",
      ),
      FullTestStageResult(
        stageNumber: 9,
        titleEn: "Catalytic Converter Efficiency Analysis",
        titleAr: "تحليل كفاءة علبة البيئة وحساسات الأكسجين",
        descriptionEn: "Cross-referencing upstream B1S1 and downstream B1S2 sensor waveform dynamics.",
        descriptionAr: "قياس كفاءة حفاز البيئة ونسبة تردد حساس الشكمان الخلفي.",
        category: "Exhaust Catalyst",
      ),
      FullTestStageResult(
        stageNumber: 10,
        titleEn: "Mode \$06 On-Board Component Monitoring",
        titleAr: "فحص المكونات غير المستمرة (Mode 06)",
        descriptionEn: "Interrogating individual cylinder misfire counters, VVT timing error & EGR limits.",
        descriptionAr: "فحص عدادات تفويت الإشعال لكل سلندر وانحراف توقيت الكامات.",
        category: "On-Board Monitoring",
      ),
      FullTestStageResult(
        stageNumber: 11,
        titleEn: "EVAP System & Fuel Vapor Integrity",
        titleAr: "فحص منظومة تبخير الوقود (EVAP)",
        descriptionEn: "Checking fuel tank vapor pressure, canister purge duty cycle & leak monitor.",
        descriptionAr: "فحص ضغط أبخرة خزان الوقود وبلف الكانيستر وتكهرب التبخير.",
        category: "Fuel Evaporation",
      ),
      FullTestStageResult(
        stageNumber: 12,
        titleEn: "Automatic Transmission & Drivetrain Health",
        titleAr: "فحص كفاءة ناقل الحركة الأوتوماتيكي (TCM)",
        descriptionEn: "Interrogating TFT fluid temperature, torque converter slip & gear ratio.",
        descriptionAr: "فحص حرارة زيت الفتيس، انزلاق الطنجرة ونسب الغيارات.",
        category: "Transmission",
      ),
      FullTestStageResult(
        stageNumber: 13,
        titleEn: "ABS, ESP & Active Chassis Dynamics",
        titleAr: "فحص منظومة الفرامل المانعة للانغلاق (ABS)",
        descriptionEn: "Testing 4-wheel independent speed sensors, steering angle sensor & yaw rate.",
        descriptionAr: "فحص حساسات سرعة العجلات الأربعة وحساس زاوية التوجيه (SAS).",
        category: "Chassis & Brakes",
      ),
      FullTestStageResult(
        stageNumber: 14,
        titleEn: "SRS Supplemental Restraint & Airbag Squibs",
        titleAr: "فحص وسائد الهواء والأمان (SRS Airbag)",
        descriptionEn: "Interrogating pyrotechnic squib resistance loops (2.2Ω - 3.2Ω) & pretensioners.",
        descriptionAr: "قياس مقاومة كبسولات الإيرباج وحزام الأمان لضمان سلامة الركاب.",
        category: "Safety & Airbags",
      ),
      FullTestStageResult(
        stageNumber: 15,
        titleEn: "HVAC Climate Control & Refrigerant Pressure",
        titleAr: "فحص منظومة التكييف وضغط الفريون (HVAC)",
        descriptionEn: "Measuring A/C high-side line pressure, evaporator temp & compressor clutch relay.",
        descriptionAr: "قياس ضغط غاز الفريون وحرارة الثلاجة الداخلية وكلاتش الكمبروسر.",
        category: "Climate Control",
      ),
      FullTestStageResult(
        stageNumber: 16,
        titleEn: "Security Gateway (SGW) & Final Report",
        titleAr: "فحص بوابة الحماية (SGW) وإصدار التقرير",
        descriptionEn: "Verifying SGW status, computing Vehicle Health Index and archiving report.",
        descriptionAr: "التحقق من بوابات الحماية وحساب مؤشر الكفاءة وتصدير التقرير.",
        category: "Security & Report",
      ),
    ];
  }
}
