# Bug 1: Dashboard XP Bar Overshoots & No Level-Up

**Date:** 2026-06-23 | **Severity:** HIGH

## Two Root Causes

### Cause 1: Backend Returns Incomplete Evolution Data

**File:** `apps/api/src/baby-mon/baby-mon.service.ts`, lines 207-209

```typescript
// getDashboard() evolution query:
evolution: await this.prisma.babyMon.findUnique({
  where: { id: babymonId },
  select: { currentXp: true },   // ← ONLY currentXp, nothing else
}),
```

The dashboard aggregation endpoint returns `{ currentXp: N }` with **none** of these fields the Flutter widget needs:

| Field | Widget Needs? | Backend Returns? |
|-------|:---:|:---:|
| `xpProgress` | Primary display | **No** — triggers fallback |
| `xpForNextLevel` | Fallback denominator | **No** — hardcoded 50 |
| `currentStage`/`currentLevel` | Level display + level-up detection | **No** from evolution, comes from babyMon merge |
| `levelName` | Display | **No** |
| `nextLevelName` | Display | **No** |

### Cause 2: Fallback Uses Hardcoded XP/50 for All Stages

**File:** `apps/mobile/lib/features/dashboard/presentation/widgets/dashboard_xp_card.dart`, lines 18-20

```dart
final needed = parseDouble(evolution!['xpForNextLevel']) ?? 50;  // ← ALWAYS 50
return needed > 0 ? (xp / needed).clamp(0.0, 1.0) : 0.0;
```

Since `xpForNextLevel` is never in the response, the fallback `50` is always used. But actual thresholds from `apps/api/src/xp/xp.service.ts`:

| Stage Range | Actual XP to Level Up | Widget Uses | Error |
|:---|:---|:---|:---|
| 1-5 | 50 | 50 | Correct (by luck) |
| 6-15 | 75 | 50 | Shows 100% at 50 XP (overshoot) |
| 16-25 | 100 | 50 | Shows 100% at 50 XP (massive overshoot) |
| 26-35 | 150 | 50 | Shows 100% at 50 XP |
| 36-45 | 200 | 50 | Shows 100% at 50 XP |
| 46-50 | 250 | 50 | Shows 100% at 50 XP |

At stage 10 with 70 XP: widget shows `70/50 = 140%` (clamped to 100%) but real target is 75 XP = 93%.

### Cause 3: Field Name Mismatch Prevents Level-Up Detection

**File:** `apps/mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart`, line 435

```dart
int get _currentLevel => parseInt(_evolution?['currentLevel']) ?? 1;
```

**File:** `apps/api/prisma/schema.prisma`, line 351

```prisma
currentStage Int @default(1)
```

The database field is `currentStage`. The Flutter widget reads `currentLevel` — which never exists. `_currentLevel` always returns **1**. The level-up detection (`newLevel > _previousLevel`) is always false. Level-up celebration never fires. Level name always shows "Level 1."

### Same Bug in dashboard_xp_card.dart, line 31

```dart
int get _currentLevel => parseInt(evolution?['currentLevel']) ?? 1;  // same wrong key
```

---

## Production-Grade Fix

### Backend: `baby-mon.service.ts` — Complete the evolution response

```typescript
// In getDashboard(), replace the bare evolution query:
const babyMonXp = await this.prisma.babyMon.findUnique({
  where: { id: babymonId },
  select: { currentXp: true, currentStage: true },
});

const currentStage = babyMonXp?.currentStage ?? 1;
const xpForNext = this.xpService.xpForNextLevel(currentStage);
const xpProgress = xpForNext > 0 ? Math.round(((babyMonXp?.currentXp ?? 0) / xpForNext) * 100) : 100;

// In the return object:
evolution: {
  currentXp: babyMonXp?.currentXp ?? 0,
  currentLevel: currentStage,        // map currentStage → currentLevel (match Flutter)
  xpProgress: Math.min(xpProgress, 100),
  xpForNextLevel: xpForNext,
  levelName: this.xpService.getLevelName(currentStage),
  nextLevelName: this.xpService.getLevelName(currentStage + 1),
},
```

### Backend: `evolution.service.ts` — Add missing fields to getEvolution()

Return `xpForNextLevel`, `levelName`, `nextLevelName` alongside existing `xpProgress` and `currentXp`. These are computed values from `xp.service.ts` methods that already exist but are only called during level-up processing.

### Flutter: Fix field names (or backend mapping)

Either:
- **Option A (recommended):** Backend maps `currentStage` → `currentLevel` in the response (shown above) — single change, Flutter stays unchanged
- **Option B:** Change all Flutter references from `currentLevel` to `currentStage` — more files touched (~4 places), but matches database field name

### Flutter: Replace hardcoded 50 fallback

```dart
// If xpForNextLevel is somehow still missing, compute from stage bracket:
int _xpForNextLevel(int stage) {
  if (stage <= 5) return 50;
  if (stage <= 15) return 75;
  if (stage <= 25) return 100;
  if (stage <= 35) return 150;
  if (stage <= 45) return 200;
  return 250;
}
```
