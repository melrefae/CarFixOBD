import 'package:flutter/material.dart';

/// One shared look for every text field in the app. Screens should not set their own
/// border, fill or label colors: they inherit this theme.
class AppInputTheme {
  static InputDecorationTheme build({
    required Color fill,
    required Color border,
    required Color focus,
    required Color label,
    required Color hint,
    required Color error,
    required Color text,
  }) {
    OutlineInputBorder b(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: b(border),
      enabledBorder: b(border),
      focusedBorder: b(focus, 2),
      errorBorder: b(error),
      focusedErrorBorder: b(error, 2),
      disabledBorder: b(border.withOpacity(0.4)),
      hintStyle: TextStyle(color: hint, fontSize: 14),
      labelStyle: WidgetStateTextStyle.resolveWith((s) {
        if (s.contains(WidgetState.error)) return TextStyle(color: error);
        if (s.contains(WidgetState.focused)) return TextStyle(color: focus, fontWeight: FontWeight.w600);
        return TextStyle(color: label);
      }),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((s) {
        if (s.contains(WidgetState.error)) return TextStyle(color: error, fontWeight: FontWeight.w600);
        return TextStyle(color: focus, fontWeight: FontWeight.w600);
      }),
      helperStyle: TextStyle(color: hint, fontSize: 12),
      errorStyle: TextStyle(color: error, fontSize: 12),
      prefixIconColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.focused) ? focus : label),
      suffixIconColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.focused) ? focus : label),
    );
  }

  static TextSelectionThemeData selection(Color c) =>
      TextSelectionThemeData(cursorColor: c, selectionHandleColor: c, selectionColor: c.withOpacity(0.3));
}
