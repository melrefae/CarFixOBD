import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/used_car_audit_models.dart';
import '../../domain/services/used_car_pdf_report_service.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen for Used Car Pre-Purchase Inspection & Fraud / Odometer Rollback Audit
class UsedCarAuditScreen extends StatefulWidget {
  const UsedCarAuditScreen({Key? key}) : super(key: key);

  @override
  State<UsedCarAuditScreen> createState() => _UsedCarAuditScreenState();
}

class _UsedCarAuditScreenState extends State<UsedCarAuditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PrePurchaseAuditScorecard? _scorecard;
  bool _isAuditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _scorecard = null; // No mock data on startup - genuine vehicle OBD audit only
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateCheckItemStatus(String categoryId, String itemId, ManualCheckItemStatus newStatus) {
    if (_scorecard == null) return;
    final currentReport = _scorecard!.manualChecklist;
    final newCategories = currentReport.categories.map((cat) {
      if (cat.id != categoryId) return cat;
      final newItems = cat.items.map((item) {
        if (item.id != itemId) return item;
        return item.copyWith(status: newStatus);
      }).toList();
      return cat.copyWith(items: newItems);
    }).toList();
    final newReport = ManualInspectionReport(categories: newCategories);
    setState(() {
      _scorecard = _scorecard!.copyWith(manualChecklist: newReport);
    });
  }

  void _updatePanelMicron(String panel, int newMicron) {
    if (_scorecard == null) return;
    final newMap = Map<String, int>.from(_scorecard!.paintAudit.panelMicrons);
    newMap[panel] = newMicron;
    final hasBondo = newMap.values.any((m) => m > 250);
    final hasStructural = (newMap['A-Pillars'] ?? 0) > 160 || (newMap['B-Pillars'] ?? 0) > 160;
    final newAudit = BodyPaintThicknessAudit(
      panelMicrons: newMap,
      hasBondoDetected: hasBondo,
      hasStructuralDamageSuspected: hasStructural,
      verdictEn: hasBondo
          ? "BODY FRAUD ALERT: High body filler/bondo detected on panels (>250 um)."
          : (hasStructural ? "STRUCTURAL ALERT: Structural pillar welding/repainting detected." : "OEM FACTORY PAINT: All panels within tolerance."),
      verdictAr: hasBondo
          ? "تنبيه غش بالهيكل: تم رصد معجون كثيف بأجزاء الهيكل (>250 ميكرون)."
          : (hasStructural ? "تنبيه شاسيه: تم رصد لحام أو دهان في القوايم الهيكلية." : "دهان فابريكا أصلي: كافة أجزاء الهيكل ضمن المدى الطبيعي."),
    );
    setState(() {
      _scorecard = _scorecard!.copyWith(paintAudit: newAudit);
    });
  }

  Future<void> _runLiveAudit(ObdState state, bool isAr) async {
    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص (OBD) الحقيقية بالسيارة أولاً"
                : "Please connect a real OBD adapter to vehicle before auditing.",
          ),
          backgroundColor: AppColors.warningOrange,
          action: SnackBarAction(
            label: isAr ? "اتصال" : "Connect",
            textColor: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectionScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAuditing = true;
    });

    try {
      final card = await state.runLiveUsedCarAudit();
      if (mounted) {
        setState(() {
          _scorecard = card;
          _isAuditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? "تم سحب بيانات السيارة الحية بنجاح! التقييم: ${card.overallScore}/100"
                  : "Live vehicle audit completed successfully! Score: ${card.overallScore}/100",
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf(ObdState state, bool isAr) async {
    if (_scorecard == null) return;
    try {
      final vehicleName = state.currentProfile?.getDisplayName(isAr) ?? "Vehicle_${_scorecard!.vinAudit.registeredVin}";
      await UsedCarPdfReportService.sharePdfReport(
        scorecard: _scorecard!,
        vehicleName: vehicleName,
        isArabic: isAr,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing PDF: $e"), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _printReport(ObdState state, bool isAr) async {
    if (_scorecard == null) return;
    try {
      final vehicleName = state.currentProfile?.getDisplayName(isAr) ?? "Vehicle_${_scorecard!.vinAudit.registeredVin}";
      await UsedCarPdfReportService.printReport(
        scorecard: _scorecard!,
        vehicleName: vehicleName,
        isArabic: isAr,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error printing report: $e"), backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  Future<void> _showSaveReportDialog(BuildContext context, ObdState state, bool isAr, bool isLight) async {
    if (_scorecard == null) return;
    final card = _scorecard!;
    final customerController = TextEditingController(text: "Customer");
    final phoneController = TextEditingController();
    final plateController = TextEditingController(text: card.vinAudit.registeredVin);
    final notesController = TextEditingController(
      text: "Pre-Purchase Audit Score: ${card.overallScore}/100. Status: ${card.overallVerdictEn}.",
    );

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          title: Row(
            children: [
              Icon(Icons.bookmark_added_outlined, color: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow),
              const SizedBox(width: 8),
              Text(
                isAr ? "حفظ تقرير الفحص بسجلات الورشة" : "Save Pre-Purchase Audit Report",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "اسم العميل / المشتري:" : "Customer / Buyer Name:",
                  style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: customerController,
                  style: TextStyle(color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: isAr ? "أدخل اسم العميل" : "Enter customer name",
                    hintStyle: TextStyle(color: isLight ? AppColors.lightTextMuted : AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr ? "رقم الهاتف:" : "Customer Phone:",
                  style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: isAr ? "رقم الهاتف للتواصل" : "Contact phone number",
                    hintStyle: TextStyle(color: isLight ? AppColors.lightTextMuted : AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr ? "رقم اللوحة / الشاسيه:" : "Plate Number / Vehicle ID:",
                  style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: plateController,
                  style: TextStyle(color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: isAr ? "رقم لوحة المركبة" : "Vehicle plate number",
                    hintStyle: TextStyle(color: isLight ? AppColors.lightTextMuted : AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr ? "ملاحظات الفني:" : "Technician Notes:",
                  style: TextStyle(fontSize: 12, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: TextStyle(color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: isAr ? "ملاحظات وتوصيات الفحص" : "Inspection recommendations & notes",
                    hintStyle: TextStyle(color: isLight ? AppColors.lightTextMuted : AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? "إلغاء" : "Cancel", style: TextStyle(color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
                foregroundColor: isLight ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                final customer = customerController.text.trim();
                final phone = phoneController.text.trim();
                final plate = plateController.text.trim();
                final notes = notesController.text.trim();

                Navigator.pop(ctx);

                try {
                  await state.saveUsedCarAuditReport(
                    card,
                    customerName: customer.isEmpty ? "Used Car Buyer" : customer,
                    customerPhone: phone.isEmpty ? "N/A" : phone,
                    plateNumber: plate.isEmpty ? card.vinAudit.registeredVin : plate,
                    notes: notes,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isAr
                              ? "تم حفظ تقرير فحص السيارة بنجاح في سجلات الورشة!"
                              : "Pre-purchase audit report saved to Workshop Records!",
                        ),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isAr ? "خطأ أثناء حفظ التقرير: $e" : "Error saving report: $e"),
                        backgroundColor: AppColors.dangerRed,
                      ),
                    );
                  }
                }
              },
              child: Text(isAr ? "حفظ التقرير" : "Save Report"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmStartNewTest(ObdState state, bool isAr, bool isLight) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
        ),
        title: Row(
          children: [
            Icon(Icons.refresh, color: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange),
            const SizedBox(width: 8),
            Text(
              isAr ? "بدء فحص سيارة جديدة؟" : "Start New Vehicle Audit?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
              ),
            ),
          ],
        ),
        content: Text(
          isAr
              ? "هل تريد تصفير تقرير الفحص الحالي وبدء فحص سيارة جديدة؟ يرجى التأكد من حفظ التقرير الحالي إذا كنت بحاجة إليه."
              : "Do you want to reset current inspection results and start a new vehicle audit? Make sure to save the current report if needed.",
          style: TextStyle(
            fontSize: 13,
            color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? "إلغاء" : "Cancel", style: TextStyle(color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isAr ? "بدء فحص جديد" : "Start New Test"),
          ),
        ],
      ),
    );

    if (shouldReset == true && mounted) {
      setState(() {
        _scorecard = null;
      });
      if (state.isConnected) {
        _runLiveAudit(state, isAr);
      }
    }
  }

  Widget _buildReadyToInspectView(ObdState state, bool isAr, bool isLight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    (isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow).withOpacity(isLight ? 0.12 : 0.2),
                    (isLight ? AppColors.lightElectricBlue : AppColors.electricBlue).withOpacity(isLight ? 0.08 : 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow, width: 2),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 46,
                color: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? "فحص الشراء الجنائي وكشف التلاعب" : "Forensic Pre-Purchase & Fraud Audit",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? "فحص شامل متعدد الكمبيوترات لقراءة بيانات السيارة الحقيقية (العداد الحقيقي عبر ECM/TCM/ABS، كشف مسح الأعطال الحديث، مطابقة رقم الشاسيه VIN، وسجلات فتح الوسائد الهوائية). جميع البيانات تُقرأ حياً من السيارة 100% بدون أي محاكاة أو بيانات افتراضية."
                : "Multi-ECU forensic audit interrogating genuine vehicle hardware (odometer verification across ECM/TCM/ABS, trouble-code clearing fraud detection, network VIN matching, and SRS crash event logs). Only values actually read from the car are used; anything the car does not expose is shown as unavailable.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: state.isConnected
                    ? (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen)
                    : (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange),
                width: 1.2,
              ),
              boxShadow: isLight
                  ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      state.isConnected ? Icons.cable : Icons.cable_outlined,
                      color: state.isConnected
                          ? (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen)
                          : (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.isConnected
                                ? (isAr ? "فيشة الفحص متصلة بالسيارة" : "OBD Hardware Connected")
                                : (isAr ? "فيشة الفحص غير متصلة" : "OBD Hardware Not Connected"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: state.isConnected
                                  ? (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen)
                                  : (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.isConnected
                                ? "${state.connectedDeviceName ?? 'ELM327 / OBD Adapter'} • ${state.activeProtocol} • ${state.batteryVoltage.toStringAsFixed(1)}V"
                                : (isAr
                                    ? "قم بتوصيل فيشة الفحص بفتحة OBD-II بالسيارة وتشغيل الكونتاكت (Ignition ON)"
                                    : "Connect OBD-II adapter to vehicle diagnostic port and turn ignition ON"),
                            style: TextStyle(fontSize: 11, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!state.isConnected) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
                        side: BorderSide(color: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.bluetooth_searching, size: 18),
                      label: Text(
                        isAr ? "توصيل فيشة الفحص (OBD)" : "Connect OBD Adapter",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ConnectionScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isConnected
                  ? (isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow)
                  : (isLight ? AppColors.lightCardSurfaceHighlight : AppColors.cardSurfaceHighlight),
              foregroundColor: state.isConnected
                  ? (isLight ? Colors.white : Colors.black)
                  : (isLight ? AppColors.lightTextMuted : Colors.white70),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: isLight ? 1 : 4,
            ),
            icon: _isAuditing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: isLight ? Colors.white : Colors.black),
                  )
                : const Icon(Icons.speed, size: 22),
            label: Text(
              _isAuditing
                  ? (isAr ? "جارِ فحص كمبيوترات وحساسات المركبة..." : "Auditing Vehicle Telemetry Live...")
                  : (isAr ? "بدء فحص السيارة الحقيقي (OBD)" : "Run Live Vehicle Audit (OBD)"),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            onPressed: _isAuditing ? null : () => _runLiveAudit(state, isAr),
          ),
          const SizedBox(height: 24),
          Text(
            isAr ? "المعايير المعتمدة في تقرير الفحص الجنائي:" : "Forensic Audit Verification Pillars:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 12),
          _buildPillarCard(
            icon: Icons.speed,
            title: isAr ? "كشف التلاعب بالعداد عبر الـ CAN Bus" : "Multi-ECU Odometer Cross-Check",
            desc: isAr
                ? "مقارنة العداد المسجل في لوحة العدادات مع كمبيوتر المحرك (ECM)، الفتيس (TCM)، ونظام الفرامل (ABS)."
                : "Cross-checks instrument cluster mileage against ECM, TCM, and ABS wheel pulse revolution counters.",
            color: isLight ? AppColors.lightElectricBlue : AppColors.accentCyan,
            isLight: isLight,
          ),
          _buildPillarCard(
            icon: Icons.history_toggle_off,
            title: isAr ? "كشف تصفير الأعطال لإخفاء العيوب" : "DTC Code-Clearing Fraud Detection",
            desc: isAr
                ? "فحص الكيلومترات ودورات التسخين المنقضية منذ آخر مسح للأعطال (Mode 01 PID 31 & 30)."
                : "Reads distance and engine warm-up cycles elapsed since diagnostic codes were erased.",
            color: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange,
            isLight: isLight,
          ),
          _buildPillarCard(
            icon: Icons.fingerprint,
            title: isAr ? "مطابقة رقم الشاسيه في كمبيوترات السيارة" : "Network VIN Integrity Matching",
            desc: isAr
                ? "مطابقة رقم الشاسيه VIN المخزن في الـ ECM و BCM و SRS للتأكد من عدم تبديل كنترولات مسروقة أو تالفة."
                : "Interrogates VIN registers across ECM, BCM, and SRS to ensure no salvaged or swapped modules.",
            color: isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
            isLight: isLight,
          ),
          _buildPillarCard(
            icon: Icons.airplay_rounded,
            title: isAr ? "سجلات حوادث الإيرباج وسلامة المحرك" : "SRS Crash History & Powertrain Health",
            desc: isAr
                ? "فحص سجلات الاصطدام غير القابلة للمسح في حساسات الأكياس الهوائية واختبار توازن انضغاط السلندرات."
                : "Inspects non-volatile crash deployment counters in SRS airbag module and relative compression.",
            color: isLight ? AppColors.lightSuccessGreen : AppColors.successGreen,
            isLight: isLight,
          ),
          _buildPillarCard(
            icon: Icons.format_paint_outlined,
            title: isAr ? "سماكة الدهان وهيكل الشاسيه بالميكرون" : "Body Paint & Structural Microns",
            desc: isAr
                ? "قياس سماكة الدهان بالميكرون (80-140 فابريكا) ورصد المعجون وحوادث قص ولحام القوايم والشاسيه."
                : "Ultrasonic paint gauge mapping (80-140 um OEM) detecting body putty filler and chassis welding.",
            color: isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
            isLight: isLight,
          ),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool isLight,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
        boxShadow: isLight
            ? [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1))]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isLight ? 0.1 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final isLight = state.isSunlightMode;

    if (_scorecard == null) {
      return Scaffold(
        backgroundColor: isLight ? AppColors.lightBackground : AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 0,
          title: Text(
            isAr ? "فحص الشراء وكشف التلاعب المتقدم" : "Forensic Used Car & Fraud Audit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.cable, color: isLight ? AppColors.lightTextPrimary : AppColors.primaryYellow),
              tooltip: isAr ? "حالة الاتصال" : "Connection",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnectionScreen()),
                );
              },
            ),
          ],
        ),
        body: _buildReadyToInspectView(state, isAr, isLight),
      );
    }

    final card = _scorecard!;
    final score = card.overallScore;
    final isTampered = card.odometerAudit.isRollbackSuspected || card.codeClearingAudit.isRecentlyCleared;
    final scoreColor = score >= 85
        ? (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen)
        : (score >= 65
            ? (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange)
            : (isLight ? AppColors.lightDangerRed : AppColors.dangerRed));

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBackground : AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
        elevation: isLight ? 0.5 : 0,
        title: Text(
          isAr ? "فحص الشراء وكشف التلاعب المتقدم" : "Forensic Used Car & Fraud Audit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_added_outlined, color: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow),
            tooltip: isAr ? "حفظ التقرير" : "Save Report",
            onPressed: () => _showSaveReportDialog(context, state, isAr, isLight),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange),
            tooltip: isAr ? "بدء فحص جديد" : "Start New Test",
            onPressed: () => _confirmStartNewTest(state, isAr, isLight),
          ),
          IconButton(
            icon: Icon(Icons.share, color: isLight ? AppColors.lightTextPrimary : AppColors.primaryYellow),
            tooltip: isAr ? "مشاركة عبر واتساب" : "Share PDF Report",
            onPressed: () => _sharePdf(state, isAr),
          ),
          IconButton(
            icon: Icon(Icons.print_outlined, color: isLight ? AppColors.lightTextPrimary : AppColors.primaryYellow),
            tooltip: isAr ? "طباعة الشهادة" : "Print Certificate",
            onPressed: () => _printReport(state, isAr),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
          labelColor: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
          unselectedLabelColor: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
          tabs: [
            Tab(icon: const Icon(Icons.verified, size: 18), text: isAr ? "الشهادة العامة" : "Certificate"),
            Tab(icon: const Icon(Icons.speed, size: 18), text: isAr ? "كشف العداد" : "Odometer"),
            Tab(icon: const Icon(Icons.history_toggle_off, size: 18), text: isAr ? "تصفير الأعطال" : "Reset Fraud"),
            Tab(icon: const Icon(Icons.security, size: 18), text: isAr ? "الشاسيه والإيرباج" : "VIN & SRS"),
            Tab(icon: const Icon(Icons.precision_manufacturing, size: 18), text: isAr ? "صحة المحرك والفتيس" : "Drivetrain"),
            Tab(icon: const Icon(Icons.format_paint_outlined, size: 18), text: isAr ? "سماكة الدهان" : "Paint & Microns"),
            Tab(icon: const Icon(Icons.water_drop_outlined, size: 18), text: isAr ? "الغرق والبطارية والملكية" : "Flood & Battery & Title"),
            Tab(icon: const Icon(Icons.checklist_rtl_outlined, size: 18), text: isAr ? "الفحص الميداني والعفشة" : "Manual Checklist"),
            Tab(icon: const Icon(Icons.receipt_long, size: 18), text: isAr ? "تقدير التكاليف والخصم" : "Defect Valuation"),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF5A3A00),
            padding: const EdgeInsets.all(8),
            child: Text(
              isAr
                  ? "تنبيه: الأقسام التالية ليست قياسات من السيارة: الدهان، الغرق، الملكية، فحص الهيكل اليدوي، تقدير التكاليف، ودرجات الأقسام. أدخلها يدوياً بعد الفحص الفعلي. المقروء فعلياً: العداد من الوحدات، مسح الأعطال، VIN، جهد البطارية فقط."
                  : "Notice: paint, flood, title, manual checklist, repair estimates and sub-scores are NOT measured by the car. Fill them from a real inspection. Actually read from the car: odometer from ECUs, DTC scan, VIN, battery voltage only.",
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
          // Score Hero Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLight
                    ? const [AppColors.lightCardSurface, AppColors.lightCardSurfaceHighlight]
                    : const [Color(0xFF263238), Color(0xFF1E262C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: isTampered
                      ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed)
                      : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
                  width: isTampered ? 2.0 : 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scoreColor.withOpacity(isLight ? 0.08 : 0.15),
                    border: Border.all(color: scoreColor, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$score",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                      Text(
                        "/ 100",
                        style: TextStyle(fontSize: 8, color: isLight ? AppColors.lightTextMuted : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isAr ? card.gradeClassificationAr : card.gradeClassificationEn,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scoreColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTampered
                                  ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed).withOpacity(isLight ? 0.1 : 0.2)
                                  : (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen).withOpacity(isLight ? 0.1 : 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isTampered
                                    ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed)
                                    : (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen),
                              ),
                            ),
                            child: Text(
                              isTampered ? (isAr ? "تحذير تلاعب" : "TAMPERED") : (isAr ? "معتمد أصلي" : "OEM VERIFIED"),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isTampered
                                    ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed)
                                    : (isLight ? AppColors.lightSuccessGreen : AppColors.successGreen),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "VIN: ${card.vinAudit.registeredVin} • Hash: ${card.verificationHash}",
                        style: TextStyle(
                          fontSize: 10,
                          color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isConnected
                        ? (isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow)
                        : (isLight ? AppColors.lightCardSurfaceHighlight : AppColors.cardSurfaceHighlight),
                    foregroundColor: state.isConnected
                        ? (isLight ? Colors.white : Colors.black)
                        : (isLight ? AppColors.lightTextMuted : Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: _isAuditing ? null : () => _runLiveAudit(state, isAr),
                  child: _isAuditing
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: isLight ? Colors.white : Colors.black),
                        )
                      : Icon(state.isConnected ? Icons.refresh : Icons.cable, size: 18),
                ),
              ],
            ),
          ),

          // 9-Report Sub-Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isAr, isLight),
                _buildOdometerTab(isAr, isLight),
                _buildCodeClearingTab(isAr, isLight),
                _buildVinAndSrsTab(isAr, isLight),
                _buildDrivetrainTab(isAr, isLight),
                _buildPaintTab(isAr, isLight),
                _buildFloodBatteryTitleTab(isAr, isLight),
                _buildManualChecklistTab(isAr, isLight),
                _buildDefectValuationTab(isAr, isLight),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightCardSurface : const Color(0xFF151D24),
              border: Border(top: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder)),
              boxShadow: isLight
                  ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, -2))]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLight ? AppColors.lightPrimaryCobalt : AppColors.primaryYellow,
                          foregroundColor: isLight ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: isLight ? 1 : 2,
                        ),
                        icon: const Icon(Icons.bookmark_added_outlined, size: 18),
                        label: Text(
                          isAr ? "حفظ التقرير بالورشة" : "Save Report",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _showSaveReportDialog(context, state, isAr, isLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange,
                          side: BorderSide(color: isLight ? AppColors.lightWarningOrange : AppColors.warningOrange, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(
                          isAr ? "بدء فحص جديد" : "Start New Test",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _confirmStartNewTest(state, isAr, isLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isLight ? AppColors.lightElectricBlue : AppColors.accentCyan,
                          side: BorderSide(color: isLight ? AppColors.lightElectricBlue : AppColors.accentCyan, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.print, size: 16),
                        label: Text(
                          isAr ? "طباعة الشهادة" : "Print PDF",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _printReport(state, isAr),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLight ? AppColors.lightSuccessGreen : AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: isLight ? 1 : 2,
                        ),
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(
                          isAr ? "إرسال للعميل" : "Share WhatsApp",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _sharePdf(state, isAr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Master Overview & Scorecard
  Widget _buildOverviewTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final card = _scorecard!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          isAr ? "توزيع درجات الفحص (100 نقطة)" : "Inspection Category Scoring Breakdown",
          Icons.pie_chart,
          isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
          isLight: isLight,
        ),
        const SizedBox(height: 10),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : Colors.transparent),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildScoreBar(isAr ? "المحرك وناقل الحركة" : "Powertrain & Transmission", card.powertrainScore, 25, isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow, isLight: isLight),
                _buildScoreBar(isAr ? "الشاسيه ونظام الفرامل ABS" : "Chassis & ABS System", card.chassisAbsScore, 20, isLight ? AppColors.lightElectricBlue : AppColors.accentCyan, isLight: isLight),
                _buildScoreBar(isAr ? "الشبكة والكمبيوترات الإلكترونية" : "Electronics & CAN Network", card.electronicsNetworkScore, 20, isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue, isLight: isLight),
                _buildScoreBar(isAr ? "وسائد الأمان والحوادث SRS" : "SRS Airbag & Safety Restraints", card.safetySrsScore, 20, isLight ? AppColors.lightWarningOrange : AppColors.warningOrange, isLight: isLight),
                _buildScoreBar(isAr ? "الانبعاثات وعلبة البيئة" : "Emissions & Catalyst System", card.emissionsCatalystScore, 15, isLight ? AppColors.lightSuccessGreen : AppColors.successGreen, isLight: isLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(
          isAr ? "ملخص القرارات الفنية الحاسمة" : "Critical Forensic Audit Flags",
          Icons.rule,
          isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
          isLight: isLight,
        ),
        const SizedBox(height: 10),
        _buildSummaryStatusTile(
          title: isAr ? "فحص تلاعب عداد الكيلومترات" : "Odometer Rollback Cross-Verification",
          isOk: !card.odometerAudit.isRollbackSuspected,
          detail: isAr ? card.odometerAudit.verdictAr : card.odometerAudit.verdictEn,
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "كشف تصفير الأعطال حديثاً" : "Code-Clearing Fraud (PIDs 0x30/31)",
          isOk: !card.codeClearingAudit.isRecentlyCleared,
          detail: isAr ? card.codeClearingAudit.riskRatingAr : card.codeClearingAudit.riskRatingEn,
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "تطابق الشاسيه بين كافة الكنترولات" : "Multi-ECU VIN Consistency",
          isOk: card.vinAudit.isVinMatched,
          detail: card.vinAudit.isVinMatched
              ? (isAr ? "كل الوحدات متطابقة 100%" : "All 4 ECUs report identical VIN")
              : (isAr ? "عدم تطابق في: ${card.vinAudit.mismatchedModules.join(', ')}" : "Mismatched: ${card.vinAudit.mismatchedModules.join(', ')}"),
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "سجل فتح الأكياس الهوائية والحوادث" : "SRS Crash Data & Squib Deployments",
          isOk: !card.srsCrash.hasCrashData,
          detail: card.srsCrash.hasCrashData
              ? (isAr ? "تم تسجيل حادث سابق وفتح كبسولات" : "Crash data recorded with squib firing")
              : (isAr ? "لا توجد سجلات حوادث مسجلة" : "No crash event records found (Clean)"),
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "سماكة الدهان وهيكل الشاسيه بالميكرون" : "Body Paint & Structural Integrity",
          isOk: !card.paintAudit.hasBondoDetected && !card.paintAudit.hasStructuralDamageSuspected,
          detail: isAr ? card.paintAudit.verdictAr : card.paintAudit.verdictEn,
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "فحص الغرق والتمليح بالضفيرة" : "Flood & Water Immersion Detection",
          isOk: card.floodAudit.floodRiskPercent < 30,
          detail: isAr ? card.floodAudit.verdictAr : card.floodAudit.verdictEn,
          isLight: isLight,
        ),
        _buildSummaryStatusTile(
          title: isAr ? "كفاءة البطارية وهبوط جهد المارش" : "12V Battery Cranking & Alternator",
          isOk: !card.batteryCrankingAudit.isWeakBattery,
          detail: isAr ? card.batteryCrankingAudit.verdictAr : card.batteryCrankingAudit.verdictEn,
          isLight: isLight,
        ),
      ],
    );
  }

  // TAB 2: Odometer Cross-Check
  Widget _buildOdometerTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final odo = _scorecard!.odometerAudit;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: odo.isRollbackSuspected ? errColor : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
              width: odo.isRollbackSuspected ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(odo.isRollbackSuspected ? Icons.warning : Icons.check_circle,
                        color: odo.isRollbackSuspected ? errColor : okColor, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr ? odo.verdictAr : odo.verdictEn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: odo.isRollbackSuspected ? errColor : (isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
                const SizedBox(height: 8),
                _buildAuditRow("Instrument Cluster Mileage:", "${odo.clusterMileageKm} km", isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow, isLight: isLight),
                _buildAuditRow("Engine ECM Stored Mileage:", "${odo.ecmMileageKm} km", isLight ? AppColors.lightTextPrimary : AppColors.textWhite, isLight: isLight),
                _buildAuditRow("Transmission TCM Mileage:", "${odo.tcmMileageKm} km", isLight ? AppColors.lightTextPrimary : AppColors.textWhite, isLight: isLight),
                _buildAuditRow("ABS Wheel Sensor Revolutions:", "${odo.absRevolutionsEquivalentKm} km equivalent", isLight ? AppColors.lightElectricBlue : AppColors.accentCyan, isLight: isLight),
                _buildAuditRow("Maximum Cross-Module Discrepancy:", "${odo.maxDeltaKm} km", odo.isRollbackSuspected ? errColor : okColor, isLight: isLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightCardSurfaceHighlight : const Color(0xFF151D24),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Text(
            isAr
                ? "طريقة التحقق: يقوم النظام بالاتصال بكمبيوتر المحرك، كمبيوتر ناقل الحركة، وكمبيوتر مانع الانغلاق ABS لمقارنة قراءات عداد الكيلومترات المستقلة عن لوحة العدادات لكشف أي تلاعب بالبرمجة."
                : "Forensic Methodology: The scanner interrogates ECM, TCM, and ABS independently. Instrument cluster rollbacks are immediately detected if secondary controllers maintain higher recorded odometer telemetry.",
            style: TextStyle(fontSize: 11, color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted, height: 1.4),
          ),
        ),
      ],
    );
  }

  // TAB 3: Code Clearing Fraud Hunter
  Widget _buildCodeClearingTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final fraud = _scorecard!.codeClearingAudit;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "تحليل مسح الأعطال (PIDs 0x30/31):" : "DTC Clearing Telemetry:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (fraud.isRecentlyCleared ? errColor : okColor).withOpacity(isLight ? 0.1 : 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: fraud.isRecentlyCleared ? errColor : okColor),
                      ),
                      child: Text(
                        isAr ? fraud.riskRatingAr : fraud.riskRatingEn,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: fraud.isRecentlyCleared ? errColor : okColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isAr ? fraud.explanationAr : fraud.explanationEn,
                  style: TextStyle(fontSize: 11, color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 14),
                Divider(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
                const SizedBox(height: 8),
                _buildAuditRow("Distance Driven Since DTCs Cleared:", "${fraud.distanceSinceDtcClearedKm} km", fraud.distanceSinceDtcClearedKm < 50 ? errColor : okColor, isLight: isLight),
                _buildAuditRow("Engine Warm-Up Cycles Since Reset:", "${fraud.warmUpCyclesSinceDtcCleared} cycles", fraud.warmUpCyclesSinceDtcCleared < 3 ? errColor : okColor, isLight: isLight),
                _buildAuditRow("Total Engine Run-Time Since Reset:", "${fraud.engineRunTimeMinutes} minutes", isLight ? AppColors.lightTextPrimary : AppColors.textWhite, isLight: isLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: VIN Integrity & SRS Crash
  Widget _buildVinAndSrsTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final vin = _scorecard!.vinAudit;
    final srs = _scorecard!.srsCrash;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          isAr ? "تطابق رقم الشاسيه بين الكنترولات" : "Multi-ECU VIN Integrity",
          Icons.fingerprint,
          isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildAuditRow("Registered Chassis VIN:", vin.registeredVin, isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow, isLight: isLight),
                _buildAuditRow("Engine ECM Stored VIN:", vin.ecmVin, vin.ecmVin == vin.registeredVin ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Body BCM Stored VIN:", vin.bcmVin, vin.bcmVin == vin.registeredVin ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Airbag SRS Stored VIN:", vin.srsVin, vin.srsVin == vin.registeredVin ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Transmission TCM VIN:", vin.tcmVin, vin.tcmVin == vin.registeredVin ? okColor : errColor, isLight: isLight),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(
          isAr ? "سجل حوادث الإيرباج والاصطدام" : "Airbag Deployment & Collision Record",
          Icons.security,
          isLight ? AppColors.lightWarningOrange : AppColors.warningOrange,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildAuditRow(
                  "Crash Event Records:",
                  srs.hasCrashData ? "CRASH DATA RECORDED" : "NO CRASH DATA (Clean)",
                  srs.hasCrashData ? errColor : okColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  "Squib Deployment Count:",
                  "${srs.squibDeploymentCount} squibs fired",
                  srs.squibDeploymentCount > 0 ? errColor : okColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  "Frontal Impact Record:",
                  srs.frontalImpactRecorded ? "YES (Impact Event)" : "NO",
                  srs.frontalImpactRecorded ? errColor : okColor,
                  isLight: isLight,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 5: Drivetrain Mechanical Health
  Widget _buildDrivetrainTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final mech = _scorecard!.drivetrainHealth;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final warnColor = isLight ? AppColors.lightWarningOrange : AppColors.warningOrange;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? mech.healthSummaryAr : mech.healthSummaryEn,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
                const SizedBox(height: 8),
                _buildAuditRow("Relative Compression Balance:", (mech.relativeCompressionBalancePercent.isNaN ? "not measured" : "${mech.relativeCompressionBalancePercent.toStringAsFixed(1)}%"), mech.relativeCompressionBalancePercent > 90 ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Short-Term Fuel Trim (STFT):", "${mech.shortTermFuelTrimPercent > 0 ? '+' : ''}${mech.shortTermFuelTrimPercent.toStringAsFixed(1)}%", mech.shortTermFuelTrimPercent.abs() < 10 ? okColor : warnColor, isLight: isLight),
                _buildAuditRow("Long-Term Fuel Trim (LTFT):", "${mech.longTermFuelTrimPercent > 0 ? '+' : ''}${mech.longTermFuelTrimPercent.toStringAsFixed(1)}%", mech.longTermFuelTrimPercent.abs() < 10 ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Downstream O2 Sensor Voltage:", "${mech.catalyticO2DownstreamVoltage.toStringAsFixed(2)} V", (mech.catalyticO2DownstreamVoltage >= 0.5 && mech.catalyticO2DownstreamVoltage <= 0.8) ? okColor : warnColor, isLight: isLight),
                _buildAuditRow("Transmission Fluid Temp:", "${mech.transmissionFluidTempC.toStringAsFixed(1)} °C", mech.transmissionFluidTempC < 100 ? okColor : errColor, isLight: isLight),
                _buildAuditRow("Active Misfire Counter:", "${mech.totalMisfireCount} misfires", mech.hasMisfireDetected ? errColor : okColor, isLight: isLight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 6: Defect Valuation & Workshop Repair Estimates
  Widget _buildDefectValuationTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final report = _scorecard!.repairEstimates;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: isLight ? const Color(0xFFFFFBEB) : const Color(0xFF241C15),
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLight ? const Color(0xFFFDE68A) : AppColors.primaryYellow,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "إجمالي تكاليف الإصلاح المقدرة:" : "Total Estimated Repair Cost:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                      ),
                    ),
                    Text(
                      "${report.totalEstimatedRepairCostEgp.toInt()} EGP (\$${report.totalEstimatedRepairCostUsd.toInt()})",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "الخصم المقترح للمشتري عند التفاوض:" : "Recommended Price Deduction:",
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      "${report.recommendedBuyerNegotiationDeductionEgp.toInt()} EGP",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.lightElectricBlue : AppColors.accentCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isAr ? report.financialVerdictAr : report.financialVerdictEn,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader(
          isAr ? "قائمة العيوب وقطع الغيار المطلوبة" : "Itemized Defect Repairs",
          Icons.build,
          isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
          isLight: isLight,
        ),
        const SizedBox(height: 10),
        if (report.defectItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              isAr ? "لا توجد عيوب مسجلة - السيارة بحالة فنية ممتازة" : "No active mechanical defects detected. Clean inspection.",
              style: TextStyle(
                color: isLight ? AppColors.lightSuccessGreen : AppColors.successGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          ...report.defectItems.map((item) {
            Color sevColor = isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow;
            if (item.severity == "CRITICAL_SAFETY") sevColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
            if (item.severity == "URGENT_MECHANICAL") sevColor = isLight ? AppColors.lightWarningOrange : AppColors.warningOrange;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
              elevation: isLight ? 0.5 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isLight ? AppColors.lightCardBorder : Colors.transparent),
              ),
              child: ListTile(
                title: Text(
                  isAr ? item.componentNameAr : item.componentNameEn,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      isAr ? item.descriptionAr : item.descriptionEn,
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: sevColor.withOpacity(isLight ? 0.12 : 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.severity,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: sevColor),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${item.estimatedCostEgp.toInt()} EGP (\$${item.estimatedCostUsd.toInt()})",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // TAB 6: Paint Thickness & Structural Collision Heatmap
  Widget _buildPaintTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final paint = _scorecard!.paintAudit;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final warnColor = isLight ? AppColors.lightWarningOrange : AppColors.warningOrange;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status & Verdict Card
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: paint.hasBondoDetected || paint.hasStructuralDamageSuspected
                  ? errColor
                  : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
              width: paint.hasBondoDetected || paint.hasStructuralDamageSuspected ? 1.5 : 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      paint.hasBondoDetected || paint.hasStructuralDamageSuspected
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: paint.hasBondoDetected || paint.hasStructuralDamageSuspected ? errColor : okColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        paint.hasBondoDetected
                            ? (isAr ? "تحذير: تم رصد معجون وحوادث سابقة" : "Warning: Body Filler & Collision Detected")
                            : (paint.hasStructuralDamageSuspected
                                ? (isAr ? "تحذير حرج: اشتباه تضرر بالقوايم والشاسيه" : "Critical: Structural Pillar Damage Suspected")
                                : (isAr ? "دهان فابريكا أصلي معتمد" : "Factory OEM Paint Verified")),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: paint.hasBondoDetected || paint.hasStructuralDamageSuspected ? errColor : okColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? paint.verdictAr : paint.verdictEn,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Thickness Scale Reference Legend
        _buildSectionHeader(
          isAr ? "دليل مقياس سماكة الدهان (ميكرون)" : "Paint Thickness Tolerance Guide",
          Icons.straighten,
          isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToleranceBadge("80 - 140 um", isAr ? "فابريكا OEM" : "OEM Factory", okColor, isLight),
              _buildToleranceBadge("150 - 250 um", isAr ? "رش نظافة" : "Repaint", warnColor, isLight),
              _buildToleranceBadge("> 250 um", isAr ? "معجون Bondo" : "Body Filler", errColor, isLight),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Panel Measurement Grid / List
        _buildSectionHeader(
          isAr ? "قياسات أجزاء الهيكل بالميكرون (قابلة للتعديل المباشر)" : "Panel Thickness Mapping (Live Editable)",
          Icons.directions_car,
          isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        ...paint.panelMicrons.entries.map((entry) {
          final panel = entry.key;
          final microns = entry.value;
          final isPillar = panel.contains('Pillar');
          Color badgeColor = okColor;
          String badgeTextEn = "OEM";
          String badgeTextAr = "فابريكا";
          if (microns > 250) {
            badgeColor = errColor;
            badgeTextEn = "BONDO";
            badgeTextAr = "معجون";
          } else if (microns > 140 || (isPillar && microns > 120)) {
            badgeColor = warnColor;
            badgeTextEn = isPillar ? "PILLAR WELD" : "REPAINT";
            badgeTextAr = isPillar ? "لحام قوايم" : "رش خارجي";
          }

          final panelTitle = isAr ? _getArabicPanelName(panel) : panel;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
            elevation: isLight ? 0.5 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: microns > 250
                    ? errColor.withOpacity(0.5)
                    : (isLight ? AppColors.lightCardBorder : Colors.transparent),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              panelTitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                              ),
                            ),
                            if (isPillar) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: (isLight ? AppColors.lightDangerRed : AppColors.dangerRed).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  isAr ? "شاسيه هيكلي" : "STRUCTURAL",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isLight ? AppColors.lightDangerRed : AppColors.dangerRed,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$microns um",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(isLight ? 0.12 : 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      isAr ? badgeTextAr : badgeTextEn,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quick +/- buttons for workshop gauge input
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                        onPressed: () {
                          if (microns > 20) _updatePanelMicron(panel, microns - 10);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
                        onPressed: () {
                          _updatePanelMicron(panel, microns + 10);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 7: Flood, 12V Battery & Title Registry
  Widget _buildFloodBatteryTitleTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final card = _scorecard!;
    final flood = card.floodAudit;
    final battery = card.batteryCrankingAudit;
    final title = card.titleAudit;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    final warnColor = isLight ? AppColors.lightWarningOrange : AppColors.warningOrange;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SECTION 1: FLOOD & WATER DAMAGE HUNTER
        _buildSectionHeader(
          isAr ? "كاشف الغرق وتمليح الضفيرة (Flood Hunter)" : "Flood & Water Immersion Damage Hunter",
          Icons.water_drop_outlined,
          isLight ? AppColors.lightElectricBlue : AppColors.accentCyan,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: flood.floodRiskPercent > 30 ? errColor : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "مؤشر خطر الغرق بالسيارة:" : "Vehicle Flood Immersion Risk:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                      ),
                    ),
                    Text(
                      "${flood.floodRiskPercent}%",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: flood.floodRiskPercent > 30 ? errColor : okColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (flood.floodRiskPercent / 100.0).clamp(0.0, 1.0),
                    backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF151D24),
                    valueColor: AlwaysStoppedAnimation<Color>(flood.floodRiskPercent > 30 ? errColor : okColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAuditRow(
                  isAr ? "مقاومة خط إنهاء الـ CAN Bus" : "CAN Bus Termination Resistance",
                  (flood.canBusTerminationOhms.isNaN ? "not measured" : "${flood.canBusTerminationOhms.toStringAsFixed(1)} Ohms"),
                  (flood.canBusTerminationOhms >= 55 && flood.canBusTerminationOhms <= 65) ? okColor : warnColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  isAr ? "حساسات رطوبة وتمليح كنترول الهيكل (BCM)" : "BCM Floor Harness Corrosion / Moisture",
                  flood.hasMoistureFaultDetected
                      ? (isAr ? "رطوبة وتمليح مسجل" : "Corrosion / Moisture Detected")
                      : (isAr ? "جاف تماماً وسليم" : "Clean & Dry (Passed)"),
                  flood.hasMoistureFaultDetected ? errColor : okColor,
                  isLight: isLight,
                ),
                const Divider(height: 16),
                Text(
                  isAr ? flood.verdictAr : flood.verdictEn,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // SECTION 2: 12V BATTERY CRANKING VOLTAGE DROP & ALTERNATOR
        _buildSectionHeader(
          isAr ? "اختبار هبوط جهد البطارية عند المارش وشحن الدينامو" : "12V Battery Cranking Voltage Drop & Alternator",
          Icons.battery_charging_full_outlined,
          isLight ? AppColors.lightPrimaryAmber : AppColors.primaryYellow,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: battery.isWeakBattery ? warnColor : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuditRow(
                  isAr ? "جهد البطارية أثناء السكون (Resting)" : "Battery Open-Circuit Resting Voltage",
                  (battery.restVoltage.isNaN ? "not measured" : "${battery.restVoltage.toStringAsFixed(2)} V"),
                  battery.restVoltage >= 12.4 ? okColor : warnColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  isAr ? "هبوط الجهد لحظة تدوير المارش (Cranking Dip)" : "Starter Cranking Dip Voltage (> 9.6V)",
                  (battery.crankingDipVoltage.isNaN ? "not measured" : "${battery.crankingDipVoltage.toStringAsFixed(2)} V"),
                  battery.crankingDipVoltage >= 9.6 ? okColor : errColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  isAr ? "جهد شحن الدينامو عند الدوران (Alternator)" : "Alternator Regulated Output (13.8-14.5V)",
                  (battery.chargingAlternatorVoltage.isNaN ? "not measured" : "${battery.chargingAlternatorVoltage.toStringAsFixed(2)} V"),
                  (battery.chargingAlternatorVoltage >= 13.5 && battery.chargingAlternatorVoltage <= 14.8) ? okColor : warnColor,
                  isLight: isLight,
                ),
                _buildAuditRow(
                  isAr ? "تموج تيار الدينامو المتناوب (Diode AC Ripple)" : "Alternator Diode Ripple (< 400 mV)",
                  (battery.rippleMilliVolts < 0 ? "not measured" : "${battery.rippleMilliVolts} mV"),
                  battery.rippleMilliVolts < 400 ? okColor : warnColor,
                  isLight: isLight,
                ),
                const Divider(height: 16),
                Text(
                  isAr ? battery.verdictAr : battery.verdictEn,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // SECTION 3: TITLE, SALVAGE & BANK MORTGAGE LIEN REGISTRY
        _buildSectionHeader(
          isAr ? "سجل الملكية وحظر البيع ومزادات الهلاك الكلي" : "Title, Salvage & Bank Mortgage Registry",
          Icons.account_balance_outlined,
          isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
          isLight: isLight,
        ),
        const SizedBox(height: 8),
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: !title.isCleanTitle ? errColor : (isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryStatusTile(
                  title: isAr ? "شهادة الملكية الرسمية" : "Official Title Certificate",
                  isOk: title.isCleanTitle,
                  detail: isAr ? (title.isCleanTitle ? "سليمة ونظيفة 100%" : "توجد ملاحظات على شهادة المركبة") : (title.isCleanTitle ? "Clean Title (Verified)" : "Title Brands / Salvage Issues"),
                  isLight: isLight,
                ),
                _buildSummaryStatusTile(
                  title: isAr ? "حظر بيع بنكي / رهن تجاري" : "Bank Mortgage Lien / Encumbrance",
                  isOk: !title.isBankLienActive,
                  detail: isAr ? (!title.isBankLienActive ? "خالية من أي حظر بيع بنكي" : "يوجد حظر بيع بنكي مسجل على المركبة!") : (!title.isBankLienActive ? "Zero active bank liens or mortgages" : "ACTIVE BANK LIEN REGISTERED"),
                  isLight: isLight,
                ),
                _buildSummaryStatusTile(
                  title: isAr ? "سجل مزادات الهلاك الكلي لشركات التأمين" : "Insurance Salvage / Total Loss Auctions",
                  isOk: !title.isSalvageTotalLoss,
                  detail: isAr ? (!title.isSalvageTotalLoss ? "لا توجد سجلات بيع كسيارة هالكة" : "السيارة مسجلة بمزاد خردة/هلاك كلي سابق!") : (!title.isSalvageTotalLoss ? "No salvage total loss records" : "SALVAGE AUCTION RECORD FOUND"),
                  isLight: isLight,
                ),
                const SizedBox(height: 8),
                Text(
                  isAr ? title.verdictAr : title.verdictEn,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: title.isCleanTitle ? okColor : errColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TAB 8: Manual Physical Workshop Checklist
  Widget _buildManualChecklistTab(bool isAr, bool isLight) {
    if (_scorecard == null) return const SizedBox.shrink();
    final checklist = _scorecard!.manualChecklist;
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    final warnColor = isLight ? AppColors.lightWarningOrange : AppColors.warningOrange;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    final leakColor = isLight ? const Color(0xFF9333EA) : const Color(0xFFC084FC); // Purple for leakage

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Score Header Card
        Card(
          color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
          elevation: isLight ? 0.5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isLight ? AppColors.lightCardBorder : AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (checklist.manualScore >= 80 ? okColor : (checklist.manualScore >= 60 ? warnColor : errColor)).withOpacity(isLight ? 0.1 : 0.2),
                        border: Border.all(
                          color: checklist.manualScore >= 80 ? okColor : (checklist.manualScore >= 60 ? warnColor : errColor),
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${checklist.manualScore}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: checklist.manualScore >= 80 ? okColor : (checklist.manualScore >= 60 ? warnColor : errColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? "كشف الفحص الميداني الميكانيكي (غير الكهربائي)" : "Physical Mechanical Workshop Checklist",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAr
                                ? "فحص العفشة، الشاسيه، تسريبات الزيوت، أنظمة التوجيه، الفرامل، الكاوتش، والهيكل الداخلي."
                                : "Suspension, chassis bushings, steering rack, fluid leaks, brakes, tires, and interior.",
                            style: TextStyle(
                              fontSize: 11,
                              color: isLight ? AppColors.lightTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCheckCountChip(isAr ? "سليم" : "Pass", "${checklist.passedCount}", okColor, isLight),
                    _buildCheckCountChip(isAr ? "ملاحظة" : "Marginal", "${checklist.marginalCount}", warnColor, isLight),
                    _buildCheckCountChip(isAr ? "تالف" : "Fail", "${checklist.failedCount}", errColor, isLight),
                    _buildCheckCountChip(isAr ? "تسريب" : "Leaking", "${checklist.leakingCount}", leakColor, isLight),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 6 Workshop Mechanical Categories
        ...checklist.categories.map((category) {
          final catTitle = isAr ? category.titleAr : category.titleEn;
          final catPassed = category.items.where((i) => i.status == ManualCheckItemStatus.pass).length;
          final catTotal = category.items.length;
          final hasIssue = catPassed < catTotal;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
            elevation: isLight ? 0.5 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: hasIssue
                    ? (isLight ? AppColors.lightWarningOrange.withOpacity(0.4) : AppColors.warningOrange.withOpacity(0.3))
                    : (isLight ? AppColors.lightCardBorder : Colors.transparent),
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: category.id == 'suspension' || category.id == 'oil_leakage',
              tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: Icon(
                _getCategoryIcon(category.id),
                color: isLight ? AppColors.lightPrimaryCobalt : AppColors.electricBlue,
                size: 22,
              ),
              title: Text(
                catTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                ),
              ),
              subtitle: Text(
                "$catPassed / $catTotal ${isAr ? 'عناصر مطابقة' : 'items passed'}",
                style: TextStyle(
                  fontSize: 10,
                  color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
                ),
              ),
              children: category.items.map((item) {
                final itemTitle = isAr ? item.titleAr : item.titleEn;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: isLight ? AppColors.lightCardBorder.withOpacity(0.5) : const Color(0xFF1E2830)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              itemTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: (item.severity == "SAFETY"
                                      ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed)
                                      : (item.severity == "MECHANICAL"
                                          ? (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange)
                                          : (isLight ? AppColors.lightTextMuted : Colors.grey)))
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              item.severity,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: item.severity == "SAFETY"
                                    ? (isLight ? AppColors.lightDangerRed : AppColors.dangerRed)
                                    : (item.severity == "MECHANICAL"
                                        ? (isLight ? AppColors.lightWarningOrange : AppColors.warningOrange)
                                        : (isLight ? AppColors.lightTextSecondary : Colors.grey)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 4 Interactive Status Chips
                      Row(
                        children: [
                          _buildStatusChoiceChip(
                            label: isAr ? "سليم" : "Pass",
                            isSelected: item.status == ManualCheckItemStatus.pass,
                            color: okColor,
                            isLight: isLight,
                            onTap: () => _updateCheckItemStatus(category.id, item.id, ManualCheckItemStatus.pass),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChoiceChip(
                            label: isAr ? "ملاحظة" : "Marginal",
                            isSelected: item.status == ManualCheckItemStatus.marginal,
                            color: warnColor,
                            isLight: isLight,
                            onTap: () => _updateCheckItemStatus(category.id, item.id, ManualCheckItemStatus.marginal),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChoiceChip(
                            label: isAr ? "تالف" : "Fail",
                            isSelected: item.status == ManualCheckItemStatus.fail,
                            color: errColor,
                            isLight: isLight,
                            onTap: () => _updateCheckItemStatus(category.id, item.id, ManualCheckItemStatus.fail),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChoiceChip(
                            label: isAr ? "تسريب" : "Leaking",
                            isSelected: item.status == ManualCheckItemStatus.leaking,
                            color: leakColor,
                            isLight: isLight,
                            onTap: () => _updateCheckItemStatus(category.id, item.id, ManualCheckItemStatus.leaking),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  static String _getArabicPanelName(String panel) {
    switch (panel) {
      case 'Hood':
        return 'الكبوت';
      case 'Roof':
        return 'السقف';
      case 'Trunk Lid':
        return 'شنطة السيارة';
      case 'Front Left Fender':
        return 'رفرف أمامي شمال';
      case 'Front Right Fender':
        return 'رفرف أمامي يمين';
      case 'Rear Left Quarter':
        return 'رفرف خلفي شمال';
      case 'Rear Right Quarter':
        return 'رفرف خلفي يمين';
      case 'Driver Door':
        return 'باب السائق';
      case 'Passenger Door':
        return 'باب الراكب';
      case 'A-Pillars':
        return 'القوايم الأمامية A';
      case 'B-Pillars':
        return 'القوايم الوسطى B';
      default:
        return panel;
    }
  }

  static Widget _buildToleranceBadge(String range, String label, Color color, bool isLight) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(isLight ? 0.12 : 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            range,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted),
        ),
      ],
    );
  }

  static IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'suspension':
        return Icons.build_circle_outlined;
      case 'steering':
        return Icons.navigation_outlined;
      case 'oil_leaks':
      case 'oil_leakage':
        return Icons.opacity_outlined;
      case 'tires_brakes':
        return Icons.album_outlined;
      case 'exterior_body':
        return Icons.directions_car_filled_outlined;
      case 'interior_cabin':
        return Icons.airline_seat_recline_extra_outlined;
      default:
        return Icons.check_box_outlined;
    }
  }

  static Widget _buildCheckCountChip(String label, String count, Color color, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isLight ? 0.1 : 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontSize: 10, color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted),
          ),
          Text(
            count,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusChoiceChip({
    required String label,
    required bool isSelected,
    required Color color,
    required bool isLight,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : (isLight ? AppColors.lightCardSurfaceHighlight : const Color(0xFF1E2830)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : (isLight ? AppColors.lightCardBorder : Colors.transparent),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isLight ? AppColors.lightTextSecondary : AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  static Widget _buildScoreBar(String label, int score, int maxScore, Color color, {required bool isLight}) {
    final double pct = (score / maxScore).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
                ),
              ),
              Text(
                "$score / $maxScore",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: (isLight && color == AppColors.primaryYellow) ? AppColors.lightPrimaryAmber : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: isLight ? const Color(0xFFE2E8F0) : const Color(0xFF151D24),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryStatusTile({
    required String title,
    required bool isOk,
    required String detail,
    required bool isLight,
  }) {
    final okColor = isLight ? AppColors.lightSuccessGreen : AppColors.successGreen;
    final errColor = isLight ? AppColors.lightDangerRed : AppColors.dangerRed;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isLight ? AppColors.lightCardSurface : AppColors.cardSurface,
      elevation: isLight ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isLight ? AppColors.lightCardBorder : Colors.transparent),
      ),
      child: ListTile(
        leading: Icon(
          isOk ? Icons.check_circle : Icons.warning,
          color: isOk ? okColor : errColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isLight ? AppColors.lightTextPrimary : AppColors.textWhite,
          ),
        ),
        subtitle: Text(
          detail,
          style: TextStyle(
            fontSize: 11,
            color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  static Widget _buildAuditRow(String label, String value, Color color, {required bool isLight}) {
    Color valColor = color;
    if (isLight) {
      if (color == AppColors.textWhite) valColor = AppColors.lightTextPrimary;
      if (color == AppColors.primaryYellow) valColor = AppColors.lightPrimaryAmber;
      if (color == AppColors.accentCyan) valColor = AppColors.lightElectricBlue;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: isLight ? AppColors.lightTextSecondary : AppColors.textMuted),
            ),
          ),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title, IconData icon, Color color, {required bool isLight}) {
    Color headerColor = color;
    if (isLight) {
      if (color == AppColors.primaryYellow) headerColor = AppColors.lightPrimaryAmber;
      if (color == AppColors.accentCyan) headerColor = AppColors.lightElectricBlue;
      if (color == AppColors.electricBlue) headerColor = AppColors.lightPrimaryCobalt;
    }
    return Row(
      children: [
        Icon(icon, size: 18, color: headerColor),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: headerColor)),
      ],
    );
  }
}
