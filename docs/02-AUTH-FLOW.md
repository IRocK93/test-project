# BabyMon — Complete Authentication Flow

> **Last updated:** June 4, 2026 (v3.0)  
> **State management:** Riverpod (`StateNotifierProvider`)  
> **HTTP layer:** Dio with `ApiClient` wrapper (refresh-gated interceptor for serialized token refresh)  
>
> ⚠️ **⚠️ CRITICAL: Two auth_provider.dart Files** The project has TWO files:
> - `lib/presentation/providers/auth_provider.dart` — **ACTIVE** (imported by all screens)
> - `lib/features/auth/presentation/providers/auth_provider.dart` — **DEAD CODE**
> Fixes applied to the dead-code file have ZERO effect. Always verify which file is imported.

---

## 1. Login Flow

```
LoginScreen._login()
  → authProvider.notifier.login(email, password)              [auth_provider.dart:85]
    → _repository.login(email, password)                       [auth_repository_impl.dart:11]
      → _datasource.login(email, password)                    [auth_remote_datasource.dart:15]
        → _apiClient.post('/api/auth/login', data)            → HTTP POST to backend
        ← 200: {user, accessToken, refreshToken}
        → _prefs.setString('accessToken', token)              [SharedPreferences]
         → _apiClient.saveTokens(token, refreshToken, user.id)  [FlutterSecureStorage]
  ← AuthState(user, token)
→ if user != null: checkEmailVerified() → /home or /verify-email
```

**Key files:** `login_screen.dart` → `auth_provider.dart` → `auth_repository_impl.dart` → `auth_remote_datasource.dart` → `api_client.dart`

---

## 2. Register Flow

```
RegisterScreen._register()
  → authProvider.notifier.register(email, password, name)     [auth_provider.dart:95]
    → _repository.register(email, password, name)              [auth_repository_impl.dart:16]
      → _datasource.register(email, password, name)           [auth_remote_datasource.dart:42]
        → _apiClient.post('/api/auth/register', data)         → HTTP POST to backend
        ← 201: {user, accessToken}
        → _prefs.setString('accessToken', token)              [SharedPreferences]
        → _apiClient.saveTokens(token, '', user.id)           [FlutterSecureStorage]
  ← AuthState(user, token)
→ if user != null: navigate to /verify-email
```

---

## 3. Email Verification Flow

```
After Register: /verify-email?email=...                       [app_router.dart]
After Login: checkEmailVerified() → verified? /home : /verify-email

VerificationScreen._checkVerification()
  → authProvider.notifier.checkEmailVerified()                [auth_provider.dart:138]
    → _repository.checkEmailVerified()                        [auth_repository_impl.dart:46]
      → _datasource.post('/api/auth/check-verification')      [auth_remote_datasource.dart]
        → returns {verified: bool}
← if verified → context.go('/home')

VerificationScreen._resendVerification()
  → authProvider.notifier.sendVerificationEmail(email)        [auth_provider.dart:128]
    → _repository.sendVerificationEmail(email)                [auth_repository_impl.dart:37]
      → _datasource.post('/api/auth/send-verification-email') [auth_remote_datasource.dart]
```

---

## 4. Password Reset Flow

```
LoginScreen "Forgot Password?" → _showForgotPasswordSheet()
  → apiClientProvider.post('/api/auth/forgot-password', {email})  [login_screen.dart:234]
  ← success: "Password reset link sent to your email"

ResetPasswordScreen (opens from emailed link /reset-password?token=xxx)
  _resetPassword()
  → authProvider.notifier.resetPassword(token, newPassword)  [auth_provider.dart:145]
    → _repository.resetPassword(token, newPassword)           [auth_repository_impl.dart:53]
      → _datasource.post('/api/auth/reset-password', {token, newPassword})
  ← success: navigate to /login
```

---

## 5. Token Storage — Two Backends

| Storage | Used By | Key | Written During |
|---------|---------|-----|---------------|
| **SharedPreferences** (`_prefs`) | `AuthRemoteDatasource` | `accessToken`, `userId`, `userEmail` | `login()`, `register()` |
| **FlutterSecureStorage** (`_storage`) | `ApiClient` Dio Interceptor | `access_token` | `_apiClient.saveTokens()` |

**Critical:** Both must be written on login/register. If only SharedPreferences is written, the Dio interceptor finds no token and 401s all requests.

---

## 6. Dio Interceptor — Auth Header Injection

**File:** `lib/data/api_client.dart` — `InterceptorsWrapper`

```dart
onRequest: (options, handler) async {
  final token = await _storage.read(key: StorageKeys.accessToken);
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}
```

Reads from `FlutterSecureStorage` key `access_token`. Skipped for `/auth/login`, `/auth/register`, `/auth/refresh`.

---

## 7. OAuth Files Map

| Provider | Service File | Package | Returns |
|----------|-------------|---------|---------|
| Google | `core/services/google_sign_in_service.dart` | `google_sign_in` | ID token |
| Apple | `core/services/apple_sign_in_service.dart` | `sign_in_with_apple` | identity token |
| Facebook | `core/services/facebook_sign_in_service.dart` | `flutter_facebook_auth` | access token |

**WARNING:** These are in `core/services/` — NOT in `features/auth/services/`.

---

## 8. Biometric Login Flow

**Opt-in on first use:**
```
LoginScreen._checkBiometrics() → LocalAuthentication().canCheckBiometrics
                                → SharedPreferences 'biometrics_enabled'
if available && optedIn → show "Sign in with Biometrics" button

_biometricLogin()
  → _localAuth.authenticate(localizedReason: '...')
  if first time: show dialog "Enable biometric login?" → save preference
  → authProvider.notifier.biometricLogin()             [auth_provider.dart:105]
    → _repository.biometricLogin()                     [auth_repository_impl.dart:22]
      → _datasource.post('/api/auth/biometric-verify') [auth_remote_datasource.dart]
  ← if user != null → /home
```

---

## 9. Provider Dependency Graph

```
authProvider (StateNotifierProvider<AuthNotifier, AuthState>)
  ├── authRepositoryProvider (Provider<AuthRepository>)
  │     └── authRemoteDatasourceProvider (Provider<AuthRemoteDatasource>)
  │           ├── apiClientProvider (Provider<ApiClient>)  ← SINGLE source
  │           └── sharedPreferencesProvider
  └── apiClientProvider (Provider<ApiClient>)              ← SAME single source

IMPORTANT: apiClientProvider is defined ONLY in:
  presentation/providers/auth_provider.dart (line 15)
NOT in core/providers.dart (that file is DEPRECATED for this provider)