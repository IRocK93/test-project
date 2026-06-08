# BabyMon Testing Plan

## 1. Backend Unit Tests

### 1.1 Auth Module
- JWT token generation & verification (access + refresh)
- Token expiration handling
- Password hashing (bcrypt round trip)
- Login with valid/invalid credentials
- Refresh token rotation

### 1.2 Baby-Mon Module
- Create baby profile (valid input, validation errors)
- XP calculation: milestone XP + feed-log bonus XP
- Level-up threshold detection (level = floor(totalXP / 1000) + 1)
- Get baby with evolution stats

### 1.3 Milestones Module
- Create milestone (correct XP assignment per type)
- Enum mapping: MILESTONE_TYPES → XP values
- Milestone retrieval by babyId

### 1.4 Feed-Logs Module
- Log feeding (type: breast/bottle/solid, amount, duration)
- XP bonus per feed (breast: 5, bottle: 5, solid: 10)
- Feed history by babyId

### 1.5 Health-Records Module
- CRUD health record (vaccine, checkup, weight, height)
- Validation: required fields, positive numbers for weight/height

### 1.6 Evolution Module
- getEvolutionStats: totalXP, level, nextMilestoneXP
- XP aggregation from milestones + feed-logs

### 1.7 Badges Module
- Badge awarding on milestone thresholds (first_log, week_streak, level_5, etc.)
- Duplicate award prevention
- List badges by userId

### 1.8 Journal Module
- Create/read/update/delete journal entries
- Entries filtered by babyId

### 1.9 Subscriptions Module
- Trial enforcement: 7-day trial, upgrade before expiration
- Plan access control (free vs premium features)
- Subscription status checks on protected routes

---

## 2. Mobile Tests

### 2.1 Riverpod Provider Tests
- `authProvider`: login/logout state transitions
- `babyListProvider`: loading, data, error states
- `milestoneProvider`: add milestone triggers XP recalc
- `subscriptionProvider`: trial countdown, upgrade prompt
- `evolutionProvider`: computed level from XP

### 2.2 Widget Tests
- **LoginScreen**: form validation, loading state, error display
- **HomeScreen**: baby card renders, XP progress bar
- **MilestoneScreen**: list renders, FAB triggers creation dialog
- **FeedLogScreen**: feeding type selector, amount input
- **BadgeScreen**: badge grid with earned/locked states

### 2.3 Key Flows (Bloc/Gateway style)
- Register → login → baby creation → log milestone → verify XP increments

---

## 3. E2E Tests (Playwright)

| # | Flow | Steps |
|---|------|-------|
| 1 | Register+Login | POST /auth/register → POST /auth/login → store token |
| 2 | Create BabyMon | POST /baby-mon → assert id returned |
| 3 | Log Milestone | POST /milestones with babyId → assert XP increased |
| 4 | Log Feed | POST /feed-logs → assert bonus XP |
| 5 | Earn Badge | Trigger milestone threshold → GET /badges → assert badge present |
| 6 | Trial Expiry | Create free account → wait/advance clock → assert upgrade prompt |

---

## 4. CI Setup (GitHub Actions)

```yaml
# Backend job
- name: Backend Tests
  run: |
    cd backend
    npm run test -- --coverage --coverageThreshold=80

- name: Backend Lint
  run: npm run lint

# Mobile job
- name: Flutter Tests
  run: flutter test

- name: Flutter Analyze
  run: flutter analyze

# E2E job
- name: Playwright Tests
  run: npx playwright test
```

---

## 5. Quality Gates

| Gate | Threshold | Required |
|------|-----------|----------|
| Test Coverage | ≥ 80% | Yes |
| All unit tests pass | 100% | Yes |
| Lint / analyze | 0 errors | Yes |
| E2E suite | 100% pass | Yes |
| No high/critical vulnerabilities | n/a | Yes |

CI must pass all gates before merging to `main`.

---

*Last updated: 2026-04-23*