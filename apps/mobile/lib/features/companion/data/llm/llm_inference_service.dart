import 'dart:async';
import 'package:baby_mon/features/companion/data/companion_repository.dart';
import 'package:baby_mon/features/companion/data/llm/rag_service.dart';
import 'package:baby_mon/features/companion/data/llm/system_prompt_builder.dart';
import 'package:baby_mon/features/companion/data/llm/chat_session_manager.dart';
import 'package:baby_mon/features/companion/domain/models/chat_message.dart';

/// Abstraction for the on-device LLM engine.
/// Swap in [MockLlmEngine] for testing, [LlamadartEngine] (future) for production.
abstract class LlmEngine {
  Stream<String> generate(String prompt);
  Future<void> loadModel(String path);
  Future<void> unload();
  bool get isLoaded;
}

/// Mock engine for development — returns canned responses with simulated streaming.
class MockLlmEngine implements LlmEngine {
  bool _loaded = false;

  @override
  bool get isLoaded => _loaded;

  @override
  Future<void> loadModel(String path) async { _loaded = true; }

  @override
  Future<void> unload() async { _loaded = false; }

  @override
  Stream<String> generate(String prompt) async* {
    const response = 'Thank you for asking! Based on the content available to me, '
        'I can share that every baby develops at their own pace. '
        'Evidence-based guidance emphasizes that what matters most '
        'is your baby\'s individual trajectory — not comparing to other babies.\n\n'
        'For specific concerns, I always recommend checking with your pediatrician '
        'who knows your child\'s full health history. ';
    for (int i = 0; i < response.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 15));
      yield response[i];
    }
  }
}

/// Orchestrates the full LLM pipeline: RAG retrieval → prompt assembly → inference.
///
/// When [_contentOnlyMode] is true (device cannot run the LLM), responses are
/// keyword-matched parenting advice cards returned directly without AI inference.
class LlmInferenceService {
  final RagService _ragService;
  final ChatSessionManager _sessionManager;
  final LlmEngine _engine;

  /// When true, responses bypass the LLM entirely and return keyword-matched
  /// content cards. Set this on devices that don't meet the LLM requirements.
  bool contentOnlyMode = false;

  LlmInferenceService({
    required CompanionRepository repository,
    required LlmEngine engine,
  })  : _ragService = RagService(repository),
        _sessionManager = ChatSessionManager(),
        _engine = engine;

  ChatSessionManager get sessionManager => _sessionManager;
  LlmEngine get engine => _engine;
  bool get isReady => contentOnlyMode || _engine.isLoaded;

  /// Runs the full inference pipeline and returns a stream of response tokens.
  ///
  /// In [contentOnlyMode], the stream yields a single string containing the
  /// top matched parenting advice cards formatted as readable text.
  Stream<String> ask({
    required String babyMonId,
    required String userMessage,
    required String babyName,
    required String age,
    required String stageName,
    required String focusOfWeek,
    String? sleepSummary,
    String? feedingSummary,
    String? growthSummary,
  }) async* {
    // 1. Retrieve relevant parenting content before adding to history (avoids self-matching)
    final ragContext = await _ragService.retrieveContext(babyMonId, userMessage);

    // 2. Add user message to history
    _sessionManager.addMessage(ChatMessage(role: ChatRole.user, content: userMessage, timestamp: DateTime.now()));

    // ── Content-only fallback path ────────────────────────────────
    if (contentOnlyMode) {
      if (ragContext.isNotEmpty) {
        final response = _buildContentOnlyResponse(ragContext);
        yield response;
        _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: response, timestamp: DateTime.now()));
      } else {
        const response = 'I could not find relevant content for your question. '
            'Try asking about sleep, feeding, development, or health topics. '
            'For medical concerns, please contact your pediatrician.';
        yield response;
        _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: response, timestamp: DateTime.now()));
      }
      return;
    }

    // ── Full LLM inference path ───────────────────────────────────

    // 3. Build system prompt
    final systemPrompt = SystemPromptBuilder.buildSystemPrompt(
      babyName: babyName,
      age: age,
      stageName: stageName,
      focusOfWeek: focusOfWeek,
      ragContext: ragContext,
      sleepSummary: sleepSummary,
      feedingSummary: feedingSummary,
      growthSummary: growthSummary,
    );

    // 4. Build full prompt — userMessage already in history, pass empty
    final prompt = _sessionManager.buildPrompt(
      systemPrompt: systemPrompt,
      userMessage: '',
      tokenBudget: ChatSessionManager.defaultContextLimit,
    );

    // 5. Guard against prompt exceeding context window
    if (prompt == null) {
      const fallback = 'I\'m sorry, but the conversation has grown too long for me to process. '
          'Please start a new chat session so I can continue helping you.';
      yield fallback;
      _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: fallback, timestamp: DateTime.now()));
      return;
    }

    // 6. Run inference and stream tokens
    final buffer = StringBuffer();
    try {
      await for (final token in _engine.generate(prompt)) {
        buffer.write(token);
        yield token;
      }
    } catch (e) {
      yield '\n\n[Error generating response. Please try again.]';
      // Don't rethrow — the error token above communicates the failure
      // to the UI; rethrowing would cause double error handling in the stream listener.
    }

    // 7. Add assistant response to history
    _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: buffer.toString(), timestamp: DateTime.now()));
  }

  /// Formats retrieved parenting content cards as a readable response for
  /// the content-only (non-LLM) fallback mode.
  String _buildContentOnlyResponse(String ragContext) {
    final cards = ragContext.split('---').where((s) => s.trim().isNotEmpty).toList();
    if (cards.isEmpty) return 'No relevant content found.';

    final buffer = StringBuffer();
    buffer.writeln('Here is reviewed information that may help:\n');
    for (final card in cards) {
      final trimmed = card.trim();
      if (trimmed.isEmpty) continue;
      buffer.writeln(trimmed);
      buffer.writeln();
    }
    buffer.writeln('---');
    buffer.writeln('Note: I am running in content-only mode because your device '
        'does not support the on-device AI model. The information above comes '
        'from parenting and child development content.');
    buffer.writeln('For medical concerns, always consult your healthcare provider.');
    return buffer.toString().trim();
  }

  void clearHistory() => _sessionManager.clearHistory();
}
