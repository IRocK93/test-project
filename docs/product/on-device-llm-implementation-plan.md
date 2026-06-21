# On-Device LLM — Implementation Plan

**Date:** 2026-06-18
**Status:** Design complete — ready for Phase 1 implementation
**Package:** `llamadart` v0.5.1
**Default Model:** **Gemma 4 E2B** (2.3B effective, INT4 ~1.2 GB, Apache 2.0)
**Premium Option:** Gemma 4 E4B (4.5B effective, ~1.8 GB) or Qwen3.5-4B
**Low-RAM Fallback:** Phi-4-mini (3.8B, Q4 2.49 GB, MIT)

---

## 1. Package Decision

**Chosen: `llamadart` v0.8.0** — zero-config Pure Native Assets, built-in resumable downloader, `ChatSession` for auto context-window management, `Stream<String>` for token streaming, GPU auto-detection (Metal/Vulkan).

**Fallback: `flutter_llama` v1.1.2** if `llamadart` proves incompatible with the Flutter SDK (confirm what flutter version the app uses and place it here) `>=3.0.0 <4.0.0`.

---

## 2. Model Selection (Updated June 2026)

### 2.1 Candidate Comparison

| Model | Params | INT4 Size | Context | Multimodal | License | Best For |
|---|---|---|---|---|---|---|
| **Gemma 4 E2B** | 2.3B eff. | ~1.2 GB | 128K | ✅ Text+Image+Audio | Apache 2.0 | **Default choice** — mobile-optimized, multimodal, fastest |
| **Gemma 4 E4B** | 4.5B eff. | ~1.8 GB | 128K | ✅ Text+Image+Audio | Apache 2.0 | Premium tier — higher reasoning, still mobile-friendly |
| **Qwen3.5-4B** | 4B | ~2.5 GB | **262K** (1M ext.) | Text+Image | Apache 2.0 | Long docs, multilingual, thinking mode |
| **Phi-4-mini** | 3.8B | 2.49 GB | 128K | ❌ Text only | MIT | Lowest RAM (4 GB), strongest English reasoning |
| **Llama 3.2 3B** | 3B | ~2 GB | 128K | ❌ Text only | Llama Community | Largest ecosystem, function calling |

### 2.2 Decision: Gemma 4 E2B as Default

**Why Gemma 4 over the others:**

- **Purpose-built for mobile.** Google co-engineered with Qualcomm, MediaTek, and Pixel teams. Up to 4× faster and 60% less battery than previous generation on Android.
- **Multimodal out of the box.** Text + image + audio in one model. A parent could snap a photo of a rash, a food label, or a sleep environment and ask about it — no separate vision model needed.
- **Apache 2.0 license.** No commercial restrictions, no usage caps, no approval process. Full freedom to modify and redistribute.
- **Configurable thinking mode.** Can toggle chain-of-thought reasoning on for complex medical questions, off for simple factual queries (saves latency).
- **128K context.** Enough to hold the entire BabyMon expert content framework (~500 cards) in context if needed.

**Why not:**
- Qwen3.5-4B has 262K context but ~2× the RAM at INT4. Overkill for a parenting coach.
- Phi-4-mini has the best English benchmarks but lacks multimodal — a meaningful gap for a parenting app where photos are central.
- Gemma 4 E4B is available as a premium "higher quality" download option for devices with 8 GB+ RAM.

### 2.3 Tiered Model Strategy

| Tier | Model | RAM Required | User Experience |
|---|---|---|---|
| **Standard** (default) | Gemma 4 E2B (1.2 GB) | 4 GB+ | Text chat + optional image upload |
| **Premium** (opt-in download) | Gemma 4 E4B (1.8 GB) | 8 GB+ | Higher-quality reasoning, faster image understanding |
| **Low-RAM fallback** | Phi-4-mini (2.49 GB Q4) | 4 GB | Text-only, strongest factual accuracy for its size |
| **Basic mode** (bundled/fallback) | SmolLM3-360M (~80 MB) | 2 GB+ | Instant basic responses while full model downloads |

---

## 3. Model Lifecycle & Versioning

The model is NOT pinned to a specific version. The app supports seamless updates while maintaining a stable fallback.

### 3.1 Backend Model Registry

A new endpoint serves model metadata:

```
GET /models/companion-llm/manifest
→ {
    "latest": {
      "version": "gemma4-e2b-v3",
      "name": "Gemma 4 E2B",
      "sizeBytes": 1288490188,
      "sha256": "a1b2c3...",
      "url": "https://cdn.babymon.app/models/gemma4-e2b-v3-q4km.gguf",
      "minRamGB": 4,
      "changelog": "Improved sleep advice accuracy, faster image understanding"
    },
    "minimumRequired": "gemma4-e2b-v1",
    "rollbackAdvised": null
  }
```

### 3.2 Local Model Registry

Stored as JSON in app documents (`models/registry.json`):

