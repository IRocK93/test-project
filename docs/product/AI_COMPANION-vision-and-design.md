# AI_COMPANION — Product Vision & Technical Design

**Date:** 2026-06-18
**Status:** Blueprint — ready for implementation
**Target:** BabyMon Premium Tier (`AI_COMPANION`)

---

## 1. Product Vision

### 1.1 Elevator Pitch

**AI_COMPANION transforms BabyMon from a tracking app into an intelligent parenting coach.** It delivers personalized, evidence-based expert guidance, adaptive daily routines, and developmental insights that evolve with the child — from the moment parents start thinking about having a baby, through pregnancy, and every week of the first two years of life.

### 1.2 Core Value Proposition

| For Parents | For BabyMon (Business) |
|---|---|
| "What should I expect this week?" — Age-appropriate developmental previews | Differentiates CORE (free tracking) from AI_COMPANION (paid coaching) |
| "Is this normal?" — Evidence-based reassurance with red-flag indicators | Drives subscription conversion with clear value |
| "What should we do today?" — Adaptive daily routine templates | Increases retention through daily engagement |
| "What does the expert say?" — Credible advice from pediatric and childcare specialists | Positions BabyMon as a trusted authority, not just a tracker |
| "I'm overwhelmed — help me." — Non-judgmental, warm, practical support | Creates emotional connection and brand loyalty |

### 1.3 Guiding Principles

1. **Evidence-based, never alarmist** — Every piece of advice is grounded in WHO, CDC, AAP guidelines. Red flags are clearly marked as "call your doctor" — never "this is definitely wrong."
2. **Adaptive, not generic** — Content changes with the baby's exact age, stage, recent tracked data (sleep patterns, growth, feeding), and parent preferences.
3. **Two voices, one trusted source** — Content is attributed to Dr. Elena Vasquez (pediatrician — clinical, reassuring, evidence-focused) and Maria Chen (child development specialist — warm, practical, lived-experience-focused). Parents can filter by voice or topic.
4. **Works offline** — Daily briefs, routines, milestone checklists, and advice cards are database content (no API call required). Only the "Ask the Companion" chat requires connectivity.
5. **Privacy-first** — No child data leaves the app for AI processing without explicit opt-in. Content-driven features work entirely on-device.

---

## 2. Age Stage Framework

The child's journey is divided into precise stages, each with unique content, routines, and guidance. The app auto-calculates the current stage from the BabyMon profile.

### 2.1 Stage Map

```
IDEA ───────────► CONCEIVED ──────────────► BORN ─────────────────► 2 YEARS
 │                  │                          │
 │  "Thinking about │  Pregnancy weeks 1-40    │  Age in weeks (0-12)
 │   having a baby" │  (preg_week_1 → 40)      │  then months (3-24)
 │                  │                          │  (born_week_0 → born_month_24)
```

### 2.2 Detailed Stage Breakdown

| Stage | Age Range | Stage Keys | Key Themes |
|---|---|---|---|
| **Pre-conception** | Before pregnancy | `idea` | Fertility awareness, preconception health, financial planning, relationship readiness |
| **1st Trimester** | Weeks 1-13 | `preg_week_1` → `preg_week_13` | Early symptoms, prenatal care, genetic screening, nutrition for two, emotional adjustment |
| **2nd Trimester** | Weeks 14-27 | `preg_week_14` → `preg_week_27` | Anatomy scan, feeling movement, birth plan prep, nursery setup, baby shower |
| **3rd Trimester** | Weeks 28-40 | `preg_week_28` → `preg_week_40` | Birth preparation, labor signs, breastfeeding classes, hospital bag, postpartum plan |
| **Newborn** | 0-4 weeks | `born_week_0` → `born_week_4` | Feeding establishment, sleep survival, jaundice, umbilical cord care, postpartum recovery, baby blues |
| **Early Infant** | 1-3 months | `born_week_4` → `born_week_12` | Social smiling, tummy time, sleep consolidation begins, first vaccines, returning to work |
| **Mid Infant** | 3-6 months | `born_month_3` → `born_month_6` | Rolling over, laughing, starting solids, sleep training readiness, teething begins |
| **Late Infant** | 6-9 months | `born_month_6` → `born_month_9` | Sitting independently, crawling, stranger anxiety, finger foods, sleep regression |
| **Early Toddler** | 9-12 months | `born_month_9` → `born_month_12` | Cruising, first words, self-feeding, separation anxiety, transitioning from bottles |
| **Young Toddler** | 12-18 months | `born_month_12` → `born_month_18` | Walking, vocabulary explosion, tantrums, weaning, one-nap transition |
| **Older Toddler** | 18-24 months | `born_month_18` → `born_month_24` | Running, two-word phrases, potty training readiness, imaginary play, big emotions |

