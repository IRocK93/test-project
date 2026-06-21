# BabyMon Redesign Plan — Full Visual Overhaul

> **Status:** Plan ready for execution
> **Target:** Flutter mobile app (BabyMon — Smart Evolving Parenting Companion)
> **Scope:** Theme, navigation, auth, dashboard, all tab screens, animations, micro-interactions

---

## Diagnosis Summary

Based on audit of all 14 screens and core configuration:

| Issue | Severity | Files Affected |
|-------|----------|---------------|
| Two conflicting color palettes (`AppTheme` vs `AppColors`) | **Critical** | `app_theme.dart`, `app_colors.dart` |
| Default Material fonts (no custom typography) | **High** | `app_theme.dart` |
| 7 bottom nav items (exceeds Material guidelines) | **High** | `main_screen.dart` |
| Generic Material cards everywhere | **High** | Every screen |
| No scroll/entry animations | **High** | Every screen |
| Basic Material navigation drawer | **Medium** | `main_screen.dart` |
| Generic loading indicators (`CircularProgressIndicator`) | **Medium** | Every screen |
| Empty states are plain icon + text | **Medium** | Every list screen |
| Confusing dual provider layout (`presentation/providers/` + `features/*/providers/`) | **Low** | Multiple providers |

---

## Phase 1: Foundation — Theme & Design System

**Goal:** Establish a single, premium, cohesive design foundation that every screen inherits.

### 1.1 Unify Color Palette

**Current problem:** `AppTheme` defines `primary = #9C7CF4` (soft purple) but `AppColors` defines `primary = #6C5CE7` (indigo). Screens import from both files.

**Decision:** Use `AppColors` as the single source of truth since it has better naming and more variations. The existing `AppTheme` references should be updated to use `AppColors`.

**New palette direction** (premium, warm, parenting-focused):
```dart
// Primary — Warm violet (trustworthy, nurturing)
primary:        #7C5CFC
primaryLight:   #A29BFE
primaryDark:    #5A3FD4

// Secondary — Soft coral (warmth, energy)
secondary:      #FF7E67
secondaryLight: #FFAB91

// Accent — Calm teal (health, growth)
accent:         #4DD0C1

// Neutrals — Warm-toned grays
background:     #FCFAFA    // Warm white
surface:        #FFFFFF
surfaceLight:   #F8F6F3    // Warm light
textPrimary:    #1A1A2E
textSecondary:  #8D8D8D
textCaption:    #B0B0B0

// Status
success:        #00C853
warning:        #FFA726
error:          #E53935
```

**Actions:**
- Delete `AppTheme` color constants (keep only theme data constructors)
- Make `AppColors` the single import for all color references
- Update all screens currently using inline colors (e.g., `Colors.orange.shadeXXX`, `Colors.indigo`) to use `AppColors`

### 1.2 Add Custom Typography

**Current:** Default Material Design fonts (Roboto on Android, SF on iOS).

**New font pairing:**
- **Headings:** `Playfair Display` or `Satoshi` — elegant, premium serif/sans-serif for display text
- **Body:** `Inter` — highly readable, modern sans-serif for body text and UI
- **Numeric/Tabular:** Enable `font-variant-numeric: tabular-nums` for data displays

**Actions:**
- Add fonts to `pubspec.yaml` under `flutter > fonts`
- Define full `TextTheme` in `AppTheme` with:
  - `displayLarge/Small`: 36/28px, bold, custom font, negative tracking
  - `headlineLarge/Medium/Small`: 24/20/18px, semi-bold
  - `titleLarge/Medium/Small`: 16/14/13px, medium weight
  - `bodyLarge/Medium/Small`: 16/14/12px, regular weight
  - `labelLarge/Medium/Small`: 14/12/10px, uppercase tracking 0.1em for labels
- Apply `text-wrap: balance` equivalent for headings

### 1.3 Redesign Theme Data

**Current:** Basic Material 3 theme with minimal customization.

