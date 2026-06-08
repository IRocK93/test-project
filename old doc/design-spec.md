# BabyMon Design Specification

**Version:** 1.0  
**Date:** April 23, 2026  
**Author:** Design Subagent

---

## 1. Color Palette & Typography

| Role | Color | Hex |
|------|-------|-----|
| Primary | Soft purple/lavender | `#9C7CF4` |
| Secondary | Warm coral/peach | `#FF8A65` |
| Background | Light cream | `#FFF8F0` |
| Accent | Mint green | `#81D4CA` |
| Text | Dark charcoal | `#2D2D2D` |
| Text (secondary) | Medium gray | `#6B6B6B` |
| Surface (cards) | White | `#FFFFFF` |
| Error | Soft red | `#E57373` |
| Success | Soft green | `#81C784` |
| XP bar fill | Gradient purple→coral | `#9C7CF4` → `#FF8A65` |
| Locked state | Light gray | `#E0E0E0` |

**Typography:**
- Font family: `Google Fonts - Nunito` (rounded, friendly)
- Heading 1: 28sp, Bold
- Heading 2: 22sp, SemiBold
- Heading 3: 18sp, SemiBold
- Body: 16sp, Regular
- Caption: 14sp, Regular
- Overline: 12sp, Medium, UPPERCASE

**Spacing System (8pt grid):**
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

**Border Radius:**
- Small (chips, buttons): 12px
- Medium (cards, inputs): 16px
- Large (modals, sheets): 24px
- Full (avatars, FAB): 50%

---

## 2. Spacing & Layout Constants

- Screen horizontal padding: 16px
- Card internal padding: 16px
- Bottom nav height: 80px (including safe area)
- Top app bar height: 56px
- FAB size: 56px
- Mini FAB size: 40px

---

## 3. Dashboard Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "BabyMon" [Avatar]  │  56px
├─────────────────────────────────┤
│                                 │
│  EvolutionVisualizationWidget   │  ~280px
│  (3D animated baby stage)       │
│                                 │
├─────────────────────────────────┤
│  XpProgressBar                  │  64px
│  "Level 3 · 2,450 / 3,000 XP"   │
├─────────────────────────────────┤
│  "Recent Badges" Row → See All  │  120px
│  [BadgeCard] [BadgeCard] [→]    │
├─────────────────────────────────┤
│  AiContentCard                  │  ~180px
│  "This week's guidance..."      │
├─────────────────────────────────┤
│                                 │
│  QuickActionsRow                │  80px
│  [🍼 Feed] [📊 Health] [📝+]    │
│                                 │
└─────────────────────────────────┘
│  BottomNavBar                    │  80px
└─────────────────────────────────┘
```

### Widget Hierarchy

```
Scaffold
├── appBar: PreferredSize
│   ├── BabyMonSwitcherAppBar
│   │   ├── Row
│   │   │   ├── BabyMonAvatar (current baby, 40px)
│   │   │   ├── Column (name, stage chip)
│   │   │   └── IconButton (dropdown chevron)
│   │   └── PopupMenuButton<BabyMon> (switcher)
│   └── bottom: BorderSide (subtle)
│
└── body: SingleChildScrollView
    ├── EvolutionVisualizationWidget
    │   ├── AnimatedContainer (stage background)
    │   ├── TweenAnimationBuilder<double>
    │   │   └── LottieAnimation / CustomPaint (baby silhouette)
    │   └── StageLabel (Nunito 18sp, centered)
    │
    ├── XpProgressBar
    │   ├── Container (height: 12px, border-radius: 6px)
    │   └── AnimatedProgress indicator (600ms ease-out)
    │
    ├── SectionHeader ("Recent Badges")
    │   ├── Text
    │   └── TextButton ("See All")
    │
    ├── BadgeShowcase (horizontal ListView, height: 100px)
    │   └── BadgeCard (small variant, 80x100px)
    │
    ├── AiContentCard (Tier 2 / trial only)
    │   ├── Card (elevation: 2, border-radius: 16px)
    │   │   ├── Row (icon + title)
    │   │   ├── Text (preview text, 3 lines max)
    │   │   └── ElevatedButton ("Read More")
    │   └── Opacity (paywall overlay for Tier 1 expired)
    │
    ├── QuickActionsRow
    │   └── Row (mainAxisAlignment: spaceBetween)
    │       ├── ActionButton (icon + label, mini variant)
    │       ├── ActionButton
    │       └── ActionButton
    │
    └── SizedBox (bottom padding for nav)
