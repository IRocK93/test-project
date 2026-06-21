import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../theme/design_tokens.dart';
import '../theme/clay_colors.dart';
import '../theme/glass_tokens.dart';

/// Premium app theme definitions — glass and clay variants, each with light/dark.
///
/// All shared component theme helpers accept their color values as parameters.
/// No palette class is referenced inside helpers — each concrete theme passes its own.
///
/// To add a third visual style:
/// 1. Create a new palette class (e.g. `NeoColors`)
/// 2. Add `neoLightTheme` and `neoDarkTheme` getters here
/// 3. Add `neo` to `AppVisualStyle` in `theme_mode_provider.dart`
/// 4. Add a toggle segment in `settings_screen.dart`
/// No screen files need modification.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════
  //  TYPOGRAPHY — Brand Font System
  // ═══════════════════════════════════════
  //
  // Display/Headlines: Syne — distinctive, geometric, editorial
  // UI/Body: Plus Jakarta Sans — warm, humanist, highly readable
  // Both via Google Fonts, fully variable weight support.
  //
  // BANNED: Inter, Roboto, Arial, Open Sans, Helvetica, Playfair Display

  static TextTheme _textTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textCaption,
    required Color textOnPrimary,
  }) {
    const display = GoogleFonts.syne;
    const ui = GoogleFonts.plusJakartaSans;

    return TextTheme(
      displayLarge: display(
        textStyle: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, letterSpacing: -1.5, height: 1.05, color: textPrimary),
      ),
      displayMedium: display(
        textStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1.0, height: 1.1, color: textPrimary),
      ),
      displaySmall: display(
        textStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.15, color: textPrimary),
      ),
      headlineLarge: display(
        textStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2, color: textPrimary),
      ),
      headlineMedium: display(
        textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.25, color: textPrimary),
      ),
      headlineSmall: display(
        textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3, color: textPrimary),
      ),
      titleLarge: ui(
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.1, height: 1.3, color: textPrimary),
      ),
      titleMedium: ui(
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: textPrimary),
      ),
      titleSmall: ui(
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4, color: textPrimary),
      ),
      bodyLarge: ui(
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: textPrimary),
      ),
      bodyMedium: ui(
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: textPrimary),
      ),
      bodySmall: ui(
        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: textSecondary),
      ),
      labelLarge: ui(
        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.3, color: textOnPrimary),
      ),
      labelMedium: ui(
        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.15, height: 1.3, color: textSecondary),
      ),
      labelSmall: ui(
        textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.2, height: 1.3, color: textCaption),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  COMPONENT THEMES (palette-agnostic)
  // ═══════════════════════════════════════
  // Every helper accepts its color values as parameters. No AppColors or
  // ClayColors references inside any helper. Each concrete theme passes
  // its own palette values.

  static CardThemeData _cardTheme({required Color surface, required Color border, Color? shadowColor}) {
    return CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: shadowColor ?? surface.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        side: BorderSide(color: border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color focusedBorder,
    required Color labelColor,
    required Color hintColor,
    required Color prefixColor,
    required Color errorColor,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg, vertical: DesignTokens.spaceMd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide(color: focusedBorder, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: TextStyle(color: labelColor, fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      prefixIconColor: prefixColor,
      suffixIconColor: prefixColor,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({
    required Color background,
    required Color foreground,
    required Color disabledBg,
    required Color disabledFg,
    required double radius,
    Color? shadowColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: disabledBg,
        disabledForegroundColor: disabledFg,
        elevation: 0,
        shadowColor: shadowColor,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl, vertical: DesignTokens.spaceMd),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.01),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({
    required Color foreground,
    required Color border,
    required double radius,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(color: border, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl, vertical: DesignTokens.spaceMd),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({required Color foreground}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceXs),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme({
    required Color background,
    required Color selectedItem,
    required Color unselectedItem,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: selectedItem,
      unselectedItemColor: unselectedItem,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  static AppBarTheme _appBarTheme({required Color background, required Color foreground}) {
    return AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleSpacing: DesignTokens.spaceLg,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: foreground),
      iconTheme: IconThemeData(color: foreground),
      actionsIconTheme: IconThemeData(color: foreground),
    );
  }

  static FloatingActionButtonThemeData _fabTheme({
    required Color background,
    required Color foreground,
    ShapeBorder? shape,
  }) {
    return FloatingActionButtonThemeData(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 4,
      shape: shape ?? const CircleBorder(),
      smallSizeConstraints: const BoxConstraints.tightFor(width: 48, height: 48),
    );
  }

  static ChipThemeData _chipTheme({
    required Color background,
    required Color selectedColor,
    required Color disabledColor,
    required Color labelColor,
    required Color secondaryLabelColor,
    required Color border,
  }) {
    return ChipThemeData(
      backgroundColor: background,
      selectedColor: selectedColor,
      disabledColor: disabledColor,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: labelColor),
      secondaryLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondaryLabelColor),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceXs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        side: BorderSide(color: border, width: 0.5),
      ),
    );
  }

  static DividerThemeData _dividerTheme({required Color color}) {
    return DividerThemeData(space: 0, thickness: 1, color: color);
  }

  static ProgressIndicatorThemeData _progressTheme({required Color color, required Color trackColor}) {
    return ProgressIndicatorThemeData(color: color, linearTrackColor: trackColor, circularTrackColor: trackColor);
  }

  static SnackBarThemeData _snackBarTheme({required Color background, required Color contentColor}) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
      contentTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: contentColor),
      backgroundColor: background,
    );
  }

  static SegmentedButtonThemeData _segmentedButtonTheme({
    required Color selectedBg,
    required Color selectedFg,
    required Color unselectedFg,
  }) {
    return SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: selectedBg,
        selectedForegroundColor: selectedFg,
        foregroundColor: unselectedFg,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ExpansionTileThemeData _expansionTileTheme({
    required Color textColor,
    required Color iconColor,
    required Color collapsedIconColor,
  }) {
    return ExpansionTileThemeData(
      iconColor: iconColor,
      collapsedIconColor: collapsedIconColor,
      textColor: textColor,
      collapsedTextColor: textColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd)),
      childrenPadding: EdgeInsets.zero,
      tilePadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
    );
  }

  static DialogThemeData _dialogTheme({required Color titleColor}) {
    return DialogThemeData(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusLg))),
      elevation: 8,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: titleColor),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme({required Color dragHandleColor}) {
    return BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusXl)),
      ),
      elevation: 8,
      showDragHandle: true,
      dragHandleColor: dragHandleColor,
    );
  }

  // ═══════════════════════════════════════
  //  GLASS — LIGHT THEME
  // ═══════════════════════════════════════

  static ThemeData get glassLightTheme => _buildGlassTheme(Brightness.light);

  // ═══════════════════════════════════════
  //  GLASS — DARK THEME
  // ═══════════════════════════════════════

  static ThemeData get glassDarkTheme => _buildGlassTheme(Brightness.dark);

  static ThemeData _buildGlassTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = _GlassTokens(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors.scheme,
      scaffoldBackgroundColor: colors.scaffoldBg,
      textTheme: _textTheme(textPrimary: colors.textPrimary, textSecondary: colors.textSecondary, textCaption: colors.textCaption, textOnPrimary: colors.textOnPrimary),
      primaryTextTheme: _textTheme(textPrimary: colors.textPrimary, textSecondary: colors.textSecondary, textCaption: colors.textCaption, textOnPrimary: colors.textOnPrimary),
      cardTheme: _cardTheme(surface: colors.cardBg, border: colors.cardBorder),
      inputDecorationTheme: _inputTheme(fill: colors.inputFill, border: colors.inputBorder, focusedBorder: colors.inputFocused, labelColor: colors.labelColor, hintColor: colors.hintColor, prefixColor: colors.caption, errorColor: colors.scheme.error),
      elevatedButtonTheme: _elevatedButtonTheme(background: colors.primary, foreground: colors.textOnPrimary, disabledBg: colors.disabled, disabledFg: colors.textOnPrimary, radius: DesignTokens.radiusMd, shadowColor: colors.primary.withValues(alpha: 0.3)),
      outlinedButtonTheme: _outlinedButtonTheme(foreground: colors.primary, border: colors.primary, radius: DesignTokens.radiusMd),
      textButtonTheme: _textButtonTheme(foreground: colors.primary),
      bottomNavigationBarTheme: _bottomNavTheme(background: colors.navBg, selectedItem: colors.primary, unselectedItem: colors.caption),
      appBarTheme: _appBarTheme(background: colors.navBg, foreground: colors.textPrimary),
      floatingActionButtonTheme: _fabTheme(background: colors.secondary, foreground: colors.textOnPrimary),
      chipTheme: _chipTheme(background: colors.chipBg, selectedColor: colors.primaryContainer, disabledColor: colors.disabled, labelColor: colors.textPrimary, secondaryLabelColor: colors.textSecondary, border: colors.chipBorder),
      dividerTheme: _dividerTheme(color: colors.divider),
      progressIndicatorTheme: _progressTheme(color: colors.primary, trackColor: colors.divider),
      snackBarTheme: _snackBarTheme(background: colors.snackBg, contentColor: colors.snackText),
      dialogTheme: _dialogTheme(titleColor: colors.textPrimary),
      bottomSheetTheme: _bottomSheetTheme(dragHandleColor: colors.divider),
      segmentedButtonTheme: _segmentedButtonTheme(selectedBg: colors.primaryContainer, selectedFg: colors.primary, unselectedFg: colors.unselectedSegmentFg),
      expansionTileTheme: _expansionTileTheme(textColor: colors.textPrimary, iconColor: colors.textSecondary, collapsedIconColor: colors.caption),
      splashColor: colors.primary.withValues(alpha: 0.08),
      highlightColor: colors.primary.withValues(alpha: 0.04),
      hoverColor: colors.primary.withValues(alpha: 0.04),
      focusColor: colors.primary.withValues(alpha: 0.12),
      canvasColor: colors.scaffoldBg,
      extensions: [isDark ? GlassTokens.dark() : GlassTokens.light()],
    );
  }

  // ═══════════════════════════════════════
  //  CLAY — LIGHT THEME
  // ═══════════════════════════════════════

  static ThemeData get clayLightTheme => _buildClayTheme(Brightness.light);

  // ═══════════════════════════════════════
  //  CLAY — DARK THEME
  // ═══════════════════════════════════════

  static ThemeData get clayDarkTheme => _buildClayTheme(Brightness.dark);

  static ThemeData _buildClayTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = _ClayTokens(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors.scheme,
      scaffoldBackgroundColor: colors.scaffoldBg,
      textTheme: _textTheme(textPrimary: colors.textPrimary, textSecondary: colors.textSecondary, textCaption: colors.textCaption, textOnPrimary: colors.textOnPrimary),
      primaryTextTheme: _textTheme(textPrimary: colors.textPrimary, textSecondary: colors.textSecondary, textCaption: colors.textCaption, textOnPrimary: colors.textOnPrimary),
      cardTheme: _cardTheme(surface: colors.cardBg, border: colors.cardBorder),
      inputDecorationTheme: _inputTheme(fill: colors.inputFill, border: colors.inputBorder, focusedBorder: colors.inputFocused, labelColor: colors.labelColor, hintColor: colors.hintColor, prefixColor: colors.caption, errorColor: colors.scheme.error),
      elevatedButtonTheme: _elevatedButtonTheme(background: colors.primary, foreground: colors.textOnPrimary, disabledBg: colors.disabled, disabledFg: colors.textOnPrimary, radius: DesignTokens.radiusMd + 4, shadowColor: null),
      outlinedButtonTheme: _outlinedButtonTheme(foreground: colors.primary, border: colors.primary, radius: DesignTokens.radiusMd + 4),
      textButtonTheme: _textButtonTheme(foreground: colors.primary),
      bottomNavigationBarTheme: _bottomNavTheme(background: colors.navBg, selectedItem: colors.primary, unselectedItem: colors.caption),
      appBarTheme: _appBarTheme(background: colors.navBg, foreground: colors.textPrimary),
      floatingActionButtonTheme: _fabTheme(background: colors.secondary, foreground: colors.textOnPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusMd + 4))),
      chipTheme: _chipTheme(background: colors.chipBg, selectedColor: colors.primaryContainer, disabledColor: colors.disabled, labelColor: colors.textPrimary, secondaryLabelColor: colors.textSecondary, border: colors.chipBorder),
      dividerTheme: _dividerTheme(color: colors.divider),
      progressIndicatorTheme: _progressTheme(color: colors.primary, trackColor: colors.divider),
      snackBarTheme: _snackBarTheme(background: colors.snackBg, contentColor: colors.snackText),
      dialogTheme: _dialogTheme(titleColor: colors.textPrimary),
      bottomSheetTheme: _bottomSheetTheme(dragHandleColor: colors.divider),
      segmentedButtonTheme: _segmentedButtonTheme(selectedBg: colors.primaryContainer, selectedFg: colors.primary, unselectedFg: colors.unselectedSegmentFg),
      expansionTileTheme: _expansionTileTheme(textColor: colors.textPrimary, iconColor: colors.textSecondary, collapsedIconColor: colors.caption),
      splashColor: colors.primary.withValues(alpha: 0.08),
      highlightColor: colors.primary.withValues(alpha: 0.04),
      canvasColor: colors.scaffoldBg,
      extensions: [GlassTokens.clay()],
    );
  }

  // ═══════════════════════════════════════
  //  THEME RESOLVER
  // ═══════════════════════════════════════

  /// Returns the correct [ThemeData] for the given visual style and brightness.
  /// This is the single entry point for theme resolution.
  static ThemeData resolve({required String visualStyle, required Brightness brightness}) {
    final isClay = visualStyle == 'clay';
    if (isClay) {
      return brightness == Brightness.dark ? clayDarkTheme : clayLightTheme;
    }
    return brightness == Brightness.dark ? glassDarkTheme : glassLightTheme;
  }

  // ═══════════════════════════════════════
  //  BACKWARD-COMPATIBLE ALIASES
  // ═══════════════════════════════════════
  // Tests and legacy code reference lightTheme / darkTheme. These resolve
  // to the Glass (default) theme variants.

  /// @deprecated Use [glassLightTheme] or [resolve].
  static ThemeData get lightTheme => glassLightTheme;

  /// @deprecated Use [glassDarkTheme] or [resolve].
  static ThemeData get darkTheme => glassDarkTheme;
}

