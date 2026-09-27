import 'package:flutter/material.dart';

// Colors
class DropAtColors {
  DropAtColors._();

  // Primary
  static const Color primary = Color(0xFF7AAB98);
  static const Color primaryDark = Color(0xFF5D8F7B);
  static const Color primaryLight = Color(0xFFB5D5C5);
  static const Color primarySurface = Color(0xFFEDF5F1);

  // Accents
  static const Color accent = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);

  // Neutrals
  static const Color black = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF4A4A4A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color pickupGreen = Color(0xFF7AAB98);
  static const Color dropRed = Color(0xFFE53935);
  static const Color starYellow = Color(0xFFFFC107);

  // Dark surfaces (for dark headers in Figma)
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkHeader = Color(0xFF3A5A4C);
}

// Text Styles
class DropAtTextStyles {
  DropAtTextStyles._();

  static const String _fontFamily = 'Poppins';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: DropAtColors.black,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: DropAtColors.black,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: DropAtColors.black,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: DropAtColors.black,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: DropAtColors.darkGrey,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: DropAtColors.grey,
    height: 1.5,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: DropAtColors.black,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: DropAtColors.darkGrey,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: DropAtColors.white,
  );

  // Price
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: DropAtColors.black,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: DropAtColors.black,
  );
}

// Spacing
class DropAtSpacing {
  DropAtSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

// Shadows
class DropAtShadows {
  DropAtShadows._();

  static List<BoxShadow> get light => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get premium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];
}

// Radii
class DropAtRadius {
  DropAtRadius._();

  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double round = 100;
}

// Theme Data
class DropAtTheme {
  DropAtTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: DropAtColors.white,
      colorScheme: const ColorScheme.light(
        primary: DropAtColors.primary,
        secondary: DropAtColors.primaryDark,
        error: DropAtColors.error,
        surface: DropAtColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DropAtColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: DropAtColors.black),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DropAtColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DropAtColors.primary,
          foregroundColor: DropAtColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DropAtRadius.md),
          ),
          textStyle: DropAtTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DropAtColors.primary,
          side: const BorderSide(color: DropAtColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DropAtRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DropAtColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DropAtRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DropAtRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DropAtRadius.md),
          borderSide: const BorderSide(color: DropAtColors.primary, width: 1.5),
        ),
        hintStyle: DropAtTextStyles.bodyMedium.copyWith(color: DropAtColors.grey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DropAtColors.white,
        selectedItemColor: DropAtColors.primary,
        unselectedItemColor: DropAtColors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: DropAtColors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DropAtRadius.lg),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
        space: 0,
      ),
    );
  }
}
