import 'package:baby_mon/features/companion/domain/models/chat_message.dart';

/// Manages chat history and builds formatted prompts for the LLM.
///
/// Tracks an approximate token count so callers can avoid overflowing
/// the model's context window before inference is attempted.
class ChatSessionManager {
  static const String _systemPrefix = '<|system|>\n';
  static const String _userPrefix = '<|user|>\n';
  static const String _assistantPrefix = '<|assistant|>\n';
  static const int _defaultMaxHistoryExchanges = 3;

  /// Rough token-to-word factor for English text.
  /// Most English text averages 1.2–1.4 tokens per word; 1.3 is a safe
  /// heuristic for Llama-family tokenizers.
  static const double _tokensPerWord = 1.3;

  /// Soft limit for total prompt tokens (system + history + user).
  /// Defaults to 2048, leaving headroom below common 4096-context models.
  static const int defaultContextLimit = 2048;

  final List<ChatMessage> _history = [];

  /// Estimated total tokens in the current history.
  int get estimatedHistoryTokens => _countTokens(
      _history.map((ChatMessage m) => m.content).join(' '));

  /// Approximate token count for a given [text].
  /// Uses word-count × `_tokensPerWord` as a lightweight heuristic;
  /// sufficient for context-window gating until a proper tokenizer is
  /// integrated.
  static int estimateTokens(String text) => _countTokens(text);

  void addMessage(ChatMessage message) => _history.add(message);

  /// Build a chat prompt, optionally limiting history to fit within
  /// [tokenBudget].  When [tokenBudget] is omitted, [defaultContextLimit]
  /// is used.
  ///
  /// Returns `null` when even the system prompt + user message would
  /// exceed the budget, signalling to the caller that the input is
  /// too long.
  String? buildPrompt({
    required String systemPrompt,
    required String userMessage,
    int maxHistoryExchanges = _defaultMaxHistoryExchanges,
    int? tokenBudget,
  }) {
    final int budget = tokenBudget ?? defaultContextLimit;
    final int systemTokens = _countTokens(systemPrompt);
    final int userTokens = _countTokens(userMessage);
    final int overheadTokens = _countTokens(
        '$_systemPrefix$_userPrefix$_assistantPrefix');

    // Absolute minimum: system + user + overhead
    if (systemTokens + userTokens + overheadTokens > budget) return null;

    int remaining = budget - systemTokens - userTokens - overheadTokens;

    final buffer = StringBuffer();
    buffer.write(_systemPrefix);
    buffer.writeln(systemPrompt);

    // Walk backwards through history, including exchanges that fit
    final List<ChatMessage> included = [];
    for (int i = _history.length - 1; i >= 0 && remaining > 0; i -= 2) {
      // Grab the user-assistant pair ending at i
      final int userIdx = i - (i % 2 == 0 ? 1 : 0);
      if (userIdx < 0) continue;
      final int assistantIdx = userIdx + 1;

      final String userText = _history[userIdx].content;
      final String assistantText =
          assistantIdx < _history.length ? _history[assistantIdx].content : '';
      final int pairTokens =
          _countTokens(userText) + _countTokens(assistantText);

      if (pairTokens <= remaining) {
        included.insert(0, _history[assistantIdx]);
        included.insert(0, _history[userIdx]);
        remaining -= pairTokens;
      } else {
        break; // can't fit this pair — stop including older history
      }
    }

    // Apply the exchange cap as well
    final int exchangeCap = maxHistoryExchanges * 2;
    final int startIdx =
        (included.length - exchangeCap).clamp(0, included.length);
    for (int i = startIdx; i < included.length; i++) {
      final message = included[i];
      buffer.write(_roleToPrefix(message.role));
      buffer.writeln(message.content);
    }

    buffer.write(_userPrefix);
    buffer.writeln(userMessage);
    buffer.write(_assistantPrefix);
    return buffer.toString();
  }

  void clearHistory() => _history.clear();

  String _roleToPrefix(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return _userPrefix;
      case ChatRole.assistant:
        return _assistantPrefix;
    }
  }

  static int _countTokens(String text) {
    if (text.isEmpty) return 0;
    // Split on whitespace, strip punctuation-only "words"
    final words = text
        .split(RegExp(r'\s+'))
        .where((String w) => w.replaceAll(RegExp(r'[^\w]'), '').isNotEmpty)
        .length;
    return (words * _tokensPerWord).ceil();
  }
}
