# BabyMon XP & Level-Up System — Technical Specification

**Status:** Spec (not yet implemented)
**Created:** 13 June 2026
**Scope:** Backend (API) and Frontend (Flutter mobile)

---

## 1. System Overview

BabyMon XP ("Monergy Points", MP) rewards parents for logging their baby's daily activities. As XP accumulates, the BabyMon progresses through 50 themed levels representing developmental stages — from newborn to kindergarten-ready. Each level-up triggers a visual celebration that makes tracking feel magical.

**Design inspiration:** Creature-raising adventure games — celebration moments, evolving stages, collection rewards (badges). Care taken to avoid copyright-conflicting names, characters, or mechanics from any specific intellectual property.

---

## 2. Points System

### 2.1 XP Earning

| Action | XP Awarded | Typical Daily Frequency |
|---|---|---|
| 🏆 Milestone logged | +10 | 0-1/day |
| 🍼 Feeding logged | +5 | 4-8/day |
| 😴 Sleep entry logged | +5 | 1-2/day |
| 💊 Health record logged | +5 | 0-0.5/day |

**XP is:** Cumulative per BabyMon, stored as `BabyMon.currentXp` (Prisma schema, line 119).
**XP is NOT:** Shared across BabyMons. Each BabyMon has independent progress.

### 2.2 XP Deduction

When an entry is soft-deleted within the 10-minute undo window, its `xpAwarded` value is deducted from `currentXp`. This can cause level-down if XP drops below the current stage threshold (acceptable behavior — the parent sees the undo and re-earns).

### 2.3 Level-Up Thresholds

Level-up thresholds follow a step function to balance reward frequency:

| Stage Range | XP Per Level | Cumulative XP to Complete Range |
|---|---|---|
| 1-5 | 50 | 250 |
| 6-15 | 75 | 1,000 |
| 16-25 | 100 | 2,000 |
| 26-35 | 150 | 3,500 |
| 36-45 | 200 | 5,500 |
| 46-50 | 250 | 6,750 |

**Total XP to reach Level 50: 6,750 MP**

**Estimated time at ~35 XP/day:** ~193 days (~6.4 months)
**Estimated time at ~15 XP/day:** ~450 days (~15 months)

### 2.4 Carry-Over System

When XP crosses the threshold, the excess carries over toward the next level:

```
Example: Lv 4 "Gaze Keeper" has 45 XP. Parent logs a milestone (+10).
New total: 55 XP. Threshold for Lv 5: 50 XP.
→ Level up to Lv 5 "Dewdrop" with 5 XP carrying over toward Lv 6.
```

This prevents "wasted XP" and means big actions (like logging a milestone) always feel fully rewarded.

### 2.5 XP Awards by Entry Type (Entity Model)

Each entry type stores its own award value at creation time (`xpAwarded` field), allowing future tuning without retroactive effects:

| Entry | Model | xpAwarded Default |
|---|---|---|
| Milestone | `Milestone` | 10 |
| Feed Log | `FeedLog` | 5 |
| Health Record | `HealthRecord` | 5 |
| Sleep Log | `SleepLog` | 5 |

---

## 3. The 50 Levels — BabyMon Bloom Journey

### 3.1 Phase Map

| Phase | Name | Levels | XP/Level | Cumulative XP | Theme |
|---|---|---|---|---|---|
| 1 | 🌰 Germination | 1-5 | 50 | 250 | Newborn cocoon — quiet, sacred, tiny miracles |
| 2 | 🌱 Rooting | 6-15 | 75 | 1,000 | Putting down roots — first sounds, first rolls |
| 3 | 🌿 Climbing | 16-25 | 100 | 2,000 | Vertical ambition — pulling up, cruising, first steps |
| 4 | 🌳 Branching | 26-35 | 150 | 3,500 | Running, jumping, pretending — a personality blossoms |
| 5 | 🏔️ Blossoming | 36-45 | 200 | 5,500 | Confidence grows — empathy emerges, world expands |
| 6 | ✨ Luminescence | 46-50 | 250 | 6,750 | Final climb — bright, kind, curious, ready for the world |

