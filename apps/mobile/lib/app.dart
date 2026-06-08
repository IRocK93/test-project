import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'presentation/router/app_router.dart';

class BabyMonApp extends ConsumerWidget {
  const BabyMonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return MaterialApp.router(
      title: 'BabyMon',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router(isLoggedIn),
    );
  }
}
