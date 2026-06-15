import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/core.dart';

/// Discover screen — placeholder for future content with premium glassmorphism design.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: ScreenHeader(
        title: 'Discover',
        onBack: () => popOrGoHome(context),
      ),
      body: PremiumBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space3xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Glass icon orb ──
                StaggeredFadeSlide(
                  index: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                    child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: DesignTokens.glassBlurLight,
                      sigmaY: DesignTokens.glassBlurLight,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.glassDark : AppColors.glassLight,
                        borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                        border: Border.all(
                          color: AppColors.glassBorderLight,
                          width: DesignTokens.glassBorderWidth,
                        ),
                      ),
                      child: const Icon(
                        PhosphorIconsLight.compass,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                ),
                const SizedBox(height: DesignTokens.space2xl),

                // ── Eyebrow tag ──
                StaggeredFadeSlide(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    ),
                    child: const Text(
                      'COMING SOON',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // ── Title ──
                StaggeredFadeSlide(
                  index: 2,
                  child: Text(
                    'Discover',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),

                // ── Description ──
                const StaggeredFadeSlide(
                  index: 3,
                  child: Text(
                    'New features, tips, and community content coming your way.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: DesignTokens.space3xl),

                // ── PremiumDoubleBezel glass card preview ──
                StaggeredFadeSlide(
                  index: 4,
                  child: PremiumDoubleBezel(
                  outerRadius: DesignTokens.radiusXl + 2,
                  gap: 3.0,
                  outerColor: AppColors.accent.withValues(alpha: 0.06),
                  innerPadding: const EdgeInsets.all(DesignTokens.spaceLg),
                  showInnerHighlight: false,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          PhosphorIconsLight.sparkle,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay tuned!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'We\'re working on something special',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
      // ── InfoFab: Get notified / explore IP ──
      floatingActionButton: InfoFab(
          tooltip: 'Discover actions',
          icon: PhosphorIconsLight.compass,
          children: [
            InfoFabAction(
              tooltip: 'Notify me when ready',
              infoDescription: 'Notify',
              backgroundColor: AppColors.accent,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('We\'ll notify you when Discover launches!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                );
              },
              child: const Icon(PhosphorIconsLight.bell, color: AppColors.textOnPrimary),
            ),
            InfoFabAction(
              tooltip: 'What\'s coming',
              infoDescription: 'Discover',
              backgroundColor: AppColors.primary,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Discover features: Tips, community content, stage-based insights, and more!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                );
              },
              child: const Icon(PhosphorIconsLight.lightbulb, color: AppColors.textOnPrimary),
            ),
          ],
        ),
    );
  }
}
