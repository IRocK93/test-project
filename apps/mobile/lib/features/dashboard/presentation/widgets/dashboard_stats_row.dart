import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/core/widgets/glass_surface.dart';
import 'package:baby_mon/core/widgets/premium_stat_card.dart';

/// Quick stats row showing milestone, feeding, health, and sleep counts.
/// Uses [GlassSurface.group] for a single shared BackdropFilter.
class DashboardStatsRow extends StatelessWidget {
  final Map<String, dynamic>? evolution;

  const DashboardStatsRow({super.key, required this.evolution});

  @override
  Widget build(BuildContext context) {
    return GlassSurface.group(
      context: context,
      blurSigma: DesignTokens.glassBlurLight,
      borderRadius: DesignTokens.radiusMd,
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.spaceXs,
        horizontal: DesignTokens.spaceXs,
      ),
      gap: DesignTokens.spaceXs,
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: PremiumStatCard(
            label: 'Milestones',
            value: '${evolution?['milestoneCount'] ?? 0}',
            icon: PhosphorIconsLight.trophy,
            iconColor: AppColors.bentoGold,
            isGlass: false,
          ),
        ),
        Expanded(
          child: PremiumStatCard(
            label: 'Feedings',
            value: '${evolution?['feedLogCount'] ?? 0}',
            icon: PhosphorIconsLight.bowlFood,
            iconColor: AppColors.bentoCoral,
            isGlass: false,
          ),
        ),
        Expanded(
          child: PremiumStatCard(
            label: 'Health',
            value: '${evolution?['healthRecordCount'] ?? 0}',
            icon: PhosphorIconsLight.heart,
            iconColor: AppColors.bentoPurple,
            isGlass: false,
          ),
        ),
        Expanded(
          child: PremiumStatCard(
            label: 'Sleep',
            value: '${evolution?['sleepLogCount'] ?? 0}',
            icon: PhosphorIconsLight.moon,
            iconColor: AppColors.bentoBlue,
            isGlass: false,
          ),
        ),
      ],
    );
  }
}
