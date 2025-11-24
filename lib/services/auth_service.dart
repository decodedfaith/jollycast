import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'dio_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<User> login(String phone, String password) async {
    try {
      final formData = FormData.fromMap({
        'phone_number': phone,
        'password': password,
      });

      final response = await _dio.post('/api/auth/login', data: formData);

      if (response.statusCode == 200) {
        return User.fromApiResponse(response.data);
      } else {
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
