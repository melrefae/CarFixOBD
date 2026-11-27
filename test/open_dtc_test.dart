import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/repositories/dtc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('open DTC definitions resolve a code not in the Arabic database', () async {
    final repo = DtcRepository();
    final dtc = await repo.getDtcDetails('P2000');
    expect(dtc.titleEn, contains('NOx Adsorber'));
    expect(dtc.causesEn.isEmpty, true); // nothing invented
  });
  test('brand-only code resolves with a definition', () async {
    final repo = DtcRepository();
    final dtc = await repo.getDtcDetails('P1120');
    expect(dtc.titleEn, isNotNull);
    expect(dtc.titleEn!.isNotEmpty, true);
  });
}
