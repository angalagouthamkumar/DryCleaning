import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RiderProfileScreen extends StatelessWidget {
  final List<dynamic> orders;
  final String phoneNumber;
  final VoidCallback? onBackToHome;

  const RiderProfileScreen({
    super.key,
    this.orders = const [],
    this.phoneNumber = '',
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = orders.where((o) {
      final status = (o['status']?.toString() ?? '').toLowerCase();
      return status.contains('delivered');
    }).length;

    final displayPhone = phoneNumber.isNotEmpty ? phoneNumber : 'PARTNER MOBILE NOT AVAILABLE';
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final shortSuffix = cleanDigits.length >= 4 ? cleanDigits.substring(cleanDigits.length - 4) : '101';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (onBackToHome != null)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
                onPressed: onBackToHome,
              ),
            ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardFill),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'RIDER PARTNER (#$shortSuffix)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 4),
                Text(
                  displayPhone,
                  style: const TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardFill),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PARTNER STATS & BADGES',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 12),
                _buildStatRow('ACCOUNT STATUS', 'APPROVED'),
                const Divider(),
                _buildStatRow('TOTAL COMPLETED DELIVERIES', '$completedCount ORDERS'),
                const Divider(),
                _buildStatRow('STORE LOCATION', 'Hasmathpet, Bowenpally'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGray)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
        ],
      ),
    );
  }
}
