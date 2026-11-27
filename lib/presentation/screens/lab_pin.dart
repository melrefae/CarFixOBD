import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple staff guard for the Lab section (not a security feature).
/// First use asks to create a PIN (or skip). Later uses ask for it.
class LabPin {
  static const _key = 'lab_pin';

  static Future<bool> check(BuildContext context, bool isAr) async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString(_key);
    if (pin != null && pin.isEmpty) return true; // user chose no PIN
    if (!context.mounted) return false;
    if (pin == null) {
      final created = await _ask(context, isAr,
          isAr ? 'أنشئ رقم سري للمختبر (4 أرقام) أو اتركه فارغاً لعدم استخدام رقم' : 'Create a 4-digit Lab PIN, or leave empty for no PIN',
          allowEmpty: true);
      if (created == null) return false;
      await prefs.setString(_key, created);
      return true;
    }
    final entered = await _ask(context, isAr, isAr ? 'أدخل رقم المختبر السري' : 'Enter Lab PIN');
    if (entered == pin) return true;
    if (entered != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? 'رقم خاطئ' : 'Wrong PIN')));
    }
    return false;
  }

  /// Clears the saved PIN so the next Lab open asks to create a new one.
  static Future<void> reset() async => (await SharedPreferences.getInstance()).remove(_key);

  static Future<String?> _ask(BuildContext context, bool isAr, String title, {bool allowEmpty = false}) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 14)),
          content: TextField(controller: c, keyboardType: TextInputType.number, obscureText: true, maxLength: 4, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
            TextButton(
              onPressed: () {
                if (c.text.isEmpty && !allowEmpty) return;
                Navigator.pop(ctx, c.text);
              },
              child: Text(isAr ? 'موافق' : 'OK'),
            ),
          ],
        ),
      ),
    );
  }
}
