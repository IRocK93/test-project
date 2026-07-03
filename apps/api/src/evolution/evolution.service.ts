import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BabyMonService } from '../baby-mon/baby-mon.service';
import { AccessControlService } from '../common/access-control.service';
import { ErrorCode } from '../common/enums/error-code.enum';
import { xpForNextLevel } from '../xp/xp.service';
import { StageCalculatorService } from '../common/stage-calculator.service';

@Injectable()
export class EvolutionService {
  constructor(
    private prisma: PrismaService,
    private babyMonService: BabyMonService,
    private accessControl: AccessControlService,
  ) {}

  async getEvolution(babyMonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
      include: {
        badges: { orderBy: { unlockedAt: 'desc' } },
      },
    });

    if (!babyMon) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    const { hasAccess } = await this.accessControl.checkAccess(userId, babyMonId);
    if (!hasAccess) {
      throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });
    }

    // Count non-deleted records manually — Prisma _count doesn't support where filters
    const [milestoneCount, feedLogCount, healthRecordCount, sleepLogCount] = await Promise.all([
      this.prisma.milestone.count({ where: { babymonId: babyMonId, deletedAt: null } }),
      this.prisma.feedLog.count({ where: { babymonId: babyMonId, deletedAt: null } }),
      this.prisma.healthRecord.count({ where: { babymonId: babyMonId, deletedAt: null } }),
      this.prisma.sleepLog.count({ where: { babymonId: babyMonId, deletedAt: null } }),
    ]);

    const stageInfo = await this.babyMonService.calculateCurrentStage(userId, babyMonId);

    // Calculate XP progress to next stage
    const xpNeeded = xpForNextLevel(babyMon.currentStage);
    const xpProgress = (babyMon.currentXp / xpNeeded) * 100;

    return {
      babyMon: {
        id: babyMon.id,
        name: babyMon.name,
        currentXp: babyMon.currentXp,
        currentStage: babyMon.currentStage,
        stageKey: stageInfo.stageKey,
      },
      badges: babyMon.badges,
      stageInfo,
      xpProgress: Math.min(xpProgress, 100),
      milestoneCount,
      feedLogCount,
      healthRecordCount,
      sleepLogCount,
      correctedAge: babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37
        ? StageCalculatorService.computeAge({ birthDate: babyMon.birthDate, gestationalAgeAtBirth: babyMon.gestationalAgeAtBirth })
        : null,
    };
  }

  async getEvolutionSummary(babyMonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
      include: {
        badges: true,
        _count: {
          select: {
            milestones: true,
            feedLogs: true,
            healthRecords: true,
          },
        },
      },
    });

    if (!babyMon) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    const { hasAccess } = await this.accessControl.checkAccess(userId, babyMonId);
    if (!hasAccess) {
      throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });
    }

    const totalEntries = babyMon._count.milestones + babyMon._count.feedLogs + babyMon._count.healthRecords;

    return {
      babyMonId: babyMon.id,
      name: babyMon.name,
      totalXp: babyMon.currentXp,
      totalBadges: babyMon.badges.length,
      totalEntries,
      milestones: babyMon._count.milestones,
      feedLogs: babyMon._count.feedLogs,
      healthRecords: babyMon._count.healthRecords,
    };
  }
}
