import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'core/router/app_router.dart';
import 'core/widgets/keyboard_shortcuts_wrapper.dart';
import 'l10n/app_localizations.dart';

class BabyMonApp extends ConsumerWidget {
  const BabyMonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final style = ref.watch(appVisualStyleProvider);
    final themeMode = ref.watch(themeModeResolverProvider);

    final styleKey = '${style.name}_$isLoggedIn';

    // Keep GoRouter singleton in sync with auth state (avoids recreating router)
    AppRouter.updateLoginState(isLoggedIn);

    return KeyboardShortcutsWrapper(
      onBack: () {
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        }
      },
      child: MaterialApp.router(
        key: ValueKey(styleKey),
        title: 'BabyMon',
        theme: AppTheme.resolve(visualStyle: styleKey, brightness: Brightness.light),
        darkTheme: AppTheme.resolve(visualStyle: styleKey, brightness: Brightness.dark),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.instance,
        // i18n
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
