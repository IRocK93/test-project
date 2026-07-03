import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// Identity card at the top of the Settings screen.
///
/// Shows the user's avatar, name, email, and current plan with a trial
/// countdown. The whole card is a single tap target that opens the
/// edit-profile flow — no internal pencil icon is required.
class IdentityCard extends StatelessWidget {
  final String name;
  final String email;
  final String planName;
  final int? trialDaysRemaining;
  final VoidCallback? onTap;

  const IdentityCard({
    super.key,
    required this.name,
    required this.email,
    required this.planName,
    this.trialDaysRemaining,
    this.onTap,
  });

  String? _buildPlanSubtitle(BuildContext context) {
    if (planName.toUpperCase() == 'PREMIUM' &&
        trialDaysRemaining != null &&
        trialDaysRemaining! > 0) {
      return context.l10n.planPremiumTrial(trialDaysRemaining!);
    }
    if (planName.toUpperCase() == 'PREMIUM') return context.l10n.planPremium;
    return context.l10n.planFree;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Semantics(
      label: 'Open profile settings',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap!.call();
                },
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          decoration: BoxDecoration(
            color: isDark ? context.glass.background : context.colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: isDark ? context.colorScheme.outline : context.colorScheme.outline,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // 56×56 gradient avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colorScheme.primary, context.colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceLg),
              // Name, email, plan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? context.colorScheme.onPrimary
                            : context.colorScheme.onSurface,
                        letterSpacing: -0.2,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: context.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Builder(
                      builder: (context) {
                        final planSubtitle = _buildPlanSubtitle(context);
                        if (planSubtitle == null) return const SizedBox.shrink();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              planSubtitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.primaryContainer,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Icon(
                PhosphorIconsLight.caretRight,
                size: 22,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
