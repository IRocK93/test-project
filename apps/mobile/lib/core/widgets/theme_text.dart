import 'package:flutter/material.dart';

/// A [Text] widget that automatically resolves its color to the correct
/// primary text color for the current theme brightness.
///
/// In light mode: [colorScheme.onSurface] (#1A1A2E)
/// In dark mode: [colorScheme.onPrimary] (#F0F0F5)
///
/// Use this as a drop-in replacement for `Text` when you would otherwise
/// hardcode `colorScheme.onSurface` as the text color — which becomes
/// invisible on dark surfaces.
///
/// ## Usage
/// ```dart
/// // Before (invisible in dark mode):
/// Text('Hello', style: TextStyle(color: colorScheme.onSurface))
///
/// // After (visible in both modes):
/// ThemeText('Hello')
///
/// // With custom styling:
/// ThemeText('Hello', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
/// ```
class ThemeText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const ThemeText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme-resolved color from the active visual style (Glass/Clay)
    final themeColor = Theme.of(context).colorScheme.onSurface;
    final resolvedStyle = (style ?? const TextStyle()).copyWith(
      color: style?.color ?? themeColor,
    );

    final effectiveScaler = textScaler ?? MediaQuery.textScalerOf(context);

    return Text(
      data,
      style: resolvedStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: effectiveScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