```

### State Management (Riverpod)

```dart
// Providers
final currentBabyMonProvider = StateNotifierProvider<BabyMonNotifier, BabyMon?>;
final evolutionProvider = FutureProvider.family<Evolution, String>((ref, babyId));
final recentBadgesProvider = FutureProvider.family<List<Badge>, String>((ref, babyId));
final aiContentProvider = FutureProvider.family<StageContent, String>((ref, stageKey));
final subscriptionProvider = FutureProvider<Subscription>;
```

### Animation Notes

- **EvolutionVisualizationWidget:** On load, scale from 0.8→1.0 (400ms spring curve). Silhouette swaps with fade crossfade (300ms). Particles emit on stage-up event.
- **XpProgressBar:** Width animates from current→new value (800ms ease-out curve). Number counts up using `IntTween`.
- **BadgeCard (unlock):** Scale 0→1.2→1.0 with bounce curve (500ms), accompanied by radial gradient burst animation.
- **AiContentCard:** Fade in on scroll into view (200ms).

---

## 4. Milestones Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "Milestones"        │
│  [FilterIcon] [SortIcon]        │
├─────────────────────────────────┤
│  StageChips (horizontal scroll) │  48px
│  [All] [Firsts] [Funny] [Love]  │
├─────────────────────────────────┤
│                                 │
│  ListView.builder               │
│  ┌─────────────────────────────┐│
│  │ EntryCard                    ││
│  │ ┌─────┐                     ││
│  │ │Photo│ Title               ││
│  │ │ 80x80│ Date · Stage tag   ││
│  │ └─────┘ Notes preview...    ││
│  │              [PendingSync]  ││
│  └─────────────────────────────┘│
│                                 │
│  ... more cards ...             │
│                                 │
└────────────────┬────────────────┘
                 │ FloatingActionButton (FAB)
                 └──────────────────────────────┘
```

### Widget Hierarchy

```
Scaffold
├── appBar: AppBar
│   ├── title: Text "Milestones"
│   └── actions: [
│       IconButton (filter_list)
│       IconButton (sort)
│      ]
│
├── body: Column
│   ├── StageChips (SingleChildScrollView)
│   │   └── Row
│   │       └── StageChip (selected/unselected states)
│   │
│   └── Expanded
│       └── ListView.builder
│           ├── Slidable (swipe actions)
│           │   └── EntryCard
│           │       ├── Row
│           │       │   ├── ClipRRect (photo, 80x80, border-radius: 12px)
│           │       │   └── Expanded
│           │       │       ├── Text (title, semibold)
│           │       │       ├── Text (date, caption)
│           │       │       ├── Row (stage tag + sync indicator)
│           │       │       └── Text (notes preview, 2 lines)
│           │       └── ...
│           │
│           └── EmptyState (if no milestones)
│               └── Column + illustration + CTA
│
└── fab: FloatingActionButton (create)
    └── Icon (add)
```

### Create Modal

```
┌─────────────────────────────────┐
│  BottomSheet (drag handle)      │
│  ┌─────────────────────────────┐│
│  │ "New Milestone"    [X close]││
│  ├─────────────────────────────┤│
│  │                             ││
│  │  PhotoPickerCard            ││
│  │  (tap to add photo, 120px)  ││
│  │                             ││
│  │  TextField (title*)         ││
│  │                             ││
│  │  DateTimePicker (date/time)││
│  │                             ││
│  │  TextField (notes, 3 lines) ││
│  │                             ││
│  │  CategoryDropdown           ││
│  │  [Firsts ▼]                ││
│  │                             ││
│  │  [Cancel]    [Save]         ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

### State Management

```dart
final milestonesProvider = StateNotifierProvider.family<MilestonesNotifier, AsyncValue<List<Milestone>>, String>(
  (ref, babyId) => MilestonesNotifier(ref, babyId),
);