### 3.2 Complete Level Name Registry

#### Phase 1: Germination (Lv 1-5)
| Lv | Name | Developmental Meaning |
|---|---|---|
| 1 | Little Seed | Just planted in this world. Everything begins here. |
| 2 | Tiny Gripper | Those fingers curl around yours with surprising strength. |
| 3 | Sleep Sprout | A champion napper. Growing happens in the quiet. |
| 4 | Gaze Keeper | First sustained eye contact. They see you now. |
| 5 | Dewdrop 💧 | Fresh as morning dew, ready to unfold. |

#### Phase 2: Rooting (Lv 6-15)
| 6 | Burble Bud | Coos, gurgles, the first language. |
| 7 | Smile Weaver | That first real smile rewires your entire heart. |
| 8 | Neck Knight | Head control achieved. A tiny warrior emerges. |
| 9 | Tummy Roller | Rolling over changes their entire world. |
| 10 | Giggle Pod | Laughter! The best sound in the universe. |
| 11 | Reach Star | Grabbing, reaching, connecting with objects. |
| 12 | Babble Scholar | Ma-ma, da-da — the conversation begins. |
| 13 | Sitter Supreme | Sitting up unaided. A new perspective on everything. |
| 14 | Taste Adventurer | Solid foods! Every meal is an expedition. |
| 15 | Scoot Scout 💧 | Crawling, exploring, unstoppable. |

#### Phase 3: Climbing (Lv 16-25)
| 16 | Cruiser Cadet | Furniture-walking with fierce determination. |
| 17 | Wave Wizard | Bye-bye! Clapping! Communication through gesture. |
| 18 | Pincer Prince/ss | Pinching cheerios with surgical precision. |
| 19 | Stack Master | Tower of blocks. Crash. Rebuild. Repeat. |
| 20 | Step Seeker 💧 | Independent steps. The world just got much bigger. |
| 21 | Word Hoarder | Vocabulary explosion — 5 new words a day. |
| 22 | Melody Hummer | Singing along to songs, mostly in tune. |
| 23 | Puzzle Prodigy | Shapes find their homes. Pattern recognition blooms. |
| 24 | Spoon Warrior | Self-feeding: messy, proud, unstoppable. |
| 25 | No-Sayer 💧 | The will awakens. Independence takes form. |

#### Phase 4: Branching (Lv 26-35)
| 26 | Tower Climber | No surface too high, no chair too tall. |
| 27 | Scribble Sage | First art — on paper and sometimes walls. |
| 28 | Dress Dancer | Shoes on the wrong feet, but proud. |
| 29 | Question Storm | "Why?" asked 47 times before breakfast. |
| 30 | Story Dreamer 💧 | Elaborate tales with stuffed animal casts. |
| 31 | Count Keeper | Numbers climbing toward infinity. |
| 32 | Friend Finder | First friendships. Sharing (sometimes). |
| 33 | Brave Heart | Trying new things without looking back. |
| 34 | Emotion Sage | Naming feelings. Understanding the heart. |
| 35 | Jump Master 💧 | Hopping, skipping, airborne joy. |

#### Phase 5: Blossoming (Lv 36-45)
| 36 | Rhyme Weaver | Reciting nursery rhymes from heart. |
| 37 | Helper Hand | Setting tables, watering plants — contribution feels good. |
| 38 | Joke Crafter | Knock-knock jokes that almost make sense. |
| 39 | Memory Vault | Recalling events from long ago in vivid detail. |
| 40 | Promise Keeper 💧 | Understanding commitments. Keeping them. |
| 41 | Pattern Seer | Spotting order in chaos. A natural scientist. |
| 42 | Kindness Bloom | Conscious acts of kindness toward others. |
| 43 | Peace Maker | Mediating between friends. Compassion in action. |
| 44 | Path Finder | Leading the way on familiar routes. Confidence embodied. |
| 45 | Song Weaver 💧 | Original songs about breakfast. Pure joy. |

