import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color background = Color(0xFF0A0B0D); // Obsidian Deep Black
  static const Color surface = Color(0xFF16181D);    // Charcoal Card Surface
  static const Color primary = Color(0xFFFFFFFF);    // Primary text/headers (High contrast)
  static const Color secondary = Color(0xFF8E95A5);  // Muted grey for descriptions/details
  static const Color divider = Color(0xFF252932);    // Subtle borders and lines

  // Accent Colors
  static const Color accentIndigo = Color(0xFF6366F1); // Focus sessions, buttons
  static const Color accentEmerald = Color(0xFF10B981); // Complete/Break
  static const Color accentAmber = Color(0xFFF59E0B);   // Medium priority
  static const Color accentRose = Color(0xFFEF4444);    // High priority, Timer danger

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        outline: divider,
      ),
      dividerColor: divider,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: primary, letterSpacing: -1.0),
        displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: primary, height: 1.4),
        bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: divider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: secondary, fontSize: 14),
        hintStyle: const TextStyle(color: secondary, fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: background,
        shape: CircleBorder(),
        elevation: 2,
      ),
    );
  }
}
