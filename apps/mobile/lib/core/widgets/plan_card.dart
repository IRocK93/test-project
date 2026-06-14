import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/design_tokens.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = AppColors.accent;
    final bg = isRecommended
        ? accent.withValues(alpha: isDark ? 0.10 : 0.05)
        : (isDark ? AppColors.glassDark : AppColors.surface);
    final borderColor = isRecommended
        ? accent.withValues(alpha: 0.6)
        : (isDark ? AppColors.darkBorder : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowSm(null),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent top bar for recommended plan
          if (isRecommended)
            const SizedBox(
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
                  const Text(
                    'RECOMMENDED',
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
                        color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/$period',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
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
                      color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
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
                          padding: const EdgeInsets.only(top: 6, right: 8),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isRecommended ? accent : AppColors.success,
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
                              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
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
                    text: isCurrent ? 'Current plan' : primaryActionLabel!,
                    onPressed: onPrimaryAction,
                    isDisabled: isCurrent,
                    isLoading: isBusy,
                    fullWidth: true,
                    backgroundColor: isRecommended ? accent : null,
                    semanticLabel: isCurrent ? 'Current plan' : primaryActionLabel!,
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
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
