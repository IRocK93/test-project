import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/clay_colors.dart';
// ignore_for_file: unused_element
import '../theme/theme_mode_provider.dart';
import 'package:baby_mon/core/constants/constants.dart';


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

class _PremiumBackgroundState extends ConsumerState<PremiumBackground> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClay = ref.watch(appVisualStyleProvider) == AppVisualStyle.clay;

    // Static gradient background — animated orbs removed for performance
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? _darkBaseColors(isClay)
                    : _lightBaseColors(isClay),
                stops: const [0.0, 0.33, 0.67, 1.0],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  List<Color> _lightBaseColors(bool isClay) {
    if (isClay) {
      // Clay: warm cream / beige base
      return [
        const Color(0xFFF5EDE4),
        const Color(0xFFFAF7F2),
        const Color(0xFFFFF8F0),
        const Color(0xFFF3EFE9),
      ];
    }
    // Glass: cool violet / lavender base
    return [
      const Color(0xFFF5F0FF),
      const Color(0xFFFCFAFF),
      const Color(0xFFFFF8F5),
      const Color(0xFFF8F7FA),
    ];
  }

  List<Color> _darkBaseColors(bool isClay) {
    if (isClay) {
      // Clay dark: warm brown-black
      return [
        const Color(0xFF1C1815),
        const Color(0xFF12100E),
        const Color(0xFF1A1510),
        const Color(0xFF12100E),
      ];
    }
    // Glass dark: cool blue-black
    return [
      const Color(0xFF14101E),
      const Color(0xFF0E0E12),
      const Color(0xFF1A1218),
      const Color(0xFF0E0E12),
    ];
  }

  List<Widget> _buildRadialMesh(bool isDark, double t, Size size, bool isClay) {
    final w = size.width;
    final h = size.height;

    // Palette-aware color selection: Clay uses warm earthy tones,
    // Glass uses cool violet/teal tones.
    final primary = isClay ? ClayColors.primary : context.colorScheme.primary;
    final primaryLight = isClay ? ClayColors.primaryLight : context.colorScheme.primary;
    final accent = isClay ? ClayColors.accent : context.colorScheme.primary;
    final accentLight = isClay ? ClayColors.accentLight : context.colorScheme.primary;
    final secondary = isClay ? ClayColors.secondary : context.colorScheme.secondary;
    final secondaryLight = isClay ? ClayColors.secondaryLight : context.colorScheme.secondaryContainer;

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
