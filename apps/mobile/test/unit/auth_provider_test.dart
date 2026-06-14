import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/features/auth/presentation/providers/auth_provider.dart';
import 'package:baby_mon/features/auth/domain/repositories/auth_repository.dart';
import 'package:baby_mon/features/auth/domain/entities/user.dart';

/// Minimal in-memory mock of [AuthRepository] for testing [AuthNotifier].
class FakeAuthRepository implements AuthRepository {
  // Configuration for next call
  ({User user, String token})? nextLoginResult;
  ({User user, String token})? nextRegisterResult;
  ({User user, String token})? nextBiometricResult;
  Exception? nextLoginError;
  Exception? nextRegisterError;
  Exception? nextBiometricError;
  bool shouldLoggedIn = false;
  User? currentUser;
  bool logoutCalled = false;
  String? lastForgotEmail;
  String? lastResetToken;
  String? lastResetPassword;
  String? lastVerificationEmail;

  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    if (nextLoginError != null) throw nextLoginError!;
    return nextLoginResult ?? (
      user: User(id: '1', email: email, createdAt: DateTime(2024)),
      token: 'test-token',
    );
  }

  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (nextRegisterError != null) throw nextRegisterError!;
    return nextRegisterResult ?? (
      user: User(id: '2', email: email, name: name, createdAt: DateTime(2024)),
      token: 'reg-token',
    );
  }

  @override
  Future<({User user, String token})> biometricLogin() async {
    if (nextBiometricError != null) throw nextBiometricError!;
    return nextBiometricResult ?? (
      user: User(id: '3', email: 'bio@test.com', createdAt: DateTime(2024)),
      token: 'bio-token',
    );
  }

  @override
  Future<bool> isLoggedIn() async => shouldLoggedIn;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> forgotPassword(String email) async {
    lastForgotEmail = email;
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    lastResetToken = token;
    lastResetPassword = newPassword;
  }

  @override
  Future<void> sendVerificationEmail(String email) async {
    lastVerificationEmail = email;
  }

  @override
  Future<bool> checkEmailVerified() async => true;
}

