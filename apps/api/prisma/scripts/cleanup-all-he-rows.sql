-- ============================================================================
-- CLEANUP v2: Handle duplicates first, then migrate old UUID → he_ prefix
-- ============================================================================

-- 1. StageContent
SELECT 'StageContent BEFORE:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix,
  COUNT(*) FILTER (WHERE id NOT LIKE 'he_%') as old_uuid
FROM "StageContent" WHERE locale = 'he';

-- Delete old UUID rows that already have a he_ prefix duplicate (matched by stageKey)
DELETE FROM "StageContent" WHERE locale = 'he' AND id NOT LIKE 'he_%'
  AND "stageKey" IN (
    SELECT "stageKey" FROM "StageContent" WHERE locale = 'he' AND id LIKE 'he_%'
  );

-- Now migrate remaining old UUID → he_ prefix (1:1 match only)
UPDATE "StageContent" he SET id = 'he_' || en.id
FROM "StageContent" en
WHERE he.locale = 'he' AND en.locale = 'en'
  AND he."stageKey" = en."stageKey"
  AND he.id NOT LIKE 'he_%'
  AND he."babymonId" IS NULL
  AND (SELECT COUNT(*) FROM "StageContent" en2 WHERE en2.locale = 'en' AND en2."stageKey" = he."stageKey") = 1;

-- Drop any remaining orphans
DELETE FROM "StageContent" WHERE locale = 'he' AND id NOT LIKE 'he_%';

SELECT 'StageContent AFTER:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix
FROM "StageContent" WHERE locale = 'he';


-- 2. RoutineTemplate
SELECT 'RoutineTemplate BEFORE:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix,
  COUNT(*) FILTER (WHERE id NOT LIKE 'he_%') as old_uuid
FROM "RoutineTemplate" WHERE locale = 'he';

DELETE FROM "RoutineTemplate" WHERE locale = 'he' AND id NOT LIKE 'he_%'
  AND "stageKey" IN (
    SELECT "stageKey" FROM "RoutineTemplate" WHERE locale = 'he' AND id LIKE 'he_%'
  );

UPDATE "RoutineTemplate" he SET id = 'he_' || en.id
FROM "RoutineTemplate" en
WHERE he.locale = 'he' AND en.locale = 'en'
  AND he."stageKey" = en."stageKey"
  AND he.id NOT LIKE 'he_%'
  AND (SELECT COUNT(*) FROM "RoutineTemplate" en2 WHERE en2.locale = 'en' AND en2."stageKey" = he."stageKey") = 1;

DELETE FROM "RoutineTemplate" WHERE locale = 'he' AND id NOT LIKE 'he_%';

SELECT 'RoutineTemplate AFTER:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix
FROM "RoutineTemplate" WHERE locale = 'he';


-- 3. MilestoneExpectation
SELECT 'MilestoneExpectation BEFORE:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix,
  COUNT(*) FILTER (WHERE id NOT LIKE 'he_%') as old_uuid
FROM "MilestoneExpectation" WHERE locale = 'he';

DELETE FROM "MilestoneExpectation" WHERE locale = 'he' AND id NOT LIKE 'he_%'
  AND ("stageKey", domain, title) IN (
    SELECT "stageKey", domain, title FROM "MilestoneExpectation" WHERE locale = 'he' AND id LIKE 'he_%'
  );

UPDATE "MilestoneExpectation" he SET id = 'he_' || en.id
FROM "MilestoneExpectation" en
WHERE he.locale = 'he' AND en.locale = 'en'
  AND he."stageKey" = en."stageKey"
  AND he.domain = en.domain
  AND he.title = en.title
  AND he.id NOT LIKE 'he_%'
  AND (SELECT COUNT(*) FROM "MilestoneExpectation" en2 WHERE en2.locale = 'en' AND en2."stageKey" = he."stageKey" AND en2.domain = he.domain AND en2.title = he.title) = 1;

DELETE FROM "MilestoneExpectation" WHERE locale = 'he' AND id NOT LIKE 'he_%';

SELECT 'MilestoneExpectation AFTER:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix
FROM "MilestoneExpectation" WHERE locale = 'he';


-- 4. ExpertAdviceCard
SELECT 'ExpertAdviceCard BEFORE:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix,
  COUNT(*) FILTER (WHERE id NOT LIKE 'he_%') as old_uuid
FROM "ExpertAdviceCard" WHERE locale = 'he';

DELETE FROM "ExpertAdviceCard" WHERE locale = 'he' AND id NOT LIKE 'he_%'
  AND ("stageKey", category, source, priority) IN (
    SELECT "stageKey", category, source, priority FROM "ExpertAdviceCard" WHERE locale = 'he' AND id LIKE 'he_%'
  );

UPDATE "ExpertAdviceCard" he SET id = 'he_' || en.id
FROM "ExpertAdviceCard" en
WHERE he.locale = 'he' AND en.locale = 'en'
  AND he."stageKey" = en."stageKey"
  AND he.category = en.category
  AND he.source = en.source
  AND he.priority = en.priority
  AND he.id NOT LIKE 'he_%'
  AND (SELECT COUNT(*) FROM "ExpertAdviceCard" en2 WHERE en2.locale = 'en' AND en2."stageKey" = he."stageKey" AND en2.category = he.category AND en2.source = he.source AND en2.priority = he.priority) = 1;

DELETE FROM "ExpertAdviceCard" WHERE locale = 'he' AND id NOT LIKE 'he_%';

SELECT 'ExpertAdviceCard AFTER:' as step, COUNT(*) as total,
  COUNT(*) FILTER (WHERE id LIKE 'he_%') as he_prefix
FROM "ExpertAdviceCard" WHERE locale = 'he';


-- ============================================================================
-- FINAL SUMMARY
-- ============================================================================
SELECT 'FINAL' as info,
  'ExpertAdviceCard' as tbl,
  (SELECT COUNT(*) FROM "ExpertAdviceCard" WHERE locale = 'en') as en,
  (SELECT COUNT(*) FROM "ExpertAdviceCard" WHERE locale = 'he') as he,
  (SELECT COUNT(*) FROM "ExpertAdviceCard" WHERE locale = 'en') - (SELECT COUNT(*) FROM "ExpertAdviceCard" WHERE locale = 'he') as missing
UNION ALL
SELECT 'FINAL', 'MilestoneExpectation',
  (SELECT COUNT(*) FROM "MilestoneExpectation" WHERE locale = 'en'),
  (SELECT COUNT(*) FROM "MilestoneExpectation" WHERE locale = 'he'),
  (SELECT COUNT(*) FROM "MilestoneExpectation" WHERE locale = 'en') - (SELECT COUNT(*) FROM "MilestoneExpectation" WHERE locale = 'he')
UNION ALL
SELECT 'FINAL', 'RoutineTemplate',
  (SELECT COUNT(*) FROM "RoutineTemplate" WHERE locale = 'en'),
  (SELECT COUNT(*) FROM "RoutineTemplate" WHERE locale = 'he'),
  (SELECT COUNT(*) FROM "RoutineTemplate" WHERE locale = 'en') - (SELECT COUNT(*) FROM "RoutineTemplate" WHERE locale = 'he')
UNION ALL
SELECT 'FINAL', 'StageContent',
  (SELECT COUNT(*) FROM "StageContent" WHERE locale = 'en'),
  (SELECT COUNT(*) FROM "StageContent" WHERE locale = 'he'),
  (SELECT COUNT(*) FROM "StageContent" WHERE locale = 'en') - (SELECT COUNT(*) FROM "StageContent" WHERE locale = 'he' AND "babymonId" IS NULL);
