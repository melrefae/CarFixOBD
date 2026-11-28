import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/datasources/obd_connection.dart';
import 'package:automotive_scanner/data/datasources/elm327_driver.dart';
import 'package:automotive_scanner/domain/services/uds_read_service.dart';

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
  test('CAN: DTCs and identification read from the ECU that answers; silent ones reported as not answering', () async {
    String hdr = '';
    final f = Fake((c) {
      if (c.startsWith('ATSH')) { hdr = c.substring(4); return 'OK'; }
      switch (c) {
        case 'ATDPN': return 'A6';
        case 'ATDP': return 'AUTO, ISO 15765-4 (CAN 11/500)';
        case '0100': return '41 00 BE 3E B8 11';
      }
      if (hdr == '7E0') {
        if (c == '1902FF') return '59 02 FF 03 01 00 09 01 71 00 08';
        if (c == '22F190') return '62 F1 90 57 30 4C 30 30 30 30 34 33';
        if (c == '22F187') return '7F 22 31';
      }
      if (c.startsWith('AT')) return 'OK';
      return null;
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    final r = await UdsReadService.run(d, headers: ['7E0', '7E1']);
    expect(r.anyAnswered, true);
    final e0 = r.ecus[0];
    expect(e0.dtcs.map((x) => x.code), ['P0301', 'P0171']);
    expect(e0.dtcs[0].confirmed, true);
    expect(e0.dtcs[0].testFailed, true);
    expect(e0.dtcs[1].confirmed, true);
    expect(e0.ident['VIN'], 'W0L000043');
    expect(r.ecus[1].answered, false);
  }, timeout: const Timeout(Duration(seconds: 90)));

  test('non-CAN bus: nothing is sent, clear explanation', () async {
    final sent = <String>[];
    final f = Fake((c) {
      sent.add(c);
      switch (c) {
        case 'ATDPN': return 'A4';
        case 'ATDP': return 'AUTO, ISO 9141-2';
        case '0100': return '41 00 BE 3E B8 11';
      }
      return 'OK';
    });
    final d = Elm327Driver(connection: f);
    await d.connectToEcu();
    sent.clear();
    final r = await UdsReadService.run(d);
    expect(r.anyAnswered, false);
    expect(r.note, contains('CAN'));
    expect(sent.where((c) => c.startsWith('19') || c.startsWith('22')), isEmpty);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('parseDtcReport on a status-only list', () {
    expect(UdsReadService.parseDtcReport([0x59, 0x02, 0xFF]), isEmpty);
  });
}
