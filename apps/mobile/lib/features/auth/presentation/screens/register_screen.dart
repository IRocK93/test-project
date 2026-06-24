import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/widgets.dart';
import 'package:baby_mon/core/widgets/responsive_wrapper.dart';
import '../../../../core/utils/validators.dart';

/// Register screen with matching auth card layout, password strength indicator,
/// confirm password field, and social row.
///
/// ═══════════════════════════════════════════
///  Auth provider: features/auth/auth.dart
///  Google OAuth:  core/services/google_sign_in_service.dart
///  Facebook OAuth: core/services/facebook_sign_in_service.dart
///  Apple OAuth:   core/services/apple_sign_in_service.dart
/// ═══════════════════════════════════════════
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
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _dateOfBirth;
  bool _tosAccepted = false;
  bool _privacyAccepted = false;
  bool _consentToDataProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 6) score += 0.25;
    if (p.length >= 10) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) score += 0.2;
    if (RegExp(r"[!@#\$%^&*(),.?':{}|<>]").hasMatch(p)) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s == 0) return Colors.transparent;
    if (s < 0.3) return AppColors.error;
    if (s < 0.6) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s == 0) return '';
    if (s < 0.3) return 'Weak';
    if (s < 0.6) return 'Fair';
    if (s < 0.8) return 'Good';
    return 'Strong';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }
    if (!_tosAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Terms of Service')),
      );
      return;
    }
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Privacy Policy')),
      );
      return;
    }
    if (!_consentToDataProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must consent to data processing')),
      );
      return;
    }
    await ref.read(authProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.isNotEmpty ? _nameController.text.trim() : null,
          _dateOfBirth!,
          _tosAccepted,
          _privacyAccepted,
          _consentToDataProcessing,
        );
  }

  Future<void> _googleLogin() async => await ref.read(authProvider.notifier).googleLogin();
  Future<void> _appleLogin() async => await ref.read(authProvider.notifier).appleLogin();
  Future<void> _facebookLogin() async => await ref.read(authProvider.notifier).facebookLogin();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;

    // Navigate after successful registration
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn && !next.isEmailVerified && mounted) {
        context.go('/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}');
      } else if (next.isLoggedIn && next.isEmailVerified && mounted) {
        context.go('/create-baby-mon');
      }
    });

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
                  // ── Glass Auth Card ──
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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceXs),
                          Text(
                            'Join BabyMon today',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.space2xl),

                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name (optional)',
                              prefixIcon: Icon(PhosphorIconsLight.user),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(PhosphorIconsLight.envelope),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: emailValidator,
                          ),
                          const SizedBox(height: DesignTokens.spaceMd),

                          // Password with strength indicator
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
                            onChanged: (_) => setState(() {}),
                            validator: passwordValidator,
                          ),

                          // Password strength bar
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: DesignTokens.spaceSm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: SizedBox(
                                height: 3,
                                child: FractionallySizedBox(
                                  widthFactor: _passwordStrength,
                                  child: Container(color: _strengthColor),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  _strengthLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _strengthColor,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: DesignTokens.spaceMd),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(PhosphorIconsLight.lock),
                              suffixIcon: Semantics(
                                label: 'Toggle password visibility',
                                child: IconButton(
                                  icon: Icon(_obscureConfirmPassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                              ),
                            ),
                            obscureText: _obscureConfirmPassword,
                            validator: (value) => confirmPasswordValidator(value, _passwordController.text),
                          ),

                          const SizedBox(height: DesignTokens.spaceMd),

                          // ── Date of Birth ──
                          InkWell(
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dateOfBirth ?? DateTime(now.year - 25),
                                firstDate: DateTime(1900),
                                lastDate: now.subtract(const Duration(days: 365 * 18)),
                                helpText: 'Select your date of birth',
                              );
                              if (picked != null) {
                                setState(() => _dateOfBirth = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                prefixIcon: const Icon(PhosphorIconsLight.calendar),
                                suffixIcon: _dateOfBirth != null
                                    ? IconButton(
                                        icon: const Icon(PhosphorIconsLight.x, size: 18),
                                        onPressed: () => setState(() => _dateOfBirth = null),
                                      )
                                    : null,
                                errorText: null,
                              ),
                              child: Text(
                                _dateOfBirth != null
                                    ? '${_dateOfBirth!.month}/${_dateOfBirth!.day}/${_dateOfBirth!.year}'
                                    : 'Tap to select',
                                style: TextStyle(
                                  color: _dateOfBirth != null
                                      ? Theme.of(context).textTheme.bodyLarge?.color
                                      : Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: DesignTokens.spaceMd),

                          // ── Consent Checkboxes ──
                          Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              value: _tosAccepted,
                              onChanged: (v) => setState(() => _tosAccepted = v ?? false),
                              title: GestureDetector(
                                onTap: () => context.push('/legal/tos'),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'I accept the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              value: _privacyAccepted,
                              onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
                              title: GestureDetector(
                                onTap: () => context.push('/legal/privacy'),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'I accept the '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              value: _consentToDataProcessing,
                              onChanged: (v) => setState(() => _consentToDataProcessing = v ?? false),
                              title: const Text(
                                'I consent to processing of child health & development data',
                                style: TextStyle(fontSize: 13),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),

                          const SizedBox(height: DesignTokens.spaceMd),

                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                              child: Text(
                                authState.error!,
                                style: TextStyle(color: cs.error, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Register button
                          ThemeButton(
                            text: 'Sign Up',
                            onPressed: _register,
                            isLoading: authState.isLoading,
                            fullWidth: true,
                            trailingIcon: PhosphorIconsLight.heart,
                            borderRadius: DesignTokens.radiusFull,
                            semanticLabel: 'Create your account',
                          ),
                        ],
                      ),
                    ),
                  ),                  ),
                ),
              ),
                const SizedBox(height: DesignTokens.space2xl),

              // ── Social Row ──
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

              // Login link
              StaggeredFadeSlide(
                index: 2,
                child: Semantics(
                    label: 'Navigate to login',
                    button: true,
                    child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textOnDark,
                        ),
                        children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
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
                      const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: DesignTokens.spaceXs),
                      const Text(
                        'Join BabyMon today',
                        style: TextStyle(fontSize: 15, color: Colors.white70),
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
                                // Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (optional)',
                                    prefixIcon: Icon(PhosphorIconsLight.user),
                                  ),
                                ),
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(PhosphorIconsLight.envelope),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: emailValidator,
                                ),
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(PhosphorIconsLight.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                  onChanged: (_) => setState(() {}),
                                  validator: passwordValidator,
                                ),
                                // Password strength
                                if (_passwordController.text.isNotEmpty) ...[
                                  const SizedBox(height: DesignTokens.spaceSm),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: SizedBox(
                                      height: 3,
                                      child: FractionallySizedBox(
                                        widthFactor: _passwordStrength,
                                        child: Container(color: _strengthColor),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Confirm Password
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: const Icon(PhosphorIconsLight.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                  obscureText: _obscureConfirmPassword,
                                  validator: (v) => confirmPasswordValidator(v, _passwordController.text),
                                ),
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Consent
                                CheckboxListTile(
                                  value: _consentToDataProcessing,
                                  onChanged: (v) => setState(() => _consentToDataProcessing = v ?? false),
                                  title: const Text(
                                    'I consent to processing of child health & development data',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                ),
                                // Error
                                if (authState.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                                    child: Text(
                                      authState.error!,
                                      style: TextStyle(color: cs.error, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: DesignTokens.spaceMd),
                                // Sign Up button
                                ThemeButton(
                                  text: 'Sign Up',
                                  onPressed: _register,
                                  isLoading: authState.isLoading,
                                  fullWidth: true,
                                  trailingIcon: PhosphorIconsLight.heart,
                                  borderRadius: DesignTokens.radiusFull,
                                  semanticLabel: 'Create your account',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    // Login link
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14),
                          children: [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(fontWeight: FontWeight.w600),
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
        ? 'Sign up with Google'
        : icon == Icons.apple
            ? 'Sign up with Apple'
            : 'Sign up with Facebook';
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
