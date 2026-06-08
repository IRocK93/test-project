import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AccessControlService } from '../common/access-control.service';
import { CreateSleepLogDto, UpdateSleepLogDto } from './dto/sleep-log.dto';

@Injectable()
export class SleepLogsService {
  constructor(
    private prisma: PrismaService,
    private accessControl: AccessControlService,
  ) {}

  async create(babymonId: string, userId: string, dto: CreateSleepLogDto) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon || babyMon.deletedAt) {
      throw new NotFoundException('BabyMon not found');
    }

    await this.accessControl.checkAccess(babymonId, userId);

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

    return sleepLog;
  }

  async findAll(babymonId: string, userId: string, skip: number = 0, take: number = 20) {
    await this.accessControl.checkAccess(babymonId, userId);

    const [items, total] = await Promise.all([
      this.prisma.sleepLog.findMany({
        where: { babymonId, deletedAt: null },
        skip,
        take,
        orderBy: { startTime: 'desc' },
        include: {
          author: { select: { id: true, name: true, email: true } },
        },
      }),
      this.prisma.sleepLog.count({
        where: { babymonId, deletedAt: null },
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
      throw new NotFoundException('Sleep log not found');
    }

    await this.accessControl.checkAccess(sleepLog.babymonId, userId);

    return sleepLog;
  }

  async update(id: string, userId: string, dto: UpdateSleepLogDto) {
    const sleepLog = await this.prisma.sleepLog.findUnique({
      where: { id },
    });

    if (!sleepLog || sleepLog.deletedAt) {
      throw new NotFoundException('Sleep log not found');
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
      throw new NotFoundException('Sleep log not found');
    }

    await this.accessControl.checkAccess(sleepLog.babymonId, userId);

    // Soft delete
    return this.prisma.sleepLog.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
}