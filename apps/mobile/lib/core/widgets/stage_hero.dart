import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/widgets.dart';

/// A flat, readable hero card for the top of the Dashboard.
///
/// Replaces the 4-deep `PremiumDoubleBezel` stack that was on the
/// previous Dashboard hero. Single 20px-radius card, clear hierarchy:
/// avatar → name+stage → level pill in one row, then meta (age/ETA)
/// on a second row.
///
/// All decoration is flat (no glass blur, no double-bezel). Color comes
/// from a single [accent] parameter which the parent derives from the
/// BabyMon's gender.
class StageHero extends StatelessWidget {
  final String name;
  final String stageLabel;
  final String emoji;
  final int level;
  final Color accent;
  final bool detailsExpanded;
  final VoidCallback onToggleDetails;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final String? ageText;
  final String? etaText;
  final Widget? child;
  /// Optional background tint applied to the card (e.g. gender-reflective shade).
  final Color? backgroundColor;
  /// When true, hides the avatar circle and stage tag entirely (compact mode).
  final bool compact;

  const StageHero({
    super.key,
    required this.name,
    this.stageLabel = '',
    this.emoji = '',
    required this.level,
    required this.accent,
    required this.detailsExpanded,
    required this.onToggleDetails,
    required this.onShare,
    required this.onEdit,
    this.ageText,
    this.etaText,
    this.child,
    this.backgroundColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = context.colorScheme.outlineVariant;
    final cardColor = backgroundColor ?? context.colorScheme.surface;
    final showAvatar = !compact && emoji.isNotEmpty;
    final showStage = !compact && stageLabel.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
      child: Container(
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Primary row: avatar, name+stage, level pill ──
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceLg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showAvatar) ...[
                    // Avatar — single 56x56 circle with accent ring, no double bezel.
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: DesignTokens.spaceMd),
                  ],
                  // Name + stage tag.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                        ),
                        if (showStage) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(DesignTokens.radiusFull),
                            ),
                            child: Text(
                              stageLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Level pill — single filled pill, no nested glass circle.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colorScheme.primary, context.colorScheme.primaryContainer],
                      ),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          PhosphorIconsLight.sparkle,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Lv $level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // ── Meta row: age/ETA + share/edit ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceLg,
              0,
              DesignTokens.spaceLg,
              DesignTokens.spaceLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ageText != null && ageText!.isNotEmpty)
                        Text(
                          ageText!,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (etaText != null && etaText!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            etaText!,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colorScheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Icon buttons — 20px icon in 36x36 hit area (meets 44pt with margin).
                ThemeButton.icon(icon: PhosphorIconsLight.shareNetwork, onPressed: onShare, tooltip: 'Share', variant: ThemeButtonVariant.text, foregroundColor: context.colorScheme.onSurfaceVariant),
                ThemeButton.icon(icon: PhosphorIconsLight.pencilSimple, onPressed: onEdit, tooltip: 'Edit profile', variant: ThemeButtonVariant.text, foregroundColor: context.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          // ── Divider + details toggle ──
          Semantics(
            label: detailsExpanded ? 'Hide details' : 'Show details',
            button: true,
            child: InkWell(
            onTap: onToggleDetails,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    detailsExpanded ? 'Hide details' : 'Show details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: detailsExpanded ? 0.5 : 0,
                    duration: DesignTokens.durationFast,
                  child: Icon(
                    PhosphorIconsLight.caretDown,
                    size: 16,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  ),
                ],
              ),
            ),
            ),
          ),
          // ── Optional details body (renders inside the same card) ──
          AnimatedSize(
            duration: DesignTokens.durationFast,
            curve: Curves.easeInOut,
            child: detailsExpanded && child != null
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.5),
                      border: Border(
                        top: BorderSide(
                          color: borderColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(DesignTokens.spaceLg),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
    );
  }
}
