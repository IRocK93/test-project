import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onSaved: onSaved,
      validator: validator,
      onChanged: onChanged,
    );
  }
}