import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary & Dark Text
  static const Color primary = Color(0xFF4ECCA3);
  static const Color primaryMint = Color(0xFF4ECCA3);
  static const Color darkNavy = Color(0xFF2D3A45);
  static const Color headingDark = Color(0xFF2D3A45);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF); // Added to fix AppColors.white
  static const Color cardFill = Color(0xFFEFEFEF);
  static const Color cardGray = Color(0xFFEFEFEF);
  static const Color sectionBg = Color(0xFFEAEAEA);

  // Text & Borders
  static const Color textDark = Color(0xFF2D3A45);
  static const Color textGray = Color(0xFF9BA1A6);
  static const Color bodyGray = Color(0xFF9BA1A6);
  static const Color textSecondary = Color(0xFF9BA1A6); // Added to fix AppColors.textSecondary
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0); // Added to fix AppColors.border
  static const Color shadowColor = Color(0x1F2D3A45);

  // Accents & States
  static const Color accentCoral = Color(0xFFEB5757);
  static const Color coralRed = Color(0xFFEB5757);
  static const Color accent = Color(0xFFEB5757);
  static const Color accentOrange = Color(0xFFE8863A);
  static const Color accentGold = Color(0xFFF2C14E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF2D3A45);

  // States
  static const Color activeTab = Color(0xFF4ECCA3);
  static const Color inactiveTab = Color(0xFF9BA1A6);
  static const Color mapPinDark = Color(0xFF2D3A45);
}

