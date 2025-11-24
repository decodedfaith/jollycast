import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, User?>(() {
  return AuthViewModel();
});

class AuthViewModel extends AsyncNotifier<User?> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<User?> build() async {
    _authRepository = ref.read(authRepositoryProvider);
    return _checkLoginStatus();
  }

  Future<User?> _checkLoginStatus() async {
    try {
      return await _authRepository.getUser();
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _authRepository.login(phone, password);
    });
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }
}
