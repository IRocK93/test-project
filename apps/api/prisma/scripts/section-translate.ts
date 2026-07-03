/**
 * section-translate.ts
 *
 * Production-grade sectioned translation pipeline.
 * Translates ONE content type at a time in small batches,
 * inserting directly via Prisma — no SQL generation, no parsing bugs.
 *
 * Usage:
 *   npx ts-node prisma/scripts/section-translate.ts --type ExpertAdviceCard --locale he
 *   npx ts-node prisma/scripts/section-translate.ts --type RoutineTemplate --locale he --batch-size 4
 *
 * Features:
 *   - Small batches (default 4) — fast feedback, avoids Ollama overload
 *   - Prisma upsert — idempotent, handles JSONB correctly
 *   - Sectioned — run one content type at a time, verify between runs
 *   - Clear per-batch progress reporting
 */

import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

// ─── Config ───

interface Config {
  contentType: string;
  locale: string;
  batchSize: number;
  batchDelayMs: number;
  maxRetries: number;
  retryDelayMs: number;
  maxItems: number;
  maxTokens: number;
  model: string;
  apiUrl: string;
  apiKey: string;
  cacheFile: string;
}

function parseArgs(): Config {
  const args = process.argv.slice(2);
  const getArg = (flag: string, fallback: string): string => {
    const idx = args.indexOf(flag);
    return idx >= 0 ? args[idx + 1] : fallback;
  };

  return {
    contentType: getArg('--type', 'ExpertAdviceCard'),
    locale: getArg('--locale', 'he'),
    batchSize: parseInt(getArg('--batch-size', '4'), 10),
    batchDelayMs: parseInt(getArg('--batch-delay', '1000'), 10),
    maxRetries: parseInt(getArg('--max-retries', '3'), 10),
    retryDelayMs: parseInt(getArg('--retry-delay', '3000'), 10),
    maxItems: parseInt(getArg('--max-items', '0'), 10),
    maxTokens: parseInt(getArg('--max-tokens', '8192'), 10),
    model: getArg('--model', 'translategemma:12b'),
    apiUrl: getArg('--api-url', 'http://localhost:11434/v1/chat/completions'),
    apiKey: process.env.OPENAI_API_KEY || 'ollama',
    cacheFile: path.join(__dirname, '.section-cache.json'),
  };
}

// ─── Preserve fields (enum values that must NOT be translated) ───

const PRESERVE_FIELDS: Record<string, string[]> = {
  ExpertAdviceCard: ['stageKey', 'category', 'source', 'priority'],
  RoutineTemplate: ['stageKey'],
  MilestoneExpectation: ['stageKey', 'domain', 'status'],
  StageContent: ['stageKey', 'isPostBirth'],
};

// ─── Simple cache ───

interface CacheEntry {
  englishId: string;
  locale: string;
  contentType: string;
  translatedFields: Record<string, unknown>;
  createdAt: string;
}

class SectionCache {
  private entries: Map<string, CacheEntry> = new Map();

  constructor(private filePath: string) {
    if (fs.existsSync(filePath)) {
      try {
        const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        for (const e of data.entries || []) {
          this.entries.set(`${e.locale}|${e.contentType}|${e.englishId}`, e);
        }
        console.log(`  Cache: ${this.entries.size} entries loaded`);
      } catch { /* fresh start */ }
    }
  }

  get(locale: string, contentType: string, englishId: string): CacheEntry | undefined {
    return this.entries.get(`${locale}|${contentType}|${englishId}`);
  }

  set(entry: CacheEntry) {
    this.entries.set(`${entry.locale}|${entry.contentType}|${entry.englishId}`, entry);
  }

  save() {
    const dir = path.dirname(this.filePath);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(this.filePath, JSON.stringify({ entries: Array.from(this.entries.values()) }, null, 2));
  }
}

// ─── AI Translation ───

function localeToLanguage(locale: string): string {
  const map: Record<string, string> = {
    he: 'Hebrew', ar: 'Arabic', es: 'Spanish', fr: 'French',
    de: 'German', it: 'Italian', pt: 'Portuguese', ru: 'Russian',
    zh: 'Chinese',
  };
  return map[locale] || locale;
}

