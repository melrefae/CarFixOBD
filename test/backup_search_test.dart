import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:automotive_scanner/core/utils/search_match.dart';
import 'package:automotive_scanner/data/models/workshop_records.dart';
import 'package:automotive_scanner/data/repositories/workshop_backup.dart';
import 'package:automotive_scanner/data/repositories/workshop_profile.dart';
import 'package:automotive_scanner/data/repositories/workshop_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search ignores case, spaces, Arabic digits and alef forms', () {
    expect(SearchMatch.matches('abc1234', ['ABC 1234']), isTrue);
    expect(SearchMatch.matches('١٢٣٤', ['أ ب ج 1234']), isTrue);
    expect(SearchMatch.matches('احمد', ['أحمد علي']), isTrue);
    expect(SearchMatch.matches('ali toyota', ['Ali', 'Toyota Corolla']), isTrue);
    expect(SearchMatch.matches('ali bmw', ['Ali', 'Toyota Corolla']), isFalse);
    expect(SearchMatch.matches('', ['x']), isTrue);
  });

  test('backup export then import merges without overwriting', () async {
    SharedPreferences.setMockInitialValues({'workshop_name': 'Test Workshop', 'workshop_phone': '0100'});
    await WorkshopStore.saveJob(JobCard(id: 'j1', customer: 'A', items: [JobLineItem(description: 'x', unitPrice: 5)]));
    await WorkshopStore.saveInspection(InspectionRecord(
        id: 'i1', createdAt: DateTime(2026, 1, 1), plate: 'ABC 1', customer: 'A', vehicleName: 'V', vin: '',
        carRead: false, carSnapshot: const {}, extra: const {'mileageKm': '10'}, checklist: const {'a': 1}));
    final data = await WorkshopBackup.buildJson();
    expect(data['format'], 'autospect-backup');
    expect((data['jobs'] as List).length, 1);
    final text = jsonEncode(data);

    // empty phone: everything comes back, identity is filled in
    SharedPreferences.setMockInitialValues({});
    final r = await WorkshopBackup.importJson(text);
    expect(r.inspections, 1);
    expect(r.jobs, 1);
    expect((await WorkshopStore.jobs()).single.items.single.unitPrice, 5);
    expect((await WorkshopStore.inspections()).single.extra['mileageKm'], '10');
    expect((await WorkshopProfile.load()).name, 'Test Workshop');

    // same file again: nothing duplicated
    final r2 = await WorkshopBackup.importJson(text);
    expect(r2.inspections + r2.jobs, 0);
    expect(r2.skipped, 2);
    expect((await WorkshopStore.jobs()).length, 1);

    // identity already set on the phone is not overwritten
    SharedPreferences.setMockInitialValues({'workshop_name': 'Mine'});
    await WorkshopBackup.importJson(text);
    expect((await WorkshopProfile.load()).name, 'Mine');
  });

  test('import rejects files that are not backups', () async {
    expect(() => WorkshopBackup.importJson('not json'), throwsFormatException);
    expect(() => WorkshopBackup.importJson('{"format":"other"}'), throwsFormatException);
    expect(() => WorkshopBackup.importJson('{"format":"autospect-backup","version":99}'), throwsFormatException);
  });
}
