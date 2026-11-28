import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/core/utils/hex_parser.dart';
import 'package:automotive_scanner/core/utils/mode06_tables.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/data/repositories/obd_repository.dart';

class Fake implements ObdConnection {
  final _c = StreamController<String>.broadcast();
  final String Function(String) reply;
  Fake(this.reply);
  @override Future<bool> connect(String t) async => true;
  @override Future<void> disconnect() async {}
  @override Stream<String> get responseStream => _c.stream;
  @override bool get isConnected => true;
  @override String get connectionType => 'fake';
  @override Future<void> send(String command) async {
    final cmd = command.trim().toUpperCase().replaceAll(' ', '');
    if (cmd.isEmpty) return;
    final r = reply(cmd);
    scheduleMicrotask(() => _c.add('$r\r\r>'));
  }
}

void main() {
  // Values below are the worked examples printed in SAE J1979 (2006), section 6.5.4 and 7.6.4.
  test('Mode 06 example: O2 threshold 0.365 V and switch time 72 ms from the standard', () {
    final bytes = [
      0x46,
      0x01, 0x01, 0x0A, 0x0B, 0xB0, 0x0B, 0xB0, 0x0B, 0xB0,
      0x01, 0x05, 0x10, 0x00, 0x48, 0x00, 0x00, 0x00, 0x64,
      0x01, 0x85, 0x24, 0x00, 0x96, 0x00, 0x4B, 0xFF, 0xFF,
    ];
    final r = HexParser.parseMode06Results(bytes);
    expect(r.length, 3);
    expect(r[0].measuredValue, closeTo(365.2, 0.5)); // mV: 2992 x 0.122 (the standard shows 0.365 V)
    expect(r[0].unit, 'mV');
    expect(r[1].measuredValue, 72);
    expect(r[1].unit, 'ms');
    expect(r[1].maxLimit, 100);
    expect(r[1].isPassed, true);
    expect(r[2].measuredValue, 150);
    expect(r[2].minLimit, 75);
    expect(r[2].unit, 'counts');
    expect(r[0].monitorName, contains('Bank 1 - Sensor 1'));
  });

  test('all-zero record (never completed) is "no result", not a pass', () {
    final r = HexParser.parseMode06Results([0x46, 0x21, 0x87, 0x2E, 0, 0, 0, 0, 0, 0]);
    expect(r.single.noResult, true);
    expect(r.single.isPassed, false);
  });

  test('unknown UASID is shown raw and flagged, not converted', () {
    final r = HexParser.parseMode06Results([0x46, 0xE1, 0x80, 0x77, 0x00, 0x10, 0x00, 0x00, 0x00, 0x20]);
    expect(r.single.scalingKnown, false);
    expect(r.single.measuredValue, 16);
  });

  test('scaling facts from the standard: 0x16 has a -40 offset, 0x0C is 0.01 V, signed 0x96', () {
    expect(uasConvert(0x16, 0x0190), closeTo(0.1 * 400 - 40, 0.001));
    expect(uasConvert(0x0C, 1234), closeTo(12.34, 0.001));
    expect(uasConvert(0x96, 0xFFF6), closeTo(-1.0, 0.001));
    expect(uasConvert(0xC5, 1), isNull);
  });

  test('MID names follow the standard (B2S1 is MID 05, misfire cylinder 3 is A4)', () {
    expect(mode06MidName(0x05), 'Oxygen sensor monitor Bank 2 - Sensor 1');
    expect(mode06MidName(0x03), 'Oxygen sensor monitor Bank 1 - Sensor 3');
    expect(mode06MidName(0xA4), 'Misfire cylinder 3');
  });

  test('a record whose MID is 0x46 is not mistaken for the response byte', () {
    final r = HexParser.parseMode06Results([0x46, 0x46, 0x01, 0x24, 0, 5, 0, 0, 0, 9]);
    expect(r.single.mid, 0x46);
    expect(r.single.measuredValue, 5);
  });

  test('Mode 05 example from the standard: 450 mV constant, switch time 72 ms (0-100 ms)', () {
    final r = HexParser.parseMode05Results([0x45, 0x01, 0x01, 0x5A, 0x45, 0x05, 0x01, 0x12, 0x00, 0x19]);
    expect(r.length, 2);
    expect(r[0].measuredValue, closeTo(0.45, 1e-9));
    expect(r[0].unit, 'V');
    expect(r[0].hasLimits, false);
    expect(r[1].measuredValue, closeTo(0.072, 1e-9));
    expect(r[1].maxLimit, closeTo(0.1, 1e-9));
    expect(r[1].isPassed, true);
    expect(r[1].source, 'Mode 05');
  });

  test('CAN car: support chain 06 00 -> 06 20 is followed and only supported MIDs are read', () async {
    final asked = <String>[];
    final f = Fake((c) {
      asked.add(c);
      switch (c) {
        case '0600': return '46 00 80 00 00 01'; // MID 01 supported, 0x20 range follows
        case '0620': return '46 20 80 00 00 00'; // MID 21 supported, no more
        case '0601': return '46 01 01 0A 0B B0 0B B0 0B B0';
        case '0621': return '46 21 87 2E 00 00 00 00 00 00';
        case 'ATDP': return 'ISO 15765-4 (CAN 11/500)';
      }
      return 'NO DATA';
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    final repo = ObdRepository(driver: d);
    final r = await repo.readMode06Monitors();
    expect(asked.where((c) => c.startsWith('06')).toList(), ['0600', '0620', '0601', '0621']);
    expect(r.length, 2);
    expect(r[1].noResult, true);
  });

  test('older bus: Mode 06 is not attempted, Mode 05 is read and the reason is given', () async {
    final asked = <String>[];
    final f = Fake((c) {
      asked.add(c);
      switch (c) {
        case '0100': return '41 00 BE 3E B8 11';
        case 'ATDP': return 'ISO 14230-4 (KWP FAST)';
        case '0113': return '41 13 03'; // B1S1 + B1S2
        case '050101': return '45 01 01 5A';
        case '050501': return '45 05 01 12 00 19';
      }
      return 'NO DATA';
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    final repo = ObdRepository(driver: d);
    final r = await repo.readMode06Monitors();
    expect(asked.any((c) => c == '0600'), false);
    expect(r.length, 2);
    expect(repo.mode06Note, contains('Mode 06 is CAN only'));
  });

  test('older bus, car answers nothing to Mode 05: explanation, no invented data', () async {
    final f = Fake((c) {
      if (c == '0100') return '41 00 BE 3E B8 11';
      if (c == 'ATDP') return 'ISO 9141-2';
      return 'NO DATA';
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    final repo = ObdRepository(driver: d);
    expect(await repo.readMode06Monitors(), isEmpty);
    expect(repo.mode06Note, contains('did not answer'));
  });
}
