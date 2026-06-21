import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateFeedLogDto, UpdateFeedLogDto } from './dto/feed-log.dto';
import { isWithinUndoWindow } from '../common/undo-window.helper';
import { BadgesService } from '../badges/badges.service';
import { AccessControlService } from '../common/access-control.service';

@Injectable()
export class FeedLogsService {
  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private accessControlService: AccessControlService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateFeedLogDto) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babymonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    const feedLog = await this.prisma.feedLog.create({
      data: {
        babymonId,
        authorUserId: userId,
        type: dto.type,
        amount: dto.amount,
        unit: dto.unit,
        notes: dto.notes,
        happenedAt: new Date(dto.happenedAt),
        localMediaRefs: dto.localMediaRefs || [],
        syncStatus: 'SYNCED',
        xpAwarded: 5,
      },
    });

    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { currentXp: { increment: 5 } },
    });

    await this.badgesService.checkAndAwardBadges(babymonId, userId);

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

    const [items, total] = await Promise.all([
      this.prisma.feedLog.findMany({
        where: { babymonId, deletedAt: null },
        orderBy: { happenedAt: 'desc' },
        skip,
        take,
        include: { author: { select: { id: true, name: true } } },
      }),
      this.prisma.feedLog.count({
        where: { babymonId, deletedAt: null },
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
      throw new NotFoundException('Feed log not found');
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
    expiresAt.setDate(expiresAt.getDate() + 7);

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
    const feedLog = await this.findOne(id, userId);

    if (isWithinUndoWindow(feedLog.createdAt)) {
      await this.prisma.feedLog.update({
        where: { id },
        data: { deletedAt: new Date() },
      });

      await this.prisma.babyMon.update({
        where: { id: feedLog.babymonId },
        data: { currentXp: { decrement: feedLog.xpAwarded } },
      });

      return { message: 'Feed log deleted successfully' };
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    return this.prisma.entryChangeProposal.create({
      data: {
        babymonId: feedLog.babymonId,
        proposerUserId: userId,
        entryType: 'FEED_LOG',
        entryId: id,
        proposalType: 'DELETE',
        proposedPayloadJson: JSON.stringify({}),
        expiresAt,
      },
    });
  }

  private async verifyAccess(babymonId: string, userId: string) {
    const { hasAccess } = await this.accessControlService.checkAccess(userId, babymonId);
    if (!hasAccess) {
      throw new ForbiddenException('Access denied');
    }
  }
}