### 2.3 Stage Key Calculation

The existing `stage-content.service.ts` already implements `getForBabyMon()` which calculates `stageKey` from the baby's birth/conception date. This logic is extended to support all stages above using the same key format (`preg_week_N`, `born_week_N`, `born_month_N`).

---

## 3. Content Pillars

Every stage delivers content across 6 pillars. Each pillar has a primary expert voice.

| Pillar | Primary Expert | Description |
|---|---|---|
| **🩺 Growth & Health** | Dr. Vasquez | Growth percentiles (WHO/CDC), vital signs by age, vaccination schedule, common illnesses, when to call the doctor |
| **🧠 Development** | Dr. Vasquez (milestones) + Maria Chen (activities) | Expected milestones (gross motor, fine motor, language, cognitive, social-emotional), developmental screening schedule, red flags |
| **🍼 Nutrition & Feeding** | Maria Chen (practice) + Dr. Vasquez (science) | Breastfeeding and formula guidance, introducing solids (BLW & purees), meal plans, allergen introduction, portion guides |
| **😴 Sleep** | Maria Chen | Wake windows, nap schedules, sleep environment setup, gentle coaching methods, regression survival guides |
| **🎮 Play & Activities** | Maria Chen | Age-appropriate play ideas, sensory activities, language-rich interactions, gross motor support, toy recommendations (budget-friendly) |
| **💚 Parent Well-being** | Both | Postpartum recovery, partner involvement, mental health screening (Edinburgh scale), returning to work, self-care, relationship maintenance |

---

## 4. Content Delivery Formats

### 4.1 Daily Brief
Each day, the parent sees a personalized snapshot:
- **Baby's Current Age** — "Maya is 6 months, 2 weeks old"
- **Stage Summary** — "Late Infant: Sitting, Starting Solids, First Teeth"
- **This Week's Focus** — One highlighted milestone or topic (e.g., "Starting solid foods this week? Here's your guide")
- **Tip of the Day** — Rotating expert tip from any pillar
- **Growth Check Reminder** — "Time to measure weight and length this week"
- **Routine Preview** — Today's sample schedule

### 4.2 Adaptive Daily Routine
A visual timeline showing:
- Wake window start
- Feed times (with amounts/types by age)
- Nap times (with duration goals)
- Activity blocks
- Bedtime ritual components

The routine adapts based on:
- Baby's age (wake windows lengthen, naps consolidate)
- Baby's tracked sleep data (adjusts if baby consistently wakes earlier)
- Parent's input (early riser? late sleeper? flexible?)

### 4.3 Milestone Tracker
Interactive checklist per age range:
- "Expected now" — milestones most babies this age are achieving
- "Emerging" — milestones that may appear soon
- "Celebrate!" — parent marks achieved milestones → triggers XP + badge
- "Talk to your doctor if…" — red-flag indicators with clear action guidance

### 4.4 Expert Advice Cards
Scrollable, filterable feed of advice cards:
- Categorized by pillar (Health, Development, Nutrition, Sleep, Play, Wellbeing)
- Attributed to Dr. Vasquez or Maria Chen
- Age-tagged (relevant for age range X–Y)
- Priority-ordered by relevance to current stage
- Bookmarkable for later reference
- "Was this helpful?" feedback

