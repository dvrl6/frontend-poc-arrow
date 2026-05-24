import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF121A2F);
  static const neonMint = Color(0xFF7AFDD6);
  static const pastelAmber = Color(0xFFFFD166);
  static const softText = Color(0xFFE8F1FF);
  static const mutedText = Color(0xFF9BA9C7);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: neonMint,
      brightness: Brightness.dark,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme.copyWith(
        primary: neonMint,
        secondary: pastelAmber,
        surface: surface,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: softText,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
        headlineSmall: TextStyle(
          color: softText,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: softText),
        bodyMedium: TextStyle(color: mutedText),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neonMint,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: softText,
          side: const BorderSide(color: neonMint),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: neonMint.withValues(alpha: 0.18)),
        ),
      ),
    );
  }
}
