import 'package:flutter/material.dart';
import '../screens/lab_gate.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/full_test_result.dart';
import '../screens/actuator_tests_screen.dart';

/// Modal bottom sheet displaying deep diagnostic telemetry, OEM ranges,
/// technical explanation, and raw hex traces for an individual test stage.
class StageDetailModal extends StatelessWidget {
  final FullTestStageResult stage;
  final bool isArabic;

  const StageDetailModal({
    Key? key,
    required this.stage,
    this.isArabic = false,
  }) : super(key: key);

  static void show(
    BuildContext context,
    FullTestStageResult stage, {
    bool isArabic = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StageDetailModal(stage: stage, isArabic: isArabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!stage.isCompleted) {
      statusColor = AppColors.textDisabled;
      statusIcon = Icons.schedule;
      statusText = isArabic ? "في الانتظار" : "PENDING";
    } else if (!stage.isPassed) {
      statusColor = AppColors.errorRed;
      statusIcon = Icons.cancel;
      statusText = isArabic ? "عطل مكتشف" : "FAULT DETECTED";
    } else if (stage.hasWarning) {
      statusColor = AppColors.warningAmber;
      statusIcon = Icons.warning_amber;
      statusText = isArabic ? "تنبيه تشغيلي" : "WARNING";
    } else {
      statusColor = AppColors.successGreen;
      statusIcon = Icons.check_circle;
      statusText = isArabic ? "سليم ومعتمد" : "PASS (NORMAL)";
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              isArabic ? "المرحلة ${stage.stageNumber}" : "Stage ${stage.stageNumber}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              stage.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.getTitle(isArabic),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                // Overview & Description
                Text(
                  stage.getDescription(isArabic),
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                ),
                if (stage.getStatusDetail(isArabic).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor.withOpacity(0.35)),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            stage.getStatusDetail(isArabic),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Parameters Table
                if (stage.parameters.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    isArabic ? "المعايير والقراءات المقاسة:" : "Inspected Parameters & OEM Tolerances:",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stage.parameters.map((p) => _buildParameterCard(p)),
                ],

                // Technical Explanation
                if (stage.getTechnicalExplanation(isArabic).isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.psychology, size: 18, color: AppColors.accentBlue),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? "التحليل الهندسي والفني:" : "Technical Diagnostic Interpretation:",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      stage.getTechnicalExplanation(isArabic),
                      style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.45),
                    ),
                  ),
                ],

                // Workshop Action & Recommendation
                if (stage.getRecommendation(isArabic).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.build_circle, size: 18, color: AppColors.primaryYellow),
                      const SizedBox(width: 6),
                      Text(
                        isArabic ? "توصيات مهندس الصيانة:" : "Workshop Recommended Actions:",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                    ),
                    child: Text(
                      stage.getRecommendation(isArabic),
                      style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
                    ),
                  ),
                ],

                // Raw OBD/CAN Hex Communication Trace
                if (stage.rawCommand.isNotEmpty || stage.rawHexResponse.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.code, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? "بيانات بروتوكول التشخيص (Hex):" : "Raw Diagnostic Bus Frames (Hex):",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          final clip = "CMD: ${stage.rawCommand}\nRESP: ${stage.rawHexResponse}";
                          Clipboard.setData(ClipboardData(text: clip));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.cardSurface,
                              content: Text(
                                isArabic ? "تم نسخ حزم الـ Hex!" : "Hex frames copied to clipboard!",
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.copy, size: 13, color: AppColors.primaryYellow),
                            const SizedBox(width: 4),
                            Text(
                              isArabic ? "نسخ" : "Copy",
                              style: const TextStyle(fontSize: 11, color: AppColors.primaryYellow),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stage.rawCommand.isNotEmpty)
                          Text(
                            "> ${stage.rawCommand}",
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                        if (stage.rawHexResponse.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "< ${stage.rawHexResponse}",
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Shortcut Actions
                const SizedBox(height: 22),
                _buildActionShortcuts(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(StageParameterDetail param) {
    Color paramColor;
    switch (param.status) {
      case StageParameterStatus.critical:
        paramColor = AppColors.errorRed;
        break;
      case StageParameterStatus.warning:
        paramColor = AppColors.warningAmber;
        break;
      case StageParameterStatus.normal:
        paramColor = AppColors.successGreen;
        break;
    }

    // Calculate progress if ranges exist
    double? progress;
    if (param.currentNumeric != null && param.minRange != null && param.maxRange != null) {
      final total = param.maxRange! - param.minRange!;
      if (total > 0) {
        progress = ((param.currentNumeric! - param.minRange!) / total).clamp(0.0, 1.0);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  param.getName(isArabic),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              Text(
                param.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: paramColor,
                ),
              ),
            ],
          ),
          if (param.nominalRange.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? "المدى الطبيعي (OEM):" : "Nominal OEM Range:",
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
                Text(
                  param.nominalRange,
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(paramColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionShortcuts(BuildContext context) {
    return Row(
      children: [
        if (stage.actionTarget != null && stage.actionTarget!.startsWith("actuator:")) ...[
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.touch_app, size: 16),
              label: Text(
                isArabic ? "فحص المشغلات" : "Actuator Tests",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.pop(context);
                LabGate.open(context, const ActuatorTestsScreen());
              },
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textWhite,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.close, size: 16),
            label: Text(
              isArabic ? "إغلاق" : "Close",
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
