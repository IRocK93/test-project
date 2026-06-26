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

**Effective Date:** June 2026

### 1. Acceptance of Terms
By creating an account and using BabyMon, you agree to these Terms. You must be at least 18 years old.

### 2. Description of Service
BabyMon is a parenting companion app for tracking your child's growth, milestones, feeding, health records, and receiving AI-powered stage guidance.

### 3. Account & Parental Affirmation
- You must provide accurate registration information
- When creating a baby profile, you affirm you are the parent or legal guardian
- You are responsible for maintaining account security

### 4. Subscriptions & Payment
- Free tier: basic tracking, 1 baby profile, 7-day history
- Premium tier (\$4.99/mo): AI Companion, unlimited history, multiple babies, photo album
- 14-day free trial; cancel anytime via Settings → Subscription
- Payments processed by Stripe (PCI-DSS Level 1)

### 5. Medical Disclaimer
**BabyMon is not a medical device.** It does not provide medical advice. Always consult your pediatrician or qualified healthcare provider. In an emergency, call your local emergency number.

### 6. Acceptable Use
Do not: use the app unlawfully, access other accounts, reverse engineer, or upload harmful content.

### 7. User Content
You retain ownership of your data. You grant BabyMon a limited license to process your data solely to provide the service.

### 8. Co-parent Features
Invite-based sharing. Owner controls access. BabyMon is not responsible for co-parent disputes.

### 9. Intellectual Property
BabyMon's code, design, gamification system, and AI content are owned by BabyMon.

### 10. Limitation of Liability
The app is provided "as is." Our liability is limited to the amount paid in the last 12 months.

### 11. Termination
We may suspend accounts for Terms violations. You may delete your account at any time.

### 12. Changes
We notify you 30 days before material changes via in-app notification and email.

### 13. Governing Law
These Terms are governed by applicable consumer protection laws in your jurisdiction.

### 14. Contact
For questions: support@babymon.app
For legal notices: legal@babymon.app
Full terms: docs/legal/terms-and-conditions.md
''';

  static const String _privacyPolicyContent = '''
## Privacy Policy

**Effective Date:** June 2026

### 1. Introduction
BabyMon is a gamified baby-tracking app. This policy explains how we handle your data. We do NOT sell your data or use it for advertising.

### 2. Information We Collect
| Category | Examples | Purpose |
|----------|----------|---------|
| Account | Email, name, password (hashed) | Authentication |
| Child Profile | Name, gender, birth date, blood group, traits | Tracking |
| Health & Growth | Weight, height, allergies, health records | Monitoring |
| Developmental | Milestones, feeding, sleep logs | Gamification |
| Photos/Videos | Child media | Memory album |
| Device | Platform, FCM token | Push notifications |
| Payment | Stripe customer ID only | Subscription |

### 3. How We Use Your Data
- Service delivery (tracking, charts, AI Companion)
- Gamification (XP, badges, evolution stages)
- Co-parent sharing (only with accounts you invite)
- Push notifications (can be disabled)
- Account management (auth, password reset)
- Security (audit logging, abuse prevention)

### 4. Sub-processors
| Provider | Data | Purpose |
|----------|------|---------|
| Neon.tech | Database | Hosting |
| AWS S3 | Photos | Media storage |
| Stripe | Customer ID | Payments |
| SendGrid | Email | Transactional email |
| Firebase | Device token | Notifications |
| Google/Apple/Facebook | OAuth | Optional login |
| Sentry | Error data | Optional tracking |

All sub-processors are under Data Processing Agreements.

### 5. Data Security
- bcrypt password hashing (12 rounds)
- JWT access tokens (15 min) with refresh rotation
- TLS 1.3 encryption in transit
- S3 server-side encryption at rest
- Rate limiting, input validation, audit logging
- Helmet security headers (CSP, HSTS, X-Frame-Options)

### 6. Data Retention
| Data | Retention |
|------|----------|
| Account | Until deletion |
| Child profiles | Until deletion |
| Photos/videos | Until deletion |
| Audit logs | 7 years (pseudonymized after deletion) |

