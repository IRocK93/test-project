import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMilestoneDto, UpdateMilestoneDto } from './dto/milestone.dto';
import { BadgesService } from '../badges/badges.service';
import { AccessControlService } from '../common/access-control.service';

@Injectable()
export class MilestonesService {
  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private accessControl: AccessControlService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateMilestoneDto) {
    // Verify BabyMon exists and user has access
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babymonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
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

    // Award XP
    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { currentXp: { increment: 10 } },
    });

    // Check for badges
    await this.badgesService.checkAndAwardBadges(babymonId, userId);

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

    const [items, total] = await Promise.all([
      this.prisma.milestone.findMany({
        where: { babymonId, deletedAt: null },
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
        where: { babymonId, deletedAt: null },
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
      throw new NotFoundException('Milestone not found');
    }

    await this.verifyAccess(milestone.babymonId, userId);

    return milestone;
  }

  async update(id: string, userId: string, dto: UpdateMilestoneDto) {
    const milestone = await this.findOne(id, userId);

    // Check if within 10-minute undo window
    const createdAt = new Date(milestone.createdAt);
    const now = new Date();
    const minutesDiff = (now.getTime() - createdAt.getTime()) / (1000 * 60);

    if (minutesDiff <= 10) {
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
    expiresAt.setDate(expiresAt.getDate() + 7);

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
    const milestone = await this.findOne(id, userId);

    // Check if within 10-minute undo window
    const createdAt = new Date(milestone.createdAt);
    const now = new Date();
    const minutesDiff = (now.getTime() - createdAt.getTime()) / (1000 * 60);

    if (minutesDiff <= 10) {
      // Allow direct delete
      await this.prisma.milestone.update({
        where: { id },
        data: { deletedAt: new Date() },
      });

      // Deduct XP
      await this.prisma.babyMon.update({
        where: { id: milestone.babymonId },
        data: { currentXp: { decrement: milestone.xpAwarded } },
      });

      return { message: 'Milestone deleted successfully' };
    }

    // Create proposal for co-parent approval
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    return this.prisma.entryChangeProposal.create({
      data: {
        babymonId: milestone.babymonId,
        proposerUserId: userId,
        entryType: 'MILESTONE',
        entryId: id,
        proposalType: 'DELETE',
        proposedPayloadJson: JSON.stringify({}),
        expiresAt,
      },
    });
  }

  private async verifyAccess(babymonId: string, userId: string) {
    const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId);
    if (!hasAccess) {
      throw new ForbiddenException('Access denied');
    }
  }
}