// ═════════════════════════════════════════════════════════════════════════════
//  TOKEN BUNDLES — Each concrete theme resolves its colors through one of these
// ═════════════════════════════════════════════════════════════════════════════

/// Resolved color tokens for the Glass (default) visual style.
class _GlassTokens {
  final bool isDark;
  _GlassTokens(this.isDark);

  ColorScheme get scheme => isDark
      ? ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.textPrimary,
          primaryContainer: AppColors.primaryDark.withValues(alpha: 0.3),
          secondary: AppColors.secondaryLight,
          onSecondary: AppColors.textPrimary,
          secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
          tertiary: AppColors.accentLight,
          surface: AppColors.darkSurface,
          onSurface: AppColors.textOnDark,
          error: AppColors.error,
          onError: AppColors.textOnDark,
          errorContainer: const Color(0xFF3E1010),
          outline: AppColors.darkBorder,
        )
      : const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.textOnPrimary,
          secondaryContainer: AppColors.secondaryContainer,
          tertiary: AppColors.accent,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          outline: AppColors.border,
        );

  Color get primary => isDark ? AppColors.primaryLight : AppColors.primary;
  Color get secondary => AppColors.secondary;
  Color get scaffoldBg => isDark ? AppColors.darkBackground : AppColors.background;
  Color get textPrimary => isDark ? AppColors.textOnDark : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get textCaption => isDark ? AppColors.textCaptionDark : AppColors.textCaption;
  Color get textOnPrimary => AppColors.textOnPrimary;
  Color get caption => isDark ? AppColors.textCaptionDark : AppColors.textCaption;
  Color get primaryContainer => isDark ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.primaryContainer;
  Color get disabled => AppColors.disabled;
  Color get divider => AppColors.divider;
  Color get cardBg => isDark ? AppColors.glassDark : AppColors.glassWhite;
  Color get cardBorder => (isDark ? AppColors.glassDarkBorder : AppColors.glassBorder).withValues(alpha: 0.6);
  Color get inputFill => isDark ? AppColors.glassDark : AppColors.glassWhite;
  Color get inputBorder => isDark ? AppColors.darkBorder : AppColors.border;
  Color get inputFocused => isDark ? AppColors.primaryLight : AppColors.primary;
  Color get labelColor => isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  Color get hintColor => isDark ? AppColors.textCaptionDark : AppColors.textCaption;
  Color get navBg => isDark ? AppColors.glassDark : AppColors.glassWhite;
  Color get chipBg => isDark ? AppColors.darkSurfaceElevated : AppColors.glassLight;
  Color get chipBorder => AppColors.border;
  Color get snackBg => isDark ? AppColors.darkSurfaceElevated.withValues(alpha: 0.95) : AppColors.textPrimary.withValues(alpha: 0.85);
  Color get snackText => isDark ? AppColors.textOnDark : AppColors.textOnDark;
  Color get unselectedSegmentFg => isDark ? AppColors.textOnDark : AppColors.textSecondary;
}