#### Phase 6: Luminescence (Lv 46-50)
| 46 | Wisdom Seed | Asking profound questions about life and the universe. |
| 47 | Story Teller | Original tales with plot, character, and imagination. |
| 48 | Light Keeper | Noticing when someone needs comfort. Being there. |
| 49 | Trail Blazer | Independence earned. Confidence radiating. |
| 50 | LUMINARY ⭐⭐⭐ | A bright, kind, curious soul ready to shine. |

💧 = Phase milestone — triggers extended celebration

---

## 4. Celebration UX Specification

### 4.1 Trigger Detection

**Backend:** After every XP-awarding action, the endpoint checks for level-up:

```
POST /api/baby-mons/:id/milestones (or feed-logs, sleep-logs, health-records)
  → awards XP → checks threshold → if crossed: increment currentStage
  → response includes: { leveledUp: true, newStage: N, levelName: "Dewdrop" }
```

**Frontend:** After every `_loadData()` call, compare `_previousLevel` with `_currentLevel`. If different (and `_previousLevel` is not null, meaning this isn't the first load), trigger the celebration.

### 4.2 Celebration Sequence (Flow)

Duration: ~3.5 seconds total. Tap-to-dismiss enabled after 1.0s.

| Time | Event | Animation |
|---|---|---|
| 0.0s | Celebration overlay appears | Scrim fades in (300ms) |
| 0.3s | XP bar pulses | Bar expands to full width, glows gold, then snaps to 0% toward next level |
| 0.6s | New level name appears | Large text fades in with scale bounce (1.2→1.0), golden glow effect behind text |
| 1.2s | Phase milestone check | If every 5th level: phase name appears below, particles double |
| 1.5s | Particles shower | 20-40 themed particles rain from top (leaf for phases 1-2, sparkle for 3-4, star for 5-6) |
| 2.0s | Description line | Fade in subtitle text ("Fresh as morning dew, ready to unfold") |
| 3.5s | Auto-dismiss | Gentle fade out. Bar returns to dashboard position, level badge updates |

### 4.3 Sound Design

- **Standard level-up:** Ascending wind chime, 3 notes, 0.8s duration
- **Phase completion (💧):** 5 notes, slightly more triumphant, 1.5s duration
- **Level 50 (LUMINARY):** Full orchestral swell, 3s duration, with a soft fade

Sounds are gentle and celebratory — reminiscent of a wind chime being stirred by a breeze, not video game fanfares. They should feel like a quiet moment of pride, not a competition.

### 4.4 Level 50 — Special Treatment

The LUMINARY level is the capstone. The celebration sequence is identical but followed by a "Journey Recap" on dismiss:

1. Horizontal scrollable timeline showing each phase completed
2. Phase emblems (🌰→🌱→🌿→🌳→🏔️→✨) in sequence
3. Final message: *"From a tiny seed to a shining soul. You've guided every step. This is the work of an amazing parent."*
4. A subtle confetti burst on close

### 4.5 Accessibility Notes

- All animations respect `MediaQuery.of(context).disableAnimations` (reduced motion)
- Level-up text has sufficient contrast (gold on dark scrim)
- Haptic feedback accompanies visual celebration (on devices with haptics)
- Screen reader announces: "Level up! Your BabyMon is now [Level Name]. [Description]"

---

## 5. Dashboard XP Bar Rendering

### 5.1 Current State (Broken)

```dart
// BUG: Hardcoded denominator of 100.0 — ignores dynamic thresholds
double get _xpProgress =>
    _evolution != null
        ? ((_evolution!['currentXp'] ?? 0) as num).toDouble() / 100.0
        : 0;

// BUG: Reads 'currentLevel' which doesn't exist — always returns 1
int get _currentLevel => parseInt(_evolution?['currentLevel']) ?? 1;
```

### 5.2 Fixed Implementation

The backend response already includes correctly computed values. The frontend should use them directly:

```dart
/// XP progress as 0.0-1.0 for the progress bar.
/// Reads the backend's pre-computed xpProgress value for accuracy.
double get _xpProgress {
  if (_evolution == null) return 0.0;
  // Use pre-computed value when available, fallback to raw calculation
  final progress = _evolution!['xpProgress'];
  if (progress != null) return (progress as num).toDouble() / 100.0;
  final xp = (_evolution!['currentXp'] as num?)?.toDouble() ?? 0;
  return xp / 100.0; // legacy fallback
}

/// Current level (evolution stage). Reads the backend field name correctly.
int get _currentLevel => parseInt(_evolution?['currentStage']) ?? 1;

/// XP required for next level. From backend or computed locally as fallback.
int get _xpForNextLevel {
  final val = parseInt(_evolution?['xpForNextLevel']);
  if (val != null) return val;
  return xpForNextLevel(_currentLevel);
}
```

### 5.3 Bar Display

The XP card on the dashboard shows:

```
┌─────────────────────────────────────────┐
│ ⚡ Experience                 35 / 50 XP │
│ ████████████░░░░░░░░░░░░░░░    70%     │
│ Current Level: Dewdrop (Lv 5)          │
│ Next: Burble Bud (Lv 6)                │
└─────────────────────────────────────────┘
```

When the bar is full (100%), it glows briefly gold before the level-up celebration triggers on the next data refresh.

---

## 6. Backend Implementation

### 6.1 New File: `apps/api/src/xp/xp.service.ts`

Centralized XP utility service:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export function xpForNextLevel(stage: number): number {
  if (stage < 1) return 50;
  if (stage <= 5) return 50;
  if (stage <= 15) return 75;
  if (stage <= 25) return 100;
  if (stage <= 35) return 150;
  if (stage <= 45) return 200;
  return 250;
}

export function getLevelName(stage: number): string {
  const names: Record<number, string> = {
    1: 'Little Seed', 2: 'Tiny Gripper', 3: 'Sleep Sprout',
    4: 'Gaze Keeper', 5: 'Dewdrop', 6: 'Burble Bud',
    7: 'Smile Weaver', 8: 'Neck Knight', 9: 'Tummy Roller',
    10: 'Giggle Pod', 11: 'Reach Star', 12: 'Babble Scholar',
    13: 'Sitter Supreme', 14: 'Taste Adventurer', 15: 'Scoot Scout',
    16: 'Cruiser Cadet', 17: 'Wave Wizard', 18: 'Pincer Prince/ss',
    19: 'Stack Master', 20: 'Step Seeker', 21: 'Word Hoarder',
    22: 'Melody Hummer', 23: 'Puzzle Prodigy', 24: 'Spoon Warrior',
    25: 'No-Sayer', 26: 'Tower Climber', 27: 'Scribble Sage',
    28: 'Dress Dancer', 29: 'Question Storm', 30: 'Story Dreamer',
    31: 'Count Keeper', 32: 'Friend Finder', 33: 'Brave Heart',
    34: 'Emotion Sage', 35: 'Jump Master', 36: 'Rhyme Weaver',
    37: 'Helper Hand', 38: 'Joke Crafter', 39: 'Memory Vault',
    40: 'Promise Keeper', 41: 'Pattern Seer', 42: 'Kindness Bloom',
    43: 'Peace Maker', 44: 'Path Finder', 45: 'Song Weaver',
    46: 'Wisdom Seed', 47: 'Story Teller', 48: 'Light Keeper',
    49: 'Trail Blazer', 50: 'LUMINARY',
  };
  return names[stage] ?? `Level ${stage}`;
}

export function isPhaseMilestone(stage: number): boolean {
  return stage > 0 && stage < 50 && stage % 5 === 0;
}

@Injectable()
export class XpService {
  constructor(private prisma: PrismaService) {}

  async checkAndProcessLevelUp(babymonId: string): Promise<{
    leveledUp: boolean;
    newStage?: number;
    levelName?: string;
    isPhaseMilestone?: boolean;
  }> {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon) return { leveledUp: false };

    const needed = xpForNextLevel(babyMon.currentStage);
    if (babyMon.currentXp >= needed && babyMon.currentStage < 50) {
      const newStage = babyMon.currentStage + 1;
      const carryOver = babyMon.currentXp - needed;

      await this.prisma.babyMon.update({
        where: { id: babymonId },
        data: {
          currentStage: newStage,
          currentXp: carryOver,
        },
      });

      return {
        leveledUp: true,
        newStage,
        levelName: getLevelName(newStage),
        isPhaseMilestone: isPhaseMilestone(newStage),
      };
    }

    return { leveledUp: false };
  }
}
```

### 6.2 New File: `apps/api/src/xp/xp.module.ts`

```typescript
import { Module, Global } from '@nestjs/common';
import { XpService } from './xp.service';

