import 'package:flutter/material.dart';

/// Colors/typography ported 1:1 from the React app's index.css (:root vars)
/// and inline styles, so the Flutter UI matches the original look.
class MatrixColors {
  static const Color green = Color(0xFF00FF00); // #0F0
  static const Color greenDark = Color(0xFF00AA00);
  static const Color greenLight = Color(0xFF00FF00);
  static const Color black = Color(0xFF000000);
  static const Color error = Color(0xFFFF0000); // #F00

  static Color greenAlpha(double opacity) => green.withValues(alpha: opacity);
}

class MatrixTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MatrixColors.black,
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.dark(
        primary: MatrixColors.green,
        secondary: MatrixColors.green,
        error: MatrixColors.error,
        surface: MatrixColors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MatrixColors.black.withValues(alpha:0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MatrixColors.green, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MatrixColors.green, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MatrixColors.greenLight, width: 2),
        ),
        labelStyle: const TextStyle(color: MatrixColors.green, fontFamily: 'monospace'),
        hintStyle: TextStyle(color: MatrixColors.greenAlpha(0.5), fontFamily: 'monospace'),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: MatrixColors.green, fontFamily: 'monospace'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MatrixColors.green,
          foregroundColor: MatrixColors.black,
          textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Reusable box decoration: black translucent card w/ green 2px border,
  // mirrors `.card` in the original CSS.
  static BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
        color: MatrixColors.black.withValues(alpha:0.85),
        border: Border.all(color: MatrixColors.green, width: 2),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: MatrixColors.greenAlpha(0.3), blurRadius: 20),
        ],
      );
}
