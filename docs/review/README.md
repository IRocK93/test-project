# BabyMon — Full Agency Audit Report

**Date:** 2026-06-17
**Repository:** `D:\Claude Workspace\Projects\00. Test Project`
**Scope:** NestJS API (27 modules) + Flutter Mobile (~114 Dart files)
**Verdict:** 🟠 **Pre-production. Critical security and compliance blockers. Strong design system and feature surface. Major wiring gaps in gamification and AI tier.**

---

## Executive Summary

BabyMon is a **baby-tracking parenting SaaS** with gamification (XP → badges → levels → evolution), co-parent sharing, and Stripe subscriptions (CORE / AI_COMPANION tiers). The codebase has a solid foundation — the NestJS API is functionally complete with good module boundaries, and the Flutter app has an excellent design system (Glass/Clay dual-theme, WCAG AA documented) with a strong widget library. However, **12 specialist audits across security, architecture, API design, data, mobile, UX, accessibility, performance, testing, DevOps, product, and privacy/compliance** surfaced 6 critical blockers that must be addressed before this app can ship or accept real user data:

1. **🔴 Committed `.env` with live database credentials** — active security incident
2. **🔴 Three IDOR/access-control bugs** — unauthorized access to any baby's data
3. **🔴 Would fail COPPA and GDPR audits** — no age gate, no consent, "coming soon" legal links
4. **🔴 Gamification pipeline ~17% wired** — 48 badges defined, only 8 awardable
5. **🔴 "AI_COMPANION" tier has zero AI features** — the paid tier delivers nothing additional
6. **🔴 Social login is completely simulated** — fake tokens, no backend OAuth

The app's **strongest assets** are its co-parent sharing with edit proposals, the design system, and the thorough internal documentation (`docs/` folder). These provide a strong foundation to build on once the blockers are resolved.

---

## Per-Specialist Reports

| # | Report | Severity | Key Finding |
|---|---|---|---|
| 01 | [Security](./01-security.md) | 🔴 Critical | Committed secrets, 3 IDOR bugs, fail-open JWT, stubbed social login |
| 02 | [Backend Architecture](./02-backend-architecture.md) | 🟠 High | No config layer, god services, redundant cascade deletes, dead badge definitions |
| 03 | [API Design](./03-api-design.md) | 🟠 High | Half of controllers accept untyped `any` bodies; no versioning; docs publicly accessible |
| 04 | [Data Model](./04-data-model.md) | 🟠 High | ~15 String fields should be enums; missing indexes on AuditLog/Subscription/RefreshToken |
| 05 | [Mobile Architecture](./05-mobile-architecture.md) | 🔴 Critical | Repository layer only in auth; god screens up to 68KB; 116 setStates with Riverpod |
| 06 | [UI/UX & Visual Design](./06-ui-ux-visual-design.md) | 🟡 Medium | Excellent design system; 28 hardcoded colors bypass tokens; Phosphor migration incomplete |
| 07 | [Accessibility](./07-accessibility.md) | 🟠 High | No font scaling; disabled color fails WCAG AA; no i18n |
| 08 | [Performance](./08-performance.md) | 🔴 Critical | Unbounded queries; missing indexes; `shrinkWrap` negates lazy loading |
| 09 | [Testing & QA](./09-testing-qa.md) | 🔴 Critical | 4 backend specs across 27 modules; no tests for AuthZ gate, Stripe, or badge logic |
| 10 | [DevOps & DX](./10-devops-dx.md) | 🔴 Critical | `.gitignore` blocks Dockerfile; CI `test:ci` script missing; 250-file dirty working tree |
| 11 | [Product](./11-product.md) | 🟠 High | 48 badges defined, 8 wired; AI_COMPANION has no AI; social login is fake |
| 12 | [Privacy & Compliance](./12-privacy-compliance.md) | 🔴 Critical | FAILS COPPA + GDPR audits; no age gate, no consent, non-functional legal links, S3 photos retained after deletion |

---

## Top 10 Cross-Cutting Issues

These are the issues that span multiple specialist domains and represent the highest-impact fixes:

### 1. 🔴 Secret Leak — `.env` Committed with Live Credentials
**Impact:** Security, Privacy/Compliance
**Details:** `apps/api/.env` contains a real Neon PostgreSQL connection string with password and a hardcoded JWT secret. No `.gitignore` prevents `.env` commits. Rotate immediately. Scrub git history.
**Reports:** [01-security](./01-security.md) (S01), [12-privacy-compliance](./12-privacy-compliance.md) (PC01)