### 4.5 Ask the Companion (AI Chat)
Chat-style interface for parent questions:
- Parent types a question (e.g., "My 4-month-old is suddenly waking every 2 hours — is this the sleep regression?")
- System retrieves: baby's profile (age, recent sleep data, stage), relevant stage content, relevant advice cards
- LLM generates a personalized, warm, evidence-based response grounded in the retrieved content
- Response is attributed: "Based on Dr. Vasquez's sleep guidance for 4-month-olds…"
- Parent can rate the response (thumbs up/down)
- Flagged if question suggests a medical emergency → immediate "Please contact your pediatrician"

### 4.6 Screening & Checkup Reminders
Timed push notifications:
- Vaccination due dates
- Well-child visit schedule
- Developmental screening windows (ASQ-3, M-CHAT-R at 18-24mo)
- Postpartum depression screening (Edinburgh at 6 weeks postpartum)
- Growth measurement reminders

---

## 5. Technical Architecture

### 5.1 Data Model (Prisma Schema Additions)

#### 5.1.1 New Enum Types

```prisma
enum AdviceCategory {
  GROWTH_HEALTH
  DEVELOPMENT
  NUTRITION_FEEDING
  SLEEP
  PLAY_ACTIVITIES
  PARENT_WELLBEING
}

enum ExpertVoice {
  DR_VASQUEZ
  MARIA_CHEN
  BOTH
}

enum MilestoneDomain {
  GROSS_MOTOR
  FINE_MOTOR
  LANGUAGE_COMMUNICATION
  COGNITIVE
  SOCIAL_EMOTIONAL
}

enum MilestoneStatus {
  EXPECTED
  EMERGING
  ACHIEVED
  NEEDS_EVALUATION
}
```

#### 5.1.2 ExpertAdviceCard

```prisma
model ExpertAdviceCard {
  id            String          @id @default(uuid())
  stageKey      String
  category      AdviceCategory
  title         String
  summary       String          // Short preview for feed cards
  content       String          // Full advice text (can contain {name} substitution)
  expertVoice   ExpertVoice
  priority      Int             @default(0)  // Higher = shown first
  ageRangeMinDays  Int?         // Minimum age in days for relevance
  ageRangeMaxDays  Int?         // Maximum age in days for relevance
  tags          String[]        // Searchable tags
  isRedFlag     Boolean         @default(false) // "Call doctor" advice
  createdAt     DateTime        @default(now())
  updatedAt     DateTime        @updatedAt

  @@index([stageKey, category])
  @@index([category])
  @@index([expertVoice])
}
```

#### 5.1.3 RoutineTemplate

```prisma
model RoutineTemplate {
  id            String   @id @default(uuid())
  stageKey      String   @unique
  title         String
  description   String
  wakeWindowMins    Int     // Typical wake window in minutes
  napCount          Int     // Number of naps
  totalNapHours     Float   // Total nap duration goal
  nightSleepHours   Float   // Night sleep duration goal
  feedFrequency     String  // e.g. "Every 2-3 hours", "3 meals + 2 snacks"
  sampleSchedule    Json    // Array of time blocks: [{time, activity, durationMins, notes}]
  bedtimeRitual     String[] // Steps in bedtime routine
  flexible          Boolean @default(true)
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt
}
```

#### 5.1.4 MilestoneExpectation

```prisma
model MilestoneExpectation {
  id            String           @id @default(uuid())
  stageKey      String
  domain        MilestoneDomain
  title         String
  description   String
  status        MilestoneStatus  @default(EXPECTED)
  ageRangeMinDays   Int?
  ageRangeMaxDays   Int?
  redFlagText       String?      // "Talk to your doctor if not by X months"
  activityPrompt    String?      // "Try this: ..." activity suggestion
  xpReward          Int          @default(10)
  createdAt     DateTime         @default(now())
  updatedAt     DateTime         @updatedAt

  @@index([stageKey, domain])
  @@index([domain])
}
```