/// Resolved color tokens for the Clay visual style.
class _ClayTokens {
  final bool isDark;
  _ClayTokens(this.isDark);

  ColorScheme get scheme => isDark
      ? ColorScheme.dark(
          primary: ClayColors.primaryLight,
          onPrimary: ClayColors.textPrimary,
          primaryContainer: ClayColors.primaryDark.withValues(alpha: 0.3),
          secondary: ClayColors.secondaryLight,
          onSecondary: ClayColors.textPrimary,
          secondaryContainer: ClayColors.secondary.withValues(alpha: 0.2),
          tertiary: ClayColors.accentLight,
          surface: ClayColors.darkSurface,
          onSurface: ClayColors.textOnDark,
          error: ClayColors.error,
          onError: ClayColors.textOnDark,
          outline: ClayColors.darkBorder,
        )
      : const ColorScheme.light(
          primary: ClayColors.primary,
          onPrimary: ClayColors.textOnPrimary,
          primaryContainer: ClayColors.primaryContainer,
          secondary: ClayColors.secondary,
          onSecondary: ClayColors.textOnPrimary,
          secondaryContainer: ClayColors.secondaryContainer,
          tertiary: ClayColors.accent,
          surface: ClayColors.surface,
          onSurface: ClayColors.textPrimary,
          error: ClayColors.error,
          onError: ClayColors.textOnPrimary,
          outline: ClayColors.border,
        );