### 2. 🔴 IDOR / Access-Control Bugs — 3 Vulnerabilities
**Impact:** Security, Testing/QA
**Details:** `milestones.create()` and `feed-logs.create()` never call `verifyAccess()` — any authenticated user can post to any BabyMon. `health-records.verifyAccess()` calls `checkAccess()` but ignores the `hasAccess` result (no-op). The `AccessControlService` has zero tests. The fix is a one-line addition each.
**Reports:** [01-security](./01-security.md) (S02-S04), [09-testing-qa](./09-testing-qa.md) (T01-T03)

### 3. 🔴 COPPA/GDPR Compliance — Would Fail Audit
**Impact:** Privacy/Compliance, Product, Security
**Details:** No age gate at registration. No verifiable parental consent. Privacy policy and terms links show "coming soon." No GDPR consent checkboxes. Delete-account is soft-delete (user PII retained permanently). Children's photos in S3 are never purged. Data is exclusively US-hosted. No DPAs with vendors. **This app cannot legally collect children's data in the US or EU.**
**Reports:** [12-privacy-compliance](./12-privacy-compliance.md)

### 4. 🔴 Gamification Pipeline Broken — 48 Badges, 8 Wired
**Impact:** Product, Backend Architecture, Testing/QA
**Details:** `BADGE_DEFINITIONS` defines 48 badges but `checkAndAwardBadges` hardcodes only 8 trigger checks. Sleep-logs, health-records, growth, media, and allergies are completely disconnected from the badge/XP system. Badges defined but never awarded = broken gamification promise.
**Reports:** [11-product](./11-product.md) (PR01), [02-backend-architecture](./02-backend-architecture.md) (BA03), [09-testing-qa](./09-testing-qa.md) (T06)

### 5. 🔴 AI_COMPANION Tier Delivers Nothing
**Impact:** Product, Security
**Details:** The paid "AI_COMPANION" tier has zero AI features — no chatbot, no ML predictions, no recommendations. The "MJ voice" in onboarding is a static flavor text array, not AI-generated. Combined with stubbed social login, the app's two differentiators are non-functional.
**Reports:** [11-product](./11-product.md) (PR02), [01-security](./01-security.md) (S06)

### 6. 🔴 Backend Coverage — 4 Specs Across 27 Modules
**Impact:** Testing/QA, Security
**Details:** Only 14.8% of backend modules have any tests. `AccessControlService` (authorization gate), Stripe webhook (billing integrity), badge awarding, XP service, and refresh-token rotation are all completely untested. The `test:e2e` script points at a nonexistent directory. Three IDOR bugs persist because no tests catch them.
**Reports:** [09-testing-qa](./09-testing-qa.md), [01-security](./01-security.md)

### 7. 🟠 Missing DTOs — Half the API Surface Accepts `@Body() body: any`
**Impact:** API Design, Security, Backend Architecture
**Details:** Allergies, medical-team, media, admin, journal, growth, notifications, and stripe endpoints accept untyped bodies. The global `ValidationPipe` with `forbidNonWhitelisted` cannot validate them. A malformed or malicious payload passes straight to Prisma. No OpenAPI schema is generated for these endpoints.
**Reports:** [03-api-design](./03-api-design.md) (AD01-AD05)

### 8. 🟠 Missing Database Indexes on High-Traffic Query Paths
**Impact:** Performance, Data Model
**Details:** `AuditLog`, `Subscription`, `RefreshToken`, `EntryChangeProposal`, and `User.deletedAt` lack indexes on their query columns. Combined with unbounded `findMany` in journal/export/growth, this means table scans that will degrade linearly with data volume.
**Reports:** [08-performance](./08-performance.md) (P01-P04), [04-data-model](./04-data-model.md) (DM04-DM07)

### 9. 🟠 CI/CD Broken + Git Hygiene Issues
**Impact:** DevOps/DX
**Details:** `.gitignore` blocks `Dockerfile*` and `docker-compose*.yml` — critical infrastructure files not tracked. CI `test:ci` script doesn't exist (CI fails). CI lint step swallows failures with `|| true`. `local.properties` with machine-specific paths tracked. 250-file dirty working tree. README.md deleted.
**Reports:** [10-devops-dx](./10-devops-dx.md) (DX01-DX07)

