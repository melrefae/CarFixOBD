import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/domain/services/ecu_capability_service.dart';

/// Scripted adapter double (replays chosen text; not a real device).
class Fake implements ObdConnection {
  final _c = StreamController<String>.broadcast();
  final String? Function(String) reply;
  final List<String> sent = [];
  Fake(this.reply);
  @override Future<bool> connect(String t) async => true;
  @override Future<void> disconnect() async {}
  @override Stream<String> get responseStream => _c.stream;
  @override bool get isConnected => true;
  @override String get connectionType => 'fake';
  @override Future<void> send(String command) async {
    final cmd = command.trim().toUpperCase().replaceAll(' ', '');
    if (cmd.isEmpty) return;
    sent.add(cmd);
    final r = reply(cmd);
    if (r == null) return;
    scheduleMicrotask(() => _c.add('$r\r\r>'));
  }
}

void main() {
  test('single-step chain: stops when continuation bit (PID 20) is clear', () async {
    final f = Fake((c) {
      if (c.startsWith('AT')) return 'OK';
      if (c == '0100') return '41 00 BE 3E B8 10'; // LSB of byte D = 0 -> no 0x20
      return null;
    });
    final d = Elm327Driver(connection: f);
    final pids = await EcuCapabilityService.discoverForModule(d, '7E0');
    expect(pids.contains('0C'), true); // RPM bit in BE 3E ...
    expect(pids.contains('20'), false);
    expect(f.sent.where((x) => x == '0120').isEmpty, true); // never asked for next range
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('two-step chain: follows continuation bit into 0120', () async {
    final f = Fake((c) {
      if (c.startsWith('AT')) return 'OK';
      if (c == '0100') return '41 00 00 00 00 01'; // only PID 0x20 -> continue
      if (c == '0120') return '41 20 80 00 00 00'; // PID 0x21 only, stop
      return null;
    });
    final d = Elm327Driver(connection: f);
    final pids = await EcuCapabilityService.discoverForModule(d, '7E0');
    expect(pids, {'20', '21'});
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('negative response and NO DATA both yield an empty set, never invented PIDs', () async {
    final fNeg = Fake((c) => c.startsWith('AT') ? 'OK' : '7F 01 11');
    final d1 = Elm327Driver(connection: fNeg);
    expect(await EcuCapabilityService.discoverForModule(d1, '7E2'), isEmpty);

    final fNone = Fake((c) => c.startsWith('AT') ? 'OK' : 'NO DATA');
    final d2 = Elm327Driver(connection: fNone);
    expect(await EcuCapabilityService.discoverForModule(d2, '7E2'), isEmpty);
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('reuses an already-fetched 0100 reply instead of asking twice', () async {
    final f = Fake((c) => c.startsWith('AT') ? 'OK' : '41 00 00 00 00 00');
    final d = Elm327Driver(connection: f);
    final pids = await EcuCapabilityService.discoverForModule(d, '7E0', firstResponse: '41 00 80 00 00 00');
    expect(pids, {'01'}); // from the passed response, not the scripted one
    expect(f.sent.where((x) => x.startsWith('01')).isEmpty, true); // no Mode 01 traffic sent
  }, timeout: const Timeout(Duration(seconds: 30)));
}