final milestoneFilterProvider = StateProvider<MilestoneCategory?>;
final milestoneSortProvider = StateProvider<SortOption>;

final filteredMilestonesProvider = Provider<AsyncValue<List<Milestone>>>((ref) {
  final milestones = ref.watch(milestonesProvider);
  final filter = ref.watch(milestoneFilterProvider);
  final sort = ref.watch(milestoneSortProvider);
  // apply filter + sort to milestones
});
```

### Animation Notes

- **EntryCard appear:** Fade + slide up (200ms stagger per item).
- **Swipe to reveal actions:** Elastic overshoot (300ms).
- **FAB press:** Scale down to 0.95, then back (150ms).
- **Modal sheet:** Slide up with spring curve (400ms).

---

## 5. Feeding Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "Feeding"           │
├─────────────────────────────────┤
│  TypeSelector (SegmentedButton) │  56px
│  [Breastmilk] [Formula] [Solid] │
├─────────────────────────────────┤
│                                 │
│  LogEntryForm (collapsible)     │
│  ┌─────────────────────────────┐│
│  │ AmountInput                  ││
│  │ "120" ml / oz               ││
│  │                             ││
│  │ DurationInput (breastmilk)   ││
│  │ "15" min                    ││
│  │                             ││
│  │ DateTimePicker              ││
│  │                             ││
│  │ TextField (notes)           ││
│  │                             ││
│  │ [Save Entry]                ││
│  └─────────────────────────────┘│
│                                 │
├─────────────────────────────────┤
│  "Today"                        │  SectionHeader
│  ┌─────────────────────────────┐│
│  │ FeedingEntryCard            ││
│  └─────────────────────────────┘│
│  ┌─────────────────────────────┐│
│  │ FeedingEntryCard            ││
│  └─────────────────────────────┘│
│  "Yesterday"                    │
│  ...                            │
└─────────────────────────────────┘
```

### Widget Hierarchy

```dart
Scaffold
├── appBar: AppBar ("Feeding")
│
├── body: Column
│   ├── SingleChildScrollView
│   │   ├── Padding
│   │   │   └── SegmentedButton<int>
│   │   │       ├── BreastmilkIcon + label
│   │   │       ├── FormulaIcon + label
│   │   │       └── SolidFoodIcon + label
│   │   │
│   │   ├── LogEntryForm (Card, margin: 16px)
│   │   │   ├── AmountInputField
│   │   │   │   └── Row: TextField + UnitDropdown (ml/oz)
│   │   │   ├── DurationInputField (visible if breastmilk)
│   │   │   │   └── Row: TextField + "min" label
│   │   │   ├── DateTimePickerRow
│   │   │   ├── TextField (notes, maxLines: 2)
│   │   │   └── ElevatedButton ("Save Entry")
│   │   │
│   │   └── HistorySection
│   │       └── GroupedListView
│   │           └── FeedingEntryCard
│   │               ├── FeedingTypeIcon
│   │               ├── Column (type, amount, notes)
│   │               ├── Text (time)
│   │               └── SyncStatusIndicator
│   │
│   └── BottomNavPlaceholder
│
└── fab: FloatingActionButton (quick add - pre-selects current type)
```

### State Management

```dart
final feedingTypeProvider = StateProvider<FeedingType>;  // breastmilk/formula/solid
final feedLogsProvider = StateNotifierProvider.family<FeedLogsNotifier, AsyncValue<List<FeedLog>>, String>(
  (ref, babyId) => FeedLogsNotifier(ref, babyId),
);

final groupedFeedLogsProvider = Provider<AsyncValue<Map<String, List<FeedLog>>>>((ref) {
  final logs = ref.watch(feedLogsProvider);
  return logs.map((data) => groupByDate(data));  // { "Today": [...], "Yesterday": [...] }
});
```

### Animation Notes

- **SegmentedButton selection:** Background slides to selected segment (200ms).
- **LogEntryForm collapse/expand:** AnimatedSize with clip (300ms).
- **Entry added to list:** Slide in from right + fade (250ms).
- **FAB:** Rotation on tap (45deg, 200ms).

