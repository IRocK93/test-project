import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<({User user, String token})> login({required String email, required String password}) async {
    return await _datasource.login(email: email, password: password);
  }

  @override
  Future<({User user, String token})> register({required String email, required String password, String? name}) async {
    return await _datasource.register(email: email, password: password, name: name);
  }

  @override
  Future<({User user, String token})> biometricLogin() async {
    try {
      final response = await _datasource.post('/api/auth/biometric-verify');
      final data = response.data as Map<String, dynamic>;
      return (
        user: User.fromJson(data['user']),
        token: data['token'] as String,
      );
    } catch (e) {
      throw Exception('Biometric login failed: $e');
    }
  }

  @override
  Future<void> sendVerificationEmail(String email) async {
    try {
      await _datasource.post('/api/auth/send-verification-email', data: {'email': email});
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      final response = await _datasource.post('/api/auth/check-verification');
      return response.data['verified'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _datasource.post('/api/auth/reset-password', data: {'token': token, 'newPassword': newPassword});
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _datasource.post('/api/auth/forgot-password', data: {'email': email});
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _datasource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _datasource.getCurrentUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _datasource.isLoggedIn();
  }
}