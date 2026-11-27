import 'package:flutter/material.dart';
import 'lab_pin.dart';
import 'package:provider/provider.dart';
import '../providers/obd_state.dart';
import 'lab_gate.dart';
import 'diagzone_service_functions_screen.dart';
import 'ecu_coding_screen.dart';
import 'sgw_assistant_screen.dart';
import 'actuator_tests_screen.dart';
import 'immo_key_programming_screen.dart';
import 'ev_hybrid_battery_lab_screen.dart';
import 'adas_calibration_screen.dart';
import 'dpf_regeneration_screen.dart';
import 'lab_scope_waveform_screen.dart';
import 'performance_dyno_screen.dart';

class _LabItem {
  final String titleEn, titleAr, noteEn, noteAr;
  final IconData icon;
  final Widget screen;
  final bool notMeasured;
  const _LabItem(this.titleEn, this.titleAr, this.noteEn, this.noteAr, this.icon, this.screen, [this.notMeasured = false]);
}

/// Lab: features still under development. Status of every item: UNVERIFIED.
class LabHubScreen extends StatelessWidget {
  const LabHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<ObdState>(context).isArabic;
    const items = <_LabItem>[
      _LabItem('Special functions / resets', 'وظائف الصيانة الخاصة', 'Generic commands, not verified per brand.', 'أوامر عامة غير مثبتة لكل ماركة.', Icons.tune, DiagzoneServiceFunctionsScreen()),
      _LabItem('ECU coding', 'تكويد الكمبيوتر', 'Writes to the ECU. Command IDs are not verified.', 'يكتب في الكمبيوتر. معرفات الأوامر غير مثبتة.', Icons.code, EcuCodingScreen()),
      _LabItem('SGW assistant', 'مساعد بوابة الأمان', 'Not verified.', 'غير مثبت.', Icons.security, SgwAssistantScreen()),
      _LabItem('Actuator tests', 'اختبار المشغلات', 'Controls real actuators. Not verified.', 'يتحكم في مشغلات حقيقية. غير مثبت.', Icons.play_circle_fill, ActuatorTestsScreen()),
      _LabItem('Immobilizer and keys', 'الإيموبلايزر والمفاتيح', 'Status values are not read from the car; replies shown as received.', 'قيم الحالة لا تُقرأ من السيارة؛ تُعرض الردود كما وصلت.', Icons.key, ImmoKeyProgrammingScreen()),
      _LabItem('EV and hybrid battery', 'بطارية EV والهايبرد', 'Cell data is not read from the car yet.', 'بيانات الخلايا لا تُقرأ من السيارة بعد.', Icons.electric_bolt, EvHybridBatteryLabScreen()),
      _LabItem('ADAS calibration', 'معايرة ADAS', 'Not verified.', 'غير مثبت.', Icons.camera, AdasCalibrationScreen()),
      _LabItem('DPF regeneration', 'تجديد فلتر DPF', 'Result is not read back from the ECU yet.', 'النتيجة لا تُقرأ من الكمبيوتر بعد.', Icons.local_fire_department, DpfRegenerationScreen(), true),
      _LabItem('Lab scope (estimated waveforms)', 'راسم الإشارة (رسومات تقديرية)', 'Waveforms are generated from formulas, not measured.', 'الرسومات مولّدة من معادلات وليست مقاسة.', Icons.waves, LabScopeWaveformScreen(), true),
      _LabItem('Dyno and performance (estimates)', 'الأداء والداينو (تقديري)', 'Estimated from limited readings.', 'تقديرات من قراءات محدودة.', Icons.speed, PerformanceDynoScreen(), true),
    ];
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'المختبر (تجريبي)' : 'Lab (experimental)'),
          actions: [
            TextButton(
              onPressed: () async {
                await LabPin.reset();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAr ? 'تم مسح الرقم. سيُطلب إنشاء رقم جديد عند الدخول القادم.' : 'PIN cleared. You will create a new one next time.')));
                }
              },
              child: Text(isAr ? 'تغيير الرقم' : 'Reset PIN'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: Colors.orange.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(isAr
                    ? 'ميزات قيد التطوير ولم يتم التحقق منها على سيارة حقيقية. حالة كل ميزة: غير مثبتة.'
                    : 'Features under development, not verified on a real car. Status of every item: UNVERIFIED.'),
              ),
            ),
            for (final i in items)
              Card(
                child: ListTile(
                  leading: Icon(i.icon),
                  title: Text(isAr ? i.titleAr : i.titleEn),
                  subtitle: Text('${isAr ? i.noteAr : i.noteEn}\n${isAr ? 'الحالة: غير مثبت' : 'Status: unverified'}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => LabGate.open(context, i.screen, notMeasured: i.notMeasured),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
