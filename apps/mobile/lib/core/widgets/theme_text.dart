import 'package:flutter/material.dart';

/// Text widget that automatically applies the system text scale factor.
///
/// Use this instead of [Text] for any user-facing text that should respect
/// accessibility font-size settings. Falls back to [Text] behavior when
/// no explicit [textScaler] is provided.
class ThemeText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextScaler? textScaler;

  const ThemeText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScaler = textScaler ?? MediaQuery.textScalerOf(context);
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: effectiveScaler,
    );
  }
}

/// Extension to apply text scaler to any [Text] widget.
extension TextScalerExtension on Text {
  /// Returns a copy of this [Text] widget with the system text scaler applied.
  Text withSystemTextScaler(BuildContext context) {
    return Text(
      data ?? '',
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }
}
