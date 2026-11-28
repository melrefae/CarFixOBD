import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/dtc_model.dart';
import 'dtc_repair_guide_modal.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';

/// Card component to display Diagnostic Trouble Code details with multimeter workshop guides
class DtcCardItem extends StatefulWidget {
  final DtcModel dtc;

  const DtcCardItem({Key? key, required this.dtc}) : super(key: key);

  @override
  State<DtcCardItem> createState() => _DtcCardItemState();
}

class _DtcCardItemState extends State<DtcCardItem> {
  bool _isExpanded = false;

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.dangerRed;
      case 'high':
        return AppColors.warningOrange;
      case 'medium':
        return AppColors.primaryYellow;
      default:
        return AppColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final sevColor = _getSeverityColor(widget.dtc.severity);
    final dtc = widget.dtc;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: sevColor.withOpacity(0.4), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Code, severity badge, and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sevColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: sevColor),
                        ),
                        child: Text(
                          dtc.code,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: sevColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${_dtcTypeLabel(l10n, dtc.dtcType)} • ${_encCatLabelW(l10n, dtc.category)}",
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primaryYellow,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                isAr && dtc.titleAr.isNotEmpty ? dtc.titleAr : dtc.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                isAr && dtc.descriptionAr.isNotEmpty ? dtc.descriptionAr : dtc.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),

              // Expanded details
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF37474F)),

                // Common causes
                if (dtc.causes.isNotEmpty) ...[
                  Text(
                    l10n.encCauses,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 4),
                  ...(isAr && dtc.causesAr.isNotEmpty ? dtc.causesAr : dtc.causes).map(
                    (cause) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ", style: TextStyle(color: AppColors.primaryYellow)),
                          Expanded(
                            child: Text(cause, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Multimeter inspection guide
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.build_circle_outlined, color: AppColors.electricBlue, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            l10n.encMultimeter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr && dtc.workshopCheckAr.isNotEmpty ? dtc.workshopCheckAr : dtc.workshopCheck,
                        style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow, width: 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: Text(l10n.encViewGuide, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => DtcRepairGuideModal.show(context, dtc.code),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _dtcTypeLabel(AppLocalizations l10n, String type) {
  switch (type.toLowerCase()) {
    case 'pending':
      return l10n.dtcTypePending;
    case 'permanent':
      return l10n.dtcTypePermanent;
    default:
      return l10n.dtcTypeStored;
  }
}

String _encCatLabelW(AppLocalizations l10n, String cat) {
  switch (cat) {
    case 'Powertrain':
      return l10n.encCatPowertrain;
    case 'Transmission':
      return l10n.encCatTransmission;
    case 'Chassis':
      return l10n.encCatChassis;
    case 'Network':
      return l10n.encCatNetwork;
    case 'Body':
      return l10n.encCatBody;
    default:
      return cat;
  }
}