**New theme structure:**
```dart
class AppTheme {
  // Refined card theme
  static final cardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    shadowColor: AppColors.textPrimary.withOpacity(0.08),
    surfaceTintColor: Colors.transparent,
  );

  // Input decoration — premium, minimal
  static final inputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.textCaption.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: TextStyle(color: AppColors.textSecondary),
  );

  // Button theme — pill-shaped primary, outlined secondary
  static final elevatedButton = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      shadowColor: AppColors.primary.withOpacity(0.3),
    ),
  );

  // Bottom nav — compact, with indicator
  static final bottomNav = BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textCaption,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  );
}
```

### 1.4 Create Design Tokens

New file: `lib/core/theme/design_tokens.dart`

```dart
class DesignTokens {
  // Spacing scale
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 12;
  static const double spaceLG = 16;
  static const double spaceXL = 24;
  static const double space2XL = 32;
  static const double space3XL = 48;

  // Border radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 999;

  // Duration
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 600);

  // Elevation shadows
  static List<BoxShadow> shadowSM = [...];
  static List<BoxShadow> shadowMD = [...];
  static List<BoxShadow> shadowLG = [...];
}
```

### 1.5 Build Premium Component Library

New directory: `lib/core/widgets/`

| Component | File | Description |
|-----------|------|-------------|
| `PremiumCard` | `premium_card.dart` | Glass-morphism card with tinted shadow, inner border, optional gradient |
| `PremiumAppBar` | `premium_app_bar.dart` | Floating island app bar with backdrop blur |
| `PremiumButton` | `premium_button.dart` | Pill-shaped, scale animation on press, icon support |
| `PremiumLoading` | `premium_loading.dart` | Skeleton shimmer + branded spinner |
| `PremiumEmptyState` | `premium_empty_state.dart` | Illustrated empty state with illustration, message, CTA |
| `PremiumBadge` | `premium_badge.dart` | Tier-colored badge chip with glow |
| `PremiumStatCard` | `premium_stat_card.dart` | Metric display card with icon |
| `PremiumSection` | `premium_section.dart` | Section header with title, subtitle, optional action |

---

## Phase 2: Navigation & App Shell

**Goal:** Clean up navigation architecture and make the app shell feel premium.

### 2.1 Reduce Bottom Nav to 5 Items

**Current:** 7 tabs (Dashboard, Milestones, Feeding, Health, Discover, Album, Journal)

**New:** 5 tabs
1. **Dashboard** (home)
2. **Milestones** (star)
3. **Feeding** (restaurant)
4. **Health** (favorite)
5. **More** (apps/dots) → opens a grid menu with Album, Journal, Sleep, Discover

**Alternative:** If all 7 are essential, use a scrollable bottom nav or a compact grid layout.

**Actions:**
- Rewrite `_MainScreenState` bottom nav to 5 items
- Create a `MoreMenuScreen` or bottom sheet for overflow items
- Remove the Discover placeholder from bottom nav

### 2.2 Redesign AppBar

**Current:** Standard Material AppBar with BabyMon selector dropdown + hamburger menu + notification bell + create button.

**New:**
- Floating pill-style AppBar (detached from top, `margin: EdgeInsets.only(top: 8)`)
- Backdrop blur effect (`backdrop-filter: blur(20px)`)
- Centered BabyMon selector as a compact badge (avatar + name)
- Right side: notification bell with badge count + create button as small icon
- Left side: hamburger or avatar button

### 2.3 Redesign Navigation Drawer

**Current:** Standard Material Drawer with `DrawerHeader` + `ListTile` items + logout.

**New:**
- Custom slide panel with elevated surface
- Profile section at top with avatar, name, email
- Sectioned navigation items with icons
- Quick stats or BabyMon summary card embedded
- Branded footer with app version

### 2.4 Replace Notification End Drawer

**Current:** "Coming Soon" placeholder.

