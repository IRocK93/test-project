# On-Device LLM — Implementation Plan

**Date:** 2026-06-18 (updated 2026-06-22)
**Status:** Model selection finalized, onboarding flow designed, ready for implementation
**Package:** `llamadart` v0.6.11 (supports Gemma 4 architecture as of v0.6.10)
**Default Model:** **SmolLM2 360M Instruct** (0.36B, Q4_K_M ~271 MB, Apache 2.0)
**Premium Option:** **SmolLM3 3B** (3B, Q4_K_M ~1.92 GB, Apache 2.0)

---

## 1. Package Decision

**Chosen: `llamadart` v0.6.11** — zero-config Pure Native Assets, built-in resumable downloader, `ChatSession` for auto context-window management, `Stream<String>` for token streaming, GPU auto-detection (Metal/Vulkan).

**Gemma 4 support:** Added in v0.6.10. Native template detection, thinking and tool-call handling, multimodal gating (`supportsVision` / `supportsAudio`). Streaming fix in v0.6.11 correctly parses `<|channel|>` thought markers.

**Fallback: `flutter_llama` v1.1.2** if `llamadart` proves incompatible with the Flutter SDK.

---

## 2. Model Selection (Updated June 2026)

### 2.1 Candidate Comparison

| Model | Params | Q4_K_M Size | RAM Needed | Context | Architecture | License |
|---|---|---|---|---|---|---|
| **SmolLM2 360M** | 0.36B | **~271 MB** | ~500 MB | 8K | `llama` (universal) | Apache 2.0 |
| **SmolLM3 3B** | 3B | **~1.92 GB** | ~2.9–3.8 GB | 128K | `llama` | Apache 2.0 |
| Gemma 4 E2B | 2.3B eff. | ~3.11 GB | ~4.7–6.2 GB | 128K | `gemma4` | Apache 2.0 |
| Qwen 2.5 1.5B | 1.5B | ~0.9 GB | ~1.5 GB | 32K | `qwen2` | Apache 2.0 |

### 2.2 Decision: SmolLM2 360M as Default, SmolLM3 3B as Premium

**Why SmolLM2 360M as default:**

- **Guaranteed to work everywhere.** 271 MB download, ~500 MB RAM — runs on every 4 GB Android phone with massive headroom. No OOM risk, no borderline memory pressure.
- **Standard `llama` architecture.** Universally supported by llama.cpp and all versions of llamadart. Zero compatibility risk.
- **Fast download.** ~2 minutes on Wi-Fi, acceptable even on cellular. No Wi-Fi gate needed.
- **RAG-first design.** The model's primary job is to reformulate retrieved parenting knowledge cards into natural conversation — 360M is sufficient for fluency and empathy when factual backbone comes from RAG.
- **ARM-optimized quants available.** `Q4_0_4_4` variant (229 MB) specifically optimized for Android ARM chips.

**Why SmolLM3 3B as premium upgrade:**

- **3B params — genuine reasoning capability.** Can handle nuanced medical Q&A, multi-turn context, and edge cases beyond RAG coverage.
- **1.92 GB fits 4 GB phones.** Unlike Gemma 4 E2B (3.11 GB which OOMs on 4 GB), SmolLM3 leaves comfortable headroom.
- **Standard `llama` architecture.** Same zero-risk compatibility as SmolLM2.
- **128K context.** Can hold the entire BabyMon expert content framework (~500 cards) in context.
- **Dual-mode reasoning.** Think/no_think toggle — chain-of-thought for complex medical questions, fast path for simple queries.

**Why NOT Gemma 4 E2B:**

- 3.11 GB file won't load on 4 GB phones (OS takes 1–1.5 GB, leaving only 2.5–3 GB for the app).
- Even at Q3_K_S (2.45 GB), users report crashes on 4 GB devices. Quality drops to ~63% of FP16.
- Multimodal (vision/audio) is attractive but the RAM cost makes it impractical for our minimum-spec target.

### 2.3 Tiered Model Strategy

| Tier | Model | Q4_K_M Size | RAM Required | User Experience |
|---|---|---|---|---|
| **Default** | SmolLM2 360M | 271 MB | 500 MB+ | Instant download, basic Q&A backed by RAG |
| **Premium** (opt-in) | SmolLM3 3B | 1.92 GB | 3 GB+ | Deeper reasoning, 128K context, think mode |
| **Content-only** (fallback) | None | — | Any | RAG cards only, no LLM — works on any device |

---

