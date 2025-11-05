import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales (état neutre/calme)
  static const Color primary = Color(0xFF1A237E); // Bleu profond
  static const Color secondary = Color(0xFF4A148C); // Violet hypnotique
  static const Color background = Color(0xFF0D1117); // Noir doux

  // Couleurs ressources (états positifs)
  static const Color gold = Color(0xFFFFD700);
  static const Color emerald = Color(0xFF50C878);
  static const Color azure = Color(0xFF007FFF);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textCaption = Color(0x80FFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: background,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.2,
          color: textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.6,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.6,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: textCaption,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withOpacity(0.3),
        thumbColor: gold,
        overlayColor: gold.withOpacity(0.2),
        trackHeight: 4,
      ),
    );
  }
}
