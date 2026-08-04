import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final riderRepositoryProvider = Provider<RiderRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return RiderRepository(dio, storage);
});

class RiderRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  RiderRepository(this._dio, this._storage);

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'phoneNumber': phoneNumber,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to send OTP code';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      });
      final data = response.data['data'];
      if (data != null && data['token'] != null) {
        await saveToken(data['token']);
      }
      await saveRiderPhone(phoneNumber);
      await _storage.write(key: 'rider_is_logged_in', value: 'true');
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Invalid verification code';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getRiderTasks() async {
    try {
      final response = await _dio.get('/rider/tasks');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to fetch rider tasks';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> acceptTask(String orderId, String flowType) async {
    try {
      final response = await _dio.post('/rider/tasks/$orderId/accept', data: {
        'flowType': flowType,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to accept task';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> updateTaskStep(String orderId, String status) async {
    try {
      final response = await _dio.patch('/rider/tasks/$orderId/step', data: {
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to update task step';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getDailyEarnings(String dateStr) async {
    try {
      final response = await _dio.get('/rider/earnings/day', queryParameters: {'date': dateStr});
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getWeeklyEarnings(String startDateStr) async {
    try {
      final response = await _dio.get('/rider/earnings/week', queryParameters: {'startDate': startDateStr});
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getMonthlyEarnings(String monthStr) async {
    try {
      final response = await _dio.get('/rider/earnings/month', queryParameters: {'month': monthStr});
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getEarningsBreakdown() async {
    try {
      final response = await _dio.get('/rider/earnings/breakdown');
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getEarningsReport() async {
    try {
      final response = await _dio.get('/rider/earnings/report');
      return response.data['data'] ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> saveRiderPhone(String phone) async {
    try {
      await _storage.write(key: 'rider_phone_number', value: phone);
    } catch (_) {}
  }

  Future<String?> getRiderPhone() async {
    try {
      return await _storage.read(key: 'rider_phone_number');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'rider_token', value: token);
      await _storage.write(key: 'rider_is_logged_in', value: 'true');
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'rider_token');
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'rider_token');
      await _storage.delete(key: 'rider_is_logged_in');
      await _storage.delete(key: 'rider_phone_number');
    } catch (_) {}
  }
}