#### 5.1.5 VaccinationSchedule

```prisma
model VaccinationSchedule {
  id            String   @id @default(uuid())
  vaccineName   String
  diseasePrevents String  // What it protects against
  dueAgeMonths  Float    // Age in months when due
  dueAgeWeeks   Int?     // For newborn vaccines
  doseNumber    Int      // Which dose in the series
  notes         String?
  createdAt     DateTime @default(now())

  @@index([dueAgeMonths])
}
```

#### 5.1.6 ScreeningReminder

```prisma
model ScreeningReminder {
  id              String   @id @default(uuid())
  title           String
  description     String
  targetAgeDays   Int      // When to prompt
  screeningTool   String   // e.g. "ASQ-3", "M-CHAT-R", "Edinburgh"
  targetAudience  String   // "baby" or "parent"
  createdAt       DateTime @default(now())

  @@index([targetAgeDays])
}
```

#### 5.1.7 UserRoutine (Personalized Instance)

```prisma
model UserRoutine {
  id              String   @id @default(uuid())
  babyMonId       String
  routineDate     DateTime // Which day this routine is for
  templateId      String
  customizations  Json     // Overrides: {wakeTime, bedtime, skipNap2, etc.}
  completedSteps  String[] // Which steps were marked done
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  babyMon  BabyMon         @relation(fields: [babyMonId], references: [id], onDelete: Cascade)
  template RoutineTemplate @relation(fields: [templateId], references: [id])

  @@unique([babyMonId, routineDate])
  @@index([babyMonId])
}
```

#### 5.1.8 BabyMilestone (Tracked Achievement)

```prisma
model BabyMilestone {
  id              String   @id @default(uuid())
  babyMonId       String
  expectationId   String
  achievedAt      DateTime @default(now())
  notes           String?
  createdAt       DateTime @default(now())

  babyMon     BabyMon              @relation(fields: [babyMonId], references: [id], onDelete: Cascade)
  expectation MilestoneExpectation @relation(fields: [expectationId], references: [id])

  @@unique([babyMonId, expectationId])
  @@index([babyMonId])
}
```

### 5.2 API Endpoints

All endpoints require JWT auth. All scoped to `subscription tier = AI_COMPANION`.

```
GET    /stage-content/:babyMonId/daily-brief
  → Returns: { age, stage, stageName, focusOfWeek, tipOfDay, growthCheckDue, routinePreview }

GET    /stage-content/:babyMonId/routine
  → Returns: { today, template, timeBlocks[], bedtimeRitual[] }

PUT    /stage-content/:babyMonId/routine
  → Body: { wakeTime, bedtime, skipNaps[], notes }
  → Saves personalization for today

POST   /stage-content/:babyMonId/routine/:stepId/complete
  → Marks a routine step as done

GET    /stage-content/:babyMonId/milestones/expected
  → Returns: { items: MilestoneExpectation[] grouped by domain }
  → Query: ?status=EXPECTED|EMERGING|ACHIEVED

POST   /stage-content/:babyMonId/milestones/:expectationId/achieve
  → Marks milestone as achieved → awards XP + triggers badge check

GET    /stage-content/:babyMonId/advice
  → Returns: { items: ExpertAdviceCard[], total }
  → Query: ?category=HEALTH&expertVoice=DR_VASQUEZ&skip=0&take=10

POST   /stage-content/:babyMonId/advice/:id/bookmark
  → Toggles bookmark for the advice card

GET    /stage-content/:babyMonId/vaccinations
  → Returns: { upcoming: VaccinationSchedule[], completed: [] }

GET    /stage-content/:babyMonId/screenings
  → Returns: { due: ScreeningReminder[], upcoming: [] }

POST   /stage-content/:babyMonId/ask
  → Body: { question: string, conversationHistory?: {role, content}[] }
  → Returns: { answer: string, sources: ExpertAdviceCard[], expertVoice: ExpertVoice, disclaimer: string }
  → This is the AI/LLM endpoint — see §5.4
```

