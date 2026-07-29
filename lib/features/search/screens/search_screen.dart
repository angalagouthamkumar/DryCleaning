import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadow.dart';
import '../../home/models/home_models.dart';
import '../../checkout/screens/checkout_screen.dart';

class SearchScreen extends StatefulWidget {
  final Map<String, int>? initialCartItems;
  final Function(Map<String, int> cartItems, double cartTotal)? onCartUpdated;

  const SearchScreen({super.key, this.initialCartItems, this.onCartUpdated});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final List<ServiceItem> _allServices = const [
    ServiceItem(id: 's1', category: 'Dry Cleaning', title: 'Men\'s Shirt / T-Shirt', price: '₹60', priceValue: 60, originalPrice: '₹80'),
    ServiceItem(id: 's2', category: 'Dry Cleaning', title: 'Trousers / Jeans', price: '₹70', priceValue: 70),
    ServiceItem(id: 's3', category: 'Dry Cleaning', title: '2-Piece Suit', price: '₹250', priceValue: 250, originalPrice: '₹300'),
    ServiceItem(id: 's4', category: 'Dry Cleaning', title: 'Silk Saree / Heavy Lehenga', price: '₹180', priceValue: 180),
    ServiceItem(id: 's5', category: 'Wash & Fold', title: 'Wash & Fold (per kg)', price: '₹50', priceValue: 50),
    ServiceItem(id: 's6', category: 'Wash & Iron', title: 'Daily Wear Wash & Iron', price: '₹80', priceValue: 80),
    ServiceItem(id: 's7', category: 'Steam Iron', title: 'Steam Iron Shirt/Top', price: '₹25', priceValue: 25),
    ServiceItem(id: 's8', category: 'Household', title: 'Double Blanket / Quilt', price: '₹350', priceValue: 350, originalPrice: '₹400'),
    ServiceItem(id: 's9', category: 'Household', title: 'Curtain Dry Clean (per panel)', price: '₹120', priceValue: 120),
    ServiceItem(id: 's10', category: 'Shoe Care', title: 'Sneaker Cleaning & Polish', price: '₹299', priceValue: 299),
  ];

  late final Map<String, int> _cartQuantities;

  @override
  void initState() {
    super.initState();
    _cartQuantities = Map<String, int>.from(widget.initialCartItems ?? {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalItemCount {
    int count = 0;
    _cartQuantities.forEach((key, val) => count += val);
    return count;
  }

  double get _cartTotal {
    double total = 0.0;
    _cartQuantities.forEach((id, qty) {
      final service = _allServices.firstWhere(
        (s) => s.id == id,
        orElse: () => ServiceItem(id: id, category: '', title: '', price: '', priceValue: 60.0),
      );
      total += service.priceValue * qty;
    });
    return total;
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

    if (widget.onCartUpdated != null) {
      widget.onCartUpdated!(_cartQuantities, _cartTotal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allServices.where((item) {
      final matchesQuery = _query.isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.category.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.onCartUpdated != null) {
          widget.onCartUpdated!(_cartQuantities, _cartTotal);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkNavy),
            onPressed: () => Navigator.pop(context, _cartQuantities),
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
            decoration: const InputDecoration(
              hintText: 'Search "shirt", "suit", "blanket"...',
              hintStyle: TextStyle(color: AppColors.textGray, fontSize: 14),
              border: InputBorder.none,
            ),
            onChanged: (val) {
              setState(() {
                _query = val.trim();
              });
            },
          ),
          actions: [
            if (_query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textGray),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                  });
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Category quick filters
                Container(
                  height: 48,
                  color: Colors.white,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: ['All', 'Dry Cleaning', 'Wash & Fold', 'Wash & Iron', 'Steam Iron', 'Household', 'Shoe Care'].map((cat) {
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.cardFill,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.darkNavy,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1),

                // Search results list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: AppColors.textGray.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text(
                                'No services found for "$_query"',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkNavy),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Try searching for "shirt", "saree", "suit", or "blanket"',
                                style: TextStyle(fontSize: 12, color: AppColors.textGray),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: _totalItemCount > 0 ? 80 : 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final qty = _cartQuantities[item.id] ?? 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.md,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: const Icon(Icons.dry_cleaning_rounded, color: AppColors.darkNavy, size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.category} • ${item.price}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (qty == 0)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
                                      ),
                                      onPressed: () => _updateQuantity(item.id, 1),
                                      child: const Text('ADD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
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
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                                            onPressed: () => _updateQuantity(item.id, -1),
                                          ),
                                          Text(
                                            '$qty',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                            onPressed: () => _updateQuantity(item.id, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Sticky Floating Cart Bar (Blinkit style checkout entry)
            if (_totalItemCount > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          subtotal: _cartTotal,
                          initialCartItems: _cartQuantities,
                          onOrderPlaced: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context, _cartQuantities);
                            }
                          },
                        ),
                      ),
                    );
                  },
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
      ),
    );
  }
}
