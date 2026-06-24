import 'package:baby_mon/features/companion/domain/models/chat_message.dart';

/// Tracks chat history for UI display and inference context.
///
/// The actual prompt formatting and context-window management is handled
/// by llamadart's ChatSession. This class only tracks messages for the UI.
class ChatSessionManager {
  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  void addMessage(ChatMessage message) => _history.add(message);

  void clearHistory() => _history.clear();
}