---

## 6. Health Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "Health"            │
├─────────────────────────────────┤
│  DefaultTabController           │
│  [Vaccination] [Visits] [Other] │  TabBar
├─────────────────────────────────┤
│                                 │
│  TabView                        │
│  ┌─────────────────────────────┐│
│  │ HealthCategoryTab           ││
│  │                             ││
│  │ HealthRecordCard            ││
│  │ ┌─────┐                     ││
│  │ │ 📋  │ Title               ││
│  │ │icon │ Date               ││
│  │ └─────┘ Provider · Notes   ││
│  │            [📎 doc] [⚡ sync]││
│  │                             ││
│  │ ...                         ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
         │ FloatingActionButton
         └──────────────────────────┘
```

### Widget Hierarchy

```dart
Scaffold
├── appBar: AppBar ("Health")
│
├── body: Column
│   └── Expanded
│       └── DefaultTabController
│           └── TabBarView
│               ├── HealthTab (vaccination)
│               ├── HealthTab (visits)
│               └── HealthTab (other)
│                   │
│                   └── ListView.builder
│                       └── HealthRecordCard (Slidable)
│                           ├── Row
│                           │   ├── Container (category icon, 48x48)
│                           │   └── Expanded
│                           │       ├── Text (title)
│                           │       ├── Text (date, caption)
│                           │       ├── Text (provider, caption)
│                           │       ├── Row (sync indicator, doc attachment)
│                           │       └── Text (notes, 2 lines)
│                           └── AttachmentIndicator (if doc exists)
│
└── fab: FloatingActionButton
```

### State Management

```dart
final healthTabProvider = StateProvider<int>;  // 0=vaccination, 1=visits, 2=other
final healthRecordsProvider = StateNotifierProvider.family<HealthRecordsNotifier, AsyncValue<List<HealthRecord>>, String>(
  (ref, babyId) => HealthRecordsNotifier(ref, babyId),
);

final filteredHealthRecordsProvider = Provider<AsyncValue<List<HealthRecord>>>((ref) {
  final records = ref.watch(healthRecordsProvider);
  final tab = ref.watch(healthTabProvider);
  return records.map((data) => filterByCategory(data, tab));
});
```

### Animation Notes

- **Tab switch:** Crossfade (200ms) between tab content.
- **Card appear:** Staggered fade + slide up.
- **Attachment indicator:** Pulse animation when document is attached.

---

## 7. Journal Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "Journal"          │
├─────────────────────────────────┤
│  FilterChips (horizontal)      │  48px
│  [All] [Milestone] [Feeding]   │
│  [Health] [System]             │
├─────────────────────────────────┤
│                                 │
│  ListView.builder (unified)    │
│  ┌─────────────────────────────┐│
│  │ JournalEntryCard (typed)    ││
│  │ [icon] Title               ││
│  │       Date · Type tag       ││
│  │       Preview text          ││
│  │       [CoParentApproval]    ││
│  └─────────────────────────────┘│
│                                 │
│  ... chronological ...         │
│                                 │
└─────────────────────────────────┘
```

### Widget Hierarchy

```dart
Scaffold
├── appBar: AppBar ("Journal")
│
├── body: Column
│   ├── FilterChipsRow (SingleChildScrollView)
│   │   └── Row
│   │       └── FilterChip (selected/unselected)
│   │           ├── FilterChip ("All")
│   │           ├── FilterChip ("Milestones")
│   │           ├── FilterChip ("Feeding")
│   │           ├── FilterChip ("Health")
│   │           └── FilterChip ("System")
│   │
│   └── Expanded
│       └── ListView.builder
│           └── JournalEntryCard
│               ├── Row
│               │   ├── EntryTypeIcon (milestone/feeding/health/system)
│               │   └── Expanded
│               │       ├── Text (title)
│               │       ├── Text (date, caption)
│               │       ├── Row (type tag chip)
│               │       └── CoParentApprovalBanner (if pending)
│               └── SyncStatusIndicator
│
└── // No FAB - journal is read-only unified view
```

