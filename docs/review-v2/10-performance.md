# S10 — Performance Audit

**Date:** 2026-06-18 | **Overall Severity:** 🟠 High

---

## Findings

### PF-C01 | 🔴 CRITICAL | shrinkWrap Anti-Pattern — sleep_screen.dart
**Location:** `sleep_screen.dart:~348`
**What:** `ListView.builder` with `shrinkWrap: true` and `NeverScrollableScrollPhysics()` inside `SingleChildScrollView` — completely defeats lazy loading. Every item built immediately.
**Fix:** Use `SliverList` inside `CustomScrollView`.

### PF-C02 | 🔴 CRITICAL | N+1 in journal-proposals approveProposal()
**Location:** `journal-proposals.service.ts:49-76`
**What:** Iterates `Object.entries(changes)` and issues one `update()` per field. 5 fields = 5 sequential Prisma calls.
**Fix:** Build single `data` object, issue one `update`.

### PF-C03 | 🔴 CRITICAL | SHA-256 OOM Risk — model_download_service.dart
**Location:** `model_download_service.dart:_verifySha256()`
**What:** Reads entire 1.2GB GGUF file with `file.readAsBytes()` for SHA-256. Guaranteed OOM crash on most devices.
**Fix:** Streaming/chunked hash computation.

### PF-H01 | 🟠 HIGH | 9 Unbounded List Endpoints
Growth, allergies, badges, medical-team, media, journal (×3), companion milestones — all return all rows with no pagination.
**Fix:** Apply PaginationDto (skip/take) to all list endpoints.

### PF-H02 | 🟠 HIGH | No Response Compression
No gzip/brotli at any layer. Journal responses can reach 500KB-2MB uncompressed.
**Fix:** Add `compression` package + `app.use(compression())` in main.ts.

### PF-H03 | 🟠 HIGH | Journal getJournal() — 5 Sequential Queries
5 independent findMany calls, each a network round-trip.
**Fix:** Combine into `$transaction` with parallel queries.

### PF-H04 | 🟠 HIGH | No Caching Layer
No Redis, no in-memory cache, no response caching headers. Stage content and reference data fetched from DB repeatedly.

### PF-H05 | 🟠 HIGH | Badge Check Pulls Full Relations for Length
`checkAndAwardBadges()` fetches all milestones, feedLogs, healthRecords just to check `.length`.
**Fix:** Use Prisma `_count` aggregations (already done correctly in evolution service).

### PF-H06 | 🟠 HIGH | ThumbnailUrl Never Populated
Media model has `thumbnailUrl` field but never populated. All media grids display full-resolution images.

### PF-M01 | 🟡 MEDIUM | DATABASE_POOL_SIZE Env Var Never Read
Defined in .env.example but no code reads it. Connection pool at Prisma default.

### PF-M02 | 🟡 MEDIUM | No Image Dimension Constraint on Upload
Photos from modern phones uploaded at full resolution. Quality 85 but no max dimension.

### PF-M03 | 🟡 MEDIUM | Full Model Returns Without select Clauses
Journal and export queries return all columns. Add `select` for needed fields only.

### PF-M04 | 🟡 MEDIUM | llamadart 0.5.1 — Pre-1.0, Unknown Performance
No benchmarks, no warm-up optimization, cold-start on first inference.

### PF-M05 | 🟡 MEDIUM | 9-Tab IndexedStack Keeps All Tabs Alive
All 9 widget trees + Riverpod state in memory simultaneously.

## Good Patterns
- ✅ Multi-stage Docker build with layer caching
- ✅ Streaming LLM inference via `async*` generators
- ✅ Correct `SliverList` usage in journal and album screens
- ✅ Evolution service uses `_count` aggregations (reference pattern)

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 3 |
| 🟠 High | 6 |
| 🟡 Medium | 5 |
| **Total** | **14** |
