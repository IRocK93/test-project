import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { StageCalculatorService } from '../common/stage-calculator.service';

// Trimester boundaries (weeks)
const FIRST_TRIMESTER_END = 13;
const SECOND_TRIMESTER_END = 27;

// Infant stage boundaries (months)
const EARLY_INFANT_END = 4;
const MID_INFANT_END = 8;
const LATE_INFANT_END = 12;

@Injectable()
export class CompanionService {
  constructor(
    private prisma: PrismaService,
    private stageCalculator: StageCalculatorService,
  ) {}

  async getDailyBrief(babyMonId: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
      select: { id: true, name: true, stageStartType: true, birthDate: true, conceptionDate: true, currentStage: true, gender: true },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const stageKey = StageCalculatorService.computeStageKey(babyMon);
    const stageName = this.getStageName(stageKey, babyMon);

    // Get today's advice card (rotates by priority)
    const tipOfDay = await this.prisma.expertAdviceCard.findFirst({
      where: { stageKey },
      orderBy: { priority: 'desc' },
    });

    // Get routine preview
    const routineTemplate = await this.prisma.routineTemplate.findUnique({
      where: { stageKey },
    });

    // Get milestone summary
    const upcomingMilestones = await this.prisma.milestoneExpectation.findMany({
      where: { stageKey, status: 'EXPECTED' },
      take: 3,
      orderBy: { domain: 'asc' },
    });

    // Get today's user routine if exists
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const userRoutine = await this.prisma.userRoutine.findUnique({
      where: {
        babyMonId_routineDate: { babyMonId, routineDate: today },
      },
      include: { template: true },
    });

    return {
      babyName: babyMon.name,
      gender: babyMon.gender,
      age: StageCalculatorService.computeAge(babyMon),
      stageKey,
      stageName,
      focusOfWeek: tipOfDay?.title || 'Your baby is growing and developing every day',
      tipOfDay: tipOfDay ? {
        title: tipOfDay.title,
        summary: tipOfDay.summary,
        category: tipOfDay.category,
        source: tipOfDay.source,
      } : null,
      routinePreview: routineTemplate ? {
        title: routineTemplate.title,
        wakeWindowMins: routineTemplate.wakeWindowMins,
        napCount: routineTemplate.napCount,
        feedFrequency: routineTemplate.feedFrequency,
        sampleSchedule: routineTemplate.sampleSchedule,
      } : null,
      upcomingMilestones: upcomingMilestones.map(m => ({
        domain: m.domain,
        title: m.title,
        description: m.description,
        activityPrompt: m.activityPrompt,
      })),
      userRoutine: userRoutine ? {
        completedSteps: userRoutine.completedSteps,
        customizations: userRoutine.customizations,
      } : null,
    };
  }