### 5.3 Flutter Screen Architecture

New feature: `lib/features/companion/`

```
companion/
├── data/
│   └── companion_repository.dart         # Abstracts API calls
├── domain/
│   └── companion_state.dart              # State models
├── presentation/
│   ├── providers/
│   │   └── companion_provider.dart       # Riverpod providers
│   └── screens/
│       ├── companion_tab.dart            # Main tab entry point
│       ├── daily_brief_screen.dart       # Today's snapshot
│       ├── routine_screen.dart           # Visual timeline
│       ├── milestone_tracker_screen.dart # Interactive checklist
│       ├── advice_feed_screen.dart       # Filterable card feed
│       └── ask_companion_screen.dart     # AI chat interface
└── widgets/
    ├── expert_advice_card.dart           # Reusable advice card
    ├── routine_timeline.dart             # Visual timeline widget
    ├── milestone_checklist.dart          # Checklist group
    └── companion_badge.dart              # AI_COMPANION tier badge
```

#### Screen Wireframe Descriptions

**Daily Brief Screen:**
```
┌────────────────────────────┐
│  🌟 Maya is 6m 2w old     │  ← Baby avatar + age
│  Late Infant Stage         │
├────────────────────────────┤
│  THIS WEEK'S FOCUS         │
│  ┌──────────────────────┐  │
│  │ 🥄 Starting Solids   │  │  ← Highlighted milestone
│  │ Your complete guide   │  │
│  │ to baby's first foods │  │
│  └──────────────────────┘  │
├────────────────────────────┤
│  💡 TIP OF THE DAY         │
│  "When introducing peanut │  ← Rotating expert tip
│   butter, thin it with     │
│   breastmilk or formula"   │
│   — Maria Chen             │
├────────────────────────────┤
│  📏 GROWTH CHECK DUE       │
│  Last measurement: 2w ago  │  ← Nudge to measure
├────────────────────────────┤
│  ⏰ TODAY'S ROUTINE        │
│  ┌──────────────────────┐  │
│  │ 7:00  Wake & Feed    │  │
│  │ 9:00  Nap (1.5hrs)   │  │
│  │ 10:30 Play & Tummy   │  │
│  │ 12:00 Feed & Solids  │  │
│  │  ...more...          │  │  ← Condensed timeline
│  │ 19:00 Bedtime Ritual │  │
│  └──────────────────────┘  │
│  [View Full Routine]       │
└────────────────────────────┘
```

**Ask the Companion Screen:**
```
┌────────────────────────────┐
│  💬 Ask the Companion      │
│  (Dr. Vasquez & Maria Chen)│
├────────────────────────────┤
│  ┌──────────────────────┐  │
│  │ Parent: "My 4-month- │  │
│  │ old is waking every  │  │
│  │ 2 hours — is this    │  │
│  │ the 4-month sleep    │  │
│  │ regression?"         │  │
│  └──────────────────────┘  │
│  ┌──────────────────────┐  │
│  │ 🩺 Dr. Vasquez:      │  │
│  │ The 4-month sleep    │  │
│  │ regression is a real │  │
│  │ developmental shift. │  │
│  │ At this age, babies  │  │
│  │ transition from      │  │
│  │ newborn sleep cycles │  │
│  │ to more adult-like   │  │
│  │ patterns...          │  │
│  │                      │  │
│  │ 📎 Sources: "Sleep   │  │
│  │ Regression Survival" │  │
│  │ "4-Month Wake Windows│  │
│  └──────────────────────┘  │
│ ─────────────────────────  │
│ [Type your question...] ✈  │
└────────────────────────────┘
│ ⚠️ For medical emergencies, │
│ contact your pediatrician   │
└────────────────────────────┘
```

