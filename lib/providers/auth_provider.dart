import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/models/user.dart';
import 'package:Melora/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool otpSent;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.otpSent = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? otpSent,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());
  final AuthRepository _repo;
  bool _busy = false;   // ← YE LINE ADD KARO


  Future<bool> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.signup(email: email, username: username, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
      return false;
    }
  }

  Future<bool> sendOtp({required String phone}) async {
    state = state.copyWith(isLoading: true, clearError: true, otpSent: false);
    try {
      await _repo.sendOtp(phone: phone);
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
      return false;
    }
  }
Future<bool> verifyOtp({required String phone, required String otp}) async {
  if (_busy) return false;
  _busy = true;
  state = state.copyWith(isLoading: true, clearError: true);
  try {
    final user = await _repo.verifyOtp(phone: phone, otp: otp);
    state = state.copyWith(user: user, isLoading: false);
    return true;
  } on ApiException catch (e) {
    state = state.copyWith(isLoading: false, error: e.message);
    return false;
  } catch (e) {
    state = state.copyWith(isLoading: false, error: 'Something went wrong');
    return false;
  } finally {
    _busy = false;
  }
}

  void resetOtpFlow() {
    state = state.copyWith(otpSent: false, clearError: true);
  }

  /// Updates the signed-in user's profile via the backend
  /// (PUT /users/profile — see internal/user in the Go backend).
  Future<bool> updateProfile({String? username, String? avatarUrl}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repo.updateProfile(username: username, avatarUrl: avatarUrl);
      state = state.copyWith(user: updated, isLoading: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});