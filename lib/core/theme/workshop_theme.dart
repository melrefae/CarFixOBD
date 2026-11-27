import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ثيم واجهة المستخدم المصمم خصيصاً لبيئة ورشة الصيانة
class WorkshopTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryYellow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryYellow,
        secondary: AppColors.electricBlue,
        surface: AppColors.cardSurface,
        error: AppColors.dangerRed,
        onPrimary: Colors.black,
        onSurface: AppColors.textWhite,
      ),
      fontFamily: 'Roboto', // يدعم الحروف العربية بوضوح ممتاز
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF263238), width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
        iconTheme: IconThemeData(color: AppColors.primaryYellow),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
          side: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF37474F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF37474F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.primaryYellow),
      ),
    );
  }

  /// وضع النهار وراحة العين (Daylight & Eye-Comfort Mode)
  /// تصميم مريح للعين بألوان هادئة (Slate-50)، بطاقات بيضاء نقية مع حدود ناعمة (1.0px Slate-200)،
  /// ودرجات تباين واضحة ومريحة تمنع إجهاد العين أثناء العمل تحت ضوء النهار وفي الورشة.
  static ThemeData get sunlightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightPrimaryCobalt,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimaryCobalt,
        secondary: AppColors.lightPrimaryAmber,
        surface: AppColors.lightCardSurface,
        error: AppColors.lightDangerRed,
        onPrimary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: AppColors.lightCardSurface,
        elevation: 0.5,
        shadowColor: const Color(0x0F000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightCardSurface,
        elevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimaryCobalt,
          foregroundColor: Colors.white,
          elevation: 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimaryCobalt,
          side: const BorderSide(color: AppColors.lightPrimaryCobalt, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCardSurfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightPrimaryCobalt, width: 1.8),
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextMuted),
        labelStyle: const TextStyle(color: AppColors.lightPrimaryCobalt, fontWeight: FontWeight.w600),
      ),
    );
  }
}

