import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_shadow.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  Map<String, int> _cartItems = {};
  double _cartTotal = 0.0;

  void _onCartUpdated(Map<String, int> items, double total) {
    setState(() {
      _cartItems = items;
      _cartTotal = total;
    });
  }

  int get _totalItemCount {
    int count = 0;
    _cartItems.forEach((key, val) => count += val);
    return count;
  }

  void _openCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          subtotal: _cartTotal,
          initialCartItems: _cartItems,
          onOrderPlaced: () {
            setState(() {
              _cartItems.clear();
              _cartTotal = 0.0;
              _currentIndex = 1; // switch directly to Orders tab
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onCartUpdated: _onCartUpdated, onOpenCheckout: _openCheckout),
      OrdersScreen(onBackToHome: () => setState(() => _currentIndex = 0)),
      ProfileScreen(onBackToHome: () => setState(() => _currentIndex = 0)),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            screens[_currentIndex],

            // Floating Sticky Cart Bar (Blinkit style checkout entry)
            if (_totalItemCount > 0 && _currentIndex == 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: _openCheckout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy,
                      borderRadius: AppRadius.pill,
                      boxShadow: AppShadow.floatingDock,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 16,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_totalItemCount ITEMS',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '₹${_cartTotal.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'View Cart & Pay',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.topSheet,
            boxShadow: AppShadow.floatingDock,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.topSheet,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: AppColors.darkNavy,
              unselectedItemColor: AppColors.textGray,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
