import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/companion/presentation/screens/daily_brief_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/routine_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/milestone_tracker_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/medical_disclaimer_gate.dart';
import 'package:baby_mon/features/companion/presentation/screens/chat_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/advice_feed_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/saved_cards_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_download_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_onboarding_screen.dart';
import 'package:baby_mon/features/companion/presentation/widgets/monthly_ai_reminder.dart';
import 'package:baby_mon/features/companion/data/sync_persistence.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/providers/llm_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/core/constants/api_constants.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/core/widgets/premium_empty_state.dart';

class CompanionTab extends ConsumerStatefulWidget {
  final String babyMonId;
  final int? initialTab;
  final bool openChat;

  const CompanionTab({super.key, required this.babyMonId, this.initialTab, this.openChat = false});

  @override
  ConsumerState<CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends ConsumerState<CompanionTab>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 5, vsync: this);
    _restorePendingState();
    // Retry any previously failed sync
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAll(widget.babyMonId));
    if (widget.initialTab != null) _tabController.index = widget.initialTab!;
    if (widget.openChat) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openChat());
    }
    _checkReminder();
  }

  Future<void> _restorePendingState() async {
    final babyMonId = widget.babyMonId;
    if (babyMonId.isEmpty) return; // no-op for empty/placeholder ID
    final routine = await SyncPersistence.loadRoutine(babyMonId);
    if (routine.isNotEmpty) {
      ref.read(pendingRoutineStepsProvider(babyMonId).notifier).state = routine;
    }
    final achieve = await SyncPersistence.loadAchievements(babyMonId);
    if (achieve.isNotEmpty) {
      ref.read(pendingMilestoneAchievementsProvider(babyMonId).notifier).state = achieve;
    }
    final unachieve = await SyncPersistence.loadUnachievements(babyMonId);
    if (unachieve.isNotEmpty) {
      ref.read(pendingMilestoneUnachievementsProvider(babyMonId).notifier).state = unachieve;
    }
  }

  void _openChat() => _tabController.index = 3;

  Future<void> _checkReminder() async {
    // Small delay to let the tab render first
    await Future<void>.delayed(DesignTokens.durationSlow);
    if (!mounted) return;

    final shouldShow = await MonthlyAIReminder.shouldShow();
    if (shouldShow && mounted) {
      await MonthlyAIReminder.show(context);
    }
  }

  static const _disclaimerKey = 'ai_disclaimer_accepted_at';

  Future<void> _openChatFlow() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final lastAccepted = prefs.getInt(_disclaimerKey);
    final needsDisclaimer = lastAccepted == null ||
        DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(lastAccepted),
        ).inDays >= 14;
    if (needsDisclaimer) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MedicalDisclaimerGate(
            onAccept: _onDisclaimerAccepted,
          ),
        ),
      );
    } else {
      _startChatFlow();
    }
  }

  /// Called when the user accepts the disclaimer. Pops the gate, persists, then
  /// delegates to [\_startChatFlow].
  void _onDisclaimerAccepted() {
    Navigator.of(context).pop(); // dismiss the disclaimer gate
    ref.read(sharedPreferencesProvider.future).then((prefs) {
      prefs.setInt(_disclaimerKey, DateTime.now().millisecondsSinceEpoch);
    });
    _startChatFlow();
  }

  /// Core post-disclaimer flow — device check, model manager, download/chat.
  Future<void> _startChatFlow() async {

    // ── Device capability check ───────────────────────────────────
    bool deviceCanRun;
    try {
      deviceCanRun = await ref.read(deviceCanRunLlmProvider.future);
    } catch (_) {
      deviceCanRun = false;
    }
    if (!mounted) return;

    if (!deviceCanRun) {
      // Device cannot run the LLM — enable content-only mode and open chat.
      final inferenceService = ref.read(llmInferenceServiceProvider);
      inferenceService.contentOnlyMode = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your device does not support on-device AI. '
                'Using parenting content cards instead (no internet required).'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final modelManager;
    try {
      modelManager = await ref.read(modelManagerProvider.future);
    } catch (_) {
      _fallbackToContentOnly();
      return;
    }
    final modelPath = await modelManager.getActiveModelPath();

    if (!mounted) return;

    if (modelPath != null) {
      // Model exists — check for updates first, then load
      try {
        final manifestService = ref.read(modelManifestServiceProvider);
        final manifest = await manifestService.fetchManifest('${ApiConstants.baseUrl}/api');
        final updateVersion = await modelManager.checkForUpdate(manifest.version);
        if (updateVersion != null && mounted) {
          await _showUpdateAvailableDialog(modelManager, manifest);
          return; // Dialog handles re-entry
        }
      } catch (_) {
        // Update check is non-blocking — proceed even if it fails.
      }

      // Load engine and open chat
      final engine = ref.read(llamadartEngineProvider);
      if (!engine.isLoaded) {
        try {
          await engine.loadModel(modelPath);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to load AI model. Please try downloading it again.')),
            );
          }
          return;
        }
      }
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ChatScreen(babyMonId: widget.babyMonId)),
        );
      }
    } else {
      // No model — show onboarding with model selection
      try {
        final manifestService = ref.read(modelManifestServiceProvider);
        final manifest = await manifestService.fetchManifest('${ApiConstants.baseUrl}/api');

        if (!mounted) return;
        final baseDir = modelManager.baseDirectory;
        final defaultUrl = _resolveModelUrl(manifest.url);

        // Check premium status
        bool isPremium = false;
        try {
          final subRes = await ref.read(apiClientProvider).getSubscription();
          final tier = parseJsonMap(subRes.data)?['tier'] as String?;
          isPremium = tier == 'PREMIUM';
        } catch (_) {
          isPremium = false;
        }

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ModelOnboardingScreen(
                manifestUrl: defaultUrl,
                manifestVersion: manifest.version,
                manifestSha256: manifest.sha256,
                manifestSizeBytes: manifest.sizeBytes,
                downloadBaseDir: baseDir,
                isPremium: isPremium,
                onSkip: _openContentChat,
              ),
            ),
          );
        }
      } catch (_) {
        // Manifest fetch failed — use direct HuggingFace URLs, no backend needed
        if (!mounted) return;
        final baseDir = modelManager.baseDirectory;
        const defaultUrl = 'https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf?download=true';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using offline model configuration. Consider checking your connection for the latest model.'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ModelOnboardingScreen(
                manifestUrl: defaultUrl,
                manifestVersion: 'smollm2-360m-v2',
                manifestSizeBytes: 271000000,
                downloadBaseDir: baseDir,
                isPremium: false,
                onSkip: _openContentChat,
              ),
            ),
          );
        }
      }
    }
  }

  String _resolveModelUrl(String url) {
    if (url.startsWith('http')) return url;
    final baseUrl = ApiConstants.baseUrl;
    return '$baseUrl$url';
  }

  void _openContentChat() {
    ref.read(llmInferenceServiceProvider).contentOnlyMode = true;
    Navigator.of(context).pop(); // dismiss download screen
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ChatScreen(babyMonId: widget.babyMonId)),
      );
    }
  }

  void _fallbackToContentOnly() {
    ref.read(llmInferenceServiceProvider).contentOnlyMode = true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI Companion unavailable. Using parenting content cards instead.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _openChatAfterDownload() async {
    final modelManager = await ref.read(modelManagerProvider.future);
    final modelPath = await modelManager.getActiveModelPath();
    if (modelPath != null && mounted) {
      final engine = ref.read(llamadartEngineProvider);
      try {
        await engine.loadModel(modelPath);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load AI model. Please try downloading it again.')),
          );
        }
        return;
      }
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ChatScreen(babyMonId: widget.babyMonId)),
        );
      }
    }
  }

  /// Shows a dialog when a newer model version is available.
  Future<void> _showUpdateAvailableDialog(dynamic modelManager, dynamic manifest) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Model Update Available'),
        content: Text(
          'A newer AI model is available (${manifest.name} ${manifest.version}).\n\n'
          'Updating ensures you have the latest parenting guidance and improvements.\n\n'
          'Download size: ~${(manifest.sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final baseDir = modelManager.baseDirectory;
      final fileName = manifest.url.split('/').last;
      final downloadPath = '$baseDir/$fileName';
      final downloadUrl = _resolveModelUrl(manifest.url);

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ModelDownloadScreen(
            url: downloadUrl,
            destinationPath: downloadPath,
            version: manifest.version as String? ?? '',
            sha256: manifest.sha256 as String? ?? '',
            sizeBytes: manifest.sizeBytes as int?,
            onSkip: _openContentChat, onComplete: () {
              Navigator.of(context).pop();
              _openChatAfterDownload();
            },
          ),
        ),
      );
    } else if (mounted) {
      // User chose "Later" — still open chat with existing model.
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ChatScreen(babyMonId: widget.babyMonId)),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncAll(widget.babyMonId);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.resumed) {
      _syncAll(widget.babyMonId);
    }
  }

  /// Merges the server's completed steps with pending toggles to produce the
  /// full authoritative list of completed activity names to send to the backend.
  List<String> _buildRoutineSyncPayload(String babyMonId, Set<String> pendingKeys) {
    try {
      final data = ref.read(routineProvider(babyMonId)).valueOrNull;
      if (data == null) return [];
      final template = data['template'] as Map<String, dynamic>?;
      if (template == null) return [];
      final schedule = (template['sampleSchedule'] as List<dynamic>?) ?? [];
      final ritual = (template['bedtimeRitual'] as List<dynamic>?)?.cast<String>() ?? [];

      // Build key↔activity mappings
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

      // Apply pending toggles
      for (final k in pendingKeys) {
        if (effectiveKeys.contains(k)) {
          effectiveKeys.remove(k);
        } else {
          effectiveKeys.add(k);
        }
      }

      // Convert back to activity names for the backend
      return effectiveKeys.map((k) => keyToActivity[k]!).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _syncAll(String babyMonId) async {
    final hasPending = await SyncPersistence.hasPending(babyMonId);
    final steps = ref.read(pendingRoutineStepsProvider(babyMonId));
    final achieve = ref.read(pendingMilestoneAchievementsProvider(babyMonId));
    final unachieve = ref.read(pendingMilestoneUnachievementsProvider(babyMonId));
    if (!hasPending && steps.isEmpty && achieve.isEmpty && unachieve.isEmpty) return;

    ref.read(syncStatusProvider(babyMonId).notifier).state = SyncStatus.syncing;
    final repo = ref.read(companionRepositoryProvider);
    var allOk = true;

    if (steps.isNotEmpty) {
      try {
        // Build the FULL merged list of completed activity names (server + pending
        // toggles) and send as the authoritative list to the backend.
        final fullActivities = _buildRoutineSyncPayload(babyMonId, steps);
        if (fullActivities.isNotEmpty) {
          await repo.syncRoutine(babyMonId, fullActivities);
          // Only clear pending after a successful send with a real payload
          ref.read(pendingRoutineStepsProvider(babyMonId).notifier).state = <String>{};
          await SyncPersistence.saveRoutine(babyMonId, <String>{});
        }
      } catch (_) {
        allOk = false;
      }
    }
    for (final id in achieve.toList()) {
      try {
        await repo.achieveMilestone(babyMonId, id);
        final s = {...ref.read(pendingMilestoneAchievementsProvider(babyMonId))}; s.remove(id);
        ref.read(pendingMilestoneAchievementsProvider(babyMonId).notifier).state = s;
        await SyncPersistence.saveAchievements(babyMonId, s);
      } catch (_) { allOk = false; break; }
    }
    for (final id in unachieve.toList()) {
      try {
        await repo.unachieveMilestone(babyMonId, id);
        final s = {...ref.read(pendingMilestoneUnachievementsProvider(babyMonId))}; s.remove(id);
        ref.read(pendingMilestoneUnachievementsProvider(babyMonId).notifier).state = s;
        await SyncPersistence.saveUnachievements(babyMonId, s);
      } catch (_) { allOk = false; break; }
    }

    if (allOk) {
      ref.read(syncStatusProvider(babyMonId).notifier).state = SyncStatus.idle;
      ref.invalidate(routineProvider(babyMonId));
      ref.invalidate(milestonesProvider(babyMonId));
      ref.invalidate(dailyBriefProvider(babyMonId));
    } else {
      ref.read(syncStatusProvider(babyMonId).notifier).state = SyncStatus.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // No BabyMon yet — show the same empty state as other feature screens
    if (widget.babyMonId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Companion'), centerTitle: false),
        body: PremiumEmptyState(
          icon: PhosphorIconsLight.baby,
          title: 'Welcome to BabyMon!',
          subtitle:
              'Create your first BabyMon to unlock the AI Companion — '
              'personalised routines, milestones, and parenting guidance.',
          actionLabel: 'Create BabyMon',
          onAction: () => GoRouter.of(context).push('/create-baby-mon'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsLight.chatCircleDots),
            tooltip: 'Ask the Companion',
            onPressed: () => _openChatFlow(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colorScheme.primary,
          unselectedLabelColor: context.textSecondary,
          indicatorColor: context.colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(PhosphorIconsLight.sun, size: 22),
              text: 'Today',
            ),
            Tab(
              icon: Icon(PhosphorIconsLight.clock, size: 22),
              text: 'Routine',
            ),
            Tab(
              icon: Icon(PhosphorIconsLight.checkCircle, size: 22),
              text: 'Milestones',
            ),
            Tab(
              icon: Icon(PhosphorIconsLight.notebook, size: 22),
              text: 'Advice',
            ),
            Tab(
              icon: Icon(PhosphorIconsLight.bookmarkSimple, size: 22),
              text: 'Saved',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DailyBriefScreen(babyMonId: widget.babyMonId),
          RoutineScreen(babyMonId: widget.babyMonId),
          MilestoneTrackerScreen(babyMonId: widget.babyMonId),
          AdviceFeedScreen(babyMonId: widget.babyMonId),
          SavedCardsScreen(babyMonId: widget.babyMonId),
        ],
      ),
    );
  }
}
