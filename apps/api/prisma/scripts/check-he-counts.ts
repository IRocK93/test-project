const { PrismaClient } = require('@prisma/client');
const p = new PrismaClient();

(async () => {
  try {
    const tables = ['ExpertAdviceCard', 'MilestoneExpectation', 'RoutineTemplate', 'StageContent'];
    for (const table of tables) {
      const rows = await p.$queryRawUnsafe(
        `SELECT COUNT(*)::int as total, SUM(CASE WHEN id LIKE 'he_%' THEN 1 ELSE 0 END)::int as he_prefix FROM "${table}" WHERE locale = 'he'`
      );
      const en = await p.$queryRawUnsafe(
        `SELECT COUNT(*)::int as total FROM "${table}" WHERE locale = 'en'`
      );
      const he = rows[0];
      console.log(`${table}: ${he.he_prefix} he_prefix + ${he.total - he.he_prefix} old = ${he.total} total (EN: ${en[0].total}, missing: ${en[0].total - he.he_prefix})`);
    }
  } catch (e) {
    console.log('Error:', e.message);
  } finally {
    await p.$disconnect();
  }
})();
