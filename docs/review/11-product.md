# 11 — Product Audit

**Date:** 2026-06-17
**Severity Score:** 🟠 High (2 Critical, 2 High, 4 Medium)
**Verdict:** Gamification wiring gap. 48 badges defined, only 8 wired. AI_COMPANION tier has no AI. Mobile-only with no web.

---

## Summary

BabyMon is a baby-tracking parenting SaaS with a gamification hook (XP → badges → levels → evolution/stage-content), co-parent sharing via linked accounts, and a two-tier subscription model (CORE / AI_COMPANION). The feature surface is solid for an MVP — it covers the core tracking categories (feeding, sleep, growth, health, milestones, allergies, journal, media) plus co-parent collaboration and data export. However, the product has critical value-delivery gaps: **(1) the gamification pipeline is only ~17% wired** — 48 badge definitions exist but `checkAndAwardBadges` hardcodes only 8 trigger checks. Sleep-logs, health-records, growth, media, and allergies are completely disconnected from the badge/XP system; **(2) the "AI_COMPANION" tier has zero AI features** — no ML, no recommendations, no chatbot. The "MJ" voice/narrator in onboarding is a static flavor text system, not AI; **(3) social login is stubbed** — the "Login with Google/Apple/Facebook" buttons create fake tokens locally; **(4) the app is mobile-only** — no web version despite being built with Flutter (which supports web). The core co-parent sharing (linked accounts with VIEW/EDIT permissions + entry-change proposals with 10-minute undo window) is genuinely thoughtful and differentiates from competitors.

---

## Findings

| ID | Severity | Title | Location | Evidence | Recommendation |
|---|---|---|---|---|---|
| PR01 | 🔴 Critical | **Gamification pipeline only ~17% wired** | `badges.service.ts:4-122` (48 badge definitions) vs `:144-210` (8 hardcoded checks) | `BADGE_DEFINITIONS` defines 48 badges with categories, traits, xpValues — but `checkAndAwardBadges` only checks for: `FIRST_MILESTONE`, `MILESTONES_5`, `MILESTONES_10`, `FIRST_FEEDING`, `FEEDING_10`, `XP_50`, `XP_100`, `XP_500`. Zero badges for sleep, health, growth, media, allergies, or journal entries. Badges defined but never awarded = broken gamification promise. | Either: (a) wire all 48 badges using data-driven awarding from `BADGE_DEFINITIONS`, or (b) delete the unused definitions and ship only what's implemented. Add badge triggers for sleep-logs, health-records, growth, media. |
| PR02 | 🔴 Critical | **"AI_COMPANION" tier has zero AI features** | `stripe.service.ts:269-280` (tier mapping), search for AI/ML/gpt/LLM | `getTierFromPriceId` maps Stripe price IDs to `'CORE'` or `'AI_COMPANION'`. No code anywhere implements an AI feature: no chatbot, no ML predictions, no personalized recommendations, no anomaly detection. The "MJ voice" in onboarding (`create_baby_mon_screen.dart`) is a static flavor text array, not AI-generated. | Either: (a) implement an AI feature (LLM-based parenting tips, growth percentile predictions, sleep pattern analysis) gated behind AI_COMPANION, or (b) rename the tier to something accurate (e.g., "PREMIUM") and adjust pricing/promises. |
| PR03 | 🟠 High | **Social login is stubbed — no real OAuth** | `auth_provider.dart:159,204,238` | Three TODO comments: "Send ID token to backend for verification". Backend has zero OAuth endpoints. Users click "Login with Google" and get a fake local session — broken product experience. | Implement real backend OAuth flow for Google, Apple, Facebook. Start with Google (largest user base). |
| PR04 | 🟠 High | **Mobile-only — no web version** | `pubspec.yaml` — no `web/` directory at `apps/mobile/` | Flutter supports web out of the box. Parenting apps often benefit from web access for data entry (keyboard), photo upload (drag-drop), and sharing previews with family. | Evaluate web support. At minimum, add `web/` directory for a basic read-only dashboard. |
| PR05 | 🟡 Medium | **No milestones-to-badges connection for non-core tracking** | `sleep-logs.service.ts`, `health-records.service.ts`, `growth.service.ts`, `media.service.ts` | Only `milestones.service.create` and `feed-logs.service.create` call `badgesService.checkAndAwardBadges`. Sleep-logs, health-records, growth, and media create operations skip badge/XP entirely — they track data but don't feed the gamification loop. | Wire badge checks into all create service methods. Seed badge definitions for sleep, health, growth, media tracking. |
| PR06 | 🟡 Medium | **Stage content is mysterious** | `stage-content.service.ts` | Returns content for a baby's developmental stage. But the content source isn't clear from the codebase — is it static JSON? AI-generated? External API? The "evolving parenting companion" value prop depends on this being rich and evolving. | Document the content source and update cadence. Ensure content covers all tracked data types with actionable parenting tips. |
| PR07 | 🟡 Medium | **Notifications are limited** | `notifications.service.ts` | Push notifications send on: milestone achieved, co-parent invitation, co-parent action. Missing: feeding reminders, sleep schedule nudges, growth checkup reminders, trial expiry warning. | Add configurable reminder notifications for feeding, sleep, growth checkups, and trial expiry. These drive retention. |
| PR08 | 🟡 Medium | **Export limits to 3 entries per category in mobile** | `export.service.ts:133-136` vs `api_client.dart:226` | Mobile calls `exportBabyMon` which hardcodes `take: 3` per category. The full export (JSON/CSV with all records) exists on backend but is unreachable from the mobile app. Users cannot get their complete data. | Expose full export via the mobile app (with a progress indicator for large datasets). |

---

## Things Done Well

1. **Co-parent sharing with edit proposals** — `linked-accounts.service.ts` + `entryChangeProposal` flow: linked accounts have VIEW/EDIT permissions, edits outside 10-min window become proposals requiring co-parent approval. Genuinely thoughtful for shared parenting data integrity.
2. **10-minute undo window** — soft-deletes and edits within 10 minutes are direct (no proposal needed). Good UX for "oops" moments.
3. **XP and level progression** — gates at specific thresholds (50, 150, 300, 500, 750, 1000, 1500, 2500). Level names (Explorer, Learner, Guardian, etc.) create a sense of progression.
4. **Personality** — the MJ voice/narrator and flavor text system add warmth. Polished onboarding wizard with splash animation and stage-specific flavor text.
5. **Data export infrastructure** — JSON, CSV, and HTML formats exist on backend.
6. **Dashboard reorderability** — users can customize their tile layout. Persisted to SharedPreferences.
7. **Subscriptions with trial** — 14-day free trial, Stripe integration for CORE/AI_COMPANION tiers.

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | **Wire all 48 badge definitions** via data-driven awarding. Add badge triggers for sleep, health, growth, media, allergies. | L |
| 2 | **Implement AI_COMPANION feature** (LLM parenting tips, growth insights, or rename tier). | L |
| 3 | **Implement real OAuth** (Google, Apple, Facebook backend verification). | L |
| 4 | **Evaluate web support** — add `web/` directory for read-only dashboard. | M |
| 5 | **Wire badge checks into all create service methods** (sleep-logs, health-records, growth, media). | M |
| 6 | **Add configurable reminder notifications** for feeding, sleep, growth checkups, trial expiry. | M |
| 7 | **Expose full export in mobile app** (with progress indicator). | M |
| 8 | **Document stage content source** and update cadence. | S |
