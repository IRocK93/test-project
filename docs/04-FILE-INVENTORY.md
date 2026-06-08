# 📁 BabyMon — Complete File Inventory

> **Last Updated:** June 5, 2026  
> **Audience:** Anyone needing to find or understand a specific file

---

## apps/mobile/lib/ — Flutter Frontend

### core/

| File | Layer | Purpose |
|------|-------|---------|
| `constants/api_constants.dart` | Core | Base URL (`10.0.2.2:3000`), API path constants, storage keys |
| `constants/app_colors.dart` | Core | Theme colors (primary #9C7CF4, background #FFF8F0) |
| `services/google_sign_in_service.dart` | Core | Google OAuth wrapper → returns ID token |
| `services/apple_sign_in_service.dart` | Core | Apple Sign-In wrapper → returns identity token |
| `services/facebook_sign_in_service.dart` | Core | Facebook OAuth wrapper → returns access token |
| `services/notification_service.dart` | Core | Firebase push notification registration |
| `services/export_service.dart` | Core | PDF/image export generation |

### data/

| File | Layer | Purpose | Key Dependencies |
|------|-------|---------|-----------------|
| `api_client.dart` | Data | Dio HTTP wrapper — ~46 typed methods (all with /api prefix, incl. `getBadgeDefinitions()`), generic get/post/patch/delete, token interceptor with refresh gate + request queuing, 401 refresh logic, BabyMon ID storage | `flutter_secure_storage`, `dio` |

### features/auth/

| File | Layer | Purpose |
|------|-------|---------|
| `domain/entities/user.dart` | Domain | User entity model |
| `domain/repositories/auth_repository.dart` | Domain | Abstract repo: login, register, biometricLogin, forgotPassword, sendVerificationEmail, checkEmailVerified, resetPassword |
| `data/datasources/auth_remote_datasource.dart` | Data | API calls for auth; saves tokens to BOTH SharedPreferences AND FlutterSecureStorage |
| `data/repositories/auth_repository_impl.dart` | Data | Concrete repo implementing AuthRepository |
| `presentation/providers/auth_provider.dart` | Presentation | Feature-level auth provider (NOT the main one) |
| `presentation/screens/verification_screen.dart` | Presentation | Email verification UI |
| `presentation/screens/login_screen.dart` | Presentation | Login form (feature-level, NOT the main one) |
| `presentation/screens/register_screen.dart` | Presentation | Register form (feature-level) |

### presentation/

| File | Layer | Purpose |
|------|-------|---------|
| `providers/auth_provider.dart` | Presentation | **MAIN** provider: apiClientProvider, AuthNotifier, AuthState, authProvider, isLoggedInProvider |
| `router/app_router.dart` | Presentation | GoRouter config — 8 routes with auth redirects |
| `screens/auth/login_screen.dart` | Presentation | Login form + OAuth buttons + biometric + forgot password |
| `screens/auth/register_screen.dart` | Presentation | Register form + OAuth buttons → /verify-email |
| `screens/auth/reset_password_screen.dart` | Presentation | Token-based password reset |
| `screens/splash/splash_screen.dart` | Presentation | App splash → auth redirect |
| `screens/onboarding/create_baby_mon_screen.dart` | Presentation | BabyMon creation form (name, stage, gender, traits) |
| `screens/main/main_screen.dart` | Presentation | 7-tab nav shell + Drawer + **shared AppBar BabyMon selector** (gender-colored pill @ 55% width w/ emoji + name, dropdown for multiple BabyMons) + **notifications bell icon** (replaces former "+" create button). Bumps `appRefreshProvider` on switch to reload all 8 IndexedStack screens. Gender mapping: MONIOUS=Male(blue), MO=Neutral(purple), MONIESE=Female(pink). |
| `screens/main/dashboard/dashboard_screen.dart` | Presentation | **Age-appropriate stages** (Fetus/Neonate/Infant/Toddler/Preschooler/Child) via `_stageLabel` + `_referenceDate`. Compact cards (padding 12, emoji 36, dense). Bold text (w800/w900). XP bar, quick stats, **all locked badges shown** per category, single quick-actions FAB. Uses `_loadInProgress` guard. Stage display uses `_stageStartType` from `getBabyMon()` (NOT `_evolution['currentStage']` which is an int). |
| `screens/main/milestones/milestones_screen.dart` | Presentation | Milestone CRUD list |
| `screens/main/feeding/feeding_screen.dart` | Presentation | Feeding log CRUD with **Metric/Imperial toggle + auto-unit** (ml/fl_oz for breastmilk/formula, g/oz for solid) |
| `screens/main/health/health_screen.dart` | Presentation | **Weight, Height, Head Circumference, Body Temperature** categories + Vax/Visit/Other with **Metric/Imperial toggle + auto-units** (kg/lbs, cm/ft-in, °C/°F). Growth/Sleep nav cards. |
| `screens/main/health/growth_chart_screen.dart` | Presentation | fl_chart LineChart for weight/height/head |
| `screens/main/sleep/sleep_screen.dart` | Presentation | Sleep tracking with date nav + quality dots |
| `screens/main/album/album_screen.dart` | Presentation | Photo grid with camera/gallery upload |
| `screens/main/journal/journal_screen.dart` | Presentation | Unified feed with filter chips + proposals |
| `screens/main/settings/settings_screen.dart` | Presentation | Profile, subscription, partners, export, delete |
| `screens/main/settings/partners_screen.dart` | Presentation | Partner invitation management |
| `screens/main/settings/subscription_screen.dart` | Presentation | Free vs Premium plan comparison |

---

## apps/api/src/ — NestJS Backend

| Module | Files | Purpose |
|--------|-------|---------|
| Core | `main.ts`, `app.module.ts` | Bootstrap, global prefix `/api`, CORS, Swagger |
| Prisma | `prisma/prisma.module.ts`, `prisma/prisma.service.ts` | Database connection (PostgreSQL via Neon.tech) |
| Auth | `auth/auth.controller.ts`, `auth/auth.service.ts`, `auth/auth.module.ts` | Register, login, refresh, verify-email, forgot/reset password |
| Users | `users/users.controller.ts`, `users/users.service.ts`, `users/users.module.ts` | Profile CRUD |
| BabyMon | `baby-mon/baby-mon.controller.ts`, `baby-mon/baby-mon.service.ts`, `baby-mon/baby-mon.module.ts` | BabyMon CRUD, stage management |
| Milestones | `milestones/` | Milestone CRUD under `/api/baby-mons/:id/milestones` |
| FeedLogs | `feed-logs/` | Feeding log CRUD |
| HealthRecords | `health-records/` | Health record CRUD |
| Allergies | `allergies/` (NEW) | Allergy CRUD under `/api/baby-mons/:id/allergies` with duplicate detection |
| MedicalTeam | `medical-team/` (NEW) | Medical team CRUD under `/api/baby-mons/:id/medical-team` |
| SleepLogs | `sleep-logs/` | Sleep log CRUD (nap/night tracking) |
| Badges | `badges/` | Badge definitions + BabyMonBadgesController registered |
| Evolution | `evolution/` | XP calculation, stage progression |
| Growth | `growth/` | Growth records (weight, height, head circumference) |
| Journal | `journal/` | Unified feed, co-parent proposals |
| Export | `export/` | PDF/data export |
| Subscriptions | `subscriptions/` | Plan management, Stripe integration |
| StageContent | `stage-content/` | Pre-generated AI educational content |
| Media | `media/` | Photo upload via presigned URLs + `/photos` aliases (PhotosController) |
| Notifications | `notifications/` | Push notification device registration |
| LinkedAccounts | `linked-accounts/` | Co-parent linking, invitations, `/api/baby-mons/:id/partners` route |
| Common | `common/guards/`, `common/filters/` | JWT auth guard, exception filters |
| Admin | `admin/` | User management, audit logs, stats |
| Stripe | `stripe/` | Payment processing |
| StripeWebhook | `stripe-webhook/` | Stripe event handling |
| Health | `health/` | Health check endpoints |

---

## Documentation Files

| File | Purpose |
|------|---------|
| `docs/00-README-FIRST.md` | Getting started guide |
| `docs/01-ARCHITECTURE.md` | System architecture (7-tab nav, Riverpod, NestJS modules) |
| `docs/02-AUTH-FLOW.md` | Auth flow (login, register, token refresh, biometric) |
| `docs/03-KNOWN-GOTCHAS.md` | 36+ known bugs and fixes |
| `docs/04-FILE-INVENTORY.md` | This file |
| `docs/05-API-CLIENT-GUIDE.md` | API client usage (typed methods, generic fallback, error handling) |
| `docs/06-SCREEN-BUILDING-GUIDE.md` | Template for building new CRUD screens |
| `docs/07-DEPLOYMENT.md` | Deployment instructions |
| `docs/08-BABYMON-CREATION-WORKFLOW.md` | BabyMon creation flow |
| `docs/09-DIAGNOSTIC-GUIDE.md` | Diagnostic and debugging guide |
| `docs/10-ACHIEVEMENTS.md` | 38 badges across 7 categories, tier system (Bronze→Diamond) |

---

*Last Updated: June 5, 2026 (v7.0)*
