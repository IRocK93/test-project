import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { S3Service } from '../s3/s3.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { CryptoService } from '../common/crypto.service';
import { CreateBabyMonDto, UpdateBabyMonDto } from './dto/baby-mon.dto';
import { StageCalculatorService } from '../common/stage-calculator.service';
import { StageContentService } from '../stage-content/stage-content.service';
import { xpForNextLevel, getLevelName } from '../xp/xp.service';
import { LimitReachedException } from '../common/exceptions/business.exception';

@Injectable()
export class BabyMonService {
  private readonly logger = new Logger(BabyMonService.name);

  constructor(
    private prisma: PrismaService,
    private s3Service: S3Service,
    private accessControl: AccessControlService,
    private subscriptionsService: SubscriptionsService,
    private stageCalculator: StageCalculatorService,
    private stageContentService: StageContentService,
    private cryptoService: CryptoService,
  ) {}

  async create(userId: string, dto: CreateBabyMonDto) {
    // FREE tier: limit to 1 BabyMon profile
    const { tier } = await this.subscriptionsService.getCurrentSubscription(userId);
    if (tier === 'FREE') {
      const count = await this.prisma.babyMon.count({
        where: { ownerUserId: userId, deletedAt: null },
      });
      if (count >= 1) {
        throw new LimitReachedException(
          'Free accounts are limited to 1 baby profile. Upgrade to PREMIUM to add more.'
        );
      }
    }

    // Calculate dates based on stage
    let conceptionDate: Date | null = null;
    let birthDate: Date | null = null;
    let ideaDate: Date | null = null;

    if (dto.stageStartType === 'INCUBATING') {
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
    } else if (dto.stageStartType === 'PLAN') {
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
        bloodGroup: this.cryptoService.encrypt(dto.bloodGroup),
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

  async createBatch(userId: string, dtos: CreateBabyMonDto[]) {
    const siblingGroupId = require('crypto').randomUUID();
    const results = [];
    for (const dto of dtos) {
      const babyMon = await this.create(userId, dto);
      await this.prisma.babyMon.update({ where: { id: babyMon.id }, data: { siblingGroupId } });
      results.push(babyMon);
    }
    return { siblingGroupId, babies: results };
  }

  async graduateBabyMon(babymonId: string, userId: string) {
    const babyMon = await this.findOne(babymonId, userId);
    if (!babyMon.isOwner) throw new ForbiddenException('Only the owner can graduate a BabyMon');

    await this.prisma.babyMon.update({
      where: { id: babymonId },
      data: { isGraduated: true, graduatedAt: new Date() },
    });

    await this.prisma.auditLog.create({
      data: { babymonId, actorUserId: userId, eventType: 'BABYMON_GRADUATED', payloadJson: JSON.stringify({ name: babyMon.name }) },
    });

    return { message: 'BabyMon graduated and archived', babymonId };
  }

  async findAll(userId: string, skip: number = 0, take: number = 20) {
    const where = {
      deletedAt: null,
      OR: [
        { ownerUserId: userId },
        { linkedUsers: { some: { userId } } },
      ],
    };

    const [items, total] = await Promise.all([
      this.prisma.babyMon.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      this.prisma.babyMon.count({ where }),
    ]);

    return {
      items: items.map(bm => ({ ...bm, isOwner: bm.ownerUserId === userId })),
      total,
      skip,
      take,
    };
  }

  async findOne(id: string, userId: string) {
    // Verify access (ownership or linked partner) before returning data
    const access = await this.accessControl.checkAccess(userId, id);
    if (!access.hasAccess) {
      throw new NotFoundException('BabyMon not found');
    }

    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id, deletedAt: null },
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

    return {
      ...babyMon,
      bloodGroup: this.cryptoService.decrypt(babyMon.bloodGroup),
      isOwner: babyMon.ownerUserId === userId,
    };
  }

  /**
   * Aggregated dashboard endpoint — collapses 9 individual HTTP requests
   * into a single response for the mobile dashboard screen.
   */
  async getDashboard(babymonId: string, userId: string) {
    const access = await this.accessControl.checkAccess(userId, babymonId);
    if (!access.hasAccess) {
      throw new NotFoundException('BabyMon not found');
    }

    const [babyMon, evolution, growth, allergies, badges] =
      await Promise.all([
        this.prisma.babyMon.findFirst({
          where: { id: babymonId, deletedAt: null },
          include: {
            _count: { select: { milestones: true, feedLogs: true, healthRecords: true, sleepLogs: true } },
          },
        }),
        this.prisma.babyMon.findUnique({
          where: { id: babymonId },
          select: { currentXp: true, currentStage: true },
        }),
        this.prisma.growthRecord.findMany({
          where: { babyMonId: babymonId },
          orderBy: { measuredAt: 'desc' },
          take: 2,
          select: { id: true, type: true, value: true, unit: true, measuredAt: true },
        }),
        this.prisma.allergy.findMany({
          where: { babyMonId: babymonId, deletedAt: null },
          take: 20,
          select: { id: true, name: true, severity: true, triggers: true },
        }),
        this.prisma.badge.findMany({
          where: { babymonId },
          take: 50,
          select: { id: true, badgeType: true, name: true, icon: true, unlockedAt: true },
        }),
      ]);

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Stage content — computed after babyMon is resolved
    const stageKey = StageCalculatorService.computeStageKey({
      stageStartType: babyMon.stageStartType,
      conceptionDate: babyMon.conceptionDate,
      birthDate: babyMon.birthDate,
      gestationalAgeAtBirth: (babyMon as any).gestationalAgeAtBirth,
    });
    let stageContent = stageKey
      ? await this.stageContentService.getByStageKey(stageKey, babymonId)
      : null;

    // Personalize {name} placeholders (matching StageContentService.getForBabyMon)
    if (stageContent && babyMon.name) {
      const name = babyMon.name;
      stageContent = {
        ...stageContent,
        summaryText: (stageContent as any).summaryText?.replace(/{name}/g, name),
        nurturingText: (stageContent as any).nurturingText?.replace(/{name}/g, name),
        encouragementText: (stageContent as any).encouragementText?.replace(/{name}/g, name),
      };
    }

    return {
      babyMon: {
        ...babyMon,
        bloodGroup: this.cryptoService.decrypt(babyMon.bloodGroup),
        isOwner: babyMon.ownerUserId === userId,
      },
      evolution: (() => {
        const rawStage = evolution?.currentStage ?? 1;
        const rawXp = evolution?.currentXp ?? 0;

        // Compute effective stage/XP (multi-hop level-ups) without mutating DB.
        // This ensures the dashboard always shows correct progress even if
        // checkAndProcessLevelUp hasn't been called yet.
        let effectiveStage = rawStage;
        let effectiveXp = rawXp;
        while (effectiveStage < 50) {
          const needed = xpForNextLevel(effectiveStage);
          if (effectiveXp < needed) break;
          effectiveXp -= needed;
          effectiveStage++;
        }

        const needed = xpForNextLevel(effectiveStage);
        return {
          currentXp: effectiveXp,
          currentLevel: effectiveStage,
          currentStage: effectiveStage,
          xpForNextLevel: needed,
          xpProgress: needed > 0 ? Math.min(Math.round((effectiveXp / needed) * 100), 100) : 100,
          levelName: getLevelName(effectiveStage),
          nextLevelName: getLevelName(effectiveStage + 1),
        };
      })(),
      growth: {
        weight: growth.find((g: any) => g.type === 'WEIGHT') || null,
        height: growth.find((g: any) => g.type === 'HEIGHT') || null,
      },
      allergies,
      badges,
      stageContent: stageContent || null,
    };
  }

  async update(id: string, userId: string, dto: UpdateBabyMonDto) {
    // Only the owner can edit the BabyMon profile
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id, deletedAt: null },
    });
    if (!babyMon || babyMon.ownerUserId !== userId) {
      throw new ForbiddenException('Only the owner can edit this BabyMon');
    }

    const updated = await this.prisma.babyMon.update({
      where: { id },
      data: {
        name: dto.name,
        middleName: dto.middleName,
        lastName: dto.lastName,
        gender: dto.gender,
        traits: dto.traits ? dto.traits : undefined,
        specialMove: dto.specialMove,
        biologicalMother: dto.biologicalMother,
        biologicalFather: dto.biologicalFather,
        bloodGroup: this.cryptoService.encrypt(dto.bloodGroup),
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

    return updated;
  }

  async delete(id: string, userId: string) {
    // Only the owner can delete the BabyMon
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id, deletedAt: null },
    });
    if (!babyMon || babyMon.ownerUserId !== userId) {
      throw new ForbiddenException('Only the owner can delete this BabyMon');
    }

    // Delete S3 media files before removing DB records
    const mediaRecords = await this.prisma.media.findMany({
      where: { babyMonId: id },
      select: { s3Key: true },
    });

    for (const media of mediaRecords) {
      try {
        await this.s3Service.deleteFile(media.s3Key);
      } catch (error) {
        this.logger.error(
          { err: error, s3Key: media.s3Key },
          'Failed to delete S3 object during BabyMon deletion',
        );
      }
    }

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

  async calculateCurrentStage(userId: string, babymonId: string) {
    // Verify user has access to this BabyMon before returning stage data
    const access = await this.accessControl.checkAccess(userId, babymonId);
    if (!access.hasAccess) {
      throw new NotFoundException('BabyMon not found');
    }

    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Use shared stage calculator — single source of truth
    const stageInfo = await this.stageCalculator.calculateStage(babymonId);

    let referenceDate: Date;
    let isPostBirth = false;

    if (babyMon.stageStartType === 'INCUBATING' && babyMon.conceptionDate) {
      referenceDate = babyMon.conceptionDate;
    } else if (babyMon.stageStartType === 'BORN' && babyMon.birthDate) {
      referenceDate = babyMon.birthDate;
      isPostBirth = true;
    } else if (babyMon.stageStartType === 'PLAN' && babyMon.ideaDate) {
      referenceDate = babyMon.ideaDate;
    } else {
      referenceDate = babyMon.createdAt;
      isPostBirth = babyMon.stageStartType === 'BORN';
    }

    return {
      stageNumber: stageInfo.currentStage,
      stageLabel: stageInfo.stageLabel,
      stageKey: stageInfo.stageKey,
      isPostBirth,
      referenceDate,
      currentXp: babyMon.currentXp,
    };
  }
}
