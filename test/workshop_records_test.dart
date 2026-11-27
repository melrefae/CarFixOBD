import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automotive_scanner/data/models/inspection_extra.dart';
import 'package:automotive_scanner/data/models/used_car_audit_models.dart';
import 'package:automotive_scanner/data/models/workshop_records.dart';
import 'package:automotive_scanner/domain/services/job_card_pdf_service.dart';
import 'package:automotive_scanner/domain/services/used_car_pdf_report_service.dart';
import 'package:automotive_scanner/domain/services/visit_compare.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  test('InspectionExtra JSON round trip', () {
    final x = InspectionExtra()
      ..plate = 'ABC 123'
      ..mileageKm = '120000'
      ..frontDiscs = ManualCheckItemStatus.fail;
    x.paintMicrons['Hood'] = '310';
    x.fluids['Coolant'] = ManualCheckItemStatus.pass;
    final y = InspectionExtra()..loadJson(x.toJson());
    expect(y.plate, 'ABC 123');
    expect(y.paintMicrons['Hood'], '310');
    expect(y.frontDiscs, ManualCheckItemStatus.fail);
    expect(y.fluids['Coolant'], ManualCheckItemStatus.pass);
    expect(y.fluids['Engine oil'], ManualCheckItemStatus.notChecked);
  });

  InspectionRecord rec(String id, String mileage, String hood, {bool car = false}) {
    final x = InspectionExtra()..plate = 'abc 123'..mileageKm = mileage;
    x.paintMicrons['Hood'] = hood;
    return InspectionRecord(
      id: id, createdAt: DateTime(2026, 1, 1), plate: 'abc 123', customer: 'Ali', vehicleName: 'Test',
      vin: '', carRead: car, carSnapshot: car ? {'ECM odometer': '100 km'} : {},
      extra: x.toJson(), checklist: {'a': 3, 'b': 1, 'c': 0},
    );
  }

  test('InspectionRecord round trip and carKey', () {
    final r = rec('1', '1000', '120');
    final r2 = InspectionRecord.fromJson(r.toJson());
    expect(r2.carKey, 'PLATE:ABC123');
    expect(r2.checklist['a'], 3);
    expect(r2.extra['mileageKm'], '1000');
  });

  test('compare marks changes and shows not measured', () {
    final rows = VisitCompare.rows(rec('1', '1000', '120'), rec('2', '2000', ''));
    expect(rows.firstWhere((r) => r.label == 'Mileage entered').changed, isTrue);
    final hood = rows.firstWhere((r) => r.label == 'Paint: Hood');
    expect(hood.a, '120 µm');
    expect(hood.b, 'not measured');
    expect(rows.firstWhere((r) => r.label == 'ECM odometer').a, 'no car reading');
    expect(rows.firstWhere((r) => r.label == 'Checklist problems').a, '1');
  });

  test('job card totals', () {
    final j = JobCard(id: 'x', discount: 50, vatPercent: 14, items: [
      JobLineItem(description: 'Filter', qty: 2, unitPrice: 100),
      JobLineItem(description: 'Work', isLabour: true, qty: 1, unitPrice: 300),
    ]);
    expect(j.partsTotal, 200);
    expect(j.labourTotal, 300);
    expect(j.afterDiscount, 450);
    expect(j.vat, closeTo(63, 1e-9));
    expect(j.total, closeTo(513, 1e-9));
    expect(JobCard.fromJson(j.toJson()).total, closeTo(513, 1e-9));
    expect(JobCard(id: 'y').vatPercent, 0);
  });

  test('PDFs build', () async {
    final j = JobCard(id: 'x', items: [JobLineItem(description: 'A', unitPrice: 10)]);
    expect((await JobCardPdfService.build(j, invoice: true)).length, greaterThan(500));
    expect((await JobCardPdfService.build(j, invoice: false)).length, greaterThan(500));
    final b = await UsedCarPdfReportService.generateManualOnlyPdf(
      extra: InspectionExtra()..plate = 'X', vehicleName: 'V', carRead: true,
      carSnapshot: {'VIN': 'ABC'}, checklist: ManualInspectionReport.defaultWorkshopChecklist(),
    );
    expect(b.length, greaterThan(500));
  });

  test('Arabic PDF builds with the bundled font (no network)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final j = JobCard(id: 'a', customer: 'محمد', vehicle: 'تويوتا', items: [JobLineItem(description: 'تيل فرامل', unitPrice: 450)]);
    final b = await JobCardPdfService.build(j, invoice: true);
    expect(b.length, greaterThan(5000)); // embeds the Arabic font subset
  });
}
