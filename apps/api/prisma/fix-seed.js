const fs = require('fs');
const path = require('path');

const file = path.join(__dirname, 'seed-companion.ts');
let content = fs.readFileSync(file, 'utf8');

const replacements = [
  ["where: { stageKey: 'born_month_4' }, update: month4Routine, create: month4Routine",
   "where: { stageKey_locale: { stageKey: 'born_month_4', locale: 'en' } }, update: month4Routine, create: { ...month4Routine, locale: 'en' }"],
  ["where: { stageKey: 'born_month_5' }, update: month5Routine, create: month5Routine",
   "where: { stageKey_locale: { stageKey: 'born_month_5', locale: 'en' } }, update: month5Routine, create: { ...month5Routine, locale: 'en' }"],
  ["where: { stageKey: 'born_month_7' }, update: month7Routine, create: month7Routine",
   "where: { stageKey_locale: { stageKey: 'born_month_7', locale: 'en' } }, update: month7Routine, create: { ...month7Routine, locale: 'en' }"],
  ["where: { stageKey: 'born_month_8' }, update: month8Routine, create: month8Routine",
   "where: { stageKey_locale: { stageKey: 'born_month_8', locale: 'en' } }, update: month8Routine, create: { ...month8Routine, locale: 'en' }"],
  ["where: { stageKey: 'preg_week_8' }, update: pregRoutineWeek8, create: pregRoutineWeek8",
   "where: { stageKey_locale: { stageKey: 'preg_week_8', locale: 'en' } }, update: pregRoutineWeek8, create: { ...pregRoutineWeek8, locale: 'en' }"],
  ["where: { stageKey: 'preg_week_20' }, update: pregRoutineWeek20, create: pregRoutineWeek20",
   "where: { stageKey_locale: { stageKey: 'preg_week_20', locale: 'en' } }, update: pregRoutineWeek20, create: { ...pregRoutineWeek20, locale: 'en' }"],
  ["where: { stageKey: 'preg_week_32' }, update: pregRoutineWeek32, create: pregRoutineWeek32",
   "where: { stageKey_locale: { stageKey: 'preg_week_32', locale: 'en' } }, update: pregRoutineWeek32, create: { ...pregRoutineWeek32, locale: 'en' }"],
];

let count = 0;
for (const [oldStr, newStr] of replacements) {
  if (content.includes(oldStr)) {
    content = content.replace(oldStr, newStr);
    count++;
  }
}

fs.writeFileSync(file, content);

const remaining = (content.match(/routineTemplate\.upsert\(\{ where:\s*\{\s*stageKey:/g) || []).length;
console.log(`Fixed ${count} upserts. Remaining stageKey-only upserts: ${remaining}`);
