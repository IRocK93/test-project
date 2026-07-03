-- Migration 0004: Convert BabyMon.stageStartType from String to StageStartType enum.
--
-- Source-of-truth reasoning: actual code uses three user-facing values — 'PLAN'
-- (pre-conception), 'INCUBATING' (pregnancy), 'BORN' (post-birth). Code values
-- are uppercase (DTO @ApiProperty() at apps/api/src/baby-mon/dto/baby-mon.dto.ts:9
-- enumerates exactly these three; stage-calculator and baby-mon service match).
--
-- Legacy variation: apps/api/prisma/seed.ts (now updated) used ``'IDEA'`` for
-- the system BabyMon, treated by stage-calculator as a synonym for PLAN.
-- Lowercase or ``'IDEA'`` values may exist in older rows from earlier code
-- revisions. The migration normalizes them all to the canonical enum.
--
-- Strategy:
--   1. Idempotently create the enum.
--   2. Uppercase any lowercase variants of valid values.
--   3. Coerce everything else (NULLs, 'IDEA', typos) to 'PLAN'. 'PLAN' is the
--      safest default: production code always gates on the date fields
--      (ideaDate / conceptionDate / birthDate), so PLAN can never misrepresent
--      a baby's actual state.
--   4. Cast the column to the enum using a USING expression.
--
-- Wrapped in a single transaction so failure of any step rolls back cleanly.

BEGIN;

-- 1. Create the enum (idempotent — re-running this migration won't fail).
DO $$ BEGIN
  CREATE TYPE "StageStartType" AS ENUM ('PLAN', 'INCUBATING', 'BORN');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- 2. Promote lowercase variants ('plan', 'incubating', 'born') to uppercase.
--    Trim handles whitespace / mixed-case corruption from legacy inserts.
UPDATE "BabyMon"
SET "stageStartType" = UPPER(TRIM("stageStartType"))
WHERE LOWER(TRIM(COALESCE("stageStartType", ''))) IN ('plan', 'incubating', 'born');

-- 3. Coerce everything else (NULLs, 'IDEA', typos) to 'PLAN'.
--    Whitelist check happens AFTER step 2 so the comparison sees uppercase.
--    Note: 'IDEA' (legacy seed default, no longer in the enum) becomes
--    'PLAN' irreversibly. They were already logically equivalent — see
--    apps/api/src/common/stage-calculator.service.ts:99, which maps both
--    to the 'idea' stage key. Information loss for the literal 'IDEA' is
--    acceptable because no production code path keyed off that value.
UPDATE "BabyMon"
SET "stageStartType" = 'PLAN'
WHERE "stageStartType" IS NULL
   OR "stageStartType" NOT IN ('PLAN', 'INCUBATING', 'BORN');

-- 4. Cast the column type. USING is required because PostgreSQL can't
--    implicitly cast TEXT → ENUM; we provide an explicit text-to-enum cast.
ALTER TABLE "BabyMon"
ALTER COLUMN "stageStartType" TYPE "StageStartType"
USING "stageStartType"::"StageStartType";

COMMIT;
</content>
</invoke>