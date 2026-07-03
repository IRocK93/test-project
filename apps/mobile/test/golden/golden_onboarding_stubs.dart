import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Empty onboarding form — no data entered yet.
class GoldenOnboardingEmpty extends StatelessWidget {
  const GoldenOnboardingEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildForm(context);
  }
}

/// Partial onboarding form — name entered, other fields empty.
class GoldenOnboardingPartial extends StatelessWidget {
  const GoldenOnboardingPartial({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildForm(context, name: 'Emma');
  }
}

/// Complete onboarding form — all fields filled.
class GoldenOnboardingComplete extends StatelessWidget {
  const GoldenOnboardingComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildForm(context, name: 'Emma', dob: '2026-01-15', gender: 'Girl');
  }
}

Widget _buildForm(
  BuildContext context, {
  String? name,
  String? dob,
  String? gender,
}) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create BabyMon'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceXl),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'Tell us about your baby',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  const Text(
                    'This helps us personalize your experience.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // Name field
                  TextFormField(
                    initialValue: name,
                    decoration: InputDecoration(
                      labelText: 'Baby\'s name',
                      prefixIcon: const Icon(
                        PhosphorIconsLight.baby,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),

                  // Date of birth field
                  TextFormField(
                    initialValue: dob,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of birth',
                      prefixIcon: const Icon(
                        PhosphorIconsLight.calendar,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: const Icon(
                        PhosphorIconsLight.caretDown,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),

                  // Gender field
                  TextFormField(
                    initialValue: gender,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(
                        PhosphorIconsLight.user,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: const Icon(
                        PhosphorIconsLight.caretDown,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXl),

                  // Create button
                  ThemeButton(
                    text: 'Create BabyMon',
                    fullWidth: true,
                    isDisabled: name == null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
