import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/glass_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showBack;
  final double? elevation;
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.showBack = true,
    this.elevation,
  });
  static void defaultBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final glass = Theme.of(context).extension<GlassTokens>();
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: DesignTokens.glassBlurMd,
              sigmaY: DesignTokens.glassBlurMd,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: glass != null
                    ? (isDark ? glass.background : glass.surface)
                    : (isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface),
                border: Border(
                  bottom: BorderSide(
                    color: (glass != null
                        ? glass.border
                        : colorScheme.outlineVariant)
                        .withValues(alpha: 0.5),
                    width: DesignTokens.glassBorderWidth,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
                leading: showBack
                    ? IconButton(
                        icon: const Icon(PhosphorIconsLight.arrowLeft),
                        onPressed: onBack ?? () => defaultBack(context),
                      )
                    : null,
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                centerTitle: true,
                actions: actions,
                leadingWidth: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