async function translateBatch(
  config: Config,
  items: Array<{ id: string; fields: Record<string, unknown> }>,
  locale: string,
  contentType: string,
): Promise<Record<string, Record<string, unknown>>> {
  const languageName = localeToLanguage(locale);

  // Mask IDs to prevent AI from mutating keys (e.g. __ → _ normalization)
  const reverseMap: Record<string, string> = {}; // originalId → item_N
  items.forEach((item, idx) => {
    reverseMap[item.id] = `item_${idx}`;
  });

  const systemPrompt = `You are a professional medical-and-parenting content translator.

LANGUAGE A (Source): English
LANGUAGE B (Target): ${languageName} (locale: "${locale}")

Your task: translate the following ${contentType} items from Language A to Language B.

Rules:
1. Preserve the original tone: warm, supportive, and encouraging. For items marked source="CLINICAL", maintain clinical accuracy while keeping language accessible.
2. Preserve ALL placeholders like {name} exactly as-is — do not translate them.
3. Preserve JSON structure for arrays and objects (sampleSchedule, bedtimeRitual, tags).
4. For arrays of strings (tags, bedtimeRitual), translate each string individually.
5. For sampleSchedule objects, translate only the "activity" and "time" string fields; keep "durationMins" numeric.
6. Do NOT add any markdown code blocks or explanatory text — output ONLY valid JSON.
7. Output format: a JSON object using the exact keys provided (item_0, item_1, ...). Each value is the translated fields object.
Example: {"item_0": {"title": "...", "summary": "..."}, "item_1": {...}}`;

  const userPrompt = JSON.stringify(
    items.reduce((acc, item, idx) => { acc[`item_${idx}`] = item.fields; return acc; }, {} as Record<string, any>),
    null, 2,
  );

  const isOpenAI = config.apiUrl.includes('api.openai.com');
  const body: Record<string, unknown> = {
    model: config.model,
    messages: isOpenAI
      ? [{ role: 'system', content: systemPrompt }, { role: 'user', content: userPrompt }]
      : [{ role: 'user', content: `${systemPrompt}\n\n---\n\n${userPrompt}` }],
    temperature: 0.3,
  };
  if (isOpenAI) (body as any).response_format = { type: 'json_object' };
  else (body as any).max_tokens = config.maxTokens; // Prevent JSON truncation on large items

  let lastError: Error | undefined;
  for (let attempt = 0; attempt < config.maxRetries; attempt++) {
    try {
      const res = await fetch(config.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${config.apiKey}` },
        body: JSON.stringify(body),
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`);

      const data = (await res.json()) as { choices?: Array<{ message?: { content?: string } }>; error?: { message?: string } };
      if (data.error) throw new Error(data.error.message || 'API error');

      const content = data.choices?.[0]?.message?.content;
      if (!content) throw new Error('Empty AI response');

      const cleaned = content.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/i, '').trim();
      const parsed = JSON.parse(cleaned) as Record<string, Record<string, unknown>>;

      // Remap masked keys back to original IDs and validate all items
      const result: Record<string, Record<string, unknown>> = {};
      for (const item of items) {
        const masked = reverseMap[item.id];
        if (!parsed[masked]) throw new Error(`Missing translation for item ${item.id} (key: ${masked})`);
        result[item.id] = parsed[masked];
      }

      return result;
    } catch (err) {
      lastError = err as Error;
      console.warn(`    Retry ${attempt + 1}/${config.maxRetries}: ${lastError.message}`);
      if (attempt < config.maxRetries - 1) {
        await new Promise(r => setTimeout(r, config.retryDelayMs * (attempt + 1)));
      }
    }
  }
  throw lastError || new Error('Translation failed after max retries');
}

// ─── Prisma Insert ───

