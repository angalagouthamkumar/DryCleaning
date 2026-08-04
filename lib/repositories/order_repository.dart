import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      final queryParams = <String, dynamic>{};
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        queryParams['phoneNumber'] = phoneNumber;
      }
      final response = await _dio.get(
        '/orders',
        queryParameters: queryParams,
      );
      if (response.data != null && response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Fetch orders Dio error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Fetch orders error: $e');
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
      debugPrint('Create order Dio error: ${e.message}');
      throw Exception(e.response?.data?['message'] ?? 'Failed to place order.');
    } catch (e) {
      debugPrint('Create order error: $e');
      throw Exception(e.toString());
    }
  }

  /// Update status of an existing order
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await _dio.patch('/orders/$orderId/status', data: {'status': newStatus});
      return response.data?['success'] == true;
    } catch (e) {
      debugPrint('Update order status error: $e');
      return false;
    }
  }

  /// Upload real recorded audio file to backend API
  Future<String?> uploadAudio(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(filePath, filename: 'voice_note.m4a'),
      });
      final response = await _dio.post('/upload/audio', data: formData);
      if (response.data != null && response.data['success'] == true) {
        return response.data['data']?['url'];
      }
    } catch (e) {
      debugPrint('Upload audio error: $e');
    }
    return null;
  }

  /// Upload real garment images to backend API
  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      if (filePaths.isEmpty) return [];
      final List<MultipartFile> files = [];
      for (final p in filePaths) {
        files.add(await MultipartFile.fromFile(p, filename: 'garment_photo.jpg'));
      }
      final formData = FormData.fromMap({
        'images': files,
      });
      final response = await _dio.post('/upload/image', data: formData);
      if (response.data != null && response.data['success'] == true) {
        final List urls = response.data['data']?['urls'] ?? [];
        return urls.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Upload images error: $e');
    }
    return [];
  }
}
