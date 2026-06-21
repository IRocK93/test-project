import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import 'button_loading.dart';

/// A premium, theme-aware button that auto-resolves background and foreground
/// colors based on the current theme brightness.
///
/// ## Variants
/// - [ThemeButtonVariant.filled] — solid background (default). Dark mode uses
///   [colorScheme.primary] so foreground text (dark) remains readable.
/// - [ThemeButtonVariant.outlined] — transparent background with border.
/// - [ThemeButtonVariant.text] — no background, no border, just text/icon.
///
/// ## Usage
/// ```dart
/// // Default filled button
/// ThemeButton(
///   text: 'Save',
///   onPressed: _save,
/// )
///
/// // Outlined with icon and loading state
/// ThemeButton(
///   text: 'Submit',
///   onPressed: isLoading ? null : _submit,
///   variant: ThemeButtonVariant.outlined,
///   icon: PhosphorIconsLight.check,
///   isLoading: isLoading,
/// )
///
/// // Full-width text button
/// ThemeButton(
///   text: 'Cancel',
///   variant: ThemeButtonVariant.text,
///   fullWidth: true,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class ThemeButton extends StatelessWidget {
  /// Creates a text-based button (default).
  const ThemeButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ThemeButtonVariant.filled,
    this.fullWidth = false,
    this.icon,
    this.trailingIcon,
    this.iconSize = DesignTokens.iconMd,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isDisabled = false,
    this.loadingColor,
    this.semanticLabel,
    this.autofocus = false,
    this.tooltip,
    this.focusNode,
  }) : _iconOnly = false,
       _iconData = null;

  /// Creates an icon-only themed button.
  ///
  /// Renders a circular button with the given icon, color-resolved per theme.
  /// Use for toolbar actions, navigation, and compact controls.
  ///
  /// ```dart
  /// ThemeButton.icon(
  ///   icon: PhosphorIconsLight.heart,
  ///   onPressed: _onFavorite,
  ///   tooltip: 'Add to favorites',
  /// )
  /// ```
  const ThemeButton.icon({
    super.key,
    required IconData icon,
    this.onPressed,
    this.iconSize = DesignTokens.iconMd,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.variant = ThemeButtonVariant.filled,
    this.isDisabled = false,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    this.loadingColor,
  }) : text = '',
       _iconOnly = true,
       _iconData = icon,
       isLoading = false,
       fullWidth = false,
       icon = null,
       trailingIcon = null,
       fontSize = 15,
       fontWeight = FontWeight.w600,
       height = 48,
       padding = null,
       borderRadius = null;

  /// Button label text.
  final String text;

  /// Whether this is an icon-only button.
  final bool _iconOnly;

  /// The icon data for icon-only mode.
  final IconData? _iconData;

  /// Tooltip for icon-only buttons. Only used with [ThemeButton.icon].
  final String? tooltip;

  /// Icon size for icon-only buttons. Default 24. Only used with [ThemeButton.icon].
  final double iconSize;

  /// Callback when the button is tapped. Set to `null` to disable.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of the label.
  final bool isLoading;

  /// Visual variant — defaults to [ThemeButtonVariant.filled].
  final ThemeButtonVariant variant;

  /// When `true`, stretches the button to fill its parent width.
  final bool fullWidth;

  /// Optional icon placed before the label.
  final IconData? icon;

  /// Optional icon placed after the label (for "button-in-button" patterns).
  final IconData? trailingIcon;

  /// Optional custom background color (overrides theme-aware default).
  final Color? backgroundColor;

  /// Optional custom foreground/text color (overrides theme-aware default).
  final Color? foregroundColor;

  /// Text size for the label. Default 15.
  final double fontSize;

  /// Font weight for the label. Default [FontWeight.w600].
  final FontWeight fontWeight;

  /// Button height. Default 48.
  final double height;

  /// Padding inside the button. Defaults to 16 horizontal, 12 vertical.
  final EdgeInsetsGeometry? padding;

  /// Border radius. Defaults to [DesignTokens.radiusMd] (12).
  final double? borderRadius;

  /// When `true`, the button appears as disabled without changing `onPressed`.
  /// Useful for states like "Current plan" where the button shouldn't be tappable
  /// but still looks intentionally inactive.
  final bool isDisabled;

  /// Optional semantic label for the loading spinner color.
  /// Defaults to [foregroundColor] or the resolved foreground.
  final Color? loadingColor;

  /// A semantic label for accessibility (screen readers).
  final String? semanticLabel;

  /// Whether this button should focus itself if nothing else is focused.
  final bool autofocus;

  /// An optional focus node for programmatic focus management.
  final FocusNode? focusNode;


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Resolve colors based on variant and theme ──
    // If a custom color is given, use it; otherwise derive from variant + theme.
    final Color bgColor;
    final Color fgColor;
    final Color disabledBgColor;
    final Color disabledFgColor;
    final Color borderColor;
    final Color disabledBorderColor;

    switch (variant) {
      case ThemeButtonVariant.filled:
        bgColor = backgroundColor ??
            (isDark ? context.colorScheme.primary : context.colorScheme.primary);
        fgColor = foregroundColor ??
            (isDark ? context.colorScheme.onSurface : context.colorScheme.onPrimary);
        disabledBgColor =
            (isDark ? context.colorScheme.primary : context.colorScheme.onSurface.withValues(alpha: 0.38))
                .withValues(alpha: 0.4);
        disabledFgColor = (isDark ? context.colorScheme.onSurface : context.colorScheme.onPrimary)
            .withValues(alpha: 0.4);
        borderColor = Colors.transparent;
        disabledBorderColor = Colors.transparent;
      case ThemeButtonVariant.outlined:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = foregroundColor ??
            (isDark ? context.colorScheme.primary : context.colorScheme.primary);
        disabledBgColor = Colors.transparent;
        disabledFgColor =
            (isDark ? context.colorScheme.primary : context.colorScheme.primary)
                .withValues(alpha: 0.4);
        borderColor = fgColor;
        disabledBorderColor = fgColor.withValues(alpha: 0.25);
      case ThemeButtonVariant.text:
        bgColor = backgroundColor ?? Colors.transparent;
        fgColor = foregroundColor ??
            (isDark ? context.colorScheme.primary : context.colorScheme.primary);
        disabledBgColor = Colors.transparent;
        disabledFgColor =
            (isDark ? context.colorScheme.primary : context.colorScheme.primary)
                .withValues(alpha: 0.4);
        borderColor = Colors.transparent;
        disabledBorderColor = Colors.transparent;
    }

    final isEffectivelyDisabled = isDisabled || onPressed == null || isLoading;

    final effectiveBg = isEffectivelyDisabled ? disabledBgColor : bgColor;
    final effectiveFg = isEffectivelyDisabled ? disabledFgColor : fgColor;
    final effectiveBorder =
        isEffectivelyDisabled ? disabledBorderColor : borderColor;

    final radius = borderRadius ?? DesignTokens.radiusMd;
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        );

    if (_iconOnly) {
      return _buildIconButton(effectiveBg, effectiveFg, radius, isEffectivelyDisabled);
    }

    final textDirection = Directionality.of(context);

    final Widget buttonContent;
    if (isLoading) {
      buttonContent = ButtonLoading(
        color: loadingColor ?? effectiveFg,
      );
    } else if (icon != null || trailingIcon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          if (icon != null) Icon(icon, size: 18),
          if (icon != null) const SizedBox(width: DesignTokens.spaceSm),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          if (trailingIcon != null) const SizedBox(width: DesignTokens.spaceSm),
          if (trailingIcon != null) _trailingIconWidget(effectiveFg),
        ],
      );
    } else {
      buttonContent = Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    }

    final Widget button = SizedBox(
      height: height,
      child: Material(
        key: const ValueKey('theme_button_material'),
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
          onTap: isEffectivelyDisabled
              ? null
              : () {
                  onPressed!();
                  HapticFeedback.lightImpact();
                },
          borderRadius: BorderRadius.circular(radius),
          splashColor: effectiveFg.withValues(alpha: 0.12),
          highlightColor: effectiveFg.withValues(alpha: 0.06),
          focusNode: focusNode,
          autofocus: autofocus,
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: effectiveBorder),
            ),
            alignment: Alignment.center,
            child: Semantics(
              label: semanticLabel,
              enabled: !isEffectivelyDisabled,
              button: true,
              child: DefaultTextStyle(
                key: const ValueKey('theme_button_text_style'),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: effectiveFg,
                ),
                child: AnimatedSwitcher(
                  duration: DesignTokens.durationFast,
                  child: buttonContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // If fullWidth, wrap in SizedBox; otherwise use intrinsic size
    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Widget _trailingIconWidget(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Icon(trailingIcon, size: 14, color: color),
    );
  }

  Widget _buildIconButton(Color bgColor, Color fgColor, double radius, bool disabled) {
    final buttonSize = iconSize + 16;
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        surfaceTintColor: Colors.transparent,
        child: InkWell(
            onTap: disabled
                ? null
                : () {
                    onPressed!();
                    HapticFeedback.lightImpact();
                  },
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            splashColor: fgColor.withValues(alpha: 0.12),
            highlightColor: fgColor.withValues(alpha: 0.06),
            focusNode: focusNode,
            autofocus: autofocus,
            child: Semantics(
              label: semanticLabel ?? tooltip,
              enabled: !disabled,
              button: true,
              child: Icon(_iconData, size: iconSize, color: fgColor),
            ),
          ),
        ),
      );
  }
}

