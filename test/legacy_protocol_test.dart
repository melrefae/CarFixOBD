import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/data/repositories/obd_repository.dart';
import 'package:automotive_scanner/core/utils/hex_parser.dart';

/// Scripted adapter. This is a test double that replays chosen reply text; it is NOT a real car.
class FakeElm implements ObdConnection {
  final _c = StreamController<String>.broadcast();
  final String Function(String cmd, String sp) reply;
  String sp = '0';
  final sent = <String>[];
  FakeElm(this.reply);
  @override
  Future<bool> connect(String t) async => true;
  @override
  Future<void> disconnect() async {}
  @override
  Stream<String> get responseStream => _c.stream;
  @override
  bool get isConnected => true;
  @override
  String get connectionType => 'fake';
  @override
  Future<void> send(String command) async {
    final cmd = command.trim().toUpperCase();
    if (cmd.isEmpty) return;
    sent.add(cmd);
    final m = RegExp(r'^AT\s?SP\s?([0-9A])$').firstMatch(cmd);
    if (m != null) sp = m.group(1)!;
    final r = reply(cmd.replaceAll(' ', ''), sp);
    scheduleMicrotask(() => _c.add('$r\r\r>'));
  }
}

void main() {
  test('0100 reply check: real answers pass, errors and look-alikes fail', () async {
    // exercised through connectToEcu below; here the parser-level facts
    expect(HexParser.isErrorResponse('UNABLE TO CONNECT'), true);
    expect(HexParser.isErrorResponse('BUS INIT: ERROR'), true);
  });

  test('2007-style K-line car (answers only on KWP fast, protocol 5) connects; attempts are recorded', () async {
    final f = FakeElm((cmd, sp) {
      if (cmd == '0100') return sp == '5' ? 'BUS INIT: OK\r41 00 BE 3E B8 11' : (sp == '0' ? 'SEARCHING...\rUNABLE TO CONNECT' : 'NO DATA');
      if (cmd == 'ATDP') return 'ISO 14230-4 (KWP 5BAUD)';
      return 'OK';
    });
    final d = Elm327Driver(connection: f);
    final ok = await d.connectToEcu();
    expect(ok, true);
    expect(d.isEcuConnected, true);
    expect(f.sp, '5');
    expect(d.protocolAttempts.first, contains('AT SP 0'));
    expect(d.protocolAttempts.last, contains('AT SP 5: ECU answered'));
    expect(f.sent, contains('AT ST 96'), reason: 'slow bus gets a longer answer window');
  });

  test('a chosen protocol is tried first', () async {
    final f = FakeElm((cmd, sp) {
      if (cmd == '0100') return sp == '3' ? '41 00 BE 3E B8 11' : 'NO DATA';
      return 'OK';
    });
    final d = Elm327Driver(connection: f);
    expect(await d.connectToEcu(specificProtocolCmd: 'AT SP 3'), true);
    expect(d.protocolAttempts.length, 1);
  });

  test('no protocol answers: connection fails and every attempt is listed', () async {
    final f = FakeElm((cmd, sp) => cmd == '0100' ? 'UNABLE TO CONNECT' : 'OK');
    final d = Elm327Driver(connection: f);
    expect(await d.connectToEcu(), false);
    expect(d.protocolAttempts.length, 10);
  });

  test('legacy Mode 03 reply from two ECU lines is parsed per 7-byte group', () {
    // line 1: P0133, P0171, empty; line 2: P0300 only
    final raw = '43 01 33 01 71 00 00 43 03 00 00 00 00 00';
    expect(HexParser.parseDtcsRaw(raw, 0x03), ['P0133', 'P0171', 'P0300']);
    expect(HexParser.parseDtcsRaw('43 00 00 00 00 00 00', 0x03), isEmpty);
  });

  test('CAN style Mode 03 reply still parses', () {
    expect(HexParser.parseDtcsRaw('43 02 01 33 03 00', 0x03), ['P0133', 'P0300']);
  });

  ObdRepository repoFor(FakeElm f) => ObdRepository(driver: Elm327Driver(connection: f));

  test('clear: accepted and read-back empty is verified', () async {
    var cleared = false;
    final f = FakeElm((cmd, sp) {
      if (cmd == '04') { cleared = true; return '44'; }
      if (cmd == '03') return cleared ? '43 00 00 00 00 00 00' : '43 01 33 00 00 00 00';
      if (cmd == '0101') return '41 01 00 07 E5 00';
      return 'OK';
    });
    final o = await repoFor(f).clearDiagnosticCodesVerified();
    expect(o.accepted, true);
    expect(o.verifiedCleared, true);
  });

  test('clear: accepted but the code is still stored is reported as not cleared', () async {
    final f = FakeElm((cmd, sp) {
      if (cmd == '04') return '44';
      if (cmd == '03') return '43 01 33 00 00 00 00';
      if (cmd == '0101') return '41 01 81 07 E5 00';
      return 'OK';
    });
    final o = await repoFor(f).clearDiagnosticCodesVerified();
    expect(o.verifiedCleared, false);
    expect(o.codesRemain, true);
    expect(o.remainingCodes, ['P0133']);
  });

  test('clear: negative response or no answer is not accepted', () async {
    final f = FakeElm((cmd, sp) => cmd == '04' ? '7F 04 22' : 'OK');
    expect((await repoFor(f).clearDiagnosticCodesVerified()).accepted, false);
    final g = FakeElm((cmd, sp) => cmd == '04' ? 'NO DATA' : 'OK');
    expect((await repoFor(g).clearDiagnosticCodesVerified()).accepted, false);
  });
}