  Color get primary => isDark ? ClayColors.primaryLight : ClayColors.primary;
  Color get secondary => isDark ? ClayColors.secondaryLight : ClayColors.secondary;
  Color get scaffoldBg => isDark ? ClayColors.darkBackground : ClayColors.background;
  Color get textPrimary => isDark ? ClayColors.textOnDark : ClayColors.textPrimary;
  Color get textSecondary => isDark ? ClayColors.textSecondaryDark : ClayColors.textSecondary;
  Color get textCaption => isDark ? ClayColors.textCaptionDark : ClayColors.textCaption;
  Color get textOnPrimary => ClayColors.textOnPrimary;
  Color get caption => isDark ? ClayColors.textCaptionDark : ClayColors.textCaption;
  Color get primaryContainer => isDark ? ClayColors.primaryDark.withValues(alpha: 0.3) : ClayColors.primaryContainer;
  Color get disabled => ClayColors.disabled;
  Color get divider => ClayColors.divider;
  Color get cardBg => isDark ? ClayColors.clayDarkSurface : ClayColors.claySurface;
  Color get cardBorder => isDark ? ClayColors.clayDarkBorder : ClayColors.clayBorder;
  Color get inputFill => isDark ? ClayColors.clayDarkSurface : ClayColors.clayElevated;
  Color get inputBorder => isDark ? ClayColors.darkBorder : ClayColors.border;
  Color get inputFocused => isDark ? ClayColors.primaryLight : ClayColors.primary;
  Color get labelColor => isDark ? ClayColors.textSecondaryDark : ClayColors.textSecondary;
  Color get hintColor => isDark ? ClayColors.textCaptionDark : ClayColors.textCaption;
  Color get navBg => isDark ? ClayColors.clayDarkSurface : ClayColors.claySurface;
  Color get chipBg => isDark ? ClayColors.darkSurfaceElevated : ClayColors.surfaceLight;
  Color get chipBorder => ClayColors.border;
  Color get snackBg => isDark ? ClayColors.darkSurfaceElevated.withValues(alpha: 0.95) : ClayColors.textPrimary.withValues(alpha: 0.85);
  Color get snackText => ClayColors.textOnDark;
  Color get unselectedSegmentFg => isDark ? ClayColors.textOnDark : ClayColors.textSecondary;
}