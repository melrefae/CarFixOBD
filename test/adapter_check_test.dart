import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/domain/services/adapter_check.dart';

/// Scripted adapter double (replays chosen text; not a real device).
class Fake implements ObdConnection {
  final _c = StreamController<String>.broadcast();
  final String? Function(String) reply;
  int n = 0;
  Fake(this.reply);
  @override Future<bool> connect(String t) async => true;
  @override Future<void> disconnect() async {}
  @override Stream<String> get responseStream => _c.stream;
  @override bool get isConnected => true;
  @override String get connectionType => 'fake';
  @override Future<void> send(String command) async {
    final cmd = command.trim().toUpperCase().replaceAll(' ', '');
    if (cmd.isEmpty) return;
    n++;
    final r = reply(cmd);
    if (r == null) return; // silence
    scheduleMicrotask(() => _c.add('$r\r\r>'));
  }
}

void main() {
  test('silent device: init fails with an explanation (e.g. proprietary dongle)', () async {
    final d = Elm327Driver(connection: Fake((_) => null));
    expect(await d.initialize(), false);
    expect(d.initProblem, contains('proprietary'));
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('check: v2.1 string warned, repeat test and VIN reported', () async {
    int k = 0;
    final f = Fake((c) {
      switch (c) {
        case 'ATI': return 'ELM327 v2.1';
        case 'AT@1': return 'OBDII to RS232 Interpreter';
        case 'STI': return '?';
        case 'ATRV': return '12.4V';
        case 'ATDPN': return 'A5';
        case 'ATDP': return 'AUTO, ISO 14230-4 (KWP FAST)';
        case '0100': k++; return k == 4 ? 'NO DATA' : '41 00 BE 3E B8 11';
        case '0902': return 'NO DATA';
      }
      return 'OK';
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    final r = await AdapterCheck.run(d);
    final txt = r.toText();
    expect(txt, contains('2.1'));
    expect(txt, contains('Repeat test'));
    expect(r.successRate, lessThan(1.0));
    expect(txt, contains('12.4'));
    expect(txt, contains('no VIN'));
  });
}