### 5.4 AI Integration Strategy (Hybrid Model)

#### Layer 1: Content-Driven (Offline-First)
- Daily briefs, routines, milestone checklists, advice cards, vaccination schedules, screening reminders → all database content
- `StageContent` seeding populates these from the content framework
- Works entirely offline — no API call needed
- Updated via content releases (new `prisma/seed.ts` migrations)

#### Layer 2: On-Device LLM Chat (Offline-First, Privacy-Preserving)
- The "Ask the Companion" chat feature runs a small open-source LLM **entirely on the device**
- **No data leaves the phone** — all inference happens locally, ensuring complete privacy of children's health data
- **No server costs** — zero per-query API fees, sustainable at any user scale

**Model Selection (updated June 2026):**

| Candidate | Q4_K_M Size | Strengths | Considerations |
|---|---|---|---|
| **SmolLM2 360M** ★ | **~271 MB** | **Default choice.** 0.36B params, standard `llama` architecture, Apache 2.0, ARM-optimized quants, instant download | Small model — best paired with RAG for factual accuracy |
| **SmolLM3 3B** | **~1.92 GB** | **Premium upgrade.** 3B params, 128K context, dual-mode reasoning (think/no_think), Apache 2.0, fits 4 GB phones | 10 min download on Wi-Fi |
| Gemma 4 E2B | ~3.11 GB | 2.3B effective, text+image+audio multimodal, 128K context, Apache 2.0 | Too large for 4 GB phones (OOM risk); relegated to future when 6 GB+ is baseline |
| Qwen 2.5 1.5B | ~0.9 GB | Lightweight, Apache 2.0, decent quality | Good alternative if SmolLM2 is insufficient |

**Recommended default:** SmolLM2 360M Instruct (Q4_K_M, 271 MB) — guaranteed to run on every 4 GB Android phone, instant download, clean license. Backed by RAG over 500 curated parenting cards for factual accuracy. SmolLM3 3B available as optional premium download for deeper reasoning.

**Runtime Engine:**
- **llamadart** v0.6.11 — Flutter/Dart wrapper around llama.cpp, zero-config Pure Native Assets
- GGUF format (Q4_K_M quantization) for efficient on-device inference
- GPU acceleration via Metal (iOS) and Vulkan (Android)
- Target inference speed: 10-25 tokens/second on modern phones (iPhone 14+/Pixel 7+)
- Supports Gemma 4 architecture as of v0.6.10

**System Prompt Design (optimized for small models):**
```
You are the BabyMon AI Companion. You are warm, knowledgeable, and evidence-based.

TODAY'S CONTEXT:
- Child: {name}, {age}-month-old {gender}
- Stage: {stageName}
- Recent: {sleepSummary}, {feedingSummary}, {growthSummary}

RELEVANT EXPERT CONTENT:
{retrievedAdviceCards — top 3-5 most relevant}

RULES:
- Be concise (2-3 short paragraphs)
- Attribute facts to Dr. Vasquez (medical) or Maria Chen (practical parenting)
- If asked about a medical emergency: "Please contact your pediatrician immediately. This is not something I can advise on."
- If unsure: "I'm not certain about that. Here's what I do know..."
- Never invent medical facts. Stick to the content provided above.
```
- **Retrieval (on-device):** Simple keyword + stage-key matching against the local `ExpertAdviceCard` SQLite database (via the existing `shared_preferences` or a small local index). No embedding API needed — keyword search over ~500 cards is fast enough.
- **Conversation history:** Last 3 exchanges kept in memory for context. Older history summarized into a 1-sentence topic.
- **No rate limiting needed** — on-device inference has no marginal cost. Users can ask unlimited questions.
- **Model update cadence:** The app checks for updated GGUF model files on app startup (monthly). Users can opt to stay on their current model.

#### Layer 3: Content Personalization (No AI Needed)
- `{name}` substitution in all content
- Stage-appropriate content filtering by calculated age
- Routine adaptation based on tracked sleep/wake patterns (simple heuristic, not ML)
- Growth percentile context from WHO/CDC lookup tables (static data, no AI)

