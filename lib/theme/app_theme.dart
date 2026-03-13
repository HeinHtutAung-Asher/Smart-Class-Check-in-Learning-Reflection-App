import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _softBackground = Color(0xFFF3F7FF);
  static const Color _textPrimary = Color(0xFF0F172A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _primaryBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: _primaryBlue,
          surface: Colors.white,
          onSurface: _textPrimary,
        ),
    scaffoldBackgroundColor: _softBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: _softBackground,
      foregroundColor: _textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        letterSpacing: 0.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        backgroundColor: WidgetStateProperty.all(_primaryBlue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return 1;
          }
          if (states.contains(WidgetState.hovered)) {
            return 3;
          }
          return 2;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withValues(alpha: 0.16);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withValues(alpha: 0.10);
          }
          return null;
        }),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DDE8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DDE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Color(0xFF475569)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
