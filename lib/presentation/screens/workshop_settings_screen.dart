import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/services/safety_alarm_service.dart';
import '../providers/obd_state.dart';
import 'cloud_backup_screen.dart';

/// Workshop profile, branding, and safety alarm thresholds screen
class WorkshopSettingsScreen extends StatefulWidget {
  const WorkshopSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WorkshopSettingsScreen> createState() => _WorkshopSettingsScreenState();
}

class _WorkshopSettingsScreenState extends State<WorkshopSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _engineerController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  double _maxCoolant = 103.0;
  double _minVoltage = 11.8;
  double _maxVoltage = 15.2;
  bool _audioAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _engineerController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('workshop_name') ?? AppStrings.defaultWorkshopName;
      _phoneController.text = prefs.getString('workshop_phone') ?? AppStrings.defaultWorkshopPhone;
      _addressController.text = prefs.getString('workshop_address') ?? AppStrings.defaultWorkshopAddress;
      _engineerController.text = prefs.getString('workshop_engineer') ?? "Certified Diagnostic Engineer";
      _feeController.text = prefs.getString('inspection_fee') ?? "300 EGP";

      _maxCoolant = prefs.getDouble('alarm_max_coolant') ?? 103.0;
      _minVoltage = prefs.getDouble('alarm_min_voltage') ?? 11.8;
      _maxVoltage = prefs.getDouble('alarm_max_voltage') ?? 15.2;
      _audioAlerts = prefs.getBool('alarm_audio_enabled') ?? true;

      _isLoading = false;
    });

    final alarmService = SafetyAlarmService();
    alarmService.maxCoolantTemp = _maxCoolant;
    alarmService.minBatteryVoltage = _minVoltage;
    alarmService.maxBatteryVoltage = _maxVoltage;
    alarmService.isAudioEnabled = _audioAlerts;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workshop_name', _nameController.text.trim());
    await prefs.setString('workshop_phone', _phoneController.text.trim());
    await prefs.setString('workshop_address', _addressController.text.trim());
    await prefs.setString('workshop_engineer', _engineerController.text.trim());
    await prefs.setString('inspection_fee', _feeController.text.trim());

    await prefs.setDouble('alarm_max_coolant', _maxCoolant);
    await prefs.setDouble('alarm_min_voltage', _minVoltage);
    await prefs.setDouble('alarm_max_voltage', _maxVoltage);
    await prefs.setBool('alarm_audio_enabled', _audioAlerts);

    final alarmService = SafetyAlarmService();
    alarmService.maxCoolantTemp = _maxCoolant;
    alarmService.minBatteryVoltage = _minVoltage;
    alarmService.maxBatteryVoltage = _maxVoltage;
    alarmService.isAudioEnabled = _audioAlerts;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Workshop branding and alarm settings saved successfully! ✅"),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
      );
    }
    final obdState = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.workshopSettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AutoSpect Brand Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2633), Color(0xFF141922)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.6), width: 1.5),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primaryYellow, size: 28),
                      SizedBox(width: 8),
                      Text(
                        "AutoSpect",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Automotive Diagnostic & Fleet Telemetry Suite",
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone, color: AppColors.successGreen, size: 16),
                        const SizedBox(width: 6),
                        SelectableText(
                          _phoneController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.copy, color: AppColors.primaryYellow, size: 16),
                          tooltip: "Copy Number",
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _phoneController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Phone number copied to clipboard")),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Workshop details for PDF reports
            const Text(
              "Workshop Information (PDF Reports):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
            ),
            const SizedBox(height: 12),

            _buildTextField("Workshop Center Name", _nameController, Icons.storefront),
            const SizedBox(height: 10),
            _buildTextField("Phone & WhatsApp", _phoneController, Icons.phone_android, keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            _buildTextField("Workshop Address", _addressController, Icons.location_on_outlined),
            const SizedBox(height: 10),
            _buildTextField("Default Inspection Engineer", _engineerController, Icons.badge_outlined),
            const SizedBox(height: 10),
            _buildTextField("Standard Inspection Fee", _feeController, Icons.payments_outlined),

            const SizedBox(height: 24),

            // Safety thresholds & Alarm limits
            const Text(
              "Safety Thresholds & Real-Time Alarms:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Enable Alarm Sounds & Haptic Vibrate", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Triggers popup alert and haptic feedback when a sensor exceeds safe limits"),
                    value: _audioAlerts,
                    activeColor: AppColors.primaryYellow,
                    onChanged: (val) => setState(() => _audioAlerts = val),
                  ),
                  const Divider(),

                  // Coolant temp alarm limit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Engine Overheating Alarm Limit:", style: TextStyle(fontSize: 14)),
                      Text("${_maxCoolant.toInt()} °C", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                    ],
                  ),
                  Slider(
                    value: _maxCoolant,
                    min: 95.0,
                    max: 115.0,
                    divisions: 20,
                    activeColor: AppColors.dangerRed,
                    label: "${_maxCoolant.toInt()}°C",
                    onChanged: (val) => setState(() => _maxCoolant = val),
                  ),
                  const SizedBox(height: 10),

                  // Alternator undercharge alarm limit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Alternator Low Voltage Limit:", style: TextStyle(fontSize: 14)),
                      Text("${_minVoltage.toStringAsFixed(1)} V", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warningOrange)),
                    ],
                  ),
                  Slider(
                    value: _minVoltage,
                    min: 10.5,
                    max: 12.5,
                    divisions: 20,
                    activeColor: AppColors.warningOrange,
                    label: "${_minVoltage.toStringAsFixed(1)}V",
                    onChanged: (val) => setState(() => _minVoltage = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cloud Backup & Fleet Sync button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                  side: const BorderSide(color: AppColors.accentBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.cloud_sync),
                label: const Text("Cloud Backup & Fleet Webhook Sync", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CloudBackupScreen()),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // OBD Adapter & Auto-Connection Persistence Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bluetooth_connected, color: AppColors.accentCyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        obdState.isArabic ? "إعدادات الاتصال التلقائي بالمحول" : "OBD Adapter & Auto-Reconnect",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      obdState.isArabic ? "الاتصال التلقائي عند فتح التطبيق" : "Auto-reconnect on app launch",
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
                    ),
                    subtitle: Text(
                      obdState.isArabic
                          ? "إعادة الاتصال تلقائياً بآخر فيشة OBD تم الاقتران بها"
                          : "Automatically connects to the last paired adapter on startup",
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    activeColor: AppColors.accentCyan,
                    value: obdState.isAutoConnectEnabled,
                    onChanged: (val) => obdState.toggleAutoConnect(val),
                  ),
                  const Divider(color: AppColors.cardBorder),
                  if (obdState.lastSavedAdapterTarget != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                obdState.lastSavedAdapterName ?? "Paired OBD Adapter",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 13),
                              ),
                              Text(
                                "${obdState.lastSavedAdapterType ?? 'Adapter'}: ${obdState.lastSavedAdapterTarget}",
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.dangerRed),
                          label: Text(
                            obdState.isArabic ? "مسح المحول" : "Forget",
                            style: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
                          ),
                          onPressed: () => obdState.clearSavedAdapter(),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      obdState.isArabic
                          ? "لم يتم حفظ أي محول حتى الآن. اتصل بمحولك ليتم حفظه تلقائياً."
                          : "No saved adapter yet. Connect your adapter to save it for auto-reconnect.",
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Save Workshop Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _saveSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.primaryYellow, size: 20),
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
