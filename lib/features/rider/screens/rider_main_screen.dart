import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

import '../providers/rider_provider.dart';
import '../widgets/rider_slide_button.dart';
import '../widgets/rider_responsive_wrapper.dart';
import 'rider_history_screen.dart';
import 'rider_profile_screen.dart';

class RiderMainScreen extends ConsumerStatefulWidget {
  const RiderMainScreen({super.key});

  @override
  ConsumerState<RiderMainScreen> createState() => _RiderMainScreenState();
}

class _RiderMainScreenState extends ConsumerState<RiderMainScreen> with SingleTickerProviderStateMixin {
  int _activeNavIndex = 0;
  late TabController _taskTabController;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _taskTabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(riderStateProvider.notifier).fetchTasks();
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          ref.read(riderStateProvider.notifier).fetchTasks(silent: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _taskTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riderState = ref.watch(riderStateProvider);
    final orders = riderState.orders;
    final screenHeight = MediaQuery.of(context).size.height;

    final pickupOrders = orders.where((o) {
      final s = (o['status']?.toString() ?? '').toLowerCase();
      return (s.contains('placed') || s.contains('pending')) && !s.contains('assigned');
    }).toList();

    final deliveryOrders = orders.where((o) {
      final s = (o['status']?.toString() ?? '').toLowerCase();
      return s.contains('ready') && !s.contains('assigned') && !s.contains('out for delivery') && !s.contains('reached') && !s.contains('delivered');
    }).toList();

    return RiderResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _activeNavIndex == 1
            ? SafeArea(
                child: RiderHistoryScreen(
                  orders: orders,
                  onSelectOrder: (order) {
                    Navigator.pushNamed(context, '/rider-task-detail', arguments: order);
                  },
                  onBackToHome: () => setState(() => _activeNavIndex = 0),
                ),
              )
            : _activeNavIndex == 2
                ? SafeArea(
                    child: RiderProfileScreen(
                      orders: orders,
                      phoneNumber: riderState.phoneNumber,
                      onBackToHome: () => setState(() => _activeNavIndex = 0),
                    ),
                  )
                : NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          pinned: true,
                          floating: false,
                          stretch: false,
                          snap: false,
                          toolbarHeight: 52,
                          collapsedHeight: screenHeight * 0.12,
                          expandedHeight: screenHeight * 0.30,
                          backgroundColor: const Color(0xFFE2E8F0),
                          elevation: 1,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                riderState.phoneNumber.isNotEmpty ? 'RIDER ${riderState.phoneNumber}' : 'RIDER PARTNER #101',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=17.476370,78.488990');
                                      try {
                                        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                                      } catch (_) {}
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.storefront_rounded, size: 12, color: AppColors.darkNavy),
                                          SizedBox(width: 4),
                                          Text(
                                            'Visit Store',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(riderStateProvider.notifier).toggleDuty();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: Text(
                                        riderState.isOnDuty ? 'ONLINE' : 'OFFLINE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: riderState.isOnDuty ? AppColors.primary : AppColors.textGray,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: AppColors.darkNavy, size: 20),
                                onPressed: () {
                                  ref.read(riderStateProvider.notifier).fetchTasks();
                                },
                              ),
                            ],
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              color: const Color(0xFFF1F5F9),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: !riderState.isOnDuty
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.cardFill),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.storefront_rounded, size: 48, color: AppColors.darkNavy),
                                  SizedBox(height: 16),
                                  Text(
                                    'YOU ARE CURRENTLY OFFLINE',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'REACH THE STORE TO GET QUICK ORDERS',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: TabBar(
                                  controller: _taskTabController,
                                  indicatorColor: AppColors.primary,
                                  labelColor: AppColors.darkNavy,
                                  unselectedLabelColor: AppColors.textGray,
                                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  tabs: [
                                    Tab(text: 'PICKUP TASKS (${pickupOrders.length})'),
                                    Tab(text: 'DELIVERY TASKS (${deliveryOrders.length})'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _taskTabController,
                                  children: [
                                    _buildTaskList(pickupOrders, 'PICKUP FROM CUSTOMER', 'pickup'),
                                    _buildTaskList(deliveryOrders, 'PICKUP FROM STORE', 'delivery'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _activeNavIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGray,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          onTap: (index) {
            setState(() {
              _activeNavIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'ORDERS'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> taskList, String badgeText, String flowType) {
    if (taskList.isEmpty) {
      return Center(
        child: Text(
          'NO ACTIVE ${flowType.toUpperCase()} TASKS ASSIGNED RIGHT NOW',
          style: const TextStyle(fontSize: 13, color: AppColors.textGray, fontWeight: FontWeight.w700),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        final order = taskList[index] as Map<String, dynamic>;
        final isCod = !(order['paymentMethod']?.toString() ?? '').toUpperCase().contains('UPI');

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.darkNavy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCod ? const Color(0xFFFFF4EC) : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCod ? 'COD: RS. ${order['grandTotal'] ?? 0}' : 'PAID ONLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isCod ? AppColors.accentOrange : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order['orderId']?.toString() ?? '',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
              ),
              const SizedBox(height: 4),
              Text(
                order['customerName']?.toString() ?? '',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${order['fullAddress'] ?? ''} ${order['landmark'] != null ? '(${order['landmark']})' : ''}',
                      style: const TextStyle(fontSize: 13, color: AppColors.darkNavy),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textGray),
                  const SizedBox(width: 4),
                  Text(
                    'SLOT: ${order['pickupDate'] ?? ''} (${order['pickupSlot'] ?? ''})',
                    style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              RiderSlideButton(
                label: 'SLIDE TO ACCEPT ORDER',
                onConfirmed: () async {
                  final nav = Navigator.of(context);
                  final success = await ref.read(riderStateProvider.notifier).acceptTask(order['orderId']?.toString() ?? '', flowType);
                  if (success) {
                    setState(() {
                      _activeNavIndex = 1;
                    });
                    nav.pushNamed('/rider-task-detail', arguments: Map<String, dynamic>.from(order));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
