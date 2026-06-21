import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/fade_scale_in.dart';

/// A single FAB sub-action with an info tooltip call-out.
///
/// Shows a [tooltip] on long-press or when a small info icon is tapped.
/// Wraps the [child] in a [ScalePress]-like animation.
class InfoFabAction extends StatelessWidget {
  final Widget child;
  final String tooltip;
  final String? infoDescription;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final double size;

  /// Optional callback invoked after [onTap] — used by the overlay to
  /// collapse the radial menu once a sub-action has been triggered.
  final VoidCallback? onClose;

  const InfoFabAction({
    super.key,
    required this.child,
    required this.tooltip,
    this.infoDescription,
    required this.onTap,
    this.backgroundColor,
    this.size = 40,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── The actual FAB action button ──
        Semantics(
          label: tooltip,
          button: true,
          child: FloatingActionButton.small(
            heroTag: 'fab_action_${tooltip.hashCode}',
            backgroundColor: backgroundColor ?? context.colorScheme.primary,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onTap();
              onClose?.call();
            },
            child: child,
          ),
        ),
      ],
    );
  }
}

/// The info-description pill for a radial action, shown inline inside the overlay.
class _ActionLabel extends StatelessWidget {
  final String text;
  final double opacity;

  const _ActionLabel({required this.text, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

/// A primary FAB that opens a radial menu overlay.
///
/// When tapped, the FAB animates upward from its bottom-right position
/// to the center of a circle, and sub-actions fan out around it with
/// staggered staggered animations. An info-description pill appears
/// above each sub-action.
class InfoFab extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final IconData closeIcon;
  final Color? backgroundColor;
  final List<InfoFabAction> children;

  const InfoFab({
    super.key,
    required this.tooltip,
    this.icon = PhosphorIconsLight.plus,
    this.closeIcon = PhosphorIconsLight.x,
    this.backgroundColor,
    required this.children,
  });

  @override
  State<InfoFab> createState() => _InfoFabState();
}

class _InfoFabState extends State<InfoFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _rotateAnim;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: DesignTokens.durationNormal,
    );
    _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animController,
        curve: DesignTokens.curvePremium,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_isOpen) {
      _closeRadial();
    } else {
      _openRadial();
    }
  }

  void _openRadial() {
    HapticFeedback.mediumImpact();
    // Capture the FAB's screen position before opening
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      setState(() => _isOpen = true);
      _animController.forward();
      return;
    }
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final originCenter = Offset(
      offset.dx + size.width / 2,
      offset.dy + size.height / 2,
    );

    setState(() => _isOpen = true);
    _animController.forward();

    _overlayEntry = OverlayEntry(
      builder: (_) => _RadialMenuOverlay(
        originCenter: originCenter,
        backgroundColor: widget.backgroundColor ?? context.colorScheme.primary,
        closeIcon: widget.closeIcon,
        children: widget.children,
        onClose: () {
          if (mounted) {
            _animController.reverse();
            _removeOverlay();
            setState(() => _isOpen = false);
          }
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeRadial() {
    HapticFeedback.mediumImpact();
    _animController.reverse();
    _removeOverlay();
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeScaleIn(
      child: Semantics(
        label: widget.tooltip,
        button: true,
        child: FloatingActionButton(
          heroTag: 'fab_${widget.hashCode}',
          backgroundColor: widget.backgroundColor ?? context.colorScheme.primary,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _rotateAnim,
            builder: (context, child) => Transform.rotate(
              angle: _rotateAnim.value * math.pi,
              child: Icon(_isOpen ? widget.closeIcon : widget.icon),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
///  Radial Menu Overlay
/// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen overlay that renders the radial action menu.
///
/// The FAB stays at its original [originCenter] position (bottom-right).
/// Sub-actions fan out in a semi-circle (180°) above and to the left,
/// keeping everything confined to the bottom-right area of the screen.
class _RadialMenuOverlay extends StatefulWidget {
  final Offset originCenter;
  final Color backgroundColor;
  final IconData closeIcon;
  final List<InfoFabAction> children;
  final VoidCallback onClose;

  const _RadialMenuOverlay({
    required this.originCenter,
    required this.backgroundColor,
    required this.closeIcon,
    required this.children,
    required this.onClose,
  });

  @override
  State<_RadialMenuOverlay> createState() => _RadialMenuOverlayState();
}

class _RadialMenuOverlayState extends State<_RadialMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scrimAnim;
  late List<_ActionAnimConfig> _actionAnims;
  bool _isForward = true;

  // ── Animation constants ──
  // Radius for action placement. 140px gives ample spacing without pushing
  // items into screen edges. Fixed 80° quadrant arc with 5° padding at each
  // end to prevent clipping at the display boundaries.
  static const double _circleRadius = 140.0;
  static const double _fabSize = 56.0;
  static const double _actionSize = 48.0;

  /// Returns arc bounds — 80° span with 5° edge padding inside the quadrant.
  /// This prevents the topmost item from clipping against the right display
  /// edge while keeping generous spacing between actions.
  static (double, double) _arcRange(int count) {
    const span = math.pi * 4 / 9;                // 80°
    const center = -3 * math.pi / 4;             // midway between left (-π) and up (-π/2) = -135°
    return (center - span / 2, center + span / 2);
  }

  @override
  void initState() {
    super.initState();

    // Slower, more deliberate animation (800ms vs 750ms)
    // Wider radius means actions travel further, so we give more time.
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationXslow,
    );

    _scrimAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    final count = widget.children.length;
    final (arcStart, arcEnd) = _arcRange(count);
    _actionAnims = List.generate(count, (i) {
      // Longer stagger for deliberate feel — wider gap between actions
      final stagger = 0.10 + i * 0.12;
      final totalSpan = arcEnd - arcStart;
      final angle = arcStart +
          (i / math.max(count - 1, 1)) * totalSpan;
      return _ActionAnimConfig(
        interval: Interval(
          stagger,
          (stagger + 0.30).clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
        angle: angle,
      );
    });

    // Guide ring haptic at t~0.2
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        void checkValue() {
          if (_controller.value >= 0.2 &&
              _controller.value < 0.25 &&
              _isForward) {
            HapticFeedback.lightImpact();
            _controller.removeListener(checkValue);
          }
        }
        _controller.addListener(checkValue);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.originCenter;
    final count = widget.children.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── 1. Scrim (backdrop) ──
          Positioned.fill(
            child: FadeTransition(
              opacity: _scrimAnim,
              child: Semantics(
                label: 'Close menu',
                button: true,
                child: GestureDetector(
                onTap: _animateClose,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          ),

          // ── 2. Pulse ring around the FAB (guide) ──
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final guideT = (_controller.value - 0.2) / 0.25;
              if (guideT <= 0.0) return const SizedBox.shrink();
              final guideO = guideT.clamp(0.0, 1.0) *
                  (1.0 - guideT.clamp(0.0, 1.0)) * 4;
              return Positioned(
                left: origin.dx - _circleRadius - 12,
                top: origin.dy - _circleRadius - 12,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (guideO * 0.4).clamp(0.0, 0.2),
                    child: Container(
                      width: (_circleRadius + 12) * 2,
                      height: (_circleRadius + 12) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── 3. Sub-actions in a semi-circle fan ──
          ...List.generate(count, (i) {
            final rawAction = widget.children[i];
            // Wrap each child so the overlay collapses after its tap.
            final action = InfoFabAction(
              tooltip: rawAction.tooltip,
              infoDescription: rawAction.infoDescription,
              onTap: rawAction.onTap,
              backgroundColor: rawAction.backgroundColor,
              size: rawAction.size,
              onClose: () => _animateClose(lightHaptic: true),
              child: rawAction.child,
            );
            final animCfg = _actionAnims[i];
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final rawT = (_controller.value - animCfg.interval.begin) /
                    (animCfg.interval.end - animCfg.interval.begin);
                final t = rawT.clamp(0.0, 1.0);
                final eased = Curves.easeOutBack.transform(t);
                const half = _actionSize / 2;

                final x = origin.dx +
                    math.cos(animCfg.angle) * _circleRadius * eased;
                final y = origin.dy +
                    math.sin(animCfg.angle) * _circleRadius * eased;

                // Label pill below each action button.
                return Positioned(
                  left: x - half,
                  top: y - half,
                  child: Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.3 + 0.7 * eased,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          action,
                          if (action.infoDescription != null) ...[
                            const SizedBox(height: 8),
                            _ActionLabel(
                              text: action.infoDescription!,
                              opacity: 1.0,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // ── 4. Main FAB stays at origin (no fly animation) ──
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Subtle scale pulse when open
              final pulse = 1.0 + math.sin(_controller.value * math.pi) * 0.04;
              const half = _fabSize / 2;
              return Positioned(
                left: origin.dx - half,
                top: origin.dy - half,
                child: Transform.scale(
                  scale: pulse,
                  child: FloatingActionButton(
                    heroTag: 'radial_fab',
                    backgroundColor: widget.backgroundColor,
                    onPressed: _animateClose,
                    child: Transform.rotate(
                      angle: _controller.value * math.pi,
                      child: Icon(widget.closeIcon),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _animateClose({bool lightHaptic = false}) {
    if (_controller.status == AnimationStatus.reverse) return;
    _isForward = false;
    if (lightHaptic) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    _controller.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Supporting classes
// ═════════════════════════════════════════════════════════════════════════════

/// Configuration for each action's animation: the angle on the circle
/// and the staggered time interval.
class _ActionAnimConfig {
  final Interval interval;
  final double angle;

  const _ActionAnimConfig({required this.interval, required this.angle});
}
