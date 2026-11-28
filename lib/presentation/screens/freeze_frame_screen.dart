import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context).freezeFrameTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).refreshFreezeFrame,
            onPressed: state.isScanning ? null : () => state.fetchFreezeFrame(),
          ),
        ],
      ),
      body: state.isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryYellow),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context).queryingFreezeFrame, style: const TextStyle(color: AppColors.textWhite)),
                ],
              ),
            )
          : hasNoData
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 64, color: AppColors.textDisabled),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context).noFreezeFrame, style: const TextStyle(color: AppColors.textWhite, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context).freezeFrameStoredWhen, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                                  Text(AppLocalizations.of(context).triggeringFaultCode, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                      Text(
                        AppLocalizations.of(context).sensorSnapshot,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
                      ),
                      const SizedBox(height: 10),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _buildSnapshotRow(AppLocalizations.of(context).engineSpeedRpm, "${ff.engineRpm.toStringAsFixed(0)} RPM", Icons.speed),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).vehicleSpeedLabel, "${ff.vehicleSpeed.toStringAsFixed(0)} km/h", Icons.directions_car),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).coolantTempLabel, "${ff.coolantTemp.toStringAsFixed(0)} °C", Icons.thermostat),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).engineLoadLabel, "${ff.engineLoad.toStringAsFixed(1)} %", Icons.fitness_center),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).throttlePositionLabel, "${ff.throttlePosition.toStringAsFixed(1)} %", Icons.touch_app),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).manifoldPressureLabel, "${ff.manifoldPressure.toStringAsFixed(0)} kPa", Icons.compress),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).intakeAirTempLabel, "${ff.intakeAirTemp.toStringAsFixed(0)} °C", Icons.air),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).stftLabel, "${ff.shortTermFuelTrim.toStringAsFixed(1)} %", Icons.local_gas_station),
                              const Divider(color: Color(0xFF37474F)),
                              _buildSnapshotRow(AppLocalizations.of(context).ltftLabel, "${ff.longTermFuelTrim.toStringAsFixed(1)} %", Icons.timeline),
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
                              children: [
                                const Icon(Icons.lightbulb_outline, color: AppColors.primaryYellow, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).workshopAnalysis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${AppLocalizations.of(context).faultContextLine1(ff.vehicleSpeed.toStringAsFixed(0), ff.engineRpm.toStringAsFixed(0), ff.coolantTemp.toStringAsFixed(0))}\n"
                              "${AppLocalizations.of(context).faultContextLine2(ff.longTermFuelTrim.toStringAsFixed(1), ff.longTermFuelTrim > 10 ? AppLocalizations.of(context).leanCondition : ff.longTermFuelTrim < -10 ? AppLocalizations.of(context).richCondition : AppLocalizations.of(context).normalCondition)}",
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
