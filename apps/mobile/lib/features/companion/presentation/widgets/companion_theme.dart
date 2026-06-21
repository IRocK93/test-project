import 'package:flutter/material.dart';

/// Theme-aware color resolution for the companion feature.
/// Uses ColorScheme tokens so colors adapt to the active theme (Glass or Clay)
/// and work correctly in both light and dark modes.
extension CompanionTheme on BuildContext {
  /// Secondary text — resolves correctly in both light and dark modes.
  Color get textSecondary => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Caption/muted text.
  Color get textCaption => Theme.of(this).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

  /// Surface color for cards — uses theme surface.
  Color get cardSurface => Theme.of(this).colorScheme.surface;

  /// Subtle border color for cards.
  Color get cardBorder => textSecondary.withValues(alpha: 0.1);
}