  async getRoutine(babyMonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
      select: { id: true, stageStartType: true, birthDate: true, conceptionDate: true },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const stageKey = StageCalculatorService.computeStageKey(babyMon);
    const template = await this.prisma.routineTemplate.findUnique({
      where: { stageKey },
    });
    if (!template) {
      return {
        stageKey,
        message: 'No routine template available yet for this stage. Check back soon!',
        template: null,
        userRoutine: null,
      };
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let userRoutine = await this.prisma.userRoutine.findUnique({
      where: { babyMonId_routineDate: { babyMonId, routineDate: today } },
    });

    if (!userRoutine) {
      userRoutine = await this.prisma.userRoutine.create({
        data: {
          userId,
          babyMonId,
          routineDate: today,
          templateId: template.id,
          customizations: {} as any,
          completedSteps: [] as any,
        } as any,
      });
    }

    return {
      template: {
        id: template.id,
        title: template.title,
        description: template.description,
        wakeWindowMins: template.wakeWindowMins,
        napCount: template.napCount,
        totalNapHours: template.totalNapHours,
        nightSleepHours: template.nightSleepHours,
        feedFrequency: template.feedFrequency,
        sampleSchedule: template.sampleSchedule,
        bedtimeRitual: template.bedtimeRitual,
      },
      userRoutine: {
        id: userRoutine.id,
        completedSteps: this.normalizeJsonArray(userRoutine.completedSteps),
        customizations: userRoutine.customizations,
      },
    };
  }

  async completeRoutineStep(babyMonId: string, stepLabel: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const userRoutine = await this.prisma.userRoutine.findUnique({
      where: { babyMonId_routineDate: { babyMonId, routineDate: today } },
    });
    if (!userRoutine) throw new NotFoundException('No routine found for today');

    const steps = this.normalizeJsonArray(userRoutine.completedSteps);
    const completedSteps = steps.includes(stepLabel)
      ? steps.filter((s: string) => s !== stepLabel)
      : [...steps, stepLabel];

    return this.prisma.userRoutine.update({
      where: { id: userRoutine.id },
      data: { completedSteps },
    });
  }

  async syncRoutineSteps(babyMonId: string, completedSteps: string[]) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    let userRoutine = await this.prisma.userRoutine.findUnique({
      where: { babyMonId_routineDate: { babyMonId, routineDate: today } },
    });
    if (!userRoutine) {
      userRoutine = await this.prisma.userRoutine.create({
        data: { babyMonId, routineDate: today, templateId: 'default', userId: '', completedSteps },
      });
    } else {
      userRoutine = await this.prisma.userRoutine.update({
        where: { id: userRoutine.id },
        data: { completedSteps },
      });
    }
    return { completedSteps: userRoutine.completedSteps };
  }

  async getMilestones(babyMonId: string, status?: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
      select: { id: true, stageStartType: true, birthDate: true, conceptionDate: true },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const stageKey = StageCalculatorService.computeStageKey(babyMon);
    const where: Record<string, unknown> = { stageKey };
    if (status && status !== 'ACHIEVED') {
      where.status = status;
    }

    const expectations = await this.prisma.milestoneExpectation.findMany({
      where,
      orderBy: [{ domain: 'asc' }, { title: 'asc' }],
    });

    // Get achieved milestones
    const achieved = await this.prisma.babyMilestone.findMany({
      where: { babyMonId },
      select: { expectationId: true, achievedAt: true },
    });

    const achievedIds = new Set(achieved.map(a => a.expectationId));

    // Group by domain
    const grouped: Record<string, Record<string, unknown>[]> = {};
    for (const m of expectations) {
      if (!grouped[m.domain]) grouped[m.domain] = [];
      grouped[m.domain].push({
        id: m.id,
        title: m.title,
        description: m.description,
        status: achievedIds.has(m.id) ? 'ACHIEVED' : m.status,
        redFlagText: m.redFlagText,
        activityPrompt: m.activityPrompt,
        xpReward: m.xpReward,
        achievedAt: achieved.find(a => a.expectationId === m.id)?.achievedAt || null,
      });
    }

    return { domains: grouped };
  }

  async achieveMilestone(babyMonId: string, expectationId: string, userId: string) {
    const existing = await this.prisma.babyMilestone.findUnique({
      where: { babyMonId_expectationId: { babyMonId, expectationId } },
    });
    if (existing) return { alreadyAchieved: true };

    const milestone = await this.prisma.babyMilestone.create({
      data: { babyMonId, expectationId },
    });

    const expectation = await this.prisma.milestoneExpectation.findUnique({
      where: { id: expectationId },
    });

    if (expectation?.xpReward) {
      await this.prisma.babyMon.update({
        where: { id: babyMonId },
        data: { currentXp: { increment: expectation.xpReward } },
      });
    }

    return { achieved: true, xpAwarded: expectation?.xpReward || 0 };
  }

