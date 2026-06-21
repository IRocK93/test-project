import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/constants.dart';


/// A compact branded loading spinner sized for buttons and inline contexts.
///
/// Use instead of raw [CircularProgressIndicator] wrapped in [SizedBox]
/// for consistent 20px branded spinners across buttons, inline loaders,
/// and small UI elements.
///
/// Defaults:
/// - Size: 20×20 (suitable for most button contexts)
/// - Color: [colorScheme.primary]
/// - Stroke width: 2
///
/// Example:
/// ```dart
/// ElevatedButton(
///   onPressed: isLoading ? null : _submit,
///   child: isLoading ? const ButtonLoading() : const Text('Submit'),
/// )
/// ```
class ButtonLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const ButtonLoading({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.colorScheme.primary,
        ),
      ),
    );
  }
}
