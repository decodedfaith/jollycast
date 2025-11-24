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
    print('AuthService: Attempting login for $phone');
    try {
      final formData = FormData.fromMap({
        'phone_number': phone,
        'password': password,
      });

      final response = await _dio.post('/api/auth/login', data: formData);

      print('AuthService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return User.fromApiResponse(response.data);
      } else {
        print(
          'AuthService: Login failed with status ${response.statusCode}: ${response.statusMessage}',
        );
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('AuthService: DioException: ${e.message}');
      print('AuthService: DioException type: ${e.type}');
      print('AuthService: DioException response: ${e.response}');
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      print('AuthService: Unexpected error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
