import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> load(String l) =>
      jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync()) as Map<String, dynamic>;
  final en = load('en'), ar = load('ar');
  final keys = (Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();
  test('en and ar ARB have the same keys', () {
    expect(keys(ar), keys(en));
  });
  test('placeholders match and Arabic is not empty', () {
    final re = RegExp(r'\{p\d+\}');
    for (final k in keys(en)) {
      expect((ar[k] as String).trim().isNotEmpty, true, reason: k);
      expect(re.allMatches(ar[k] as String).map((m) => m[0]).toSet(),
          re.allMatches(en[k] as String).map((m) => m[0]).toSet(), reason: k);
    }
  });
}
