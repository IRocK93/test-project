import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class StaggeredFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? duration;
  final double offset;
  final Curve? curve;

  const StaggeredFadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.duration,
    this.offset = 20.0,
    this.curve,
  });

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _translate;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? DesignTokens.durationEntrance,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: DesignTokens.curvePremium),
      ),
    );

    _translate = Tween<Offset>(
      begin: const Offset(0, DesignTokens.slideUpOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: DesignTokens.curvePremium),
      ),
    );

    _delayTimer = Timer(
      Duration(milliseconds: widget.index * DesignTokens.staggerDelayMs),
      () {
        if (mounted) {
          setState(() {});
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translate.value.dy),
          child: child,
        ),
      ),
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class ScrollStagger extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? duration;

  const ScrollStagger({
    super.key,
    required this.child,
    required this.index,
    this.duration,
  });

  @override
  State<ScrollStagger> createState() => _ScrollStaggerState();
}

class _ScrollStaggerState extends State<ScrollStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translate;
  bool _hasAnimated = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? DesignTokens.durationEntrance,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: DesignTokens.curvePremium),
      ),
    );

    _translate = Tween<double>(
      begin: DesignTokens.slideUpOffset,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: DesignTokens.curvePremium),
      ),
    );
  }

  Timer? _fallbackTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    if (_scrollPosition != null) {
      if (!_hasAnimated) _scrollPosition!.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onScroll();
      });
    } else if (!_hasAnimated) {
      _fallbackTimer = Timer(
        Duration(milliseconds: widget.index * DesignTokens.staggerDelayMs),
        () {
          if (mounted) {
            setState(() {
              _hasAnimated = true;
            });
            _controller.forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _fallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_hasAnimated || !mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;

    if (position.dy < viewportHeight * 1.15) {
      setState(() {
        _hasAnimated = true;
      });
      _scrollPosition?.removeListener(_onScroll);
      final delay = widget.index * DesignTokens.staggerDelayMs;
      if (delay > 0) {
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted) _controller.forward();
        });
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }
    if (!_hasAnimated) {
      return Opacity(
        opacity: 0.0,
        child: Transform.translate(
          offset: const Offset(0, DesignTokens.slideUpOffset),
          child: RepaintBoundary(child: widget.child),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _translate.value),
          child: child,
        ),
      ),
      child: RepaintBoundary(child: widget.child),
    );
  }
}

class ScalePress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleAmount;
  final Duration? pressDuration;
  final Duration? releaseDuration;
  final double magneticOffset;
  final double magneticAngle;

  const ScalePress({
    super.key,
    required this.child,
    this.onTap,
    this.scaleAmount = 0.96,
    this.pressDuration,
    this.releaseDuration,
    this.magneticOffset = 2.5,
    this.magneticAngle = 0.7854,
  });

  @override
  State<ScalePress> createState() => _ScalePressState();
}

class _ScalePressState extends State<ScalePress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _translateX;
  late final Animation<double> _translateY;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressDuration ?? const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 1.0, end: widget.scaleAmount).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curvePremium,
      ),
    );

    final dx = widget.magneticOffset * math.cos(widget.magneticAngle);
    final dy = widget.magneticOffset * math.sin(widget.magneticAngle);

    _translateX = Tween<double>(begin: 0.0, end: dx).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curvePremium,
      ),
    );

    _translateY = Tween<double>(begin: 0.0, end: dy).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DesignTokens.curvePremium,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _isPressed = true;
    _controller.duration = widget.pressDuration ?? const Duration(milliseconds: 200);
    _controller.forward();
  }

  void _onTapUp(_) {
    _isPressed = false;
    if (widget.releaseDuration != null) {
      _controller.duration = widget.releaseDuration;
    }
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      if (widget.releaseDuration != null) {
        _controller.duration = widget.releaseDuration;
      }
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(_scale.value, _scale.value, _scale.value)
            ..setTranslationRaw(_translateX.value, _translateY.value, 0),
          child: child,
        ),
        child: RepaintBoundary(child: widget.child),
      ),
    );
  }
}
