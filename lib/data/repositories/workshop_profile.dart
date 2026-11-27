import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Workshop identity printed on PDFs. Comes from Workshop Settings; empty fields are not printed.
class WorkshopProfile {
  final String name;
  final String phone;
  final String address;
  final Uint8List? logo; // PNG/JPEG bytes

  const WorkshopProfile({this.name = 'AutoSpect', this.phone = '', this.address = '', this.logo});

  static const _kLogo = 'workshop_logo_path';

  static Future<WorkshopProfile> load() async {
    final p = await SharedPreferences.getInstance();
    Uint8List? logo;
    final lp = p.getString(_kLogo);
    if (lp != null && lp.isNotEmpty) {
      try {
        final f = File(lp);
        if (await f.exists()) logo = await f.readAsBytes();
      } catch (_) {}
    }
    final n = (p.getString('workshop_name') ?? '').trim();
    return WorkshopProfile(
      name: n.isEmpty ? 'AutoSpect' : n,
      phone: (p.getString('workshop_phone') ?? '').trim(),
      address: (p.getString('workshop_address') ?? '').trim(),
      logo: logo,
    );
  }

  static Future<String?> logoPath() async => (await SharedPreferences.getInstance()).getString(_kLogo);

  /// Copies the picked image into app storage and remembers it.
  static Future<void> setLogo(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = sourcePath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final dest = File('${dir.path}/workshop_logo.$ext');
    await File(sourcePath).copy(dest.path);
    await (await SharedPreferences.getInstance()).setString(_kLogo, dest.path);
  }

  static Future<void> setLogoBytes(Uint8List bytes, String ext) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/workshop_logo.$ext');
    await dest.writeAsBytes(bytes, flush: true);
    await (await SharedPreferences.getInstance()).setString(_kLogo, dest.path);
  }

  static Future<void> removeLogo() async {
    final p = await SharedPreferences.getInstance();
    final lp = p.getString(_kLogo);
    if (lp != null) {
      try { await File(lp).delete(); } catch (_) {}
    }
    await p.remove(_kLogo);
  }
}
