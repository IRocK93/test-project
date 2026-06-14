import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Simplified login form for golden testing — mirrors LoginScreen layout
/// without platform plugin dependencies (local_auth, SharedPreferences).
class GoldenLoginForm extends StatelessWidget {
  const GoldenLoginForm({super.key});

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsLight.baby,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),

                      // Title
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceSm),
                      const Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Email field
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            PhosphorIconsLight.envelope,
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

                      // Password field
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            PhosphorIconsLight.lock,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: Icon(
                            PhosphorIconsLight.eyeSlash,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceSm),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: null,
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceMd),

                      // Login button
                      const ThemeButton(
                        text: 'Sign In',
                        icon: PhosphorIconsLight.arrowRight,
                        fullWidth: true,
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Social divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceMd,
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),

                      // Social buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialCircle(PhosphorIconsLight.googleLogo, Colors.red),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(PhosphorIconsLight.appleLogo, Colors.black),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(PhosphorIconsLight.facebookLogo, Color(0xFF1877F2)),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Register link
                      RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialCircle(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// Simplified register form for golden testing — mirrors RegisterScreen layout
/// without platform plugin dependencies.
class GoldenRegisterForm extends StatelessWidget {
  const GoldenRegisterForm({super.key});

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsLight.baby,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),

                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceSm),
                      const Text(
                        'Join BabyMon today',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Name field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Name (optional)',
                          prefixIcon: Icon(
                            PhosphorIconsLight.user,
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

                      // Email field
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            PhosphorIconsLight.envelope,
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

                      // Password field
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            PhosphorIconsLight.lock,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: Icon(
                            PhosphorIconsLight.eyeSlash,
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

                      // Confirm password field
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(
                            PhosphorIconsLight.lock,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: Icon(
                            PhosphorIconsLight.eyeSlash,
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

                      // Sign up button
                      const ThemeButton(
                        text: 'Sign Up',
                        fullWidth: true,
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Social divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceMd,
                            ),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceLg),

                      // Social buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialCircle(PhosphorIconsLight.googleLogo, Colors.red),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(PhosphorIconsLight.appleLogo, Colors.black),
                          const SizedBox(width: DesignTokens.spaceMd),
                          _socialCircle(PhosphorIconsLight.facebookLogo, Color(0xFF1877F2)),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceXl),

                      // Login link
                      RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialCircle(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// Simplified splash screen for golden testing — mirrors SplashScreen layout
/// without the auth-check navigation that causes SharedPreferences issues.
class GoldenSplashScreen extends StatelessWidget {
  const GoldenSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIconsLight.baby,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceLg),
                // App name
                const Text(
                  'BabyMon',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                // Tagline
                Text(
                  'Smart Evolving Parenting Companion',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: DesignTokens.space3xl),
                // Loading indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
