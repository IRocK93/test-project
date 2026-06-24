import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

/// A polished upgrade prompt shown when the user tries to access a
/// PREMIUM-tier companion feature without a Premium subscription.
///
/// Displays a crown icon, feature name, benefit list, and a CTA button
/// that navigates to the subscription plans screen.
class UpgradePromptWidget extends StatelessWidget {
  /// The name of the feature the user is trying to access (e.g. "Daily Brief").
  final String featureName;

  /// Brief description of what upgrading unlocks.
  final String? description;

  const UpgradePromptWidget({
    super.key,
    required this.featureName,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Crown icon ──
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.primary.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsLight.crown,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXl),

            // ── Heading ──
            Text(
              'Premium Feature',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),

            // ── Subtitle ──
            Text(
              description ?? _defaultDescription(featureName),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceXl),

            // ── Benefits ──
            ..._benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsLight.checkCircle,
                        size: 18,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Text(
                        benefit,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: DesignTokens.space2xl),

            // ── CTA Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIconsLight.crown, size: 20),
                    SizedBox(width: DesignTokens.spaceSm),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontSize: DesignTokens.fontLg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),

            // ── Price note ──
            Text(
              '\$4.99/month · Cancel anytime',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceXl),

            // ── Bottom link to go back ──
            TextButton(
              onPressed: () {
                if (context.canPop()) context.pop();
              },
              child: Text(
                'Maybe later',
                style: TextStyle(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _defaultDescription(String feature) {
    return 'Upgrade to Premium to unlock $feature and get '
        'AI-powered parenting guidance, adaptive routines, '
        'and developmental milestone tracking.';
  }

  static const _benefits = [
    'AI-powered stage content & daily tips',
    'Adaptive routines & milestone tracking',
    'Unlimited history & export',
    'Multiple BabyMon profiles',
  ];
}
