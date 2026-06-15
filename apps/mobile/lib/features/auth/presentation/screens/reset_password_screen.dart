import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/utils/error_handler.dart';
import 'package:baby_mon/core/widgets/widgets.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isResetting = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(widget.token, _newPasswordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful. Please login.')));
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      setState(() => _isResetting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(extractErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // ── Glass card ──
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.glassDark
                              : AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.glassDarkBorder
                                : AppColors.glassBorder,
                            width: DesignTokens.glassBorderWidth,
                          ),
                          boxShadow: [...DesignTokens.glassShadow(null)],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // ── Lock icon ──
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                ),
                                child: const Icon(
                                  PhosphorIconsLight.lockKey,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceLg),
                              Text(
                                'Reset Password',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spaceXs),
                              Text(
                                'Enter your new password below.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                              ),
                              const SizedBox(height: DesignTokens.space2xl),

                              // ── New Password ──
                              TextFormField(
                                controller: _newPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  prefixIcon: const Icon(PhosphorIconsLight.lock),
                                  suffixIcon: Semantics(
                                    label: 'Toggle password visibility',
                                    child: IconButton(
                                      icon: Icon(_obscureNewPassword
                                          ? PhosphorIconsLight.eyeSlash
                                          : PhosphorIconsLight.eye),
                                      onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                                    ),
                                  ),
                                ),
                                obscureText: _obscureNewPassword,
                                validator: (value) => value!.length < 6
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: DesignTokens.spaceMd),

                              // ── Confirm Password ──
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(PhosphorIconsLight.lock),
                                  suffixIcon: Semantics(
                                    label: 'Toggle password visibility',
                                    child: IconButton(
                                      icon: Icon(_obscureConfirmPassword
                                          ? PhosphorIconsLight.eyeSlash
                                          : PhosphorIconsLight.eye),
                                      onPressed: () => setState(
                                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                ),
                                obscureText: _obscureConfirmPassword,
                                validator: (value) => value != _newPasswordController.text
                                    ? 'Passwords do not match'
                                    : null,
                              ),
                              const SizedBox(height: DesignTokens.space2xl),

                              // ── Reset Button ──
                              ThemeButton(
                                text: 'Reset Password',
                                onPressed: _resetPassword,
                                isLoading: _isResetting,
                                fullWidth: true,
                                trailingIcon: PhosphorIconsLight.check,
                                borderRadius: DesignTokens.radiusFull,
                                height: 56,
                                semanticLabel: 'Reset your password',
                              ),
                            ],
                          ),
                        ),
                      ),                  ),
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
