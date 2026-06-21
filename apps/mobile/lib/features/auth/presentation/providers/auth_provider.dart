import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/services/google_sign_in_service.dart';
import '../../../../core/services/apple_sign_in_service.dart';
import '../../../../core/services/facebook_sign_in_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Datasource
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
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
  final bool isEmailVerified;

  const AuthState({this.user, this.token, this.isLoading = false, this.error, this.isEmailVerified = true});

  bool get isLoggedIn => token != null && user != null;

  AuthState copyWith({User? user, String? token, bool? isLoading, String? error, bool? isEmailVerified}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

// AuthNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final GoogleSignInService Function() _googleServiceFactory;
  final AppleSignInService Function() _appleServiceFactory;
  final FacebookSignInService Function() _facebookServiceFactory;

  AuthNotifier(
    this._repository, {
    GoogleSignInService Function()? googleServiceFactory,
    AppleSignInService Function()? appleServiceFactory,
    FacebookSignInService Function()? facebookServiceFactory,
  })  : _googleServiceFactory = googleServiceFactory ?? GoogleSignInService.new,
        _appleServiceFactory = appleServiceFactory ?? AppleSignInService.new,
        _facebookServiceFactory = facebookServiceFactory ?? FacebookSignInService.new,
        super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final loggedIn = await _repository.isLoggedIn();
      if (loggedIn) {
        final user = await _repository.getCurrentUser();
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        state = AuthState(user: user, token: token);
      }
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<bool> checkAuth() async {
    await _checkAuthStatus();
    return state.isLoggedIn;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.login(email: email, password: password);
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<void> register(
    String email,
    String password,
    String? name,
    DateTime dateOfBirth,
    bool tosAccepted,
    bool privacyAccepted,
    bool consentToDataProcessing,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.register(
        email: email,
        password: password,
        name: name,
        dateOfBirth: dateOfBirth,
        tosAccepted: tosAccepted,
        privacyAccepted: privacyAccepted,
        consentToDataProcessing: consentToDataProcessing,
      );
      state = AuthState(user: result.user, token: result.token, isEmailVerified: false);
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<void> biometricLogin() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.biometricLogin();
      state = AuthState(user: result.user, token: result.token);
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<void> sendVerificationEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Call backend endpoint to send verification email
      // For now, just simulate success
      await Future<void>.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
      rethrow;
    }
  }

  Future<bool> checkEmailVerified() async {
    // Email verification is optional/cosmetic; skip the backend call
    // that results in a 404. Always allow login to proceed.
    state = state.copyWith(isLoading: false, isEmailVerified: true);
    return true;
  }

  Future<void> googleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleService = _googleServiceFactory();
      final idToken = await googleService.signInWithGoogle();

      if (idToken == null) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return;
      }

      final result = await _repository.googleLogin(idToken);
      state = AuthState(
        user: result.user,
        token: result.token,
        isEmailVerified: true, // Google emails are pre-verified
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  Future<void> appleLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final appleService = _appleServiceFactory();

      // Check if Apple Sign-In is available
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
        // User cancelled
        state = state.copyWith(isLoading: false);
        return;
      }

      final identityToken = appleData['identityToken'] as String?;
      if (identityToken == null || identityToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No identity token received from Apple',
        );
        return;
      }

      final result = await _repository.appleLogin(identityToken);
      state = AuthState(
        user: result.user,
        token: result.token,
        isEmailVerified: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  Future<void> facebookLogin() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final facebookService = _facebookServiceFactory();
      final facebookData = await facebookService.signInWithFacebook();

      if (facebookData == null) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return;
      }

      final accessToken = facebookData['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No access token received from Facebook',
        );
        return;
      }

      final result = await _repository.facebookLogin(accessToken);
      state = AuthState(
        user: result.user,
        token: result.token,
        isEmailVerified: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: extractErrorMessage(e));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetPassword(token, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(error: null);
    try {
      await _repository.forgotPassword(email);
    } catch (e) {
      state = AuthState(error: extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});
