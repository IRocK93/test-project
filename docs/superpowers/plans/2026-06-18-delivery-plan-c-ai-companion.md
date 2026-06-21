# Delivery Plan C: AI Companion — Content Seed + Safety

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make the AI_COMPANION tier deliver functional value by seeding content tables and adding minimum safety guardrails. Fix the placeholder SHA-256, remove the mock engine default fallback, and add an output safety classifier.

**Architecture:** Seed ExpertAdviceCard, RoutineTemplate, MilestoneExpectation tables for newborn stage (0-4 weeks) as minimum viable content. Add a rule-based safety classifier that runs on model output before display. Replace mock engine default with explicit error state.

**Tech Stack:** Prisma, NestJS, Flutter/Dart, llamadart

**Related Reports:** S11 (AI-C01 through AI-C04, AI-H01 through AI-H06)

---

## Phase C-1: Seed Newborn Content

### Task C-1: Ensure companion seed runs in main seed pipeline

**Files:**
- Modify: `apps/api/package.json`
- Modify: `apps/api/prisma/seed.ts`

- [ ] **Step 1: Fix duplicate seed:companion script key**

In `package.json`, delete the duplicate `"seed:companion"` line. There should be exactly one.

- [ ] **Step 2: Import and call companion seed from main seed.ts**

At the end of `seed.ts`, add:
```typescript
import { seedCompanion } from './seed-companion';

// After the main seed:
await seedCompanion();
```

This ensures `npx prisma db seed` (which the CI calls) seeds companion content too.

- [ ] **Step 3: Verify seed runs end-to-end**

```bash
cd apps/api && npx prisma db seed
```

Expected: Seed runs without errors. Both main and companion content seeded.

- [ ] **Step 4: Verify content is queryable**

```bash
curl http://localhost:3000/api/stage-content/baby-mon/{test-babymon-id}/advice
```

Expected: Returns advice cards for the baby's stage.

- [ ] **Step 5: Commit**

```bash
git add apps/api/prisma/ apps/api/package.json
git commit -m "fix(companion): integrate companion seed into main seed pipeline"
```

---

## Phase C-2: Fix Model Integrity

### Task C-2: Set real SHA-256 hash in model manifest

**Files:**
- Modify: `apps/api/src/companion/model-manifest.controller.ts`

- [ ] **Step 1: Generate real SHA-256 of the actual GGUF model file**

```bash
sha256sum path/to/gemma4-e2b-v1-q4km.gguf
```

- [ ] **Step 2: Replace the placeholder**

In `model-manifest.controller.ts`, find:
```typescript
sha256: 'placeholder-sha256-replace-with-real-hash',
```

Replace with the actual hash from Step 1.

- [ ] **Step 3: Commit**

```bash
git add apps/api/src/companion/model-manifest.controller.ts
git commit -m "fix(companion): set real SHA-256 hash for model integrity verification"
```

---

## Phase C-3: Remove Mock Engine Default

### Task C-3: No silent fallback — throw explicit error when model unavailable

**Files:**
- Modify: `apps/mobile/lib/features/companion/data/llm/llm_inference_service.dart`

- [ ] **Step 1: Remove MockLlmEngine default**

Find the constructor where `_engine = engine ?? MockLlmEngine()` (line ~58). Change to:
```dart
LlmInferenceService({LlmEngine? engine}) : _engine = engine {
  if (_engine == null) {
    throw StateError(
      'LlmInferenceService requires a configured LlmEngine. '
      'The AI model has not been loaded. Please download the model first.'
    );
  }
}
```

- [ ] **Step 2: Update the fallback response in llamadart_engine.dart**

When the engine is not loaded, instead of returning a canned response masquerading as AI, return a clear error:
```dart
if (_engine == null) {
  yield 'The AI model is not available. Please download the model from '
        'the Companion tab to enable AI-powered advice.';
  return;
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/mobile/lib/features/companion/data/llm/
git commit -m "fix(companion): remove silent mock engine fallback; throw explicit errors"
```

---

## Phase C-4: Add Output Safety Classifier

### Task C-4: Rule-based safety filter on model outputs

**Files:**
- Create: `apps/mobile/lib/features/companion/data/llm/safety_classifier.dart`
- Modify: `apps/mobile/lib/features/companion/data/llm/llm_inference_service.dart`

- [ ] **Step 1: Create safety classifier**

```dart
class SafetyClassifier {
  static const _emergencyPatterns = [
    'seizure', 'not breathing', 'blue', 'unresponsive',
    'choking', 'bleeding', 'passed out', 'fell and',
    'swallowed poison', 'allergic reaction', 'anaphylaxis',
    'difficulty breathing', 'turning blue',
  ];

  static const _dangerousDrugPatterns = [
    'aspirin', 'ibuprofen dosage', 'acetaminophen dosage',
    'give them', 'take this', 'dose of',
  ];

  static const _antiVaccinePatterns = [
    'vaccines cause', 'vaccine injury', 'no vaccines',
    'anti vax', 'anti-vax',
  ];

  static SafetyResult check(String response) {
    final lower = response.toLowerCase();

    for (final pattern in _emergencyPatterns) {
      if (lower.contains(pattern)) {
        return SafetyResult(
          flagged: true,
          category: 'emergency',
          warning: '⚠️ If this is a medical emergency, stop using this app '
                   'and call 911 or your local emergency number immediately.',
        );
      }
    }

    for (final pattern in _dangerousDrugPatterns) {
      if (lower.contains(pattern)) {
        return SafetyResult(
          flagged: true,
          category: 'medication',
          warning: '⚠️ The AI cannot provide medication dosage advice. '
                   'Always consult your pediatrician before giving any medication.',
        );
      }
    }

    for (final pattern in _antiVaccinePatterns) {
      if (lower.contains(pattern)) {
        return SafetyResult(
          flagged: true,
          category: 'anti_vaccine',
          warning: '⚠️ Content about vaccine safety may not be accurate. '
                   'Vaccines are safe and effective. Consult your pediatrician.',
        );
      }
    }

    return SafetyResult(flagged: false, category: 'safe', warning: null);
  }
}

class SafetyResult {
  final bool flagged;
  final String category;
  final String? warning;

  SafetyResult({required this.flagged, required this.category, this.warning});
}
```

- [ ] **Step 2: Integrate safety classifier into inference service**

In `llm_inference_service.dart`, wrap the model output:
```dart
import 'safety_classifier.dart';

// In the ask() method, after receiving the full response:
final safetyResult = SafetyClassifier.check(fullResponse);
if (safetyResult.flagged) {
  yield '\n\n${safetyResult.warning}';
}
```

- [ ] **Step 3: Commit**

```bash
git add apps/mobile/lib/features/companion/data/llm/
git commit -m "feat(companion): add rule-based safety classifier on AI outputs"
```

---

**Estimated time:** 2-3 days (most time is seed content verification and model SHA-256 generation).
