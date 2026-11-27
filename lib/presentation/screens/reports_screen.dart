import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/inspection_report.dart';
import '../../domain/exporters/pdf_report_generator.dart';
import '../providers/obd_state.dart';
import 'cloud_backup_screen.dart';

/// Inspection reports history and PDF sharing screen
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = "";

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    final filteredReports = state.savedReports.where((r) {
      if (_filter.isEmpty) return true;
      return r.plateNumber.toLowerCase().contains(_filter) ||
          r.vin.toLowerCase().contains(_filter) ||
          r.customerName.toLowerCase().contains(_filter);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inspectionReports),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: AppColors.primaryYellow),
            tooltip: "Cloud Backup & Fleet Sync",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudBackupScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _filter = val.trim().toLowerCase();
                });
              },
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: "Search by plate number, VIN, or customer...",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          Expanded(
            child: filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.folder_open, size: 56, color: AppColors.textDisabled),
                        SizedBox(height: 12),
                        Text("No saved inspection reports found", style: TextStyle(color: AppColors.textMuted)),
                        SizedBox(height: 6),
                        Text(
                          "Run a 'Quick Scan' to generate and save customer inspection reports",
                          style: TextStyle(fontSize: 11, color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(context, report, state);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, InspectionReport report, ObdState state) {
    final dateStr = DateFormat('yyyy/MM/dd - hh:mm a').format(report.timestamp);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryYellow),
                      ),
                      child: Text(
                        report.plateNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryYellow),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(report.vehicleMakeModel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.textDisabled, size: 20),
                  tooltip: "Delete Report",
                  onPressed: () async {
                    await state.deleteReport(report.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Customer: ${report.customerName} | Phone: ${report.customerPhone}", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text("VIN: ${report.vin}", style: const TextStyle(fontSize: 11, color: AppColors.textDisabled, fontFamily: 'monospace')),
            Text("Date: $dateStr", style: const TextStyle(fontSize: 10, color: AppColors.textDisabled)),

            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: report.dtcsFound.isEmpty ? AppColors.successGreen.withOpacity(0.2) : AppColors.dangerRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.dtcsFound.isEmpty ? "All Systems Clear" : "${report.dtcsFound.length} Trouble Codes",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: report.dtcsFound.isEmpty ? AppColors.successGreen : AppColors.dangerRed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Voltage: ${report.batteryVoltage.toStringAsFixed(1)}V", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),

            if (report.mechanicNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.cardSurfaceHighlight, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  "Technician Notes: ${report.mechanicNotes}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textWhite),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text(AppStrings.exportPdf, style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    final pdfBytes = await PdfReportGenerator.generatePdf(report);
                    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text(AppStrings.shareWhatsapp, style: TextStyle(fontSize: 12)),
                  onPressed: () async {
                    final pdfBytes = await PdfReportGenerator.generatePdf(report);
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: "Inspection_Report_${report.plateNumber}.pdf",
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
