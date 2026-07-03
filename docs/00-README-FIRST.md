# BabyMon — Developer Quickstart

> **If you only read ONE document, read this.**

> **Canonical fix-tracking source:** [`docs/review-v4/ROADMAP.md`](./review-v4/ROADMAP.md) — tracks every code-level fix from all prior review iterations (99% resolved). For pre-fix review history, see [`_archive/`](../_archive/README.md).

---

## What is BabyMon?

BabyMon is a gamified baby tracking mobile app (Flutter) with a NestJS backend and PostgreSQL database. Parents log milestones, feedings, health records, and sleep data. The app awards XP, badges, and shows evolution stages as babies grow. Co-parents can collaborate via a shared journal.

**Tech Stack:** Flutter 3.x + Riverpod | NestJS (Node.js) + Prisma ORM | PostgreSQL

---

## How to Start

### Emulator
```bash

cd "C:\Android\Sdk\emulator
.\emulator.exe -avd Pixel_10_Pro -no-snapshot-load -gpu swiftshader -verbose
```

### Backend
```bash

cd /d "d:\Claude Workspace\Projects\00. Test Project\apps\api"
npm install
npm run start:dev
```
Backend runs on **port 3000**. Verify: `curl http://localhost:3000/api/health`

### Frontend
```bash
cd /d "d:\Claude Workspace\Projects\00. Test Project\apps\mobile"
flutter pub get
flutter run -d emulator-5554  # Android emulator
```
Frontend connects to backend at **`http://10.0.2.2:3000`** (Android emulator → host localhost).

**Both must run simultaneously.** Start backend first, then frontend.

---

## Project Structure

```
apps/
├── api/                          # NestJS backend
│   ├── src/                      # Controllers, services, modules
│   ├── prisma/                   # Schema + migrations
│   └── .env                      # Database URL, JWT secret
├── mobile/                       # Flutter frontend
│   └── lib/
│       ├── core/                 # Constants, services (OAuth, notifications)
│       ├── data/                 # ApiClient (Dio wrapper)
│       ├── features/             # Domain + data layers (auth, feeding, etc.)
│       └── presentation/        # Screens, providers, router
docs/                              # ← YOU ARE HERE
├── 00-README-FIRST.md            # This file
├── 01-ARCHITECTURE.md            # Layers, providers, routes, storage
├── 02-AUTH-FLOW.md               # Login, register, tokens, OAuth
├── 03-KNOWN-GOTCHAS.md           # Every bug we fixed (21 issues)
├── 04-FILE-INVENTORY.md          # Every source file mapped
├── 05-API-CLIENT-GUIDE.md        # How to call the backend correctly
├── 06-SCREEN-BUILDING-GUIDE.md   # Templates for new screens
├── 07-DEPLOYMENT.md              # Railway + Google Play deployment
├── 08-BABYMON-CREATION-WORKFLOW.md
├── 09-DIAGNOSTIC-GUIDE.md        # 10-bug debugging checklist
├── 10-ACHIEVEMENTS.md            # XP, badges, evolution
├── 11-REVIEW-REPORT.md           # Most recent review findings
├── 12-XP-SYSTEM-SPEC.md          # XP & leveling formulas
├── 13-THEME-SYSTEM-SPEC.md       # Glass + Clay dual theme
├── 14- onboarding-redesign-DESIGN.md
├── 15-MIGRATION-NOTES.md         # Roll-up of migrations 0001–0004 (incl. PLAN replaces IDEA rename)
├── Production_Sprint/            # Active deployment work (10-13)
└── review-v4/                    # Current review state + ROADMAP
```

> Archived (gitignored): `_archive/` — superseded reviews v1–v3, old sprints 01–09, the `old doc/` early-project planning files, and April 2026 mobile architecture audits. See [`_archive/README.md`](../_archive/README.md).

---

## Documentation Index

| Doc | Audience | What It Covers |
|-----|----------|---------------|
| `01-ARCHITECTURE.md` | New developers | Layers, providers, routes, component tree |
| `02-AUTH-FLOW.md` | Auth debuggers | Login/register/token/verification flows |
| `03-KNOWN-GOTCHAS.md` | Bug fixers | 21 bugs found + exact fixes |
| `04-FILE-INVENTORY.md` | File searchers | Every source file with purpose |
| `05-API-CLIENT-GUIDE.md` | API callers | Typed vs generic methods, prefix rules |
| `06-SCREEN-BUILDING-GUIDE.md` | AI agents | Copy-paste templates for new screens |
| `07-DEPLOYMENT.md` | DevOps | Railway, Firebase, Google Play |
| `08-BABYMON-CREATION-WORKFLOW.md` | Feature developers | Multi-step create-BabyMon flow |
| `09-DIAGNOSTIC-GUIDE.md` | Bug fixers | 10-bug QA checklist |
| `10-ACHIEVEMENTS.md` | Gamification devs | XP, badges, evolution |
| `11-REVIEW-REPORT.md` | Tech leads | Most recent review findings |
| `12-XP-SYSTEM-SPEC.md` | Gamification devs | XP & leveling formulas |
| `13-THEME-SYSTEM-SPEC.md` | UI devs | Glass + Clay dual theme system |
| `14- onboarding-redesign-DESIGN.md` | UX/designers | Onboarding redesign rationale |
| `15-MIGRATION-NOTES.md` | Backend devs, DB admins | Roll-up of migrations 0001–0004; explains the `'PLAN'` replaces `'IDEA'` rename |
| **`review-v4/ROADMAP.md`** | **Everyone** | **Canonical fix-tracking source — 99% of code-level issues resolved** |
| `Production_Sprint/10..13` | DevOps | Migration strategy, promo codes, i18n, **deployment plan** |

---

## 🚨 CRITICAL RULES — Read Before Writing Any Code

### 1. Provider Import Rule
```dart
// ✅ CORRECT — use either path, both reference the SAME provider:
import 'package:baby_mon/presentation/providers/auth_provider.dart';
import 'package:baby_mon/core/providers.dart';

// ❌ WRONG — NEVER define apiClientProvider in more than one file.
// It lives ONLY in presentation/providers/auth_provider.dart.
// core/providers.dart now defines appRefreshProvider instead.
```

### 2. API Prefix Rule
- **Typed methods** (e.g., `api.getProfile()`) call `_dio.get()` directly — must include `/api` prefix
- **Generic methods** (e.g., `api.get('/users/me')`) auto-prepend `/api` — do NOT include it

### 3. Loading State Rule
Every screen that loads data MUST call `setState(() => _isLoading = false)` before ANY early return.

---

## Quick Debugging Checklist

1. **Is the backend running?** `curl http://localhost:3000/api/health` — should return `{"status":"ok"}`
2. **Did you register before logging in?** The backend requires email verification — check the verify-email flow.
3. **401 on API calls?** See `docs/09-DIAGNOSTIC-GUIDE.md` — complete debugging checklist with 10 bug fixes.
4. **Data saved but not showing?** All backend responses return `{ items: [...], total, skip, take }`. Check you're extracting `response.data['items']` not casting `response.data as List`. See Bug #9.
5. **No error but no data?** Check `docs/01-ARCHITECTURE.md` — all typed methods need `/api` prefix. See Bug #6.

---

*Last Updated: July 3, 2026 (v4.4) — added arcs to 08–14, Production_Sprint 10–13, and review-v4.*

*Doc 15 (MIGRATION-NOTES) added 2026-07-03 to document migrations 0001–0004 and the `PLAN` ↔ `IDEA` rename.*

*Previous archived reviews: [`_archive/`](../_archive/README.md).*
