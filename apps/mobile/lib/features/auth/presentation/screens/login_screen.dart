import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/utils/error_mapper.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/widgets/responsive_wrapper.dart';
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
    } catch (e) { debugPrint('[Login] biometrics check failed: $e'); }
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
          context.go('/loading');
        } else if (mounted) {
          context.go('/verify-email?email=${Uri.encodeComponent(_emailController.text)}');
        }
      }
    }
  }
  Future<void> _biometricLogin() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: context.l10n.biometricPrompt,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      if (authenticated && mounted) {
        if (!_biometricsOptedIn) {
          final enable = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.l10n.biometricEnableTitle),
              content: Text(context.l10n.biometricEnablePrompt),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.notNow)),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.enable)),
              ],
            ),
          );
          if (enable == true && mounted) await _saveBiometricPreference(true);
        }
        await ref.read(authProvider.notifier).biometricLogin();
        if (ref.read(authProvider).user != null && mounted) context.go('/loading');
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
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              const SizedBox(height: DesignTokens.spaceSm),
              Text(context.l10n.resetPasswordTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: DesignTokens.spaceSm),
              Text(
                context.l10n.resetPasswordSubtitle,
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant, fontSize: 14),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: context.l10n.emailLabel,                              prefixIcon: const Icon(PhosphorIconsLight.envelope),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              ThemeButton(
                text: context.l10n.sendResetLink,
                onPressed: () async {
                  if (resetEmailController.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(context.l10n.emailRequired)),
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
                        SnackBar(content: Text(context.l10n.resetPasswordSuccess)),
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: ResponsiveWrapper(
        scrollable: false,
        landscapeLayout: _buildLandscapeBody(cs, authState),
        child: SingleChildScrollView(
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark], // Gradient uses branded palette
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
                            ...DesignTokens.glassShadow(Colors.transparent),
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
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                            ),
                            child: Icon(
                              PhosphorIconsLight.baby,
                              size: 36,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceLg),
                          // Title
                          Text(
                            context.l10n.loginTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXs),
                          Text(
                            context.l10n.loginSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space2xl),
                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: context.l10n.emailLabel,
                              prefixIcon: const Icon(PhosphorIconsLight.envelope),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => value!.isEmpty ? context.l10n.emailRequired : null,
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),
                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: context.l10n.passwordLabel,
                              prefixIcon: const Icon(PhosphorIconsLight.lock),
                              suffixIcon: Semantics(
                                label: context.l10n.togglePasswordVisibility,
                                child: IconButton(
                                  icon: Icon(_obscurePassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) => value!.isEmpty ? context.l10n.passwordRequired : null,
                          ),
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordSheet,
                              child: Text(context.l10n.forgotPassword),
                            ),
                          ),
                          // Error
                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                              child: Text(
                                ErrorMapper.localize(context, authState.error),
                                style: TextStyle(color: cs.error, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          // Login button
                          ThemeButton(
                            text: context.l10n.loginButton,
                            onPressed: _login,
                            isLoading: authState.isLoading,
                            fullWidth: true,
                            trailingIcon: PhosphorIconsLight.arrowRight,
                            borderRadius: DesignTokens.radiusFull,
                            semanticLabel: context.l10n.loginButton,
                          ),
                          // Biometrics
                          if (_biometricsAvailable && _biometricsOptedIn) ...[
                            const SizedBox(height: DesignTokens.spaceMd),
                            ThemeButton(
                            text: context.l10n.biometricLogin,
                            onPressed: _biometricLogin,
                            variant: ThemeButtonVariant.outlined,
                            icon: PhosphorIconsLight.fingerprint,
                            fullWidth: true,
                            semanticLabel: context.l10n.biometricLogin,
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
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
                            child: Text(
                              context.l10n.orDivider,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.divider)),
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
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textOnDark,
                        ),
                        children: [
                          TextSpan(text: context.l10n.noAccount),
                          TextSpan(
                            text: context.l10n.signUpLink,
                            style: const TextStyle(
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
	    ),
	    ));
				  }
  /// Landscape layout: branding panel on left, scrollable form on right.
  Widget _buildLandscapeBody(ColorScheme cs, dynamic authState) {
    return Row(
      children: [
        // ── Left: branding ──
        Expanded(
          flex: 4,
          child: Container(
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
                  padding: const EdgeInsets.all(DesignTokens.space2xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                        ),
                        child: Icon(PhosphorIconsLight.baby, size: 40, color: cs.primary),
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),
                      Text(
                        context.l10n.loginTitle,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXs),
                      Text(
                        context.l10n.loginSubtitle,
                        style: const TextStyle(fontSize: 15, color: Colors.white70),
                      ),
                      const SizedBox(height: DesignTokens.space2xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialCircle(Icons.g_mobiledata, AppColors.warning, _googleLogin),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(Icons.apple, Colors.white, _appleLogin),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(Icons.facebook, const Color(0xFF1877F2), _facebookLogin),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // ── Right: form ──
        Expanded(
          flex: 6,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignTokens.space2xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass form card
                    ClipRRect(
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
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.emailLabel,
                                    prefixIcon: const Icon(PhosphorIconsLight.envelope),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.isEmpty ? context.l10n.emailRequired : null,
                                ),
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.passwordLabel,
                                    prefixIcon: const Icon(PhosphorIconsLight.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (v) => v!.isEmpty ? context.l10n.passwordRequired : null,
                                ),
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showForgotPasswordSheet,
                                    child: Text(context.l10n.forgotPassword),
                                  ),
                                ),
                                // Error
                                if (authState.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                                    child: Text(
                                      ErrorMapper.localize(context, authState.error),
                                      style: TextStyle(color: cs.error, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                // Login button
                                ThemeButton(
                                  text: context.l10n.loginButton,
                                  onPressed: _login,
                                  isLoading: authState.isLoading,
                                  fullWidth: true,
                                  trailingIcon: PhosphorIconsLight.arrowRight,
                                  borderRadius: DesignTokens.radiusFull,
                                  semanticLabel: context.l10n.loginButton,
                                ),
                                // Biometrics
                                if (_biometricsAvailable && _biometricsOptedIn) ...[
                                  const SizedBox(height: DesignTokens.spaceMd),
                                  ThemeButton(
                                    text: context.l10n.biometricLogin,
                                    onPressed: _biometricLogin,
                                    variant: ThemeButtonVariant.outlined,
                                    icon: PhosphorIconsLight.fingerprint,
                                    fullWidth: true,
                                    semanticLabel: context.l10n.biometricLogin,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // Register link
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14),
                          children: [
                            TextSpan(text: context.l10n.noAccount),
                            TextSpan(
                              text: context.l10n.signUpLink,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _socialCircle(IconData icon, Color color, VoidCallback onTap) {
    final label = icon == Icons.g_mobiledata
        ? context.l10n.socialLoginGoogle
        : icon == Icons.apple
            ? context.l10n.socialLoginApple
            : context.l10n.socialLoginFacebook;
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