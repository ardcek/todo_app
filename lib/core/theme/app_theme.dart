import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFB00020);
  static const Color textColor = Color(0xFF333333);
  static const Color subtextColor = Color(0xFF666666);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textColor),
      displayMedium: TextStyle(color: textColor),
      displaySmall: TextStyle(color: textColor),
      headlineMedium: TextStyle(color: textColor),
      headlineSmall: TextStyle(color: textColor),
      titleLarge: TextStyle(color: textColor),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: textColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: subtextColor),
      labelLarge: TextStyle(color: textColor),
      labelMedium: TextStyle(color: textColor),
      labelSmall: TextStyle(color: subtextColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // You can add darkTheme here if needed
}