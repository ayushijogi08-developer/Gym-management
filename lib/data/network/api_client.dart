import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  static final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
          headers: {
      'Content-Type': 'application/json',
    },
    ),
  );

  static bool _initialized = false;

  static Dio get instance {
    if (!_initialized) {
      _initialized = true;

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _storage.read(key: 'jwt_token');
debugPrint("DEBUG: Sending Token: $token");
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              await _storage.delete(key: 'jwt_token');
            }

            handler.next(error);
          },
        ),
      );
    }

    return _dio;
  }

  static Future<Response> get(String path,
      {Map<String, dynamic>? params}) {
    return instance.get(path, queryParameters: params);
  }

  static Future<Response> post(String path, {dynamic data}) {
    return instance.post(path, data: data);
  }

  // FIX: Changed from positional to named parameter with default
  static Future<Response> put(String path, {dynamic data}) {
    return instance.put(path, data: data);
  }

  static Future<Response> delete(String path) {
    return instance.delete(path);
  
  }
  // ADD THIS METHOD
  static Future<Response> patch(String path, {dynamic data}) {
    return instance.patch(path, data: data);
  }
}