@Global()
@Module({
  providers: [XpService],
  exports: [XpService],
})
export class XpModule {}
```

### 6.3 Modified File: `apps/api/src/app.module.ts`

Add `XpModule` to the imports array.

### 6.4 Modified Files: XP-Awarding Services

Each service that awards XP must be updated to call the level-up check after the XP increment. The pattern is identical across all services:

| File | After line | Insert |
|---|---|---|
| `milestones.service.ts` | Line 43 (after XP award) | Inject `XpService`, call `checkAndProcessLevelUp()` |
| `feed-logs.service.ts` | Line 42 (after XP award) | Same |
| `health-records.service.ts` | Line 29 (after XP award) | Same |
| `sleep-logs.service.ts` | Line 42 (after XP award) | Same |

The change is minimal — inject the new dependency and add two lines:

```typescript
// After the XP award line:
// Check and process any level-up
const levelUpResult = await this.xpService.checkAndProcessLevelUp(babymonId);
```

### 6.5 Modified File: `evolution.service.ts`

Fix the `getEvolution()` method to use the new threshold function and include carry-over XP correctly. The response already includes `xpProgress` as a percentage — this line just needs to use the correct denominator:

```typescript
// OLD (broken for stages > 1):
const xpForNextLevel = (babyMon.currentStage + 1) * 100;

