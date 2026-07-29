import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_text_theme.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      primaryColor: AppColors.primaryMint,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMint,
        secondary: AppColors.darkNavy,
        onSecondary: AppColors.backgroundWhite,
        surface: AppColors.backgroundWhite,
        onSurface: AppColors.headingDark,
        error: AppColors.coralRed,
      ),
      fontFamily: AppTextTheme.fontFamily,
      textTheme: AppTextTheme.lightTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkNavy),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardGray,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        ),
      ),
    );
  }
}