/// Visual variants for [ThemeButton].
enum ThemeButtonVariant {
  /// Solid background — most prominent action.
  filled,

  /// Transparent background with border — secondary action.
  outlined,

  /// No background or border — tertiary action.
  text,
}

/// Static utility class for theme-aware button helpers.
///
/// Provides methods to get theme-resolved colors and build themed InkWell
/// wrappers for custom use cases.
class ThemeButtonStyle {
  ThemeButtonStyle._();

  /// Resolves the background color for a given [variant] and [isDark] state.
  /// Respects [customColor] if provided.
  static Color resolveBackground({
    required ThemeButtonVariant variant,
    required bool isDark,
    Color? customColor,
  }) {
    switch (variant) {
      case ThemeButtonVariant.filled:
        return customColor ?? (isDark ? const Color(0xFFA29BFE) : const Color(0xFF7C5CFC));
      case ThemeButtonVariant.outlined:
      case ThemeButtonVariant.text:
        return customColor ?? Colors.transparent;
    }
  }

  /// Resolves the foreground color for a given [variant] and [isDark] state.
  /// Respects [customColor] if provided.
  static Color resolveForeground({
    required ThemeButtonVariant variant,
    required bool isDark,
    Color? customColor,
  }) {
    switch (variant) {
      case ThemeButtonVariant.filled:
        return customColor ?? (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF));
      case ThemeButtonVariant.outlined:
      case ThemeButtonVariant.text:
        return customColor ?? (isDark ? const Color(0xFFA29BFE) : const Color(0xFF7C5CFC));
    }
  }

  /// Wraps a [child] widget in an [InkWell] with theme-aware splash colors.
  ///
  /// Use this to add button-like tap feedback to arbitrary widgets while
  /// keeping the same ripple style as [ThemeButton].
  ///
  /// ```dart
  /// ThemeButtonStyle.inkWell(
  ///   context: context,
  ///   onTap: _handleTap,
  ///   borderRadius: 12,
  ///   child: MyWidget(),
  /// )
  /// ```
  static Widget inkWell({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
    double borderRadius = DesignTokens.radiusMd,
    Color? splashColor,
    Color? highlightColor,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? context.colorScheme.primary : context.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      splashColor: splashColor ?? baseColor.withValues(alpha: 0.12),
      highlightColor: highlightColor ?? baseColor.withValues(alpha: 0.06),
      focusNode: focusNode,
      autofocus: autofocus,
      child: child,
    );
  }

  /// Wraps a [child] widget in a [GestureDetector] with optional [onTap].
  ///
  /// Unlike [inkWell], this does not render a Material ripple — use for
  /// contexts where only a tap gesture is needed without visual feedback.
  static Widget gestureDetector({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Reusable ink well builder function for quick use in build methods.
///
/// This is a convenience function equivalent to [ThemeButtonStyle.inkWell]
/// but callable as a top-level function for brevity.
Widget themedInkWell({
  required BuildContext context,
  required Widget child,
  VoidCallback? onTap,
  double borderRadius = DesignTokens.radiusMd,
  Color? splashColor,
  Color? highlightColor,
  FocusNode? focusNode,
  bool autofocus = false,
}) {
  return ThemeButtonStyle.inkWell(
    context: context,
    child: child,
    onTap: onTap,
    borderRadius: borderRadius,
    splashColor: splashColor,
    highlightColor: highlightColor,
    focusNode: focusNode,
    autofocus: autofocus,
  );
}

/// Reusable gesture detector builder function for quick use in build methods.
///
/// This is a convenience function equivalent to [ThemeButtonStyle.gestureDetector]
/// but callable as a top-level function for brevity.
Widget themedGestureDetector({
  required Widget child,
  VoidCallback? onTap,
  VoidCallback? onDoubleTap,
  VoidCallback? onLongPress,
}) {
  return ThemeButtonStyle.gestureDetector(
    child: child,
    onTap: onTap,
    onDoubleTap: onDoubleTap,
    onLongPress: onLongPress,
  );
}
