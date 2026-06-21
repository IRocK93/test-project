import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/glass_surface.dart';
import 'package:baby_mon/features/companion/presentation/providers/advice_feed_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

// ─── Category definitions (file-private) ──────────────────────────

class _CategoryInfo {
  final String? key;
  final String label;
  final IconData icon;
  const _CategoryInfo({this.key, required this.label, required this.icon});
}

const _categories = [
  _CategoryInfo(key: null, label: 'All', icon: PhosphorIconsLight.lightbulb),
  _CategoryInfo(key: 'GROWTH_HEALTH', label: 'Health', icon: PhosphorIconsLight.heartbeat),
  _CategoryInfo(key: 'DEVELOPMENT', label: 'Development', icon: PhosphorIconsLight.brain),
  _CategoryInfo(key: 'NUTRITION_FEEDING', label: 'Nutrition', icon: PhosphorIconsLight.appleLogo),
  _CategoryInfo(key: 'SLEEP', label: 'Sleep', icon: PhosphorIconsLight.moon),
  _CategoryInfo(key: 'PLAY_ACTIVITIES', label: 'Play', icon: PhosphorIconsLight.puzzlePiece),
  _CategoryInfo(key: 'PARENT_WELLBEING', label: 'Wellbeing', icon: PhosphorIconsLight.heart),
];

// ─── Helper builders ──────────────────────────────────────────────

Widget _categoryChip(BuildContext context, String category) {
  final cat = _categories
      .where((c) => c.key != null)
      .cast<_CategoryInfo?>()
      .firstWhere((c) => c!.key == category, orElse: () => null);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm, vertical: 3),
    decoration: BoxDecoration(
      color: context.colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(cat?.icon ?? PhosphorIconsLight.lightbulb, size: 12, color: context.colorScheme.primary),
        const SizedBox(width: DesignTokens.spaceXs),
        Text(
          cat?.label ?? category,
          style: TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w600, color: context.colorScheme.primary),
        ),
      ],
    ),
  );
}

Widget _expertBadge(BuildContext context, String voice) {
  final isClinical = voice == 'CLINICAL';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm, vertical: 3),
    decoration: BoxDecoration(
      color: isClinical ? context.colorScheme.primary.withValues(alpha: 0.1) : context.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
    ),
    child: Text(
      isClinical
          ? 'Clinical Guide'
          : voice == 'DEVELOPMENT'
              ? 'Development Guide'
              : 'General Guide',
      style: TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w600, color: context.colorScheme.primary),
    ),
  );
}

// ─── Screen ───────────────────────────────────────────────────────

class AdviceFeedScreen extends ConsumerWidget {
  final String babyMonId;

  const AdviceFeedScreen({super.key, required this.babyMonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adviceFeedProvider(babyMonId));
    final notifier = ref.read(adviceFeedProvider(babyMonId).notifier);

    return Scaffold(
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spaceLg,
              DesignTokens.spaceMd,
              DesignTokens.spaceLg,
              DesignTokens.spaceXs,
            ),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.spaceSm),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = state.selectedCategory == cat.key;
                  return FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 16),
                        const SizedBox(width: DesignTokens.spaceXs + 2),
                        Text(cat.label, style: const TextStyle(fontSize: DesignTokens.fontSm2)),
                      ],
                    ),
                    onSelected: (_) => notifier.changeCategory(cat.key),
                    selectedColor: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                    checkmarkColor: context.colorScheme.primary,
                    side: BorderSide.none,
                    backgroundColor: context.cardSurface,
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          // Content area
          Expanded(child: _buildContent(context, state, notifier)),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AdviceFeedState state,
    AdviceFeedNotifier notifier,
  ) {
    // Initial centered loading
    if (state.isInitialLoad && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state with retry
    if (state.error != null && state.cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space3xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsLight.wifiX, size: 48, color: context.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(height: DesignTokens.spaceMd),
              Text('Couldn\'t load advice', style: TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600, color: context.textSecondary)),
              const SizedBox(height: DesignTokens.spaceSm),
              Text(state.error!, textAlign: TextAlign.center, style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.textCaption)),
              const SizedBox(height: DesignTokens.spaceXl),
              ElevatedButton.icon(
                onPressed: () => notifier.retry(),
                icon: const Icon(PhosphorIconsLight.arrowCounterClockwise, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state (after successful load, no results)
    if (state.cards.isEmpty && !state.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsLight.notebook, size: 48, color: context.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: DesignTokens.spaceMd),
            Text('No advice cards yet', style: TextStyle(color: context.textSecondary)),
          ],
        ),
      );
    }

    // Card list
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      itemCount: state.cards.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.cards.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceLg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final card = state.cards[index];
        final cardId = card['id'] as String? ?? '';
        return _AdviceCard(
          card: card,
          isBookmarked: state.bookmarkedIds.contains(cardId),
          rating: state.ratings[cardId],
          onToggleBookmark: () => notifier.toggleBookmark(cardId),
          onRate: (helpful) => notifier.rateCard(cardId, helpful),
        );
      },
    );
  }
}

