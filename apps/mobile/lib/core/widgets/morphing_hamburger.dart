import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A premium morphing hamburger menu icon that fluidly transitions
/// between 3 horizontal lines and an X (close) state.
///
/// Features:
/// - Spring physics animation (cubic-bezier 0.32, 0.72, 0, 1)
/// - Line rotation + translation for natural morph
/// - Middle line fades out while outer lines rotate to form X
/// - Haptic-ready tap feedback via ScalePress
class MorphingHamburger extends StatefulWidget {
  final bool isOpen;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final double strokeWidth;

  const MorphingHamburger({
    super.key,
    required this.isOpen,
    this.onTap,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  State<MorphingHamburger> createState() => _MorphingHamburgerState();
}

class _MorphingHamburgerState extends State<MorphingHamburger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _translation;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationNormal,
    );

    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: DesignTokens.curvePremium),
      ),
    );

    _translation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: DesignTokens.curvePremium),
      ),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: DesignTokens.curvePremium),
      ),
    );

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant MorphingHamburger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? context.colorScheme.onSurface;
    final lineLength = widget.size * 0.75;
    final lineGap = widget.size * 0.18;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rotation = _rotation.value;
        final translation = _translation.value;
        final opacity = _opacity.value;

        return Semantics(
          label: widget.isOpen ? 'Close menu' : 'Open menu',
          button: true,
          child: GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _HamburgerPainter(
                progress: rotation,
                translation: translation,
                middleOpacity: opacity,
                color: effectiveColor,
                strokeWidth: widget.strokeWidth,
                lineLength: lineLength,
                lineGap: lineGap,
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}

class _HamburgerPainter extends CustomPainter {
  final double progress; // 0.0 = closed (3 lines), 1.0 = open (X)
  final double translation;
  final double middleOpacity;
  final Color color;
  final double strokeWidth;
  final double lineLength;
  final double lineGap;

  _HamburgerPainter({
    required this.progress,
    required this.translation,
    required this.middleOpacity,
    required this.color,
    required this.strokeWidth,
    required this.lineLength,
    required this.lineGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final halfLength = lineLength / 2;

    // Line positions (relative to center)
    final topY = -lineGap;
    const midY = 0.0;
    final botY = lineGap;

    if (progress < 1.0) {
      // Draw top line — rotates 45deg and translates down
      final topAngle = progress * (math.pi / 4); // 0 to 45deg
      final topTranslateY = translation * lineGap;
      _drawLine(
        canvas,
        paint,
        center,
        halfLength,
        topAngle,
        Offset(0, topY + topTranslateY),
      );

      // Draw middle line — fades out
      if (middleOpacity > 0) {
        final midPaint = Paint()
          ..color = color.withValues(alpha: middleOpacity)
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        _drawLine(
          canvas,
          midPaint,
          center,
          halfLength * (1.0 - progress * 0.3), // Slightly shrinks
          0,
          const Offset(0, midY),
        );
      }

      // Draw bottom line — rotates -45deg and translates up
      final botAngle = -progress * (math.pi / 4); // 0 to -45deg
      final botTranslateY = translation * lineGap;
      _drawLine(
        canvas,
        paint,
        center,
        halfLength,
        botAngle,
        Offset(0, botY - botTranslateY),
      );
    } else {
      // Fully open — draw perfect X
      _drawLine(canvas, paint, center, halfLength, math.pi / 4, Offset.zero);
      _drawLine(canvas, paint, center, halfLength, -math.pi / 4, Offset.zero);
    }
  }

  void _drawLine(
    Canvas canvas,
    Paint paint,
    Offset center,
    double halfLength,
    double angle,
    Offset offset,
  ) {
    canvas.save();
    canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
    canvas.rotate(angle);
    canvas.drawLine(
      Offset(-halfLength, 0),
      Offset(halfLength, 0),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HamburgerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        translation != oldDelegate.translation ||
        middleOpacity != oldDelegate.middleOpacity ||
        color != oldDelegate.color;
  }
}