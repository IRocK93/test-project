import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';
import 'package:baby_mon/l10n/l10n_ext.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String text) onSend;
  final bool enabled;

  const ChatInputBar({super.key, required this.onSend, this.enabled = true});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceSm, DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: context.cardSurface,
        border: Border(top: BorderSide(color: context.cardBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: context.l10n.askCompanionHint,
                  hintStyle: TextStyle(color: context.textCaption, fontSize: 15),
                  filled: true,
                  fillColor: context.textSecondary.withValues(alpha: 0.06),
                  contentPadding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd, vertical: DesignTokens.spaceSm),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusXl), borderSide: BorderSide.none),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            AnimatedContainer(
              duration: DesignTokens.durationFast,
              decoration: BoxDecoration(
                color: _hasText && widget.enabled ? context.colorScheme.primary : context.textSecondary.withValues(alpha: DesignTokens.opacitySubtle),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
              ),
              child: Semantics(
                label: context.l10n.sendMessage,
                button: true,
                enabled: _hasText && widget.enabled,
                child: IconButton(
                icon: Icon(PhosphorIconsLight.paperPlaneRight, color: _hasText && widget.enabled ? Colors.white : context.textCaption),
                onPressed: _hasText && widget.enabled ? _send : null,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