### 5.5 Gating Mechanism

All AI_COMPANION endpoints check subscription tier:

```typescript
// In companion.controller.ts or a guard
@UseGuards(JwtAuthGuard, TierGuard)
@Tier('AI_COMPANION')  // Custom decorator
```

The `TierGuard` calls `SubscriptionsService.checkWriteAccess()` which already exists and checks:
- Is trial active? (within 14 days)
- Is subscription active? (isActive = true, currentPeriod not expired)
- Is tier AI_COMPANION?

If trial expired and not subscribed → returns 402 Payment Required with upgrade prompt.

---

## 6. Content Seeding Strategy

### 6.1 Seed Data Volume Estimate

| Model | Records | Details |
|---|---|---|
| `ExpertAdviceCard` | ~500 | ~10 cards per pillar per stage × 6 pillars × ~8 stage groups |
| `RoutineTemplate` | ~13 | One per stage key group |
| `MilestoneExpectation` | ~200 | 5 domains × ~4 milestones each × ~10 age ranges |
| `VaccinationSchedule` | ~15 | Standard US schedule birth–24 months |
| `ScreeningReminder` | ~8 | ASQ-3 intervals + M-CHAT-R + Edinburgh + well-child visits |

### 6.2 Seeding Approach

1. Content authored in structured markdown files (`docs/product/content/`)
2. A seed script parses markdown → inserts into Prisma
3. Content versioned (migration number or content version field on `StageContent`)
4. Medical content reviewed by a licensed pediatrician before production use (legal disclaimer)

### 6.3 Content Freshness

- Expert advice cards: reviewed quarterly
- Vaccination schedules: updated when CDC schedule changes
- Milestone expectations: updated when CDC/WHO guidelines change (rare)
- Routine templates: reviewed quarterly based on user feedback

---

## 7. Implementation Roadmap

### Phase 1: Foundation (2-3 weeks)
**Deliverable:** AI_COMPANION tier delivers daily briefs, routines, and expert advice cards — all content-driven, no AI yet.

- [ ] Add Prisma models (ExpertAdviceCard, RoutineTemplate, MilestoneExpectation, VaccinationSchedule, ScreeningReminder, UserRoutine, BabyMilestone)
- [ ] Run migration
- [ ] Create seed data for Newborn stage (0-4 weeks) — prove the content pipeline
- [ ] Implement CompanionRepository + API endpoints (daily-brief, routine, milestones/expected, advice)
- [ ] Build Flutter screens: CompanionTab, DailyBrief, Routine, MilestoneTracker, AdviceFeed
- [ ] Add TierGuard + gating
- [ ] Wire into main navigation (new tab for AI_COMPANION subscribers)

### Phase 2: Content Expansion (2-3 weeks)
**Deliverable:** Complete content for all stages from preconception through 24 months.

- [ ] Author all ~500 ExpertAdviceCards (6 pillars × 8 stage groups)
- [ ] Author all 13 RoutineTemplates
- [ ] Author all ~200 MilestoneExpectations
- [ ] Seed vaccination schedule + screening reminders
- [ ] Add bookmarking + "Was this helpful?" feedback
- [ ] Add push notification support for screening reminders + vaccine due dates

### Phase 3: On-Device AI Chat (3-4 weeks)
**Deliverable:** "Ask the Companion" — on-device LLM running entirely on the phone, zero data leaves the device.

