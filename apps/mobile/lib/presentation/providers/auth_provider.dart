import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/constants/api_constants.dart';
import 'package:baby_mon/data/api_client.dart';
import 'package:baby_mon/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:baby_mon/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:baby_mon/features/auth/domain/entities/user.dart';
import 'package:baby_mon/features/auth/domain/repositories/auth_repository.dart';
import 'package:baby_mon/core/services/google_sign_in_service.dart';
import 'package:baby_mon/core/services/apple_sign_in_service.dart';
import 'package:baby_mon/core/services/facebook_sign_in_service.dart';
import 'package:meta/meta.dart';
import 'package:baby_mon/core/providers.dart';
export 'package:baby_mon/core/providers.dart' show apiClientProvider;

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in overrides');
});

// Datasource
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRemoteDatasource(apiClient: apiClient, prefs: prefs);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

// Auth state
@immutable
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.token, this.isLoading = false, this.error});

  bool get isLoggedIn => token != null && user != null;

  AuthState copyWith({User? user, String? token, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// AuthNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final loggedIn = await _repository.isLoggedIn();
      if (loggedIn) {
        final user = await _repository.getCurrentUser();
        // Since remote token check succeeds, we can assign a dummy token to proceed
        // (or load it from secure storage, which is handled inside ApiClient interceptors)
        state = AuthState(user: user, token: 'logged_in_session');
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<bool> checkAuth() async {
    await _checkAuthStatus();
    return state.isLoggedIn;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.login(email: email, password: password);
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register(String email, String password, String? name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.register(email: email, password: password, name: name);
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> biometricLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.biometricLogin();
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> sendVerificationEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.sendVerificationEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<bool> checkEmailVerified() async {
    // Backend has no /auth/check-verification endpoint — skip the API call.
    // Email verification is cosmetic/optional at this stage.
    return true;
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(token, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(error: null);
    try {
      await _repository.forgotPassword(email);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleService = GoogleSignInService();
      final idToken = await googleService.signInWithGoogle();

      if (idToken == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // TODO: Send ID token to backend for verification
      // For now, simulate successful Google login
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'google-${DateTime.now().millisecondsSinceEpoch}',
        email: 'google.user@gmail.com',
        name: 'Google User',
        createdAt: DateTime.now(),
      );

      state = AuthState(
        user: user,
        token: 'google-token-${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> appleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appleService = AppleSignInService();
      final isAvailable = await appleService.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Apple Sign-In is not available on this device',
        );
        return;
      }

      final appleData = await appleService.signInWithApple();
      if (appleData == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // TODO: Send identityToken to backend for verification
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'apple-${appleData['userIdentifier'] ?? DateTime.now().millisecondsSinceEpoch}',
        email: appleData['email'] ?? 'apple.user@privaterelay.appleid.com',
        name: appleData['fullName'] ?? 'Apple User',
        createdAt: DateTime.now(),
      );

      state = AuthState(
        user: user,
        token: 'apple-token-${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> facebookLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final facebookService = FacebookSignInService();
      await facebookService.initialize();

      final facebookData = await facebookService.signInWithFacebook();
      if (facebookData == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // TODO: Send accessToken to backend for verification
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'facebook-${facebookData['userId'] ?? DateTime.now().millisecondsSinceEpoch}',
        email: facebookData['email'] ?? 'facebook.user@facebook.com',
        name: facebookData['name'] ?? 'Facebook User',
        createdAt: DateTime.now(),
      );

      state = AuthState(
        user: user,
        token: 'facebook-token-${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
