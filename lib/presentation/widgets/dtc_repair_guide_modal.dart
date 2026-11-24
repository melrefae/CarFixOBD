import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../data/datasources/dtc_knowledge_base.dart';

/// Modal bottom sheet displaying detailed offline diagnostic repair guide for any DTC
class DtcRepairGuideModal extends StatelessWidget {
  final String code;
  final bool isArabic;

  const DtcRepairGuideModal({
    Key? key,
    required this.code,
    this.isArabic = false,
  }) : super(key: key);

  static void show(BuildContext context, String code, {bool isArabic = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DtcRepairGuideModal(code: code, isArabic: isArabic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guide = DtcKnowledgeBase.lookup(code);
    if (guide == null) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            isArabic ? "لم يتم العثور على دليل إصلاح للكود $code" : "No repair guide found for code $code",
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final title = guide.getTitle(isArabic);
    final desc = guide.getDescription(isArabic);
    final symptoms = guide.getSymptoms(isArabic);
    final causes = guide.getCauses(isArabic);
    final steps = guide.getDiagnosticSteps(isArabic);
    final multi = guide.getMultimeterChecks(isArabic);
    final rep = guide.getRepairSolutions(isArabic);

    Color severityColor = AppColors.primaryYellow;
    if (guide.severity.toLowerCase() == 'critical') {
      severityColor = AppColors.dangerRed;
    } else if (guide.severity.toLowerCase() == 'low') {
      severityColor = AppColors.successGreen;
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.cardBorder),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    guide.code,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "${guide.category} • ${guide.severity}",
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 2),
                          Text(guide.estimatedRepairTime, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Body Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description card
                _buildSectionCard(
                  icon: Icons.info_outline,
                  title: isArabic ? "وصف العطل وآلية الرصد" : "System Description & Detection Logic",
                  child: Text(
                    desc,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.4),
                  ),
                ),

                const SizedBox(height: 12),

                // Real-World Symptoms
                _buildSectionCard(
                  icon: Icons.warning_amber_rounded,
                  title: isArabic ? "الأعراض الشائعة بالسيارة" : "Common Vehicle Symptoms",
                  child: Column(
                    children: symptoms.map((s) => _buildBulletItem(s, Colors.amber)).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Root causes
                _buildSectionCard(
                  icon: Icons.search_rounded,
                  title: isArabic ? "الأسباب المحتملة ورتبة الترجيح" : "Probable Root Causes",
                  child: Column(
                    children: causes.map((c) => _buildBulletItem(c, Colors.cyan)).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Step-by-step diagnostic roadmap
                _buildSectionCard(
                  icon: Icons.alt_route_rounded,
                  title: isArabic ? "خارطة الفحص التشخيصي للورشة" : "Workshop Diagnostic Roadmap",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: steps.map((st) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        st,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5, height: 1.35),
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Multimeter & pinout check
                _buildSectionCard(
                  icon: Icons.speed,
                  title: isArabic ? "فحص الأفوميتر والضفيرة الكهربائية" : "Multimeter & Electrical Pinout Specs",
                  color: AppColors.primaryYellow.withOpacity(0.08),
                  borderColor: AppColors.primaryYellow.withOpacity(0.4),
                  child: Text(
                    multi,
                    style: const TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Recommended repair & fix
                _buildSectionCard(
                  icon: Icons.build_circle_outlined,
                  title: isArabic ? "الحل وقطع الغيار الموصى بتغييرها" : "Recommended Repair & Solutions",
                  color: AppColors.successGreen.withOpacity(0.08),
                  borderColor: AppColors.successGreen.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rep,
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            isArabic ? "صعوبة الإصلاح:" : "Repair Complexity:",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 6),
                          ...List.generate(5, (index) => Icon(
                            Icons.build,
                            size: 13,
                            color: index < guide.laborDifficulty ? AppColors.primaryYellow : Colors.white24,
                          )),
                          const Spacer(),
                          Text(
                            "${isArabic ? 'الوقت التقديري:' : 'Est. Time:'} ${guide.estimatedRepairTime}",
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Copy Diagnostic Roadmap Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryYellow,
                    side: const BorderSide(color: AppColors.primaryYellow),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(isArabic ? "نسخ خطوات الفحص للعميل" : "Copy Diagnostic Roadmap"),
                  onPressed: () {
                    final clipboardText = """
[${guide.code}] $title
Symptoms:
${symptoms.map((s) => "• $s").join("\n")}

Diagnostic Roadmap:
${steps.join("\n")}

Electrical Spec:
$multi

Recommended Fix:
$rep
""";
                    Clipboard.setData(ClipboardData(text: clipboardText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic ? "تم نسخ خارطة الإصلاح للحافظة! 📋" : "Diagnostic roadmap copied to clipboard! 📋"),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Color? color,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 12.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
