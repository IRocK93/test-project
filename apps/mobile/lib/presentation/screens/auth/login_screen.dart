import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'package:baby_mon/data/api_client.dart';

/// Login screen with email/password auth, OAuth buttons, password visibility toggle,
/// forgot password recovery, and biometric login support.
///
/// ═══════════════════════════════════════════════════════════
///  OAuth FILES REFERENCE
/// ═══════════════════════════════════════════════════════════
///  Auth provider: presentation/providers/auth_provider.dart
///  Google OAuth:  core/services/google_sign_in_service.dart
///  Facebook OAuth: core/services/facebook_sign_in_service.dart
///  Apple OAuth:   core/services/apple_sign_in_service.dart
/// ═══════════════════════════════════════════════════════════
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Whether the password field shows plain text (true = hidden, false = visible)
  bool _obscurePassword = true;

  /// Whether a password reset request is currently in progress
  bool _isResetting = false;

  /// Whether biometric authentication is available on this device
  bool _biometricsAvailable = false;

  /// Whether the user has opted in to biometric login via SharedPreferences
  bool _biometricsOptedIn = false;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks biometric availability and user preference from SharedPreferences
  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final prefs = await SharedPreferences.getInstance();
      final optedIn = prefs.getBool('biometrics_enabled') ?? false;

      if (mounted) {
        setState(() {
          _biometricsAvailable = canCheck && isDeviceSupported;
          _biometricsOptedIn = optedIn;
        });
      }
    } catch (_) {}
  }

  /// Saves biometric preference to SharedPreferences
  Future<void> _saveBiometricPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', enabled);
    setState(() => _biometricsOptedIn = enabled);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
      if (ref.read(authProvider).user != null && mounted) {
        final isVerified = await ref.read(authProvider.notifier).checkEmailVerified();
        if (isVerified && mounted) {
          context.go('/home');
        } else if (mounted) {
          context.go('/verify-email?email=${Uri.encodeComponent(_emailController.text)}');
        }
      }
    }
  }

  /// Initiates biometric authentication (fingerprint / face) for login
  Future<void> _biometricLogin() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to log in to BabyMon',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );

      if (authenticated && mounted) {
        if (!_biometricsOptedIn) {
          final enable = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Enable Biometric Login'),
              content: const Text('Would you like to use biometrics for faster sign-in next time?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not Now')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Enable')),
              ],
            ),
          );
          if (enable == true && mounted) await _saveBiometricPreference(true);
        }

        await ref.read(authProvider.notifier).biometricLogin();
        if (ref.read(authProvider).user != null && mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Biometric login failed: $e')));
      }
    }
  }

  Future<void> _googleLogin() async => await ref.read(authProvider.notifier).googleLogin();
  Future<void> _appleLogin() async => await ref.read(authProvider.notifier).appleLogin();
  Future<void> _facebookLogin() async => await ref.read(authProvider.notifier).facebookLogin();

  /// Shows the forgot password bottom sheet with email field
  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Enter your email address and we\'ll send you a password reset link.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isResetting ? null : () async {
                  if (resetEmailController.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please enter your email')));
                    return;
                  }
                  setSheetState(() => _isResetting = true);
                  try {
                    await ref.read(apiClientProvider).post('/api/auth/forgot-password', data: {'email': resetEmailController.text});
                    setSheetState(() => _isResetting = false);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent to your email')));
                  } catch (e) {
                    setSheetState(() => _isResetting = false);
                    if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: _isResetting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send Reset Link'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.child_care, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _showForgotPasswordSheet, child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)))),
                const SizedBox(height: 16),
                if (_biometricsAvailable && _biometricsOptedIn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: authState.isLoading ? null : _biometricLogin,
                      icon: const Icon(Icons.fingerprint, size: 24),
                      label: const Text('Sign in with Biometrics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                    ),
                  ),
                if (authState.error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(authState.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: authState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('OR', style: TextStyle(color: Colors.grey[600]))),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ]),
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: authState.isLoading ? null : _googleLogin, icon: const Icon(Icons.g_mobiledata, size: 24), label: const Text('Continue with Google')),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: authState.isLoading ? null : _appleLogin, icon: const Icon(Icons.apple, size: 24), label: const Text('Continue with Apple')),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: authState.isLoading ? null : _facebookLogin, icon: const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)), label: const Text('Continue with Facebook')),
                const SizedBox(height: 16),
                TextButton(onPressed: () => context.go('/register'), child: const Text("Don't have an account? Sign up")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}