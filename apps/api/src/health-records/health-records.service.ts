import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AccessControlService } from '../common/access-control.service';
import { isWithinUndoWindow } from '../common/undo-window.helper';
import { CreateHealthRecordDto, UpdateHealthRecordDto } from './dto/health-record.dto';

@Injectable()
export class HealthRecordsService {
  constructor(private prisma: PrismaService, private accessControl: AccessControlService) {}

  async create(babymonId: string, userId: string, dto: CreateHealthRecordDto) {
    const babyMon = await this.prisma.babyMon.findFirst({ where: { id: babymonId, deletedAt: null } });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const record = await this.prisma.healthRecord.create({
      data: {
        babymonId,
        authorUserId: userId,
        category: dto.category,
        title: dto.title,
        notes: dto.notes,
        happenedAt: new Date(dto.happenedAt),
        localMediaRefs: dto.localMediaRefs || [],
        syncStatus: 'SYNCED',
        xpAwarded: 5,
      },
    });

    await this.prisma.babyMon.update({ where: { id: babymonId }, data: { currentXp: { increment: 5 } } });
    await this.prisma.auditLog.create({
      data: { babymonId: babymonId, actorUserId: userId, eventType: 'HEALTH_RECORD_CREATED', payloadJson: JSON.stringify({ recordId: record.id }) },
    });

    return record;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.verifyAccess(babymonId, userId);

    const [items, total] = await Promise.all([
      this.prisma.healthRecord.findMany({
        where: { babymonId, deletedAt: null },
        orderBy: { happenedAt: 'desc' },
        skip,
        take,
        include: { author: { select: { id: true, name: true } } },
      }),
      this.prisma.healthRecord.count({
        where: { babymonId, deletedAt: null },
      }),
    ]);

    return { items, total, skip, take };
  }

  async findOne(id: string, userId: string) {
    const record = await this.prisma.healthRecord.findUnique({ where: { id }, include: { author: { select: { id: true, name: true } } } });
    if (!record || record.deletedAt) throw new NotFoundException('Health record not found');
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
    expiresAt.setDate(expiresAt.getDate() + 7);
    return this.prisma.entryChangeProposal.create({
      data: { babymonId: record.babymonId, proposerUserId: userId, entryType: 'HEALTH_RECORD', entryId: id, proposalType: 'EDIT', proposedPayloadJson: JSON.stringify(dto), expiresAt },
    });
  }

  async delete(id: string, userId: string) {
    const record = await this.findOne(id, userId);
    if (isWithinUndoWindow(record.createdAt)) {
      await this.prisma.healthRecord.update({ where: { id }, data: { deletedAt: new Date() } });
      await this.prisma.babyMon.update({ where: { id: record.babymonId }, data: { currentXp: { decrement: record.xpAwarded } } });
      return { message: 'Health record deleted' };
    }

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);
    return this.prisma.entryChangeProposal.create({
      data: { babymonId: record.babymonId, proposerUserId: userId, entryType: 'HEALTH_RECORD', entryId: id, proposalType: 'DELETE', proposedPayloadJson: JSON.stringify({}), expiresAt },
    });
  }

  private async verifyAccess(babymonId: string, userId: string) {
    await this.accessControl.checkAccess(userId, babymonId);
  }
}