### State Management

```dart
final journalFilterProvider = StateProvider<JournalFilter>;  // all/milestone/feeding/health/system
final journalEntriesProvider = FutureProvider.family<List<JournalEntry>, String>(
  (ref, babyId) => ref.read(journalRepositoryProvider).getJournalEntries(babyId),
);

final filteredJournalProvider = Provider<AsyncValue<List<JournalEntry>>>((ref) {
  final entries = ref.watch(journalEntriesProvider);
  final filter = ref.watch(journalFilterProvider);
  return entries.map((data) => filterByType(data, filter));
});
```

### Animation Notes

- **FilterChip selection:** Check icon scales in (150ms).
- **CoParentApprovalBanner:** Slide down from card top (300ms ease-out).
- **Card appear:** Standard staggered list animation.

---

## 8. Onboarding Flow

### Screen 1: Welcome

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│         🎀 BabyMon Logo         │  120x120
│                                 │
│     "Welcome to BabyMon"        │  H1, centered
│     "Your smart parenting       │
│      companion"                 │  Body, centered
│                                 │
│                                 │
│   ┌─────────────────────────┐  │
│   │   Get Started           │  │  ElevatedButton, primary
│   └─────────────────────────┘  │
│                                 │
│     Already have an account?    │
│     [Sign In]                   │  TextButton
│                                 │
└─────────────────────────────────┘
```

### Screen 2: Sign Up / Sign In (Tabbed)

```
┌─────────────────────────────────┐
│  TopAppBar (transparent)        │
├─────────────────────────────────┤
│                                 │
│  DefaultTabController           │
│  [Sign Up] [Sign In]            │  TabBar
│                                 │
│  ┌─────────────────────────────┐│
│  │ SignUpTab                   ││
│  │   EmailTextField            ││
│  │   PasswordTextField         ││
│  │   ConfirmPasswordTextField  ││
│  │   Checkbox ("I agree...")   ││
│  │   [Create Account]          ││
│  │                             ││
│  │  ─────── or ───────         ││
│  │  [Continue with Google]     ││
│  └─────────────────────────────┘│
│                                 │
│  ┌─────────────────────────────┐│
│  │ SignInTab                   ││
│  │   EmailTextField            ││
│  │   PasswordTextField         ││
│  │   [Forgot Password?]        ││
│  │   [Sign In]                 ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

### Screen 3: Create BabyMon

```
┌─────────────────────────────────┐
│  TopAppBar (back arrow)         │
│  "Create BabyMon"              │
├─────────────────────────────────┤
│  StepIndicator (3 dots)         │
├─────────────────────────────────┤
│                                 │
│  Step 1: Stage Picker          │
│  ┌─────┐ ┌─────┐ ┌─────┐       │
│  │ 💡  │ │ 👶  │ │ 🌟  │       │
│  │Idea │ │Con- │ │Born │       │
│  │     │ │ceived│ │     │       │
│  └─────┘ └─────┘ └─────┘       │
│                                 │
│  Step 2: Date Input            │
│  ┌─────────────────────────┐   │
│  │ "Baby's ${stage} date"   │   │
│  │  [📅 Select Date]        │   │
│  │  Calculated: "Due: ..."   │   │
│  └─────────────────────────┘   │
│                                 │
│  Step 3: Gender + Name         │
│  ┌─────────────────────────┐   │
│  │ GenderSelector           │   │
│  │ [Girl] [Boy] [Other]     │   │
│  │                          │   │
│  │ NameTextField (optional) │   │
│  └─────────────────────────┘   │
│                                 │
│   [Back]        [Continue]     │
│                                 │
└─────────────────────────────────┘
```

### State Management

```dart
final onboardingStateProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>;

class OnboardingState {
  final int currentStep;  // 0-3
  final StageOption stage;  // idea/conceived/born
  final DateTime? dueDate;
  final DateTime? birthDate;
  final Gender? gender;
  final String? name;
  final AuthStatus authStatus;
}
```

### Animation Notes