// NEW (correct dynamic threshold):
const xpForNextLevel = require('../xp/xp.service').xpForNextLevel(babyMon.currentStage);
```

Also add to the response:
```typescript
return {
  // ...existing fields...
  xpForNextLevel, // So frontend can display "35 / 50 XP"
  currentLevel: babyMon.currentStage, // Consistent key name
};
```

---

## 7. Frontend Implementation

### 7.1 Modified File: `apps/mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Fix 1:** Correct the XP progress calculation (see section 5.2 above).

**Fix 2:** Add `_previousLevel` state variable and detection:

```dart
int? _previousLevel;

// In _loadData(), after _evolution is populated:
if (mounted) {
  final newLevel = _currentLevel;
  if (_previousLevel != null && newLevel != _previousLevel) {
    // Trigger celebration on next frame to avoid build-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLevelUpCelebration(newLevel);
    });
  }
  _previousLevel = newLevel;
  setState(() {
    _isLoading = false;
    _isRefreshing = false;
  });
}
```

**Fix 3:** Add the celebration method:

```dart
void _showLevelUpCelebration(int newLevel) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (ctx) => LevelUpCelebration(
      level: newLevel,
      onDismiss: () => Navigator.of(ctx).pop(),
    ),
  );
}
```

### 7.2 New File: `apps/mobile/lib/features/dashboard/presentation/widgets/level_up_celebration.dart`

