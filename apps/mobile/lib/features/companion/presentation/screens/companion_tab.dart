import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/features/companion/presentation/screens/daily_brief_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/routine_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/milestone_tracker_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/medical_disclaimer_gate.dart';
import 'package:baby_mon/features/companion/presentation/screens/chat_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/advice_feed_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/saved_cards_screen.dart';
import 'package:baby_mon/features/companion/presentation/screens/model_download_screen.dart';
import 'package:baby_mon/features/companion/presentation/widgets/monthly_ai_reminder.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/providers/llm_provider.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/core/constants/api_constants.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';

class CompanionTab extends ConsumerStatefulWidget {
  final String babyMonId;

  const CompanionTab({super.key, required this.babyMonId});

  @override
  ConsumerState<CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends ConsumerState<CompanionTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkReminder();
  }

  Future<void> _checkReminder() async {
    // Small delay to let the tab render first
    await Future<void>.delayed(DesignTokens.durationSlow);
    if (!mounted) return;

    final shouldShow = await MonthlyAIReminder.shouldShow();
    if (shouldShow && mounted) {
      await MonthlyAIReminder.show(context);
    }
  }

  Future<void> _onDisclaimerAccepted() async {
    Navigator.of(context).pop(); // close disclaimer

    // ── Device capability check ───────────────────────────────────
    final deviceCanRun = await ref.read(deviceCanRunLlmProvider.future);
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

    final modelManager = await ref.read(modelManagerProvider.future);
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
      // No model — fetch manifest from backend, then show download
      try {
        final manifestService = ref.read(modelManifestServiceProvider);
        final manifest = await manifestService.fetchManifest('${ApiConstants.baseUrl}/api');

        if (!mounted) return;
        final baseDir = modelManager.baseDirectory;
        final fileName = manifest.url.split('/').last;
        final downloadPath = '$baseDir/$fileName';

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ModelDownloadScreen(
                url: manifest.url,
                destinationPath: downloadPath,
                version: manifest.version,
                sha256: manifest.sha256,
                sizeBytes: manifest.sizeBytes,
                onComplete: () {
                  Navigator.of(context).pop();
                  _openChatAfterDownload();
                },
              ),
            ),
          );
        }
      } catch (_) {
        // Manifest fetch failed — use fallback hardcoded only as last resort
        if (!mounted) return;
        final baseDir = modelManager.baseDirectory;
        const fallbackUrl = 'https://cdn.babymon.app/models/gemma4-e2b-v1-q4km.gguf';
        final downloadPath = '$baseDir/gemma4-e2b-v1-q4km.gguf';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Using offline model configuration. Consider checking your connection for the latest model.'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ModelDownloadScreen(
                url: fallbackUrl,
                destinationPath: downloadPath,
                version: 'gemma4-e2b-v1',
                onComplete: () {
                  Navigator.of(context).pop();
                  _openChatAfterDownload();
                },
              ),
            ),
          );
        }
      }
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

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ModelDownloadScreen(
            url: manifest.url as String,
            destinationPath: downloadPath,
            version: manifest.version as String? ?? '',
            sha256: manifest.sha256 as String? ?? '',
            sizeBytes: manifest.sizeBytes as int?,
            onComplete: () {
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsLight.chatCircleDots),
            tooltip: 'Ask the Companion',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MedicalDisclaimerGate(
                    onAccept: () => _onDisclaimerAccepted(),
                  ),
                ),
              );
            },
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
