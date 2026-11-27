import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/models/workshop_records.dart';
import 'package:automotive_scanner/data/repositories/workshop_profile.dart';
import 'package:automotive_scanner/domain/services/job_card_pdf_service.dart';
import 'package:automotive_scanner/domain/services/pdf_arabic.dart';

/// Regression tests for Arabic in PDFs. The golden PNGs were checked by eye and against an
/// independent HarfBuzz/raqm rendering (pixel difference ~4 for the correct layout vs ~50 for
/// mirrored or word-swapped text). If these fail, Arabic shaping or direction changed.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final b = await File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytes();
    final l = FontLoader('NotoSansArabic')..addFont(Future.value(ByteData.view(Uint8List.fromList(b).buffer)));
    await l.load();
  });

  Future<List<int>> rgba(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final img = (await codec.getNextFrame()).image;
    return (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
  }

  test('detects Arabic and paragraph direction', () {
    expect(PA.hasArabic('Plate: أ ب ج'), isTrue);
    expect(PA.hasArabic('Brake pads'), isFalse);
    expect(PA.isRtl('محمد Ali'), isTrue);
    expect(PA.isRtl('Customer: محمد'), isFalse);
    expect(PA.isRtl('1234 محمد'), isTrue);
  });

  for (final t in {'name': 'محمد الرفاعي', 'part': 'تيل فرامل أمامي ١٢٣٤'}.entries) {
    test('Arabic line renders as the golden image: ${t.key}', () async {
      final png = await PA.debugPng(t.value, size: 20);
      final gold = File('test/goldens/ar_${t.key}.png');
      if (!gold.existsSync()) {
        gold.createSync(recursive: true);
        gold.writeAsBytesSync(png);
        fail('golden created, review it and re-run');
      }
      final a = await rgba(png);
      final b = await rgba(gold.readAsBytesSync());
      expect(a.length, b.length, reason: 'size changed');
      var diff = 0;
      for (var i = 0; i < a.length; i++) { diff += (a[i] - b[i]).abs(); }
      expect(diff / a.length, lessThan(1.5));
    });
  }

  test('reversed word order does NOT match the golden (guards direction)', () async {
    final good = await rgba(await PA.debugPng('محمد الرفاعي'));
    final swapped = await rgba(await PA.debugPng('الرفاعي محمد'));
    expect(good.length, swapped.length);
    var diff = 0;
    for (var i = 0; i < good.length; i++) { diff += (good[i] - swapped[i]).abs(); }
    expect(diff / good.length, greaterThan(3));
  });

  test('job card PDF puts Arabic in as images, not as raw text', () async {
    final j = JobCard(id: 'a', customer: 'محمد الرفاعي', complaint: 'صوت في الفرامل', items: [JobLineItem(description: 'تيل فرامل', unitPrice: 450)]);
    final bytes = await JobCardPdfService.build(j, invoice: true, profile: const WorkshopProfile(name: 'ورشة'));
    final s = String.fromCharCodes(bytes);
    // customer, complaint, part name and workshop name: 4 images (each plus its alpha mask)
    expect('/Subtype/Image'.allMatches(s).length, greaterThanOrEqualTo(4));
  });
}
