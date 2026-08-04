import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../features/home/models/home_models.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ServiceRepository(dio);
});

class DynamicServicesData {
  final List<ServiceItem> services;
  final List<QuickPack> packs;

  DynamicServicesData({required this.services, required this.packs});
}

class ServiceRepository {
  final Dio _dio;

  ServiceRepository(this._dio);

  Future<DynamicServicesData> fetchServices() async {
    try {
      final response = await _dio.get('/services');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final List rawServices = data['services'] ?? [];
        final List rawPacks = data['packs'] ?? [];

        final services = rawServices.map((s) {
          return ServiceItem(
            id: s['id']?.toString() ?? s['_id']?.toString() ?? '',
            category: s['category']?.toString() ?? 'Dry Cleaning',
            title: s['title']?.toString() ?? s['name']?.toString() ?? '',
            price: s['price']?.toString() ?? '₹${s['priceValue'] ?? 60}',
            priceValue: (s['priceValue'] as num?)?.toDouble() ?? 60.0,
            originalPrice: s['originalPrice']?.toString(),
          );
        }).toList();

        final packs = rawPacks.map((p) {
          return QuickPack(
            id: p['id']?.toString() ?? p['_id']?.toString() ?? '',
            title: p['title']?.toString() ?? '',
            subtitle: p['subtitle']?.toString() ?? '',
            price: p['price']?.toString() ?? '₹${p['priceValue'] ?? 349}',
            priceValue: (p['priceValue'] as num?)?.toDouble() ?? 349.0,
          );
        }).toList();

        return DynamicServicesData(services: services, packs: packs);
      }
    } catch (_) {}

    return DynamicServicesData(
      services: const [
        ServiceItem(id: 's1', category: 'Dry Cleaning', title: "Men's Shirt / T-Shirt", price: '₹60', priceValue: 60, originalPrice: '₹80'),
        ServiceItem(id: 's2', category: 'Dry Cleaning', title: 'Trousers / Jeans', price: '₹70', priceValue: 70),
        ServiceItem(id: 's3', category: 'Dry Cleaning', title: '2-Piece Suit', price: '₹250', priceValue: 250, originalPrice: '₹300'),
        ServiceItem(id: 's4', category: 'Dry Cleaning', title: 'Silk Saree / Heavy Lehenga', price: '₹180', priceValue: 180),
        ServiceItem(id: 's5', category: 'Wash & Fold', title: 'Wash & Fold (per kg)', price: '₹50', priceValue: 50),
        ServiceItem(id: 's6', category: 'Wash & Iron', title: 'Daily Wear Wash & Iron', price: '₹80', priceValue: 80),
        ServiceItem(id: 's7', category: 'Steam Iron', title: 'Steam Iron Shirt/Top', price: '₹25', priceValue: 25),
        ServiceItem(id: 's8', category: 'Household', title: 'Double Blanket / Quilt', price: '₹350', priceValue: 350, originalPrice: '₹400'),
        ServiceItem(id: 's9', category: 'Household', title: 'Curtain Dry Clean (per panel)', price: '₹120', priceValue: 120),
      ],
      packs: const [
        QuickPack(id: 'p1', title: 'Weekly Laundry', subtitle: '5 Shirts + 3 Trousers', price: '₹349', priceValue: 349),
        QuickPack(id: 'p2', title: 'Office Wear', subtitle: '4 Suits + 4 Ties', price: '₹599', priceValue: 599),
        QuickPack(id: 'p3', title: 'Family Pack', subtitle: '15 Mixed Items Wash & Iron', price: '₹899', priceValue: 899),
      ],
    );
  }
}

final dynamicServicesProvider = FutureProvider<DynamicServicesData>((ref) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return await repo.fetchServices();
});
