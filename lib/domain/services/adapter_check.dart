import '../../data/datasources/elm327_driver.dart';
import '../../core/utils/hex_parser.dart';

enum CheckLevel { ok, warn, fail, info }

class AdapterCheckItem {
  final CheckLevel level;
  final String title;
  final String detail;
  const AdapterCheckItem(this.level, this.title, this.detail);
  @override
  String toString() => '[${level.name}] $title: $detail';
}

class AdapterCheckReport {
  final List<AdapterCheckItem> items;
  final int medianLatencyMs;
  final double successRate;
  const AdapterCheckReport(this.items, this.medianLatencyMs, this.successRate);
  bool get hasFail => items.any((i) => i.level == CheckLevel.fail);
  String toText() => items.map((e) => e.toString()).join('\n');
}

/// Asks the connected adapter a fixed set of questions and reports what it answered.
/// Nothing here is guessed: each line is a reply the adapter gave (or did not give).
/// It cannot prove an adapter is genuine. Version strings are only hints.
class AdapterCheck {
  static Future<AdapterCheckReport> run(Elm327Driver d, {int repeats = 10}) async {
    final items = <AdapterCheckItem>[];

    // 1. Identity
    final ati = await d.executeCommand('AT I', timeout: const Duration(seconds: 2));
    final okId = ati.isNotEmpty && ati != 'TIMEOUT' && !ati.contains('?');
    items.add(AdapterCheckItem(okId ? CheckLevel.info : CheckLevel.warn, 'Adapter says (AT I)', okId ? ati : 'no usable answer'));
    final m = RegExp(r'ELM327\s*v?(\d+\.\d+)', caseSensitive: false).firstMatch(ati);
    if (m != null) {
      final v = m.group(1)!;
      if (v.startsWith('2.')) {
        items.add(AdapterCheckItem(CheckLevel.warn, 'Version string $v', 'Versions 2.x are very often printed by copies of the chip; a genuine ELM327 is 1.x up to 1.5a. This is a hint, not proof. Watch for dropped replies below.'));
      } else {
        items.add(AdapterCheckItem(CheckLevel.info, 'Version string $v', 'Plausible for an ELM327. Strings can be copied.'));
      }
    }
    final at1 = await d.executeCommand('AT @1', timeout: const Duration(seconds: 2));
    if (at1.isNotEmpty && at1 != 'TIMEOUT' && !at1.contains('?')) {
      items.add(AdapterCheckItem(CheckLevel.info, 'Device description (AT @1)', at1));
    }
    final stn = await d.executeCommand('ST I', timeout: const Duration(seconds: 2));
    if (stn.isNotEmpty && stn != 'TIMEOUT' && !stn.contains('?')) {
      items.add(AdapterCheckItem(CheckLevel.ok, 'STN chip (OBDLink / vLinker type)', stn));
    }

    // 2. Voltage
    final rv = await d.executeCommand('AT RV', timeout: const Duration(seconds: 2));
    final volt = HexParser.parseVoltage(rv);
    items.add(AdapterCheckItem(volt != null ? CheckLevel.info : CheckLevel.warn, 'Battery voltage (AT RV)',
        volt != null ? '${volt.toStringAsFixed(1)} V. Compare with a meter; a big difference means the adapter reading is not reliable.' : 'no usable answer'));

    // 3. Protocol
    final dpn = await d.executeCommand('AT DPN', timeout: const Duration(seconds: 2));
    final dp = await d.executeCommand('AT DP', timeout: const Duration(seconds: 2));
    items.add(AdapterCheckItem(dp.isNotEmpty && dp != 'TIMEOUT' && !dp.contains('?') ? CheckLevel.info : CheckLevel.warn,
        'Protocol in use', 'AT DP: $dp | AT DPN: $dpn'));

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
      items.add(const AdapterCheckItem(CheckLevel.warn, 'Repeat test (0100)', 'skipped: no ECU connected. Turn the key ON and connect to the car first.'));
    } else if (good == repeats) {
      items.add(AdapterCheckItem(CheckLevel.ok, 'Repeat test (0100 x$repeats)', 'all $repeats answered, median $median ms'));
    } else if (good == 0) {
      items.add(AdapterCheckItem(CheckLevel.fail, 'Repeat test (0100 x$repeats)', 'no valid answer'));
    } else {
      items.add(AdapterCheckItem(CheckLevel.warn, 'Repeat test (0100 x$repeats)', '$good of $repeats answered. Dropped replies: cable/Bluetooth link, weak power, or a poor adapter.'));
    }

    // 5. Slow adapter tolerance: longer waits when the adapter is slow
    if (median > 500) {
      d.timeoutScale = 2.0;
      items.add(AdapterCheckItem(CheckLevel.info, 'Slow adapter or bus', 'median $median ms per request; the app now waits twice as long for each reply in this session.'));
    } else if (median > 0) {
      d.timeoutScale = 1.0;
    }

    // 6. Long reply (VIN needs several lines on most buses). Some cars do not support it.
    if (d.isEcuConnected) {
      final vin = await d.executeCommand('0902', timeout: const Duration(seconds: 5));
      final vinOk = vin != 'TIMEOUT' && !HexParser.isErrorResponse(vin) && HexParser.parseVin(HexParser.extractBytes(vin)).length >= 15;
      items.add(AdapterCheckItem(vinOk ? CheckLevel.ok : CheckLevel.info, 'Long reply (VIN, mode 09 02)',
          vinOk ? 'multi-line reply read correctly' : 'no VIN. Many cars before 2005 do not provide it, so this alone is not an adapter fault.'));
    }

    return AdapterCheckReport(items, median, rate);
  }
}
