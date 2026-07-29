import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/buttons/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(color: AppColors.cardFill, shape: BoxShape.circle),
                child: const Icon(Icons.dry_cleaning_rounded, size: 90, color: AppColors.darkNavy),
              ),
              const SizedBox(height: 40),
              const Text(
                'Premium Care for Your Garments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Schedule pickup and delivery at your convenience. Fast, reliable, and hassle-free dry cleaning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGray,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