```json
{
  "activeVersion": "gemma4-e2b-v2",
  "fallbackVersion": "gemma4-e2b-v1",
  "installed": [
    {
      "version": "gemma4-e2b-v1",
      "path": "models/gemma4-e2b-v1-q4km.gguf",
      "sizeBytes": 1288490188,
      "sha256": "abc123...",
      "installedAt": "2026-05-01T10:00:00Z",
      "lastUsedAt": "2026-06-15T08:30:00Z",
      "status": "stable"
    },
    {
      "version": "gemma4-e2b-v2",
      "path": "models/gemma4-e2b-v2-q4km.gguf",
      "sizeBytes": 1290123456,
      "sha256": "def456...",
      "installedAt": "2026-06-15T09:00:00Z",
      "lastUsedAt": "2026-06-18T07:00:00Z",
      "status": "active"
    }
  ],
  "updateCheckedAt": "2026-06-18T07:00:00Z"
}
```

### 3.3 Update Flow

```
┌─────────────────────────────────────────────────────┐
│  App checks /models/companion-llm/manifest          │
│  (on launch, once per 24h)                          │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │ New version available? │─── No ──► Use active version
         └───────────┬───────────┘
                     │ Yes
                     ▼
┌─────────────────────────────────────────────────────┐
│  1. DOWNLOAD new model to temp path                 │
│     (models/gemma4-e2b-v3-q4km.gguf.tmp)           │
│  2. VERIFY SHA256 hash                              │
│  3. RENAME to final path (atomic on same filesystem)│
│  4. Update registry: status = "unverified"          │
│                                                     │
│  ⚠️ OLD MODEL IS NEVER DELETED DURING DOWNLOAD      │
│     Active version keeps serving requests           │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  LOAD new model, run smoke test:                    │
│  - "What is a normal temperature for a newborn?"    │
│  - Verify response is non-empty, coherent           │
│  - Verify inference latency < timeout               │
│                                                     │
│  ✅ Pass → set activeVersion, old → fallbackVersion │
│  ❌ Fail → delete new, keep old active, log error   │
└─────────────────────────────────────────────────────┘
```

### 3.4 Rollback Triggers

The app automatically rolls back to the fallback version if:

| Trigger | Detection | Action |
|---|---|---|
| Model fails to load (corrupt file) | `LlamaEngine.loadModel()` throws | Delete new version, mark registry, fall back |
| Inference consistently fails | 3+ consecutive inference errors in 24h | Auto-rollback, notify user |
| OOM on model load | `loadModel()` throws memory error | Fall back to smaller model (Phi-4-mini or SmolLM3) |
| User manually requests rollback | Settings → Companion Model → "Use previous version" | Swap active ↔ fallback in registry |
| Server flags version as broken | `manifest.rollbackAdvised != null` | App checks on launch, auto-rolls back |

### 3.5 User-Visible Controls

