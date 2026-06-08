import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBabyMonDto, UpdateBabyMonDto } from './dto/baby-mon.dto';

@Injectable()
export class BabyMonService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateBabyMonDto) {
    // Calculate dates based on stage
    let conceptionDate: Date | null = null;
    let birthDate: Date | null = null;
    let ideaDate: Date | null = null;

    if (dto.stageStartType === 'CONCEIVED') {
      if (dto.conceptionDate) {
        conceptionDate = new Date(dto.conceptionDate);
      } else if (dto.lmpDate) {
        // LMP + 2 weeks = conception date (average)
        const lmp = new Date(dto.lmpDate);
        lmp.setDate(lmp.getDate() + 14);
        conceptionDate = lmp;
      }
    } else if (dto.stageStartType === 'BORN') {
      birthDate = dto.birthDate ? new Date(dto.birthDate) : null;
    } else if (dto.stageStartType === 'IDEA') {
      ideaDate = dto.ideaDate ? new Date(dto.ideaDate) : new Date();
    }

    const babyMon = await this.prisma.babyMon.create({
      data: {
        ownerUserId: userId,
        name: dto.name,
        middleName: dto.middleName,
        lastName: dto.lastName,
        stageStartType: dto.stageStartType,
        conceptionDate,
        birthDate,
        ideaDate,
        gender: dto.gender,
        traits: dto.traits || [],
        specialMove: dto.specialMove,
        biologicalMother: dto.biologicalMother,
        biologicalFather: dto.biologicalFather,
        bloodGroup: dto.bloodGroup,
        eyeColor: dto.eyeColor,
      },
    });

    // Create initial audit log
    await this.prisma.auditLog.create({
      data: {
        babymonId: babyMon.id,
        actorUserId: userId,
        eventType: 'BABYMON_CREATED',
        payloadJson: JSON.stringify({ name: babyMon.name }),
      },
    });

    // Award first BabyMon badge
    await this.prisma.badge.create({
      data: {
        babymonId: babyMon.id,
        badgeType: 'FIRST_BABYMON',
        name: 'New Beginning',
        icon: 'baby',
      },
    });

    return babyMon;
  }

  async findAll(userId: string, skip: number = 0, take: number = 20) {
    const [items, total] = await Promise.all([
      this.prisma.babyMon.findMany({
        where: { ownerUserId: userId, deletedAt: null },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      this.prisma.babyMon.count({
        where: { ownerUserId: userId, deletedAt: null },
      }),
    ]);

    return {
      items,
      total,
      skip,
      take,
    };
  }

  async findOne(id: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id, ownerUserId: userId, deletedAt: null },
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

    return babyMon;
  }

  async update(id: string, userId: string, dto: UpdateBabyMonDto) {
    await this.findOne(id, userId); // Verify ownership

    const babyMon = await this.prisma.babyMon.update({
      where: { id },
      data: {
        name: dto.name,
        middleName: dto.middleName,
        lastName: dto.lastName,
        traits: dto.traits ? dto.traits : undefined,
        specialMove: dto.specialMove,
        biologicalMother: dto.biologicalMother,
        biologicalFather: dto.biologicalFather,
        bloodGroup: dto.bloodGroup,
        eyeColor: dto.eyeColor,
      },
    });

    // Audit log
    await this.prisma.auditLog.create({
      data: {
        babymonId: id,
        actorUserId: userId,
        eventType: 'BABYMON_UPDATED',
        payloadJson: JSON.stringify(dto),
      },
    });

    return babyMon;
  }

  async delete(id: string, userId: string) {
    await this.findOne(id, userId); // Verify ownership

    // Hard delete with manual cascade (children first, then parent)
    await this.prisma.$transaction([
      this.prisma.milestone.deleteMany({ where: { babymonId: id } }),
      this.prisma.feedLog.deleteMany({ where: { babymonId: id } }),
      this.prisma.healthRecord.deleteMany({ where: { babymonId: id } }),
      this.prisma.badge.deleteMany({ where: { babymonId: id } }),
      this.prisma.stageContent.deleteMany({ where: { babymonId: id } }),
      this.prisma.linkedBabyMon.deleteMany({ where: { babymonId: id } }),
      this.prisma.media.deleteMany({ where: { babyMonId: id } }),
      this.prisma.growthRecord.deleteMany({ where: { babyMonId: id } }),
      this.prisma.auditLog.updateMany({ where: { babymonId: id }, data: { babymonId: null } }),
      this.prisma.entryChangeProposal.deleteMany({ where: { babymonId: id } }),
      this.prisma.journalProposal.deleteMany({ where: { babymonId: id } }),
    ]);

    return this.prisma.babyMon.delete({ where: { id } });
  }

  async calculateCurrentStage(babymonId: string) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    let referenceDate: Date;
    let isPostBirth = false;

    if (babyMon.stageStartType === 'CONCEIVED' && babyMon.conceptionDate) {
      referenceDate = babyMon.conceptionDate;
      isPostBirth = false;
    } else if (babyMon.stageStartType === 'BORN' && babyMon.birthDate) {
      referenceDate = babyMon.birthDate;
      isPostBirth = true;
    } else if (babyMon.stageStartType === 'IDEA' && babyMon.ideaDate) {
      referenceDate = babyMon.ideaDate;
      isPostBirth = false;
    } else {
      // Default to creation date
      referenceDate = babyMon.createdAt;
      isPostBirth = babyMon.stageStartType === 'BORN';
    }

    const now = new Date();
    const weeksDiff = Math.floor((now.getTime() - referenceDate.getTime()) / (1000 * 60 * 60 * 24 * 7));
    const monthsDiff = Math.floor((now.getTime() - referenceDate.getTime()) / (1000 * 60 * 60 * 24 * 30));

    let stageNumber: number;
    let stageLabel: string;

    if (!isPostBirth) {
      // Pregnancy: week by week until birth (40 weeks)
      stageNumber = Math.min(weeksDiff, 40);
      stageLabel = `Week ${stageNumber}`;
    } else {
      // Post-birth: week by week until 3 months, then month by month until 24 months
      if (monthsDiff < 3) {
        stageNumber = weeksDiff;
        stageLabel = `Week ${stageNumber}`;
      } else {
        stageNumber = Math.min(monthsDiff, 24);
        stageLabel = `Month ${stageNumber}`;
      }
    }

    return {
      stageNumber,
      stageLabel,
      isPostBirth,
      referenceDate,
      currentXp: babyMon.currentXp,
    };
  }
}
