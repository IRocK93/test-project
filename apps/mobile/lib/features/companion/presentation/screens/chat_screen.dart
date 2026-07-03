import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';
import 'package:baby_mon/features/companion/domain/models/chat_message.dart';
import 'package:baby_mon/features/companion/presentation/widgets/chat_bubble.dart';
import 'package:baby_mon/features/companion/presentation/widgets/chat_input_bar.dart';
import 'package:baby_mon/features/companion/presentation/widgets/thinking_indicator.dart';
import 'package:baby_mon/features/companion/presentation/providers/companion_provider.dart';
import 'package:baby_mon/features/companion/presentation/providers/llm_provider.dart';
import 'package:baby_mon/features/companion/data/llm/safety_classifier.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String babyMonId;

  const ChatScreen({super.key, required this.babyMonId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messages = <ChatMessage>[];
  final _scrollController = ScrollController();
  bool _isGenerating = false;
  String _babyName = '';
  String _ageInfo = '';
  String _genderInfo = '';
  String _stageInfo = '';
  String _focusInfo = '';

  List<ChatMessage> get _visibleMessages =>
      _messages.where((m) => !m.hidden).toList();

  // ── Medical emergency keyword detection ──────────────────────────
  // These patterns bypass the LLM entirely — if a user's message matches
  // any of them, we respond with a hardcoded emergency instruction instead
  // of sending the query to the on-device model (which may not reliably
  // detect emergencies, especially at INT4 quantization).
  static const _emergencyKeywords = [
    'not breathing',
    'cannot breathe',
    'can\'t breathe',
    'stopped breathing',
    'struggling to breathe',
    'choking',
    'seizure',
    'convulsions',
    'convulsing',
    'unresponsive',
    'unconscious',
    'won\'t wake up',
    'passed out',
    'lost consciousness',
    'blue lips',
    'turning blue',
    'blue around mouth',
    'not moving',
    'bleeding heavily',
    'won\'t stop bleeding',
    'severe bleeding',
    'overdose',
    'want to hurt myself',
    'want to kill myself',
    'want to hurt my baby',
    'anaphylaxis',
    'throat closing',
    'throat swelling shut',
    'can\'t swallow',
    'drowning',
    'nearly drowned',
    'severe burn',
    'third degree burn',
    'electrocuted',
    'fell from height',
    'fell out of window',
    'ingested poison',
    'ate medication',
    'swallowed a battery',
    'allergic reaction swelling',
  ];

  String _emergencyResponse() => context.l10n.emergencyResponseFull;

  bool _isMedicalEmergency(String text) {
    final lower = text.toLowerCase();
    return _emergencyKeywords.any((kw) => lower.contains(kw));
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadBabyContext();
    await _loadModelIfNeeded();
    if (!mounted) return;
    await _warmUpModel();
  }

  Future<void> _loadBabyContext() async {
    final briefData = await ref.read(dailyBriefProvider(widget.babyMonId).future);
    if (!mounted) return;
    setState(() {
      _babyName = briefData['babyName'] as String? ?? 'your baby';
      _ageInfo = briefData['age'] as String? ?? '';
      _genderInfo = briefData['gender'] as String? ?? '';
      _stageInfo = briefData['stageName'] as String? ?? '';
      _focusInfo = briefData['focusOfWeek'] as String? ?? '';
    });
  }

  Future<void> _loadModelIfNeeded() async {
    final inferenceService = ref.read(llmInferenceServiceProvider);
    if (inferenceService.contentOnlyMode) return; // Basic mode — skip

    final modelManager = await ref.read(modelManagerProvider.future);
    final modelPath = await modelManager.getActiveModelPath();
    if (modelPath == null) return; // No active model

    final engine = ref.read(llamadartEngineProvider);
    if (!engine.isLoaded) {
      try {
        await engine.loadModel(modelPath);
      } catch (_) {
        // Failed to load — fall back to content-only
        inferenceService.contentOnlyMode = true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.couldNotLoadModelMessage)),
          );
        }
      }
    }
  }

  /// Sends a hidden "hi" to the model and displays the greeting response.
  Future<void> _warmUpModel() async {
    final inferenceService = ref.read(llmInferenceServiceProvider);
    if (!inferenceService.isReady) return;
    if (!mounted) return;

    setState(() => _isGenerating = true);

    // Add hidden user message + visible assistant placeholder
    _messages.add(ChatMessage(role: ChatRole.user, content: 'hi', hidden: true, timestamp: DateTime.now()));
    _messages.add(ChatMessage(role: ChatRole.assistant, content: '', timestamp: DateTime.now()));
    final assistantIndex = _messages.length - 1;

    final buffer = StringBuffer();
    try {
      final stream = inferenceService.ask(
        babyMonId: widget.babyMonId,
        userMessage: 'hi',
        babyName: _babyName,
        age: _ageInfo,
        gender: _genderInfo,
        stageName: _stageInfo,
        focusOfWeek: _focusInfo,
      );
      await for (final token in stream) {
        buffer.write(token);
        if (mounted) {
          setState(() {
            _messages[assistantIndex] = ChatMessage(
              role: ChatRole.assistant,
              content: buffer.toString(),
              timestamp: DateTime.now(),
            );
          });
        }
      }
    } catch (_) {
      // Warm-up failed — silently skip, user can still chat
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _safetyWarning(SafetyCategory c) {
    switch (c) {
      case SafetyCategory.emergency: return context.l10n.safetyWarningEmergency;
      case SafetyCategory.medication: return context.l10n.safetyWarningMedication;
      case SafetyCategory.antiVaccine: return context.l10n.safetyWarningAntiVax;
      case SafetyCategory.hallucination: return context.l10n.safetyWarningHallucination;
      default: return '';
    }
  }

  @override
  void dispose() {
    // Unload model to free RAM when leaving chat
    final engine = ref.read(llamadartEngineProvider);
    if (engine.isLoaded) engine.unload();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (_isGenerating) return; // Guard against concurrent messages

    // ── Medical emergency detection ──────────────────────────
    // Check BEFORE touching the LLM. If emergency keywords are
    // detected, respond with a hardcoded safety message and
    // never send the query to the on-device model.
    if (_isMedicalEmergency(text)) {
      setState(() {
        _messages.add(ChatMessage(role: ChatRole.user, content: text, timestamp: DateTime.now()));
        _messages.add(ChatMessage(role: ChatRole.assistant, content: _emergencyResponse(), timestamp: DateTime.now()));
      });
      _scrollToBottom();
      return;
    }

    final inferenceService = ref.read(llmInferenceServiceProvider);
    if (!inferenceService.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.modelNotLoaded)));
      return;
    }
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, content: text, timestamp: DateTime.now()));
      _isGenerating = true;
    });
    _scrollToBottom();

    final responseBuffer = StringBuffer();
    final assistantMessage = ChatMessage(role: ChatRole.assistant, content: '', timestamp: DateTime.now());
    final assistantIndex = _messages.length;
    setState(() => _messages.add(assistantMessage));

    inferenceService.ask(
      babyMonId: widget.babyMonId,
      userMessage: text,
      babyName: _babyName,
      age: _ageInfo,
      gender: _genderInfo,
      stageName: _stageInfo,
      focusOfWeek: _focusInfo,
    ).listen(
      (token) {
        responseBuffer.write(token);
        if (mounted) setState(() => _messages[assistantIndex] = ChatMessage(role: ChatRole.assistant, content: responseBuffer.toString(), timestamp: assistantMessage.timestamp));
      },
      onDone: () {
        // Run safety classifier on completed response
        final fullResponse = responseBuffer.toString();
        final safety = SafetyClassifier.check(fullResponse);
        if (safety.flagged && mounted) {
          setState(() {
            _messages[assistantIndex] = ChatMessage(
              role: ChatRole.assistant,
              content: '$fullResponse${context.l10n.safetyWarningPrefix}${_safetyWarning(safety.category)}',
              timestamp: assistantMessage.timestamp,
            );
          });
        }
        if (mounted) setState(() => _isGenerating = false);
        _scrollToBottom();
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
            _messages[assistantIndex] = ChatMessage(role: ChatRole.assistant, content: context.l10n.errorGeneratingResponse, timestamp: assistantMessage.timestamp);
          });
        }
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(DesignTokens.durationInstant, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: DesignTokens.durationNormal, curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.askCompanion),
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsLight.info, color: context.textSecondary),
            tooltip: context.l10n.aboutAiCompanion,
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _visibleMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(DesignTokens.spaceLg),
                    itemCount: _visibleMessages.length + (_isGenerating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _visibleMessages.length) return const ThinkingIndicator();
                      return ChatBubble(message: _visibleMessages[index]);
                    },
                  ),
          ),
          ChatInputBar(onSend: _sendMessage, enabled: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceXl),
              decoration: BoxDecoration(color: context.colorScheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(PhosphorIconsLight.chatCircleDots, size: 48, color: context.colorScheme.primary),
            ),
            const SizedBox(height: DesignTokens.spaceXl),
            Text(context.l10n.askCompanion, style: const TextStyle(fontSize: DesignTokens.fontXl2, fontWeight: FontWeight.w700)),
            const SizedBox(height: DesignTokens.spaceSm),
            Text(
              'I\'m powered by an on-device AI that runs entirely on your phone. '
              'Your questions and your child\'s data never leave your device.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: DesignTokens.fontMd2, color: context.textSecondary, height: 1.5),
            ),
            const SizedBox(height: DesignTokens.space2xl),
            _suggestionChip('What should my 4-month-old\'s sleep schedule look like?'),
            _suggestionChip(context.l10n.isItNormalRefuseSolids),
            _suggestionChip(context.l10n.whenConcernedFever),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 13)),
        avatar: const Icon(PhosphorIconsLight.lightbulb, size: 16),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.aboutAiCompanion),
        content: Text(context.l10n.aboutAiCompanionDialogText),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.gotIt))],
      ),
    );
  }
}
