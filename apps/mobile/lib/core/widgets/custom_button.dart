import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'theme_button.dart';

/// A convenience wrapper around [ThemeButton] that provides a simpler API
/// with `isOutlined` boolean instead of the [ThemeButtonVariant] enum.
///
/// **Deprecated:** Use [ThemeButton] directly instead. This wrapper exists only
/// as a migration layer and will be removed in a future version.
///
/// This widget delegates all rendering to [ThemeButton], so it benefits
/// from theme-aware color resolution, dark-mode support, and accessibility
/// features like [Semantics] and [HapticFeedback].
///
/// Prefer using [ThemeButton] directly for new code — it offers more
/// control with [ThemeButtonVariant.filled], [.outlined], and [.text],
/// plus [icon], [trailingIcon], [fullWidth], [isDisabled], [borderRadius],
/// [semanticLabel], and other premium features.
///
/// ## Usage
/// ```dart
/// // Filled (default)
/// CustomButton(
///   text: 'Save',
///   onPressed: _save,
///   isLoading: isSaving,
/// )
///
/// // Outlined
/// CustomButton(
///   text: 'Cancel',
///   onPressed: _cancel,
///   isOutlined: true,
/// )
///
/// // With icon
/// CustomButton(
///   text: 'Add',
///   onPressed: _add,
///   icon: PhosphorIconsLight.plus,
/// )
/// ```
@Deprecated('Use ThemeButton directly instead of CustomButton')
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final button = ThemeButton(
      text: text,
      onPressed: onPressed,
      // ThemeButton handles disabled state internally when isLoading is true
      isLoading: isLoading,
      variant: isOutlined ? ThemeButtonVariant.outlined : ThemeButtonVariant.filled,
      fullWidth: width == null,
      icon: icon,
      height: height ?? 48,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      borderRadius: DesignTokens.radiusMd,
    );

    // If a specific width is given, apply it; otherwise the button is already fullWidth
    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
