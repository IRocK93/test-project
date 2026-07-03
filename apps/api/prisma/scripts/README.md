# Seed Data Translation Scripts

This directory contains `section-translate.ts`, a production-grade pipeline that
translates BabyMon companion content into any locale using an AI translation API
and inserts directly via Prisma — no SQL generation, no parsing bugs.

---

## Overview

The pipeline reads English seed content from the database, sends it to an AI
translation API in small batches, and inserts translated rows directly into the
database via Prisma upsert. It is idempotent, resumable, and sectioned so you
can translate one content type at a time.

**Translated content types:**

| Table                  | Fields Translated                                           |
| ---------------------- | ----------------------------------------------------------- |
| `ExpertAdviceCard`     | `title`, `summary`, `content`, `tags`                       |
| `RoutineTemplate`      | `title`, `description`, `feedFrequency`, `sampleSchedule`, `bedtimeRitual` |
| `MilestoneExpectation` | `title`, `description`, `redFlagText`, `activityPrompt`     |
| `StageContent`         | `summaryText`, `nurturingText`, `encouragementText`         |

---

## Quick Start

```bash
cd apps/api

# Translate one content type (e.g. Hebrew ExpertAdviceCard, 16 items max)
npx ts-node prisma/scripts/section-translate.ts \
  --type ExpertAdviceCard --locale he --max-items 16

# Translate all 4 content types for Hebrew
for type in ExpertAdviceCard RoutineTemplate MilestoneExpectation StageContent; do
  npx ts-node prisma/scripts/section-translate.ts --type $type --locale he
done
```

**Prerequisites:**
- English seed data in the database (`npm run prisma:seed`)
- Ollama running with a translation model (default: `translategemma:12b`)
  - Or any OpenAI-compatible API via `--api-url`

---

## CLI Options

| Flag              | Default                                      | Description                                      |
| ----------------- | -------------------------------------------- | ------------------------------------------------ |
| `--type`          | `ExpertAdviceCard`                           | Content type to translate.                       |
| `--locale`        | `he`                                         | Target locale code.                              |
| `--model`         | `translategemma:12b`                         | AI model to use.                                 |
| `--api-url`       | `http://localhost:11434/v1/chat/completions` | API endpoint (OpenAI-compatible).                |
| `--batch-size`    | `4`                                          | Items per API call.                              |
| `--batch-delay`   | `1000`                                       | Milliseconds to wait between API calls.          |
| `--max-retries`   | `3`                                          | Retry attempts per failed batch.                 |
| `--retry-delay`   | `3000`                                       | Base retry delay in milliseconds.                |
| `--max-items`     | `0` (no limit)                               | Stop after N successfully translated items.      |

---

## How It Works

1. **Fetches** all English items for the content type from the database.
2. **Checks** what's already done via on-disk cache (`.section-cache.json`) and
   existing `he_` prefix rows in the database.
3. **Translates** remaining items in batches via AI, with auto-retry on failure.
4. **Inserts** directly via Prisma `upsert` using `he_<englishId>` as the ID.
5. **Preserves** enum/structural fields (`stageKey`, `category`, `domain`, etc.)
   that must not be translated.

The pipeline is **idempotent** — re-run the same command and it skips
already-translated items. The cache survives restarts and interruptions.

---

## Key Design Decisions

- **No SQL generation.** The old pipeline (`translate-seed-data.ts`) generated
  SQL files with manual escaping, which was fragile. The new pipeline uses
  Prisma upsert directly — no parsing bugs, no escape issues.
- **ID masking.** Item IDs are masked as `item_0`, `item_1`, etc. before
  sending to the AI, preventing the model from mutating keys (e.g. `__` → `_`).
- **`max_tokens: 4096`** is set on Ollama API calls to prevent JSON truncation
  on large items (e.g. RoutineTemplate with nested `sampleSchedule`).
- **Hebrew rows get `he_` prefix IDs** (e.g. `he_seed_advice_born_month_1_...`),
  making them easy to identify and query.

---

## Supported Locales

| Code | Language             |
| ---- | -------------------- |
| `he` | Hebrew               |
| `ar` | Arabic               |
| `es` | Spanish              |
| `fr` | French               |
| `de` | German               |
| `it` | Italian              |
| `pt` | Portuguese           |
| `ru` | Russian              |

---

## Utility Scripts

| Script | Description |
| ------ | ----------- |
| `section-translate.ts` | Main translation pipeline. |
| `check-he-counts.ts` | Query current Hebrew row counts vs English baseline. |
| `spot-check-quality.ts` | Sample rows side-by-side (EN vs target locale) and verify script characters. |
| `cleanup-all-he-rows.sql` | Migrate old random-UUID Hebrew rows to `he_` prefix IDs. |

---

## Troubleshooting

### "Missing translation for item" errors
Some items have special characters in their IDs or unusually long content. Try:
```bash
# Reduce batch size to 1 to isolate the problem item
npx ts-node prisma/scripts/section-translate.ts --type ExpertAdviceCard --locale he --batch-size 1
```

### "Unexpected end of JSON input"
The AI model is truncating its JSON output. The pipeline already sets
`max_tokens: 4096`. If the issue persists, reduce `--batch-size` to 1 for
items with large nested JSON (e.g. RoutineTemplate).

### Cache issues
Delete the cache to force re-translation:
```bash
rm prisma/scripts/.section-cache.json
```

### Cleanup old random-UUID rows
If you migrated from the old pipeline, you may have rows with random UUIDs
instead of `he_` prefix IDs. Run the cleanup script to migrate them:
```bash
npx prisma db execute --file prisma/scripts/cleanup-all-he-rows.sql
```
