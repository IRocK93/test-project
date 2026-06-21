import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class MilestoneTrackerScreen extends ConsumerStatefulWidget {
  final String babyMonId;

  const MilestoneTrackerScreen({super.key, required this.babyMonId});

  @override
  ConsumerState<MilestoneTrackerScreen> createState() => _MilestoneTrackerScreenState();
}

class _MilestoneTrackerScreenState extends ConsumerState<MilestoneTrackerScreen> {
  String? _selectedDomain;

  static const _domains = [
    {'key': null, 'label': 'All', 'icon': PhosphorIconsLight.star},
    {'key': 'GROSS_MOTOR', 'label': 'Gross Motor', 'icon': PhosphorIconsLight.personSimpleRun},
    {'key': 'FINE_MOTOR', 'label': 'Fine Motor', 'icon': PhosphorIconsLight.hand},
    {'key': 'LANGUAGE_COMMUNICATION', 'label': 'Language', 'icon': PhosphorIconsLight.chatCircle},
    {'key': 'COGNITIVE', 'label': 'Cognitive', 'icon': PhosphorIconsLight.brain},
    {'key': 'SOCIAL_EMOTIONAL', 'label': 'Social', 'icon': PhosphorIconsLight.smiley},
  ];

  @override
  Widget build(BuildContext context) {
    final milestonesAsync = ref.watch(milestonesProvider(widget.babyMonId));

    return milestonesAsync.when(
      data: (data) => _buildContent(data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsLight.warning, size: 48, color: context.textSecondary),
            const SizedBox(height: 12),
            Text('Unable to load milestones', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.invalidate(milestonesProvider(widget.babyMonId)),
              icon: const Icon(PhosphorIconsLight.arrowCounterClockwise, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final domains = data['domains'] as Map<String, dynamic>? ?? {};
    final allMilestones = <Map<String, dynamic>>[];

    for (final entry in domains.entries) {
      final list = (entry.value as List<dynamic>?) ?? [];
      for (final m in list) {
        allMilestones.add({...m as Map<String, dynamic>, '_domain': entry.key});
      }
    }

    final filtered = _selectedDomain == null
        ? allMilestones
        : allMilestones.where((m) => m['_domain'] == _selectedDomain).toList();

    final achieved = filtered.where((m) => m['status'] == 'ACHIEVED').length;
    final total = filtered.length;

    return Column(
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          color: context.colorScheme.primary.withValues(alpha: 0.05),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(PhosphorIconsLight.medal, color: context.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$achieved of $total milestones achieved',
                    style: const TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track your baby\'s progress',
                    style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              if (total > 0)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: achieved / total,
                        strokeWidth: 4,
                        backgroundColor: context.textSecondary.withValues(alpha: DesignTokens.opacitySubtle),
                        valueColor: AlwaysStoppedAnimation(context.colorScheme.primary),
                      ),
                      Center(
                        child: Text(
                          '${((achieved / total) * 100).round()}%',
                          style: const TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Domain filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.spaceSm, DesignTokens.spaceLg, DesignTokens.spaceXs),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _domains.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final d = _domains[index];
                final isSelected = _selectedDomain == d['key'];
                return FilterChip(
                  selected: isSelected,
                  label: Text(d['label'] as String, style: const TextStyle(fontSize: DesignTokens.fontSm)),
                  avatar: Icon(d['icon'] as IconData, size: 16),
                  onSelected: (_) => setState(() => _selectedDomain = d['key'] as String?),
                  selectedColor: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle),
                  checkmarkColor: context.colorScheme.primary,
                  side: BorderSide.none,
                );
              },
            ),
          ),
        ),

        // Milestone list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsLight.checkCircle, size: 48, color: context.textSecondary.withValues(alpha: DesignTokens.opacityDim)),
                      const SizedBox(height: 12),
                      Text('No milestones in this category', style: TextStyle(color: context.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildMilestoneCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    final isAchieved = milestone['status'] == 'ACHIEVED';
    final redFlagText = milestone['redFlagText'] as String?;
    final activityPrompt = milestone['activityPrompt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: isAchieved
            ? context.colorScheme.primary.withValues(alpha: 0.05)
            : context.cardSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: isAchieved
              ? context.colorScheme.primary.withValues(alpha: 0.2)
              : (redFlagText != null
                  ? context.colorScheme.error.withValues(alpha: 0.2)
                  : context.textSecondary.withValues(alpha: 0.08)),
        ),
      ),
      child: InkWell(
        onTap: isAchieved ? null : () => _achieveMilestone(milestone),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => isAchieved ? null : _achieveMilestone(milestone),
                child: Semantics(
                  label: isAchieved ? 'Achieved: ${milestone['title']}' : 'Mark achieved: ${milestone['title']}',
                  child: Container(
                    width: 44, height: 44,
                  margin: const EdgeInsets.only(top: DesignTokens.space2xs),
                  decoration: BoxDecoration(
                    color: isAchieved ? context.colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAchieved ? context.colorScheme.primary : context.textSecondary.withValues(alpha: DesignTokens.opacityDim),
                      width: 2,
                    ),
                  ),
                  child: isAchieved
                      ? const Icon(PhosphorIconsLight.check, size: 14, color: Colors.white)
                      : null,
                ),
              )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      milestone['title'] as String? ?? '',
                      style: TextStyle(
                        fontSize: DesignTokens.fontMd2,
                        fontWeight: FontWeight.w600,
                        color: isAchieved ? context.textSecondary : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      milestone['description'] as String? ?? '',
                      style: TextStyle(fontSize: DesignTokens.fontSm2, color: context.textSecondary, height: 1.4),
                    ),
                    // Red flag
                    if (redFlagText != null && !isAchieved) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(DesignTokens.spaceSm),
                        decoration: BoxDecoration(
                          color: context.colorScheme.error.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(PhosphorIconsLight.warning, size: 14, color: context.colorScheme.error),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                redFlagText,
                                style: TextStyle(fontSize: DesignTokens.fontSm, color: context.colorScheme.error, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Activity prompt
                    if (activityPrompt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(PhosphorIconsLight.lightbulb, size: 14, color: context.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              activityPrompt,
                              style: TextStyle(fontSize: DesignTokens.fontSm, color: context.colorScheme.primary, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // XP reward
                    if (!isAchieved && (milestone['xpReward'] as int? ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(PhosphorIconsLight.star, size: 14, color: context.textCaption),
                          const SizedBox(width: 4),
                          Text(
                            '+${milestone['xpReward']} XP',
                            style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textCaption, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                    // Achieved date
                    if (isAchieved && milestone['achievedAt'] != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Achieved!',
                        style: TextStyle(fontSize: DesignTokens.fontSm, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _achieveMilestone(Map<String, dynamic> milestone) async {
    final repo = ref.read(companionRepositoryProvider);
    final id = milestone['id'] as String;
    try {
      await repo.achieveMilestone(widget.babyMonId, id);
      ref.invalidate(milestonesProvider(widget.babyMonId));
      ref.invalidate(dailyBriefProvider(widget.babyMonId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Milestone achieved! +${milestone['xpReward'] ?? 10} XP'),
            backgroundColor: context.colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save milestone')),
        );
      }
    }
  }
}
