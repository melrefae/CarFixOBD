import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/workshop_theme.dart';
import 'presentation/providers/obd_state.dart';
import 'l10n/gen/app_localizations.dart';
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
            title: 'AutoSpect | OBD2 Diagnostic System',
            debugShowCheckedModeBanner: false,
            theme: state.isSunlightMode ? WorkshopTheme.sunlightTheme : WorkshopTheme.darkTheme,
            // English default locale
            locale: state.isArabic ? const Locale('ar') : const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
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
