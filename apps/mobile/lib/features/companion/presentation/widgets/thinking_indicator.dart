import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/constants.dart';
import 'package:baby_mon/features/companion/presentation/widgets/companion_theme.dart';

class ThinkingIndicator extends StatefulWidget {
  const ThinkingIndicator({super.key});

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); // Intentional: slow breathing rhythm
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: DesignTokens.space5xl, bottom: DesignTokens.spaceMd),
      child: Row(
        children: [
          _dot(0),
          const SizedBox(width: 6),
          _dot(1),
          const SizedBox(width: 6),
          _dot(2),
          const SizedBox(width: 10),
          Text('Thinking...', style: TextStyle(fontSize: 13, color: context.textCaption)),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    final delay = index * 0.2;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = (_controller.value + delay) % 1.0;
        final scale = t < 0.5 ? 0.4 + t * 1.2 : 1.0 - (t - 0.5) * 1.2;
        return Transform.scale(
          scale: scale.clamp(0.4, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}
