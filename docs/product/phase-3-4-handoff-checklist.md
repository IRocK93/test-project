# Phase 3-4 Handoff Checklist — BabyMon AI Companion
**Last updated:** 2026-06-18  
**Status:** Phase 2 content ~50% complete, Phase 3 device code complete, Phase 4 pending external resources

---

## Phase 3 — On-Device AI Chat (Code Complete, Pending Verification)

### 3.1 ✅ Device Capability Check
- **File:** `apps/mobile/lib/features/companion/data/llm/device_capability_service.dart`
- **Status:** Implemented — checks 64-bit CPU, RAM ≥4GB, storage ≥2.5GB
- **Verification needed:** Test on physical devices across price tiers (iPhone SE, iPhone 12, iPhone 15 Pro; Pixel 6a, Galaxy S23, budget Android devices)

### 3.2 ✅ Content-Only Fallback
- **File:** `apps/mobile/lib/features/companion/data/llm/llm_inference_service.dart`
- **Status:** Implemented — `contentOnlyMode` flag returns keyword-matched expert cards
- **Verification needed:** Test chat flow on a device that fails the capability check

### 3.3 ✅ Model Update Mechanism
- **File:** `apps/mobile/lib/features/companion/data/llm/model_manager.dart`
- **Status:** Implemented — `checkForUpdate()`, `getLastKnownManifestVersion()`, update dialog in companion_tab
- **Verification needed:** Deploy a manifest with a newer version string and verify update prompt appears

### 3.4 ❌ Real-Device Performance Testing
**Target:** 5-15 tokens/second on iPhone 14+ / Pixel 7+

| Action Item | Owner | Priority |
|-------------|-------|----------|
| Build Flutter app in release mode with llamadart linked | Developer | P0 |
| Install on iPhone 14/15 (iOS) and Pixel 7/8 (Android) | QA | P0 |
| Run inference benchmark: 10 queries, measure time-to-first-token and tok/s | QA | P0 |
| Test on low-end device (iPhone SE 2020, Pixel 6a) to verify fallback triggers | QA | P0 |
| Record metrics and file performance bugs if below 5 tok/s | QA | P1 |

### 3.5 ❌ llamadart Native Binary Compilation Verification
| Action Item | Owner | Priority |
|-------------|-------|----------|
| Verify `llamadart` package compiles and links correctly in release mode (iOS + Android) | Developer | P0 |
| Verify GGUF model file is bundled correctly and accessible at runtime | Developer | P0 |
| Run the `llama.cpp` smoke test (load model, generate 1 token, unload) | Developer | P0 |
| Check for missing Metal/MetalKit/Accelerate framework linkages on iOS | Developer | P1 |
| Check for missing NDK/CMake configuration on Android | Developer | P1 |

### 3.6 ❌ Fallback for Unsupported/Low-RAM Devices
**Code complete.** Verification items:
| Action Item | Owner | Priority |
|-------------|-------|----------|
| Test on device with <4GB RAM — verify content-only mode activates automatically | QA | P0 |
| Test on device with <2.5GB free storage — verify storage warning appears | QA | P1 |
| Verify content-only chat produces helpful keyword-matched responses | QA | P0 |

---

## Phase 4 — Polish & Launch

### 4.1 ❌ Medical/Legal Review
**Requires:** Licensed pediatrician + healthcare attorney

| Action Item | Owner | Priority |
|-------------|-------|----------|
| Review all ~500 ExpertAdviceCard content entries for medical accuracy | Pediatrician | P0 |
| Review all milestone expectations and red flag text | Pediatrician | P0 |
| Review emergency keyword detection list for completeness | Pediatrician | P0 |
| Review medical disclaimer language in the app and medical_disclaimer_gate | Attorney | P0 |
| Review Terms & Conditions at `docs/legal/` | Attorney | P0 |
| Review AI/LLM disclaimer language | Attorney | P0 |
| Confirm HIPAA/COPPA/GDPR compliance for on-device data | Attorney | P0 |

### 4.2 ❌ Full Accessibility Audit
**Requires:** Screen reader testing + contrast ratio verification

| Action Item | Owner | Priority |
|-------------|-------|----------|
| Run all companion screens through TalkBack (Android) and VoiceOver (iOS) | QA | P0 |
| Verify all interactive elements have Semantics labels (bookmark, rating, expand/collapse, filter chips, chat input) | QA | P0 |
| Check contrast ratios for all text/background combinations in both light and dark modes | Designer/QA | P0 |
| Test minimum touch target size (44×44dp) on all interactive elements | QA | P1 |
| Test with dynamic text sizes (largest accessibility font) | QA | P1 |
| Run automated accessibility scanner (Android Accessibility Scanner, iOS Accessibility Inspector) | QA | P1 |

### 4.3 ❌ A/B Test Setup
| Action Item | Owner | Priority |
|-------------|-------|----------|
| Integrate A/B testing SDK (Firebase Remote Config, LaunchDarkly, or custom) | Developer | P2 |
| Design CORE vs AI_COMPANION onboarding experiment | Product | P2 |
| Track conversion rate from CORE → AI_COMPANION trial | Developer | P2 |
| Set up feature flags for gradual rollout of companion features | Developer | P2 |

### 4.4 ❌ Analytics Integration
| Action Item | Owner | Priority |
|-------------|-------|----------|
| Integrate analytics SDK (Firebase Analytics, Mixpanel, or Amplitude) | Developer | P2 |
| Track: advice card views by category, advice card bookmarks, advice card ratings, model download completion rate, model download time, chat sessions per user, chat messages per session, inference latency, content-only mode activation rate, routine step completion rate | Developer | P2 |
| Build analytics dashboard for KPIs | Developer/Data | P2 |

### 4.5 ❌ App Store Launch Prep
| Action Item | Owner | Priority |
|-------------|-------|----------|
| Create App Store screenshots featuring AI Companion UI (all device sizes) | Designer | P1 |
| Write App Store description emphasizing on-device privacy, expert-reviewed content, adaptive routines | Product/Marketing | P1 |
| Prepare privacy nutrition labels for App Store (no data collection — on-device LLM) | Developer | P1 |
| Create Google Play Store listing with feature graphic | Designer | P1 |
| Prepare launch blog post / press release | Marketing | P2 |
| Set up app rating/review prompt at appropriate milestone | Developer | P2 |
| Beta testing via TestFlight (iOS) and Google Play Internal Testing (Android) | Developer | P1 |

---

## Current Phase 2 Content Progress

| Deliverable | Target | Current | % |
|-------------|--------|---------|---|
| ExpertAdviceCards | ~500 | ~220 | 44% |
| RoutineTemplates | 13 | 13 | 100% |
| MilestoneExpectations | ~200 | ~160 | 80% |
| VaccinationSchedule | 12+ | 12 | 100% |
| ScreeningReminder | 9 | 9 | 100% |

*Note: Content counts are approximate pending the current agent generation batch.*

---

## Immediate Next Steps (Ranked by Priority)

1. **Apply agent-generated content** (advice cards + milestones) → re-run seed
2. **Build Flutter app in release mode** with llamadart linked → smoke test on physical device
3. **Schedule medical review** with qualified pediatrician (use docs/product/AI_COMPANION-vision-and-design.md as reference)
4. **Run accessibility scanner** on all companion screens
5. **Integrate analytics** SDK and wire up the 10+ tracked events listed above
6. **Prepare app store assets** (screenshots, descriptions, privacy labels)