**New:**
- Remove end drawer entirely for now
- Replace with a FAB menu or action chip on the dashboard
- When notifications are implemented, use a proper slide-in panel or a dedicated screen

### 2.5 Page Transition Animations

**Current:** Instant route changes via `GoRouter`.

**New:**
- Custom `CustomTransitionPage` for route transitions
- Slide-up + fade for forward navigation
- Slide-down + fade for back navigation
- Hero animations for shared elements (e.g., BabyMon avatar between AppBar and detail)
- Staggered list item animations on screen entry

---

## Phase 3: Splash & Auth Screens (4 screens)

**Goal:** Make the entry experience feel premium and build trust.

### 3.1 Splash Screen

**Current:** Basic `Icon(child_care)` + `Text('BabyMon')` + `CircularProgressIndicator`.

**New:**
- Gradient background (primary → primaryDark)
- Animated logo: scale-up + fade-in over 1.2s
- Tagline fades in below with staggered delay
- A subtle animated indicator (pulsing dot or custom ring animation)
- Smooth transition to next screen (cross-fade, no abrupt push)

### 3.2 Login Screen

**Current:** Full-width form on plain background with stacked social buttons.

**New:**
- Card-centered layout on gradient/pattern background
- Premium card with slight elevation and rounded corners
- App icon at top with drop shadow
- "Welcome Back" heading with subtle animation
- Email/password fields with proper focus transitions
- "Forgot Password?" as inline text link (not bottom sheet by default)
- Social buttons reimagined as compact icon buttons in a row (Google, Apple, Facebook)
- Biometric button as a prominent icon if available
- "Don't have an account? Sign up" at bottom
- Gentle fade-in animation for the entire card

### 3.3 Register Screen

**Current:** Matches login layout.

**New:**
- Mirror login card design for consistency
- Password strength indicator (visual bar below password field)
- Terms of service checkbox at bottom
- Smooth transition to verification screen on success

### 3.4 Reset Password & Verification Screens

**Current:** Basic forms.

**New:**
- Match auth card layout
- Verification screen: animated envelope icon, "Check your email" message, resend button with countdown timer
- Reset password: success animation, clear instructions

---

## Phase 4: Dashboard (Highest Impact — 7 sections)

**Goal:** The dashboard is the most important screen. Make it feel like a premium parenting companion.

### 4.1 Stage Card (Header)

**Current:** Gradient card with emoji, name, stage, age, level badge, share/edit buttons, expandable details.

**New:**
- Large, premium hero card with:
  - Glass-morphism background with subtle noise/grain overlay
  - Animated emoji (scale bounce on load)
  - Baby name in large custom font with letter-spacing
  - Stage label with custom chip
  - Age displayed with animated counter
  - Level badge redesigned as a circular XP ring with level number inside
  - Share/edit as compact icon buttons with proper hit areas
  - Expandable details section with animated height transition
  - Tinted shadow matching gender color

### 4.2 Quick Stats Row

**Current:** 4 border-only containers with emoji + text.

**New:**
- 4 compact stat cards with:
  - Colored icon backgrounds (milestone=amber, feeding=orange, health=green, sleep=indigo)
  - Animated number counters (count up on load)
  - Smaller, cleaner label text
  - Subtle tap ripple for navigation to respective tab
  - Card shadow for depth

### 4.3 XP Bar

**Current:** Basic `LinearProgressIndicator` with "XP" label.

**New:**
- Rounded track with gradient fill (amber → orange)
- Glowing effect at the leading edge of the fill
- Level badge at the end
- XP count displayed prominently
- Small milestone markers along the bar

### 4.4 Growth Card

**Current:** Basic row with icon, label, value, chevron.

**New:**
- Mini chart preview showing last 5 growth data points as a sparkline
- Current value with trend indicator (up/down arrow)
- Tap navigates to full Growth Chart screen
- Same card styling as other dashboard cards

### 4.5 Badges Section

**Current:** `ExpansionTile` with nested category tiles and circle chips.

