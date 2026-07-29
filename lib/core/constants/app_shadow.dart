import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppShadow {
  /// Soft shadow for cards
  static final List<BoxShadow> softCard = [
    BoxShadow(
      color: AppColors.darkNavy.withValues(alpha: 0.04),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  /// Medium shadow for buttons, chips, floating widgets
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.darkNavy.withValues(alpha: 0.06),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  /// Stronger shadow for bottom floating dock/cart bar
  static final List<BoxShadow> floatingDock = [
    BoxShadow(
      color: AppColors.darkNavy.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, -2),
    ),
  ];

  /// Large shadow for dialogs, bottom sheets, modals
  static final List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.darkNavy.withValues(alpha: 0.12),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];

  /// Very subtle shadow for small elements
  static final List<BoxShadow> light = [
    BoxShadow(
      color: AppColors.darkNavy.withValues(alpha: 0.02),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
}
