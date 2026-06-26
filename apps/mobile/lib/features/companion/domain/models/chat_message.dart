import 'package:flutter/foundation.dart';

enum ChatRole { user, assistant }

@immutable
class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final bool hidden;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.hidden = false,
  });

  bool get isUser => role == ChatRole.user;
}
