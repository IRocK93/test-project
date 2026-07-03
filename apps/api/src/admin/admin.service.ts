import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ErrorCode } from '../common/enums/error-code.enum';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // ─── Content Management ───

  async upsertAdviceCard(data: {
    stageKey: string;
    category: string;
    priority?: number;
    title: string;
    summary: string;
    content: string;
    source?: string;
    tags?: string[];
    locale: string;
  }) {
    const existing = await this.prisma.expertAdviceCard.findFirst({
      where: { stageKey: data.stageKey, locale: data.locale, title: data.title },
    });

    if (existing) {
      return this.prisma.expertAdviceCard.update({
        where: { id: existing.id },
        data: {
          category: data.category as any,
          priority: data.priority ?? 50,
          summary: data.summary,
          content: data.content,
          source: data.source as any,
          tags: data.tags ?? [],
        },
      });
    }

    return this.prisma.expertAdviceCard.create({
      data: {
        stageKey: data.stageKey,
        category: data.category as any,
        priority: data.priority ?? 50,
        title: data.title,
        summary: data.summary,
        content: data.content,
        source: (data.source as any) ?? 'DEVELOPMENT',
        tags: data.tags ?? [],
        locale: data.locale,
      },
    });
  }

  async upsertRoutineTemplate(data: {
    stageKey: string;
    title: string;
    description?: string;
    wakeWindowMins?: number;
    napCount?: number;
    totalNapHours?: number;
    nightSleepHours?: number;
    feedFrequency?: string;
    sampleSchedule?: any;
    bedtimeRitual?: any;
    flexible?: boolean;
    locale: string;
  }) {
    const existing = await (this.prisma.routineTemplate as any).findUnique({
      where: { stageKey_locale: { stageKey: data.stageKey, locale: data.locale } },
    });

    const payload = {
      title: data.title,
      description: data.description,
      wakeWindowMins: data.wakeWindowMins,
      napCount: data.napCount,
      totalNapHours: data.totalNapHours,
      nightSleepHours: data.nightSleepHours,
      feedFrequency: data.feedFrequency,
      sampleSchedule: data.sampleSchedule,
      bedtimeRitual: data.bedtimeRitual,
      flexible: data.flexible ?? false,
    };

    if (existing) {
      return (this.prisma.routineTemplate as any).update({
        where: { stageKey_locale: { stageKey: data.stageKey, locale: data.locale } },
        data: payload,
      });
    }

    return (this.prisma.routineTemplate as any).create({
      data: { ...payload, stageKey: data.stageKey, locale: data.locale },
    });
  }

  async upsertMilestoneExpectation(data: {
    stageKey: string;
    domain: string;
    title: string;
    description: string;
    status?: string;
    ageRangeMinDays?: number;
    ageRangeMaxDays?: number;
    redFlagText?: string;
    activityPrompt?: string;
    xpReward?: number;
    locale: string;
  }) {
    const existing = await this.prisma.milestoneExpectation.findFirst({
      where: {
        stageKey: data.stageKey,
        locale: data.locale,
        domain: data.domain as any,
        title: data.title,
      },
    });

    const payload = {
      domain: data.domain as any,
      description: data.description,
      status: (data.status as any) ?? 'EXPECTED',
      ageRangeMinDays: data.ageRangeMinDays,
      ageRangeMaxDays: data.ageRangeMaxDays,
      redFlagText: data.redFlagText,
      activityPrompt: data.activityPrompt,
      xpReward: data.xpReward ?? 10,
    };

    if (existing) {
      return this.prisma.milestoneExpectation.update({
        where: { id: existing.id },
        data: payload,
      });
    }

    return this.prisma.milestoneExpectation.create({
      data: {
        ...payload,
        stageKey: data.stageKey,
        title: data.title,
        locale: data.locale,
      },
    });
  }

  async upsertStageContent(data: {
    babymonId?: string;
    stageKey: string;
    weekNumber?: number;
    monthNumber?: number;
    isPostBirth?: boolean;
    summaryText: string;
    nurturingText: string;
    encouragementText: string;
    xpThreshold?: number;
    locale: string;
  }) {
    const babymonId = data.babymonId || null;
    const existing = await (this.prisma.stageContent as any).findFirst({
      where: { stageKey: data.stageKey, locale: data.locale, babymonId },
    });

    const payload = {
      weekNumber: data.weekNumber,
      monthNumber: data.monthNumber,
      isPostBirth: data.isPostBirth ?? false,
      summaryText: data.summaryText,
      nurturingText: data.nurturingText,
      encouragementText: data.encouragementText,
      xpThreshold: data.xpThreshold ?? 0,
    };

    if (existing) {
      return (this.prisma.stageContent as any).update({
        where: { id: existing.id },
        data: payload,
      });
    }

    return (this.prisma.stageContent as any).create({
      data: {
        ...payload,
        babymonId,
        stageKey: data.stageKey,
        locale: data.locale,
      },
    });
  }

  async listContent(
    type?: string,
    stageKey?: string,
    locale?: string,
    page = 1,
    limit = 20,
  ) {
    const skip = (page - 1) * limit;
    const where: any = {};
    if (stageKey) where.stageKey = stageKey;
    if (locale) where.locale = locale;

    switch (type) {
      case 'advice-card': {
        const [items, total] = await Promise.all([
          this.prisma.expertAdviceCard.findMany({ where, skip, take: limit, orderBy: { priority: 'desc' } }),
          this.prisma.expertAdviceCard.count({ where }),
        ]);
        return { type: 'advice-card', items, total, page, limit };
      }
      case 'routine-template': {
        const [items, total] = await Promise.all([
          (this.prisma.routineTemplate as any).findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
          (this.prisma.routineTemplate as any).count({ where }),
        ]);
        return { type: 'routine-template', items, total, page, limit };
      }
      case 'milestone-expectation': {
        const [items, total] = await Promise.all([
          this.prisma.milestoneExpectation.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
          this.prisma.milestoneExpectation.count({ where }),
        ]);
        return { type: 'milestone-expectation', items, total, page, limit };
      }
      case 'stage-content': {
        const [items, total] = await Promise.all([
          (this.prisma.stageContent as any).findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
          (this.prisma.stageContent as any).count({ where }),
        ]);
        return { type: 'stage-content', items, total, page, limit };
      }
      default: {
        // Return counts for all types when no type specified
        const [adviceCards, routineTemplates, milestoneExpectations, stageContents] = await Promise.all([
          this.prisma.expertAdviceCard.count({ where: { ...(stageKey && { stageKey }), ...(locale && { locale }) } }),
          (this.prisma.routineTemplate as any).count({ where: { ...(stageKey && { stageKey }), ...(locale && { locale }) } }),
          this.prisma.milestoneExpectation.count({ where: { ...(stageKey && { stageKey }), ...(locale && { locale }) } }),
          (this.prisma.stageContent as any).count({ where: { ...(stageKey && { stageKey }), ...(locale && { locale }) } }),
        ]);
        return {
          type: 'summary',
          counts: {
            adviceCards,
            routineTemplates,
            milestoneExpectations,
            stageContents,
          },
          filters: { stageKey, locale },
        };
      }
    }
  }

  async getAllUsers(page = 1, limit = 20, role?: string) {
    const skip = (page - 1) * limit;
    const where: any = {};

    if (role) {
      where.role = role;
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          isActive: true,
          verifiedAt: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      items: users,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getUserById(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        isActive: true,
        verifiedAt: true,
        createdAt: true,
        _count: {
          select: {
            babyMons: true,
            subscriptions: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException({ message: 'User not found', code: ErrorCode.ADMIN_USER_NOT_FOUND });
    }

    return user;
  }

  async updateUserStatus(userId: string, isActive: boolean) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({ message: 'User not found', code: ErrorCode.ADMIN_USER_NOT_FOUND });
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { isActive },
      select: {
        id: true,
        email: true,
        isActive: true,
      },
    });
  }

  async updateUserRole(userId: string, role: string) {
    if (!['USER', 'ADMIN'].includes(role)) {
      throw new ForbiddenException({ message: 'Invalid role', code: ErrorCode.ADMIN_UNAUTHORIZED });
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({ message: 'User not found', code: ErrorCode.ADMIN_USER_NOT_FOUND });
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { role },
      select: {
        id: true,
        email: true,
        role: true,
      },
    });
  }

  async getAuditLogs(page = 1, limit = 20, userId?: string, babymonId?: string) {
    const skip = (page - 1) * limit;
    const where: any = {};

    if (userId) {
      where.actorUserId = userId;
    }

    if (babymonId) {
      where.babymonId = babymonId;
    }

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          actor: {
            select: { id: true, email: true, name: true },
          },
        },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      items: logs,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getSystemStats() {
    const [
      totalUsers,
      activeUsers,
      totalBabyMons,
      totalMilestones,
      totalFeedLogs,
      totalHealthRecords,
      totalSubscriptions,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { isActive: true } }),
      this.prisma.babyMon.count({ where: { deletedAt: null } }),
      this.prisma.milestone.count(),
      this.prisma.feedLog.count(),
      this.prisma.healthRecord.count(),
      this.prisma.subscription.count({ where: { isActive: true } }),
    ]);

    return {
      users: {
        total: totalUsers,
        active: activeUsers,
      },
      babyMons: {
        total: totalBabyMons,
      },
      entries: {
        milestones: totalMilestones,
        feedLogs: totalFeedLogs,
        healthRecords: totalHealthRecords,
      },
      subscriptions: {
        active: totalSubscriptions,
      },
    };
  }
}
