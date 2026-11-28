import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context).ecuInfo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).refreshEcuDetails,
            onPressed: state.isScanning ? null : () => state.fetchEcuDetails(),
          ),
        ],
      ),
      body: state.isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryYellow),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context).ecuQuerying, style: TextStyle(color: AppColors.textWhite)),
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
                              Text(AppLocalizations.of(context).ecuModuleLabel, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                details['ecu_name'] ?? AppLocalizations.of(context).ecuDefaultName,
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
                            title: AppLocalizations.of(context).vinLabel,
                            value: (details['vin'] ?? state.currentVin) == 'N/A' ? AppLocalizations.of(context).notAvailable : (details['vin'] ?? state.currentVin),
                            subtitle: AppLocalizations.of(context).vinSubtitle,
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: AppLocalizations.of(context).calIdLabel,
                            value: details['cal_id'] ?? AppLocalizations.of(context).notAvailable,
                            subtitle: AppLocalizations.of(context).calIdSubtitle,
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: AppLocalizations.of(context).cvnLabel,
                            value: details['cvn'] ?? AppLocalizations.of(context).notAvailable,
                            subtitle: AppLocalizations.of(context).cvnSubtitle,
                          ),
                          const Divider(color: Color(0xFF37474F)),
                          _buildDetailRow(
                            title: AppLocalizations.of(context).protocolLabel,
                            value: state.activeProtocol == 'Not Detected' ? AppLocalizations.of(context).notDetected : state.activeProtocol,
                            subtitle: AppLocalizations.of(context).protocolSubtitle,
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
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security, color: AppColors.electricBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).ecuTechNoteTitle,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.electricBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context).ecuTechNoteBody,
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
