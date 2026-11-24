import 'package:flutter/material.dart';

/// ألوان خاصة ببيئة الورشة (عالية التباين لسهولة الرؤية تحت الإضاءة القوية والأيدي المتسخة)
class AppColors {
  // الخلفيات
  static const Color darkBackground = Color(0xFF0F141C);
  static const Color cardSurface = Color(0xFF1A2230);
  static const Color cardSurfaceHighlight = Color(0xFF242F42);

  // ألوان رئيسية وتأكيدية
  static const Color primaryYellow = Color(0xFFFFB800); // لون الورش الصناعي البارز
  static const Color primaryAmber = Color(0xFFFF9100);
  static const Color electricBlue = Color(0xFF00B4D8);
  static const Color accentCyan = Color(0xFF48CAE4);

  // ألوان الحالة التشخيصية
  static const Color successGreen = Color(0xFF00E676); // سليم / متصل
  static const Color warningOrange = Color(0xFFFF9800); // عطل معلق / تنبيه
  static const Color dangerRed = Color(0xFFFF3D00); // عطل حرج / لمبة محرك
  static const Color neutralGray = Color(0xFF90A4AE);

  // نصوص
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0BEC5);
  static const Color textDisabled = Color(0xFF546E7A);

  // حالة الاتصال
  static const Color statusConnected = Color(0xFF00E676);
  static const Color statusConnecting = Color(0xFFFFB800);
  static const Color statusDisconnected = Color(0xFFFF5252);
  static const Color statusSimulation = Color(0xFF9C27B0); // بنفسجي للمحاكي

  // Aliases for workshop UI
  static const Color backgroundDark = darkBackground;
  static const Color textPrimary = textWhite;
  static const Color textSecondary = textMuted;
  static const Color cardBorder = Color(0xFF263238);
  static const Color surfaceCard = cardSurface;
  static const Color surfaceDark = darkBackground;
  static const Color borderSubtle = cardBorder;
  static const Color warningAmber = primaryAmber;
  static const Color crimsonRed = dangerRed;
  static const Color errorRed = dangerRed;
  static const Color accentBlue = electricBlue;

  // Light Theme (Eye-Comfort Workshop Palette)
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate-50: soft, calm, non-glare canvas
  static const Color lightCardSurface = Colors.white; // Clean elevated white
  static const Color lightCardSurfaceHighlight = Color(0xFFF1F5F9); // Slate-100: soft subtle fill
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Slate-200: soft 1px hairline border

  // Light Theme Typography
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate-900: sharp contrast, no eye strain
  static const Color lightTextSecondary = Color(0xFF475569); // Slate-600: accessible subtext
  static const Color lightTextMuted = Color(0xFF64748B); // Slate-500: readable caption

  // Light Theme Accents (Ergonomic & Soothing)
  static const Color lightPrimaryCobalt = Color(0xFF2563EB); // Royal Cobalt Blue 600
  static const Color lightPrimaryAmber = Color(0xFFD97706); // Warm Amber 600 (not blinding)
  static const Color lightElectricBlue = Color(0xFF0284C7); // Sky-600 / Azure
  static const Color lightSuccessGreen = Color(0xFF16A34A); // Emerald-600
  static const Color lightWarningOrange = Color(0xFFEA580C); // Orange-600
  static const Color lightDangerRed = Color(0xFFDC2626); // Red-600

  // Semantic Helpers
  static Color getBackground(bool isLight) => isLight ? lightBackground : darkBackground;
  static Color getCardSurface(bool isLight) => isLight ? lightCardSurface : cardSurface;
  static Color getCardSurfaceHighlight(bool isLight) => isLight ? lightCardSurfaceHighlight : cardSurfaceHighlight;
  static Color getCardBorder(bool isLight) => isLight ? lightCardBorder : cardBorder;
  static Color getTextPrimary(bool isLight) => isLight ? lightTextPrimary : textWhite;
  static Color getTextSecondary(bool isLight) => isLight ? lightTextSecondary : textMuted;
  static Color getTextMuted(bool isLight) => isLight ? lightTextMuted : textMuted;
  static Color getPrimaryAccent(bool isLight) => isLight ? lightPrimaryCobalt : primaryYellow;
  static Color getSuccess(bool isLight) => isLight ? lightSuccessGreen : successGreen;
  static Color getWarning(bool isLight) => isLight ? lightWarningOrange : warningOrange;
  static Color getDanger(bool isLight) => isLight ? lightDangerRed : dangerRed;
}
