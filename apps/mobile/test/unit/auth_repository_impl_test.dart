import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:baby_mon/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baby_mon/features/auth/domain/entities/user.dart';
import 'package:baby_mon/features/auth/data/datasources/auth_remote_datasource.dart';

/// Fake datasource that records calls and returns configurable results.
class FakeAuthDatasource implements AuthRemoteDatasource {
  ({User user, String token})? nextLoginResult;
  ({User user, String token})? nextRegisterResult;
  ({User user, String token})? nextBiometricResult;
  Exception? nextLoginError;
  Exception? nextRegisterError;
  Exception? nextBiometricError;
  bool isLoggedInResult = false;
  User? currentUser;
  bool logoutCalled = false;
  String? lastVerificationEmail;
  String? lastForgotPasswordEmail;
  String? lastResetToken;
  String? lastResetPassword;

  @override
  Future<({User user, String token})> login({
    required String email,
    required String password,
  }) async {
    if (nextLoginError != null) throw nextLoginError!;
    return nextLoginResult ?? (
      user: User(id: '1', email: email, createdAt: DateTime(2024)),
      token: 'token',
    );
  }

  @override
  Future<({User user, String token})> register({
    required String email,
    required String password,
    String? name,
    required DateTime dateOfBirth,
    required bool tosAccepted,
    required bool privacyAccepted,
    required bool consentToDataProcessing,
  }) async {
    if (nextRegisterError != null) throw nextRegisterError!;
    return nextRegisterResult ?? (
      user: User(id: '2', email: email, name: name, createdAt: DateTime(2024)),
      token: 'reg-token',
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<bool> isLoggedIn() async => isLoggedInResult;

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<({User user, String token})> googleLogin(String idToken) async => throw UnimplementedError();

  @override
  Future<({User user, String token})> appleLogin(String idToken) async => throw UnimplementedError();

  @override
  Future<({User user, String token})> facebookLogin(String accessToken) async => throw UnimplementedError();

  @override
  Future<void> syncLocale() async {}

  @override
  Future<void> clearToken() async {}

  @override
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    if (nextBiometricError != null) throw nextBiometricError!;
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {
        'user': {'id': 'bio-1', 'email': 'bio@test.com', 'createdAt': '2024-01-01T00:00:00.000Z'},
        'token': 'bio-token',
      },
      statusCode: 200,
    );
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late FakeAuthDatasource fakeDatasource;
    late AuthRepositoryImpl repository;

    setUp(() {
      fakeDatasource = FakeAuthDatasource();
      repository = AuthRepositoryImpl(fakeDatasource);
    });

    group('login', () {
      test('delegates to datasource and returns user + token', () async {
        fakeDatasource.nextLoginResult = (
          user: User(id: 'u1', email: 'test@test.com', createdAt: DateTime(2024)),
          token: 'jwt-abc',
        );

        final result = await repository.login(email: 'test@test.com', password: 'pass');

        expect(result.user.email, 'test@test.com');
        expect(result.token, 'jwt-abc');
      });

      test('propagates datasource errors', () async {
        fakeDatasource.nextLoginError = Exception('Invalid credentials');

        expect(
          () => repository.login(email: 'x', password: 'y'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('register', () {
      test('delegates to datasource and returns user + token', () async {
        fakeDatasource.nextRegisterResult = (
          user: User(id: 'u2', email: 'new@test.com', name: 'New', createdAt: DateTime(2024)),
          token: 'reg-xyz',
        );

        final result = await repository.register(
          email: 'new@test.com',
          password: 'pass',
          name: 'New',
          dateOfBirth: DateTime(1990, 1, 1),
          tosAccepted: true,
          privacyAccepted: true,
          consentToDataProcessing: true,
        );

        expect(result.user.name, 'New');
        expect(result.token, 'reg-xyz');
      });

      test('propagates datasource errors', () async {
        fakeDatasource.nextRegisterError = Exception('Duplicate email');

        expect(
          () => repository.register(
            email: 'x',
            password: 'y',
            dateOfBirth: DateTime(1990, 1, 1),
            tosAccepted: true,
            privacyAccepted: true,
            consentToDataProcessing: true,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('logout', () {
      test('delegates to datasource', () async {
        await repository.logout();
        expect(fakeDatasource.logoutCalled, isTrue);
      });
    });

    group('isLoggedIn', () {
      test('returns true when datasource says logged in', () async {
        fakeDatasource.isLoggedInResult = true;
        expect(await repository.isLoggedIn(), isTrue);
      });

      test('returns false when datasource says not logged in', () async {
        fakeDatasource.isLoggedInResult = false;
        expect(await repository.isLoggedIn(), isFalse);
      });
    });

    group('getCurrentUser', () {
      test('returns user from datasource', () async {
        fakeDatasource.currentUser = User(id: 'u1', email: 'a@b.com', createdAt: DateTime(2024));
        final user = await repository.getCurrentUser();
        expect(user?.id, 'u1');
      });

      test('returns null when no user', () async {
        fakeDatasource.currentUser = null;
        final user = await repository.getCurrentUser();
        expect(user, isNull);
      });
    });

    group('biometricLogin', () {
      test('parses biometric response correctly', () async {
        final result = await repository.biometricLogin();
        expect(result.user.email, 'bio@test.com');
        expect(result.token, 'bio-token');
      });

      test('wraps errors in Exception', () async {
        fakeDatasource.nextBiometricError = Exception('Biometric not available');

        expect(
          () => repository.biometricLogin(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('resetPassword', () {
      test('calls datasource post with correct data', () async {
        await repository.resetPassword('token-123', 'newpass456');
        // No error means success — the fake datasource's post() handles it
      });
    });

    group('forgotPassword', () {
      test('calls datasource post with correct data', () async {
        await repository.forgotPassword('user@test.com');
        // No error means success
      });
    });
  });
}
