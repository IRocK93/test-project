
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/widgets.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});
  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  String? _message;

  Future<void> _resendVerification() async {
    setState(() { _isResending = true; _message = null; });
    try {
      await ref.read(authProvider.notifier).sendVerificationEmail(widget.email);
      if (mounted) setState(() => _message = 'Verification email sent! Check your inbox.');
    } catch (e) {
      if (mounted) setState(() => _message = 'Failed to send verification email. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() { _isChecking = true; _message = null; });
    try {
      final isVerified = await ref.read(authProvider.notifier).checkEmailVerified();
      if (isVerified && mounted) { context.go('/home'); }
      else if (mounted) { setState(() => _message = 'Email not yet verified. Please check your inbox.'); }
    } catch (e) {
      if (mounted) setState(() => _message = 'Failed to check verification status.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StaggeredFadeSlide(
                    index: 0,
                    child: GlassSurface(
                      borderRadius: DesignTokens.radius2xl,
                      blurSigma: DesignTokens.glassBlurMd,
                      padding: const EdgeInsets.all(DesignTokens.space2xl),
                        child: Column(
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                              ),
                              child: Icon(PhosphorIconsLight.envelope, size: 40, color: colorScheme.primary),
                            ),
                            const SizedBox(height: DesignTokens.spaceLg),
                            Text('Verify Your Email',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                            const SizedBox(height: DesignTokens.spaceMd),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                border: Border.all(color: colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle), width: 0.5),
                              ),
                              child: Text(widget.email,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: DesignTokens.spaceMd),
                            Text('Please check your inbox and click the verification link to continue.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                              textAlign: TextAlign.center),
                            const SizedBox(height: DesignTokens.space2xl),
                            if (_message != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                                child: Container(
                                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                                  decoration: BoxDecoration(
                                    color: _message!.contains('Failed') ? colorScheme.error.withValues(alpha: 0.1) : colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                                    border: Border.all(color: _message!.contains('Failed') ? colorScheme.error.withValues(alpha: 0.2) : colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _message!.contains('Failed') ? PhosphorIconsLight.warningCircle : PhosphorIconsLight.checkCircle,
                                        size: 16,
                                        color: _message!.contains('Failed') ? colorScheme.error : colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(_message!,
                                          style: TextStyle(color: _message!.contains('Failed') ? colorScheme.error : colorScheme.primary, fontWeight: FontWeight.w500, fontSize: DesignTokens.fontSm2),
                                          textAlign: TextAlign.center),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ThemeButton(
                              text: 'Continue',
                              onPressed: _checkVerification,
                              isLoading: _isChecking,
                              fullWidth: true,
                              trailingIcon: PhosphorIconsLight.check,
                              borderRadius: DesignTokens.radiusFull,
                              height: 56,
                              semanticLabel: 'Check email verification',
                            ),
                            const SizedBox(height: DesignTokens.spaceMd),
                            ThemeButton(
                              text: 'Resend Verification Email',
                              onPressed: _resendVerification,
                              isLoading: _isResending,
                              variant: ThemeButtonVariant.outlined,
                              fullWidth: true,
                              semanticLabel: 'Resend verification email',
                            ),
                          ],
                        ),
                      ),
                  ),
                  const SizedBox(height: DesignTokens.space2xl),
                  StaggeredFadeSlide(
                    index: 1,
                    child: TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(PhosphorIconsLight.arrowLeft, size: 18),
                    label: const Text('Back to Login'),
                    style: TextButton.styleFrom(foregroundColor: colorScheme.onPrimary),
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
}
