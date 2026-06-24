import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/core/constants/constants.dart';
/// Splash screen with premium gradient, glass logo orb, and animated entry.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (MediaQuery.of(context).disableAnimations) {
          _controller.value = 1.0;
        } else {
          _controller.forward();
        }
      }
    });
    _checkAuth();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Future<void> _checkAuth() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 500)); // brief pause for animation to play
      if (!mounted) return;
      final isLoggedIn = await authNotifier.checkAuth();
      if (!mounted) return;
      if (isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } catch (_) {
      if (mounted) context.go('/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ──
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.primaryContainer,
                  context.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // ── Glass orbs for depth ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.secondary.withValues(alpha: DesignTokens.opacitySubtle),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          // ── Glass backdrop blur ──
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: DesignTokens.glassBlurHeavy,
                sigmaY: DesignTokens.glassBlurHeavy,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),
          // ── Content ──
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Glass logo orb ──
                    Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: context.glass.surface,
                            borderRadius: BorderRadius.circular(DesignTokens.radius3xl),
                            border: Border.all(
                              color: context.glass.border,
                              width: DesignTokens.glassBorderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: context.colorScheme.onSurface.withValues(alpha: DesignTokens.opacitySubtle),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              PhosphorIconsLight.baby,
                              size: 56,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space2xl),
                    // ── App name ──
                    Opacity(
                      opacity: _logoFade.value,
                      child: Text(
                        'BabyMon',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.colorScheme.onPrimary,
                            ),
                      ),
                    ),
                    // ── Tagline ──
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: DesignTokens.spaceSm),
                        child: Text(
                          'Smart Evolving Parenting Companion',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.space5xl),
                    // ── Glass spinner ──
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.glass.surface.withValues(alpha: DesignTokens.opacitySubtle),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.glass.border,
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colorScheme.onPrimary,
                              ),
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
        ],
      ),
    );
  }
}
