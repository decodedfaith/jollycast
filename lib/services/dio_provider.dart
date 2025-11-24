import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.jollypodcast.net',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor());

  return dio;
});

class AuthInterceptor extends Interceptor {
  static const String _userKey = 'user_data';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for login endpoint
    if (options.path.contains('/api/auth/login')) {
      return handler.next(options);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);

      if (userStr != null) {
        final userData = jsonDecode(userStr);
        final token = userData['token'] as String?;

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      // Silently handle errors
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear the stored user data
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_userKey);
      } catch (e) {
        // Silently handle errors
      }
    }
    return handler.next(err);
  }
}
