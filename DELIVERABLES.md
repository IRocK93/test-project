# BabyMon — Deliverable Audit

> **Current state tracker:** [`docs/review-v4/ROADMAP.md`](./docs/review-v4/ROADMAP.md) is the canonical record of every code-level fix across all 25 remediation sessions (June 4–June 23, 2026), covering 122 findings (118/122 addressed = 97%). This deliverable list was last refreshed before v4 was completed; for latest remediation status, see the v4 ROADMAP.

## Verified State: 2026-07-03

> The original "Verified State: 2026-06-18" snapshot below is preserved for historical reference. Refresh the per-phase tables with live metrics from the v4 ROADMAP when you re-audit.

---

## Phase 2: Content Generation

### ExpertAdviceCards — 422 total
| File | Cards | Stage Coverage |
|---|---|---|
| `apps/api/prisma/seed-companion.ts` | 113 | Original + Batch 2 (pregnancy, newborn, infant, toddler) |
| `apps/api/prisma/seed-companion-batch3-pregnancy.ts` | 43 | preg_week_1–40, born_week_4/6/12, born_week_0 (vitamin D) |
| `apps/api/prisma/seed-companion-batch3-infant.ts` | 113 | born_month_1–12 (~10/month) |
| `apps/api/prisma/seed-companion-batch3-toddler.ts` | 72 | born_month_13–24 (6/month) |

**Categories:** GROWTH_HEALTH, DEVELOPMENT, NUTRITION_FEEDING, SLEEP, PLAY_ACTIVITIES, PARENT_WELLBEING  
**Expert voices:** DR_VASQUEZ, MARIA_CHEN, BOTH  
**Medical review:** 7 fixes applied (teething fever, baby blues timeline, formula age cutoff, pregnancy dating, Hep B vaccine, vitamin D card, newborn weight loss context)

### MilestoneExpectations — 200 total
| File | Count |
|---|---|
| `apps/api/prisma/seed-companion.ts` | 160 |
| `apps/api/prisma/seed-more-milestones.ts` | 40 |

**Domains:** GROSS_MOTOR, FINE_MOTOR, LANGUAGE_COMMUNICATION, COGNITIVE, SOCIAL_EMOTIONAL  
**Coverage:** pregnancy weeks through 24 months

### RoutineTemplates — 13 total
Seeded within `seed-companion.ts`. Covers newborn, infant, toddler, pregnancy stages.

### DB Verification
```
Cards:      422
Milestones: 200
```

---

## Phase 3: Testing, Config, Accessibility, Medical

### Integration Tests
| File | Purpose |
|---|---|
| `apps/mobile/integration_test/flutter_test_config.dart` | Global test setup (binding + SharedPreferences mock) |
| `apps/mobile/integration_test/app_test.dart` | On-device flows: unauthenticated (splash→login→register→back) + authenticated (MainScreen nav tabs) |
| `apps/mobile/pubspec.yaml` | `integration_test` added to dev_dependencies |

### Test Mock Fixes — 6 files
Updated `AuthRepository.register` signature in:
- `test/auth_flow_integration_test.dart`
- `test/auth_screens_test.dart`
- `test/unit/auth_provider_test.dart`
- `test/unit/auth_repository_impl_test.dart`
- `test/widget/auth_form_validation_test.dart`
- `test/widget/auth_screens_unit_test.dart`

Added: `dateOfBirth`, `tosAccepted`, `privacyAccepted`, `consentToDataProcessing` params.

### Android Config
| File | Change |
|---|---|
| `android/app/src/main/AndroidManifest.xml` | Added INTERNET, CAMERA, POST_NOTIFICATIONS, VIBRATE, READ_MEDIA_IMAGES permissions |
| `android/app/src/main/res/xml/network_security_config.xml` | Created: cleartext for localhost/10.0.2.2, HTTPS for production |

### iOS Config
| File | Change |
|---|---|
| `ios/Runner/Info.plist` | CFBundleName → "BabyMon", added NSPhotoLibraryAddUsageDescription, NSPrivacyPolicyURL, ITSAppUsesNonExemptEncryption |
| `ios/Runner/PrivacyInfo.xcprivacy` | Created: required API reasons, tracking domains (empty), collected data types |