async function insertTranslated(
  prisma: any,
  contentType: string,
  englishRow: Record<string, unknown>,
  translated: Record<string, unknown>,
  locale: string,
) {
  const localeId = `${locale}_${englishRow.id}`;
  const preserve = PRESERVE_FIELDS[contentType] || [];

  // Build translated row: translated fields first, then preserve fields overlay (preserve wins)
  const row: Record<string, unknown> = { locale, ...translated };
  for (const key of preserve) {
    if (englishRow[key] !== undefined) row[key] = englishRow[key];
  }

  switch (contentType) {
    case 'ExpertAdviceCard':
      await prisma.expertAdviceCard.upsert({
        where: { id: localeId },
        update: row,
        create: { id: localeId, ...row },
      });
      break;
    case 'RoutineTemplate':
      await prisma.routineTemplate.upsert({
        where: { id: localeId },
        update: row,
        create: { id: localeId, ...row },
      });
      break;
    case 'MilestoneExpectation':
      await prisma.milestoneExpectation.upsert({
        where: { id: localeId },
        update: row,
        create: { id: localeId, ...row },
      });
      break;
    case 'StageContent':
      await prisma.stageContent.upsert({
        where: { id: localeId },
        update: row,
        create: { id: localeId, ...row },
      });
      break;
    default:
      throw new Error(`Unknown content type: ${contentType}`);
  }
}

// ─── Content Type Definitions ───

interface ContentTypeDef {
  model: string;    // Prisma model name (camelCase)
  tableName: string; // DB table name
  fields: string[];  // Fields to fetch from English and send for translation
}

const CONTENT_TYPES: Record<string, ContentTypeDef> = {
  ExpertAdviceCard: {
    model: 'expertAdviceCard',
    tableName: 'ExpertAdviceCard',
    fields: ['stageKey', 'category', 'source', 'priority', 'title', 'summary', 'content', 'tags'],
  },
  RoutineTemplate: {
    model: 'routineTemplate',
    tableName: 'RoutineTemplate',
    fields: ['stageKey', 'title', 'description', 'wakeWindowMins', 'napCount', 'totalNapHours', 'nightSleepHours', 'feedFrequency', 'sampleSchedule', 'bedtimeRitual', 'flexible'],
  },
  MilestoneExpectation: {
    model: 'milestoneExpectation',
    tableName: 'MilestoneExpectation',
    fields: ['stageKey', 'domain', 'status', 'title', 'description', 'ageRangeMinDays', 'ageRangeMaxDays', 'redFlagText', 'activityPrompt', 'xpReward'],
  },
  StageContent: {
    model: 'stageContent',
    tableName: 'StageContent',
    fields: ['stageKey', 'weekNumber', 'monthNumber', 'isPostBirth', 'summaryText', 'nurturingText', 'encouragementText', 'xpThreshold'],
  },
};

// ─── Main ───

