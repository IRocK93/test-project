import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/widgets/widgets.dart';

//// Login screen with premium double-bezel card, button-in-button CTAs, and info tooltips on social circles.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isResetting = false;
  bool _biometricsAvailable = false;
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

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final optedIn = prefs.getBool('biometrics_enabled') ?? false;
      if (mounted) {
        setState(() {
          _biometricsAvailable = canCheck && isDeviceSupported;
          _biometricsOptedIn = optedIn;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveBiometricPreference(bool enabled) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('biometrics_enabled', enabled);
    if (mounted) setState(() => _biometricsOptedIn = enabled);
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
        showError(context, e);
      }
    }
  }

  Future<void> _googleLogin() async => await ref.read(authProvider.notifier).googleLogin();
  Future<void> _appleLogin() async => await ref.read(authProvider.notifier).appleLogin();
  Future<void> _facebookLogin() async => await ref.read(authProvider.notifier).facebookLogin();

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: DesignTokens.spaceLg,
            right: DesignTokens.spaceLg,
            top: DesignTokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [                  Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              const SizedBox(height: DesignTokens.spaceSm),
              Text('Reset Password', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: DesignTokens.spaceSm),
              const Text(
                "Enter your email address and we'll send you a password reset link.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',                              prefixIcon: Icon(PhosphorIconsLight.envelope),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              ThemeButton(
                text: 'Send Reset Link',
                onPressed: () async {
                  if (resetEmailController.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Please enter your email')),
                    );
                    return;
                  }
                  setSheetState(() => _isResetting = true);
                  try {
                    await ref.read(apiClientProvider).post(
                      '/api/auth/forgot-password',
                      data: {'email': resetEmailController.text},
                    );
                    setSheetState(() => _isResetting = false);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password reset link sent to your email')),
                      );
                    }
                  } catch (e) {
                    setSheetState(() => _isResetting = false);
                    if (ctx.mounted) showError(ctx, e);
                  }
                },
                isLoading: _isResetting,
                fullWidth: true,
                semanticLabel: 'Send password reset link',
              ),
              const SizedBox(height: DesignTokens.spaceLg),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spaceLg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ---- Glass Auth Card ----
                  StaggeredFadeSlide(
                    index: 0,
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: DesignTokens.glassBlurMd,
                        sigmaY: DesignTokens.glassBlurMd,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(DesignTokens.space2xl),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: DesignTokens.glassBorderWidth,
                          ),
                          boxShadow: [
                            ...DesignTokens.glassShadow(null),
                          ],
                        ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                            ),
                            child: const Icon(
                              PhosphorIconsLight.baby,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceLg),

                          // Title
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXs),
                          const Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space2xl),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(PhosphorIconsLight.envelope),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(PhosphorIconsLight.lock),
                              suffixIcon: Semantics(
                                label: 'Toggle password visibility',
                                child: IconButton(
                                  icon: Icon(_obscurePassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) => value!.isEmpty ? 'Please enter your password' : null,
                          ),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordSheet,
                              child: const Text('Forgot Password?'),
                            ),
                          ),

                          // Error
                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                              child: Text(
                                authState.error!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Login button
                          ThemeButton(
                            text: 'Login',
                            onPressed: _login,
                            isLoading: authState.isLoading,
                            fullWidth: true,
                            trailingIcon: PhosphorIconsLight.arrowRight,
                            borderRadius: DesignTokens.radiusFull,
                            semanticLabel: 'Login to your account',
                          ),

                          // Biometrics
                          if (_biometricsAvailable && _biometricsOptedIn) ...[
                            const SizedBox(height: DesignTokens.spaceMd),
                            ThemeButton(
                            text: 'Sign in with Biometrics',
                            onPressed: _biometricLogin,
                            variant: ThemeButtonVariant.outlined,
                            icon: PhosphorIconsLight.fingerprint,
                            fullWidth: true,
                            semanticLabel: 'Sign in with biometrics',
                          ),
                          ],
                        ],
                      ),
                    ),
                  ),                  ),
                ),
              ),
                const SizedBox(height: DesignTokens.space2xl),

              // ---- Social Row ----
              StaggeredFadeSlide(
                index: 1,
                child: Column(
                    children: [
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.divider)),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),

                      // Social icons in a row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialCircle(Icons.g_mobiledata, AppColors.warning, _googleLogin),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(Icons.apple, AppColors.textPrimary, _appleLogin),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(Icons.facebook, const Color(0xFF1877F2), _facebookLogin),
                        ],
                      ),
                    ],
                  ),
              ),

              const SizedBox(height: DesignTokens.space2xl),

              // Register link
              StaggeredFadeSlide(
                index: 2,
                child: Semantics(
                    label: 'Navigate to register',
                    button: true,
                    child: GestureDetector(
                    onTap: () => context.go('/register'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textOnDark,
                        ),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialCircle(IconData icon, Color color, VoidCallback onTap) {
    final label = icon == Icons.g_mobiledata
        ? 'Sign in with Google'
        : icon == Icons.apple
            ? 'Sign in with Apple'
            : 'Sign in with Facebook';
    return Tooltip(
      message: label,
      preferBelow: false,
      verticalOffset: 12,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      textStyle: const TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          border: Border.all(
            color: AppColors.textOnDark.withValues(alpha: 0.15),
          ),
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: AppColors.textOnDark, size: 22),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}