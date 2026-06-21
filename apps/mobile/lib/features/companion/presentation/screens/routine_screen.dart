import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  final String babyMonId;

  const RoutineScreen({super.key, required this.babyMonId});

  @override
  ConsumerState<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends ConsumerState<RoutineScreen> {
  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(routineProvider(widget.babyMonId));

    return routineAsync.when(
      data: (data) => _buildContent(data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsLight.warning, size: 48, color: context.textSecondary),
            const SizedBox(height: 16),
            Text('Unable to load routine', style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.invalidate(routineProvider(widget.babyMonId)),
              icon: const Icon(PhosphorIconsLight.arrowCounterClockwise, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final template = data['template'] as Map<String, dynamic>? ?? {};
    final userRoutine = data['userRoutine'] as Map<String, dynamic>? ?? {};
    final completedSteps = (userRoutine['completedSteps'] as List<dynamic>?)?.cast<String>() ?? [];
    final schedule = (template['sampleSchedule'] as List<dynamic>?) ?? [];
    final bedtimeRitual = (template['bedtimeRitual'] as List<dynamic>?)?.cast<String>() ?? [];
    final title = template['title'] as String? ?? 'Daily Routine';
    final description = template['description'] as String? ?? '';
    final totalSteps = schedule.length + bedtimeRitual.length;
    final completed = completedSteps.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(fontSize: DesignTokens.fontLg2)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colorScheme.primary, context.colorScheme.primary.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.space5xl, DesignTokens.spaceLg, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress
                        Row(
                          children: [
                            Text(
                              '$completed / $totalSteps steps done',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: DesignTokens.fontMd2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                totalSteps > 0 ? '${((completed / totalSteps) * 100).round()}%' : '0%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (totalSteps > 0)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completed / totalSteps,
                              backgroundColor: Colors.white.withValues(alpha: DesignTokens.opacityDim),
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.spaceLg, DesignTokens.spaceLg, DesignTokens.spaceSm),
              child: Text(
                description,
                style: TextStyle(fontSize: DesignTokens.fontMd, color: context.textSecondary, height: 1.5),
              ),
            ),
          ),

          // Schedule section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.spaceLg, DesignTokens.spaceLg, DesignTokens.spaceSm),
              child: Row(
                children: [
                  Icon(PhosphorIconsLight.clock, size: 20, color: context.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'TODAY\'S SCHEDULE',
                    style: TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),

          // Timeline
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final step = schedule[index] as Map<String, dynamic>;
                final activity = step['activity'] as String? ?? '';
                final time = step['time'] as String? ?? '';
                final isLast = index == schedule.length - 1;
                final isCompleted = completedSteps.contains(activity);

                return _TimelineStep(
                  time: time,
                  activity: activity,
                  isLast: isLast,
                  isCompleted: isCompleted,
                  onToggle: () => _toggleStep(activity),
                );
              },
              childCount: schedule.length,
            ),
          ),

          // Bedtime ritual section
          if (bedtimeRitual.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.space2xl, DesignTokens.spaceLg, DesignTokens.spaceSm),
                child: Row(
                  children: [
                    Icon(PhosphorIconsLight.moonStars, size: 20, color: context.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'BEDTIME RITUAL',
                      style: TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final step = bedtimeRitual[index];
                  final isLast = index == bedtimeRitual.length - 1;
                  final isCompleted = completedSteps.contains(step);

                  return _TimelineStep(
                    time: '${index + 1}',
                    activity: step,
                    isLast: isLast,
                    isCompleted: isCompleted,
                    onToggle: () => _toggleStep(step),
                    showNumber: true,
                  );
                },
                childCount: bedtimeRitual.length,
              ),
            ),
          ],

          // Spacing
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _toggleStep(String stepLabel) async {
    final repo = ref.read(companionRepositoryProvider);
    try {
      await repo.completeRoutineStep(widget.babyMonId, stepLabel);
      ref.invalidate(routineProvider(widget.babyMonId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update step')),
        );
      }
    }
  }
}

class _TimelineStep extends StatelessWidget {
  final String time;
  final String activity;
  final bool isLast;
  final bool isCompleted;
  final VoidCallback onToggle;
  final bool showNumber;

  const _TimelineStep({
    required this.time,
    required this.activity,
    required this.isLast,
    required this.isCompleted,
    required this.onToggle,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
              SizedBox(width: 44, child: Column(children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Semantics(
                    label: isCompleted ? 'Completed: $activity' : 'Mark complete: $activity',
                    child: Container(
                      width: 44, height: 44,
                      padding: const EdgeInsets.all(DesignTokens.spaceSm),
                      decoration: BoxDecoration(
                        color: isCompleted ? context.colorScheme.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? context.colorScheme.primary : context.textSecondary.withValues(alpha: DesignTokens.opacityDim),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(PhosphorIconsLight.check, size: 14, color: Colors.white)
                          : (showNumber ? Center(
                              child: Text(time, style: TextStyle(fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w700, color: context.textSecondary)),
                            ) : null),
                    ),
                  )),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isCompleted ? context.colorScheme.primary : context.textSecondary.withValues(alpha: DesignTokens.opacitySubtle),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? DesignTokens.spaceSm : DesignTokens.space2xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showNumber)
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSm,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? context.colorScheme.primary : context.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      activity,
                      style: TextStyle(
                        fontSize: DesignTokens.fontMd,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? context.textSecondary : null,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
