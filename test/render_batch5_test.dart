import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import 'package:automotive_scanner/core/theme/workshop_theme.dart';
import 'package:automotive_scanner/presentation/providers/obd_state.dart';
import 'package:automotive_scanner/presentation/screens/flight_recorder_screen.dart';
import 'package:automotive_scanner/presentation/screens/multi_ecu_topology_screen.dart';
import 'package:automotive_scanner/presentation/screens/o2_cat_analyzer_screen.dart';
import 'package:automotive_scanner/presentation/screens/performance_dyno_screen.dart';
import 'package:automotive_scanner/presentation/screens/workshop_lan_sync_screen.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mf = '/tmp/flutter/bin/cache/artifacts/material_fonts';
  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.view(File('$mf/Roboto-Regular.ttf').readAsBytesSync().buffer)))
    ..addFont(Future.value(ByteData.view(File('$mf/Roboto-Bold.ttf').readAsBytesSync().buffer)));
  await roboto.load();
  final mono = FontLoader('monospace')
    ..addFont(Future.value(ByteData.view(File('$mf/Roboto-Regular.ttf').readAsBytesSync().buffer)));
  await mono.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(File('$mf/MaterialIcons-Regular.otf').readAsBytesSync().buffer)));
  await icons.load();
  final arabic = FontLoader('NotoSansArabic')
    ..addFont(Future.value(ByteData.view(File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync().buffer)))
    ..addFont(Future.value(ByteData.view(File('assets/fonts/NotoSansArabic-Bold.ttf').readAsBytesSync().buffer)));
  await arabic.load();

  Future<void> render(WidgetTester tester, String name, Widget screen, bool ar) async {
    SharedPreferences.setMockInitialValues({});
    final state = ObdState();
    state.setLanguage(arabic: ar);
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: WorkshopTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(ar ? 'ar' : 'en'),
      home: ChangeNotifierProvider<ObdState>.value(value: state, child: screen),
    ));
    await tester.pump();
    await expectLater(find.byType(Scaffold).first, matchesGoldenFile('goldens/$name.png'));
  }

  testWidgets('b5 renders', (tester) async {
    await render(tester, 'b5_flight_ar', const FlightRecorderScreen(), true);
    await render(tester, 'b5_topo_ar', const MultiEcuTopologyScreen(), true);
    await render(tester, 'b5_o2_ar', const O2CatAnalyzerScreen(), true);
    await render(tester, 'b5_dyno_ar', const PerformanceDynoScreen(), true);
    await render(tester, 'b5_lan_ar', const WorkshopLanSyncScreen(), true);
  });
}
