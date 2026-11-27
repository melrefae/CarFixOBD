import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/obd_state.dart';

/// Experimental features that write to the vehicle or use commands that are
/// NOT yet verified on a real car. They live only in the Lab section.
class LabGate {
  /// Opens [screen] only after the user confirms the experimental warning.
  static Future<void> open(BuildContext context, Widget screen, {bool notMeasured = false}) async {
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => notMeasured ? NotMeasuredWrapper(child: screen) : screen));
    }
  }
}

/// Persistent banner for screens whose numbers/graphs are computed from a few
/// readings or formulas and are NOT measured from the car.
class NotMeasuredWrapper extends StatelessWidget {
  final Widget child;
  const NotMeasuredWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<ObdState>(context).isArabic;
    return Column(
      children: [
        Material(
          color: Colors.red.shade900,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  isAr
                      ? 'تحذير: الأرقام والرسومات في هذه الشاشة محسوبة تقديرياً من قراءات قليلة وليست قياساً حقيقياً من السيارة. لا تعتمد عليها في أي قرار.'
                      : 'WARNING: values and graphs on this screen are estimated from a few readings, NOT measured from the car. Do not rely on them for any decision.',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ],
    );
  }
}
