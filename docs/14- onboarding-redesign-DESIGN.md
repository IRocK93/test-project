# Onboarding Redesign: Narrative Registration Flow

## Overview

Transform the current 4-step form (`create_baby_mon_screen.dart`) into an emotive,
guide-led narrative onboarding. The user doesn't "submit fields" — they are
welcomed into a parenting journey by **MJ**, a gentle, genderless narrator who
guides each interaction with warm second-person prose.

> **Spirit reference:** The magical-familiar bonding moment in games like Pokémon
> (first lab scene where you receive your partner). **Copyright is a hard line:
> zero Pokémon terminology, imagery, or trademarkable concepts.** The feeling is
> "welcome to something precious" — not "catch, battle, or train."

---

## Table of Contents

1. [Guide Character — MJ](#1-guide-character--mj)
2. [Copyright Guardrails](#2-copyright-guardrails)
3. [Narrative Flow](#3-narrative-flow)
4. [Step-by-Step Specifications](#4-step-by-step-specifications)
5. [Sound Design](#5-sound-design)
6. [Animation & Motion](#6-animation--motion)
7. [Flavor Text System](#7-flavor-text-system)
8. [Component Tree & Dependencies](#8-component-tree--dependencies)
9. [Data Flow](#9-data-flow)
10. [Edge Cases](#10-edge-cases)
11. [Implementation Order](#11-implementation-order)
12. [File Manifest](#12-file-manifest)

---

## 1. Guide Character — MJ

| Attribute | Value |
|-----------|-------|
| **Name** | MJ (initials only — no expanded form) |
| **Voice** | Second-person, present tense, warm but not saccharine |
| **Visual** | None — MJ is a voice only (no avatar, no portrait) |
| **Appearance** | Rendered as floating italic Syne Light text on the glass card surface |
| **Tone examples** | *"Every great journey begins with a single heartbeat."* / *"Names carry stories. What will yours be called?"* |
| **Anti-patterns** | Never uses first person ("I think..."), never gives instructions ("Enter your name"), never references game mechanics |
| **Implementation** | `_mjMessage` state field updated per step; rendered in a `Text` widget above the interaction area with a fade-slide animation on each step change |

### MJ Voice Permissions & Prohibitions

| ✅ Allowed | ❌ Prohibited |
|------------|---------------|
| "Your BabyMon" | "Your Pokémon / monster / creature" |
| "Journey" | "Quest / adventure / mission" |
| "Spirit" | "Type / element / class" |
| "Milestone" | "Evolution / level-up / rank" |
| "Special gift" | "Special move / attack / ability" |
| "Welcome" | "Catch / capture / collect" |
| "Nest / cradle" | "Ball / capsule / pod" |
| "Parenting story" | "Trainer story / battle story" |

---

## 2. Copyright Guardrails

Every text string, icon choice, and interaction must pass this test:
> *"Could a reasonable person associate this with a Nintendo/Pokémon product?"*

**If yes → redesign the text/interaction. Do not approximate.**

Hard-blocked concepts:
- **Pokémon, Poké Ball, Professor, Gym, Badge, Trainer, League, Battle, Type chart, Shiny, Rare, Evolve (verb for BabyMon), Catch, Release, Trade, Breed**
- Pikachu, Charizard, or any recognizable Pokémon name/design
- Red/Blue/Pokédex UI color schemes
- "Gotta catch 'em all" or any slogan-like phrasing

MJ's voice described as "warm guide" → the **safe** reference is the opening of
*The House in the Cerulean Sea* or *Kiki's Delivery Service* — gentle, affirming,
no game mechanics.

---

## 3. Narrative Flow

```
Step 0: Splash     →  "Every great journey begins with a single heartbeat."
Step 1: Name       →  "Names carry stories. What will yours be called?"
Step 2: Stage/Date →  "When did your unique journey begin?"
Step 3: Spirit     →  "Every BabyMon has a unique spirit. Let's discover yours."
Step 4: Review     →  "You've written the first page of your story together."
```

Each step is a **ceremonial interaction**, not a form field. Text fields, chips,
and pickers are restyled to feel like meaningful choices, not data entry.

---

## 4. Step-by-Step Specifications

### Step 0 — Splash (NEW)

**Purpose:** Set emotional tone. Introduce MJ. Create a held-breath moment.

**Layout (top to bottom):**
```
[glass card — PremiumDoubleBezel]
  ┌─────────────────────────────────┐
  │                                 │
  │          [glowing orb]          │  ← 80px animated orb, breath pulse
  │                                 │
  │    "Every great journey         │  ← MJ text, Syne Light italic
  │     begins with a single        │     opacity 0.7, centered
  │     heartbeat."                 │
  │                                 │
  │    "Yours started the moment    │  ← MJ text, continued
  │     you decided to welcome      │
  │     a new life."                │
  │                                 │
  │    ┌──────────────────────┐     │
  │    │  Begin Your Journey  │     │  ← ThemeButton, full width
  │    └──────────────────────┘     │     pulse animation when ready
  │                                 │
  └─────────────────────────────────┘
```

- Orb: `Container` with `ClipOval` + `BackdropFilter` blur + animated radial gradient
- MJ text: fades in with staggered timing (line 1 @ 0.5s, line 2 @ 1.5s)
- Button: appears @ 2.5s with gentle fade+slide up
- On tap: fade out splash (0.4s), chime plays, transition to Step 1
- **Not skippable** — shown for every BabyMon creation (not just first-time)
- Step indicator shows all 5 steps (Step 0 + 1-4)

**State:** No data collected. `_currentStep = 0` (splash), extends `_totalSteps` to 5.

---

### Step 1 — Name Your BabyMon (was Step 0)

**Layout:**
```
  MJ: "Names carry stories. What will yours be called?"

  [avatar orb — breathing animation]
  [text field — ceremonial naming moment]
  [suggested name chips — floating, Pill-shaped]
```

**Ceremonial naming moment:**
- When text field gains focus → background orb pulses brighter
- When user types first character → soft glow border appears on field
- When user clears field → glow fades
- Suggested names: 3-4 rotating placeholder suggestions (e.g., "Luna, Milo, Nova") shown as translucent chips below the field; tapping a chip enters it
- "Continue" button disabled until name is non-empty

**MJ text variants (rotated or one per visit):**
- *"A name is the first gift you'll give. What feels right?"*
- *"Some names arrive like a whisper. Others wait to be discovered."*
- *"What will your BabyMon answer to?"*

---

### Step 2 — When Does Your Journey Start? (was Step 1)

**Layout:**
```
  MJ: "Every journey begins at a different point. When did yours begin?"

  [3 stage cards — horizontal row]
    ┌──────────┐  ┌──────────┐  ┌──────────┐
    │  [icon]  │  │  [icon]  │  │  [icon]  │
    │  Born    │  │Conceived │  │  Idea    │
    │"A gentle │  │"A beauti-│  │"A heart- │
    │ arrival" │  │ ful sur- │  │ felt     │
    │          │  │ prise"   │  │ wish"    │
    └──────────┘  └──────────┘  └──────────┘

  [date picker — calendar-style, not wheel]
    ┌─────────────────────────┐
    │  <  June 2026  >        │
    │  Mo Tu We Th Fr Sa Su   │
    │      1  2  3  4  5  6   │
    │  7  8  9 10 11 12 13 14 │
    │ 15 16 17 ...            │
    │           [Today]       │
    └─────────────────────────┘
```

- Stage cards: `AnimatedContainer`, selected card has a warm border glow, unselected cards are dimmed
- Poetic stage descriptions replace the current bare labels:
  - **Born** → *"A gentle arrival. The world welcomed them."*
  - **Conceived** → *"A beautiful surprise. The journey began in stillness."*
  - **Idea** → *"A heartfelt wish. Long before they existed, they were loved."*
- Date picker: Replace the wheel picker with a calendar grid (`TableCalendar` or custom). Selected date gets a filled circle behind it. "Today" button scrolls to current date.

---

### Step 3 — Discover Their Spirit (was Step 2)

**Layout:**
```
  MJ: "Every BabyMon has a unique spirit. Let's discover yours."

  [3 gender orbs — large, touchable, pulse on press]
    ┌──────┐  ┌──────┐  ┌──────┐
    │      │  │      │  │      │
    │   M  │  │   F  │  │  ☆   │
    │      │  │      │  │      │
    └──────┘  └──────┘  └──────┘
   Moniese   Monious   Neutral

  [trait chips — 2 rows of 3, with flavor text beneath]
    ┌──────┐ ┌────────┐ ┌────────┐
    │Curious│ │ Peaceful│ │ Playful│
    └──────┘ └────────┘ └────────┘
    ┌──────┐ ┌──────────┐ ┌────────┐
    │Gentle│ │Adventurous│ │Creative│
    └──────┘ └──────────┘ └────────┘

    [flavor text — appears below chips when one is selected]
    "Curious — always exploring the world with wide eyes."

  [special gift input]
    "Every BabyMon has a special gift. What's yours?"
    [text field — optional, smaller, less prominent]
```

**Gender interaction:**
- Three large orbs (~72px) with subtle breathing animation
- No binary labels — just soft feminine/masculine/neutral visual cues (colors, shapes)
- **Moniese**: warm pink-coral gradient, soft petal shape
- **Monious**: cool blue-lavender gradient, gentle wave shape
- **Neutral**: golden-cream gradient, star/sparkle shape
- Selected orb: full opacity + glow, unselected: 0.4 opacity
- Selection is NOT required — gender can be unset (neutral is default)

**Trait chips with flavor text:**
- Chips are `FilterChip` styled to match the premium theme
- Multi-select: toggle on/off
- When tapped ON → flavor text fades in below the chip row
- When tapped OFF → flavor text fades out
- Only the LAST tapped chip's flavor text is shown
- See [Section 7 — Flavor Text System](#7-flavor-text-system) for all strings

---

### Step 4 — Review & Begin (was Step 3)

**Layout:**
```
  MJ: "You've written the first page of your story together.
       Are you ready to begin?"

  [PremiumDoubleBezel card — styled as a journal page]
    ┌────────────────────────────────┐
    │                                │
    │   ✦  [Name]                   │  ← Syne display, large
    │                                │
    │   [Date formatted poetically]  │  ← "A summer morning · June 13"
    │   [Stage descriptor]           │  ← "A gentle arrival" / etc.
    │                                │
    │   [Spirit words — chips]       │
    │   [Gender symbol — small]      │
    │   [Special gift — if entered]  │
    │                                │
    └────────────────────────────────┘

  ┌──────────────────────────────────┐
  │        Begin Your Story          │  ← ThemeButton with pulse
  └──────────────────────────────────┘
```

- **Poetic date formatting:**
  - Morning (5-12): `"A ${weekday} morning · ${month} ${day}"`
  - Afternoon (12-17): `"A ${weekday} afternoon · ${month} ${day}"`
  - Evening (17-22): `"A ${weekday} evening · ${month} ${day}"`
  - Night (22-5): `"A ${weekday} night · ${month} ${day}"`
  - If no date selected: `"The journey has begun"`
- "Begin" button: slow pulse animation (scale: 1.0 ↔ 1.02, duration: 2s)
- On tap: plays chime, brief particle burst (confetti-like, warm colors), then navigates to dashboard
- Loading state replaces button text with spinner, button disabled

---

## 5. Sound Design

### Ceremonial Chime

A single soft chime plays at the naming moment:
- **When:** First character typed in the name field (Step 1)
- **Asset:** `assets/audio/naming_chime.wav` or `.mp3`
- **Character:** Warm, short (< 1s), piano or glockenspiel, single note (C5 or D5 major)
- **Volume:** 0.3 of system volume
- **Ducking:** Lower any background audio by 50% during playback (if any)

### Implementation

```dart
final _audioPlayer = AudioPlayer();  // from audioplayers package

Future<void> _playNamingChime() async {
  await _audioPlayer.setVolume(0.3);
  await _audioPlayer.play(AssetSource('audio/naming_chime.mp3'));
}
```

**Dependency:** Add `audioplayers: ^6.0.0` to `pubspec.yaml` (check current version).

### Audio Source

The chime should be sourced from a royalty-free library:
- [Pixabay Music](https://pixabay.com/music/search/mood/relaxing/)
- [Freesound.org](https://freesound.org/) — filter by CC0 license
- Search terms: "soft piano chime", "glockenspiel single note", "bell tone warm"
- File must be < 50KB, mono, 44100Hz, MP3 or WAV

Place in `assets/audio/` and register in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/audio/
```

---

## 6. Animation & Motion

### Cross-Step Animations

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Step transition (enter) | FadeSlideUp (y: 20→0, opacity: 0→1) | 400ms | `DesignTokens.curvePremium` |
| Step transition (exit) | FadeSlideUp (y: 0→-20, opacity: 1→0) | 300ms | `DesignTokens.curvePremium` |
| MJ text change | Cross-fade + subtle y-shift | 350ms | easeOut |
| Orb pulse | Scale 1.0 ↔ 1.05 | 3s | easeInOut, repeat |
| Stage card select | Border glow + scale 1.0 → 1.02 | 200ms | easeOut |
| Gender orb select | Opacity 0.4 → 1.0 + glow appear | 300ms | easeOut |
| Flavor text appear | FadeSlideUp (y: 8→0, opacity: 0→1) | 250ms | easeOut |
| Chips toggle | Scale bounce (1.0→1.15→1.0) + color transition | 300ms | spring |
| Naming glow pulse | Border opacity 0 → 0.5 → 0 | 2s per cycle | easeInOut, one-shot on first char |
| "Begin" button pulse | Scale 1.0 ↔ 1.02 | 2s | easeInOut, repeat |
| Particle burst | Radial outward + fade out | 800ms | easeOut |

### Page Transition (AnimatedSwitcher)

Keep the existing `AnimatedSwitcher` with `StaggeredFadeSlide` but update
`pageTransitionBuilder` in `DesignTokens` to prefer vertical slide (upwards)
instead of cross-fade, to reinforce the "turning a page" feeling.

---

## 7. Flavor Text System

### Data Structure

```dart
const Map<String, String> traitFlavorText = {
  'Curious': 'Curious — always exploring the world with wide eyes.',
  'Peaceful': 'Peaceful — a calm presence that soothes everyone around them.',
  'Playful': 'Playful — finding joy in every tiny moment.',
  'Gentle': 'Gentle — the softest touch, the kindest heart.',
  'Adventurous': 'Adventurous — ready to discover something new every day.',
  'Creative': 'Creative — seeing the world differently, beautifully.',
};
```

### Behavior

- **Show:** When a trait chip transitions from unselected → selected, its flavor
  text appears below the chip row with a 250ms fade-slide-up animation
- **Replace:** If another chip is already showing flavor text, the old text
  fades out (150ms) while the new text fades in (250ms)
- **Hide:** When the last selected chip is unselected, the text fades out (200ms)
- **Multiple selected:** Only the LAST tapped chip's flavor text is shown
  (most-recent-wins)

### State

```dart
String? _lastTappedTrait;  // null when no traits selected
```

---

## 8. Component Tree & Dependencies

```
CreateBabyMonScreen (ConsumerStatefulWidget)
├── Stack
│   ├── Scaffold
│   │   ├── PremiumBackground
│   │   │   └── Column
│   │   │       ├── SizedBox (spacer, clears floating back button)
│   │   │       ├── _buildStepIndicator()       ← KEEP, update to 5 circles
│   │   │       ├── Expanded
│   │   │       │   └── AnimatedSwitcher
│   │   │       │       └── StaggeredFadeSlide
│   │   │       │           └── _buildCurrentStep()
│   │   │       │               ├── Step 0: _buildSplash()                [NEW]
│   │   │       │               ├── Step 1: _buildNameStep()              [REWRITE]
│   │   │       │               ├── Step 2: _buildStageStep()             [REWRITE]
│   │   │       │               ├── Step 3: _buildSpiritStep()            [REWRITE]
│   │   │       │               └── Step 4: _buildReviewStep()            [REWRITE]
│   │   │       └── SafeArea > buttons
│   │   │           ├── [Back] button (ThemeButton.outlined)
│   │   │           └── [Continue/Begin] button (ThemeButton.filled)
│   │   └── Positioned (floating back button overlay)  ← KEEP
│   └── ...floating back button
```

### New Widgets Needed

| Widget | File | Description |
|--------|------|-------------|
| `NamingTextField` | inline (Step 1) | Text field with ceremonial glow, suggested name chips, chime trigger |
| `StageSelectionCard` | inline (Step 2) | Tappable card with icon, title, poetic description |
| `GenderOrb` | inline (Step 3) | Pressable orb with gradient, glow, breathing animation |
| `FlavorChip` | inline (Step 3) | `FilterChip` with on-select flavor text display |
| `CeremonialCard` | inline (Step 4) | Journal-style summary card with poetic formatting |
| `SplashOrb` | inline (Step 0) | Animated orb with radial gradient + backdrop blur |

**No external packages needed** beyond `audioplayers` (for chime).

---

## 9. Data Flow

### State Changes

```
_currentStep: 0 → 1 → 2 → 3 → 4
_totalSteps: 4 → 5  (added splash)
```

### Variables Mapped Per Step

| Step | Reads | Writes | Validates |
|------|-------|--------|-----------|
| 0 (Splash) | — | — | Always `_canProceed = true` after animation |
| 1 (Name) | `_nameController.text` | `_nameController` | `_nameController.text.trim().isNotEmpty` |
| 2 (Stage) | `_stageType`, `_birthDate`/`_conceptionDate`/`_ideaDate` | `_stageType`, date | As before |
| 3 (Spirit) | `_gender`, `_selectedTraits` | `_gender`, `_selectedTraits` | `true` (gender is optional) |
| 4 (Review) | All | `_specialMoveController` | `true` |

### API Contract

No changes. The `_createBabyMon()` POST remains identical — same fields, same
`Map<String, dynamic>` structure, same `/baby-mons` endpoint. The redesign is
purely frontend.

---

## 10. Edge Cases

| Edge Case | Behavior |
|-----------|----------|
| Name exceeds 50 chars | Field truncates at 50, shows subtle character counter near limit (45+) |
| No date selected (Step 2) | Continue button disabled |
| Gender not selected | Defaults to `MONIOUS` (existing behavior, sent as `gender` field) |
| No traits selected | Submit empty `[]` for `traits` field |
| Special move empty | Omit `specialMove` from payload (existing behavior) |
| Splash rapidly tapped | Debounce: prevent double-navigation, button disabled during transition |
| Back button on Splash | Navigates away from screen (pops or goes home) — same as Step 0 currently |
| Chime fails to load | Silent fail — no error shown, naming moment proceeds without sound |
| Very long name in review | `Text` with `overflow: TextOverflow.ellipsis`, max 1 line |
| Step indicator on Step 0 | Circle 0 is active, shows "S" or a heart icon instead of "1" |
| Poetic date with missing date | Display: `"The journey has begun"` |
| Orientation change | Rebuild layout (Flutter standard). Date picker re-renders. No custom handling needed. |

---

## 11. Implementation Order

| Phase | Tasks | Effort |
|-------|-------|--------|
| **P0** | Extend `_totalSteps` to 5, add Step 0 splash step shell, update step indicator to 5 dots | 15min |
| **P0** | Implement `_buildSplash()` with animated orb, MJ text, "Begin" button | 30min |
| **P1** | Rewrite `_buildNameStep()`: ceremonial text field, suggested name chips, chime integration | 45min |
| **P1** | Rewrite `_buildStageStep()`: stage cards (icon + title + poetic description), calendar date picker | 60min |
| **P1** | Rewrite `_buildSpiritStep()`: gender orbs, trait chips with flavor text system | 45min |
| **P2** | Rewrite `_buildReviewStep()`: journal-style card, poetic date formatting, particle burst | 45min |
| **P2** | Add MJ text system: `_mjMessage` per step, fade-slide transition | 15min |
| **P2** | Update cross-step page transition (vertical slide) | 10min |
| **P3** | Add `audioplayers` dep, source + add chime, wire into naming moment | 30min |
| **P3** | Add particle burst widget for "Begin" tap | 30min |
| **P3** | Polish: animation timing, responsive layout, accessibility labels | 30min |
| **P4** | Full `flutter analyze` pass, test on device | 15min |

---

## 12. File Manifest

### Files to Modify

| File | Changes |
|------|---------|
| `lib/features/onboarding/presentation/screens/create_baby_mon_screen.dart` | All step builders rewritten, splash added, `_totalSteps` → 5, MJ state, flavor text state |
| `lib/core/theme/design_tokens.dart` | Optionally: add `pageTransitionVertical` builder, `durationSlow` for splash |
| `pubspec.yaml` | Add `audioplayers` dependency, register `assets/audio/` |

### Files to Create

| File | Purpose |
|------|---------|
| `assets/audio/naming_chime.mp3` | Ceremonial chime sound (royalty-free) |
| No new Dart files | All new widgets are inline methods on `_CreateBabyMonScreenState` |

### Files to Delete

None.

---

## Appendix A: MJ Script — Full Per-Step Copy

### Step 0 — Splash

| Element | Text |
|---------|------|
| Line 1 | *"Every great journey begins with a single heartbeat."* |
| Line 2 | *"Yours started the moment you decided to welcome a new life."* |
| Button | **Begin Your Journey** |

### Step 1 — Name

| Variant | Text |
|---------|------|
| A | *"Names carry stories. What will yours be called?"* |
| B | *"A name is the first gift you'll give. What feels right?"* |
| C | *"Some names arrive like a whisper. Others wait to be discovered."* |
| D | *"What will your BabyMon answer to?"* |

### Step 2 — Stage

| Text | Line |
|------|------|
| Primary | *"Every journey begins at a different point. When did yours begin?"* |
| Validation empty | *"Mark the day your story began."* |

### Step 3 — Spirit

| Text | Line |
|------|------|
| Primary | *"Every BabyMon has a unique spirit. Let's discover yours."* |
| Trait hint | *"What words feel like them?"* |
| Special gift | *"Every BabyMon has a special gift. What's yours?"* |

### Step 4 — Review

| Text | Line |
|------|------|
| Primary | *"You've written the first page of your story together. Are you ready to begin?"* |
| Button resting | **Begin Your Story** |
| Button loading | **Writing the next page...** |
| Success | (particle burst, navigate to dashboard) |

---

## Appendix B: Design Token Alignment

All new UI must reference these existing tokens — no new hardcoded values:

| Token | Value | Used For |
|-------|-------|----------|
| `DesignTokens.curvePremium` | `Cubic(0.32, 0.72, 0.0, 1.0)` | All step transitions, MJ text crossfade |
| `DesignTokens.durationNormal` | 300ms | Standard fades, chip transitions |
| `DesignTokens.durationPage` | 400ms | Step transition |
| `DesignTokens.spaceXl` | 20px | Card padding, chip gaps |
| `DesignTokens.radiusFull` | 999px | Stage cards, orbs, chips |
| `AppColors.primary` | `#7C5CFC` | Selected state glow, active indicators |
| `AppColors.textOnDark` | `#F0F0F5` | MJ text color |
| `AppColors.glassWhite` | `#CCFFFFFF` | Ceremonial card surface |
| `PremiumDoubleBezel` | — | Splash card, review card |
| `PremiumBackground` | — | Step backgrounds |