**New:**
- Collapsible section with animated expand/collapse
- Category tabs or horizontal scrollable category pills
- Badge grid: proper card-based badges with tier colors, unlock animation
- Progress indicator per category
- Locked badges shown with overlay, not just grayed out
- Tap shows a proper badge detail bottom sheet

### 4.6 Stage Content Card

**Current:** Basic container with `primaryContainer` background.

**New:**
- Card with icon header and subtle background decoration
- Content shown with proper typography hierarchy
- Tips displayed as numbered or bulleted list with custom styling
- Scroll animation for tip items

### 4.7 Quick Actions (FAB + Bottom Sheet)

**Current:** Basic `FloatingActionButton` + `showModalBottomSheet` with `ListTile`s.

**New:**
- Floating action button with expandable speed dial (3 options: Log Feeding, Add Milestone, Add Health Record)
- Each option has icon + color + label
- Smooth expand/collapse animation
- Or: persistent mini action bar below the dashboard tiles

---

## Phase 5: Feature Tab Screens (7 screens)

**Goal:** Consistent premium feel across all feature screens.

### 5.1 Milestones Screen

**Current:** `ListView` of `Card` with `ListTile`.

**New:**
- Timeline-style layout: vertical line on the left with dots at each milestone
- Cards are achievement-style with colored left border
- Date shown as a badge above each entry, not just in subtitle text
- Each card has: title (bold), date chip, notes (truncated with expand), category icon
- Staggered slide-in animation on load
- Pull-to-refresh with custom indicator
- Empty state: illustrated achievement trophy image + encouraging message

### 5.2 Feeding Screen

**Current:** Stacked bar chart + `ListView` of `Card` with `Dismissible`.

**New:**
- Chart: proper stacked bar chart with legends, gradient colors, tap for day detail
- Each feeding log card shows: time (prominent), type icon with color, amount with unit, notes preview
- Group logs by date with sticky date headers
- Swipe to delete with premium delete animation
- Add form: redesigned bottom sheet with segmented type selector, wheel picker for amount, time preset buttons (15m ago, 30m ago, etc.)
- Empty state: bottle illustration

### 5.3 Health Screen

**Current:** Growth chart nav + Sleep nav + filter chips + list + expandable FAB.

**New:**
- Navigation cards (Growth Chart, Sleep) redesigned as premium action cards with illustrations
- Filter chips as compact visual tabs with icons
- Record cards styled by category (green for growth, orange for events, red for allergies)
- Expandable FAB replaced with a proper speed dial with labels
- Allergy events shown with severity color indicators
- Empty state: medical bag illustration

### 5.4 Growth Chart Screen

**Current:** `fl_chart` with zoom controls and record list.

**New:**
- Minor polish: gradient fill below line, better grid line styling, improved tooltip design
- Metric selector as pill-shaped segmented control
- Add record form matches health screen design

### 5.5 Sleep Screen

**Current:** Date navigator + summary card + 24h timeline chart + list.

**New:**
- Summary cards redesigned with proper icons and colors
- Timeline chart: better time axis labels, more distinguishable sleep quality colors, tap for details
- Sleeker add form with quick preset buttons (Nap, Night), wheel time picker
- Date navigator with smooth slide animation

### 5.6 Album Screen

**Current:** Photo grid grouped by month.

**New:**
- Staggered photo grid entry animation
- Section header styling with custom divider
- Upload FAB: camera + gallery as mini speed dial
- Full-screen viewer with swipe to dismiss
- Empty state: camera illustration with gradient

### 5.7 Journal Screen

**Current:** Filter chips + proposals section + card list.

**New:**
- Timeline feed with visual distinction between entry types (milestone, feeding, health, system)
- Each entry type has a unique card design (not just different icon color)
- Proposals shown as action cards with accept/decline buttons
- Filter tabs as visual chips with count badges
- Empty state: book/journal illustration

### 5.8 Discover Screen

