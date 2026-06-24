import 'package:flutter/material.dart';

/// Responsive breakpoint helper — provides consistent layout adaptation
/// across phone portrait, phone landscape, and tablet.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Widget? landscapeLayout;
  final bool scrollable;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.landscapeLayout,
    this.scrollable = true,
  });

  /// Returns true if the screen is wide enough for tablet/multi-column layout
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  /// Returns true if the device is in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Returns adaptive column count for grid layouts
  static int adaptiveColumnCount(BuildContext context, {int phone = 2, int tablet = 3, int desktop = 4}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return desktop;
    if (width >= 600) return tablet;
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    if (landscapeLayout != null && isLandscape(context)) {
      return scrollable
          ? SingleChildScrollView(child: landscapeLayout!)
          : landscapeLayout!;
    }
    return scrollable
        ? SingleChildScrollView(child: child)
        : child;
  }
}
