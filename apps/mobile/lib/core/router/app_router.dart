import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:baby_mon/core/theme/design_tokens.dart';
import 'package:baby_mon/features/auth/auth.dart';
import 'package:baby_mon/features/splash/splash.dart';
import 'package:baby_mon/features/onboarding/onboarding.dart';
import 'package:baby_mon/features/settings/settings.dart';
import 'package:baby_mon/features/album/album.dart';
import 'package:baby_mon/features/journal/journal.dart';
import 'package:baby_mon/features/health/health.dart';
import 'package:baby_mon/features/discover/discover.dart';
import 'package:baby_mon/features/navigation/presentation/screens/main_screen.dart';
import 'package:baby_mon/features/companion/companion.dart';
import 'package:baby_mon/features/loading/loading.dart';
import 'package:baby_mon/core/widgets/legal_document_screen.dart';

/// Shared page transition builder using slide-up + fade.
/// Uses [DesignTokens.durationPage] and [DesignTokens.curvePremium].
CustomTransitionPage _pageTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: DesignTokens.curveDecelerate),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: DesignTokens.curvePremium)),
          child: child,
        ),
      );
    },
    transitionDuration: DesignTokens.durationPage,
  );
}

class AppRouter {
  static const String _termsOfServiceContent = '''
## Terms of Service

Last updated: June 2026

### 1. Acceptance of Terms
By creating an account and using BabyMon, you agree to these Terms of Service. If you do not agree, do not use the app.

### 2. Description of Service
BabyMon is a parenting companion app that helps you track your child's growth, milestones, feeding, health records, and provides AI-powered parenting guidance. The AI Companion runs entirely on-device and is not a substitute for professional medical advice.

### 3. User Accounts
- You must be at least 18 years old to create an account
- You are responsible for maintaining the confidentiality of your login credentials
- You must provide accurate and complete information during registration

### 4. Acceptable Use
You agree not to:
- Use the app for any unlawful purpose
- Attempt to access another user's account
- Interfere with the app's operation or security
- Use the AI Companion for emergency medical situations

### 5. Disclaimer of Medical Advice
BabyMon is NOT a medical device. It does not diagnose, treat, cure, or prevent any disease or condition. Always consult a qualified healthcare provider for medical advice.

### 6. Limitation of Liability
BabyMon and its developers shall not be liable for any damages arising from your use of the app. The app is provided "as is" without warranty of any kind.

### 7. Changes to Terms
We reserve the right to modify these terms at any time. You will be notified of material changes via email or in-app notification.

### 8. Contact
For questions about these terms, contact: support@babymon.app
''';

  static const String _privacyPolicyContent = '''
## Privacy Policy

Last updated: June 2026

### 1. Information We Collect
- Account information: email address, name, date of birth
- Child information: name, birth date, growth measurements, health records, feeding logs, sleep patterns, milestones
- Device information: device model, OS version (for AI compatibility)

### 2. How We Use Your Information
- To provide and improve the BabyMon service
- To generate growth charts and parenting insights
- To enable the on-device AI Companion
- To send account-related notifications
- To comply with legal obligations

### 3. Data Storage and Security
- Your child's health data is stored securely on our servers
- All AI Companion inference runs entirely on-device — no child health data is sent to external AI services
- We use industry-standard encryption for data in transit and at rest

### 4. Data Retention
We retain your data for as long as your account is active. You may request deletion of your account and associated data at any time.

### 5. Third-Party Services
We use:
- Stripe for payment processing (subscription data only)
- AWS S3 for media storage (photos, documents)
- SendGrid for transactional emails
- Neon (PostgreSQL) for database hosting

### 6. Your Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Delete your account and data
- Export your data
- Withdraw consent at any time

### 7. Children's Privacy
BabyMon is designed for parents to track their children's development. We do not knowingly collect data directly from children under 13.

### 8. Changes to This Policy
We will notify you of material changes via email or in-app notification.

### 9. Contact
For privacy inquiries, contact: privacy@babymon.app
''';

  static GoRouter router(bool isLoggedIn) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = isLoggedIn;
        final onAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final onSplash = state.matchedLocation == '/';
        final onVerify = state.matchedLocation == '/verify-email';
        final onLegal = state.matchedLocation == '/legal/tos' || state.matchedLocation == '/legal/privacy';
        final onLoading = state.matchedLocation == '/loading';
        
        if (!loggedIn && !onAuth && !onSplash && !onVerify && !onLegal && !onLoading) {
          return '/login';
        }
        if (loggedIn && onAuth) {
          return '/loading';
        }
        if (loggedIn && onSplash) {
          return '/loading';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const SplashScreen())),
        GoRoute(path: '/login', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const LoginScreen())),
        GoRoute(path: '/loading', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const PostLoginLoadingScreen())),
        GoRoute(path: '/register', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const RegisterScreen())),
        GoRoute(
          path: '/verify-email',
          pageBuilder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return _pageTransition(context: context, state: state, child: VerificationScreen(email: email));
          },
        ),
        GoRoute(path: '/create-baby-mon', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const CreateBabyMonScreen())),
        GoRoute(path: '/home', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const MainScreen())),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) {
            final token = state.uri.queryParameters['token'] ?? '';
            return _pageTransition(context: context, state: state, child: ResetPasswordScreen(token: token));
          },
        ),
        GoRoute(path: '/settings', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const SettingsScreen())),
        GoRoute(path: '/album', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const AlbumScreen())),
        GoRoute(path: '/journal', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const JournalScreen())),
        GoRoute(path: '/sleep', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const SleepScreen())),
        GoRoute(path: '/growth-chart', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const GrowthChartScreen())),
        GoRoute(path: '/partners', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const PartnersScreen())),
        GoRoute(path: '/subscription', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const SubscriptionScreen())),
        GoRoute(path: '/discover', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const DiscoverScreen())),
        GoRoute(
          path: '/companion/:babyMonId',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: CompanionTab(babyMonId: state.pathParameters['babyMonId']!),
          ),
        ),
        GoRoute(
          path: '/legal/tos',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: LegalDocumentScreen(
              title: 'Terms of Service',
              content: _termsOfServiceContent,
            ),
          ),
        ),
        GoRoute(
          path: '/legal/privacy',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: LegalDocumentScreen(
              title: 'Privacy Policy',
              content: _privacyPolicyContent,
            ),
          ),
        ),
      ],
    );
  }
}