### 10. 🟠 Mobile God Files + Missing Repository Layer
**Impact:** Mobile Architecture, UI/UX
**Details:** `create_baby_mon_screen.dart` is 68KB (1,800 lines) with 19 `setState` calls. `dashboard_screen.dart` has 10 silent `catch {}` blocks. Only `auth/` has a repository/data layer — 15 screens call `ApiClient` directly. Four dependencies are dead weight (`provider`, `get_it`, `drift`, `sqlite3_flutter_libs`). Social login is stubbed.
**Reports:** [05-mobile-architecture](./05-mobile-architecture.md), [06-ui-ux-visual-design](./06-ui-ux-visual-design.md)

---

## Quick Wins (Under 1 Day Total)

These are small, high-impact fixes that can be done immediately:

| # | Action | Effort | Report(s) |
|---|---|---|---|
| 1 | **Rotate leaked credentials.** Delete `.env` from git history. Add `.gitignore`. | S | S01, PC01 |
| 2 | **Fix 3 IDOR bugs** — add `verifyAccess()` to `milestones.create`, `feed-logs.create`, `health-records.create`. Fix `health-records.verifyAccess` to check `hasAccess`. | S | S02-S04 |
| 3 | **Add `test:ci` script** to `package.json`. Fix CI lint step (`|| true`). | S | DX03-DX04 |
| 4 | **Fix `.gitignore`** — remove Dockerfile/compose rules. `git add -f` the real files. | S | DX01 |
| 5 | **Remove dead deps** from pubspec.yaml (`provider`, `get_it`, `drift`, `sqlite3_flutter_libs`). | S | MA07 |
| 6 | **Fix `LoadingWidget` dark-mode break** (hardcoded white). | S | UI01 |
| 7 | **Add font scaling support** in `MaterialApp.router` builder. | S | A11 |
| 8 | **Fix `AppColors.disabled`** to ≥#949494 for 3:1 AA contrast. | S | A12 |
| 9 | **Replace hardcoded URL** with `--dart-define` + `envied`. | S | MA06 |
| 10 | **Add 8 missing database indexes** (AuditLog ×2, Subscription ×2, RefreshToken ×2, EntryChangeProposal, User.deletedAt). | S | DM04-DM07, P02-P04 |

---

## Things Done Well

Despite the blockers, the codebase has genuine strengths that signal a capable engineering team:

- **Co-parent sharing with edit proposals** — linked accounts with VIEW/EDIT permissions + 10-minute undo window + entry-change proposals requiring approval. This is thoughtfully designed for shared parenting data integrity.
- **Design system** — dual-theme architecture (Glass + Clay × light/dark = 4 combinations) with palette-agnostic component helpers. WCAG AA contrast documented. 38 reusable widgets. 250 lines of design tokens. Professional-grade.
- **Testing infrastructure (mobile)** — 60+ test files with strong entity tests, `StubApiClient` mock, `FakeAuthRepository`, platform mocks. The building blocks for meaningful tests exist.
- **Internal documentation** — `docs/` folder with 15 well-structured markdown files covering architecture, auth flow, known gotchas, deployment, diagnostics, and theme system spec. Unusually thorough.
- **Multi-stage Dockerfile** with non-root user, production-only deps, Prisma generate for target platform.
- **Stripe integration** — webhook signature verification, idempotency via `StripeEvent` table, checkout/portal session flow.
- **Refresh-token rotation** with revocation — correct pattern for JWT security.
- **Global ValidationPipe** with `whitelist`, `forbidNonWhitelisted`, `transform` — correct NestJS hardening.
- **Rate limiting tiers** — AUTH (30/min), SENSITIVE (20/min), DEFAULT (100/min) with per-route overrides.
- **Soft-delete consistency** — `deletedAt` filter on all read queries across all services.

---

## Report Statistics

| Metric | Count |
|---|---|
| **Total Findings** | 178 |
| 🔴 Critical | 26 |
| 🟠 High | 47 |
| 🟡 Medium | 58 |
| 🔵 Low | 35 |
| ⚪ Nitpick | 12 |
| **Specialists Deployed** | 12 |
| **Files Analyzed** | 200+ |
| **Report Pages** | 13 markdown files |