### 7. Your Rights
- **Access**: Export your data (JSON/CSV) via Settings
- **Correction**: Edit any entry at any time
- **Deletion**: Delete account (Settings → Delete Account)
- **Portability**: Download all your data
- **Consent withdrawal**: Disable features or delete account
- **Opt-out**: Disable notifications; unsubscribe from emails

### 8. GDPR Rights (EEA/UK)
Additional rights under GDPR Art. 15-22 including erasure, restriction, objection, and complaint to your supervisory authority. Legal bases: contractual necessity, explicit consent (health data), legitimate interest.

### 9. CCPA Rights (California)
Right to know, delete, opt-out of sale (we do not sell data), and non-discrimination.

### 10. Children's Privacy
BabyMon is for parents, not children. No data is collected directly from children under 16. Parents create and manage all child profiles. See our full Children's Privacy Notice.

### 11. International Transfers
Data is hosted in the US with Standard Contractual Clauses for EEA/UK transfers.

### 12. Breach Notification
We notify affected users and supervisory authorities as required by GDPR Art. 33-34.

### 13. Contact
- Support: support@babymon.app
- Privacy inquiries: privacy@babymon.app
- Data Protection Officer: dpo@babymon.app
- Full policy: docs/legal/privacy-policy.md
''';

  static const String _childrensPrivacyContent = '''
## Children's Privacy Notice

BabyMon is designed for parents, not children.

### We do NOT:
- Allow children under 16 to create accounts
- Collect data directly from children
- Target advertising to children or parents
- Enable public profiles for children
- Share child data with third parties for marketing

### Parental Controls:
- All child data is entered by you, the parent
- You control who sees it (via co-parent invitations)
- You can delete any entry at any time
- You can delete the entire baby profile
- You can export all data for your healthcare provider

### Parental Affirmation:
When creating a baby profile, you affirm you are the parent or legal guardian. This affirmation is timestamped and stored.

### Deletion:
Deleting a baby profile or your account permanently removes all child data from our servers, including photos from AWS S3.

### Contact:
For questions about children's privacy: privacy@babymon.app
Full notice: docs/legal/childrens-privacy-notice.md
''';

  static bool _isLoggedIn = false;

  /// Call this when login state changes (e.g., from app.dart via ref.watch).
  /// Keeps GoRouter as a singleton instead of recreating on every auth change.
  static void updateLoginState(bool loggedIn) {
    _isLoggedIn = loggedIn;
  }

  static final GoRouter instance = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = _isLoggedIn;
      final onAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/';
      final onVerify = state.matchedLocation == '/verify-email';
      final onLegal = state.matchedLocation == '/legal/tos' || state.matchedLocation == '/legal/privacy' || state.matchedLocation == '/legal/childrens-privacy';
      final onLoading = state.matchedLocation == '/loading';
      final onLanguageOnboarding = state.matchedLocation == '/welcome-language';

      if (!loggedIn && !onAuth && !onSplash && !onVerify && !onLegal && !onLoading && !onLanguageOnboarding) {
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
        GoRoute(path: '/welcome-language', pageBuilder: (context, state) => _pageTransition(context: context, state: state, child: const LanguageOnboardingScreen())),
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
        // Route without babyMonId — shows inline "Create BabyMon" empty state
        GoRoute(
          path: '/companion',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: const CompanionTab(babyMonId: ''),
          ),
        ),
        GoRoute(
          path: '/companion/:babyMonId',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: CompanionTab(
              babyMonId: state.pathParameters['babyMonId']!,
              openChat: state.uri.queryParameters['openChat'] == 'true',
              initialTab: int.tryParse(state.uri.queryParameters['initialTab'] ?? ''),
            ),
          ),
        ),
        GoRoute(
          path: '/legal/tos',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: const LegalDocumentScreen(
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
            child: const LegalDocumentScreen(
              title: 'Privacy Policy',
              content: _privacyPolicyContent,
            ),
          ),
        ),
        GoRoute(
          path: '/legal/childrens-privacy',
          pageBuilder: (context, state) => _pageTransition(
            context: context,
            state: state,
            child: const LegalDocumentScreen(
              title: "Children's Privacy",
              content: _childrensPrivacyContent,
            ),
          ),
        ),
      ],
    );
}