The celebration widget handles:
- Dark scrim backdrop
- Glowing XP bar animation (expands → pulses → resets)
- Level name reveal with scale bounce
- Themed particle effects (custom painter: leaf/sparkle/star particles)
- Phase milestone detection (every 5th level gets extended treatment)
- Level 50 special journey recap
- Haptic feedback on entry
- Tap-to-dismiss
- Accessibility: respect reduced motion, provide screen reader announcements

The 50-level name map and phases are defined as static constants within this file (could be extracted to a shared constants file later if needed elsewhere).

### 7.3 Barrel Export

Add to `apps/mobile/lib/features/dashboard/dashboard.dart`:
```dart
export 'presentation/widgets/level_up_celebration.dart' show LevelUpCelebration;
```

---

## 8. Files Summary

| File | Action | Purpose |
|---|---|---|
| `docs/12-XP-SYSTEM-SPEC.md` | **NEW** | This specification document |
| `apps/api/src/xp/xp.service.ts` | **NEW** | Centralized XP logic, thresholds, level-up processing |
| `apps/api/src/xp/xp.module.ts` | **NEW** | NestJS module (global) |
| `apps/api/src/app.module.ts` | MODIFY | Add XpModule to imports |
| `apps/api/src/evolution/evolution.service.ts` | MODIFY | Fix threshold formula, add response fields |
| `apps/api/src/milestones/milestones.service.ts` | MODIFY | Inject XpService, call level-up check |
| `apps/api/src/feed-logs/feed-logs.service.ts` | MODIFY | Inject XpService, call level-up check |
| `apps/api/src/health-records/health-records.service.ts` | MODIFY | Inject XpService, call level-up check |
| `apps/api/src/sleep-logs/sleep-logs.service.ts` | MODIFY | Inject XpService, call level-up check |
| `apps/mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart` | MODIFY | Fix XP bar, add level detection |
| `apps/mobile/lib/features/dashboard/presentation/widgets/level_up_celebration.dart` | **NEW** | Animated celebration overlay |
| `apps/mobile/lib/features/dashboard/dashboard.dart` | MODIFY | Add celebration widget export |

**No changes needed:** Prisma schema, badge system, growth records, allergy tracking, journal, settings, auth.

---

## 9. Testing Checklist

### Backend
- [ ] Creating a milestone awards 10 XP and triggers badge check
- [ ] Creating a feed log awards 5 XP
- [ ] When XP crosses threshold, `currentStage` increments and XP carries over
- [ ] Deleting a record within undo window deducts XP (and may level down)
- [ ] `getEvolution()` returns correct `xpProgress`, `xpForNextLevel`, `currentLevel`
- [ ] Level 50 is the cap — no level-up beyond it
- [ ] Phase milestones (every 5 levels) are correctly detected

### Frontend
- [ ] Dashboard XP bar shows correct percentage for current level
- [ ] Level number display uses correct value from backend
- [ ] When a level-up occurs, celebration overlay appears on next load
- [ ] Level 50 triggers special extended celebration with journey recap
- [ ] Level-up overlay respects reduced motion accessibility setting
- [ ] Tap dismisses celebration
- [ ] Haptic feedback fires on celebration entry
- [ ] Level-up is NOT triggered on first dashboard load (only on detected changes)

---

## 10. Future Extensions (Out of Scope)

- **XP bonuses** for streaks (logging 7 days in a row)
- **Co-parent XP sharing** — both parents' logs contribute to the same BabyMon
- **Seasonal events** — limited-time XP multipliers for themed periods
- **Level-up push notifications** — "Your BabyMon reached Level 10: Giggle Pod!"
- **Level badge collection** — visual gallery of all 50 level emblems earned
- **Leaderboards** — gentle comparison with friends (opt-in only)