import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../providers/location_provider.dart';
import '../models/home_models.dart';
import '../../search/screens/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(Map<String, int> cartItems, double cartTotal)? onCartUpdated;
  final VoidCallback? onOpenCheckout;

  const HomeScreen({super.key, this.onCartUpdated, this.onOpenCheckout});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Timer _placeholderTimer;
  int _placeholderIndex = 0;
  String _selectedCategoryFilter = 'All';

  final List<String> _placeholders = const [
    'Search "iron shirt"...',
    'Search "sneaker cleaning"...',
    'Search "dry clean saree"...',
    'Search "blanket wash"...',
  ];

  final List<String> _serviceCategories = const [
    'All',
    'Dry Cleaning',
    'Wash & Fold',
    'Wash & Iron',
    'Steam Iron',
    'Household',
  ];

  final List<ServiceItem> _allServices = const [
    ServiceItem(
      id: 's1',
      category: 'Dry Cleaning',
      title: 'Men\'s Shirt / T-Shirt',
      price: '₹60',
      priceValue: 60,
      originalPrice: '₹80',
    ),
    ServiceItem(
      id: 's2',
      category: 'Dry Cleaning',
      title: 'Trousers / Jeans',
      price: '₹70',
      priceValue: 70,
    ),
    ServiceItem(
      id: 's3',
      category: 'Dry Cleaning',
      title: '2-Piece Suit',
      price: '₹250',
      priceValue: 250,
      originalPrice: '₹300',
    ),
    ServiceItem(
      id: 's4',
      category: 'Dry Cleaning',
      title: 'Silk Saree / Heavy Lehenga',
      price: '₹180',
      priceValue: 180,
    ),
    ServiceItem(
      id: 's5',
      category: 'Wash & Fold',
      title: 'Wash & Fold (per kg)',
      price: '₹50',
      priceValue: 50,
    ),
    ServiceItem(
      id: 's6',
      category: 'Wash & Iron',
      title: 'Daily Wear Wash & Iron',
      price: '₹80',
      priceValue: 80,
    ),
    ServiceItem(
      id: 's7',
      category: 'Steam Iron',
      title: 'Steam Iron Shirt/Top',
      price: '₹25',
      priceValue: 25,
    ),
    ServiceItem(
      id: 's8',
      category: 'Household',
      title: 'Double Blanket / Quilt',
      price: '₹350',
      priceValue: 350,
      originalPrice: '₹400',
    ),
    ServiceItem(
      id: 's9',
      category: 'Household',
      title: 'Curtain Dry Clean (per panel)',
      price: '₹120',
      priceValue: 120,
    ),
  ];

  final List<QuickPack> _quickPacks = const [
    QuickPack(
      id: 'p1',
      title: 'Weekly Laundry',
      subtitle: '5 Shirts + 3 Trousers',
      price: '₹349',
      priceValue: 349,
    ),
    QuickPack(
      id: 'p2',
      title: 'Office Wear',
      subtitle: '4 Suits + 4 Ties',
      price: '₹599',
      priceValue: 599,
    ),
    QuickPack(
      id: 'p3',
      title: 'Family Pack',
      subtitle: '15 Mixed Items Wash & Iron',
      price: '₹899',
      priceValue: 899,
    ),
  ];

  final Map<String, int> _cartQuantities = {};

  @override
  void initState() {
    super.initState();
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _placeholderTimer.cancel();
    super.dispose();
  }

  int _calculateRealTimeEtaMins(double? custLat, double? custLng) {
    if (custLat == null || custLng == null) return 25;
    const storeLat = 17.476370;
    const storeLng = 78.488990;
    final dLat = (custLat - storeLat) * 111.0;
    final dLng = (custLng - storeLng) * 111.0;
    final distKm = math.sqrt(dLat * dLat + dLng * dLng);
    if (distKm < 0.5) return 15;
    final eta = (distKm * 5 + 15).round();
    return eta < 15 ? 15 : (eta > 60 ? 60 : eta);
  }

  void _openStoreOnGoogleMaps() async {
    final Uri storeMapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=17.476370,78.488990');
    try {
      await launchUrl(storeMapUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final current = _cartQuantities[itemId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cartQuantities.remove(itemId);
      } else {
        _cartQuantities[itemId] = next;
      }
    });
    _notifyCartChange();
  }

  void _notifyCartChange() {
    double total = 0.0;
    _cartQuantities.forEach((id, qty) {
      final service = _allServices.firstWhere(
        (s) => s.id == id,
        orElse: () => ServiceItem(id: id, category: '', title: '', price: '', priceValue: 349.0),
      );
      total += service.priceValue * qty;
    });
    if (widget.onCartUpdated != null) {
      widget.onCartUpdated!(_cartQuantities, total);
    }
  }

  void _showStainPhotoSheet(BuildContext context, String itemTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topSheet),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Stain/Damage Photo for $itemTitle',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload 1 to 5 photos so stain treatment notes and clear expectations are recorded before pickup.',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.cardFill,
                      borderRadius: AppRadius.md,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: AppColors.darkNavy, size: 24),
                        SizedBox(height: 4),
                        Text(
                          'Upload',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkNavy,
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Save Photo Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationStateProvider);
    final realTimeEta = _calculateRealTimeEtaMins(locationState.latitude, locationState.longitude);

    final filteredServices = _selectedCategoryFilter == 'All'
        ? _allServices
        : _allServices.where((s) => s.category == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header (Brand Name "DryCleaning" + Live Store Location & Calculated Real-time ETA)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DryCleaning',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Pickup in $realTimeEta mins',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            InkWell(
                              onTap: _openStoreOnGoogleMaps,
                              borderRadius: AppRadius.pill,
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  borderRadius: AppRadius.pill,
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.storefront_rounded,
                                      size: 13,
                                      color: AppColors.darkNavy,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Visit Store',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.darkNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationState.currentAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkNavy,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.darkNavy,
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      borderRadius: AppRadius.pill,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.cardFill,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded, color: AppColors.darkNavy),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 2. Interactive Search Bar with Live Sync
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    final updatedCart = await Navigator.push<Map<String, int>>(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => SearchScreen(
                          initialCartItems: _cartQuantities,
                          onCartUpdated: (items, total) {
                            setState(() {
                              _cartQuantities.clear();
                              _cartQuantities.addAll(items);
                            });
                            _notifyCartChange();
                          },
                        ),
                      ),
                    );
                    if (updatedCart != null) {
                      setState(() {
                        _cartQuantities.clear();
                        _cartQuantities.addAll(updatedCart);
                      });
                      _notifyCartChange();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardFill,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textGray, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _placeholders[_placeholderIndex],
                              key: ValueKey<int>(_placeholderIndex),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 3. Category Tabs
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _serviceCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _serviceCategories[index];
                    final isSelected = cat == _selectedCategoryFilter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryFilter = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkNavy : AppColors.cardFill,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 4. Quick Saver Packs Carousel
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Quick Saver Packs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickPacks.length,
                  itemBuilder: (context, index) {
                    final pack = _quickPacks[index];
                    final qty = _cartQuantities[pack.id] ?? 0;
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardFill,
                        borderRadius: AppRadius.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pack.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pack.subtitle,
                                style: const TextStyle(fontSize: 11, color: AppColors.textGray),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pack.price,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              if (qty == 0)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _updateQuantity(pack.id, 1),
                                  child: const Text('ADD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: AppRadius.pill,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                        onPressed: () => _updateQuantity(pack.id, -1),
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                        onPressed: () => _updateQuantity(pack.id, 1),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 5. Individual Garments / Services Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategoryFilter == 'All' ? 'Popular Garment Services' : _selectedCategoryFilter,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    Text(
                      '${filteredServices.length} items',
                      style: const TextStyle(fontSize: 12, color: AppColors.textGray, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  final qty = _cartQuantities[service.id] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardFill,
                      borderRadius: AppRadius.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadius.md,
                          ),
                          child: const Icon(
                            Icons.dry_cleaning_rounded,
                            color: AppColors.darkNavy,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    service.price,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  if (service.originalPrice != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      service.originalPrice!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGray,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.center_focus_strong_rounded, size: 20, color: AppColors.textGray),
                          tooltip: 'Add Stain Photo',
                          onPressed: () => _showStainPhotoSheet(context, service.title),
                        ),
                        const SizedBox(width: 4),
                        if (qty == 0)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                              elevation: 0,
                            ),
                            onPressed: () => _updateQuantity(service.id, 1),
                            child: const Text('ADD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadius.pill,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                  onPressed: () => _updateQuantity(service.id, -1),
                                ),
                                Text(
                                  '$qty',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                  onPressed: () => _updateQuantity(service.id, 1),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
