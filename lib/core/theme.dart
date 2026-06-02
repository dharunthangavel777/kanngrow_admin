import 'package:flutter/material.dart';

class AdminTheme {
  // Premium Dark Theme Palette
  static const Color scaffoldBackground = Color(0xFF0F1115);
  static const Color surfaceColor = Color(0xFF16191F);
  static const Color surfaceHighlight = Color(0xFF22262F);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color borderSubtle = Color(0xFF2A2D35);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: primaryBlue,
      canvasColor: surfaceColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentPurple,
        surface: surfaceColor,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceColor,
        selectedIconTheme: IconThemeData(color: primaryBlue),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
