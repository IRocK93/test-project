import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

/// Navigates back if possible, otherwise goes to the home route.
/// Use as the `onBack` callback for [ScreenHeader] throughout the app.
void popOrGoHome(BuildContext context) {
  if (GoRouter.of(context).canPop()) {
    GoRouter.of(context).pop();
  } else {
    GoRouter.of(context).go('/home');
  }
}