In the companion settings (accessible from the chat screen's overflow menu):

```
┌──────────────────────────────────────┐
│  AI Companion Model                  │
├──────────────────────────────────────┤
│  Active: Gemma 4 E2B v3  ● Active   │
│  Updated: June 15, 2026             │
│                                      │
│  What's new in v3:                  │
│  • Better sleep advice              │
│  • Faster photo understanding       │
│                                      │
│  [Check for Updates]                │
│  [Use Previous Version (v2)]        │
│  [Delete Old Versions (save 1.2GB)] │
│                                      │
│  Auto-update: [ON]  WiFi only: [ON] │
└──────────────────────────────────────┘
```

### 3.6 Storage Management

- Maximum 2 versions stored at once (active + fallback)
- When a 3rd version is downloaded and verified, the oldest non-active, non-fallback version is deleted
- User can manually delete old versions to free space
- Minimum required version enforced: if the server declares `minimumRequired: "gemma4-e2b-v2"` and the user only has v1, the app blocks chat until updated

### 3.7 New Files for Versioning

| File | Responsibility |
|---|---|
| `data/llm/model_registry.dart` | Read/write `registry.json`, track versions, manage active/fallback |
| `data/llm/model_update_service.dart` | Check manifest, download new version, atomic install, smoke test, rollback |
| `data/llm/model_smoke_test.dart` | Run canonical questions against newly downloaded model, verify output quality |
| `domain/models/model_manifest.dart` | Data class for backend manifest response |
| `domain/models/model_version_entry.dart` | Data class for local registry entry |
| `presentation/screens/model_settings_screen.dart` | User-facing model management UI |

---

## 4. File Structure

```
lib/features/companion/
  data/llm/
    model_registry.dart               # Read/write registry.json, track active/fallback versions
    model_update_service.dart         # Check manifest, download, atomic install, smoke test, rollback
    model_download_service.dart       # Download lifecycle, resume, SHA256, WiFi gating
    model_manager.dart                # Load/unload LlamaEngine, file integrity, dispose on background
    model_smoke_test.dart             # Canonical questions to verify new model quality
    rag_service.dart                  # Keyword search over ExpertAdviceCard, assembles RAG context
    system_prompt_builder.dart        # Assembles full prompt from baby profile + RAG + history
    chat_session_manager.dart         # Wraps llamadart ChatSession, history trimming
  domain/models/
    chat_message.dart                 # {role, content, timestamp}
    model_manifest.dart               # Backend manifest response
    model_version_entry.dart          # Local registry entry
    model_download_state.dart         # Sealed: notStarted | downloading(progress) | verifying | ready | error
    model_load_state.dart             # Sealed: unloaded | loading | ready | error
    inference_state.dart              # Sealed: idle | generating(partialText) | complete(fullText) | error
  presentation/providers/
    llm_provider.dart                 # All LLM Riverpod providers (engine, download, chat, inference, registry)
  presentation/screens/
    chat_screen.dart                  # Chat UI with streaming token display
    model_download_screen.dart        # Download progress, WiFi gate, skip option
    model_settings_screen.dart        # User-facing model management (version, rollback, storage)
  presentation/widgets/
    chat_bubble.dart                  # User vs assistant message bubble
    chat_input_bar.dart               # Text field + send button
    thinking_indicator.dart           # Animated dots during generation
    model_status_banner.dart          # "Gemma 4 E2B v3 ● Active / Update available / Downloading..."
```
    model_download_state.dart        # Sealed: notStarted | downloading(progress) | verifying | ready | error
    model_load_state.dart            # Sealed: unloaded | loading | ready | error
    inference_state.dart             # Sealed: idle | generating(partialText) | complete(fullText) | error
  presentation/providers/
    llm_provider.dart                # All LLM Riverpod providers (engine, download, chat, inference)
  presentation/screens/
    chat_screen.dart                 # Chat UI with streaming token display
    model_download_screen.dart       # Download progress, WiFi gate, skip option
  presentation/widgets/
    chat_bubble.dart                 # User vs assistant message bubble
    chat_input_bar.dart              # Text field + send button
    thinking_indicator.dart          # Animated dots during generation
    model_status_banner.dart         # "Model ready / downloading / not available"
```

---

## 5. Riverpod Providers

| Provider | Type | Purpose |
|---|---|---|
| `modelDownloadStateProvider` | `StateNotifierProvider` | Download progress + status |
| `modelLoadStateProvider` | `StateNotifierProvider` | Engine load/unload state |
| `inferenceStateProvider` | `StateNotifierProvider` | Current generation state with streaming text |
| `chatHistoryProvider` | `StateNotifierProvider<List<ChatMessage>>` | In-memory chat history |
| `chatSessionProvider` | `Provider<ChatSession>` | llamadart ChatSession instance |
| `llmEngineProvider` | `Provider<LlamaEngine>` | llamadart LlamaEngine singleton |
| `ragContextProvider` | `FutureProvider.family` | Keyword search → concatenated RAG context |

---

## 6. Build Impact

| Setting | Requirement |
|---|---|
| Android `minSdkVersion` | API 24 (Android 7.0) for NEON SIMD |
| iOS Deployment Target | iOS 15.0+ for Metal |
| APK size increase | ~20 MB for native library (model downloaded post-install) |
| Device RAM minimum | 4 GB (Gemma 4 E2B); 6 GB recommended for E4B/Premium |
| New pubspec deps | `llamadart: ^0.5.1`, `device_info_plus: ^10.0.0`, `connectivity_plus: ^6.0.0`, `flutter_markdown: ^0.7.0` |

---

## 7. Fallback Strategy

| Device condition | Behavior |
|---|---|
| < 4 GB RAM | Show "device doesn't support on-device AI" + content-only mode |
| Model not downloaded | Show download screen |
| Inference OOM | Catch exception, offer "close other apps and retry" |
| No GPU (CPU-only) | Warn "responses will be slower," set `nThreads: 2` |
| Tiny fallback model | Bundled ~80 MB, loads instantly, labeled "Basic Mode" until full model ready |

---

## 8. Testing

- **Widget tests:** `MockChatSessionManager` returning scripted token streams
- **Unit tests:** `SystemPromptBuilder` with mock baby profile, `RagService` with mock repository
- **Desktop integration:** Load small GGUF on macOS for end-to-end validation
- **Device testing:** iPhone SE (4 GB), Pixel 6a (6 GB), old Android 3 GB (verify fallback)

---

## 9. Implementation Phases

| Phase | Duration | Deliverable |
|---|---|---|
| **Infrastructure** | Week 1-2 | Domain models, model download service, model manager, download screen |
| **Inference Pipeline** | Week 3-4 | RAG service, system prompt builder, chat session manager, providers |
| **Chat UI** | Week 5-6 | Chat screen, bubbles, input bar, streaming display, navigation wiring |
| **Hardening** | Week 7-8 | Background lifecycle, RAM detection, fallback UI, device testing |

---

*References: llamadart v0.5.1, flutter_llama v1.1.2, llama.cpp GGUF format, Gemma 4 E2B/E4B, Qwen3.5-4B, Phi-4-mini, Llama 3.2 3B*
