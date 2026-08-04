import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/rider_provider.dart';
import '../widgets/rider_slide_button.dart';
import '../widgets/rider_cod_alert_dialog.dart';
import '../widgets/rider_responsive_wrapper.dart';

class RiderTaskDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;

  const RiderTaskDetailScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<RiderTaskDetailScreen> createState() => _RiderTaskDetailScreenState();
}

class _RiderTaskDetailScreenState extends ConsumerState<RiderTaskDetailScreen> {
  late Map<String, dynamic> _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = Map<String, dynamic>.from(widget.order);
  }

  void _openGoogleMaps() async {
    final lat = _currentOrder['latitude'] ?? 17.4485;
    final lng = _currentOrder['longitude'] ?? 78.3815;
    final url = Uri.parse(_currentOrder['liveLocationUrl']?.toString() ?? 'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openPhoneCall() async {
    final phone = _currentOrder['customerPhone']?.toString() ?? '';
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp() async {
    final raw = (_currentOrder['customerPhone']?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
    final cleanPhone = raw.length == 10 ? '91$raw' : raw;
    final url = Uri.parse('https://wa.me/$cleanPhone?text=Regarding%20your%20Order%20${_currentOrder['orderId']}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _advanceStep(String newStatus) async {
    final orderId = _currentOrder['orderId']?.toString() ?? '';
    final success = await ref.read(riderStateProvider.notifier).updateTaskStep(orderId, newStatus);
    if (mounted && success) {
      setState(() {
        _currentOrder['status'] = newStatus;
      });

      final lowerStatus = newStatus.toLowerCase();
      final isFinalStep = lowerStatus.contains('received') || lowerStatus.contains('delivered') || lowerStatus.contains('store');
      if (isFinalStep) {
        Navigator.pushNamedAndRemoveUntil(context, '/rider-main', (route) => false);
      }
    }
  }

  void _verifyDistanceAndReachedAtDrop() async {
    try {
      final destLat = (_currentOrder['latitude'] as num?)?.toDouble() ?? 17.4485;
      final destLng = (_currentOrder['longitude'] as num?)?.toDouble() ?? 78.3815;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 3));

      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destLat,
        destLng,
      );

      if (distanceInMeters > 50) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are ${distanceInMeters.toInt()}m away. You must be within 50m of drop location.'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
        return;
      }
    } catch (_) {}

    _advanceStep('Reached at Drop');
  }

  @override
  Widget build(BuildContext context) {
    final rawArg = ModalRoute.of(context)?.settings.arguments;
    if (_currentOrder.isEmpty && rawArg is Map) {
      _currentOrder = Map<String, dynamic>.from(rawArg);
    }
    if (_currentOrder.isEmpty && widget.order.isNotEmpty) {
      _currentOrder = Map<String, dynamic>.from(widget.order);
    }

    final status = (_currentOrder['status']?.toString() ?? '').toLowerCase();
    final isDeliveryFlow = status.contains('ready') ||
        status.contains('delivery partner assigned') ||
        status.contains('partner assigned') ||
        status.contains('out for delivery') ||
        status.contains('reached') ||
        status.contains('delivered') ||
        (_currentOrder['flowType']?.toString().toLowerCase() == 'delivery');
    final isPickupFlow = !isDeliveryFlow;
    final isCod = !(_currentOrder['paymentMethod']?.toString() ?? '').toUpperCase().contains('UPI');
    final grandTotal = _currentOrder['grandTotal'] ?? 0;

    final isSessionActive = !status.contains('placed') && !status.contains('received') && !status.contains('delivered') && !status.contains('cancel');

    return PopScope(
      canPop: !isSessionActive,
      child: RiderResponsiveWrapper(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.darkNavy,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: !isSessionActive,
            leading: isSessionActive
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: Text(
              'ORDER ${_currentOrder['orderId'] ?? ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentOrder['status']?.toString() ?? '',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
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
                          'CUSTOMER & ADDRESS DETAILS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentOrder['customerName']?.toString() ?? '',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentOrder['fullAddress'] ?? ''} ${_currentOrder['landmark'] != null ? '(${_currentOrder['landmark']})' : ''}',
                          style: const TextStyle(fontSize: 13, color: AppColors.darkNavy),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PAYMENT: ${_currentOrder['paymentMethod'] ?? "Cash on Delivery"} ${isCod ? "(COLLECT RS. $grandTotal)" : ""}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCod ? AppColors.accentOrange : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.navigation_rounded, size: 16),
                          label: const Text('MAPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkNavy,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _openPhoneCall,
                          icon: const Icon(Icons.phone_rounded, size: 16),
                          label: const Text('CALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: _openWhatsApp,
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: const Text('WHATSAPP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  /* Stepper Sequences */
                  if (isPickupFlow) ...[
                    if (status.contains('placed') || status.contains('pending') || status.contains('pickup assigned') || status.contains('on the way'))
                      RiderSlideButton(
                        label: 'MARK ORDER PICKED UP',
                        onConfirmed: () => _advanceStep('Pickup Completed'),
                      ),
                    if (status.contains('pickup completed') || status.contains('clothes picked up'))
                      RiderSlideButton(
                        label: 'DELIVER ORDER TO STORE',
                        onConfirmed: () => _advanceStep('Received at Store'),
                      ),
                    if (status.contains('store') || status.contains('received'))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'GARMENTS DELIVERED TO STORE. READY FOR CLEANING.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ] else ...[
                    if (status.contains('ready') || status.contains('delivery partner assigned') || status.contains('partner assigned'))
                      RiderSlideButton(
                        label: 'PICK UP AT STORE',
                        onConfirmed: () => _advanceStep('Out for Delivery'),
                      ),
                    if (status.contains('out for delivery'))
                      RiderSlideButton(
                        label: 'REACHED AT DROP',
                        onConfirmed: _verifyDistanceAndReachedAtDrop,
                      ),
                    if (status.contains('reached'))
                      RiderSlideButton(
                        label: 'MARK AS DELIVERED',
                        onConfirmed: () {
                          if (isCod) {
                            showDialog(
                              context: context,
                              builder: (context) => RiderCodAlertDialog(
                                amount: grandTotal,
                                onConfirm: () => _advanceStep('Delivered'),
                              ),
                            );
                          } else {
                            _advanceStep('Delivered');
                          }
                        },
                      ),
                    if (status.contains('delivered'))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'ORDER DELIVERED SUCCESSFULLY.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
