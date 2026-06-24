import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StageCalculatorService } from '../common/stage-calculator.service';

const REFLECTION_PROMPTS = [
  'What small moment brought you joy today?',
  'What are you most proud of today?',
  'How did your baby make you smile today?',
  'What felt like a win today, no matter how small?',
  'What would you love to remember about this day?',
  'How are you feeling right now, truly?',
  'What made you grateful today?',
];

/// Converts a stageKey like "born_month_5" to a friendly name like "5 Months".
function stageKeyToName(stageKey: string): string {
  if (stageKey.startsWith('born_month_')) {
    const m = parseInt(stageKey.replace('born_month_', ''));
    return `${m} Month${m > 1 ? 's' : ''}`;
  }
  if (stageKey.startsWith('born_week_')) {
    const w = parseInt(stageKey.replace('born_week_', ''));
    return `Week ${w}`;
  }
  if (stageKey.startsWith('preg_week_')) {
    const w = parseInt(stageKey.replace('preg_week_', ''));
    return `Week ${w}`;
  }
  return stageKey.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

@Injectable()
export class StageContentService {
  constructor(
    private prisma: PrismaService,
    private stageCalculator: StageCalculatorService,
  ) {}

  async getByStageKey(stageKey: string, babyMonId?: string | null) {
    // First try to find BabyMon-specific content (only if babyMonId provided)
    let content = null;
    if (babyMonId) {
      content = await this.prisma.stageContent.findFirst({
        where: { stageKey, babymonId: babyMonId },
      });
    }

    // Fall back to system default content (babymonId IS NULL or SYSTEM_BABYMON_ID)
    if (!content) {
      content = await this.prisma.stageContent.findFirst({
        where: {
          stageKey,
          OR: [
            { babymonId: null },
            { babymonId: '00000000-0000-0000-0000-000000000000' },
          ],
        },
      });
    }

    if (!content) {
      // Return default content instead of throwing — allows empty DB to work
      return {
        id: 'default',
        stageKey,
        babymonId: babyMonId || null,
        title: `${stageKeyToName(stageKey)} Insights`,
        summaryText: `Your BabyMon is growing! Track feedings, sleep, and milestones for personalized stage content.`,
        nurturingText: 'Keep tracking feedings, sleep, and milestones.',
        encouragementText: 'You\'re doing great!',
        expertTips: [],
        upcomingMilestone: null,
        reflectionPrompt: REFLECTION_PROMPTS[
          Math.floor(Date.now() / 86400000) % REFLECTION_PROMPTS.length
        ],
      };
    }

    // Enrich DB record with UI-required fields that the StageContent model
    // does not store (title, expertTips) so the frontend always has them.
    return {
      ...content,
      title: content.title ?? `${stageKeyToName(stageKey)} Insights`,
      expertTips: content.expertTips ?? [],
    };
  }

  async getForBabyMon(babyMonId: string, babyMonName?: string, traits?: string[]) {
    try {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Calculate stage key using shared service (single source of truth)
    const stageKey = StageCalculatorService.computeStageKey(babyMon);

    const content = await this.getByStageKey(stageKey, babyMonId);

    // Fetch upcoming milestone for this stage
    const upcomingMilestone = stageKey
      ? await this.prisma.milestoneExpectation.findFirst({
          where: { stageKey, status: 'EXPECTED' },
          orderBy: { domain: 'asc' },
        })
      : null;

    // Personalize content
    const name = babyMonName || babyMon.name;
    const personalizedContent = {
      ...content,
      summaryText: content.summaryText.replace(/{name}/g, name),
      nurturingText: content.nurturingText.replace(/{name}/g, name),
      encouragementText: content.encouragementText.replace(/{name}/g, name),
      upcomingMilestone: upcomingMilestone
        ? {
            domain: upcomingMilestone.domain,
            title: upcomingMilestone.title,
            activityPrompt: upcomingMilestone.activityPrompt,
            description: upcomingMilestone.description,
            xpReward: upcomingMilestone.xpReward,
          }
        : null,
      reflectionPrompt: REFLECTION_PROMPTS[
        Math.floor(Date.now() / 86400000) % REFLECTION_PROMPTS.length
      ],
    };

    return personalizedContent;
    } catch (e) {
      // Only return default content for NotFound-like errors; re-throw real errors
      if (e instanceof Error && e.message?.includes('not found')) {
        return {
          id: 'default',
          stageKey: 'born_week_1',
          babymonId: babyMonId,
          title: 'Stage Insights',
          summaryText: 'Your BabyMon is growing!',
          nurturingText: 'Keep tracking to see personalized content.',
          encouragementText: 'You\'re doing a great job!',
          expertTips: [],
          upcomingMilestone: null,
          reflectionPrompt: 'What small moment brought you joy today?',
        };
      }
      throw e;
    }
  }
}