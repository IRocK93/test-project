import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BabyMonService } from '../baby-mon/baby-mon.service';
import { AccessControlService } from '../common/access-control.service';

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
      include: { badges: { orderBy: { unlockedAt: 'desc' } } },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    const { hasAccess } = await this.accessControl.checkAccess(userId, babyMonId);
    if (!hasAccess) {
      throw new ForbiddenException('Access denied');
    }

    const stageInfo = await this.babyMonService.calculateCurrentStage(babyMonId);

    // Calculate XP progress to next stage
    const xpForNextLevel = (babyMon.currentStage + 1) * 100;
    const xpProgress = (babyMon.currentXp / xpForNextLevel) * 100;

    return {
      babyMon: {
        id: babyMon.id,
        name: babyMon.name,
        currentXp: babyMon.currentXp,
        currentStage: babyMon.currentStage,
      },
      badges: babyMon.badges,
      stageInfo,
      xpProgress: Math.min(xpProgress, 100),
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
      throw new NotFoundException('BabyMon not found');
    }

    const { hasAccess } = await this.accessControl.checkAccess(userId, babyMonId);
    if (!hasAccess) {
      throw new ForbiddenException('Access denied');
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
