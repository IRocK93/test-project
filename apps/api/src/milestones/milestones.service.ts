import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMilestoneDto, UpdateMilestoneDto } from './dto/milestone.dto';
import { isWithinUndoWindow } from '../common/undo-window.helper';
import { PROPOSAL_EXPIRY_DAYS } from '../common/app-constants';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { buildHistoryDateFilter } from '../common/history-filter.helper';
import { trackDailyActivity } from '../common/daily-activity.helper';

@Injectable()
export class MilestonesService {
  private readonly logger = new Logger(MilestonesService.name);

  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private xpService: XpService,
    private accessControl: AccessControlService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateMilestoneDto) {
    // Verify BabyMon exists and user has access
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babymonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });
    }

    const milestone = await this.prisma.milestone.create({
      data: {
        babymonId,
        authorUserId: userId,
        title: dto.title,
        notes: dto.notes,
        happenedAt: new Date(dto.happenedAt),
        localMediaRefs: dto.localMediaRefs || [],
        isCustom: dto.isCustom || false,
        syncStatus: 'SYNCED',
        xpAwarded: 10,
      },
    });

    // Track daily activity for streak badges
    await trackDailyActivity(this.prisma, babymonId, 'milestone');

    // Award XP and check for level-up
    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { currentXp: { increment: 10 } },
    });

    // Process level-up (may advance multiple stages if XP exceeds thresholds)
    await this.xpService.checkAndProcessLevelUp(babymonId);

    try {
      await this.badgesService.checkAndAwardBadges(babymonId, userId);
    } catch (e) {
      this.logger.warn({ err: e }, 'Badge check failed (non-critical)');
    }

    // Audit log
    await this.prisma.auditLog.create({
      data: {
        babymonId: babymonId,
        actorUserId: userId,
        eventType: 'MILESTONE_CREATED',
        payloadJson: JSON.stringify({ milestoneId: milestone.id, title: milestone.title }),
      },
    });

    return milestone;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.verifyAccess(babymonId, userId);

    // FREE tier: only show limited history
    const dateFilter = await buildHistoryDateFilter(this.subscriptionsService, userId);

    const baseWhere = { babymonId, deletedAt: null, ...dateFilter };

    const [items, total] = await Promise.all([
      this.prisma.milestone.findMany({
        where: baseWhere,
        orderBy: { happenedAt: 'desc' },
        skip,
        take,
        include: {
          author: {
            select: { id: true, name: true },
          },
        },
      }),
      this.prisma.milestone.count({
        where: baseWhere,
      }),
    ]);

    return { items, total, skip, take };
  }

  async findOne(id: string, userId: string) {
    const milestone = await this.prisma.milestone.findUnique({
      where: { id },
      include: {
        author: {
          select: { id: true, name: true },
        },
      },
    });

    if (!milestone || milestone.deletedAt) {
      throw new NotFoundException({ message: 'Milestone not found', code: ErrorCode.MILESTONE_NOT_FOUND });
    }

    await this.verifyAccess(milestone.babymonId, userId);

    return milestone;
  }

  async update(id: string, userId: string, dto: UpdateMilestoneDto) {
    const milestone = await this.findOne(id, userId);

    // Check if within 10-minute undo window
    if (isWithinUndoWindow(milestone.createdAt)) {
      // Allow direct update
      return this.prisma.milestone.update({
        where: { id },
        data: {
          title: dto.title,
          notes: dto.notes,
          happenedAt: dto.happenedAt ? new Date(dto.happenedAt) : undefined,
          localMediaRefs: dto.localMediaRefs ? dto.localMediaRefs : undefined,
        },
      });
    }

    // Create proposal for co-parent approval
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);

    return this.prisma.entryChangeProposal.create({
      data: {
        babymonId: milestone.babymonId,
        proposerUserId: userId,
        entryType: 'MILESTONE',
        entryId: id,
        proposalType: 'EDIT',
        proposedPayloadJson: JSON.stringify(dto),
        expiresAt,
      },
    });
  }

  async delete(id: string, userId: string) {
    const milestone = await this.prisma.milestone.findUnique({
      where: { id },
      select: { id: true, babymonId: true, deletedAt: true, xpAwarded: true, createdAt: true },
    });

    if (!milestone) throw new NotFoundException({ message: 'Milestone not found', code: ErrorCode.MILESTONE_NOT_FOUND });

    // Idempotent: if already soft-deleted, return success
    if (milestone.deletedAt) {
      return { message: 'Milestone already deleted' };
    }

    await this.verifyAccess(milestone.babymonId, userId);

    // Always soft-delete the milestone
    await this.prisma.milestone.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    // Deduct XP
    await this.prisma.babyMon.update({
      where: { id: milestone.babymonId },
      data: { currentXp: { decrement: milestone.xpAwarded } },
    });

    // If outside the undo window, also create a proposal for partner review
    if (!isWithinUndoWindow(milestone.createdAt)) {
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);
      this.prisma.entryChangeProposal.create({
        data: {
          babymonId: milestone.babymonId,
          proposerUserId: userId,
          entryType: 'MILESTONE',
          entryId: id,
          proposalType: 'DELETE',
          proposedPayloadJson: JSON.stringify({}),
          expiresAt,
        },
      }).catch((err) => this.logger.warn?.({ err }, 'Proposal creation failed (non-critical)'));
    }

    return { message: 'Milestone deleted successfully' };
  }

  private async verifyAccess(babymonId: string, userId: string) {
    const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId);
    if (!hasAccess) {
      throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });
    }
  }
}
