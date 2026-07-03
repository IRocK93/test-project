import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { PrismaService } from '../prisma/prisma.service';
import { isWithinUndoWindow } from '../common/undo-window.helper';
import { PROPOSAL_EXPIRY_DAYS } from '../common/app-constants';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { buildHistoryDateFilter } from '../common/history-filter.helper';
import { trackDailyActivity } from '../common/daily-activity.helper';
import { CreateHealthRecordDto, UpdateHealthRecordDto } from './dto/health-record.dto';
import { validateHealthRecordValue } from '../common/health-value-keys';

@Injectable()
export class HealthRecordsService {
  private readonly logger = new Logger(HealthRecordsService.name);

  constructor(
    private prisma: PrismaService,
    private badgesService: BadgesService,
    private xpService: XpService,
    private accessControl: AccessControlService,
    private subscriptionsService: SubscriptionsService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateHealthRecordDto) {
    await this.accessControl.checkAccess(userId, babymonId);

    const babyMon = await this.prisma.babyMon.findFirst({ where: { id: babymonId, deletedAt: null } });
    if (!babyMon) throw new NotFoundException({ message: 'BabyMon not found', code: ErrorCode.BABYMON_NOT_FOUND });

    try {
      validateHealthRecordValue(dto.category, dto.value, dto.unit);
    } catch (err: any) {
      throw new BadRequestException({ message: err.message, code: ErrorCode.VALIDATION_ERROR });
    }

    const record = await this.prisma.healthRecord.create({
      data: {
        babymonId,
        authorUserId: userId,
        category: dto.category,
        title: dto.title,
        value: dto.value,
        unit: dto.unit,
        notes: dto.notes,
        happenedAt: new Date(dto.happenedAt),
        localMediaRefs: dto.localMediaRefs || [],
        syncStatus: 'SYNCED',
        xpAwarded: 5,
      },
    });

    await this.prisma.babyMon.update({ where: { id: babymonId }, data: { currentXp: { increment: 5 } } });

    await trackDailyActivity(this.prisma, babymonId, 'healthRecord');

    await this.xpService.checkAndProcessLevelUp(babymonId);

    try {
      await this.badgesService.checkAndAwardBadges(babymonId, userId);
    } catch (e) {
      this.logger.warn({ err: e }, 'Badge check failed (non-critical)');
    }

    await this.prisma.auditLog.create({
      data: { babymonId: babymonId, actorUserId: userId, eventType: 'HEALTH_RECORD_CREATED', payloadJson: JSON.stringify({ recordId: record.id }) },
    });

    return record;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.verifyAccess(babymonId, userId);

    // FREE tier: only show limited history
    const dateFilter = await buildHistoryDateFilter(this.subscriptionsService, userId);

    const baseWhere = { babymonId, deletedAt: null, ...dateFilter };

    const [items, total] = await Promise.all([
      this.prisma.healthRecord.findMany({
        where: baseWhere,
        orderBy: { happenedAt: 'desc' },
        skip,
        take,
        include: { author: { select: { id: true, name: true } } },
      }),
      this.prisma.healthRecord.count({
        where: baseWhere,
      }),
    ]);

    return { items, total, skip, take };
  }

  async findOne(id: string, userId: string) {
    const record = await this.prisma.healthRecord.findUnique({ where: { id }, include: { author: { select: { id: true, name: true } } } });
    if (!record || record.deletedAt) throw new NotFoundException({ message: 'Health record not found', code: ErrorCode.HEALTH_RECORD_NOT_FOUND });
    await this.verifyAccess(record.babymonId, userId);
    return record;
  }

  async update(id: string, userId: string, dto: UpdateHealthRecordDto) {
    const record = await this.findOne(id, userId);
    if (isWithinUndoWindow(record.createdAt)) {
      return this.prisma.healthRecord.update({
        where: { id },
        data: {
          category: dto.category,
          title: dto.title,
          notes: dto.notes,
          happenedAt: dto.happenedAt ? new Date(dto.happenedAt) : undefined,
          localMediaRefs: dto.localMediaRefs ? dto.localMediaRefs : undefined
        },
      });
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);
    return this.prisma.entryChangeProposal.create({
      data: { babymonId: record.babymonId, proposerUserId: userId, entryType: 'HEALTH_RECORD', entryId: id, proposalType: 'EDIT', proposedPayloadJson: JSON.stringify(dto), expiresAt },
    });
  }

  async delete(id: string, userId: string) {
    const record = await this.prisma.healthRecord.findUnique({
      where: { id },
      select: { id: true, babymonId: true, deletedAt: true, xpAwarded: true, createdAt: true },
    });

    if (!record) throw new NotFoundException({ message: 'Health record not found', code: ErrorCode.HEALTH_RECORD_NOT_FOUND });

    // Idempotent: if already soft-deleted, return success
    if (record.deletedAt) {
      return { success: true };
    }

    await this.verifyAccess(record.babymonId, userId);

    // Always soft-delete the record
    await this.prisma.healthRecord.update({ where: { id }, data: { deletedAt: new Date() } });
    await this.prisma.babyMon.update({ where: { id: record.babymonId }, data: { currentXp: { decrement: record.xpAwarded } } });

    // If outside the undo window, also create a proposal for partner review
    if (!isWithinUndoWindow(record.createdAt)) {
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + PROPOSAL_EXPIRY_DAYS);
      this.prisma.entryChangeProposal.create({
        data: { babymonId: record.babymonId, proposerUserId: userId, entryType: 'HEALTH_RECORD', entryId: id, proposalType: 'DELETE', proposedPayloadJson: JSON.stringify({}), expiresAt },
      }).catch((err) => this.logger.warn?.({ err }, 'Proposal creation failed (non-critical)'));
    }

    return { success: true };
  }

  private async verifyAccess(babymonId: string, userId: string) {
    await this.accessControl.checkAccess(userId, babymonId);
  }
}
