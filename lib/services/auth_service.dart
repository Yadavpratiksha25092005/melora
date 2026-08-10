import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:Melora/core/constants/app_constants.dart';
import 'package:Melora/core/network/api_client.dart';
import 'package:Melora/core/network/api_endpoints.dart';
import 'package:Melora/core/network/api_exceptions.dart';
import 'package:Melora/core/network/dummy_data_source.dart';
import 'package:Melora/models/user.dart';

class AuthService {
  final ApiClient _client = ApiClient();
  final _storage = const FlutterSecureStorage();

  static const String _mockOtp = '123456';

  Future<User> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final userJson = await DummyDataSource.user();
      final newUser = {...userJson, 'email': email, 'username': username};
      await _storage.write(key: AppConstants.tokenKey, value: 'dummy_token');
      return User.fromJson(newUser);
    }

    final result = await _client.request<Map<String, dynamic>>(
      () => _client.dio.post(
        ApiEndpoints.signup,
        data: {'email': email, 'username': username, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );
    final token = result['token'] as String?;
    if (token != null) {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    }
    return User.fromJson(result['user']);
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  Future<void> sendOtp({required String phone}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      return;
    }
    await _client.request(
      () => _client.dio.post(
        '${ApiEndpoints.login}/otp/send',
        data: {'phone': phone},
      ),
      (_) {},
    );
  }

  Future<User> verifyOtp({required String phone, required String otp}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      if (otp != _mockOtp) {
        throw ApiException(
          code: 'INVALID_OTP',
          message: 'Incorrect OTP. Try $_mockOtp for this demo.',
        );
      }
      final userJson = await DummyDataSource.user();
      final newUser = {...userJson, 'phone': phone};
      await _storage.write(key: AppConstants.tokenKey, value: 'dummy_token');
      return User.fromJson(newUser);
    }

    final result = await _client.request<Map<String, dynamic>>(
      () => _client.dio.post(
        '${ApiEndpoints.login}/otp/verify',
        data: {'phone': phone, 'otp': otp},
      ),
      (data) => data as Map<String, dynamic>,
    );
    final token = result['token'] as String?;
    if (token != null) {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    }
    return User.fromJson(result['user']);
  }

  /// PUT /users/profile — backend only accepts/stores `name` and
  /// `avatar_url` (see internal/user/dto.go: UpdateProfileRequest), and
  /// returns {id, name, phone_number, avatar_url} (no email field, since
  /// this backend's user model is phone/OTP-based).
<<<<<<< HEAD
=======
  /// PUT /auth/profile/name — this backend only supports updating the
  /// name via the auth module (see internal/auth: UpdateNameRequest /
  /// UpdateName handler). Avatar isn't supported by the backend yet, so
  /// avatarUrl is accepted here but not sent.
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
  Future<User> updateProfile({String? username, String? avatarUrl}) async {
    if (AppConstants.useDummyData) {
      await DummyDataSource.simulateDelay();
      final userJson = await DummyDataSource.user();
      final updated = {
        ...userJson,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      return User.fromJson(updated);
    }

<<<<<<< HEAD
    final result = await _client.request<Map<String, dynamic>>(
      () => _client.dio.put(
        ApiEndpoints.userProfile,
        data: {
          'name': username ?? '',
          'avatar_url': avatarUrl ?? '',
=======
 final result = await _client.request<Map<String, dynamic>>(
      () => _client.dio.put(
        ApiEndpoints.updateName,
        data: {
          'name': username ?? '',
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
        },
      ),
      (data) => data as Map<String, dynamic>,
    );
    return User(
      id: result['id'] as String,
      email: '',
      username: result['name'] as String? ?? username ?? '',
<<<<<<< HEAD
      avatarUrl: result['avatar_url'] as String?,
=======
      avatarUrl: avatarUrl,
>>>>>>> 3cb5a6ec211f46c4bc31b1cbd4ba22d147c15624
      phone: result['phone_number'] as String?,
    );
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      return token != null;
    } catch (e) {
      // The Android Keystore key used to encrypt secure-storage values can
      // become invalid (e.g. after a rebuild/reinstall leaves stale
      // encrypted data behind, or a device backup/restore), which makes
      // flutter_secure_storage throw a PlatformException/BadPaddingException
      // on read instead of returning null. Treat that as "not logged in"
      // and wipe the unreadable data so it doesn't keep failing on every
      // future launch.
      await _storage.deleteAll();
      return false;
    }
  }
}