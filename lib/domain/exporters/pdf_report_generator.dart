import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../data/models/inspection_report.dart';

/// PDF inspection report generator for printing and customer sharing
class PdfReportGenerator {
  static Future<Uint8List> generatePdf(InspectionReport report) async {
    final pdf = pw.Document();

    final dateFormatted = DateFormat('yyyy-MM-dd HH:mm').format(report.timestamp);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.ltr,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.amber800, width: 2)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "AutoSpect",
                            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800),
                          ),
                          pw.Text(
                            report.workshopName.isNotEmpty ? report.workshopName : "Automotive Diagnostic Center",
                            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                          ),
                          pw.Text("OBD-II Computer Diagnostic & Inspection Report", style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700)),
                          pw.Text("Contact: +20 155 366 6635", style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Date: $dateFormatted", style: const pw.TextStyle(fontSize: 10)),
                          pw.Text("Report ID: #${report.id.substring(0, 8)}", style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // Vehicle & Customer Info Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Vehicle: ${report.vehicleMakeModel}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text("Plate: ${report.plateNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("VIN: ${report.vin}", style: const pw.TextStyle(fontSize: 10)),
                          pw.Text("Customer: ${report.customerName}", style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Battery Voltage: ${report.batteryVoltage.toStringAsFixed(1)} V", style: const pw.TextStyle(fontSize: 10)),
                          pw.Text("Check Engine (MIL): ${report.milStatusOn ? 'ACTIVE (ON)' : 'CLEAR (OFF)'}",
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: report.milStatusOn ? PdfColors.red800 : PdfColors.green800,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // DTCs Table
                pw.Text(
                  "Diagnostic Trouble Codes (DTCs):",
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                ),
                pw.SizedBox(height: 6),
                if (report.dtcsFound.isEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(4)),
                    child: pw.Text("All Systems Clear! No active or stored trouble codes detected in ECU memory.",
                        style: const pw.TextStyle(color: PdfColors.green900, fontSize: 10)),
                  )
                else
                  pw.Column(
                    children: report.dtcsFound.map((dtc) {
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 6),
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text("${dtc.code} - ${dtc.title}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                                pw.Text("Severity: ${dtc.severity}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(dtc.description, style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                pw.SizedBox(height: 15),

                // Live Sensor Snapshot
                if (report.liveSensorsSnapshot.isNotEmpty) ...[
                  pw.Text(
                    "Live Sensor Snapshot at Inspection:",
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: report.liveSensorsSnapshot.entries.map((e) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text("${e.key}: ${e.value}", style: const pw.TextStyle(fontSize: 9)),
                      );
                    }).toList(),
                  ),
                  pw.SizedBox(height: 15),
                ],

                // Technician Recommendations
                pw.Text(
                  "Technician Assessment & Recommendations:",
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    report.mechanicNotes.isNotEmpty ? report.mechanicNotes : "Vehicle diagnostic inspection completed without additional remarks.",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),

                pw.Spacer(),

                // Workshop Signature Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Inspector / Technician Signature: _______________________", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("AutoSpect | OBD-II Diagnostics", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
