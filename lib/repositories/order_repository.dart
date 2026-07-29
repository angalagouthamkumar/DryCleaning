import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRepository(dio);
});

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  /// Fetch orders from MongoDB Atlas backend API
  Future<List<Map<String, dynamic>>> fetchOrders({String? phoneNumber}) async {
    try {
      final response = await _dio.get(
        '/orders',
        queryParameters: phoneNumber != null && phoneNumber.isNotEmpty
            ? {'phoneNumber': phoneNumber}
            : null,
      );
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Fetch orders Dio error: ${e.message}');
      return [];
    } catch (e) {
      print('Fetch orders error: $e');
      return [];
    }
  }

  /// Create order and save to MongoDB Atlas via backend API
  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/orders', data: payload);
      if (response.data != null && response.data['success'] == true) {
        return response.data['data']?['order'];
      }
      return null;
    } on DioException catch (e) {
      print('Create order Dio error: ${e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Failed to place order.');
    } catch (e) {
      print('Create order error: $e');
      throw Exception(e.toString());
    }
  }

  /// Update status of an existing order
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _dio.patch('/orders/$orderId/status', data: {'status': newStatus});
      return response.data?['success'] == true;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }
}
