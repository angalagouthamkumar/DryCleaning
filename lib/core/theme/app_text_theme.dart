import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract class AppTextTheme {
  static const String fontFamily = 'PlusJakartaSans';

  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.headingDark,
      letterSpacing: -0.5,
    ),
    headlineMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.headingDark,
      letterSpacing: -0.3,
    ),
    titleLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.headingDark,
    ),
    titleMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.headingDark,
    ),
    bodyLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.headingDark,
    ),
    bodyMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.bodyGray,
    ),
    bodySmall: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.bodyGray,
    ),
    labelLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.headingDark,
    ),
    labelMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.bodyGray,
    ),
  );
}
