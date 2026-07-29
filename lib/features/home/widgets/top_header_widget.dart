import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

class TopHeaderWidget extends StatelessWidget {
  final bool isServiceable;
  final String etaText;
  final String distanceText;
  final String selectedAddress;
  final VoidCallback onAddressTap;
  final VoidCallback onProfileTap;

  const TopHeaderWidget({
    super.key,
    this.isServiceable = true,
    this.etaText = 'DryCleaning in 45 min',
    this.distanceText = 'updatelater',
    this.selectedAddress = 'Hasmathpet, Old Bowenpally',
    required this.onAddressTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DryCleaning',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                if (isServiceable)
                  Row(
                    children: [
                      Text(
                        etaText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.storefront_rounded,
                              size: 14,
                              color: AppColors.darkNavy,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distanceText,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Not serviceable at this location yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentCoral,
                    ),
                  ),
              ],
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.cardFill,
                child: Icon(Icons.person, color: AppColors.darkNavy, size: 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onAddressTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedAddress,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavy,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.darkNavy),
            ],
          ),
        ),
      ],
    );
  }
}
