import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../providers/obd_state.dart';

/// Freeze Frame screen (OBD-II Mode 02)
/// Displays snapshot of all engine parameters and sensor readings at the exact instant the DTC was logged
class FreezeFrameScreen extends StatefulWidget {
  const FreezeFrameScreen({Key? key}) : super(key: key);

  @override
  State<FreezeFrameScreen> createState() => _FreezeFrameScreenState();
}

class _FreezeFrameScreenState extends State<FreezeFrameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObdState>(context, listen: false).fetchFreezeFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final ff = state.freezeFrame;

    final hasNoData = ff == null ||
        ff.dtcCode.isEmpty ||
        ff.dtcCode == "لا يوجد كود مسجل" ||
        ff.dtcCode == "No DTC Recorded" ||
        ff.dtcCode == "P0000";

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.freezeFrame),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Freeze Frame",
            onPressed: state.isScanning ? null : () => state.fetchFreezeFrame(),
          ),
        ],
      ),
      body: state.isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: AppColors.primaryYellow),
                  SizedBox(height: 16),
                  Text("Querying Freeze Frame data from ECU (Mode 02)...", style: TextStyle(color: AppColors.textWhite)),
                ],
              ),
            )
          : hasNoData
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textDisabled),
                      SizedBox(height: 16),
                      Text("No Freeze Frame logged in ECU memory", style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Freeze frame data is stored only when a confirmed DTC is first triggered", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Triggering DTC Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.dangerRed, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Triggering Fault Code:", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  Text(
                                    ff.dtcCode,
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dangerRed, letterSpacing: 1.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Snapshot Sensor Data Table
                      const Text(
                        "Sensor Snapshot at Event Occurrence:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
                      ),
                      const SizedBox(height: 10),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _buildSnapshotRow("Engine Speed (RPM):", "${ff.engineRpm.toStringAsFixed(0)} RPM", Icons.speed),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Vehicle Speed:", "${ff.vehicleSpeed.toStringAsFixed(0)} km/h", Icons.directions_car),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Coolant Temperature:", "${ff.coolantTemp.toStringAsFixed(0)} °C", Icons.thermostat),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Calculated Engine Load:", "${ff.engineLoad.toStringAsFixed(1)} %", Icons.fitness_center),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Throttle Position (TPS):", "${ff.throttlePosition.toStringAsFixed(1)} %", Icons.touch_app),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Manifold Absolute Pressure:", "${ff.manifoldPressure.toStringAsFixed(0)} kPa", Icons.compress),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Intake Air Temp (IAT):", "${ff.intakeAirTemp.toStringAsFixed(0)} °C", Icons.air),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Short Term Fuel Trim (STFT):", "${ff.shortTermFuelTrim.toStringAsFixed(1)} %", Icons.local_gas_station),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow("Long Term Fuel Trim (LTFT):", "${ff.longTermFuelTrim.toStringAsFixed(1)} %", Icons.timeline),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Technician Diagnostic Deductions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceHighlight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.lightbulb_outline, color: AppColors.primaryYellow, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Workshop Analysis & Operating Context:",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "This fault was triggered while driving at ${ff.vehicleSpeed.toStringAsFixed(0)} km/h with engine running at ${ff.engineRpm.toStringAsFixed(0)} RPM and coolant at ${ff.coolantTemp.toStringAsFixed(0)}°C.\n"
                              "Long Term Fuel Trim was (${ff.longTermFuelTrim.toStringAsFixed(1)}%), indicating the ECU was compensating for a ${ff.longTermFuelTrim > 10 ? 'lean condition (intake vacuum leak or low fuel pressure)' : ff.longTermFuelTrim < -10 ? 'rich condition (dripping injector or restricted air intake)' : 'normal air-fuel ratio'} at the moment the fault occurred.",
                              style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSnapshotRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryYellow),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