### Accessibility Fixes — 6 files
| File | Change |
|---|---|
| `lib/core/widgets/photo_grid.dart` | `semanticLabel` on CachedNetworkImage, `ExcludeSemantics` on error icons |
| `lib/core/widgets/photo_viewer.dart` | `ExcludeSemantics` on error icons |
| `lib/features/companion/.../chat_bubble.dart` | `ExcludeSemantics` on decorative star icon |
| `lib/core/widgets/settings_row.dart` | `ExcludeSemantics` on decorative leading icon |
| `lib/features/companion/.../medical_disclaimer_gate.dart` | `Semantics` labels on warning icon, checkbox, accept/decline buttons |
| `lib/features/navigation/.../main_screen.dart` | `Semantics(label: '$label tab', button: true, selected: ...)` on bottom nav |
| `lib/core/widgets/theme_text.dart` | System text scaler default for WCAG 1.4.4 |

### Medical Accuracy — 7 fixes applied
| Card | Fix |
|---|---|
| `born_month_7` "Those First Teeth" | Fever threshold harmonized to 100.4°F |
| `born_week_4` "The First Month" | Baby blues timeline corrected (onset 2–5 days, peak 3–5, resolve by 2 weeks) |
| `born_month_2` "Formula Preparation" | Age cutoff "2 months" → "3 months" (CDC) |
| `preg_week_1` "How Pregnancy Weeks Are Actually Counted" | Added ACOG early/full/late/postterm terminology |
| `born_week_6` + `born_month_2` vaccine cards | Added Hepatitis B second dose |
| `born_week_0` (new card) | Vitamin D 400 IU/day supplementation |
| `born_month_1` "Newborn Weight Gain" | 7% evaluation threshold with clinical context |

---

## Phase 4: Store Launch Readiness

### App Icons
| File | Purpose |
|---|---|
| `tool/generate_icons.dart` | Dart script generating PNGs at all Android/iOS sizes via `image` package. Run: `dart run tool/generate_icons.dart` |
| `android/.../mipmap-anydpi-v26/ic_launcher.xml` | Adaptive icon referencing foreground/background drawables |
| `android/.../drawable/ic_launcher_foreground.xml` | Vector: baby icon silhouette + heart accent |
| `android/.../drawable/ic_launcher_background.xml` | Vector: gradient base |
| `ios/.../Assets.xcassets/AppIcon.appiconset/Contents.json` | iOS asset catalog with all required sizes (20–1024px) |

### Keystore / Signing
| File | Purpose |
|---|---|
| `tool/generate_keystore.bat` | Windows batch script. Run: `tool\generate_keystore.bat` |
| `android/key.properties.template` | Template with placeholder values |
| `.gitignore` | Added: `*.keystore`, `key.properties`, `google-services.json`, `GoogleService-Info.plist` |

### Privacy Policy
| File | Purpose |
|---|---|
| `tool/privacy_policy.html` | 12-section HTML page (WCAG accessible, dark/light mode). Host at `https://babymon.app/privacy` |

### Store Listing
| File | Purpose |
|---|---|
| `tool/store_listing.md` | App name, descriptions (short + full), keywords, category, age rating, support contacts, screenshot guide |

### Splash Branding
| File | Purpose |
|---|---|
| `android/.../drawable/splash_logo.xml` | Vector: baby icon + heart on branded background |
| `android/.../drawable/launch_background.xml` | Updated to reference splash_logo (was commented out) |
| `android/.../drawable-v21/launch_background.xml` | Same for Android 5.0+ |

### Firebase
| File | Purpose |
|---|---|
| `tool/firebase_setup.md` | Step-by-step Firebase project setup instructions |

---

## Phase 5: Design UI/UX Maturity

### Router Transitions
| File | Change |
|---|---|
| `lib/core/router/app_router.dart` | Removed duplicate `/companion/:babyMonId` route. Added `CustomTransitionPage` slide+fade to all 18 routes. Uses `DesignTokens.durationPage` + `DesignTokens.curvePremium`. |

### Design Tokens Extended
| File | Tokens Added |
|---|---|
| `lib/core/theme/design_tokens.dart` | Font scale: `fontXs(10)` → `font5xl(64)` — 14 steps. Opacity scale: `opacityGhost(0.06)` → `opacityGlassElevated(0.90)` — 6 steps. |

