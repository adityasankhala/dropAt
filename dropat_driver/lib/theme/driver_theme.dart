import 'package:flutter/material.dart';

class DriverColors {
  DriverColors._();
  static const Color primary = Color(0xFF7AAB98);
  static const Color primaryDark = Color(0xFF5D8F7B);
  static const Color primaryLight = Color(0xFFB5D5C5);
  static const Color primarySurface = Color(0xFFEDF5F1);
  static const Color accent = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color starYellow = Color(0xFFFFC107);
  static const Color darkHeader = Color(0xFF3A5A4C);
}

class DriverTheme {
  DriverTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: DriverColors.white,
      colorScheme: const ColorScheme.light(
        primary: DriverColors.primary,
        secondary: DriverColors.primaryDark,
        error: DriverColors.error,
        surface: DriverColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DriverColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: DriverColors.black),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DriverColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DriverColors.primary,
          foregroundColor: DriverColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DriverColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DriverColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: DriverColors.grey,
          fontSize: 14,
        ),
      ),
    );
  }
}
