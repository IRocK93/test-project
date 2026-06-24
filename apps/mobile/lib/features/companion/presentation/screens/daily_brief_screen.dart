import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/utils/tier_required_exception.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/features/companion/presentation/widgets/upgrade_prompt.dart';

class DailyBriefScreen extends ConsumerWidget {
  final String babyMonId;

  const DailyBriefScreen({super.key, required this.babyMonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefAsync = ref.watch(dailyBriefProvider(babyMonId));

    return briefAsync.when(
      data: (data) => _buildContent(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        if (error is TierRequiredException) {
          return const UpgradePromptWidget(featureName: 'Daily Brief');
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsLight.warning, size: 48, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Unable to load companion',
                style: TextStyle(color: context.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(dailyBriefProvider(babyMonId)),
                icon: const Icon(PhosphorIconsLight.arrowCounterClockwise, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final babyName = data['babyName'] as String? ?? 'Your baby';
    final age = data['age'] as String? ?? '';
    final stageName = data['stageName'] as String? ?? '';
    final focusOfWeek = data['focusOfWeek'] as String? ?? '';
    final tipOfDay = data['tipOfDay'] as Map<String, dynamic>?;
    final routinePreview = data['routinePreview'] as Map<String, dynamic>?;
    final upcomingMilestones = (data['upcomingMilestones'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, babyName, age, stageName),
          const SizedBox(height: 24),

          // This Week's Focus
          if (focusOfWeek.isNotEmpty) ...[
            _buildFocusCard(context, focusOfWeek),
            const SizedBox(height: 20),
          ],

          // Tip of the Day
          if (tipOfDay != null) ...[
            _buildTipCard(context, tipOfDay),
            const SizedBox(height: 20),
          ],

          // Routine Preview
          if (routinePreview != null) ...[
            _buildRoutinePreview(context, routinePreview),
            const SizedBox(height: 20),
          ],

          // Upcoming Milestones
          if (upcomingMilestones.isNotEmpty) ...[
            _buildMilestonesSection(context, upcomingMilestones),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String age, String stage) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsLight.star, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name is $age',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: DesignTokens.fontXl,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: DesignTokens.fontMd,
                      ),
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

  Widget _buildFocusCard(BuildContext context, String focus) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsLight.target, color: context.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THIS WEEK\'S FOCUS',
                  style: TextStyle(
                    fontSize: DesignTokens.font2xs,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  focus,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, Map<String, dynamic> tip) {
    final expertVoice = tip['source'] as String? ?? 'CLINICAL';
    final category = tip['category'] as String? ?? '';
    final icon = _categoryIcon(category);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: context.colorScheme.primary.withValues(alpha: DesignTokens.opacitySubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'TIP OF THE DAY',
                style: TextStyle(
                  fontSize: DesignTokens.font2xs,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              _expertBadge(context, expertVoice),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tip['title'] as String? ?? '',
            style: const TextStyle(fontSize: DesignTokens.fontLg, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            tip['summary'] as String? ?? '',
            style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinePreview(BuildContext context, Map<String, dynamic> routine) {
    final sampleSchedule = (routine['sampleSchedule'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsLight.clock, size: 20, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'TODAY\'S ROUTINE',
                style: TextStyle(
                  fontSize: DesignTokens.font2xs,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...sampleSchedule.take(5).map((step) {
            final s = step as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      s['time'] as String? ?? '',
                      style: TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600, color: context.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      s['activity'] as String? ?? '',
                      style: const TextStyle(fontSize: DesignTokens.fontSm2),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (sampleSchedule.length > 5) ...[
            const SizedBox(height: 4),
            Text(
              '+${sampleSchedule.length - 5} more steps — view full routine',
              style: TextStyle(fontSize: DesignTokens.fontSm, color: context.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context, List<dynamic> milestones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(PhosphorIconsLight.checkCircle, size: 20, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'DEVELOPMENTAL MILESTONES',
              style: TextStyle(
                fontSize: DesignTokens.font2xs,
                fontWeight: FontWeight.w700,
                color: context.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...milestones.map((m) {
          final milestone = m as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            decoration: BoxDecoration(
              color: context.cardSurface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              border: Border.all(color: context.textSecondary.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Semantics(
                  label: '${milestone['domain']} milestone: ${milestone['title']}',
                  child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _domainIcon(milestone['domain'] as String? ?? ''),
                    size: 18,
                    color: context.colorScheme.primary,
                  ),
                ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone['title'] as String? ?? '',
                        style: const TextStyle(fontSize: DesignTokens.fontMd, fontWeight: FontWeight.w600),
                      ),
                      if (milestone['activityPrompt'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          milestone['activityPrompt'] as String,
                          style: TextStyle(fontSize: DesignTokens.fontSm, color: context.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _expertBadge(BuildContext context, String voice) {
    final isClinical = voice == 'CLINICAL';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceSm, vertical: DesignTokens.spaceXs),
      decoration: BoxDecoration(
        color: isClinical ? context.colorScheme.primary.withValues(alpha: 0.1) : context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isClinical ? 'Clinical Guide' : 'Development Guide',
        style: TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w600, color: context.colorScheme.primary),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'GROWTH_HEALTH': return PhosphorIconsLight.heartbeat;
      case 'DEVELOPMENT': return PhosphorIconsLight.brain;
      case 'NUTRITION_FEEDING': return PhosphorIconsLight.appleLogo;
      case 'SLEEP': return PhosphorIconsLight.moon;
      case 'PLAY_ACTIVITIES': return PhosphorIconsLight.puzzlePiece;
      case 'PARENT_WELLBEING': return PhosphorIconsLight.heart;
      default: return PhosphorIconsLight.lightbulb;
    }
  }

  IconData _domainIcon(String domain) {
    switch (domain) {
      case 'GROSS_MOTOR': return PhosphorIconsLight.personSimpleRun;
      case 'FINE_MOTOR': return PhosphorIconsLight.hand;
      case 'LANGUAGE_COMMUNICATION': return PhosphorIconsLight.chatCircle;
      case 'COGNITIVE': return PhosphorIconsLight.brain;
      case 'SOCIAL_EMOTIONAL': return PhosphorIconsLight.smiley;
      default: return PhosphorIconsLight.star;
    }
  }
}
