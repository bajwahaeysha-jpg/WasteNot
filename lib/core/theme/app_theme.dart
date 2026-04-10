import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    primaryColor: AppColors.primaryGreen,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
  color: const Color.fromARGB(255, 255, 255, 255),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  elevation: 3,
),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
      ),
    ),
  );
}
