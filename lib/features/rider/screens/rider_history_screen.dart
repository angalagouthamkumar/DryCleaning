import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RiderHistoryScreen extends StatefulWidget {
  final List<dynamic> orders;
  final Function(Map<String, dynamic>) onSelectOrder;
  final VoidCallback? onBackToHome;

  const RiderHistoryScreen({
    super.key,
    required this.orders,
    required this.onSelectOrder,
    this.onBackToHome,
  });

  @override
  State<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final activeOrders = widget.orders.where((o) {
      final s = (o['status']?.toString() ?? '').toLowerCase();
      return (s.contains('assigned') ||
              s.contains('pickup completed') ||
              s.contains('clothes picked up') ||
              s.contains('out for delivery') ||
              s.contains('reached')) &&
          !s.contains('delivered') &&
          !s.contains('received at store');
    }).toList();

    final completedOrders = widget.orders.where((o) {
      final s = (o['status']?.toString() ?? '').toLowerCase();
      return s.contains('delivered') || s.contains('received at store');
    }).toList();

    return Column(
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              if (widget.onBackToHome != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
                  onPressed: widget.onBackToHome,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (widget.onBackToHome != null) const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY ORDERS',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Active Accepted Orders Section
              if (activeOrders.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ACTIVE ACCEPTED ORDERS',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${activeOrders.length} IN PROGRESS',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...activeOrders.map((order) {
                  final o = order as Map<String, dynamic>;
                  final statusStr = o['status']?.toString() ?? '';
                  return GestureDetector(
                    onTap: () => widget.onSelectOrder(o),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusStr.toUpperCase(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'TAP TO CONTINUE',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            o['orderId']?.toString() ?? '',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${o['customerName'] ?? ''} (${o['customerPhone'] ?? ''})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${o['fullAddress'] ?? ''}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Completed History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMPLETED HISTORY',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cardFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${completedOrders.length} COMPLETED',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (completedOrders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'NO COMPLETED ORDERS YET',
                      style: TextStyle(fontSize: 13, color: AppColors.textGray, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else
                ...completedOrders.map((order) {
                  final o = order as Map<String, dynamic>;
                  final status = (o['status']?.toString() ?? '').toLowerCase();
                  final isStoreDrop = status.contains('received at store');

                  return GestureDetector(
                    onTap: () => widget.onSelectOrder(o),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardFill),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.cardFill,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isStoreDrop ? 'STORE DROP COMPLETED' : 'CUSTOMER DELIVERED',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                                ),
                              ),
                              Text(
                                '₹${o['grandTotal'] ?? 0}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            o['orderId']?.toString() ?? '',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${o['customerName'] ?? ''} (${o['customerPhone'] ?? ''})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