- [ ] Integrate `flutter_llama` / `dart_llama_cpp` plugin for on-device inference
- [ ] Bundle Llama 3.2 3B (INT4 GGUF, ~2 GB) as an app-downloadable asset (downloaded on first AI_COMPANION activation)
- [ ] Implement on-device keyword content retrieval over `ExpertAdviceCard` (SQLite FTS or simple index)
- [ ] Build system prompt assembler (baby profile + stage content + top-3 advice cards → formatted prompt)
- [ ] Build AskCompanionScreen (chat UI) with streaming token display
- [ ] Implement conversation memory (last 3 exchanges + 1-sentence topic summary)
- [ ] Add medical emergency keyword detection + hardcoded "call your doctor" response (bypasses LLM for safety)
- [ ] Add response rating (thumbs up/down)
- [ ] Performance testing: target 5-15 tok/s on iPhone 14+ / Pixel 7+
- [ ] Fallback: if device can't run model (old device, low RAM), offer lightweight keyword-matched content responses (non-LLM fallback)
- [ ] Model update mechanism: check for newer GGUF files on app startup (monthly cadence)

### Phase 4: Polish & Launch (1-2 weeks)
**Deliverable:** Production-ready AI_COMPANION tier.

- [ ] Content review pass (all 500+ cards)
- [ ] Medical/legal review of disclaimers and red-flag language
- [ ] Performance optimization (caching, lazy loading)
- [ ] Accessibility audit of new screens
- [ ] On-device LLM download UX: progress indicator, WiFi-only, resume support, skip option with content-only fallback
- [ ] A/B test: CORE vs AI_COMPANION onboarding
- [ ] Analytics: track which content pillars drive most engagement, model inference latency, download completion rate
- [ ] Launch AI_COMPANION tier in app stores

---

## 8. Success Metrics

| Metric | Target | Measurement |
|---|---|---|
| AI_COMPANION conversion rate | >15% of trial users | Stripe subscription events |
| Daily active usage of Companion tab | >60% of subscribers | In-app analytics |
| Routine completion rate | >40% of steps marked done | UserRoutine.completedSteps |
| Milestone tracking engagement | >3 milestones achieved/week | BabyMilestone count |
| Ask the Companion satisfaction | >80% thumbs up | Response rating |
| Model download completion rate | >90% of subscribers | On-device analytics |
| On-device inference latency | <3s to first token, 8+ tok/s sustained | Device-reported metrics |
| Content pillar engagement diversity | >4 pillars viewed/week | Advice card view analytics |
| Subscription retention (month 2) | >70% | Stripe churn rate |

---

## 9. Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|---|
| LLM hallucination gives incorrect medical advice | 🔴 Critical | Ground all responses in approved expert content cards. Add medical emergency keyword detection with hardcoded "call your doctor" bypass. Prominent disclaimer on every AI response. Small models hallucinate more — content grounding is non-negotiable. |
| On-device model too slow on older phones | 🟠 High | Offer lightweight fallback: keyword-matched content responses without LLM. Allow users to skip the model download. Set minimum device requirements (iPhone 12+ / Pixel 6+). Test across device tiers. |
| Initial model download (~2 GB) deters users | 🟡 Medium | Download only after AI_COMPANION activation (not at app install). Show progress with WiFi-only requirement. Resume support. Compress GGUF with aggressive quantization (Q4_K_M). |
| Model quality insufficient for complex medical questions | 🟡 Medium | System prompt heavily constrains responses to provided content. Medical emergency detection bypasses LLM entirely. Start with 3B model; upgrade path to 4B as mobile hardware improves. Fine-tune on parenting content if needed (Phase 4+). |
| Content becomes stale/outdated | 🟡 Medium | Content versioning + quarterly review cycle. Flag content older than 6 months for review. |
| Parents over-rely on AI vs real doctor | 🟡 Medium | Red-flag detection for medical questions. Clear "call your doctor" language on concerning topics. Disclaimer on every screen. |
| Content quality inconsistent across stages | 🔵 Low | Single content framework. Expert attribution. Peer review cycle. |
| Competitor copies the feature | 🔵 Low | Content is the moat — 500+ expert-authored cards + AI personalization is hard to replicate quickly. |

---

*This document is the blueprint for the AI_COMPANION module. Implementation should follow the phased roadmap in §7. All medical content must be reviewed by a licensed pediatrician before production use.*
