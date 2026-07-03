import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/utils/theme_text_utils.dart';
import 'package:baby_mon/core/widgets/glass_surface.dart';
import 'package:baby_mon/features/companion/presentation/providers/advice_feed_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/upgrade_prompt.dart';

class SavedCardsScreen extends ConsumerWidget {
  final String babyMonId;

  const SavedCardsScreen({super.key, required this.babyMonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adviceFeedProvider(babyMonId));

    // Show upgrade prompt if this is a tier error
    if (state.isTierError && state.cards.isEmpty) {
      return UpgradePromptWidget(
        featureName: context.l10n.savedCardsTitle,
        description: 'Upgrade to Premium to bookmark and save expert advice '
            'cards to your personal parenting library.',
      );
    }

    final bookmarkedCards = state.cards
        .where((card) => state.bookmarkedIds.contains(card['id'] as String? ?? ''))
        .toList();

    if (bookmarkedCards.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spaceLg,
        DesignTokens.spaceMd,
        DesignTokens.spaceLg,
        DesignTokens.space4xl,
      ),
      itemCount: bookmarkedCards.length,
      itemBuilder: (context, index) {
        final card = bookmarkedCards[index];
        final cardId = card['id'] as String? ?? '';
        return _SavedCard(
          card: card,
          isBookmarked: true,
          onToggleBookmark: () {
            ref.read(adviceFeedProvider(babyMonId).notifier).toggleBookmark(cardId);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsLight.bookmarkSimple,
              size: 56,
              color: context.textCaption.withValues(alpha: 0.4),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Text(
              context.l10n.noSavedCards,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'Bookmark advice cards from the Advice tab to build your personal parenting library.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textCaption,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatefulWidget {
  final Map<String, dynamic> card;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const _SavedCard({
    required this.card,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  @override
  State<_SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<_SavedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final category = card['category'] as String? ?? '';
    final title = card['title'] as String? ?? '';
    final summary = card['summary'] as String? ?? '';
    final source = card['source'] as String? ?? 'CLINICAL';
    final isRedFlag = card['isRedFlag'] as bool? ?? false;

    return GlassSurface(
      borderRadius: DesignTokens.radiusMd,
      blurSigma: DesignTokens.glassBlurLight,
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
      borderColor: isRedFlag
          ? context.colorScheme.error.withValues(alpha: 0.3)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: category chip, red flag, bookmark ──
          Row(
            children: [
              _categoryChip(context, category),
              if (isRedFlag) ...[
                const SizedBox(width: DesignTokens.spaceSm),
                Icon(
                  PhosphorIconsLight.warning,
                  size: 16,
                  color: context.colorScheme.error,
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: widget.onToggleBookmark,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceXs),
                  child: Icon(
                    widget.isBookmarked
                        ? PhosphorIconsFill.bookmarkSimple
                        : PhosphorIconsLight.bookmarkSimple,
                    size: 20,
                    color: widget.isBookmarked
                        ? context.colorScheme.primary
                        : context.textCaption,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Title ──
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spaceXs),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: DesignTokens.spaceSm),
          // ── Expandable content ──
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              child: Text(
                card['content'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
              ),
            ),
          // ── Bottom row: source badge + Read more ──
          Row(
            children: [
              _sourceBadge(context, source),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? context.l10n.showLess : context.l10n.readMore,
                      style: TextStyle(
                        fontSize: DesignTokens.fontSm2,
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceXs),
                    Icon(
                      _expanded ? PhosphorIconsLight.caretUp : PhosphorIconsLight.caretDown,
                      size: 14,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(BuildContext context, String category) {
    if (category.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Text(
        category.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: DesignTokens.font2xs,
          fontWeight: FontWeight.w600,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _sourceBadge(BuildContext context, String source) {
    final label = source == 'CLINICAL'
        ? context.l10n.clinicalGuide
        : source == 'DEVELOPMENT'
            ? context.l10n.developmentGuide
            : context.l10n.generalGuide;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: DesignTokens.font2xs,
          fontWeight: FontWeight.w500,
          color: context.textCaption,
        ),
      ),
    );
  }
}
