import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

class AppServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const AppServiceCard({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.md,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.cardFill, borderRadius: AppRadius.md),
            child: Icon(icon, size: 32, color: AppColors.darkNavy),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
      ],
    );
  }
}
