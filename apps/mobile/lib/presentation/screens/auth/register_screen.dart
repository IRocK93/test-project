import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';

/// Register screen with email/password signup and social OAuth buttons.
///
/// ═══════════════════════════════════════════════════════════
///  OAuth FILES REFERENCE (same as login_screen.dart)
/// ═══════════════════════════════════════════════════════════
///
/// [AUTH PROVIDER — CENTRAL FILE]
///   `presentation/providers/auth_provider.dart`
///   Contains the main AuthNotifier with login/logout/register/googleLogin/
///   appleLogin/facebookLogin. This is where screen events connect.
///
/// [FEATURE-LEVEL AUTH PROVIDER — SEPARATE FILE]
///   `features/auth/presentation/providers/auth_provider.dart`
///   A different provider in the features layer. Check path if imports fail.
///
/// [OAUTH SERVICE FILES — all in core/services/]
///   • `core/services/google_sign_in_service.dart`  — google_sign_in ^6.2.1
///   • `core/services/facebook_sign_in_service.dart` — flutter_facebook_auth ^7.0.1
///   • `core/services/apple_sign_in_service.dart`   — sign_in_with_apple ^6.1.2
///   WARNING: These are NOT in features/auth/services/ — don't look there.
///
/// [AUTH DATA SOURCE] — `features/auth/data/datasources/auth_remote_datasource.dart`
///
/// [SCREENS WITH OAuth BUTTONS]
///   • `auth/login_screen.dart`     — Login form + social buttons
///   • `auth/register_screen.dart`  — THIS FILE. Register form + social buttons
///
/// Common pitfall: authProvider import must be:
///   `package:baby_mon/presentation/providers/auth_provider.dart`
/// NOT the features-layer provider path.
/// ═══════════════════════════════════════════════════════════
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Whether the password field shows plain text (true = hidden, false = visible)
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).register(
        _emailController.text,
        _passwordController.text,
        _nameController.text.isNotEmpty ? _nameController.text : null,
      );
      if (ref.read(authProvider).user != null && mounted) {
        context.go('/verify-email?email=${Uri.encodeComponent(_emailController.text)}');
      }
    }
  }

  Future<void> _googleLogin() async {
    await ref.read(authProvider.notifier).googleLogin();
  }

  Future<void> _appleLogin() async {
    await ref.read(authProvider.notifier).appleLogin();
  }

  Future<void> _facebookLogin() async {
    await ref.read(authProvider.notifier).facebookLogin();
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.child_care, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join BabyMon today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name (optional)', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
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
                  validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(authState.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _googleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _appleLogin,
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Continue with Apple'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _facebookLogin,
                  icon: const Icon(Icons.facebook, size: 24, color: Color(0xFF1877F2)),
                  label: const Text('Continue with Facebook'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
