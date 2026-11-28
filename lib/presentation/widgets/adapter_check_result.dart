import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/services/adapter_check.dart';

/// Shows the adapter check outcome: one honest verdict card, then every
/// question/answer line. Arabic when [isAr]; English otherwise.
class AdapterCheckResultView extends StatelessWidget {
  final AdapterCheckReport report;
  final bool isAr;
  const AdapterCheckResultView({Key? key, required this.report, required this.isAr}) : super(key: key);

  Color _verdictColor() {
    switch (report.verdict) {
      case AdapterVerdict.likelyGenuine:
        return Colors.greenAccent;
      case AdapterVerdict.likelyClone:
        return Colors.orangeAccent;
      case AdapterVerdict.unknown:
        return AppColors.textMuted;
    }
  }

  IconData _verdictIcon() {
    switch (report.verdict) {
      case AdapterVerdict.likelyGenuine:
        return Icons.verified_outlined;
      case AdapterVerdict.likelyClone:
        return Icons.warning_amber_rounded;
      case AdapterVerdict.unknown:
        return Icons.help_outline;
    }
  }

  Color _levelColor(CheckLevel l) {
    switch (l) {
      case CheckLevel.ok:
        return Colors.greenAccent;
      case CheckLevel.warn:
        return Colors.orangeAccent;
      case CheckLevel.fail:
        return AppColors.dangerRed;
      case CheckLevel.info:
        return AppColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vc = _verdictColor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: vc.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: vc.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(_verdictIcon(), color: vc, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(report.verdictHeadline(isAr),
                      style: TextStyle(color: vc, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(report.verdictBody(isAr),
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 12, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...report.items.map((it) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.circle, size: 7, color: _levelColor(it.level)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.localizedTitle(isAr),
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(it.localizedDetail(isAr),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
