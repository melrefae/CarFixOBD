import 'package:flutter/material.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/vehicle_profile.dart';

/// Modal dialog to add or edit a custom OBD-II PID formula for a vehicle profile
class CustomPidDialog extends StatefulWidget {
  final Function(CustomPid) onSaved;

  const CustomPidDialog({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<CustomPidDialog> createState() => _CustomPidDialogState();
}

class _CustomPidDialogState extends State<CustomPidDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();
  final _modeController = TextEditingController(text: "21");
  final _pidController = TextEditingController();
  final _formulaController = TextEditingController(text: "A - 40");
  final _unitController = TextEditingController(text: "°C");
  final _minController = TextEditingController(text: "-40");
  final _maxController = TextEditingController(text: "150");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.add_chart, color: AppColors.primaryYellow, size: 26),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context).customPidTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameEnController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).sensorNameLabel),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).requiredField : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameArController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context).arabicNameOptional),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _modeController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).modeHexLabel),
                      validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).requiredField : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _pidController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).pidHexLabel),
                      validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).requiredField : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _formulaController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).formulaLabel,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).requiredField : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).unitLabel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).minValueLabel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).maxValueLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel, style: const TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final enName = _nameEnController.text.trim();
              final arName = _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : enName;
              final newPid = CustomPid(
                name: arName,
                nameEn: enName,
                mode: _modeController.text.trim(),
                pid: _pidController.text.trim(),
                formula: _formulaController.text.trim(),
                unit: _unitController.text.trim(),
                min: double.tryParse(_minController.text) ?? 0.0,
                max: double.tryParse(_maxController.text) ?? 100.0,
              );
              widget.onSaved(newPid);
              Navigator.pop(context);
            }
          },
          child: Text(AppLocalizations.of(context).savePid),
        ),
      ],
    );
  }
}
