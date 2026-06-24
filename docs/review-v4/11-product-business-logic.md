# BabyMon Product & Business Logic Audit — v4

**Date:** 2026-06-22
**Overall Grade: C+**

---

## Executive Summary

BabyMon is architecturally ambitious with well-structured documentation. However, implementation is significantly behind specification. The two most critical findings:

1. **XP and level-up system is fully implemented but completely disconnected** from every entry-creation service — level-ups never actually fire
2. **Badge-awarding logic covers only 9 out of 86 specified badges** (~10% of design)

---

## 1. Critically Broken Features

| Feature | File | Issue |
|---------|------|-------|
| **XP level-up processing** | `xp.service.ts:104` | `checkAndProcessLevelUp()` is never called by any entry-creation service |
| **XP threshold in evolution endpoint** | `evolution.service.ts:42` | Uses hardcoded `(babyMon.currentStage + 1) * 100` — wrong formula |
| **Badge awarding** | `badges.service.ts:144-209` | Only 9/86 badge checks implemented |
| **Stripe webhook** | `stripe-webhook.controller.ts:23` | Only logs "Received Stripe webhook" — no event processing |
| **Evolution field name mismatch** | `evolution.service.ts` + frontend | Returns `currentStage` but frontend expects `currentLevel` |

---

## 2. Feature Gap Analysis

### Implemented (No Issues)
- BabyMon CRUD, stage calculation, milestones, feeding, health, sleep, growth, allergies
- Journal (unified feed), co-parent linking, edit proposals
- Access control, media/S3, export (JSON/CSV), push notifications
- AI Companion (daily brief, routine, milestones, advice)
- Stage content, Stripe checkout/portal/cancel

### Missing (from SPEC.md)
| Feature | Status |
|---------|--------|
| Google OAuth | Stub only |
| PDF export (bento-box style) | Not implemented |
| On-device LLM chat | Code-complete but never verified on device |
| Screenings and checkup reminders | API endpoints not found |
| Vaccination schedule endpoints | Not found |
| Routine personalization save | Not found |
| Offline sync indicators | Pending |
| Delete account | Not found |

---

## 3. Gamification Balance Audit

### XP System — Design: A, Implementation: F

The XP specification is excellent:
- Dynamic thresholds (50→75→100→150→200→250 XP)
- Carry-over system prevents wasted XP
- Multi-hop level-ups handle large XP gains
- 50 themed levels with phase milestones
- ~193 days to level 50 at active usage

**But none of this works** because XpService is never called.

### Badge System — Design: B+, Implementation: D

86 badges across 8 categories designed. Only 9 have awarding logic:
- M01-M03 (milestone count only)
- F01-F02 (feeding count only)
- X01-X03 (XP thresholds)
- FIRST_BABYMON

**Missing entirely:** All trait-based badges (48), sleep badges (6), health badges (5), growth badges (4), milestone badges M04-M07, feeding badges F03-F06, parenting badges P01-P06, XP Legend X04.

Additional issues:
- Badge naming is inconsistent between definitions and `checkAndAwardBadges`
- No streak tracking for consecutive-day badges
- No trait activation timestamps for "trait active for X days" badges
- No text-based notes analysis for content-aware badges

---

## 4. Subscription Value Assessment: C+

### Tier Differentiation — Clearly defined but some gray areas
- "Badge animations & effects" listed as Premium but badges awarded to all users
- "Priority support" listed but no support ticketing system
- 7-day history limit inconsistently enforced

### Trial Handling — C+
- 14-day trial implemented
- Post-trial: app becomes view-only (good)
- Missing: trial-start notification, trial-ending reminders, grace period

### Payment Handling — D
- Stripe checkout works
- Webhook processing is broken (two endpoints, one non-functional)
- No payment failure handling
- No subscription upgrade/downgrade flow
- Dev-only trial override is `@Public()` — security risk

---

## 5. Missing Edge Cases

### Premature Birth / Adjusted Age — CRITICAL GAP
Zero support. No "adjusted age" concept exists. A baby born at 32 weeks should see milestone expectations based on adjusted age, not chronological age. Growth percentiles should use Fenton preterm charts.

### Twins/Multiples — No Support
No batch creation, no sibling linking, no shared feeding sessions.

### Baby Grows Past 24 Months — Hard Cap
`calculateCurrentStage()` caps at `born_month_24`. No graduation, archiving, or "freeze baby" flow.

### Co-parent Edge Cases
- Co-parent with active subscription can log for baby whose owner's trial expired
- Co-parent notifications only go to owner, not co-parent awaiting response

---

## 6. Product Roadmap

### Priority 0 — Week 1-2
1. Wire XpService into all entry-creation services
2. Fix evolution endpoint XP formula
3. Fix Stripe webhook (consolidate endpoints)
4. Fix badge awarding — implement remaining 77 checks

### Priority 1 — Week 3-4
5. Implement streak tracking
6. Add trait activation timestamps
7. Add text-based badge detection
8. Implement trial-ending reminders

### Priority 2 — Week 5-6
9. Add premature birth support (gestationalAgeAtBirth, adjusted age)
10. Implement "graduation" flow for 24+ month babies
11. Add payment failure handling
12. Implement notification preferences (opt-in/opt-out, quiet hours)

### Priority 3 — Month 2-3
13. On-device LLM deployment and testing
14. Complete content coverage (fill ~78 missing advice cards)
15. Add twin/multiples support
16. Implement Google OAuth
