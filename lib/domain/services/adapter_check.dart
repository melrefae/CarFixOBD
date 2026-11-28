import '../../data/datasources/elm327_driver.dart';
import '../../core/utils/hex_parser.dart';

enum CheckLevel { ok, warn, fail, info }

/// Overall judgement about the connected adapter.
/// [likelyGenuine] means no clone sign was found; it is never proof of a genuine chip.
enum AdapterVerdict { likelyGenuine, likelyClone, unknown }

class AdapterCheckItem {
  final CheckLevel level;
  final String title;
  final String detail;
  final String titleAr;
  final String detailAr;
  const AdapterCheckItem(this.level, this.title, this.detail, {this.titleAr = '', this.detailAr = ''});
  String localizedTitle(bool ar) => ar && titleAr.isNotEmpty ? titleAr : title;
  String localizedDetail(bool ar) => ar && detailAr.isNotEmpty ? detailAr : detail;
  @override
  String toString() => '[${level.name}] $title: $detail';
  String toLocalizedString(bool ar) => '[${level.name}] ${localizedTitle(ar)}: ${localizedDetail(ar)}';
}

class AdapterCheckReport {
  final List<AdapterCheckItem> items;
  final int medianLatencyMs;
  final double successRate;
  final AdapterVerdict verdict;
  const AdapterCheckReport(this.items, this.medianLatencyMs, this.successRate, this.verdict);
  bool get hasFail => items.any((i) => i.level == CheckLevel.fail);
  String toText({bool ar = false}) => items.map((e) => e.toLocalizedString(ar)).join('\n');

  String verdictHeadline(bool ar) {
    switch (verdict) {
      case AdapterVerdict.likelyGenuine:
        return ar ? 'مفيش علامات تقليد ظاهرة' : 'No clone signs found';
      case AdapterVerdict.likelyClone:
        return ar ? 'الفيشة دي غالباً نسخة مقلدة' : 'This adapter is probably a copy (clone)';
      case AdapterVerdict.unknown:
        return ar ? 'مش قادر أحكم على الفيشة' : 'Cannot judge this adapter';
    }
  }

  String verdictBody(bool ar) {
    switch (verdict) {
      case AdapterVerdict.likelyGenuine:
        return ar
            ? 'الفيشة ردت على كل الاختبارات من غير سقوط. نص النسخة ممكن يتنسخ، فده مش دليل قاطع إن الشريحة أصلية، لكن مفيش حاجة فشلت.'
            : 'The adapter answered every test without dropped replies. A version string can be copied, so this is not proof of a genuine chip, but nothing failed.';
      case AdapterVerdict.likelyClone:
        return ar
            ? 'النسخ المقلدة بتتهنيج كتير مع العربيات القديمة بنظام K-line (ISO 9141 / KWP، أغلب العربيات قبل 2008) ومع الأوامر الطويلة. لو التطبيق مش بيتصل بعربية قديمة أو بيقطع، الفيشة ممكن تكون هي السبب. فيشة أصلية ELM327 إصدار 1.x أو OBDLink أو vLinker أضمن.'
            : 'Clones often fail with older K-line cars (ISO 9141 / KWP, most cars before 2008) and with long replies. If the app cannot connect to an older car or drops replies, the adapter may be the reason. A genuine ELM327 v1.x, OBDLink or vLinker is safer.';
      case AdapterVerdict.unknown:
        return ar
            ? 'الفيشة مردتش على أسئلة الهوية، فمفيش دليل كفاية. نتيجة اختبار التكرار تحت هي الحكم الأفضل.'
            : 'The adapter did not answer the identity questions, so there is not enough evidence. The repeat test below is the best judge.';
    }
  }
}

