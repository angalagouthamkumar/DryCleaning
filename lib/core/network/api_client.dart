import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String kLocalUrl = 'http://localhost:3000/api/v1';
const String kProdUrl = 'https://backend-phi-five-63.vercel.app/api/v1';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: kIsWeb ? kLocalUrl : kProdUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'rider_token') ?? await storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.requestOptions.baseUrl == kLocalUrl) {
          try {
            final fallbackDio = Dio(
              BaseOptions(
                baseUrl: kProdUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );
            final response = await fallbackDio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (_) {}
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
