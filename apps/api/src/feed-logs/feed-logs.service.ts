import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { PrismaService } from '../prisma/prisma.service';
import { CreateFeedLogDto, UpdateFeedLogDto } from './dto/feed-log.dto';
import { buildHistoryDateFilter } from '../common/history-filter.helper';
import { trackDailyActivity } from '../common/daily-activity.helper';
import { isWithinUndoWindow } from '../common/undo-window.helper';
import { PROPOSAL_EXPIRY_DAYS } from '../common/app-constants';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';

@Injectable()
export class FeedLogsService {
  private readonly logger = new Logger(FeedLogsService.name);

  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private xpService: XpService,
    private accessControlService: AccessControlService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateFeedLogDto) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babymonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    const feedLog = await this.prisma.feedLog.create({
      data: {
        babymonId,
        authorUserId: userId,
        type: dto.type,
        amount: dto.amount,
        unit: dto.unit,
        notes: dto.notes,
        happenedAt: new Date(dto.happenedAt || dto.loggedAt || new Date()),
        localMediaRefs: dto.localMediaRefs || [],
        syncStatus: 'SYNCED',
        xpAwarded: 5,
      },
    });

    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { currentXp: { increment: 5 } },
    });

    await trackDailyActivity(this.prisma, babymonId, 'feedLog');

    await this.xpService.checkAndProcessLevelUp(babymonId);

    try {
      await this.badgesService.checkAndAwardBadges(babymonId, userId);
    } catch (e) {
      this.logger.warn({ err: e }, 'Badge check failed (non-critical)');
    }

    await this.prisma.auditLog.create({
      data: {
        babymonId: babymonId,
        actorUserId: userId,
        eventType: 'FEED_LOG_CREATED',
        payloadJson: JSON.stringify({ feedLogId: feedLog.id, type: feedLog.type }),
      },
    });

    return feedLog;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.verifyAccess(babymonId, userId);

    // FREE tier: only show limited history
    const dateFilter = await buildHistoryDateFilter(this.subscriptionsService, userId);

    const baseWhere = { babymonId, deletedAt: null, ...dateFilter };

    const [items, total] = await Promise.all([
      this.prisma.feedLog.findMany({
        where: baseWhere,
        orderBy: { happenedAt: 'desc' },
        skip,
        take,
        include: { author: { select: { id: true, name: true } } },
      }),
      this.prisma.feedLog.count({
        where: baseWhere,
      }),
    ]);

    return { items, total, skip, take };
  }

  async findOne(id: string, userId: string) {
    const feedLog = await this.prisma.feedLog.findUnique({
      where: { id },
      include: { author: { select: { id: true, name: true } } },
    });

    if (!feedLog || feedLog.deletedAt) {
      throw new NotFoundException({ message: 'Feed log not found', code: ErrorCode.FEED_LOG_NOT_FOUND });
    }

    await this.verifyAccess(feedLog.babymonId, userId);
    return feedLog;
  }

  async update(id: string, userId: string, dto: UpdateFeedLogDto) {
    const feedLog = await this.findOne(id, userId);

    if (isWithinUndoWindow(feedLog.createdAt)) {
      return this.prisma.feedLog.update({
        where: { id },
        data: {
          type: dto.type,
          amount: dto.amount,
          unit: dto.unit,
          notes: dto.notes,
          happenedAt: dto.happenedAt ? new Date(dto.happenedAt) : undefined,
          localMediaRefs: dto.localMediaRefs ? dto.localMediaRefs : undefined,
        },
      });
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);

    return this.prisma.entryChangeProposal.create({
      data: {
        babymonId: feedLog.babymonId,
        proposerUserId: userId,
        entryType: 'FEED_LOG',
        entryId: id,
        proposalType: 'EDIT',
        proposedPayloadJson: JSON.stringify(dto),
        expiresAt,
      },
    });
  }

  async delete(id: string, userId: string) {
    const feedLog = await this.prisma.feedLog.findUnique({
      where: { id },
      select: { id: true, babymonId: true, deletedAt: true, xpAwarded: true, createdAt: true },
    });

    if (!feedLog) throw new NotFoundException({ message: 'Feed log not found', code: ErrorCode.FEED_LOG_NOT_FOUND });

    // Idempotent: if already soft-deleted, return success
    if (feedLog.deletedAt) {
      return { message: 'Feed log already deleted' };
    }

    await this.verifyAccess(feedLog.babymonId, userId);

    // Always soft-delete the feed log
    await this.prisma.feedLog.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    await this.prisma.babyMon.update({
      where: { id: feedLog.babymonId },
      data: { currentXp: { decrement: feedLog.xpAwarded } },
    });

    // If outside the undo window, also create a proposal for partner review
    if (!isWithinUndoWindow(feedLog.createdAt)) {
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);

      // Fire-and-forget: create proposal in background, don't block the response
      this.prisma.entryChangeProposal.create({
        data: {
          babymonId: feedLog.babymonId,
          proposerUserId: userId,
          entryType: 'FEED_LOG',
          entryId: id,
          proposalType: 'DELETE',
          proposedPayloadJson: JSON.stringify({}),
          expiresAt,
        },
      }).catch((err) => this.logger.warn?.({ err }, 'Proposal creation failed (non-critical)'));
    }

    return { message: 'Feed log deleted successfully' };
  }

  private async verifyAccess(babymonId: string, userId: string) {
    const { hasAccess } = await this.accessControlService.checkAccess(userId, babymonId);
    if (!hasAccess) {
      throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });
    }
  }
}
