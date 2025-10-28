import 'package:flutter/material.dart';

class AppTheme {
  // Modernized palette based on existing slate tones with a cooler accent
  static const Color primaryColor = Color(0xFF405A72); // slightly deeper slate
  static const Color primaryVariant = Color(0xFF2E4A5F);
  static const Color accentColor = Color(0xFF6AB0C8); // cool cyan accent

  static const Color backgroundColor = Color(0xFFF6F7FB);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Status colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color dangerColor = Color(0xFFF56565);
  static const Color infoColor = Color(0xFF4299E1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        background: backgroundColor,
        error: dangerColor,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Typography: modern, slightly larger headings
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 14, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryVariant.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryVariant.withOpacity(0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF1A202C),
      colorScheme: ColorScheme.dark(
        primary: primaryVariant,
        secondary: accentColor,
        surface: const Color(0xFF2D3748),
        error: dangerColor,
      ),
    );
  }
}
