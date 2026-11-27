/// Loose text match for plates, names and phones: ignores case, spaces and dashes,
/// treats Arabic-Indic digits as Latin digits and alef variants as one letter.
class SearchMatch {
  static String norm(String s) {
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final b = StringBuffer();
    for (final r in s.toLowerCase().runes) {
      final c = String.fromCharCode(r);
      final i = ar.indexOf(c);
      if (i >= 0) { b.write(i); continue; }
      if ('أإآ'.contains(c)) { b.write('ا'); continue; }
      if (c == 'ة') { b.write('ه'); continue; }
      if (c == 'ى') { b.write('ي'); continue; }
      if (c.trim().isEmpty || c == '-' || c == '_') continue;
      b.write(c);
    }
    return b.toString();
  }

  /// Every space-separated word of the query must appear in at least one field.
  static bool matches(String query, Iterable<String> fields) {
    final words = query.trim().split(RegExp(r'\s+')).map(norm).where((w) => w.isNotEmpty);
    if (words.isEmpty) return true;
    final hay = fields.map(norm).join('|');
    return words.every(hay.contains);
  }
}
