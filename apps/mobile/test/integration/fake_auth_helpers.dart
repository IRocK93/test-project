import 'package:baby_mon/features/auth/domain/entities/user.dart';
import 'package:baby_mon/features/auth/domain/repositories/auth_repository.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
//  Shared Fake Auth helpers — avoids SharedPreferences dependency chain
//
//  Any screen test that renders a ConsumerWidget reading authProvider
//  should override authProvider with FakeAuthNotifier to avoid the
//  SharedPreferences → authRemoteDatasourceProvider → authRepositoryProvider
//  dependency chain that crashes in tests.
//
//  Usage:
//    ProviderScope(
//      overrides: [
//        authProvider.overrideWith((ref) => FakeAuthNotifier()),
//      ],
//      child: ...,
//    )
// ═══════════════════════════════════════════════════════════════

/// Minimal [AuthRepository] stub that satisfies the abstract interface.
///
/// All mutating methods throw [UnimplementedError] — override as needed.
/// [isLoggedIn] always returns `false` (required by [FakeAuthNotifier] contract).
class StubAuthRepo implements AuthRepository {
  @override
  Future<bool> isLoggedIn() async => false;
  @override
  Future<User?> getCurrentUser() async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();
  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
  }) async =>
      throw UnimplementedError();
  @override
  Future<({User user, String token})> biometricLogin() async =>
      throw UnimplementedError();
  @override
  Future<void> forgotPassword(String email) async {}
  @override
  Future<void> resetPassword(String token, String newPassword) async {}
  @override
  Future<void> sendVerificationEmail(String email) async {}
  @override
  Future<bool> checkEmailVerified() async => true;
}

/// Fake [AuthNotifier] that bypasses the real constructor's `_checkAuthStatus`.
///
/// **Contract:** [StubAuthRepo] must always return `false` from [isLoggedIn]
/// so that the parent constructor's fire-and-forget `_checkAuthStatus` never
/// tries to read SharedPreferences.
///
/// Also overrides [checkAuth] to always return `false`, which is the safe
/// default for smoke/rendering tests where you don't want navigation side effects.
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(StubAuthRepo());

  @override
  Future<bool> checkAuth() async => false;
}
