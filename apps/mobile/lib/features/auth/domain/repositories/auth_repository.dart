import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User user, String token})> login({required String email, required String password});
  Future<({User user, String token})> register({required String email, required String password, String? name});
  Future<({User user, String token})> biometricLogin();
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> sendVerificationEmail(String email);
  Future<bool> checkEmailVerified();
  Future<void> resetPassword(String token, String newPassword);
  Future<bool> isLoggedIn();
}