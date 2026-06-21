
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
                  child: GlassSurface(
                    borderRadius: DesignTokens.radius2xl,
                    blurSigma: DesignTokens.glassBlurLight,
                    backgroundColor: isDark ? context.glass.background : context.glass.surface,
                    borderColor: context.glass.borderLight,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(
                        PhosphorIconsLight.compass,
                        size: 44,
                        color: context.colorScheme.primary,
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
                      color: context.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                    ),
                    child: Text(
                      'COMING SOON',
                      style: TextStyle(
                        fontSize: DesignTokens.font2xs,
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.primary,
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
                  outerColor: context.colorScheme.primary.withValues(alpha: 0.06),
                  innerPadding: const EdgeInsets.all(DesignTokens.spaceLg),
                  showInnerHighlight: false,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: Border.all(
                            color: context.colorScheme.primary.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          PhosphorIconsLight.sparkle,
                          color: context.colorScheme.primary,
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
                                color: isDark ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'We\'re working on something special',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colorScheme.onSurfaceVariant,
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
              backgroundColor: context.colorScheme.primary,
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
              child: Icon(PhosphorIconsLight.bell, color: context.colorScheme.onPrimary),
            ),
            InfoFabAction(
              tooltip: 'What\'s coming',
              infoDescription: 'Discover',
              backgroundColor: context.colorScheme.primary,
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
              child: Icon(PhosphorIconsLight.lightbulb, color: context.colorScheme.onPrimary),
            ),
          ],
        ),
    );
  }
}