- **Welcome screen:** Logo scales in with bounce (600ms). Background has subtle floating shapes animation.
- **Step transitions:** Horizontal slide with fade (400ms ease-in-out).
- **Stage card selection:** Scale up + glow border animation (200ms).
- **Continue button:** Shimmer effect while loading.

---

## 9. Settings Screen

### Layout Structure

```
┌─────────────────────────────────┐
│  TopAppBar: "Settings"          │
├─────────────────────────────────┤
│                                 │
│  ProfileSection                 │
│  ┌─────────────────────────────┐│
│  │ BabyMonAvatar (large, 80px) ││
│  │ Baby name                   ││
│  │ Stage · Age                 ││
│  │ [Edit Profile Button]       ││
│  └─────────────────────────────┘│
│                                 │
│  SubscriptionCard               │
│  ┌─────────────────────────────┐│
│  │ "BabyMon Premium"            ││
│  │ "14 days remaining"          ││
│  │ [Upgrade / Renew]           ││
│  └─────────────────────────────┘│
│                                 │
│  SettingsListTile              │
│  [👤] Profile           [→]     │
│  [🔔] Notifications     [→]     │
│  [📤] Export Data       [→]    │
│  [🔗] Linked Accounts   [→]    │
│  [ℹ️] About             [→]    │
│                                 │
│  DangerZone                     │
│  ┌─────────────────────────────┐│
│  │ [Delete All Data]           ││
│  │ [Delete Account]            ││
│  └─────────────────────────────┘│
│                                 │
└─────────────────────────────────┘
```

### Widget Hierarchy

```dart
Scaffold
├── appBar: AppBar ("Settings")
│
├── body: ListView
│   ├── ProfileSection (Card)
│   │   ├── BabyMonAvatar (large, with stage ring)
│   │   ├── Column (name, stage/age)
│   │   └── TextButton ("Edit")
│   │
│   ├── SubscriptionCard (tier info, trial countdown)
│   │
│   ├── ListView (settings groups)
│   │   └── SettingsListTile
│   │       ├── leading: Icon
│   │       ├── title: Text
│   │       └── trailing: Icon / Switch
│   │
│   └── DangerZone (Card, red tinted)
│       ├── OutlinedButton ("Delete Data")
│       └── OutlinedButton ("Delete Account", red)
│
└── // No FAB
```

### State Management

```dart
final settingsProvider = FutureProvider<Settings>;
final subscriptionProvider = FutureProvider<Subscription>;
final linkedAccountsProvider = FutureProvider<List<LinkedAccount>>;
```

---

## 10. Widget Library

### BabyMonAvatar

```dart
class BabyMonAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final BabyStage stage;
  final double size;  // default: 48px
  final bool showStageRing;
}
```

**Visual:**
- Circle avatar with image or initials
- Stage ring: colored border matching stage (Idea=purple, Conceived=coral, Born=mint)
- Size variants: small (32px), medium (48px), large (80px), xlarge (120px)

**States:**
- Default: avatar with stage ring
- Loading: shimmer placeholder
- Empty: initials on colored background

---

### XpProgressBar

```dart
class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final int level;
  final bool showLabel;  // default: true
  final double height;  // default: 12px
}
```