  async unachieveMilestone(babyMonId: string, expectationId: string) {
    const existing = await this.prisma.babyMilestone.findUnique({
      where: { babyMonId_expectationId: { babyMonId, expectationId } },
    });
    if (!existing) return { notFound: true };

    await this.prisma.babyMilestone.delete({
      where: { id: existing.id },
    });

    const expectation = await this.prisma.milestoneExpectation.findUnique({
      where: { id: expectationId },
    });
    if (expectation?.xpReward) {
      await this.prisma.babyMon.update({
        where: { id: babyMonId },
        data: { currentXp: { decrement: expectation.xpReward } },
      });
    }

    return { unachieved: true };
  }

  async getAdvice(babyMonId: string, category?: string, skip = 0, take = 10) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
      select: { id: true, stageStartType: true, birthDate: true, conceptionDate: true },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const stageKey = StageCalculatorService.computeStageKey(babyMon);
    const where: Record<string, unknown> = { stageKey };
    if (category) where.category = category;

    const [items, total] = await Promise.all([
      this.prisma.expertAdviceCard.findMany({
        where,
        orderBy: { priority: 'desc' },
        skip,
        take,
      }),
      this.prisma.expertAdviceCard.count({ where }),
    ]);

    return { items, total, skip, take };
  }

  async toggleBookmarkAdvice(userId: string, babyMonId: string, adviceCardId: string) {
    const existing = await this.prisma.savedAdvice.findUnique({
      where: { userId_adviceCardId: { userId, adviceCardId } },
    });
    if (existing) {
      await this.prisma.savedAdvice.delete({ where: { id: existing.id } });
      return { bookmarked: false };
    }
    await this.prisma.savedAdvice.create({
      data: { userId, babyMonId, adviceCardId },
    });
    return { bookmarked: true };
  }

  async getBookmarkedAdviceIds(userId: string): Promise<string[]> {
    const saved = await this.prisma.savedAdvice.findMany({
      where: { userId },
      select: { adviceCardId: true },
      take: 100,
    });
    return saved.map(s => s.adviceCardId);
  }

  async rateAdvice(userId: string, adviceCardId: string, helpful: boolean) {
    const existing = await this.prisma.adviceRating.findUnique({
      where: { userId_adviceCardId: { userId, adviceCardId } },
    });
    if (existing) {
      await this.prisma.adviceRating.update({
        where: { id: existing.id },
        data: { helpful },
      });
      return { rated: true, helpful, updated: true };
    }
    await this.prisma.adviceRating.create({
      data: { userId, adviceCardId, rating: 0, helpful },
    });
    return { rated: true, helpful, updated: false };
  }

  // ─── Helpers ───

  /** Normalize a JSON column value (string or already-parsed array) to a plain array. */
  private normalizeJsonArray(value: unknown): string[] {
    if (Array.isArray(value)) return value as string[];
    if (typeof value === 'string') {
      try {
        const parsed = JSON.parse(value);
        if (Array.isArray(parsed)) return parsed as string[];
      } catch { /* fall through */ }
    }
    return [];
  }

  // Stage calculation and age display delegated to StageCalculatorService
  // (see common/stage-calculator.service.ts — computeStageKey, computeAge)

  private getStageName(stageKey: string, babyMon: { name?: string | null; stageStartType?: string | null }): string {
    if (stageKey.startsWith('preg_week_')) {
      const week = parseInt(stageKey.replace('preg_week_', ''));
      if (week <= FIRST_TRIMESTER_END) return 'First Trimester';
      if (week <= SECOND_TRIMESTER_END) return 'Second Trimester';
      return 'Third Trimester';
    }
    if (stageKey.startsWith('born_week_')) {
      return 'Newborn';
    }
    if (stageKey.startsWith('born_month_')) {
      const month = parseInt(stageKey.replace('born_month_', ''));
      if (month <= EARLY_INFANT_END) return 'Early Infant';
      if (month <= MID_INFANT_END) return 'Mid Infant';
      if (month <= LATE_INFANT_END) return 'Late Infant';
      if (month <= 18) return 'Young Toddler';
      return 'Older Toddler';
    }
    if (babyMon.stageStartType === 'PLAN') return 'Pre-conception';
    return 'Getting Started';
  }
}
