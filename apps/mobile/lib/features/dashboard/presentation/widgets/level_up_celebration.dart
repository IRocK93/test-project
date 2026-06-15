import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baby_mon/core/constants/constants.dart';

/// All 50 level names from the BabyMon Bloom Journey.
const Map<int, String> _levelNames = {
  1: 'Little Seed',
  2: 'Tiny Gripper',
  3: 'Sleep Sprout',
  4: 'Gaze Keeper',
  5: 'Dewdrop',
  6: 'Burble Bud',
  7: 'Smile Weaver',
  8: 'Neck Knight',
  9: 'Tummy Roller',
  10: 'Giggle Pod',
  11: 'Reach Star',
  12: 'Babble Scholar',
  13: 'Sitter Supreme',
  14: 'Taste Adventurer',
  15: 'Scoot Scout',
  16: 'Cruiser Cadet',
  17: 'Wave Wizard',
  18: 'Pincer Prince/ss',
  19: 'Stack Master',
  20: 'Step Seeker',
  21: 'Word Hoarder',
  22: 'Melody Hummer',
  23: 'Puzzle Prodigy',
  24: 'Spoon Warrior',
  25: 'No-Sayer',
  26: 'Tower Climber',
  27: 'Scribble Sage',
  28: 'Dress Dancer',
  29: 'Question Storm',
  30: 'Story Dreamer',
  31: 'Count Keeper',
  32: 'Friend Finder',
  33: 'Brave Heart',
  34: 'Emotion Sage',
  35: 'Jump Master',
  36: 'Rhyme Weaver',
  37: 'Helper Hand',
  38: 'Joke Crafter',
  39: 'Memory Vault',
  40: 'Promise Keeper',
  41: 'Pattern Seer',
  42: 'Kindness Bloom',
  43: 'Peace Maker',
  44: 'Path Finder',
  45: 'Song Weaver',
  46: 'Wisdom Seed',
  47: 'Story Teller',
  48: 'Light Keeper',
  49: 'Trail Blazer',
  50: 'LUMINARY',
};

/// Phase descriptions for the 6 phases.
const Map<int, String> _phaseDescriptions = {
  1: 'Newborn cocoon — quiet, sacred, tiny miracles',
  2: 'Putting down roots — first sounds, first rolls',
  3: 'Vertical ambition — pulling up, cruising, first steps',
  4: 'Running, jumping, pretending — a personality blossoms',
  5: 'Confidence grows — empathy emerges, world expands',
  6: 'Final climb — bright, kind, curious, ready for the world',
};

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
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.3),
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
      duration: const Duration(milliseconds: 3500),
    );

    // Haptic feedback on entry
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

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
  String get _levelName => _levelNames[widget.level] ?? 'Level ${widget.level}';
  int get _phase => _phaseForLevel(widget.level);

  /// Particle type is based on the phase number:
  /// Phase 1-2: leaf (🍃), Phase 3-4: sparkle (✨), Phase 5-6: star (⭐)
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
      label: 'Level up! Your BabyMon is now $_levelName.',
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
                      child: Container(color: AppColors.darkBackground),
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
                            'Tap anywhere to continue',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
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
              const Text(
                '⚡',
                style: TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 2),
              Text(
                'Lv ${widget.level}',
                style: const TextStyle(
                  fontSize: 16,
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
              color: AppColors.textOnPrimary,
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
              '💧 Phase Milestone 💧',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF80DEEA).withValues(alpha: opacity.clamp(0.5, 1.0)),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _phaseDescriptions[_phase] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
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
          'Keep tracking — every moment counts!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,                              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildLuminaryRecap(bool reducedMotion) {
    const phases = ['🌰', '🌱', '🌿', '🌳', '🏔️', '✨'];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phase emblems in sequence
          Row(
            mainAxisSize: MainAxisSize.min,
            children: phases
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(e, style: const TextStyle(fontSize: 28)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'From a tiny seed to a shining soul.\n'
            'You\'ve guided every step.\n'
            'This is the work of an amazing parent.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,                              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '⭐⭐⭐',
            style: TextStyle(
              fontSize: 32,
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
    return AnimatedBuilder(
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