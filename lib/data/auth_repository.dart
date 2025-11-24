import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService);
});

class AuthRepository {
  final AuthService _authService;
  static const String _userKey = 'user_data';

  AuthRepository(this._authService);

  Future<User> login(String phone, String password) async {
    final user = await _authService.login(phone, password);
    await _saveUser(user);
    return user;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final user = User.fromJson(jsonDecode(userStr));
        if (user.token.isEmpty) {
          print(
            'AuthRepository: Found user but token is empty. Clearing data.',
          );
          await prefs.remove(_userKey);
          return null;
        }
        return user;
      } catch (e) {
        print('AuthRepository: Error parsing user data: $e');
        await prefs.remove(_userKey);
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
