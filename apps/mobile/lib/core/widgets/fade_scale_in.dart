import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A reusable entrance animation widget that fades in and scales up its child.
///
/// Wraps the [child] in a [TweenAnimationBuilder] that animates from
/// invisible/small (opacity 0, scale [fadeScaleInBegin]) to visible/full-size
/// (opacity 1, scale 1.0) over [duration] using [curve].
///
/// Defaults: [DesignTokens.durationEntrance], [DesignTokens.curveEntrance] —
/// a subtle but noticeable entrance. Pass [delay] to stagger multiple
/// entries (e.g., in a list).
class FadeScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Duration? delay;

  const FadeScaleIn({
    super.key,
    required this.child,
    this.duration = DesignTokens.durationEntrance,
    this.curve = DesignTokens.curveEntrance,
    this.delay,
  });

  @override
  State<FadeScaleIn> createState() => _FadeScaleInState();
}

class _FadeScaleInState extends State<FadeScaleIn> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    if (widget.delay != null) {
      _showAnimation = false;
      Future<void>.delayed(widget.delay!).then((_) {
        if (mounted) setState(() => _showAnimation = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAnimation) return const SizedBox.shrink();

    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: DesignTokens.fadeScaleInBegin +
                (1.0 - DesignTokens.fadeScaleInBegin) * value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
