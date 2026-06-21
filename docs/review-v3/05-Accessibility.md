# Accessibility Audit Report

## Grade: C+

## Summary

BabyMon demonstrates strong foundational awareness of accessibility -- the codebase contains 60+ `Semantics()` widgets, a reusable confirmation dialog, ExcludeSemantics on decorative elements, reduced-motion support, and a beautifully Semantics-labeled medical disclaimer gate. However, several WCAG AA violations exist in color contrast, touch targets, and missing screen-reader infrastructure. For a parenting app where users may be sleep-deprived, operating one-handed at 3am, the colour contrast issues on critical interactive elements (primary buttons, FAB, error text) are the highest-severity concern.

## Findings

| # | WCAG Rule | Severity | File:Line | Finding | Fix |
|---|-----------|----------|-----------|---------|-----|
| 1 | **1.4.3 Contrast (Minimum)** | **HIGH** | `app_colors.dart:29` | Glass secondary (#FF7E67) on white text has contrast ~2.4:1, used as FAB background via `_fabTheme`. Fails both WCAG AA 4.5:1 text and 3:1 non-text. | Darken secondary to at least #E06A5C (or #C95A4E for 4.5:1) or use a dark foreground on the coral background. |
| 2 | **1.4.3 Contrast (Minimum)** | **HIGH** | `app_colors.dart:39` | Glass error (#E53935) on white has contrast ~4.2:1, failing WCAG AA 4.5:1 for normal text. Used for error text, form validation, and error borders. | Use #D32F2F or darker for error text. Consider two-tone: darker for text (#C62828), current for borders only. |
| 3 | **1.4.3 Contrast (Minimum)** | **MEDIUM** | `app_colors.dart:19` | Glass primary (#7C5CFC) on white has contrast ~4.4:1, borderline-failing WCAG AA 4.5:1 for normal body text. | For text-button and outlined-button uses, darken to #6A4DE0. |
| 4 | **1.4.11 Non-text Contrast** | **HIGH** | `app_theme.dart:130-132` | Glass light input border (#E0DDE8) on white fill has contrast ~1.3:1. Nearly invisible; fails WCAG 3:1 for UI component boundary. | Darken border to at least #9490A0 for 3:1 contrast. |
| 5 | **1.4.11 Non-text Contrast** | **MEDIUM** | `clay_colors.dart:61-62` | Clay divider (#E8E3DB) and border (#DDD7CF) on cream surfaces have very low contrast (~1.5:1). Fails 3:1 minimum. | Darken clay border to at least #B8AFA0. |
| 6 | **2.5.5 Target Size (AAA)** | **MEDIUM** | `theme_button.dart:348-349` | Icon-only ThemeButton uses `iconSize + 16` for dimensions. With default iconSize 24, touch target is 40x40dp -- below WCAG AAA 48x48dp. | Increase minimum to 48x48: `max(iconSize + 16, 48)`. |
| 7 | **2.5.5 Target Size (AAA)** | **MEDIUM** | `photo_viewer.dart:160-167` | Photo viewer close button is 40x40dp, below 48x48dp AAA minimum. | Increase to 48x48dp. |
| 8 | **2.1.1 Keyboard** | **HIGH** | Entire `lib/` | **No keyboard navigation infrastructure.** No `FocusTraversalGroup`, no `Shortcuts`/`Actions` widgets, no `onKeyEvent` handlers. Only 5 autofocus usages exist. | Add `FocusTraversalGroup` to screen scaffolds. Create and dispose `FocusNode` instances. Add visible focus indicators. |
| 9 | **1.3.1 Info and Relationships** | **MEDIUM** | Entire `lib/` | **No heading hierarchy.** Zero uses of `Semantics(header: true)` or `Semantics(headingLevel: ...)`. Screen readers cannot navigate by heading structure. | Mark screen titles, card titles, and section headers with `Semantics(header: true)`. |
| 10 | **4.1.3 Status Messages** | **HIGH** | Entire `lib/` | **No `SemanticsService.announce()` calls.** When BabyMon saves data, deletes a record, or completes an action, no announcement is made to screen readers. | Add `SemanticsService.announce()` after critical operations: "Growth record saved," "Feeding logged," "AI response ready." |
| 11 | **1.3.5 Identify Input Purpose** | **LOW** | `login_screen.dart:285-292` | No `autofillHints`. No `AutofillGroup` wrapping form groups. | Add `autofillHints: [AutofillHints.email]` to email fields, wrap forms in `AutofillGroup`. |
| 12 | **2.4.7 Focus Visible** | **HIGH** | `app_theme.dart:382` | Focus color is set but no screen creates or manages FocusNodes. Combined with absence of keyboard handling, focused elements may lack visible indication. | Ensure all focusable elements have visible focus indicators. Implement `FocusNode` lifecycle. |
| 13 | **1.4.1 Use of Color** | **LOW** | `login_screen.dart:324-331` | Error state shown only as red text. No icon or semantic indicator accompanies the error. | Add error icon alongside error text. |
| 14 | **1.4.4 Resize Text** | **LOW** | Multiple screens | Many screens use raw `Text()` widgets directly which rely on default Material scaling. Inconsistent approach may cause layout breakage at 200%. | Standardize all text through ThemeText or ensure raw Text widgets use `MediaQuery.textScalerOf(context)`. |
| 15 | **Parenting-specific: Dark mode** | **MEDIUM** | `app_colors.dart:106-109` | Dark surface elevated (#242430) has only ~1.5:1 contrast against dark surface (#1A1A22), making elevated cards nearly indistinguishable at night. | Increase dark surface elevated to #2E2E3C for visible depth differentiation. |
| 16 | **Parenting-specific: One-handed operation** | **MEDIUM** | Multiple screens | No reachability accommodations. Primary actions at bottom (good) but critical nav requires top-of-screen reach. | Ensure all primary actions are reachable within bottom 50% of screen. |

## Top 5 WCAG Violations

1. **Glass secondary (#FF7E67) fails WCAG AA contrast** -- FAB background with white icon unusable by low-vision users. Highest severity because FAB is the primary data-entry mechanism across 5+ screens.
2. **No keyboard navigation infrastructure** -- Complete absence of FocusNode management, FocusTraversalGroup, Shortcuts/Actions, or onKeyEvent. A keyboard-only user cannot meaningfully use the app.
3. **No status announcements for screen readers** -- Blind users receive no confirmation when critical parenting data is saved, deleted, or when AI produces a response.
4. **Glass error color (#E53935) fails WCAG AA** -- Error text across all screens fails 4.5:1. Sleep-deprived parents with visual fatigue may miss error states entirely.
5. **Input borders lack sufficient contrast** -- Form field boundaries nearly invisible at 1.3:1. Users in dark rooms at night cannot distinguish input fields.

## Top 3 Accessibility Wins

1. **Medical Disclaimer Gate** -- Exemplary. Every element labeled, checkbox with `checked` property, dynamic button labels, programmatic state communication. Model for the rest of the app.
2. **Extensive Semantics Coverage** -- 60+ `Semantics()` widgets. Buttons, tabs, FABs, form fields, chat input, badges, stat cards all labeled. `ExcludeSemantics` correctly wraps decorative icons.
3. **Reduced Motion Support** -- Respected in 4 animation systems. ThemeText respects system `TextScaler`. Confirmation dialogs reused consistently with clear language.

## Parent-Specific UX Concerns

- **Dark mode at 3am is adequate**: darkBackground (#0E0E12) and text (#F0F0F5) provide ~13:1 contrast, excellent for low-light use.
- **Touch targets for one-handed use**: ThemeButton defaults to 48px (passes AAA). Social login circles at 48x48 are good.
- **Confirmation on critical actions**: `ConfirmDeleteDialog` used consistently across 8+ data types with clear "this cannot be undone" messaging.
- **Biometric authentication**: Offered as alternative to password entry -- excellent for motor-impaired or sleep-deprived parents.

## Screen Reader Readiness

| Aspect | Status | Details |
|--------|--------|---------|
| Interactive element labels | Good | All buttons, tabs, FABs, and form controls labeled |
| Decorative element exclusion | Good | ExcludeSemantics used on decorative icons |
| Heading navigation | Missing | Zero `header: true` or `headingLevel` semantics |
| Dynamic announcements | Missing | No `SemanticsService.announce()` calls |
| Form error association | Partial | InputDecoration errors appear but not linked via `Semantics(error: true)` |
| Disabled state communication | Good | ThemeButton uses `Semantics(enabled: false)` when disabled |
| Selected state communication | Good | Bottom nav tabs use `Semantics(selected: isSelected)` |
| Autofill support | Missing | No `AutofillHints` or `AutofillGroup` on any form |
