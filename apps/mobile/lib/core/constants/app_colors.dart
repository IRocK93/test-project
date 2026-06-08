import 'package:flutter/material.dart';

/// Centralized color palette for the application
/// All colors defined once, referenced everywhere — no magic values
///
class AppColors {
  AppColors._();

  // Primary colors
  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFFA29BFE);

  // Secondary colors
  static const secondary = Color(0xFF00B4D8);
  static const accent = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFA726);

  // Text colors
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF8D8D8D);
  static const textCaption = Color(0xFFB0B0B0);

  // Background colors
  static const background = Color(0xFFFAFAFA);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF8F8F8);

  // Utility colors
  static const divider = Color(0xFFE0E0E0);
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF00C853);
  static const border = Color(0xFFE0E0E0);
}
