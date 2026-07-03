import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/glass_tokens.dart';
import 'theme_button.dart';

/// A single subscription plan card. Used to render Free and Premium plans
/// stacked vertically on the Subscription screen.
///
/// Renders a 16dp-radius card with a 2px accent top border when
/// [isRecommended] is true, an "RECOMMENDED" eyebrow label, a name,
/// a price + period, a feature list, and a primary action button.
class PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final String? premiumHeader; // e.g. "Everything in Free, plus:"
  final bool isCurrent;
  final bool isRecommended;
  final bool isBusy;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final String? footerNote; // e.g. "Cancel anytime · 30-day refund"
  final String recommendedLabel;
  final String currentPlanLabel;

  const PlanCard({
    super.key,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.premiumHeader,
    this.isCurrent = false,
    this.isRecommended = false,
    this.isBusy = false,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.footerNote,
    this.recommendedLabel = 'RECOMMENDED',
    this.currentPlanLabel = 'Current plan',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final glass = Theme.of(context).extension<GlassTokens>()!;
    final accent = glass.accent;
    final bg = isRecommended
        ? accent.withValues(alpha: 0.05)
        : glass.background;
    final borderColor = isRecommended
        ? accent.withValues(alpha: 0.6)
        : glass.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowSm(bg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent top bar for recommended plan
          if (isRecommended)
            SizedBox(
              width: double.infinity,
              height: 2,
              child: ColoredBox(color: accent),
            ),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended) ...[
                  Text(
                    recommendedLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXs),
                ],
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/$period',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (premiumHeader != null) ...[
                  const SizedBox(height: DesignTokens.spaceMd),
                  Text(
                    premiumHeader!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.spaceMd),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(top: 6, end: 8),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isRecommended ? accent : context.colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                if (primaryActionLabel != null && onPrimaryAction != null)
                  ThemeButton(
                    text: isCurrent ? currentPlanLabel : primaryActionLabel!,
                    onPressed: onPrimaryAction,
                    isDisabled: isCurrent,
                    isLoading: isBusy,
                    fullWidth: true,
                    backgroundColor: isRecommended ? accent : null,
                    semanticLabel: isCurrent ? currentPlanLabel : primaryActionLabel!,
                  ),
                if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                  const SizedBox(height: DesignTokens.spaceSm),
                  Center(
                    child: TextButton(
                      onPressed: onSecondaryAction,
                      child: Text(
                        secondaryActionLabel!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (footerNote != null) ...[
                  const SizedBox(height: DesignTokens.spaceSm),
                  Center(
                    child: Text(
                      footerNote!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
