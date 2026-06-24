import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/features/companion/domain/models/chat_message.dart';
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _companionAvatar(colorScheme),
            const SizedBox(width: DesignTokens.spaceSm),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: isUser ? colorScheme.primary : context.cardSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(DesignTokens.radiusLg),
                  topRight: const Radius.circular(DesignTokens.radiusLg),
                  bottomLeft: isUser ? const Radius.circular(DesignTokens.radiusLg) : const Radius.circular(DesignTokens.radiusXs),
                  bottomRight: isUser ? const Radius.circular(DesignTokens.radiusXs) : const Radius.circular(DesignTokens.radiusLg),
                ),
                border: isUser ? null : Border.all(color: context.cardBorder),
              ),
              child: RichText(
                text: _parseMarkdown(message.content, isUser ? Colors.white : colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// Lightweight inline parser: **bold** and *italic*.
  static TextSpan _parseMarkdown(String text, Color? defaultColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      // Text before this match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: 15, height: 1.5, color: defaultColor),
        ));
      }
      final matched = match.group(0)!;
      final isBold = matched.startsWith('**');
      final content = matched.substring(isBold ? 2 : 1, matched.length - (isBold ? 2 : 1));
      spans.add(TextSpan(
        text: content,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          fontStyle: isBold ? FontStyle.normal : FontStyle.italic,
          color: defaultColor,
        ),
      ));
      lastEnd = match.end;
    }
    // Remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: 15, height: 1.5, color: defaultColor),
      ));
    }
    return TextSpan(children: spans.isNotEmpty ? spans : [TextSpan(text: text, style: TextStyle(fontSize: 15, height: 1.5, color: defaultColor))]);
  }
  Widget _companionAvatar(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: Image.asset(
        'assets/images/enas_chat.png',
        width: 32,
        height: 32,
        fit: BoxFit.cover,
      ),
    );
  }
}
