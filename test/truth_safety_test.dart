import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/core/utils/uds_response.dart';
import 'package:automotive_scanner/data/models/used_car_audit_models.dart';

void main() {
  group('UdsResult', () {
    test('positive response is accepted', () {
      expect(UdsResult.evaluate('6E 01 40', 0x2E).isPositive, true);
      expect(UdsResult.evaluate('71 01 02 03', 0x31).isPositive, true);
    });
    test('negative response is a failure with NRC', () {
      final r = UdsResult.evaluate('7F 2E 31', 0x2E);
      expect(r.isPositive, false);
      expect(r.outcome, UdsOutcome.negative);
      expect(r.nrc, '31');
    });
    test('no data and not connected are failures', () {
      expect(UdsResult.evaluate('NO DATA', 0x31).isPositive, false);
      expect(UdsResult.evaluate('', 0x31).isPositive, false);
      expect(UdsResult.evaluate('ERROR: Not connected', 0x31).outcome, UdsOutcome.notConnected);
    });
  });

  group('Odometer cross-check', () {
    test('single reading cannot be verified', () {
      final r = OdometerCrossCheckResult.evaluate(ecm: 0, tcm: 0, abs: 0, cluster: 150000);
      expect(r.isRollbackSuspected, false);
      expect(r.verdictEn.startsWith('CANNOT VERIFY'), true);
    });
    test('two readings with a big gap are flagged', () {
      final r = OdometerCrossCheckResult.evaluate(ecm: 180000, tcm: 0, abs: 0, cluster: 120000);
      expect(r.isRollbackSuspected, true);
    });
    test('matching readings pass', () {
      final r = OdometerCrossCheckResult.evaluate(ecm: 120000, tcm: 120100, abs: 0, cluster: 120000);
      expect(r.isRollbackSuspected, false);
      expect(r.verdictEn.startsWith('VERIFIED'), true);
    });
  });
}
