import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../theme/clay_colors.dart';
import '../theme/theme_mode_provider.dart';

class PremiumBackground extends ConsumerStatefulWidget {
  final Widget child;
  final bool showOrnaments;

  const PremiumBackground({
    super.key,
    required this.child,
    this.showOrnaments = true,
  });

  @override
  ConsumerState<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends ConsumerState<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClay = ref.watch(appVisualStyleProvider) == AppVisualStyle.clay;
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? _darkBaseColors(t, isClay)
                        : _lightBaseColors(t, isClay),
                    stops: [0.0, 0.3 + t * 0.05, 0.7 - t * 0.05, 1.0],
                  ),
                ),
              ),
            ),
            if (widget.showOrnaments) ..._buildRadialMesh(isDark, t, size, isClay),
            widget.child,
          ],
        );
      },
      child: widget.child,
    );
  }

  List<Color> _lightBaseColors(double t, bool isClay) {
    if (isClay) {
      // Clay: warm cream / beige base — matches ClayColors.background
      return [
        Color.lerp(const Color(0xFFF5EDE4), const Color(0xFFF0E8DC), t)!,
        Color.lerp(const Color(0xFFFAF7F2), const Color(0xFFFDFBFA), t)!,
        Color.lerp(const Color(0xFFFFF8F0), const Color(0xFFFFF3E8), t)!,
        const Color(0xFFF3EFE9),
      ];
    }
    // Glass: cool violet / lavender base
    return [
      Color.lerp(const Color(0xFFF5F0FF), const Color(0xFFF0EBFF), t)!,
      Color.lerp(const Color(0xFFFCFAFF), const Color(0xFFFFF9FF), t)!,
      Color.lerp(const Color(0xFFFFF8F5), const Color(0xFFFFF3EE), t)!,
      const Color(0xFFF8F7FA),
    ];
  }

  List<Color> _darkBaseColors(double t, bool isClay) {
    if (isClay) {
      // Clay dark: warm brown-black — matches ClayColors.darkBackground
      return [
        Color.lerp(const Color(0xFF1C1815), const Color(0xFF221C18), t)!,
        const Color(0xFF12100E),
        Color.lerp(const Color(0xFF1A1510), const Color(0xFF201810), t)!,
        const Color(0xFF12100E),
      ];
    }
    // Glass dark: cool blue-black
    return [
      Color.lerp(const Color(0xFF14101E), const Color(0xFF1A1428), t)!,
      const Color(0xFF0E0E12),
      Color.lerp(const Color(0xFF1A1218), const Color(0xFF221018), t)!,
      const Color(0xFF0E0E12),
    ];
  }

  List<Widget> _buildRadialMesh(bool isDark, double t, Size size, bool isClay) {
    final w = size.width;
    final h = size.height;

    // Palette-aware color selection: Clay uses warm earthy tones,
    // Glass uses cool violet/teal tones.
    final primary = isClay ? ClayColors.primary : AppColors.primary;
    final primaryLight = isClay ? ClayColors.primaryLight : AppColors.primaryLight;
    final accent = isClay ? ClayColors.accent : AppColors.accent;
    final accentLight = isClay ? ClayColors.accentLight : AppColors.accentLight;
    final secondary = isClay ? ClayColors.secondary : AppColors.secondary;
    final secondaryLight = isClay ? ClayColors.secondaryLight : AppColors.secondaryLight;

    if (isDark) {
      return [
        _radialOrb(
          left: w * 0.8 - 120 + t * 20,
          top: -80 - t * 30,
          size: 280,
          color: primary.withValues(alpha: 0.12),
        ),
        _radialOrb(
          left: -60 + t * 25,
          top: h * 0.6 - 100 - t * 15,
          size: 240,
          color: accent.withValues(alpha: 0.08),
        ),
        _radialOrb(
          left: w * 0.3 - 80 + t * 15,
          top: h * 0.25 - 80,
          size: 200,
          color: secondary.withValues(alpha: 0.06),
        ),
        _radialOrb(
          left: w * 0.1 - 60,
          top: h - 100 + t * 20,
          size: 180,
          color: primaryLight.withValues(alpha: 0.05),
        ),
      ];
    }

    return [
      _radialOrb(
        left: w * 0.85 - 140 + t * 25,
        top: -100 - t * 25,
        size: 320,
        color: primaryLight.withValues(alpha: 0.15),
      ),
      _radialOrb(
        left: -80 + t * 20,
        top: h * 0.55 - 120 - t * 20,
        size: 280,
        color: accentLight.withValues(alpha: 0.1),
      ),
      _radialOrb(
        left: w * 0.25 - 90 + t * 18,
        top: h * 0.2 - 90,
        size: 240,
        color: secondaryLight.withValues(alpha: 0.08),
      ),
      _radialOrb(
        left: w * 0.5 - 70 - t * 15,
        top: h * 0.75 - 80,
        size: 220,
        color: primary.withValues(alpha: 0.06),
      ),
    ];
  }

  Widget _radialOrb({
    required double left,
    required double top,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
