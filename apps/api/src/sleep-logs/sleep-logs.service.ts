import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { CreateSleepLogDto, UpdateSleepLogDto } from './dto/sleep-log.dto';
import { buildHistoryDateFilter } from '../common/history-filter.helper';
import { trackDailyActivity } from '../common/daily-activity.helper';
import { ErrorCode } from '../common/enums/error-code.enum';

@Injectable()
export class SleepLogsService {
  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private xpService: XpService,
    private accessControl: AccessControlService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateSleepLogDto) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon || babyMon.deletedAt) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    await this.accessControl.checkAccess(userId, babymonId);

    const sleepLog = await this.prisma.sleepLog.create({
      data: {
        babymonId,
        authorUserId: userId,
        type: dto.type,
        startTime: new Date(dto.startTime),
        endTime: new Date(dto.endTime),
        notes: dto.notes,
        quality: dto.quality,
        syncStatus: 'SYNCED',
        xpAwarded: 5,
      },
    });

    // Award XP to the BabyMon
    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { currentXp: { increment: 5 } },
    });

    await trackDailyActivity(this.prisma, babymonId, 'sleepLog');

    await this.xpService.checkAndProcessLevelUp(babymonId);

    try {
      await this.badgesService.checkAndAwardBadges(babymonId, userId);
    } catch (e) {
      // Badge check is non-critical — the sleep log is already persisted
    }

    // Audit log
    await this.prisma.auditLog.create({
      data: { babymonId, actorUserId: userId, eventType: 'SLEEP_LOG_CREATED', payloadJson: JSON.stringify({ sleepLogId: sleepLog.id, type: sleepLog.type }) },
    });

    return sleepLog;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.accessControl.checkAccess(userId, babymonId);

    // FREE tier: only show limited history
    const dateFilter = await buildHistoryDateFilter(this.subscriptionsService, userId, 'startTime');

    const baseWhere = { babymonId, deletedAt: null, ...dateFilter };

    const [items, total] = await Promise.all([
      this.prisma.sleepLog.findMany({
        where: baseWhere,
        skip,
        take,
        orderBy: { startTime: 'desc' },
        include: {
          author: { select: { id: true, name: true, email: true } },
        },
      }),
      this.prisma.sleepLog.count({
        where: baseWhere,
      }),
    ]);

    return { items, total, skip, take };
  }

  async findOne(id: string, userId: string) {
    const sleepLog = await this.prisma.sleepLog.findUnique({
      where: { id },
      include: {
        author: { select: { id: true, name: true, email: true } },
      },
    });

    if (!sleepLog || sleepLog.deletedAt) {
      throw new NotFoundException({ message: 'Sleep log not found', code: ErrorCode.SLEEP_LOG_NOT_FOUND });
    }

    await this.accessControl.checkAccess(sleepLog.babymonId, userId);

    return sleepLog;
  }

  async update(id: string, userId: string, dto: UpdateSleepLogDto) {
    const sleepLog = await this.prisma.sleepLog.findUnique({
      where: { id },
    });

    if (!sleepLog || sleepLog.deletedAt) {
      throw new NotFoundException({ message: 'Sleep log not found', code: ErrorCode.SLEEP_LOG_NOT_FOUND });
    }

    await this.accessControl.checkAccess(sleepLog.babymonId, userId);

    const data: any = { ...dto };
    if (dto.startTime) data.startTime = new Date(dto.startTime);
    if (dto.endTime) data.endTime = new Date(dto.endTime);

    return this.prisma.sleepLog.update({
      where: { id },
      data,
      include: {
        author: { select: { id: true, name: true, email: true } },
      },
    });
  }

  async delete(id: string, userId: string) {
    const sleepLog = await this.prisma.sleepLog.findUnique({
      where: { id },
    });

    if (!sleepLog || sleepLog.deletedAt) {
      throw new NotFoundException({ message: 'Sleep log not found', code: ErrorCode.SLEEP_LOG_NOT_FOUND });
    }

    await this.accessControl.checkAccess(sleepLog.babymonId, userId);

    // Soft delete
    return this.prisma.sleepLog.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}