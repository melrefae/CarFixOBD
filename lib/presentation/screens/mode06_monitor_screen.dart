import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _filter = 'All';

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

  List<Mode06TestResult> _applyFilter(List<Mode06TestResult> raw) {
    switch (_filter) {
      case 'Misfires':
        return raw.where((r) => r.mid >= 0xA1 && r.mid <= 0xA9).toList();
      case 'O2 & Catalyst':
        return raw.where((r) => (r.mid >= 0x01 && r.mid <= 0x08) || r.mid == 0x21 || r.mid == 0x22).toList();
      case 'Failed Only':
        return raw.where((r) => !r.isPassed).toList();
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
    final failedCount = state.mode06Results.where((r) => !r.isPassed).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "اختبارات المكونات والمس فاير (Mode 06)" : "Mode \$06 Misfire & Component Monitor"),
        actions: [
          IconButton(
            icon: state.isScanningMode06
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryYellow),
                  )
                : const Icon(Icons.refresh, color: AppColors.primaryYellow),
            tooltip: isAr ? "إعادة الفحص" : "Scan Mode \$06",
            onPressed: state.isConnected && !state.isScanningMode06
                ? () => state.fetchMode06Monitors()
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
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
                        isAr
                            ? "نتائج Mode 06: $total اختبار ($failedCount خارج الحدود)"
                            : "Mode \$06 Summary: $total Monitors ($failedCount Out-of-Spec)",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isAr
                            ? "يكشف عدادات تفويت السلندرات (Misfire) وحالة علبة البيئة والحساسات قبل إضاءة لمبة الأعطال."
                            : "Reads early cylinder misfire counters, catalyst & O2 margins before a Check Engine light triggers.",
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
                for (final label in const ['All', 'Misfires', 'O2 & Catalyst', 'Failed Only'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == label,
                      selectedColor: AppColors.primaryYellow,
                      backgroundColor: AppColors.cardSurface,
                      labelStyle: TextStyle(
                        color: _filter == label ? Colors.black : AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (v) {
                        if (v) setState(() => _filter = label);
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
                        isAr
                            ? "يرجى توصيل فيشة الفحص بالسيارة أولاً لقراءة اختبارات Mode 06."
                            : "Connect an OBD adapter to query real-time Mode \$06 component monitors.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                : state.isScanningMode06
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryYellow),
                            SizedBox(height: 12),
                            Text(
                              "Interrogating ECU Mode \$06 Test IDs...",
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
                                    isAr
                                        ? "لا توجد اختبارات Mode 06 متاحة أو الكنترول لا يدعم Mode 06 في هذا التصفية."
                                        : "No Mode \$06 test records returned by this ECU for the current filter.",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: Text(isAr ? "إعادة المسح" : "Re-Scan Mode \$06"),
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
    final color = r.isPassed ? AppColors.successGreen : AppColors.dangerRed;
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
                Icon(r.isPassed ? Icons.check_circle : Icons.error, color: color, size: 20),
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
                    r.isPassed ? "PASS" : "FAIL",
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
                  "MID ${r.midHex} • TID ${r.tidHex}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  "${r.measuredValue.toStringAsFixed(r.measuredValue == r.measuredValue.roundToDouble() ? 0 : 2)} ${r.unit}",
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
                Text("Min: ${r.minLimit.toStringAsFixed(1)} ${r.unit}",
                    style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
                Text("Max: ${r.maxLimit.toStringAsFixed(1)} ${r.unit}",
                    style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
