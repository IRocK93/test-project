import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StageCalculatorService } from '../common/stage-calculator.service';
import { ErrorCode } from '../common/enums/error-code.enum';
import {
  findStageContentByLocale,
  findMilestoneExpectationsByLocale,
} from '../common/locale-content.helper';
import { getStageDefaults, getReflectionPrompt } from '../common/localized-strings';

@Injectable()
export class StageContentService {
  constructor(
    private prisma: PrismaService,
    private stageCalculator: StageCalculatorService,
  ) {}

  async getByStageKey(stageKey: string, babyMonId?: string | null, locale?: string) {
    const effectiveLocale = locale || 'en';
    const content = await findStageContentByLocale(
      this.prisma, stageKey, effectiveLocale, babyMonId,
    );

    if (!content) {
      // Return locale-aware default content — allows empty DB to work
      const defaults = getStageDefaults(effectiveLocale);
      return {
        id: 'default',
        stageKey,
        babymonId: babyMonId || null,
        title: defaults.stageTitle(stageKey),
        summaryText: defaults.summaryText,
        nurturingText: defaults.nurturingText,
        encouragementText: defaults.encouragementText,
        expertTips: [],
        upcomingMilestone: null,
        reflectionPrompt: getReflectionPrompt(effectiveLocale),
      };
    }

    // Enrich DB record with UI-required fields so the frontend always has them.
    const defaults = getStageDefaults(effectiveLocale);
    return {
      ...content,
      title: defaults.stageTitle(stageKey),
      expertTips: [],
    };
  }

  async getForBabyMon(babyMonId: string, locale?: string, babyMonName?: string, _traits?: string[]) {
    const effectiveLocale = locale || 'en';

    try {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
    });

    if (!babyMon) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    // Calculate stage key using shared service (single source of truth)
    const stageKey = StageCalculatorService.computeStageKey(babyMon);

    const content = await this.getByStageKey(stageKey, babyMonId, effectiveLocale);

    // Fetch upcoming milestone for this stage (locale-aware)
    const upcomingMilestone = stageKey
      ? (
          await findMilestoneExpectationsByLocale(
            this.prisma, stageKey, effectiveLocale, { status: 'EXPECTED', take: 1 },
          )
        )[0] ?? null
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
      reflectionPrompt: getReflectionPrompt(effectiveLocale),
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