/// Auth Feature Barrel
///
/// Import all auth-related symbols from a single location:
/// ```dart
/// import 'package:baby_mon/features/auth/auth.dart';
/// ```
library;

// ── Domain ──
export 'domain/entities/user.dart' show User;
export 'domain/repositories/auth_repository.dart' show AuthRepository;

// ── Data ──
export 'data/datasources/auth_remote_datasource.dart' show AuthRemoteDatasource;
export 'data/repositories/auth_repository_impl.dart' show AuthRepositoryImpl;

// ── Presentation: Providers ──
export 'presentation/providers/auth_provider.dart' show authProvider, AuthState, AuthNotifier, isLoggedInProvider, authRemoteDatasourceProvider, authRepositoryProvider;

// ── Presentation: Widgets ──
export 'presentation/widgets/auth_text_field.dart' show AuthTextField;

// ── Presentation: Screens ──
export 'presentation/screens/login_screen.dart' show LoginScreen;
export 'presentation/screens/register_screen.dart' show RegisterScreen;
export 'presentation/screens/verification_screen.dart' show VerificationScreen;
export 'presentation/screens/reset_password_screen.dart' show ResetPasswordScreen;
