import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/app_colors.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/morphing_hamburger.dart';
import 'package:baby_mon/core/widgets/theme_button.dart';
import 'package:baby_mon/core/widgets/info_fab.dart';

/// Simplified MainScreen for golden testing — mirrors the navigation shell
/// layout (floating AppBar, bottom nav, IndexedStack) without GoRouter
/// dependencies or child screen provider chains.
class GoldenMainScreen extends StatelessWidget {
  const GoldenMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.glassDark : AppColors.glassWhite;
    final navBorder = isDark
        ? AppColors.glassDarkBorder.withValues(alpha: 0.6)
        : AppColors.glassBorder.withValues(alpha: 0.6);

    return Scaffold(
      // ── Floating pill AppBar ──
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.only(
            top: DesignTokens.spaceSm,
            left: DesignTokens.spaceSm,
            right: DesignTokens.spaceSm,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.glassDarkShadow : AppColors.glassShadow,
                  blurRadius: DesignTokens.glassShadowBlur,
                  offset: const Offset(0, DesignTokens.glassShadowOffset),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: DesignTokens.glassBlurHeavy,
                  sigmaY: DesignTokens.glassBlurHeavy,
                ),
                child: AppBar(
                  backgroundColor: navBg,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 2,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                    side: BorderSide(
                      color: navBorder,
                      width: DesignTokens.glassBorderWidth,
                    ),
                  ),
                  leading: const MorphingHamburger(
                    isOpen: false,
                    onTap: null,
                    size: 28,
                    strokeWidth: 2.5,
                  ),
                  title: Row(
                    children: [
                      // BabyMon selector pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.genderMonious.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                          border: Border.all(
                            color: AppColors.genderMoniousAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👶‍♂️', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              'Test Baby',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  actions: [
                    ThemeButton.icon(
                      icon: PhosphorIconsLight.bell,
                      onPressed: () {},
                      tooltip: 'Notifications',
                      variant: ThemeButtonVariant.text,
                    ),
                    ThemeButton.icon(
                      icon: PhosphorIconsLight.plusCircle,
                      onPressed: () {},
                      tooltip: 'Create BabyMon',
                      variant: ThemeButtonVariant.text,
                      foregroundColor: AppColors.secondary,
                    ),
                    const SizedBox(width: DesignTokens.spaceXs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // ── Body — placeholder for Dashboard ──
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              PhosphorIconsLight.gauge,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav — Floating Glass Pill ──
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: DesignTokens.spaceLg,
          right: DesignTokens.spaceLg,
          bottom: DesignTokens.spaceLg + MediaQuery.of(context).padding.bottom,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: DesignTokens.glassBlurHeavy,
              sigmaY: DesignTokens.glassBlurHeavy,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: navBg.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                border: Border.all(
                  color: navBorder,
                  width: DesignTokens.glassBorderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.glassDarkShadow : AppColors.glassShadow)
                        .withValues(alpha: 0.15),
                    blurRadius: DesignTokens.glassShadowBlur,
                    offset: const Offset(0, DesignTokens.glassShadowOffset),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceSm,
                vertical: DesignTokens.spaceXs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(PhosphorIconsLight.gauge, 'Dashboard', true),
                  _navItem(PhosphorIconsLight.trophy, 'Milestones', false),
                  _navItem(PhosphorIconsLight.bowlFood, 'Feeding', false),
                  _navItem(PhosphorIconsLight.heart, 'Health', false),
                  _navItem(PhosphorIconsLight.dotsSixVertical, 'More', false),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButton: InfoFab(
        tooltip: 'Quick actions',
        icon: PhosphorIconsLight.lightning,
        children: [
          InfoFabAction(
            tooltip: 'Log Feeding',
            infoDescription: 'Feeding',
            backgroundColor: AppColors.warning,
            onTap: () {},
            child: const Icon(PhosphorIconsLight.bowlFood, color: Colors.white),
          ),
          InfoFabAction(
            tooltip: 'Add Milestone',
            infoDescription: 'Milestone',
            backgroundColor: AppColors.accent,
            onTap: () {},
            child: const Icon(PhosphorIconsLight.star, color: Colors.white),
          ),
        ],
      ),
    );
  }

  static Widget _navItem(IconData icon, String label, bool selected) {
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        curve: DesignTokens.curvePremium,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? DesignTokens.spaceMd : DesignTokens.spaceSm,
          vertical: DesignTokens.spaceXs,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.textCaption,
            ),
            if (selected) ...[
              const SizedBox(width: DesignTokens.spaceXs),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
