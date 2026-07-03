import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/premium_double_bezel.dart';
import 'package:baby_mon/features/health/domain/entities/growth_record.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';

/// Growth card showing the latest weight measurement.
class DashboardGrowthCard extends StatelessWidget {
  final GrowthRecord latestGrowth;

  const DashboardGrowthCard({super.key, required this.latestGrowth});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final measuredAt = latestGrowth.measuredAt != null
        ? DateFormat.yMMMd().format(latestGrowth.measuredAt!)
        : '';
    final unitLabel = _localizeUnit(latestGrowth.unit, l10n);
    return Semantics(
      label: '${l10n.latestWeightLabel}: ${latestGrowth.value} $unitLabel',
      button: true,
      child: PremiumDoubleBezel(
        outerRadius: DesignTokens.radius2xl,
        gap: 5.0,
        outerColor: context.colorScheme.primary.withValues(alpha: 0.06),
        onTap: () => context.push('/growth-chart'),
        child: Row(
        children: [
          PremiumDoubleBezel(
            outerRadius: DesignTokens.radiusMd + 4,
            gap: 3.0,
            outerColor: context.colorScheme.primary.withValues(alpha: 0.08),
            innerPadding: EdgeInsets.zero,
            showInnerHighlight: false,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: Icon(
                PhosphorIconsLight.scales,
                color: context.colorScheme.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.latestWeightLabel,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${latestGrowth.value} $unitLabel',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                if (measuredAt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      measuredAt,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Icon(
                PhosphorIconsLight.caretRight,
                color: context.colorScheme.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
	      ),
	    );
	  }

  String _localizeUnit(String? unit, dynamic l10n) {
    if (unit == null || unit.isEmpty) return l10n.kg;
    switch (unit) {
      case 'kg': return l10n.kg;
      case 'cm': return l10n.cm;
      case 'lb': return l10n.lb;
      case 'oz': return l10n.oz;
      case 'in': return l10n.unitInches;
      default: return unit;
    }
  }
}
