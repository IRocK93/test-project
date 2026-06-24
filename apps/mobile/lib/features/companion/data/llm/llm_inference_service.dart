import 'dart:async';
import 'package:baby_mon/features/companion/data/companion_repository.dart';
import 'package:baby_mon/features/companion/data/llm/rag_service.dart';
import 'package:baby_mon/features/companion/data/llm/system_prompt_builder.dart';
import 'package:baby_mon/features/companion/data/llm/chat_session_manager.dart';
import 'package:baby_mon/features/companion/data/llm/llamadart_engine.dart';
import 'package:baby_mon/features/companion/domain/models/chat_message.dart';

class LlmInferenceService {
  final RagService _ragService;
  final ChatSessionManager _sessionManager;
  final LlamadartEngine _engine;
  bool _sessionStarted = false;

  bool contentOnlyMode = false;

  LlmInferenceService({
    required CompanionRepository repository,
    required LlamadartEngine engine,
  })  : _ragService = RagService(repository),
        _sessionManager = ChatSessionManager(),
        _engine = engine;

  bool get isReady => contentOnlyMode || _engine.isLoaded;

  Stream<String> ask({
    required String babyMonId,
    required String userMessage,
    required String babyName,
    required String age,
    required String gender,
    required String stageName,
    required String focusOfWeek,
    String? sleepSummary,
    String? feedingSummary,
    String? growthSummary,
  }) async* {
    // 1. Retrieve RAG context
    final ragContext = await _ragService.retrieveContext(babyMonId, userMessage);

    // 2. Build system prompt
    final systemPrompt = SystemPromptBuilder.buildSystemPrompt(
      babyName: babyName,
      age: age,
      gender: gender,
      stageName: stageName,
      focusOfWeek: focusOfWeek,
      ragContext: ragContext,
      sleepSummary: sleepSummary,
      feedingSummary: feedingSummary,
      growthSummary: growthSummary,
    );

    // 3. Content-only fallback
    if (contentOnlyMode) {
      _sessionManager.addMessage(ChatMessage(role: ChatRole.user, content: userMessage, timestamp: DateTime.now()));
      if (ragContext.isNotEmpty) {
        final response = _buildContentOnlyResponse(ragContext);
        yield response;
        _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: response, timestamp: DateTime.now()));
      } else {
        const response = 'I could not find relevant content. Try asking about sleep, feeding, development, or health.';
        yield response;
        _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: response, timestamp: DateTime.now()));
      }
      return;
    }

    // 4. Update system prompt each message
    //    First message: full identity + disclaimer + RAG
    //    Subsequent:    context-only (RAG) — stops model from repeating itself
    if (!_sessionStarted) {
      print('[PROMPT] === FIRST (full identity) ===\n$systemPrompt\n=== END ===');
      _engine.startSession(systemPrompt);
      _sessionStarted = true;
    } else {
      final contextPrompt = SystemPromptBuilder.buildContextOnlyPrompt(
        babyName: babyName,
        focusOfWeek: focusOfWeek,
        ragContext: ragContext,
        sleepSummary: sleepSummary,
        feedingSummary: feedingSummary,
        growthSummary: growthSummary,
      );
      print('[PROMPT] === Subsequent (context-only) ===\n$contextPrompt\n=== END ===');
      _engine.updateSystemPrompt(contextPrompt);
    }

    // 5. Track in our session manager (for UI history display)
    _sessionManager.addMessage(ChatMessage(role: ChatRole.user, content: userMessage, timestamp: DateTime.now()));

    // 6. Run inference — llamadart ChatSession handles template, context window, history
    final buffer = StringBuffer();
    try {
      final stream = _engine.sendMessage(userMessage);
      await for (final token in stream) {
        buffer.write(token);
        yield token;
      }
    } catch (e) {
      yield '\n\n[Error generating response. Please try again.]';
      return;
    }

    // 7. Track assistant response
    final response = buffer.toString();
    if (response.isNotEmpty && !response.startsWith('[Error') && !response.startsWith('\n\n[Error')) {
      _sessionManager.addMessage(ChatMessage(role: ChatRole.assistant, content: response, timestamp: DateTime.now()));
    }
  }

  String _buildContentOnlyResponse(String ragContext) {
    final cards = ragContext.split('---').where((s) => s.trim().isNotEmpty).toList();
    if (cards.isEmpty) return 'No relevant content found.';
    final buffer = StringBuffer();
    buffer.writeln('Here is reviewed information:\n');
    for (final card in cards) {
      final trimmed = card.trim();
      if (trimmed.isEmpty) continue;
      buffer.writeln(trimmed);
      buffer.writeln();
    }
    buffer.writeln('For medical concerns, always consult your healthcare provider.');
    return buffer.toString().trim();
  }

  void clearHistory() {
    _sessionManager.clearHistory();
    _engine.resetSession();
  }
}
