import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
              child: Text(
                message.content,
                style: TextStyle(fontSize: 15, height: 1.5, color: isUser ? Colors.white : null),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _companionAvatar(ColorScheme colorScheme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary]),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: const ExcludeSemantics(
        child: Icon(PhosphorIconsLight.star, size: 16, color: Colors.white),
      ),
    );
  }
}
