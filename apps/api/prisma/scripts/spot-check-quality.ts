/**
 * spot-check-quality.ts
 *
 * Pulls 2-3 sample rows from each content table in both English and a target
 * locale, printing key translatable fields side by side for quality review.
 *
 * Usage:
 *   npx ts-node prisma/scripts/spot-check-quality.ts --locale he
 *   npx ts-node prisma/scripts/spot-check-quality.ts --locale ar
 */

import { PrismaClient } from '@prisma/client';

function parseLocale(): string {
  const idx = process.argv.indexOf('--locale');
  return idx >= 0 ? process.argv[idx + 1] : 'he';
}

function localeName(locale: string): string {
  const map: Record<string, string> = { he: 'Hebrew', ar: 'Arabic', es: 'Spanish', fr: 'French', de: 'German', it: 'Italian', pt: 'Portuguese', ru: 'Russian' };
  return map[locale] || locale.toUpperCase();
}

function detectScript(locale: string, text: string): boolean {
  const ranges: Record<string, RegExp> = {
    he: /[\u0590-\u05FF]/,
    ar: /[\u0600-\u06FF]/,
    ru: /[\u0400-\u04FF]/,
  };
  if (ranges[locale]) return ranges[locale].test(text);
  // Fallback: check it's not pure ASCII/English
  return /[^\x00-\x7F]/.test(text);
}

async function main() {
  const locale = parseLocale();
  const langName = localeName(locale);
  const prefix = `${locale}_`;

  const prisma = new PrismaClient();

  interface Sample { en: any; tr: any }
  const samples: Record<string, Sample[]> = {};
  function add(table: string, en: any, tr: any | null) {
    if (!tr) { console.warn(`  ⚠️  No ${langName} row for ${table} id=${en.id}`); return; }
    if (!samples[table]) samples[table] = [];
    samples[table].push({ en, tr });
  }

  // ── StageContent (2 samples) ──
  const enSC = await prisma.stageContent.findMany({
    where: { locale: 'en', babymonId: null },
    select: { id: true, stageKey: true, summaryText: true, nurturingText: true, encouragementText: true },
    orderBy: { stageKey: 'asc' },
    take: 3,
  });
  for (const row of enSC) {
    const trRow = await prisma.stageContent.findFirst({
      where: { locale, id: `${prefix}${row.id}` },
      select: { summaryText: true, nurturingText: true, encouragementText: true },
    });
    add('StageContent', row, trRow);
  }

  // ── MilestoneExpectation (2 samples) ──
  const enME = await prisma.milestoneExpectation.findMany({
    where: { locale: 'en' },
    select: { id: true, stageKey: true, domain: true, title: true, description: true, activityPrompt: true },
    orderBy: { stageKey: 'asc' },
    take: 3,
  });
  for (const row of enME) {
    const trRow = await prisma.milestoneExpectation.findFirst({
      where: { locale, id: `${prefix}${row.id}` },
      select: { title: true, description: true, activityPrompt: true },
    });
    add('MilestoneExpectation', row, trRow);
  }

  // ── RoutineTemplate (2 samples) ──
  const enRT = await prisma.routineTemplate.findMany({
    where: { locale: 'en' },
    select: { id: true, stageKey: true, title: true, description: true, feedFrequency: true },
    orderBy: { stageKey: 'asc' },
    take: 3,
  });
  for (const row of enRT) {
    const trRow = await prisma.routineTemplate.findFirst({
      where: { locale, id: `${prefix}${row.id}` },
      select: { title: true, description: true, feedFrequency: true },
    });
    add('RoutineTemplate', row, trRow);
  }

  // ── ExpertAdviceCard (3 samples, different categories) ──
  const enAC = await prisma.expertAdviceCard.findMany({
    where: { locale: 'en' },
    select: { id: true, stageKey: true, category: true, title: true, summary: true },
    orderBy: [{ category: 'asc' }, { stageKey: 'asc' }],
    take: 4,
  });
  for (const row of enAC) {
    const trRow = await prisma.expertAdviceCard.findFirst({
      where: { locale, id: `${prefix}${row.id}` },
      select: { title: true, summary: true },
    });
    add('ExpertAdviceCard', row, trRow);
  }

  // ── Print ──
  console.log('═══════════════════════════════════════════════════════════════');
  console.log(`  ${langName.toUpperCase()} TRANSLATION QUALITY SPOT CHECK`);
  console.log('═══════════════════════════════════════════════════════════════\n');

  for (const [table, items] of Object.entries(samples)) {
    console.log(`\n▌ ${table} — ${items.length} sample(s)`);
    console.log('═'.repeat(60));

    for (let i = 0; i < items.length; i++) {
      const { en, tr } = items[i];
      const stageKey = en.stageKey || '';
      const domain = en.domain ? ` | ${en.domain}` : '';
      const category = en.category ? ` | ${en.category}` : '';
      console.log(`\n  Sample ${i + 1}  (stageKey: ${stageKey}${domain}${category})`);
      console.log('  ' + '─'.repeat(56));

      for (const [key, enVal] of Object.entries(en)) {
        if (['id', 'stageKey', 'domain', 'category', 'babymonId'].includes(key)) continue;
        const trVal = (tr as any)[key];
        if (enVal == null && trVal == null) continue;
        const enStr = String(enVal).substring(0, 250);
        if (trVal == null) {
          console.log(`    [${key}] ⚠ MISSING`);
          console.log(`      EN: ${enStr}`);
          console.log(`      ${locale.toUpperCase()}: (null)`);
          console.log();
          continue;
        }
        const trStr = String(trVal).substring(0, 250);
        const hasScript = detectScript(locale, trStr);
        const flag = hasScript ? '✓' : '✗';
        console.log(`    [${key}] ${flag}`);
        console.log(`      EN: ${enStr}`);
        console.log(`      ${locale.toUpperCase()}: ${trStr}`);
        console.log();
      }
    }
  }

  console.log('═══════════════════════════════════════════════════════════════');
  console.log('  Spot check complete.');
  console.log('═══════════════════════════════════════════════════════════════');

  await prisma.$disconnect();
}

main().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
