import { PrismaService } from '../prisma/prisma.service';

// TODO: Remove `as any` casts once Prisma client is regenerated on this machine.
// The casts are needed because the Prisma client types are stale after schema
// changes (locale columns + composite unique keys). Run `npx prisma generate`
// when the Windows file-lock issue is resolved.

/**
 * Queries ExpertAdviceCards for a stageKey, preferring the requested locale.
 * If no cards exist in the requested locale, falls back to English.
 */
export async function findAdviceCardsByLocale(
  prisma: PrismaService,
  stageKey: string,
  locale: string,
  options: { category?: string; skip?: number; take?: number } = {},
) {
  const where = { stageKey, locale } as Record<string, unknown>;
  if (options.category) where.category = options.category;

  let items = await prisma.expertAdviceCard.findMany({
    where,
    orderBy: { priority: 'desc' },
    skip: options.skip ?? 0,
    take: options.take ?? 100,
  });

  // Fallback to English if no content in requested locale
  if (items.length === 0 && locale !== 'en') {
    const enWhere = { stageKey, locale: 'en' } as Record<string, unknown>;
    if (options.category) enWhere.category = options.category;
    items = await prisma.expertAdviceCard.findMany({
      where: enWhere,
      orderBy: { priority: 'desc' },
      skip: options.skip ?? 0,
      take: options.take ?? 100,
    });
  }

  return items;
}

/**
 * Counts ExpertAdviceCards for a stageKey, using the same locale fallback logic.
 */
export async function countAdviceCardsByLocale(
  prisma: PrismaService,
  stageKey: string,
  locale: string,
  options: { category?: string } = {},
) {
  const where = { stageKey, locale } as Record<string, unknown>;
  if (options.category) where.category = options.category;

  let count = await prisma.expertAdviceCard.count({ where });

  if (count === 0 && locale !== 'en') {
    const enWhere = { stageKey, locale: 'en' } as Record<string, unknown>;
    if (options.category) enWhere.category = options.category;
    count = await prisma.expertAdviceCard.count({ where: enWhere });
  }

  return count;
}

/**
 * Finds a RoutineTemplate by stageKey and locale, falling back to English.
 */
export async function findRoutineTemplateByLocale(
  prisma: PrismaService,
  stageKey: string,
  locale: string,
) {
  let template = await (prisma.routineTemplate as any).findUnique({
    where: { stageKey_locale: { stageKey, locale } },
  });

  if (!template && locale !== 'en') {
    template = await (prisma.routineTemplate as any).findUnique({
      where: { stageKey_locale: { stageKey, locale: 'en' } },
    });
  }

  return template;
}

/**
 * Finds MilestoneExpectations by stageKey and locale, falling back to English.
 */
export async function findMilestoneExpectationsByLocale(
  prisma: PrismaService,
  stageKey: string,
  locale: string,
  options: { status?: string; take?: number } = {},
) {
  const where: Record<string, unknown> = { stageKey, locale };
  if (options.status && options.status !== 'ACHIEVED') {
    where.status = options.status;
  }

  let items = await prisma.milestoneExpectation.findMany({
    where,
    ...(options.take ? { take: options.take } : {}),
    orderBy: [{ domain: 'asc' }, { title: 'asc' }],
  });

  if (items.length === 0 && locale !== 'en') {
    const enWhere: Record<string, unknown> = { stageKey, locale: 'en' };
    if (options.status && options.status !== 'ACHIEVED') {
      enWhere.status = options.status;
    }
    items = await prisma.milestoneExpectation.findMany({
      where: enWhere,
      ...(options.take ? { take: options.take } : {}),
      orderBy: [{ domain: 'asc' }, { title: 'asc' }],
    });
  }

  return items;
}

/**
 * Finds StageContent by stageKey (and optional babyMonId) and locale,
 * falling back to English.
 */
export async function findStageContentByLocale(
  prisma: PrismaService,
  stageKey: string,
  locale: string,
  babyMonId?: string | null,
) {
  // Try babyMon-specific content first
  if (babyMonId) {
    const babyMonContent = await (prisma.stageContent as any).findFirst({
      where: { stageKey, babymonId: babyMonId, locale },
    });
    if (babyMonContent) return babyMonContent;

    if (locale !== 'en') {
      const babyMonEn = await (prisma.stageContent as any).findFirst({
        where: { stageKey, babymonId: babyMonId, locale: 'en' },
      });
      if (babyMonEn) return babyMonEn;
    }
  }

  // Fall back to system default content
  let content = await (prisma.stageContent as any).findFirst({
    where: {
      stageKey,
      locale,
      OR: [
        { babymonId: null },
        { babymonId: '00000000-0000-0000-0000-000000000000' },
      ],
    },
  });

  if (!content && locale !== 'en') {
    content = await (prisma.stageContent as any).findFirst({
      where: {
        stageKey,
        locale: 'en',
        OR: [
          { babymonId: null },
          { babymonId: '00000000-0000-0000-0000-000000000000' },
        ],
      },
    });
  }

  return content;
}
