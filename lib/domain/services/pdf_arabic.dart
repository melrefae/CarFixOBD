import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart' show TextDirection;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Correct Arabic in PDFs.
///
/// The `pdf` package does not shape Arabic letters or order bidirectional text reliably
/// (measured: letters come out in the wrong order, and its RTL mode draws broken glyphs with
/// these fonts). So any text line that contains Arabic is laid out by Flutter's own text engine
/// (HarfBuzz shaping, ICU bidi, the bundled Noto Sans Arabic font) and placed in the PDF as a
/// high-resolution image. Text without Arabic stays normal selectable PDF text.
/// Trade-off: Arabic lines in a PDF cannot be selected or searched as text.
class PA {
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
  static final RegExp _strongLatin = RegExp(r'[A-Za-z]');
  static const double scale = 4;

  static bool hasArabic(String s) => _arabic.hasMatch(s);

  /// Paragraph direction: by the first strong letter, like the Unicode bidi default.
  static bool isRtl(String s) {
    for (final r in s.runes) {
      final c = String.fromCharCode(r);
      if (_arabic.hasMatch(c)) return true;
      if (_strongLatin.hasMatch(c)) return false;
    }
    return false;
  }

  static final Map<String, _Img> _cache = {};
  static List<_Spec>? _collect;

  static String _key(String s, double size, bool bold, PdfColor c, double maxW) =>
      '$s|$size|$bold|${c.toInt()}|$maxW';

  /// Drop-in for pw.Text. Arabic-containing lines become an image (after [run] prepared them).
  static pw.Widget t(String s, {double size = 10, bool bold = false, PdfColor color = PdfColors.black, double maxW = 480}) {
    pw.Widget plain() => pw.Text(s, style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color));
    if (!hasArabic(s)) return plain();
    final k = _key(s, size, bold, color, maxW);
    if (_collect != null) {
      _collect!.add(_Spec(s, size, bold, color, maxW));
      return pw.SizedBox(height: size * 1.4);
    }
    final img = _cache[k];
    if (img == null) return plain();
    return pw.Align(
      alignment: img.rtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Image(pw.MemoryImage(img.png), width: img.w, height: img.h),
    );
  }

  /// For tests: the PNG that would be placed in the PDF for [s].
  static Future<Uint8List> debugPng(String s, {double size = 20}) async =>
      (await _render(_Spec(s, size, false, PdfColors.black, 480))).png;

  /// Runs [build] twice: a dry run collects the Arabic lines, they are rendered, then the real run.
  static Future<Uint8List> run(Future<Uint8List> Function() build) async {
    if (_collect != null) return build();
    _collect = [];
    List<_Spec> specs;
    try {
      await build();
    } finally {
      specs = _collect!;
      _collect = null;
    }
    for (final sp in specs) {
      final k = _key(sp.s, sp.size, sp.bold, sp.color, sp.maxW);
      if (_cache.containsKey(k)) continue;
      try {
        _cache[k] = await _render(sp);
      } catch (_) {}
    }
    return build();
  }

  static Future<_Img> _render(_Spec sp) async {
    final rtl = isRtl(sp.s);
    ui.Paragraph make(double width) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: rtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        textAlign: ui.TextAlign.start,
        fontFamily: 'Roboto',
        fontSize: sp.size * scale,
        fontWeight: sp.bold ? ui.FontWeight.bold : ui.FontWeight.normal,
      ))
        ..pushStyle(ui.TextStyle(
          color: ui.Color(0xFF000000 | (sp.color.toInt() & 0xFFFFFF)),
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['NotoSansArabic'],
          fontSize: sp.size * scale,
          fontWeight: sp.bold ? ui.FontWeight.bold : ui.FontWeight.normal,
        ))
        ..addText(sp.s);
      return pb.build()..layout(ui.ParagraphConstraints(width: width));
    }

    final first = make(sp.maxW * scale);
    final w = (first.longestLine.ceilToDouble() + 2).clamp(1.0, sp.maxW * scale);
    // lay out again at the exact width so right-to-left lines fill the image box
    final para = make(w);
    final h = para.height.ceilToDouble().clamp(1.0, 4000.0);
    final rec = ui.PictureRecorder();
    final canvas = ui.Canvas(rec);
    canvas.drawParagraph(para, ui.Offset.zero);
    final pic = rec.endRecording();
    final image = await pic.toImage(w.toInt(), h.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return _Img(data!.buffer.asUint8List(), w / scale, h / scale, rtl);
  }
}

class _Spec {
  final String s;
  final double size;
  final bool bold;
  final PdfColor color;
  final double maxW;
  _Spec(this.s, this.size, this.bold, this.color, this.maxW);
}

class _Img {
  final Uint8List png;
  final double w;
  final double h;
  final bool rtl;
  _Img(this.png, this.w, this.h, this.rtl);
}