/// Asks the connected adapter a fixed set of questions and reports what it answered.
/// Nothing here is guessed: each line is a reply the adapter gave (or did not give).
/// It cannot prove an adapter is genuine. Version strings are only hints.
class AdapterCheck {
  static Future<AdapterCheckReport> run(Elm327Driver d, {int repeats = 10}) async {
    final items = <AdapterCheckItem>[];

    var sawV2x = false;
    var sawV1x = false;
    var sawStn = false;
    var identityAnswered = false;

    // 1. Identity
    final ati = await d.executeCommand('AT I', timeout: const Duration(seconds: 2));
    final okId = ati.isNotEmpty && ati != 'TIMEOUT' && !ati.contains('?');
    identityAnswered = okId;
    items.add(AdapterCheckItem(okId ? CheckLevel.info : CheckLevel.warn, 'Adapter says (AT I)', okId ? ati : 'no usable answer',
        titleAr: 'رد الفيشة (AT I)', detailAr: okId ? ati : 'مفيش رد مفيد'));
    final m = RegExp(r'ELM327\s*v?(\d+\.\d+)', caseSensitive: false).firstMatch(ati);
    if (m != null) {
      final v = m.group(1)!;
      if (v.startsWith('2.')) {
        sawV2x = true;
        items.add(AdapterCheckItem(CheckLevel.warn, 'Version string $v',
            'Versions 2.x are very often printed by copies of the chip; a genuine ELM327 is 1.x up to 1.5a. This is a hint, not proof. Watch for dropped replies below.',
            titleAr: 'نص النسخة $v',
            detailAr: 'النسخ 2.x غالباً بتتطبع على شرائح مقلدة؛ الـ ELM327 الأصلي 1.x لحد 1.5a. ده مؤشر مش دليل قاطع. راقب الردود الساقطة تحت.'));
      } else {
        sawV1x = true;
        items.add(AdapterCheckItem(CheckLevel.info, 'Version string $v', 'Plausible for an ELM327. Strings can be copied.',
            titleAr: 'نص النسخة $v', detailAr: 'منطقي لفيشة ELM327. النصوص ممكن تتنسخ.'));
      }
    }
    final at1 = await d.executeCommand('AT @1', timeout: const Duration(seconds: 2));
    if (at1.isNotEmpty && at1 != 'TIMEOUT' && !at1.contains('?')) {
      items.add(AdapterCheckItem(CheckLevel.info, 'Device description (AT @1)', at1,
          titleAr: 'وصف الجهاز (AT @1)', detailAr: at1));
    }
    final stn = await d.executeCommand('ST I', timeout: const Duration(seconds: 2));
    if (stn.isNotEmpty && stn != 'TIMEOUT' && !stn.contains('?')) {
      sawStn = true;
      items.add(AdapterCheckItem(CheckLevel.ok, 'STN chip (OBDLink / vLinker type)', stn,
          titleAr: 'شريحة STN (نوع OBDLink / vLinker)', detailAr: stn));
    }

    // 2. Voltage
    final rv = await d.executeCommand('AT RV', timeout: const Duration(seconds: 2));
    final volt = HexParser.parseVoltage(rv);
    items.add(AdapterCheckItem(volt != null ? CheckLevel.info : CheckLevel.warn, 'Battery voltage (AT RV)',
        volt != null ? '${volt.toStringAsFixed(1)} V. Compare with a meter; a big difference means the adapter reading is not reliable.' : 'no usable answer',
        titleAr: 'فولت البطارية (AT RV)',
        detailAr: volt != null ? '${volt.toStringAsFixed(1)} V. قارنها بجهاز قياس؛ فرق كبير يعني إن قراءة الفيشة مش مضمونة.' : 'مفيش رد مفيد'));

    // 3. Protocol
    final dpn = await d.executeCommand('AT DPN', timeout: const Duration(seconds: 2));
    final dp = await d.executeCommand('AT DP', timeout: const Duration(seconds: 2));
    final dpOk = dp.isNotEmpty && dp != 'TIMEOUT' && !dp.contains('?');
    items.add(AdapterCheckItem(dpOk ? CheckLevel.info : CheckLevel.warn, 'Protocol in use', 'AT DP: $dp | AT DPN: $dpn',
        titleAr: 'البروتوكول المستخدم', detailAr: 'AT DP: $dp | AT DPN: $dpn'));

    // 4. Repeated request: dropped replies and speed
    final times = <int>[];
    int good = 0;
    if (d.isEcuConnected) {
      for (var i = 0; i < repeats; i++) {
        final sw = Stopwatch()..start();
        final r = await d.executeCommand('0100', timeout: const Duration(seconds: 3));
        sw.stop();
        final ok = RegExp(r'(?<![0-9A-F])41\s?00(\s?[0-9A-F]{2}){4}', caseSensitive: false).hasMatch(r);
        if (ok) { good++; times.add(sw.elapsedMilliseconds); }
      }
    }
    times.sort();
    final median = times.isEmpty ? 0 : times[times.length ~/ 2];
    final rate = d.isEcuConnected ? good / repeats : 0.0;
    if (!d.isEcuConnected) {
      items.add(const AdapterCheckItem(CheckLevel.warn, 'Repeat test (0100)', 'skipped: no ECU connected. Turn the key ON and connect to the car first.',
          titleAr: 'اختبار التكرار (0100)', detailAr: 'اتخطى: مفيش كنترول متوصل. افتح الكونتاك واتصل بالعربية الأول.'));
    } else if (good == repeats) {
      items.add(AdapterCheckItem(CheckLevel.ok, 'Repeat test (0100 x$repeats)', 'all $repeats answered, median $median ms',
          titleAr: 'اختبار التكرار (0100 ×$repeats)', detailAr: 'كل الـ $repeats ردوا، الوسيط $median مللي ثانية'));
    } else if (good == 0) {
      items.add(AdapterCheckItem(CheckLevel.fail, 'Repeat test (0100 x$repeats)', 'no valid answer',
          titleAr: 'اختبار التكرار (0100 ×$repeats)', detailAr: 'مفيش رد صحيح'));
    } else {
      items.add(AdapterCheckItem(CheckLevel.warn, 'Repeat test (0100 x$repeats)', '$good of $repeats answered. Dropped replies: cable/Bluetooth link, weak power, or a poor adapter.',
          titleAr: 'اختبار التكرار (0100 ×$repeats)', detailAr: '$good من $repeats ردوا. الردود الساقطة سببها كابل/بلوتوث أو كهربا ضعيفة أو فيشة رديئة.'));
    }

    // 5. Slow adapter tolerance: longer waits when the adapter is slow
    if (median > 500) {
      d.timeoutScale = 2.0;
      items.add(AdapterCheckItem(CheckLevel.info, 'Slow adapter or bus', 'median $median ms per request; the app now waits twice as long for each reply in this session.',
          titleAr: 'فيشة أو باص بطيء', detailAr: 'الوسيط $median مللي ثانية للطلب؛ التطبيق هيستنى الضعف لكل رد في الجلسة دي.'));
    } else if (median > 0) {
      d.timeoutScale = 1.0;
    }

    // 6. Long reply (VIN needs several lines on most buses). Some cars do not support it.
    if (d.isEcuConnected) {
      final vin = await d.executeCommand('0902', timeout: const Duration(seconds: 5));
      final vinOk = vin != 'TIMEOUT' && !HexParser.isErrorResponse(vin) && HexParser.parseVin(HexParser.extractBytes(vin)).length >= 15;
      items.add(AdapterCheckItem(vinOk ? CheckLevel.ok : CheckLevel.info, 'Long reply (VIN, mode 09 02)',
          vinOk ? 'multi-line reply read correctly' : 'no VIN. Many cars before 2005 do not provide it, so this alone is not an adapter fault.',
          titleAr: 'رد طويل (VIN، مود 09 02)',
          detailAr: vinOk ? 'الرد متعدد السطور اتقري صح' : 'مفيش VIN. عربيات كتير قبل 2005 مش بتوفره، فده لوحده مش عيب في الفيشة.'));
    }

    // Verdict: never proof, only what the evidence above shows.
    final AdapterVerdict verdict;
    if (sawV2x || (d.isEcuConnected && rate > 0 && rate < 0.8)) {
      verdict = AdapterVerdict.likelyClone;
    } else if (sawStn || (sawV1x && d.isEcuConnected && rate == 1.0)) {
      verdict = AdapterVerdict.likelyGenuine;
    } else if (!identityAnswered) {
      verdict = AdapterVerdict.unknown;
    } else {
      verdict = AdapterVerdict.unknown;
    }

    return AdapterCheckReport(items, median, rate, verdict);
  }
}
