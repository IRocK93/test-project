import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/widgets/premium_double_bezel.dart';
import 'package:baby_mon/core/widgets/premium_progress_bar.dart';

/// XP progress card showing current level, XP bar, and next level.
class DashboardXpCard extends StatelessWidget {
  final Map<String, dynamic>? evolution;

  const DashboardXpCard({super.key, required this.evolution});

  double get _xpProgress {
    if (evolution == null) return 0.0;
    final progress = evolution!['xpProgress'];
    if (progress != null) return (progress as num).toDouble() / 100.0;
    final xp = (parseDouble(evolution!['currentXp']) ?? 0.0);
    final needed = parseDouble(evolution!['xpForNextLevel']) ?? _xpForStage(_currentLevel).toDouble();
    return needed > 0 ? (xp / needed).clamp(0.0, 1.0) : 0.0;
  }

  int get _xpCurrent => parseInt(evolution?['currentXp']) ?? 0;

  int get _xpForNextLevel {
    final numVal = parseDouble(evolution?['xpForNextLevel']);
    if (numVal != null && numVal > 0) return numVal.round();
    return _xpForStage(_currentLevel);
  }

  int get _currentLevel => parseInt(evolution?['currentLevel']) ?? 1;
  String get _levelName => parseString(evolution?['levelName']) ?? 'Level $_currentLevel';
  String get _nextLevelName => parseString(evolution?['nextLevelName']) ?? 'Level ${_currentLevel + 1}';

  /// Stage-based XP thresholds — matches backend xp.service.ts XP_BRACKETS.
  static int _xpForStage(int stage) {
    if (stage <= 5) return 50;
    if (stage <= 15) return 75;
    if (stage <= 25) return 100;
    if (stage <= 35) return 150;
    if (stage <= 45) return 200;
    return 250;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Level $_currentLevel, $_levelName, ${(_xpProgress * 100).round()}% progress, $_xpCurrent of $_xpForNextLevel XP',
      child: PremiumDoubleBezel(
        outerRadius: DesignTokens.radius2xl,
        gap: 5.0,
        outerColor: context.colorScheme.tertiary.withValues(alpha: 0.06),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.colorScheme.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      border: Border.all(
                        color: context.colorScheme.tertiary.withValues(alpha: DesignTokens.opacitySubtle),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      PhosphorIconsLight.sparkle,
                      size: 16,
                      color: context.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.experience,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  border: Border.all(
                    color: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_xpCurrent',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: context.colorScheme.primary,
                            fontSize: DesignTokens.fontSm2,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '/ $_xpForNextLevel ${context.l10n.xpShort}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          PremiumProgressBar(
            value: _xpProgress,
            height: 10,
            progressColor: context.colorScheme.secondary,
            showGlow: true,
            isGlass: true,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_levelName (${context.l10n.levelShort} $_currentLevel)',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ),
              Text(
                '${context.l10n.nextLabel}: $_nextLevelName',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
