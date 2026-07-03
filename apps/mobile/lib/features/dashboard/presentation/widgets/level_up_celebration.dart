import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';

/// Returns the phase number (1-6) for a given level (1-50).
int _phaseForLevel(int level) {
  if (level <= 5) return 1;
  if (level <= 15) return 2;
  if (level <= 25) return 3;
  if (level <= 35) return 4;
  if (level <= 45) return 5;
  return 6;
}

/// Animated celebration overlay shown when a BabyMon levels up.
///
/// Features:
/// - Dark scrim backdrop with tap-to-dismiss
/// - Animated XP bar that fills and glows gold
/// - Level name reveal with scale bounce
/// - Themed particle effects (leaf/sparkle/star based on phase)
/// - Phase milestone extended treatment (every 5th level)
/// - Level 50 special journey recap
/// - Haptic feedback on entry
/// - Respects reduced motion accessibility
class LevelUpCelebration extends StatefulWidget {
  const LevelUpCelebration({
    super.key,
    required this.level,
    required this.onDismiss,
  });

  final int level;
  final VoidCallback onDismiss;

  /// Convenience factory that shows the celebration as a dialog.
  static void show(BuildContext context, int newLevel) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: context.colorScheme.onSurface.withValues(alpha: 0.3),
      builder: (ctx) => LevelUpCelebration(
        level: newLevel,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showLevelName = false;
  bool _showDescription = false;
  bool _showParticles = false;
  bool _showPhase = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), // Intentional: dramatic celebration reveal
    );

    // Haptic feedback on entry
    try {
      HapticFeedback.mediumImpact();
    } catch (_) { /* haptic feedback unavailable — non-critical */ }

    // Sequence the animation reveals
    _controller.addListener(() {
      final v = _controller.value;
      if (!_showLevelName && v >= 0.15) {
        setState(() => _showLevelName = true);
      }
      if (!_showParticles && v >= 0.30) {
        setState(() => _showParticles = true);
      }
      if (widget.level % 5 == 0 && !_showPhase && v >= 0.45) {
        setState(() => _showPhase = true);
      }
      if (!_showDescription && v >= 0.50) {
        setState(() => _showDescription = true);
      }
    });

    _controller.forward();

    // Auto-dismiss after 4s (slightly longer than animation to allow settling)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isPhaseMilestone => widget.level % 5 == 0 && widget.level < 50;
  bool get _isLuminary => widget.level >= 50;
  String get _levelName {
    final lvl = widget.level;
    if (lvl < 1 || lvl > 50) return context.l10n.levelFallback(lvl);
    final keys = [
      '', // index 0 unused
      context.l10n.levelName1, context.l10n.levelName2, context.l10n.levelName3, context.l10n.levelName4, context.l10n.levelName5,
      context.l10n.levelName6, context.l10n.levelName7, context.l10n.levelName8, context.l10n.levelName9, context.l10n.levelName10,
      context.l10n.levelName11, context.l10n.levelName12, context.l10n.levelName13, context.l10n.levelName14, context.l10n.levelName15,
      context.l10n.levelName16, context.l10n.levelName17, context.l10n.levelName18, context.l10n.levelName19, context.l10n.levelName20,
      context.l10n.levelName21, context.l10n.levelName22, context.l10n.levelName23, context.l10n.levelName24, context.l10n.levelName25,
      context.l10n.levelName26, context.l10n.levelName27, context.l10n.levelName28, context.l10n.levelName29, context.l10n.levelName30,
      context.l10n.levelName31, context.l10n.levelName32, context.l10n.levelName33, context.l10n.levelName34, context.l10n.levelName35,
      context.l10n.levelName36, context.l10n.levelName37, context.l10n.levelName38, context.l10n.levelName39, context.l10n.levelName40,
      context.l10n.levelName41, context.l10n.levelName42, context.l10n.levelName43, context.l10n.levelName44, context.l10n.levelName45,
      context.l10n.levelName46, context.l10n.levelName47, context.l10n.levelName48, context.l10n.levelName49, context.l10n.levelName50,
    ];
    return keys[lvl];
  }

  int get _phase => _phaseForLevel(widget.level);

  String _phaseDescForLevel(int lvl) {
    final phase = _phaseForLevel(lvl);
    switch (phase) {
      case 1: return context.l10n.phaseDescSeed;
      case 2: return context.l10n.phaseDescSprout;
      case 3: return context.l10n.phaseDescGrowth;
      case 4: return context.l10n.phaseDescTree;
      case 5: return context.l10n.phaseDescPeak;
      default: return context.l10n.phaseDescStar;
    }
  }

  String _phaseEmblem(int phase) {
    switch (phase) {
      case 1: return context.l10n.phaseEmblemSeed;
      case 2: return context.l10n.phaseEmblemSprout;
      case 3: return context.l10n.phaseEmblemGrowth;
      case 4: return context.l10n.phaseEmblemTree;
      case 5: return context.l10n.phaseEmblemPeak;
      default: return context.l10n.phaseEmblemStar;
    }
  }

  /// Particle type is based on the phase number:
  /// Phase 1-2: leaf (eco icon), Phase 3-4: sparkle (auto_awesome icon), Phase 5-6: star (star icon)
  IconData get _particleIcon {
    if (_phase <= 2) return Icons.eco;
    if (_phase <= 4) return Icons.auto_awesome;
    return Icons.star;
  }

  Color get _particleColor {
    if (_phase <= 2) return const Color(0xFF7BC67E);
    if (_phase <= 4) return const Color(0xFFF5D76E);
    return const Color(0xFFFFD700);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: context.l10n.levelUpSemanticsFormat(widget.level, _levelName),
      child: GestureDetector(
        onTap: () {
          if (_controller.value > 0.25) {
            widget.onDismiss();
          }
        },
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Animated scrim
                  Positioned.fill(
                    child: Opacity(
                      opacity: (_controller.value * 0.7).clamp(0.0, 0.7),
                      child: Container(color: Colors.black87),
                    ),
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Level badge ──
                          _buildLevelBadge(reducedMotion),
                          const SizedBox(height: 24),
                          // ── Level name reveal ──
                          if (_showLevelName) _buildLevelName(reducedMotion),
                          // ── Phase milestone text ──
                          if (_showPhase && _isPhaseMilestone)
                            _buildPhaseMilestone(reducedMotion),
                          // ── Description ──
                          if (_showDescription) _buildDescription(reducedMotion),
                          // ── Level 50 journey recap ──
                          if (_showDescription && _isLuminary)
                            _buildLuminaryRecap(reducedMotion),
                        ],
                      ),
                    ),
                  ),
                  // ── Particle overlay ──
                  if (_showParticles && !reducedMotion)
                    _ParticleOverlay(
                      icon: _particleIcon,
                      color: _particleColor,
                      count: _isPhaseMilestone || _isLuminary ? 40 : 25,
                    ),
                  // ── Tap hint ──
                  if (_controller.value > 0.25)
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            context.l10n.tapAnywhereToContinue,
                            style: TextStyle(
                              fontSize: DesignTokens.fontSm2,
                              color: context.colorScheme.onPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(bool reducedMotion) {
    final scale = reducedMotion
        ? 1.0
        : 0.6 + (0.6 * Curves.easeOutBack.transform(_controller.value));
    final glowOpacity = _controller.value.clamp(0.0, 1.0);

    return Transform.scale(
      scale: scale.clamp(0.6, 1.3),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
            radius: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4 * glowOpacity),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.l10n.levelShort} ${widget.level}',
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 2),
              Text(
                '${context.l10n.levelShort} ${widget.level}',
                style: const TextStyle(
                  fontSize: DesignTokens.fontLg,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D4037),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelName(bool reducedMotion) {
    final opacity = reducedMotion
        ? 1.0
        : ((_controller.value - 0.15) / 0.15).clamp(0.0, 1.0);
    final scale = reducedMotion
        ? 1.0
        : 0.95 + (0.10 * Curves.easeOutBack.transform((_controller.value - 0.15).clamp(0.0, 0.5) * 2));
    final showGlow = !reducedMotion && _controller.value > 0.2;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale.clamp(0.9, 1.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: showGlow
                ? const Color(0xFFFFD700).withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _levelName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _isLuminary ? 34 : 28,
              fontWeight: FontWeight.w900,
              color: context.colorScheme.onPrimary,
              letterSpacing: -1.0,
              shadows: [
                if (showGlow)
                  Shadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                    blurRadius: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseMilestone(bool reducedMotion) {
    final opacity = reducedMotion
        ? 1.0
        : ((_controller.value - 0.45) / 0.1).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Opacity(
        opacity: reducedMotion ? 1.0 : opacity.clamp(0.0, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.phaseMilestone,
              style: TextStyle(
                fontSize: DesignTokens.fontLg,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF80DEEA).withValues(alpha: opacity.clamp(0.5, 1.0)),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _phaseDescForLevel(widget.level),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTokens.fontSm2,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(bool reducedMotion) {
    final opacity = reducedMotion
        ? 1.0
        : ((_controller.value - 0.50) / 0.15).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Opacity(
        opacity: reducedMotion ? 1.0 : opacity.clamp(0.0, 1.0),
        child: Text(
          context.l10n.keepTrackingMoment,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: DesignTokens.fontMd,
            fontWeight: FontWeight.w500,                              color: context.colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildLuminaryRecap(bool reducedMotion) {
    final emblems = <String>[
      _phaseEmblem(1), _phaseEmblem(2), _phaseEmblem(3),
      _phaseEmblem(4), _phaseEmblem(5), _phaseEmblem(6),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: emblems
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(e, style: const TextStyle(fontSize: 28)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '${context.l10n.luminaryLine1}\n${context.l10n.luminaryLine2}\n${context.l10n.luminaryLine3}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: DesignTokens.fontMd2,
              fontWeight: FontWeight.w600,                              color: context.colorScheme.onPrimary.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.masterLevel,
            style: TextStyle(
              fontSize: DesignTokens.font3xl,
              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Particle overlay that renders falling themed particles.
class _ParticleOverlay extends StatefulWidget {
  const _ParticleOverlay({
    required this.icon,
    required this.color,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final int count;

  @override
  State<_ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<_ParticleOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final _particles = <_Particle>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final rng = Random(42); // Seeded for consistency
    for (var i = 0; i < widget.count; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        size: 14 + rng.nextDouble() * 20,
        delay: rng.nextDouble() * 0.5, // Stagger start within 0.5s
        speed: 0.6 + rng.nextDouble() * 0.8, // Fall speed variance
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 2, // Spin speed
        opacity: 0.4 + rng.nextDouble() * 0.6,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              icon: widget.icon,
              color: widget.color,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double size;
  final double delay;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double opacity;

  const _Particle({
    required this.x,
    required this.size,
    required this.delay,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.icon,
    required this.color,
    required this.progress,
  });

  final List<_Particle> particles;
  final IconData icon;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Staggered start: each particle begins after its delay
      final localProgress = ((progress - p.delay) / p.speed).clamp(0.0, 1.1);
      if (localProgress <= 0) continue;

      // Y position: falls from top to ~10% past bottom
      final y = size.height * localProgress - p.size;
      // Horizon fall disappears slightly
      final fadeOut = localProgress > 1.0 ? (2.0 - localProgress).clamp(0.0, 1.0) : 1.0;
      final alpha = (p.opacity * fadeOut).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(p.x * size.width, y);
      canvas.rotate(p.rotation + p.rotationSpeed * localProgress * pi * 2);

      // Paint a small filled circle (particle) with glow
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        const Offset(0, 0),
        p.size / 3,
        paint,
      );

      // Glow ring
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        const Offset(0, 0),
        p.size / 2,
        glowPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}