**Current:** Placeholder "Coming Soon".

**New:**
- Either remove and integrate into More menu
- Or: well-designed Coming Soon screen with illustration, email notify option, and feature preview cards

---

## Phase 6: Settings & Secondary Screens (4 screens)

**Goal:** Polish remaining screens to match the new design system.

### 6.1 Settings Screen

**Current:** `ListView` of `Card` + `ListTile` with divider.

**New:**
- Grouped sections with visual headers (Profile, Preferences, Data, Account)
- Profile card with avatar, name, email, edit button
- Settings items as properly styled navigation tiles with trailing icons
- Measurement unit selector as styled toggle
- Danger zone (delete, logout) with red tint and warning icons

### 6.2 Subscription Screen

**Current:** Plan comparison cards + upgrade button.

**New:**
- Current plan banner redesigned as premium highlight card
- Plan comparison cards with better visual hierarchy and feature lists
- Animated checkmark for included features
- Upgrade button with gradient and shine animation
- Trial countdown as a prominent indicator

### 6.3 Partners Screen

**Current:** Card list with status badges.

**New:**
- Partner cards with larger avatars and role indicators
- Status badges with proper color coding
- Invite dialog as styled bottom sheet
- Empty state: group illustration with "Invite a co-parent" message

### 6.4 Create BabyMon Screen

**Current:** Long scrolling form with all fields visible.

**New:**
- Multi-step wizard with 3-4 steps
- Step indicator at top (animated dots or numbered circles)
- Step 1: Name + Gender
- Step 2: Stage + Date
- Step 3: Traits + Special Move
- Step 4: Review + Create
- Smooth slide transitions between steps
- Form validation per step

---

## Phase 7: Animations & Micro-interactions

**Goal:** Make the app feel alive and premium through thoughtful motion design.

### 7.1 Scroll Animations

- **Dashboard tiles:** Staggered fade-in + slide-up on first load (uses `ScrollVisibilityDetector` or `AnimationController`)
- **List items:** Each card fades in and slides up with incremental delay
- **Section headers:** Slide in from left

### 7.2 Button & Interaction Physics

- **All buttons:** `Transform.scale(0.96)` on press, spring-back on release
- **Cards:** Subtle elevation increase on hover/tap
- **Switches/Toggles:** Smooth slide animation
- **Segmented controls:** Animated indicator sliding between options

### 7.3 Pull-to-Refresh

- Custom refresh indicator with app branding (BabyMon icon or logo animation)
- Color-matched to primary palette

### 7.4 Tab Switching

- Replace `IndexedStack` with `AnimatedSwitcher` or `PageView` for smooth horizontal transitions
- Or use cross-fade animation between tabs

### 7.5 State Transitions

- **Loading → Content:** Skeleton shimmer placeholder → content with fade
- **Empty → Populated:** Items animate in when data arrives
- **Error → Retry:** Error state with animated illustration, retry button bounces on tap

### 7.6 Micro-interactions

- **Level up:** Full-screen celebration overlay with particles
- **Badge unlock:** Brief pop-up badge animation
- **XP gain:** Animated XP counter incrementing
- **Milestone creation:** Brief confetti or sparkle effect
- **Haptic feedback:** On important actions (create, delete, unlock)

---

## File Inventory — Files to Create

| File | Purpose |
|------|---------|
| `lib/core/theme/design_tokens.dart` | Spacing, radius, duration, shadow constants |
| `lib/core/theme/app_colors.dart` | **Already exists** — will be updated as single source of truth |
| `lib/core/theme/app_theme.dart` | **Already exists** — will be rewritten with new theme data |
| `lib/core/widgets/premium_card.dart` | Reusable premium card widget |
| `lib/core/widgets/premium_app_bar.dart` | Floating island app bar |
| `lib/core/widgets/premium_button.dart` | Styled button with animations |
| `lib/core/widgets/premium_loading.dart` | Skeleton + branded spinner |
| `lib/core/widgets/premium_empty_state.dart` | Illustrated empty state |
| `lib/core/widgets/premium_badge.dart` | Badge chip widget |
| `lib/core/widgets/premium_stat_card.dart` | Stat card widget |
| `lib/core/widgets/premium_section.dart` | Section header widget |
| `lib/core/animation/page_transitions.dart` | Custom route transitions |
| `lib/core/animation/scroll_animations.dart` | Scroll-based animation helpers |