## 3. Model Onboarding Flow

### 3.1 First-Time Activation

When the user opens the AI Companion for the first time:

1. **Medical Disclaimer** (existing) — user must accept.
2. **Model Onboarding** (NEW) — presents two options:

```
┌──────────────────────────────────────────────┐
│  🧠  Your On-Device AI Companion              │
│                                               │
│  A parenting coach that runs entirely on      │
│  your phone. Nothing leaves your device.      │
│                                               │
│  ┌──────────────────────────────────────┐    │
│  │  ⚡ Quick Start              271 MB  │    │
│  │  SmolLM2 360M                        │    │
│  │  Instant answers, fast download      │    │
│  │  ~2 min on Wi-Fi          [Download] │    │
│  └──────────────────────────────────────┘    │
│                                               │
│  ┌──────────────────────────────────────┐    │
│  │  ⭐ Best Quality            1.9 GB   │    │
│  │  SmolLM3 3B                          │    │
│  │  Deeper reasoning, nuanced advice    │    │
│  │  ~10 min on Wi-Fi         [Download] │    │
│  │  ⚠ Wi-Fi recommended                │    │
│  └──────────────────────────────────────┘    │
│                                               │
│  [Skip for now — use basic mode]             │
└──────────────────────────────────────────────┘
```

3. **Wi-Fi gate for SmolLM3:** If user taps Best Quality on cellular, show dialog: *"This download is 1.9 GB. We recommend Wi-Fi to avoid data charges."* → [Use Wi-Fi] [Download Anyway]
4. **No Wi-Fi gate for SmolLM2:** 271 MB is small enough for cellular.
5. **Download progress** (existing screen, updated sizes).
6. **Model loads into LlamadartEngine** → chat opens.

### 3.2 Re-entry States

| State | Behavior |
|---|---|
| Model installed | Chat opens instantly, no onboarding |
| Skipped download | Content-only mode + dismissible banner: "⚡ Download the AI model for smarter answers (271 MB)" |
| Low-RAM device (< 4 GB) | "Your device doesn't support on-device AI" → content-only mode |
| Reinstall / data cleared | Treated as first visit (registry.json is gone) |

### 3.3 Model Switching

From companion settings (accessible via chat screen overflow menu):

```
┌──────────────────────────────────────┐
│  AI Companion Model                  │
├──────────────────────────────────────┤
│  Active: SmolLM2 360M  ● Active     │
│                                      │
│  [Download SmolLM3 3B (1.9 GB)]     │
│                                      │
│  Your other model:                   │
│  None                                │
└──────────────────────────────────────┘
```

- Maximum 2 models stored (active + fallback or active + premium).
- User can delete unused models to free space.
- Model download progress shown inline.

---

## 4. Model Lifecycle & Versioning

### 4.1 Backend Model Registry

```
GET /models/companion-llm/manifest
→ {
    "default": {
      "version": "smollm2-360m-v2",
      "name": "SmolLM2 360M Instruct",
      "sizeBytes": 271000000,
      "sha256": null,
      "url": "https://huggingface.co/bartowski/SmolLM2-360M-Instruct-GGUF/resolve/main/SmolLM2-360M-Instruct-Q4_K_M.gguf",
      "minRamGB": 1
    },
    "premium": {
      "version": "smollm3-3b-v1",
      "name": "SmolLM3 3B",
      "sizeBytes": 1920000000,
      "sha256": null,
      "url": "https://huggingface.co/bartowski/HuggingFaceTB_SmolLM3-3B-GGUF/resolve/main/SmolLM3-3B-Q4_K_M.gguf",
      "minRamGB": 3
    },
    "minimumRequired": null
  }
```

### 4.2 Local Model Registry

Stored as JSON in app documents (`models/registry.json`):

```json
{
  "activeVersion": "smollm2-360m-v2",
  "installed": [
    {
      "version": "smollm2-360m-v2",
      "path": "models/SmolLM2-360M-Instruct-Q4_K_M.gguf",
      "sizeBytes": 271000000,
      "name": "SmolLM2 360M",
      "installedAt": "2026-06-22T10:00:00Z",
      "status": "active"
    }
  ],
  "updateCheckedAt": "2026-06-22T10:00:00Z"
}
```

### 4.3 Update Flow

```
App checks /models/companion-llm/manifest (on launch, once per 24h)
↓
New version available? → No → Use active version
↓ Yes
Download new model to temp path (*.gguf.partial)
↓
Verify SHA256 (optional, skipped if not configured)
↓
Rename to final path
↓
Load new model, run smoke test
↓
✅ Pass → set as active, old → fallback
❌ Fail → delete new, keep old, log error
```

