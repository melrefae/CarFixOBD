import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/workshop_records.dart';

/// Quote / invoice PDF for a job card. Prices are exactly what the user typed.
class JobCardPdfService {
  /// Arabic-capable theme (Noto Sans Arabic via the printing package, downloaded once and cached).
  /// If the phone is offline the PDF still builds with the default font, and Arabic letters may not print.
  static Future<pw.ThemeData?> arabicTheme() async {
    try {
      final f = await PdfGoogleFonts.notoSansArabicRegular().timeout(const Duration(seconds: 6));
      final b = await PdfGoogleFonts.notoSansArabicBold().timeout(const Duration(seconds: 6));
      return pw.ThemeData.withFont(base: f, bold: b, fontFallback: [f]);
    } catch (_) {
      return null;
    }
  }

  static String money(double v) => '${v.toStringAsFixed(2)} EGP';

  static Future<Uint8List> build(JobCard j, {required bool invoice, String workshop = 'AutoSpect', bool arabicFont = false}) async {
    final theme = arabicFont ? await arabicTheme() : null;
    final pdf = pw.Document(theme: theme);
    final title = invoice ? 'INVOICE' : 'QUOTE';
    final d = j.createdAt.toIso8601String().substring(0, 10);
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) => [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(workshop, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: PdfColors.blueGrey800)),
        ]),
        pw.Text('Job card #${j.id.toUpperCase()}   Date: $d', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Text('Customer: ${j.customer.isEmpty ? "-" : j.customer}    Phone: ${j.phone.isEmpty ? "-" : j.phone}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Vehicle: ${j.vehicle.isEmpty ? "-" : j.vehicle}    Plate: ${j.plate.isEmpty ? "-" : j.plate}    Odometer: ${j.odometerKm.isEmpty ? "-" : "${j.odometerKm} km"}', style: const pw.TextStyle(fontSize: 10)),
        if (j.complaint.trim().isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 6), child: pw.Text('Complaint: ${j.complaint}', style: const pw.TextStyle(fontSize: 10))),
        if (j.findings.trim().isNotEmpty) pw.Padding(padding: const pw.EdgeInsets.only(top: 4), child: pw.Text('Findings: ${j.findings}', style: const pw.TextStyle(fontSize: 10))),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Type', 'Qty', 'Unit (EGP)', 'Total (EGP)'],
          data: [
            for (final i in j.items)
              [i.description, i.isLabour ? 'Labour' : 'Part', _n(i.qty), i.unitPrice.toStringAsFixed(2), i.total.toStringAsFixed(2)],
          ],
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
          cellAlignments: {2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight},
        ),
        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('Parts: ${money(j.partsTotal)}', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Labour: ${money(j.labourTotal)}', style: const pw.TextStyle(fontSize: 10)),
            if (j.discount > 0) pw.Text('Discount: -${money(j.discount)}', style: const pw.TextStyle(fontSize: 10)),
            if (j.vatPercent > 0) pw.Text('VAT ${_n(j.vatPercent)}%: ${money(j.vat)}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Text('TOTAL: ${money(j.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          ]),
        ),
        pw.SizedBox(height: 24),
        pw.Text(invoice ? 'Thank you for choosing $workshop.' : 'This quote is an estimate. Final price is confirmed after approval of the work.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    ));
    return pdf.save();
  }

  static String _n(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  static String fileName(JobCard j, bool invoice) =>
      '${invoice ? "Invoice" : "Quote"}_${j.plate.isEmpty ? j.id : j.plate.replaceAll(" ", "")}_${j.id}.pdf';

  static Future<void> share(JobCard j, {required bool invoice}) async {
    final bytes = await build(j, invoice: invoice, arabicFont: true);
    await Printing.sharePdf(bytes: bytes, filename: fileName(j, invoice));
  }
}
