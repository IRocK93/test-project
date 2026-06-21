import 'package:flutter/material.dart';

/// Extension on [BuildContext] to get theme-aware text colors.
///
/// These helpers resolve to [colorScheme.onSurface] in both light and dark
/// modes, ensuring text maintains proper contrast against surface backgrounds.
///
/// ## Usage
/// ```dart
/// // Instead of:
/// Text('Hello', style: TextStyle(color: colorScheme.onSurface))
///
/// // Use:
/// Text('Hello', style: TextStyle(color: context.textPrimary))
///
/// // Or use the theme's text style directly (preferred):
/// Text('Hello', style: Theme.of(context).textTheme.bodyMedium)
/// ```
extension ThemeTextColor on BuildContext {
  /// Primary text color — resolves to [colorScheme.onSurface].
  Color get textPrimary => Theme.of(this).colorScheme.onSurface;

  /// Secondary text color — resolves to [colorScheme.onSurfaceVariant].
  Color get textSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Caption/muted text color — [colorScheme.onSurfaceVariant] at 70% opacity.
  Color get textCaption =>
      Theme.of(this).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
}
