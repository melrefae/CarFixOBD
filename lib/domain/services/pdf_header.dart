import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/repositories/workshop_profile.dart';
import 'pdf_arabic.dart';

/// Header block with the workshop's own name, phone, address and optional logo.
class PdfHeader {
  static pw.Widget build(WorkshopProfile p, {PdfColor color = PdfColors.black, PdfColor sub = PdfColors.grey700}) {
    pw.Widget? logo;
    if (p.logo != null) {
      try {
        logo = pw.Container(width: 48, height: 48, margin: const pw.EdgeInsets.only(right: 10), child: pw.Image(pw.MemoryImage(p.logo!), fit: pw.BoxFit.contain));
      } catch (_) {}
    }
    final lines = [if (p.phone.isNotEmpty) p.phone, if (p.address.isNotEmpty) p.address];
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
      if (logo != null) logo,
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        PA.t(p.name, size: 16, bold: true, color: color, maxW: 300),
        if (lines.isNotEmpty) PA.t(lines.join('   |   '), size: 9, color: sub, maxW: 300),
      ]),
    ]);
  }
}
