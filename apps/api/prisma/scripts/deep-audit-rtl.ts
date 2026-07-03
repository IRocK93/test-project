/**
 * deep-audit-rtl.ts
 *
 * Deep quality audit for RTL locales: he, ar.
 *
 * Usage:
 *   npx ts-node prisma/scripts/deep-audit-rtl.ts --locale he
 *   npx ts-node prisma/scripts/deep-audit-rtl.ts  (all RTL locales)
 */

import { PrismaClient } from '@prisma/client';

const LOCALES = ['he', 'ar'];
const LOCALE_NAMES: Record<string, string> = { he: 'Hebrew', ar: 'Arabic' };

const SCRIPTS: Record<string, RegExp> = {
  he: /[\u0590-\u05FF]/,
  ar: /[\u0600-\u06FF]/,
};

function parseLocales(): string[] {
  const idx = process.argv.indexOf('--locale');
  return idx >= 0 ? [process.argv[idx + 1]] : LOCALES;
}

function hasScript(locale: string, text: string): boolean {
  if (!text || text.length < 5) return true;
  return SCRIPTS[locale]?.test(text) ?? true;
}

function isTruncated(tr: string, en: string): boolean {
  if (!tr || !en || en.length < 30) return false;
  if (tr.length < en.length * 0.4) return true;
  const t = tr.trim();
  const last = t[t.length - 1];
  if (last && !'.,!?)]}'.includes(last) && t.length < en.length * 0.7) return true;
  if (t.length > 10 && tr !== t) return true;
  return false;
}

async function audit(prisma: PrismaClient, locale: string) {
  const prefix = `${locale}_`;
  const name = LOCALE_NAMES[locale];

  console.log(`\n═══ ${name} (${locale}) ═══`);

  for (const table of ['StageContent', 'MilestoneExpectation', 'RoutineTemplate', 'ExpertAdviceCard'] as const) {
    const model = table[0].toLowerCase() + table.slice(1) as keyof PrismaClient;
    const enItems = await (prisma[model] as any).findMany({ where: { locale: 'en' } }) as any[];
    const trItems = await (prisma[model] as any).findMany({ where: { locale } }) as any[];

    const byKey = table === 'RoutineTemplate'
      ? new Map(trItems.map((i: any) => [i.stageKey, i]))
      : new Map(trItems.map((i: any) => [i.id.replace(prefix, ''), i]));

    let missing = 0, nullF = 0, truncs = 0, noScript = 0, jsonb = 0;

    for (const en of enItems) {
      const key = table === 'RoutineTemplate' ? en.stageKey : en.id;
      const tr = byKey.get(key) as any;
      if (!tr) { missing++; continue; }

      const fields = getFields(table);
      for (const f of fields) {
        const ev = String(en[f] || '');
        const tv = String(tr[f] || '');
        if (!tv && ev) { nullF++; continue; }
        if (isTruncated(tv, ev)) { truncs++; continue; }
        if (tv.length > 10 && !hasScript(locale, tv)) noScript++;
      }

      if (table === 'RoutineTemplate') {
        const es = en.sampleSchedule as any[] | null;
        const ts = tr.sampleSchedule as any[] | null;
        if (es && ts && es.length !== ts.length) jsonb++;
        const er = en.bedtimeRitual as string[] | null;
        const trit = tr.bedtimeRitual as string[] | null;
        if (er && trit && er.length !== trit.length) jsonb++;
      }
      if (table === 'ExpertAdviceCard') {
        const et = en.tags as string[] | null;
        const tt = tr.tags as string[] | null;
        if (et && tt && et.length !== tt.length) jsonb++;
      }
    }

    const issues = missing + nullF + truncs + noScript + jsonb;
    console.log(`  ${issues === 0 ? '✅' : '⚠️'} ${table.padEnd(22)} ${trItems.length}/${enItems.length}  missing:${missing} null:${nullF} trunc:${truncs} script:${noScript} jsonb:${jsonb}`);
  }
}

function getFields(t: string): string[] {
  switch (t) {
    case 'StageContent': return ['summaryText', 'nurturingText', 'encouragementText'];
    case 'MilestoneExpectation': return ['title', 'description', 'redFlagText', 'activityPrompt'];
    case 'RoutineTemplate': return ['title', 'description', 'feedFrequency'];
    case 'ExpertAdviceCard': return ['title', 'summary', 'content'];
    default: return [];
  }
}

async function main() {
  const locales = parseLocales();
  const prisma = new PrismaClient();
  try {
    for (const l of locales) await audit(prisma, l);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch(e => { console.error(e); process.exit(1); });
