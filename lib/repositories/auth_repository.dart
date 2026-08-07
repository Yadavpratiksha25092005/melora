import 'package:Melora/models/user.dart';
import 'package:Melora/services/auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository({AuthService? service}) : _service = service ?? AuthService();

  Future<User> signup({
    required String email,
    required String username,
    required String password,
  }) =>
      _service.signup(email: email, username: username, password: password);

  Future<void> logout() => _service.logout();

  Future<void> sendOtp({required String phone}) => _service.sendOtp(phone: phone);

  Future<User> verifyOtp({required String phone, required String otp}) =>
      _service.verifyOtp(phone: phone, otp: otp);

  Future<User> updateProfile({String? username, String? avatarUrl}) =>
      _service.updateProfile(username: username, avatarUrl: avatarUrl);

  Future<bool> isLoggedIn() => _service.isLoggedIn();
}