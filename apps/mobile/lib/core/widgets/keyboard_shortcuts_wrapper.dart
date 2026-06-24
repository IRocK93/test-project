import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the entire app with keyboard shortcuts for tablet/Bluetooth-keyboard users.
///
/// Alt+1..4 switch tabs (Dashboard, Milestones, Feeding, Health).
/// Escape navigates back.
class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final void Function(int index)? onTabSwitch;
  final VoidCallback? onBack;

  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onTabSwitch,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: _buildShortcuts(),
      child: Actions(
        actions: _buildActions(),
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return <ShortcutActivator, Intent>{
      LogicalKeySet(LogicalKeyboardKey.digit1, LogicalKeyboardKey.alt):
          const _TabSwitchIntent(0),
      LogicalKeySet(LogicalKeyboardKey.digit2, LogicalKeyboardKey.alt):
          const _TabSwitchIntent(1),
      LogicalKeySet(LogicalKeyboardKey.digit3, LogicalKeyboardKey.alt):
          const _TabSwitchIntent(2),
      LogicalKeySet(LogicalKeyboardKey.digit4, LogicalKeyboardKey.alt):
          const _TabSwitchIntent(3),
      LogicalKeySet(LogicalKeyboardKey.escape): const _BackIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions() {
    return <Type, Action<Intent>>{
      _TabSwitchIntent: CallbackAction<_TabSwitchIntent>(
        onInvoke: (intent) {
          onTabSwitch?.call(intent.index);
          return null;
        },
      ),
      _BackIntent: CallbackAction<_BackIntent>(
        onInvoke: (intent) {
          onBack?.call();
          return null;
        },
      ),
    };
  }
}

class _TabSwitchIntent extends Intent {
  final int index;
  const _TabSwitchIntent(this.index);
}

class _BackIntent extends Intent {
  const _BackIntent();
}
