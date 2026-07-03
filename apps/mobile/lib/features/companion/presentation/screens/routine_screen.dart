import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/core/utils/tier_required_exception.dart';
import 'package:baby_mon/features/companion/data/sync_persistence.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/sync_banner.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/features/companion/presentation/widgets/upgrade_prompt.dart';

class RoutineScreen extends ConsumerStatefulWidget {
  final String babyMonId;

  const RoutineScreen({super.key, required this.babyMonId});

  @override
  ConsumerState<RoutineScreen> createState() => RoutineScreenState();
}

class RoutineScreenState extends ConsumerState<RoutineScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }
  Map<String, String> _keyToActivity = {};
  Timer? _syncDebounce;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final routineAsync = ref.watch(routineProvider(widget.babyMonId));

    return routineAsync.when(
      data: (data) => _buildContent(data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        if (error is TierRequiredException) {
          return const UpgradePromptWidget(
            featureName: 'Routine',
            description: 'Upgrade to Premium to unlock adaptive daily routines '
                'personalized to your baby\'s developmental stage.',
          );
        }
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsLight.warning, size: 48, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(context.l10n.unableToLoadRoutine, style: TextStyle(color: context.textSecondary)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref.invalidate(routineProvider(widget.babyMonId)),
                icon: const Icon(PhosphorIconsLight.arrowCounterClockwise, size: 18),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final template = data['template'] as Map<String, dynamic>?;
    final message = data['message'] as String?;

    // No template available for this stage — show a friendly placeholder
    if (template == null) {
      return _buildNoTemplate(context, message);
    }

    final userRoutine = data['userRoutine'] as Map<String, dynamic>? ?? {};
    final completedSteps = (userRoutine['completedSteps'] as List<dynamic>?)?.cast<String>() ?? [];
    final schedule = (template['sampleSchedule'] as List<dynamic>?) ?? [];
    final bedtimeRitual = (template['bedtimeRitual'] as List<dynamic>?)?.cast<String>() ?? [];

    // Build index→activity mapping for unique keys (avoids identical labels sharing state)
    _keyToActivity = {};
    for (var i = 0; i < schedule.length; i++) {
      final a = schedule[i]['activity'] as String?;
      if (a?.isNotEmpty == true) _keyToActivity['s$i'] = a!;
    }
    for (var i = 0; i < bedtimeRitual.length; i++) {
      _keyToActivity['b$i'] = bedtimeRitual[i];
    }

    // Build reverse map: activity name → key (safe — names are unique per template)
    final activityToKey = {for (final e in _keyToActivity.entries) e.value: e.key};

    // Convert server activity names to index keys, filtering orphaned entries
    final serverSteps = completedSteps
        .map((a) => activityToKey[a])
        .whereType<String>()
        .where(_keyToActivity.containsKey)
        .toSet();
    final totalSteps = schedule.length + bedtimeRitual.length;
    final pendingKeys = ref.watch(pendingRoutineStepsProvider(widget.babyMonId));
    final effectiveCompleted = {...serverSteps};
    for (final k in pendingKeys) {
      if (effectiveCompleted.contains(k)) { effectiveCompleted.remove(k); } else { effectiveCompleted.add(k); }
    }
    final completed = effectiveCompleted.length;
    final title = template['title'] as String? ?? context.l10n.dailyRoutineTitle;
    final description = template['description'] as String? ?? '';

    return Scaffold(
      body: Column(
        children: [
          SyncBanner(
            babyMonId: widget.babyMonId,
            onRetry: () => _triggerSync(),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
          // Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.colorScheme.primary, context.colorScheme.primary.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(DesignTokens.spaceLg, DesignTokens.space3xl, DesignTokens.spaceLg, DesignTokens.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: DesignTokens.fontLg2, fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Progress
                        Row(
                          children: [
                            Text(
                              '$completed / $totalSteps steps done',
                              style: const TextStyle(color: Colors.white, fontSize: DesignTokens.fontSm, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                totalSteps > 0 ? '${((completed / totalSteps) * 100).round()}%' : '0%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                  Text(
                    context.l10n.todaysSchedule,
                    style: const TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w700, letterSpacing: 1.2),
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
                final key = 's$index';
                final isCompleted = effectiveCompleted.contains(key);

                return _TimelineStep(
                  time: time,
                  activity: activity,
                  isLast: isLast,
                  isCompleted: isCompleted,
                  onToggle: () => _toggleStep(key),
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
                    Text(
                      context.l10n.bedtimeRitual,
                      style: const TextStyle(fontSize: DesignTokens.font2xs, fontWeight: FontWeight.w700, letterSpacing: 1.2),
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
                  final key = 'b$index';
                  final isCompleted = effectiveCompleted.contains(key);

                  return _TimelineStep(
                    time: '${index + 1}',
                    activity: step,
                    isLast: isLast,
                    isCompleted: isCompleted,
                    onToggle: () => _toggleStep(key),
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
        ),
        ],
      ),
    );
  }

  Widget _buildNoTemplate(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsLight.clock,
              size: 56,
              color: context.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            Text(
              context.l10n.routineComingSoon,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              message ?? 'We\'re creating a personalized routine for this stage. Check back soon!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStep(String key) {
    final notifier = ref.read(pendingRoutineStepsProvider(widget.babyMonId).notifier);
    final current = {...notifier.state};
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    notifier.state = current;
    SyncPersistence.saveRoutine(widget.babyMonId, current);
    ref.read(syncStatusProvider(widget.babyMonId).notifier).state = SyncStatus.pending;
    // Debounced auto-sync: 3s after last toggle
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 3), () => _triggerSync());
  }

  void _triggerSync() {
    _syncDebounce?.cancel();
    ref.read(syncStatusProvider(widget.babyMonId).notifier).state = SyncStatus.syncing;
    final repo = ref.read(companionRepositoryProvider);
    final pendingKeys = ref.read(pendingRoutineStepsProvider(widget.babyMonId));
    if (pendingKeys.isNotEmpty) {
      // Build the FULL merged list of completed activity names (server + pending
      // toggles) and send as the authoritative list to the backend.
      final fullActivities = _buildFullSyncPayload(pendingKeys);
      repo.syncRoutine(widget.babyMonId, fullActivities).then((_) {
        ref.read(pendingRoutineStepsProvider(widget.babyMonId).notifier).state = <String>{};
        SyncPersistence.saveRoutine(widget.babyMonId, <String>{});
        ref.read(syncStatusProvider(widget.babyMonId).notifier).state = SyncStatus.idle;
        ref.invalidate(routineProvider(widget.babyMonId));
      }).catchError((_) {
        ref.read(syncStatusProvider(widget.babyMonId).notifier).state = SyncStatus.error;
      });
    }
  }

  /// Merges the server's completed steps with pending toggles to produce the
  /// full authoritative list of completed activity names to send to the backend.
  List<String> _buildFullSyncPayload(Set<String> pendingKeys) {
    // Build key↔activity mappings from the provider so this method is
    // self-contained and doesn't depend on _buildContent having run first.
    final data = ref.read(routineProvider(widget.babyMonId)).valueOrNull;
    if (data == null) return [];
    final template = data['template'] as Map<String, dynamic>?;
    if (template == null) return [];
    final schedule = (template['sampleSchedule'] as List<dynamic>?) ?? [];
    final ritual = (template['bedtimeRitual'] as List<dynamic>?)?.cast<String>() ?? [];

    final keyToActivity = <String, String>{};
    for (var i = 0; i < schedule.length; i++) {
      final a = schedule[i]['activity'] as String?;
      if (a?.isNotEmpty == true) keyToActivity['s$i'] = a!;
    }
    for (var i = 0; i < ritual.length; i++) {
      keyToActivity['b$i'] = ritual[i];
    }
    final activityToKey = {for (final e in keyToActivity.entries) e.value: e.key};

    // Read server state and convert activity names to keys
    final userRoutine = data['userRoutine'] as Map<String, dynamic>? ?? {};
    final serverNames =
        (userRoutine['completedSteps'] as List<dynamic>?)?.cast<String>() ?? [];
    final effectiveKeys = serverNames
        .map((a) => activityToKey[a])
        .whereType<String>()
        .where(keyToActivity.containsKey)
        .toSet();

    // Apply pending toggles (add or remove)
    for (final k in pendingKeys) {
      if (effectiveKeys.contains(k)) {
        effectiveKeys.remove(k);
      } else {
        effectiveKeys.add(k);
      }
    }

    // Convert back to activity names for the backend
    return effectiveKeys.map((k) => keyToActivity[k]!).toList();
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