### GlassSurface Widget
| File | Purpose |
|---|---|
| `lib/core/widgets/glass_surface.dart` | Reusable glassmorphism surface. `GlassSurface(...)` for single child, `GlassSurface.group(...)` for shared BackdropFilter across multiple children. |
| `lib/core/widgets/widgets.dart` | Barrel export added |

**Files refactored to use GlassSurface (6):**
- `dashboard_stats_row.dart` → `GlassSurface.group()` (4 stat cards, shared blur)
- `advice_feed_screen.dart` → `GlassSurface` (advice cards)
- `login_screen.dart` → `GlassSurface` (auth form card)
- `register_screen.dart` → `GlassSurface` (auth form card)
- `reset_password_screen.dart` → `GlassSurface` (auth form card)
- `verification_screen.dart` → `GlassSurface` (auth card)

### RepaintBoundary
| File | Change |
|---|---|
| `lib/core/widgets/animated_entry.dart` | `StaggeredFadeSlide` + `ScalePress` children wrapped |
| `lib/features/.../level_up_celebration.dart` | `_ParticleOverlay` AnimatedBuilder wrapped |

### Animation Duration Standardization — 7 files
`chat_input_bar.dart`, `monthly_ai_reminder.dart`, `thinking_indicator.dart`, `main_screen.dart`, `info_fab.dart`, `medical_disclaimer_gate.dart`, `level_up_celebration.dart`
— all migrated from `Duration(milliseconds: N)` to `DesignTokens.duration*`.

### Token Adoption Counts
| Token Type | Usages | Files |
|---|---|---|
| `DesignTokens.font*` | 154 | 17 |
| `DesignTokens.opacity*` | 54 | 18 |
| `DesignTokens.duration*` | 17 | 10 |
| `DesignTokens.space*` | ~470 | extensive |
| `Semantics()` accessibility | 45 | 23 |

### Design Documentation
| File | Purpose |
|---|---|
| `apps/mobile/DESIGN_PATTERNS.md` | Component catalog, layout patterns, animation guidelines, accessibility checklist, spacing/radius/opacity/font scales |

---

## Stream D: Features
**Bookmark/rate UI — fully implemented end-to-end** (no changes needed).
- Backend: controller endpoints, service methods, Prisma models, migration
- Flutter: repository, state management (optimistic + rollback), UI (bookmark toggle + thumbs up/down)

---

## Stream E: Tech Debt Fixes
| Fix | File |
|---|---|
| Error handling: try/catch + `extractErrorMessage` on all 9 methods | `companion_repository.dart` |
| Error handling: `e.toString()` → `extractErrorMessage(e)` | `advice_feed_provider.dart` |
| Error handling: removed double rethrow after error token yield | `llm_inference_service.dart` |
| Race condition: `loadCards().then((_) => loadBookmarks())` | `advice_feed_provider.dart` (constructor + refresh) |
| Pre-existing bug: `widget.newStage` → `widget.level` | `level_up_celebration.dart` |

---

## Pre-Existing Bugs Fixed During Verification
| Bug | File | Fix |
|---|---|---|
| `const Text('Phase ${widget.newStage}')` — non-const + undefined getter | `level_up_celebration.dart` | Removed `const`, changed `newStage` → `level` |

---

## Test Results (snapshot 2026-06-18 — superseded by v4)

```
Backend:  12/12 unit tests passing
Mobile:   462/462 passing (then ~52 added in v4 Session 24)
Seed:     422 cards, 200 milestones, 13 routines
```

> **For live test counts as of July 2026**, see [`docs/review-v4/ROADMAP.md`](./docs/review-v4/ROADMAP.md) Session 24 (Testing Gap Closure): +24 user-journey e2e tests, +15 feed-logs service specs, +13 growth-chart widget tests, for a net of ~104 new test cases since this snapshot.

---

## Remaining (External Resources)
| Item | Dependency |
|---|---|
| Run icon generator | `dart run tool/generate_icons.dart` (requires `dart pub add image`) |
| Generate release keystore | Run `tool\generate_keystore.bat` (requires JDK keytool) |
| Host privacy policy | Deploy `tool/privacy_policy.html` to babymon.app |
| Regenerate iOS Xcode project | `flutter create .` in `apps/mobile` (requires macOS + Xcode) |
| Firebase configuration | Create Firebase project, download config files |
| Device integration test execution | Requires Android emulator or iOS simulator |
