import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/models/used_car_audit_models.dart';
import 'package:automotive_scanner/domain/services/used_car_pdf_report_service.dart';
import 'package:automotive_scanner/data/models/inspection_extra.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('paint audit with nothing entered is not assessed', () {
    final a = InspectionExtra().buildPaintAudit();
    expect(a.panelMicrons.isEmpty, true);
    expect(a.verdictEn.startsWith('NOT ASSESSED'), true);
  });
  test('paint audit only uses entered panels and flags filler', () {
    final x = InspectionExtra();
    x.paintMicrons['Hood'] = '120';
    x.paintMicrons['Roof'] = '300';
    final a = x.buildPaintAudit();
    expect(a.panelMicrons.length, 2);
    expect(a.hasBondoDetected, true);
    expect(a.verdictEn.contains('2 of 11'), true);
  });
  test('PDF builds with hand-entered extras', () async {
    final x = InspectionExtra()..plate = 'ABC 123'..paintMicrons['Hood'] = '110';
    final bytes = await UsedCarPdfReportService.generatePdfReport(
      scorecard: PrePurchaseAuditScorecard.generateDefaultAudit(),
      vehicleName: 'Test car',
      isArabic: false,
      extra: x,
    );
    expect(bytes.length > 1000, true);
  });
}
