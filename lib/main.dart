import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/workshop_theme.dart';
import 'presentation/providers/obd_state.dart';
import 'presentation/screens/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutomotiveScannerApp());
}

class AutomotiveScannerApp extends StatelessWidget {
  const AutomotiveScannerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ObdState>(
      create: (_) => ObdState(),
      child: Consumer<ObdState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Aspect Auto Scan | OBD2 Diagnostic System',
            debugShowCheckedModeBanner: false,
            theme: state.isSunlightMode ? WorkshopTheme.sunlightTheme : WorkshopTheme.darkTheme,
            // English default locale
            locale: const Locale('en', 'US'),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'EG'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeDashboardScreen(),
          );
        },
      ),
    );
  }
}