**Visual:**
- Rounded container (height: 12px, radius: 6px)
- Gradient fill from primary to secondary
- Background: light gray (#E0E0E0)
- Level label above: "Level N"
- XP label below: "X / Y XP"

**States:**
- Default: animated fill
- Animating: smooth width transition (800ms ease-out)
- Maxed out: full bar with sparkle animation before leveling up

---

### BadgeCard

```dart
class BadgeCard extends StatelessWidget {
  final Badge badge;
  final BadgeCardVariant variant;  // small / medium / large
}
```

**Visual:**
- Card with rounded corners (16px)
- Badge icon (emoji or custom asset)
- Title text
- Unlock date (unlocked) or "???" (locked)
- Glow effect for recently unlocked

**States:**
- **Unlocked:** Full color, title visible, date shown
- **Locked:** Grayscale, blurred icon, "???" text, padlock overlay
- **Newly Unlocked:** Radial burst animation, scale bounce

---

### EntryCard (Base)

```dart
class EntryCard extends StatelessWidget {
  final EntryType type;  // milestone / feeding / health
  final String title;
  final String? subtitle;
  final String? notes;
  final DateTime date;
  final String? imageUrl;
  final bool isPendingSync;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
}
```

**Visual:**
- White Card with elevation 1, radius 16px
- Leading: type-specific icon or image thumbnail (80x80)
- Title (semibold, 16sp)
- Date (caption, 14sp, secondary color)
- Notes preview (2 lines max, body text)
- Trailing: SyncStatusIndicator

**States:**
- Default: standard appearance
- Syncing: SyncStatusIndicator animating
- Pending sync: orange dot indicator
- Error: red border, retry option

---

### StageChip

```dart
class StageChip extends StatelessWidget {
  final BabyStage stage;
  final bool selected;
  final VoidCallback? onTap;
}
```

**Visual:**
- Pill shape (border-radius: 12px)
- Stage emoji + label
- Background: primary (selected) or surface (unselected)
- Text: white (selected) or charcoal (unselected)

**States:**
- Selected: filled primary, white text
- Unselected: outlined, charcoal text
- Disabled: 50% opacity

---

### ActionButton (FAB variants)

```dart
class ActionButton extends StatelessWidget {
  final ActionButtonVariant variant;  // primary / secondary / mini
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool loading;
}
```

**Visual:**
- **Primary FAB:** 56px circle, primary gradient, white icon
- **Secondary FAB:** 48px circle, white bg, primary icon
- **Mini FAB:** 40px circle, secondary color, white icon
- Label variants: icon only OR icon + label below

**States:**
- Default: standard appearance
- Pressed: scale 0.95 (150ms)
- Loading: CircularProgressIndicator replaces icon
- Disabled: 50% opacity

---

### SyncStatusIndicator

```dart
class SyncStatusIndicator extends StatelessWidget {
  final SyncStatus status;  // synced / pending / error
}
```

**Visual:**
- Small icon (16px) with optional label
- **Synced:** Mint check icon
- **Pending:** Orange rotating arrows
- **Error:** Red exclamation

**States:**
- Synced: static check
- Pending: rotation animation (continuous)
- Error: static with tooltip on hover/longpress

---

## 11. Navigation Structure

```
BottomNavigationBar (5 tabs)
├── Dashboard (index 0)
│   └── /dashboard
├── Milestones (index 1)
│   ├── /milestones (list)
│   └── /milestones/create (modal sheet)
├── Feeding (index 2)
│   ├── /feeding (list + form)
│   └── /feeding/:id (detail, if needed)
├── Health (index 3)
│   ├── /health (tabs)
│   └── /health/create (modal sheet)
└── Journal (index 4)
    └── /journal (unified feed)

Secondary Routes:
├── /settings
├── /settings/profile
├── /settings/subscription
├── /settings/export
├── /onboarding (Welcome, SignUp, CreateBabyMon — initial flow)
└── /baby-switcher (modal)
```

---

## 12. Animation Summary

| Element | Animation | Duration | Curve |
|---------|-----------|----------|-------|
| Page transition | Slide + Fade | 400ms | easeInOut |
| Modal sheet | Slide up | 400ms | spring |
| Card appear | Fade + slide up | 200ms | easeOut |
| Badge unlock | Scale bounce + burst | 500ms | bounceOut |
| XP bar fill | Width tween | 800ms | easeOut |
| FAB press | Scale 0.95 | 150ms | easeInOut |
| Tab switch | Crossfade | 200ms | linear |
| Filter chip | Scale check | 150ms | easeOut |
| Stage ring pulse | Scale 1→1.05→1 | 1500ms | easeInOut (loop) |
| Sync spinner | Rotation | 1000ms | linear (loop) |

---

## 13. Responsive Considerations

- **Phone (375-428px):** Standard layout, 16px horizontal padding
- **Tablet (768px+):** Two-column layout for lists, side-by-side form + preview
- **Safe area:** Respected on all devices (notch, home indicator)
- **Bottom nav:** 80px including home indicator clearance

---

*End of Design Specification*
