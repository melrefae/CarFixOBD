import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../providers/obd_state.dart';
import '../widgets/dtc_card_item.dart';
import 'reports_screen.dart';

/// Quick diagnostic scan screen (30-second automated health assessment)
class QuickScanScreen extends StatefulWidget {
  const QuickScanScreen({Key? key}) : super(key: key);

  @override
  State<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends State<QuickScanScreen> {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ObdState>(context, listen: false).runQuickScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).quickScan30s),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).rescan,
            onPressed: state.isScanning ? null : () => state.runQuickScan(),
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
                  Text(AppLocalizations.of(context).scanningVinMil, style: const TextStyle(color: AppColors.textWhite)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Health status banner
                  _buildHealthBanner(state),

                  const SizedBox(height: 16),

                  // Vehicle basic data card
                  _buildVehicleDataCard(state),

                  const SizedBox(height: 20),

                  // Detected trouble codes header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).detectedDtcs(state.storedDtcs.length),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryYellow),
                      ),
                      if (state.storedDtcs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(4)),
                          child: Text(AppLocalizations.of(context).activeFaults, style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (state.storedDtcs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.successGreen, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).noDtcsFound,
                              style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.storedDtcs.map((dtc) => DtcCardItem(dtc: dtc)),

                  const SizedBox(height: 24),

                  // Save job card section
                  _buildSaveJobCardSection(context, state),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthBanner(ObdState state) {
    final isClean = state.storedDtcs.isEmpty && !state.isMilOn;
    final color = isClean ? AppColors.successGreen : AppColors.dangerRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(isClean ? Icons.verified : Icons.warning_amber_rounded, color: color, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isClean ? AppLocalizations.of(context).optimalHealth : AppLocalizations.of(context).codesDetectedCel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  isClean
                      ? AppLocalizations.of(context).noMisfires
                      : AppLocalizations.of(context).codesNeedInspection(state.storedDtcs.length),
                  style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDataCard(ObdState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _buildDataRow(AppLocalizations.of(context).vinLabel, state.currentVin == 'N/A' ? AppLocalizations.of(context).notAvailable : state.currentVin, isMonospace: true),
            const Divider(color: Color(0xFF37474F)),
            _buildDataRow(AppLocalizations.of(context).protocolLabel, state.activeProtocol == 'Not Detected' ? AppLocalizations.of(context).notDetected : state.activeProtocol),
            const Divider(color: Color(0xFF37474F)),
            _buildDataRow(AppLocalizations.of(context).batteryVoltageLabel, "${state.batteryVoltage.toStringAsFixed(1)}V"),
            const Divider(color: Color(0xFF37474F)),
            _buildDataRow(
              AppLocalizations.of(context).milStatusLabel,
              state.isMilOn ? AppLocalizations.of(context).milOn : AppLocalizations.of(context).milOff,
              textColor: state.isMilOn ? AppColors.dangerRed : AppColors.successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isMonospace = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.textWhite,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveJobCardSection(BuildContext context, ObdState state) {
    return Card(
      color: AppColors.cardSurfaceHighlight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).saveJobCard,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _plateController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).licensePlateLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _customerController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).customerName),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).phoneWhatsappNumber),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).technicianNotes),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, color: Colors.black),
              label: Text(AppLocalizations.of(context).saveReport),
              onPressed: () async {
                if (_plateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).enterPlate), backgroundColor: AppColors.warningOrange),
                  );
                  return;
                }

                await state.saveCurrentInspection(
                  plateNumber: _plateController.text.trim(),
                  customerName: _customerController.text.trim().isEmpty ? AppLocalizations.of(context).walkInCustomer : _customerController.text.trim(),
                  customerPhone: _phoneController.text.trim(),
                  notes: _notesController.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).jobCardSaved), backgroundColor: AppColors.successGreen),
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
