import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_state.dart';

/// Experimental features that write to the vehicle or use commands that are
/// NOT yet verified on a real car. They live only in the Lab section.
class LabGate {
  /// Opens [screen] only after the user confirms the experimental warning.
  static Future<void> open(BuildContext context, Widget screen) async {
    final isAr = Provider.of<ObdState>(context, listen: false).isArabic;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(isAr ? 'ميزة تجريبية غير مثبتة' : 'Experimental, unverified feature'),
          content: Text(isAr
              ? 'هذه الميزة لم يتم التحقق منها على سيارة حقيقية. قد ترسل أوامر عامة غير مخصصة لماركة سيارتك، وقد تؤثر على وحدات التحكم. استخدمها على سيارة تجارب فقط وبمسؤوليتك، ولا تعتمد على نتائجها.'
              : 'This feature has not been verified on a real car. It may send generic commands that are not specific to your vehicle brand and could affect ECUs. Use it only on a test vehicle, at your own risk, and do not rely on its results.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isAr ? 'فهمت، متابعة' : 'I understand, continue')),
          ],
        ),
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }
}
