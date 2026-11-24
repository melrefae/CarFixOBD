import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';

/// Safety confirmation modal before sending OBD Mode 04 (Clear DTCs & Freeze Frames)
class SafetyConfirmationDialog extends StatefulWidget {
  final VoidCallback onConfirmed;

  const SafetyConfirmationDialog({Key? key, required this.onConfirmed}) : super(key: key);

  @override
  State<SafetyConfirmationDialog> createState() => _SafetyConfirmationDialogState();
}

class _SafetyConfirmationDialogState extends State<SafetyConfirmationDialog> {
  bool _engineStoppedConfirmed = false;
  bool _ignitionOnConfirmed = false;

  bool get _canProceed => _engineStoppedConfirmed && _ignitionOnConfirmed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dangerRed, width: 2),
      ),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 32),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.clearWarningTitle,
              style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.clearWarningBody,
              style: TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF37474F)),
            const Text(
              "Mandatory Safety Pre-Conditions:",
              style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            // Confirm engine OFF
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.dangerRed,
              title: const Text(
                "I confirm vehicle engine is completely OFF (RPM = 0)",
                style: TextStyle(fontSize: 12, color: AppColors.textWhite),
              ),
              value: _engineStoppedConfirmed,
              onChanged: (val) {
                setState(() {
                  _engineStoppedConfirmed = val ?? false;
                });
              },
            ),

            // Confirm Key ON
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.dangerRed,
              title: const Text(
                "I confirm ignition is ON with instrument cluster illuminated (Key ON / Ignition RUN)",
                style: TextStyle(fontSize: 12, color: AppColors.textWhite),
              ),
              value: _ignitionOnConfirmed,
              onChanged: (val) {
                setState(() {
                  _ignitionOnConfirmed = val ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _canProceed ? AppColors.dangerRed : Colors.grey.shade800,
            foregroundColor: Colors.white,
          ),
          onPressed: _canProceed
              ? () {
                  Navigator.pop(context);
                  widget.onConfirmed();
                }
              : null,
          child: const Text(AppStrings.confirmClear),
        ),
      ],
    );
  }
}
