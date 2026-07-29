import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/order_provider.dart';
import '../../checkout/screens/checkout_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackToHome;
  const OrdersScreen({super.key, this.onBackToHome});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _selectedSegment = 0; // 0 = Active, 1 = Past

  final List<String> _stages = const [
    'Placed',
    'Confirmed',
    'Picked Up',
    'In Cleaning',
    'Ready',
    'Out for Delivery',
    'Delivered',
  ];

  int _getStageIndex(String status) {
    switch (status.trim().toLowerCase()) {
      case 'placed':
        return 0;
      case 'confirmed':
        return 1;
      case 'picked up':
      case 'picked_up':
        return 2;
      case 'in cleaning':
      case 'incleaning':
        return 3;
      case 'ready':
        return 4;
      case 'out for delivery':
      case 'outfordelivery':
        return 5;
      case 'delivered':
        return 6;
      default:
        return 0;
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (_) {}
  }

  void _openWhatsApp(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanPhone?text=Hi%2C%20inquiring%20about%20my%20DryCleaning%20order');
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showCancelConfirmationDialog(String orderId, String orderMongoId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        title: const Text('Cancel Order?', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy)),
        content: Text('Are you sure you want to cancel Order #$orderId? It will be moved to Past History as Cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Order', style: TextStyle(color: AppColors.textGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(ordersProvider.notifier).updateOrderStatus(orderMongoId, 'Cancelled');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚫 Order cancelled and moved to Past History.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final allOrders = ordersState.orders;

    final activeOrders = allOrders.where((o) {
      final st = (o['status'] ?? 'Placed').toString().trim().toLowerCase();
      return st != 'delivered' && st != 'cancelled';
    }).toList();

    final pastOrders = allOrders.where((o) {
      final st = (o['status'] ?? 'Placed').toString().trim().toLowerCase();
      return st == 'delivered' || st == 'cancelled';
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkNavy),
            onPressed: () {
              ref.read(ordersProvider.notifier).fetchOrders();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(ordersProvider.notifier).fetchOrders();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Segmented Toggle
                Container(
                  height: 42,
                  decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: AppRadius.pill),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSegment = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedSegment == 0 ? AppColors.darkNavy : Colors.transparent,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Center(
                              child: Text(
                                'Active Orders (${activeOrders.length})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedSegment == 0 ? Colors.white : AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSegment = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedSegment == 1 ? AppColors.darkNavy : Colors.transparent,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Center(
                              child: Text(
                                'Past History (${pastOrders.length})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedSegment == 1 ? Colors.white : AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (ordersState.isLoading && allOrders.isEmpty)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else
                  Expanded(
                    child: _selectedSegment == 0
                        ? _buildActiveOrdersList(activeOrders)
                        : _buildPastOrdersList(pastOrders),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrdersList(List<Map<String, dynamic>> activeOrders) {
    if (activeOrders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.local_laundry_service_outlined, size: 64, color: AppColors.textGray.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text(
                  'No active laundry orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Place an order from home screen to get live status updates',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        final orderId = order['orderId'] ?? order['id'] ?? 'ORD-000';
        final grandTotal = order['grandTotal'] ?? 0;
        final items = (order['items'] as List?) ?? [];
        final itemsCount = items.fold<int>(0, (sum, i) => sum + ((i['quantity'] ?? 1) as int));
        final status = (order['status'] ?? 'Placed').toString();
        final stageIndex = _getStageIndex(status);

        // Extract Customer Payment Method
        final paymentMethodRaw = (order['paymentMethod'] ?? 'Cash on Delivery').toString();
        final String paymentBadgeText = paymentMethodRaw.contains('SemPay')
            ? 'SemPay UPI Gateway'
            : (paymentMethodRaw.contains('UPI') ? 'UPI Payment' : 'Cash on Delivery (COD)');

        // Real-Time Time & Estimated Delivery calculations
        final String rawCreatedAt = order['createdAt']?.toString() ?? DateTime.now().toIso8601String();
        DateTime orderDateTime;
        try {
          orderDateTime = DateTime.parse(rawCreatedAt).toLocal();
        } catch (_) {
          orderDateTime = DateTime.now();
        }

        final int displayHour = (orderDateTime.hour % 12 == 0) ? 12 : (orderDateTime.hour % 12);
        final String hourStr = displayHour.toString().padLeft(2, '0');
        final String minuteStr = orderDateTime.minute.toString().padLeft(2, '0');
        final String periodStr = orderDateTime.hour >= 12 ? 'PM' : 'AM';
        final String formattedOrderTime = "$hourStr:$minuteStr $periodStr, ${orderDateTime.day} July ${orderDateTime.year}";

        // Estimated Delivery: DATE ONLY
        final DateTime estDeliveryDate = orderDateTime.add(const Duration(hours: 24));
        final String formattedEstDelivery = "${estDeliveryDate.day} July ${estDeliveryDate.year}";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$orderId',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${itemsCount > 0 ? "$itemsCount Items" : "Garments"} • ₹$grandTotal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.pill),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ],
              ),

              // Real-Time Time & Estimated Delivery & Payment Mode Card
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment_rounded, size: 15, color: AppColors.darkNavy),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Mode: $paymentBadgeText',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 15, color: AppColors.darkNavy),
                        const SizedBox(width: 8),
                        Text(
                          'Ordered at: $formattedOrderTime',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_rounded, size: 15, color: AppColors.darkNavy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚡ Estimated Delivery: $formattedEstDelivery',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timeline Tracker
              const Text(
                'Live Progress Tracker',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_stages.length, (idx) {
                  final isDone = idx <= stageIndex;
                  final isCurrent = idx == stageIndex;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: Icon(
                                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 20,
                                color: isDone ? AppColors.primary : AppColors.textGray,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _stages[idx],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCurrent
                                  ? FontWeight.w900
                                  : (isDone ? FontWeight.w700 : FontWeight.w400),
                              color: isCurrent
                                  ? AppColors.darkNavy
                                  : (isDone ? AppColors.darkNavy : AppColors.textGray),
                            ),
                          ),
                        ],
                      ),
                      if (idx < _stages.length - 1)
                        Container(
                          margin: const EdgeInsets.only(left: 9, top: 2, bottom: 2),
                          width: 2,
                          height: 18,
                          color: idx < stageIndex
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Cancel Order Action Button (Customer Action)
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                  ),
                  onPressed: () {
                    final orderMongoId = (order['_id'] ?? order['orderId'] ?? order['id']).toString();
                    _showCancelConfirmationDialog(orderId.toString(), orderMongoId);
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                  label: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.redAccent),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Call / WhatsApp Shop Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkNavy),
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      ),
                      onPressed: () => _makePhoneCall('918341726226'),
                      icon: const Icon(Icons.call, size: 16, color: AppColors.darkNavy),
                      label: const Text(
                        'Call Shop',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF25D366)), // WhatsApp Green
                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      ),
                      onPressed: () => _openWhatsApp('918341726226'),
                      icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF25D366)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPastOrdersList(List<Map<String, dynamic>> pastOrders) {
    if (pastOrders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 64, color: AppColors.textGray.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                const Text(
                  'No past orders yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Delivered and cancelled orders will appear in your past history',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: pastOrders.length,
      itemBuilder: (context, index) {
        final order = pastOrders[index];
        final orderId = order['orderId'] ?? order['id'] ?? 'ORD-000';
        final grandTotal = order['grandTotal'] ?? 0;
        final items = (order['items'] as List?) ?? [];
        final summaryText = items.map((i) => "${i['quantity']}x ${i['name']}").join(", ");
        final isCancelled = (order['status'] ?? '').toString().toLowerCase() == 'cancelled';
        final statusLabel = isCancelled ? 'CANCELLED' : 'DELIVERED';
        final statusColor = isCancelled ? Colors.redAccent : AppColors.primary;

        final paymentMethodRaw = (order['paymentMethod'] ?? 'Cash on Delivery').toString();
        final String paymentBadgeText = paymentMethodRaw.contains('SemPay')
            ? 'SemPay UPI'
            : (paymentMethodRaw.contains('UPI') ? 'UPI' : 'COD');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.cardFill, borderRadius: AppRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                summaryText.isNotEmpty ? '$summaryText • ₹$grandTotal • $paymentBadgeText' : 'Dry Cleaning • ₹$grandTotal • $paymentBadgeText',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCancelled ? 'Order Cancelled' : 'Completed Order',
                    style: const TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkNavy),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () {
                      final double orderTotal = (grandTotal is num) ? grandTotal.toDouble() : 470.0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => CheckoutScreen(
                            subtotal: orderTotal > 45.0 ? (orderTotal - 45.0) : 470.0,
                            onOrderPlaced: () {
                              ref.read(ordersProvider.notifier).fetchOrders();
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Reorder',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