async function main() {
  const config = parseArgs();
  const def = CONTENT_TYPES[config.contentType];
  if (!def) {
    console.error(`Unknown content type: ${config.contentType}`);
    console.error(`Valid types: ${Object.keys(CONTENT_TYPES).join(', ')}`);
    process.exit(1);
  }

  console.log('='.repeat(60));
  console.log(`Section Translate: ${config.contentType} → ${config.locale}`);
  console.log('='.repeat(60));
  console.log(`Model:      ${config.model}`);
  if (config.maxItems > 0) console.log(`Max items:  ${config.maxItems}`);
  console.log(`Max tokens: ${config.maxTokens}`);
  console.log(`Batch size: ${config.batchSize}`);
  console.log(`Delay:      ${config.batchDelayMs}ms`);
  console.log('='.repeat(60));

  const cache = new SectionCache(config.cacheFile);
  const prisma = new PrismaClient();

  try {
    // Fetch English items
    console.log(`\nFetching English ${config.contentType}...`);
    const englishItems = await (prisma as any)[def.model].findMany({
      where: { locale: 'en' },
      orderBy: { stageKey: 'asc' },
    });
    console.log(`  Found: ${englishItems.length} English items`);

    // Idempotency: check what's already done via cache + existing locale-prefix rows
    const safeLocale = config.locale.replace(/'/g, "''");
    const localePrefix = `${config.locale}_`;
    const existingIds = await prisma.$queryRawUnsafe<Array<{ id: string }>>(
      `SELECT id FROM "${def.tableName}" WHERE locale = '${safeLocale}' AND id LIKE '${localePrefix}%'`,
    );
    const existingEnglishIds = new Set(existingIds.map(r => r.id.startsWith(localePrefix) ? r.id.slice(localePrefix.length) : r.id));

    const alreadyDone = new Set<string>();
    for (const item of englishItems) {
      // Priority 1: cache hit
      const cached = cache.get(config.locale, config.contentType, item.id);
      if (cached) {
        alreadyDone.add(item.id);
        await insertTranslated(prisma, config.contentType, item, cached.translatedFields, config.locale);
        continue;
      }
      // Priority 2: existing locale-prefix row in DB
      if (existingEnglishIds.has(item.id)) {
        alreadyDone.add(item.id);
      }
    }
    console.log(`  Already done (cache + DB): ${alreadyDone.size} items`);

    const todo = englishItems.filter((item: any) => !alreadyDone.has(item.id));
    console.log(`  Already translated: ${englishItems.length - todo.length}`);
    console.log(`  To translate:       ${todo.length}`);

    if (todo.length === 0) {
      console.log(`\n✅ All ${config.contentType} items already translated for ${config.locale}.`);
      return;
    }

    // Process in batches
    const preserve = PRESERVE_FIELDS[config.contentType] || [];
    let translated = 0;
    let failed = 0;

    for (let i = 0; i < todo.length; i += config.batchSize) {
      const batch = todo.slice(i, i + config.batchSize);
      const batchNum = Math.floor(i / config.batchSize) + 1;
      const totalBatches = Math.ceil(todo.length / config.batchSize);

      console.log(`\n  [${batchNum}/${totalBatches}] Translating ${batch.length} items...`);

      // Prepare items for AI (strip preserve fields, keep rest)
      const aiItems = batch.map((item: any) => {
        const fields: Record<string, unknown> = {};
        for (const key of def.fields) {
          if (!preserve.includes(key) && item[key] !== undefined) {
            fields[key] = item[key];
          }
        }
        return { id: item.id, fields };
      });

      try {
        const result = await translateBatch(config, aiItems, config.locale, config.contentType);

        // Rehydrate preserve fields and insert
        for (const item of batch as any[]) {
          const translatedFields = result[item.id];
          if (!translatedFields) {
            console.warn(`    ⚠️  Missing translation for ${item.id}, skipping`);
            failed++;
            continue;
          }

          // Rehydrate preserve fields
          const rehydrated: Record<string, unknown> = { ...translatedFields };
          for (const key of preserve) {
            if (item[key] !== undefined) rehydrated[key] = item[key];
          }

          await insertTranslated(prisma, config.contentType, item, rehydrated, config.locale);

          // Update cache
          cache.set({
            englishId: item.id,
            locale: config.locale,
            contentType: config.contentType,
            translatedFields: rehydrated,
            createdAt: new Date().toISOString(),
          });
          translated++;
        }

        cache.save();
        console.log(`    ✅ ${batch.length}/${batch.length} inserted (cumulative: ${translated} done, ${failed} failed)`);

        // Early exit if --max-items limit reached
        if (config.maxItems > 0 && translated >= config.maxItems) {
          console.log(`    ⏹️  Reached --max-items limit (${config.maxItems}). Exiting early.`);
          break;
        }
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        console.error(`    ❌ Batch failed: ${msg}`);
        failed += batch.length;
      }

      if (config.batchDelayMs > 0 && i + config.batchSize < todo.length) {
        await new Promise(r => setTimeout(r, config.batchDelayMs));
      }
    }

    console.log(`\n${'─'.repeat(60)}`);
    console.log(`✅ ${config.contentType} complete: ${translated} translated, ${failed} failed`);
    console.log(`   Cache saved to: ${config.cacheFile}`);
    console.log(`${'─'.repeat(60)}`);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((err) => {
  console.error('\n❌ Fatal error:', err);
  process.exit(1);
});
