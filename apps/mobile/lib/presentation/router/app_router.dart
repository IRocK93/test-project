import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/create_baby_mon_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/main/settings/settings_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verification_screen.dart';

class AppRouter {
  static GoRouter router(bool isLoggedIn) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = isLoggedIn;
        final onAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final onSplash = state.matchedLocation == '/';

        final onVerify = state.matchedLocation == '/verify-email';
        
        if (!loggedIn && !onAuth && !onSplash && !onVerify) {
          return '/login';
        }
        if (loggedIn && (onAuth || onSplash)) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return VerificationScreen(email: email);
          },
        ),
         GoRoute(path: '/create-baby-mon', builder: (context, state) => const CreateBabyMonScreen()),
         GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
         GoRoute(
           path: '/reset-password',
           builder: (context, state) {
             final token = state.uri.queryParameters['token'] ?? '';
             return ResetPasswordScreen(token: token);
           },
         ),
         GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    );
  }
}
