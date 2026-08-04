import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

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

  Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/resend-otp', data: {
        'phoneNumber': phoneNumber,
      });
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to resend OTP code';
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
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Invalid verification code';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> firebaseLogin(String idToken, String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/firebase-login', data: {
        'idToken': idToken,
        'phoneNumber': phoneNumber,
      });
      final data = response.data['data'];
      if (data != null && data['token'] != null) {
        await saveToken(data['token']);
      }
      return response.data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Firebase authentication failed';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data['data'];
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    try {
      await _storage.write(key: 'is_logged_in', value: 'true');
      await _storage.write(key: 'user_data', value: jsonEncode(user));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final raw = await _storage.read(key: 'user_data');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> isLoggedIn() async {
    try {
      final val = await _storage.read(key: 'is_logged_in');
      final raw = await _storage.read(key: 'user_data');
      final token = await _storage.read(key: 'auth_token');
      return val == 'true' || (token != null && token.isNotEmpty) || (raw != null && raw.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'is_logged_in');
      await _storage.delete(key: 'user_data');
    } catch (_) {}
  }
}