// ─── Advice Card Widget ──────────────────────────────────────────

class _AdviceCard extends StatefulWidget {
  final Map<String, dynamic> card;
  final bool isBookmarked;
  final bool? rating; // null = unrated, true = helpful, false = not helpful
  final VoidCallback onToggleBookmark;
  final void Function(bool helpful) onRate;

  const _AdviceCard({
    required this.card,
    required this.isBookmarked,
    required this.rating,
    required this.onToggleBookmark,
    required this.onRate,
  });

  @override
  State<_AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<_AdviceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final category = card['category'] as String? ?? '';
    final expertVoice = card['source'] as String? ?? 'CLINICAL';
    final isRedFlag = card['isRedFlag'] as bool? ?? false;

    return GlassSurface(
      borderRadius: DesignTokens.radiusMd,
      blurSigma: DesignTokens.glassBlurLight,
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
      borderColor: isRedFlag ? context.colorScheme.error.withValues(alpha: 0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: category chip, red-flag badge, bookmark, source badge ──
          Row(
            children: [
              _categoryChip(context, category),
              const SizedBox(width: DesignTokens.spaceSm),
              if (isRedFlag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm, vertical: DesignTokens.space2xs),
                  decoration: BoxDecoration(
                    color: context.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsLight.warning, size: 12, color: context.colorScheme.error),
                      const SizedBox(width: DesignTokens.spaceXs),
                      Text('Call Doctor', style: TextStyle(fontSize: DesignTokens.fontXs, fontWeight: FontWeight.w700, color: context.colorScheme.error)),
                    ],
                  ),
                ),
              const Spacer(),
              // ── Bookmark button ──
              GestureDetector(
                onTap: widget.onToggleBookmark,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceXs),
                  child: Icon(
                    widget.isBookmarked ? PhosphorIconsFill.bookmarkSimple : PhosphorIconsLight.bookmarkSimple,
                    size: 20,
                    color: widget.isBookmarked ? context.colorScheme.primary : context.textCaption,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              _expertBadge(context, expertVoice),
            ],
          ),
          const SizedBox(height: 10),
          // ── Title ──
          Text(
            card['title'] as String? ?? '',
            style: const TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600, height: 1.3),
          ),
          const SizedBox(height: DesignTokens.spaceXs + 2),
          // ── Summary ──
          Text(
            card['summary'] as String? ?? '',
            style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 10),
          // ── Expandable content ──
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              child: Text(
                card['content'] as String? ?? '',
                style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary, height: 1.6),
              ),
            ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Semantics(
              label: _expanded ? 'Collapse advice' : 'Expand to read full advice',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: TextStyle(fontSize: DesignTokens.fontSm2, fontWeight: FontWeight.w600, color: context.colorScheme.primary),
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
          ),
          // ── Rating row (only when expanded) ──
          if (_expanded) ...[
            const SizedBox(height: DesignTokens.spaceSm),
            _buildRatingRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    final rating = widget.rating;
    return Row(
      children: [
        Text('Was this helpful?', style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textCaption)),
        const SizedBox(width: DesignTokens.spaceSm),
        GestureDetector(
          onTap: () => widget.onRate(true),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceXs),
            child: Icon(
              rating == true ? PhosphorIconsFill.thumbsUp : PhosphorIconsLight.thumbsUp,
              size: 18,
              color: rating == true ? context.colorScheme.primary : context.textCaption,
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        GestureDetector(
          onTap: () => widget.onRate(false),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceXs),
            child: Icon(
              rating == false ? PhosphorIconsFill.thumbsDown : PhosphorIconsLight.thumbsDown,
              size: 18,
              color: rating == false ? context.colorScheme.primary : context.textCaption,
            ),
          ),
        ),
      ],
    );
  }
}
