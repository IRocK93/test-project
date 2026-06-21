# S11 — AI/LLM Review

**Date:** 2026-06-18 | **Overall Verdict:** 🔴 NOT PRODUCTION-READY

The AI Companion is an **ambitious architectural skeleton** with genuinely strong content strategy but dangerously incomplete engineering. It should not ship to real parents in its current state.

---

## Key Findings

### AI-C01 | 🔴 CRITICAL | Hallucinated Medical Advice — No Safety Layer
No output validation, no confidence scoring, no hallucination detection, no factuality verification against RAG source material. A 2B parameter Q4 quantized model WILL hallucinate on parenting questions.

### AI-C02 | 🔴 CRITICAL | System Prompt Jailbreak — Trivially Bypassable
Grounding constraint ("Only provide information present in...") is easily overridden by adversarial prompts. No anti-jailbreak instructions, no defense in depth.

### AI-C03 | 🔴 CRITICAL | Mock Engine as Default Constructor
`llm_inference_service.dart:58`: `_engine = engine ?? MockLlmEngine()` — any error recovery path constructing without explicit engine silently uses mock returning canned text.

### AI-C04 | 🔴 CRITICAL | Placeholder SHA-256 — No Model Integrity
`model-manifest.controller.ts:18`: `sha256: 'placeholder-sha256-replace-with-real-hash'` — zero integrity verification on downloaded model.

### AI-H01 | 🟠 HIGH | llamadart — Dynamic Dispatch via as dynamic
Every API call routed through `as dynamic` with zero compile-time type checking. API change → runtime crash with opaque error.

### AI-H02 | 🟠 HIGH | No Token Counting — Context Window Overflow Risk
ChatSessionManager uses fixed `maxHistoryExchanges = 3` (message count, not tokens). RAG + system prompt + history can easily exceed 8K token window.

### AI-H03 | 🟠 HIGH | Fallback Canned Response Pretends to Be Real AI
When model unavailable, returns identical canned text for every query — including emergencies. No "model unavailable" disclosure.

### AI-H04 | 🟠 HIGH | Seed Content Gaps — Most stageKeys Return Empty
Content seeded for ~25 specific stageKeys. Any baby with different stageKey gets zero advice cards, no routine, no milestones.

### AI-H05 | 🟠 HIGH | Companion Seed NOT in Main Seed Pipeline
`prisma:seed` runs `seed.ts` only. `seed:companion` requires separate manual invocation.

### AI-H06 | 🟠 HIGH | RAG — Naive Keyword Matching Only
Simple word-overlap scoring. No TF-IDF, no embeddings, no synonym expansion. Query "shots" won't match cards about "vaccines."

### AI-M01 | 🟡 MEDIUM | No AI Identity Disclosure in System Prompt
Presents as "BabyMon Companion, a warm and knowledgeable parenting assistant" — no "I am an AI" disclosure.

### AI-M02 | 🟡 MEDIUM | Content Provenance Unclear
Advice card content reads as potentially AI-generated. No evidence of human medical review.

### AI-M03 | 🟡 MEDIUM | download — 2-Hour Timeout Too Long for Mobile
`receiveTimeout: Duration(hours: 2)` — hangs indefinitely on stalled connections.

### AI-M04 | 🟡 MEDIUM | No Device Capability Checks
No minimum disk space check, no RAM check before downloading 1.2GB model.

## Strengths
- ✅ On-device inference preserves privacy (no data leaves device)
- ✅ Streaming inference via `async*` generators (progressive UI)
- ✅ Medical disclaimer gate mandatory before first use
- ✅ Expert persona system well-designed (Dr. Vasquez + Maria Chen)
- ✅ Monthly AI limitation reminder
- ✅ Content writing quality is genuinely excellent (if medically reviewed)
- ✅ Correct Gemma chat template format (`<|system|>`, `<|user|>`, `<|assistant|>`)

## Risk Register (Top 5)

| # | Risk | Severity | Likelihood |
|---|---|---|---|
| 1 | Hallucinated medical advice harms child | CRITICAL | High |
| 2 | System prompt jailbreak → dangerous responses | CRITICAL | Medium |
| 3 | Mock engine default → parents trust non-functional AI | HIGH | Medium |
| 4 | Placeholder SHA-256 → no model integrity | HIGH | Certain |
| 5 | Zero test coverage → undetectable regressions | HIGH | Certain |

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 6 |
| 🟡 Medium | 4 |
| **Total** | **14** |
