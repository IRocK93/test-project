import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A widget that centers its child vertically within the available space.
///
/// When placed inside a [SliverFillRemaining] (bounded height), it fills
/// the remaining space and centers the child. When placed inside a
/// scrollable parent (unbounded height), it simply centers the child
/// without constraining height, avoiding the "BoxConstraints forces an
/// infinite height" error that [LayoutBuilder] + [ConstrainedBox] would cause.
///
/// This is useful for empty states, coming-soon screens, and any widget
/// that should be vertically centered regardless of its parent context.
class SliverFillCentered extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SliverFillCentered({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.space3xl),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // When inside a scrollable parent (infinite height), just center
        // the content without constraining height.
        if (!constraints.hasBoundedHeight) {
          return Padding(
            padding: padding,
            child: Center(child: child),
          );
        }

        // When given bounded height (e.g. inside SliverFillRemaining),
        // fill and center the remaining space.
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