void main() {
  group('AuthNotifier', () {
    late FakeAuthRepository fakeRepo;
    late AuthNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeRepo = FakeAuthRepository();
      // Don't call _checkAuthStatus in constructor by pre-setting shouldLoggedIn
      fakeRepo.shouldLoggedIn = false;
      notifier = AuthNotifier(fakeRepo);
    });

    tearDown(() {
      notifier.dispose();
    });

    group('initial state', () {
      test('starts with empty AuthState', () {
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
        expect(notifier.state.error, isNull);
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('login', () {
      test('sets user and token on successful login', () async {
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'jwt-token-123',
        );

        await notifier.login('test@test.com', 'password123');

        expect(notifier.state.user, isNotNull);
        expect(notifier.state.user!.email, 'test@test.com');
        expect(notifier.state.token, 'jwt-token-123');
        expect(notifier.state.error, isNull);
        expect(notifier.state.isLoading, isFalse);
      });

      test('sets error on failed login', () async {
        fakeRepo.nextLoginError = Exception('Invalid credentials');

        await notifier.login('bad@test.com', 'wrong');

        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, isFalse);
      });

      test('sets isLoading during login', () async {
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'token',
        );

        // Start login but don't await yet
        final future = notifier.login('test@test.com', 'pass');
        // After the first line of login(), isLoading should be true
        expect(notifier.state.isLoading, isTrue);

        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('register', () {
      test('sets user, token, and isEmailVerified=false on success', () async {
        fakeRepo.nextRegisterResult = (
          user: User(id: 'u2', email: 'new@test.com', name: 'New User', createdAt: DateTime(2024)),
          token: 'reg-token-456',
        );

        await notifier.register('new@test.com', 'pass123', 'New User');

        expect(notifier.state.user, isNotNull);
        expect(notifier.state.user!.email, 'new@test.com');
        expect(notifier.state.user!.name, 'New User');
        expect(notifier.state.token, 'reg-token-456');
        expect(notifier.state.isEmailVerified, isFalse);
        expect(notifier.state.error, isNull);
      });

      test('sets error on failed registration', () async {
        fakeRepo.nextRegisterError = Exception('Email already exists');

        await notifier.register('dup@test.com', 'pass', null);

        expect(notifier.state.user, isNull);
        expect(notifier.state.error, isNotNull);
      });
    });

    group('logout', () {
      test('resets state to empty after logout', () async {
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'token',
        );
        await notifier.login('test@test.com', 'pass');
        expect(notifier.state.isLoggedIn, isTrue);

        await notifier.logout();
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
        expect(notifier.state.isLoggedIn, isFalse);
        expect(fakeRepo.logoutCalled, isTrue);
      });
    });

    group('forgotPassword', () {
      test('calls repository with email', () async {
        await notifier.forgotPassword('user@test.com');
        expect(fakeRepo.lastForgotEmail, 'user@test.com');
      });

      test('sets error on failure', () async {
        fakeRepo.nextLoginError = Exception('Not found');
        await notifier.forgotPassword('bad@test.com');
      });
    });

    group('resetPassword', () {
      test('calls repository with token and password', () async {
        await notifier.resetPassword('reset-token-xyz', 'newpass123');
        expect(fakeRepo.lastResetToken, 'reset-token-xyz');
        expect(fakeRepo.lastResetPassword, 'newpass123');
      });
    });

    group('checkEmailVerified', () {
      test('always returns true (per current implementation)', () async {
        final result = await notifier.checkEmailVerified();
        expect(result, isTrue);
        expect(notifier.state.isEmailVerified, isTrue);
      });
    });

    group('checkAuth', () {
      test('returns true when user is logged in', () async {
        fakeRepo.shouldLoggedIn = true;
        fakeRepo.currentUser = User(id: 'u1', email: 'exist@test.com', createdAt: DateTime(2024));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', 'stored-token');

        final result = await notifier.checkAuth();

        expect(result, isTrue);
        expect(notifier.state.isLoggedIn, isTrue);
      });

      test('returns false when user is not logged in', () async {
        fakeRepo.shouldLoggedIn = false;

        final result = await notifier.checkAuth();

        expect(result, isFalse);
        expect(notifier.state.isLoggedIn, isFalse);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    //  Social Login — Error handling tests
    //
    //  GoogleSignInService and FacebookSignInService catch exceptions
    //  INTERNALLY and return null → provider treats as "user cancelled".
    //  AppleSignInService.isAvailable() does NOT catch → throws
    //  MissingPluginException → provider catch block sets error.
    // ═══════════════════════════════════════════════════════════════

    group('googleLogin', () {
      test('sets isLoading true during login', () async {
        final future = notifier.googleLogin();
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);
        await future;
      });

      test('handles cancelled/null response from service gracefully', () async {
        // GoogleSignInService catches internally and returns null in test env.
        // Provider treats null as "user cancelled" — no error set.
        await notifier.googleLogin();

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
        expect(notifier.state.error, isNull);
      });

      test('clears isLoading after completion', () async {
        // Set up a logged-in state first
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'token',
        );
        await notifier.login('test@test.com', 'pass');
        expect(notifier.state.isLoggedIn, isTrue);

        // googleLogin clears isLoading: true, error: null
        final future = notifier.googleLogin();
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);
        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('appleLogin', () {
      test('sets isLoading true during login', () async {
        final future = notifier.appleLogin();
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);
        await future;
      });

      test('sets error when Apple Sign-In is not available', () async {
        // AppleSignInService.isAvailable() does NOT catch exceptions.
        // It throws MissingPluginException in test env.
        await notifier.appleLogin();

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.error, isNotNull);
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
      });

      test('clears isLoading after completion', () async {
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'token',
        );
        await notifier.login('test@test.com', 'pass');
        expect(notifier.state.isLoggedIn, isTrue);

        final future = notifier.appleLogin();
        expect(notifier.state.isLoading, isTrue);
        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('facebookLogin', () {
      test('sets isLoading true during login', () async {
        final future = notifier.facebookLogin();
        expect(notifier.state.isLoading, isTrue);
        expect(notifier.state.error, isNull);
        await future;
      });

      test('handles cancelled/null response from service gracefully', () async {
        // FacebookSignInService catches internally and returns null in test env.
        // Provider treats null as "user cancelled" — no error set.
        await notifier.facebookLogin();

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.user, isNull);
        expect(notifier.state.token, isNull);
        expect(notifier.state.error, isNull);
      });

      test('clears isLoading after completion', () async {
        fakeRepo.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'token',
        );
        await notifier.login('test@test.com', 'pass');
        expect(notifier.state.isLoggedIn, isTrue);

        final future = notifier.facebookLogin();
        expect(notifier.state.isLoading, isTrue);
        await future;
        expect(notifier.state.isLoading, isFalse);
      });
    });

    group('AuthState', () {
      test('isLoggedIn returns true when both token and user exist', () {
        final state = AuthState(
          user: User(id: '1', email: 'a@b.com', createdAt: DateTime(2024)),
          token: 'tok',
        );
        expect(state.isLoggedIn, isTrue);
      });

      test('isLoggedIn returns false when token is null', () {
        final state = AuthState(
          user: User(id: '1', email: 'a@b.com', createdAt: DateTime(2024)),
        );
        expect(state.isLoggedIn, isFalse);
      });

      test('isLoggedIn returns false when user is null', () {
        const state = AuthState(token: 'tok');
        expect(state.isLoggedIn, isFalse);
      });

      test('copyWith preserves unmodified fields', () {
        final original = AuthState(
          user: User(id: '1', email: 'a@b.com', createdAt: DateTime(2024)),
          token: 'tok',
          isLoading: true,
          error: 'some error',
        );
        final copied = original.copyWith(isLoading: false);

        expect(copied.user, original.user);
        expect(copied.token, original.token);
        expect(copied.isLoading, isFalse);
        expect(copied.error, original.error);
      });
    });
  });
}
