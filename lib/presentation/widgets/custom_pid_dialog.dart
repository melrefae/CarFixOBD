import 'package:flutter/material.dart';
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
        children: const [
          Icon(Icons.add_chart, color: AppColors.primaryYellow, size: 26),
          SizedBox(width: 10),
          Text(
            "Add Custom PID",
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
                decoration: const InputDecoration(labelText: "Sensor Name (e.g. AT Fluid Temp)"),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameArController,
                decoration: const InputDecoration(labelText: "Arabic Name (Optional)"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _modeController,
                      decoration: const InputDecoration(labelText: "Mode (Hex)"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _pidController,
                      decoration: const InputDecoration(labelText: "PID (Hex)"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _formulaController,
                decoration: const InputDecoration(
                  labelText: "Formula (e.g. A - 40 or ((A*256)+B)/10)",
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: "Unit (°C / Bar / %)"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Min Value"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _maxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Max Value"),
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
          child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textMuted)),
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
          child: const Text("Save PID"),
        ),
      ],
    );
  }
}