## File Inventory — Files to Modify

| File | Changes |
|------|---------|
| `lib/core/theme/app_theme.dart` | Complete rewrite with new colors, fonts, theme data |
| `lib/core/constants/app_colors.dart` | Add new colors, remove duplicates |
| `pubspec.yaml` | Add custom font assets |
| `lib/app.dart` | Update theme reference |
| `lib/main.dart` | Add provider for animation state |
| `lib/presentation/screens/main/main_screen.dart` | New bottom nav, app bar, drawer |
| `lib/presentation/screens/splash/splash_screen.dart` | Full rewrite |
| `lib/presentation/screens/auth/login_screen.dart` | Full rewrite |
| `lib/presentation/screens/auth/register_screen.dart` | Full rewrite |
| `lib/presentation/screens/auth/reset_password_screen.dart` | Redesign |
| `lib/presentation/screens/onboarding/create_baby_mon_screen.dart` | Multi-step wizard |
| `lib/presentation/screens/main/dashboard/dashboard_screen.dart` | Full rewrite |
| `lib/presentation/screens/main/feeding/feeding_screen.dart` | Redesign |
| `lib/presentation/screens/main/health/health_screen.dart` | Redesign |
| `lib/presentation/screens/main/milestones/milestones_screen.dart` | Timeline redesign |
| `lib/presentation/screens/main/journal/journal_screen.dart` | Timeline redesign |
| `lib/presentation/screens/main/sleep/sleep_screen.dart` | Redesign |
| `lib/presentation/screens/main/album/album_screen.dart` | Redesign |
| `lib/presentation/screens/main/health/growth_chart_screen.dart` | Polish |
| `lib/presentation/screens/main/settings/settings_screen.dart` | Redesign |
| `lib/presentation/screens/main/settings/subscription_screen.dart` | Redesign |
| `lib/presentation/screens/main/settings/partners_screen.dart` | Redesign |

---

## Execution Order

```
Phase 1: Foundation (Theme + Design System)
    │
    ▼
Phase 2: Navigation & App Shell (MainScreen, AppBar, Drawer, Nav)
    │
    ▼
Phase 3: Auth Screens (Splash, Login, Register, Reset, Verify)
    │
    ▼
Phase 4: Dashboard (Most visible — highest impact)
    │
    ▼
Phase 5: Feature Tabs (Milestones, Feeding, Health, Sleep, Album, Journal)
    │
    ▼
Phase 6: Settings (Settings, Subscription, Partners, Create BabyMon)
    │
    ▼
Phase 7: Animations & Micro-interactions (Polish pass across all screens)
```

Each phase should be executed as a separate implementation step with review and testing between phases.

---

## Design Principles

1. **Warm, not cold** — Parenting is emotional. Colors should be warm, not sterile blue/gray corporate UI.
2. **Premium, not flashy** — Subtle shadows, refined typography, intentional whitespace. No gradients for the sake of gradients.
3. **Consistent, not repetitive** — Every card follows the same design language, but content sections have distinct visual identities.
4. **Delightful, not distracting** — Animations should feel natural and purposeful, not gimmicky.
5. **Functional first** — Redesign must not break existing functionality. API contracts stay the same.

---

## References

- **Design audit checklist:** See `redesign-existing-projects` skill
- **Premium design patterns:** See `high-end-visual-design` skill
- **Current app theme:** `lib/core/theme/app_theme.dart`
- **Current color palette:** `lib/core/constants/app_colors.dart`
