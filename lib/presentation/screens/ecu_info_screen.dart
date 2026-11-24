import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../providers/obd_state.dart';

/// ECU calibration and module programming screen (OBD-II Mode 09)
class EcuInfoScreen extends StatefulWidget {
  const EcuInfoScreen({Key? key}) : super(key: key);

  @override
  State<EcuInfoScreen> createState() => _EcuInfoScreenState();
}

class _EcuInfoScreenState extends State<EcuInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObdState>(context, listen: false).fetchEcuDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final details = state.ecuDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.ecuInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh ECU Details",
            onPressed: state.isScanning ? null : () => state.fetchEcuDetails(),
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
                  Text("Querying VIN and calibration identification numbers (Mode 09)...", style: TextStyle(color: AppColors.textWhite)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Module Name Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.memory, color: AppColors.primaryYellow, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Electronic Control Module:", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                details['ecu_name'] ?? 'Engine Control Module (ECM/PCM)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Calibration Data Table
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            title: "${AppStrings.vinLabel}:",
                            value: details['vin'] ?? state.currentVin,
                            subtitle: "Standard vehicle electronic identification number stored in ECU flash memory",
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: "Calibration ID (CALID):",
                            value: details['cal_id'] ?? 'Not Available',
                            subtitle: "Software revision and firmware version installed on the engine control unit",
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: "Calibration Verification Number (CVN):",
                            value: details['cvn'] ?? 'Not Available',
                            subtitle: "Cryptographic checksum ensuring software calibration integrity and authenticity",
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: "${AppStrings.protocolLabel}:",
                            value: state.activeProtocol,
                            subtitle: "Active serial communications bus protocol over OBD-II DLC connector",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tuning & Modification Inspection Tip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.electricBlue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.security, color: AppColors.electricBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Technician Note (ECU Software & Remap Check):",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.electricBlue),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          "CALID and CVN codes are used by service centers to verify whether vehicle software has been altered with aftermarket ECU tunes/remaps, or if an official OEM factory reflash is needed to resolve technical service bulletins.",
                          style: TextStyle(fontSize: 11, color: AppColors.textWhite, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({required String title, required String value, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow)),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
