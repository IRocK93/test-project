import 'package:flutter/material.dart';

/// Wraps a child widget and reports whether its content has been scrolled
/// past a configurable [threshold] (default: 10px).
///
/// Calls [onScrolledChanged] whenever the scroll state transitions so the
/// parent can react without excessive rebuilds during continuous scrolling.
class ScrollAware extends StatelessWidget {
  /// The widget to observe for scroll notifications.
  final Widget child;

  /// Called with `true` when the child scrolls past [threshold],
  /// and with `false` when it returns to the top.
  final ValueChanged<bool> onScrolledChanged;

  /// The pixel offset past which the child is considered "scrolled".
  final double threshold;

  const ScrollAware({
    super.key,
    required this.child,
    required this.onScrolledChanged,
    this.threshold = 10,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final isScrolled = notification.metrics.pixels > threshold;
        onScrolledChanged(isScrolled);
        return false; // don't consume
      },
      child: child,
    );
  }
}
