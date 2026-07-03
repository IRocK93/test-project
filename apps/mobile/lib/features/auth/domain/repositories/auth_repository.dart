import '../entities/user.dart';

abstract class AuthRepository {
  Future<({User user, String token})> login({required String email, required String password});
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
    required DateTime dateOfBirth,
    required bool tosAccepted,
    required bool privacyAccepted,
    required bool consentToDataProcessing,
  });
  Future<({User user, String token})> biometricLogin();
  Future<void> forgotPassword(String email);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> sendVerificationEmail();
  Future<bool> checkEmailVerified();
  Future<void> resetPassword(String token, String newPassword);
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
  Future<({User user, String token})> googleLogin(String idToken) => throw UnimplementedError('googleLogin not implemented');
  Future<({User user, String token})> appleLogin(String idToken) => throw UnimplementedError('appleLogin not implemented');
  Future<({User user, String token})> facebookLogin(String accessToken) => throw UnimplementedError('facebookLogin not implemented');

  /// Syncs the locally-saved locale preference to the backend.
  /// Failures are silently ignored — this is a non-critical fire-and-forget operation.
  Future<void> syncLocale();
}
