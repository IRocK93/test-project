# S15 — Brand Consistency Audit

**Date:** 2026-06-18 | **Overall:** Fractured voice, strong foundations

---

## P0 — Critical

| ID | Issue |
|---|---|
| BR-C01 | **Tier naming fracture:** Backend sends `CORE`, frontend expects `FREE`. `isCurrent` logic broken. |
| BR-C02 | `appName = 'Baby Tracker'` contradicts `title: 'BabyMon'` |
| BR-C03 | **Dual badge system:** `BADGE_DEFINITIONS` (48 badges) and `checkAndAwardBadges` (8 badges) share no identifiers or names |

## P1 — High

| ID | Issue |
|---|---|
| BR-H01 | Emoji in 7 production files after Phosphor migration was declared complete |
| BR-H02 | "Sign In"/"Login" and "Sign Up"/"Register" — dual naming for same actions |
| BR-H03 | Duplicate `/companion/:babyMonId` route |

## The Voice Problem
Three distinct tones without a unifying personality:
- **Tone A — Poetic warmth** (onboarding): "Every great journey begins with a single heartbeat"
- **Tone B — Clinical/utilitarian** (auth, errors): "Welcome Back!", "Server error. Please try again."
- **Tone C — Gentle companion** (AI reminder): "We love that you trust BabyMon..."

The poetic MJ Voice System is the strongest brand asset — but it collapses after onboarding.

## Strengths
- ✅ Onboarding narrative is genuinely premium
- ✅ Level naming (50 levels) is creative and developmentally appropriate
- ✅ Phase system with plant-growth metaphor is coherent
- ✅ AI companion has consistent, warm voice with clear expert attribution
- ✅ Medical disclaimer is thorough with no dark patterns