### 4.4 Rollback Triggers

| Trigger | Detection | Action |
|---|---|---|
| Model fails to load | `LlamaEngine.loadModel()` throws | Delete new version, fall back to previous |
| Inference consistently fails | 3+ consecutive errors in 24h | Auto-rollback, notify user |
| OOM on model load | `loadModel()` throws memory error | Fall back to smaller model or content-only |
| User manually requests rollback | Settings → Companion Model | Swap active ↔ fallback |

---

## 5. File Structure

```
lib/features/companion/
  data/llm/
    model_download_service.dart       # Download lifecycle, resume, SHA256, connectivity check
    model_manager.dart                # Load/unload engine, registry.json, version tracking
    rag_service.dart                  # TF-IDF search over ExpertAdviceCard, RAG context
    system_prompt_builder.dart        # Full prompt from baby profile + RAG + history
    chat_session_manager.dart         # Chat history, token counting, context window gating
    llamadart_engine.dart             # llamadart wrapper, load/generate/unload
    llm_inference_service.dart        # Full pipeline: RAG → prompt → generate → safety check
    safety_classifier.dart            # Post-inference checks: emergency, medication, anti-vax
    device_capability_service.dart    # RAM, storage, architecture checks
    model_manifest_service.dart       # Fetches manifest from backend
  domain/models/
    chat_message.dart                 # {role, content, timestamp}
    model_download_state.dart         # Sealed: notStarted | inProgress | verifying | complete | error
    model_manifest.dart               # Backend manifest response (default + premium)
  presentation/providers/
    llm_provider.dart                 # All Riverpod providers (download, engine, inference, registry)
    companion_provider.dart           # Engine and inference service wiring
  presentation/screens/
    companion_tab.dart                # Entry point, device check, onboarding dispatch
    model_onboarding_screen.dart      # NEW — model selection card (Quick Start vs Best Quality)
    model_download_screen.dart        # Download progress, Wi-Fi gate, cancel
    chat_screen.dart                  # Chat UI with streaming token display
  presentation/widgets/
    chat_bubble.dart                  # User vs assistant message bubble
    chat_input_bar.dart               # Text field + send button
    upgrade_prompt.dart               # Premium gate for non-subscribers
```

---

## 6. Build Impact

| Setting | Requirement |
|---|---|
| Android `minSdkVersion` | API 24 (Android 7.0) for NEON SIMD |
| iOS Deployment Target | iOS 15.0+ for Metal |
| APK size increase | ~20 MB for native library (models downloaded post-install) |
| Device RAM minimum | 1 GB (SmolLM2 360M); 3 GB recommended for SmolLM3 3B |
| New pubspec deps | `llamadart: ^0.6.11`, `device_info_plus: ^10.0.0`, `connectivity_plus: ^6.0.0` |

---

## 7. Fallback Strategy

| Device condition | Behavior |
|---|---|
| < 1 GB RAM | "Device doesn't support on-device AI" → content-only mode |
| Model not downloaded | Model onboarding screen |
| Download skipped | Content-only mode with dismissible banner |
| Inference OOM | Catch exception, offer "close other apps and retry" or fall back to SmolLM2 |
| No GPU (CPU-only) | Warn "responses will be slower," set `nThreads: 2` |

---

## 8. Testing

- **Widget tests:** `MockChatSessionManager` returning scripted token streams
- **Unit tests:** `SystemPromptBuilder` with mock baby profile, `RagService` with mock repository
- **Device testing:** 4 GB Android phone (SmolLM2 + SmolLM3), 2 GB old device (content-only fallback)
- **Desktop integration:** Load GGUF on macOS for end-to-end validation

---

## 9. Implementation Phases

| Phase | Duration | Deliverable |
|---|---|---|
| **Infrastructure** | Week 1-2 | Domain models, model download service, model manager, download screen |
| **Inference Pipeline** | Week 3-4 | RAG service, system prompt builder, chat session manager, providers |
| **Chat UI** | Week 5-6 | Chat screen, bubbles, input bar, streaming display, navigation wiring |
| **Hardening** | Week 7-8 | Background lifecycle, RAM detection, fallback UI, device testing |

---

*References: llamadart v0.6.11, llama.cpp GGUF format, SmolLM2 360M, SmolLM3 3B, Gemma 4 E2B*
