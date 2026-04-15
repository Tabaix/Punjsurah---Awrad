// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color primaryDark   = Color(0xFF1B5E20);
  static const Color primary       = Color(0xFF2E7D32);
  static const Color primaryLight  = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF1A237E);
  static const Color secondary     = Color(0xFF283593);
  static const Color accent        = Color(0xFFFFB300);
  static const Color accentLight   = Color(0xFFFFE082);
  static const Color background    = Color(0xFFF5F0E8);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color cardBorder    = Color(0xFFD8CCAA);
  static const Color textPrimary   = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF5D5D5D);
  static const Color textOnDark    = Color(0xFFFFFFFF);
}

class AppTheme {
  AppTheme._();

  // The professional font for Urdu
  static const String urduFont = 'JameelNooriNastaliq';

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryDark),
    scaffoldBackgroundColor: AppColors.background,
    
    // Set Nastaliq as the default font for the entire app
    fontFamily: urduFont,
    
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.textOnDark,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: urduFont, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: AppColors.accent,
      labelColor: AppColors.accent,
      unselectedLabelColor: Color(0xFFA5D6A7),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: urduFont),
      displayMedium: TextStyle(fontFamily: urduFont),
      bodyLarge: TextStyle(fontFamily: urduFont),
      bodyMedium: TextStyle(fontFamily: urduFont, height: 1.4),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textOnDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
