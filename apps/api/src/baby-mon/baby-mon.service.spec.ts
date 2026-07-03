import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { BabyMonService } from './baby-mon.service';
import { PrismaService } from '../prisma/prisma.service';
import { S3Service } from '../s3/s3.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { CryptoService } from '../common/crypto.service';
import { StageCalculatorService } from '../common/stage-calculator.service';
import { StageContentService } from '../stage-content/stage-content.service';

describe('BabyMonService', () => {
  let service: BabyMonService;

  const mockPrisma = {
    babyMon: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    growthRecord: { findMany: jest.fn() },
    allergy: { findMany: jest.fn() },
    badge: { findMany: jest.fn() },
    stageContent: { findFirst: jest.fn() },
    auditLog: { create: jest.fn() },
    milestone: { count: jest.fn() },
    feedLog: { count: jest.fn() },
    healthRecord: { count: jest.fn() },
    sleepLog: { count: jest.fn() },
  };

  const mockS3 = { deleteFile: jest.fn() };
  const mockAccessControl = { checkAccess: jest.fn() };
  const mockSubscriptions = {
    getCurrentSubscription: jest.fn().mockResolvedValue({ tier: 'PREMIUM', trialActive: true, hasSubscription: true }),
    getHistoryLimitDays: jest.fn().mockResolvedValue(null),
  };
  const mockCrypto = { encrypt: jest.fn((v: string) => v), decrypt: jest.fn((v: string) => v) };
  const mockStageCalc = { calculateStage: jest.fn() };
  const mockStageContent = { getByStageKey: jest.fn() };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
      { provide: ConfigService, useValue: { get: jest.fn(() => undefined) } },
        BabyMonService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: S3Service, useValue: mockS3 },
        { provide: AccessControlService, useValue: mockAccessControl },
        { provide: SubscriptionsService, useValue: mockSubscriptions },
        { provide: CryptoService, useValue: mockCrypto },
        { provide: StageCalculatorService, useValue: mockStageCalc },
        { provide: StageContentService, useValue: mockStageContent },
      ],
    }).compile();

    service = module.get<BabyMonService>(BabyMonService);
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return paginated BabyMons', async () => {
      mockPrisma.babyMon.findMany.mockResolvedValue([{ id: '1' }, { id: '2' }]);
      mockPrisma.babyMon.count.mockResolvedValue(2);

      const result = await service.findAll('user-1', 0, 20);

      expect(result.items).toHaveLength(2);
      expect(result.total).toBe(2);
    });
  });

  describe('calculateCurrentStage', () => {
    it('should return stage info for pregnancy', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        id: '1',
        stageStartType: 'INCUBATING',
        conceptionDate: new Date('2024-01-01'),
      });
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });
      mockStageCalc.calculateStage.mockResolvedValue({ stageKey: 'preg_week_20', age: '20 weeks' });

      const result = await service.calculateCurrentStage('user-1', '1');

      expect(result).toBeDefined();
      expect(mockAccessControl.checkAccess).toHaveBeenCalled();
    });

    it('should throw if BabyMon not found', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue(null);
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });

      await expect(service.calculateCurrentStage('user-1', '1')).rejects.toThrow();
    });
  });

  describe('getDashboard', () => {
    const babyMonId = 'bm-1';
    const userId = 'user-1';
    const mockBabyMon = {
      id: babyMonId, name: 'Test Baby', stageStartType: 'BORN', birthDate: new Date('2026-01-15'),
      conceptionDate: null, ownerUserId: userId, bloodGroup: 'O+', currentXp: 55,
      eyeColor: 'Brown', traits: ['Curious'], deletedAt: null,
      _count: { milestones: 3, feedLogs: 10, healthRecords: 2, sleepLogs: 5 },
    };

    it('should return full aggregated dashboard data', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });
      mockPrisma.babyMon.findFirst.mockResolvedValue(mockBabyMon);
      mockPrisma.babyMon.findUnique.mockResolvedValue({ currentXp: 55, currentStage: 1 });
      mockPrisma.growthRecord.findMany.mockResolvedValue([
        { id: 'g1', type: 'WEIGHT', value: 7.5, unit: 'kg', measuredAt: new Date() },
        { id: 'g2', type: 'HEIGHT', value: 65, unit: 'cm', measuredAt: new Date() },
      ]);
      mockPrisma.allergy.findMany.mockResolvedValue([{ id: 'a1', name: 'Lactose', severity: 'MILD', triggers: 'Dairy' }]);
      mockPrisma.badge.findMany.mockResolvedValue([{ id: 'b1', badgeType: 'M01', name: 'First Milestone', icon: 'star', unlockedAt: new Date() }]);
      mockStageContent.getByStageKey.mockResolvedValue({ summaryText: 'Growing!', nurturingText: 'Nurture', encouragementText: 'Great!', stageKey: 'born_month_5', weekNumber: 20 });

      const result = await service.getDashboard(babyMonId, userId);

      expect(result.babyMon.id).toBe(babyMonId);
      expect(result.babyMon.isOwner).toBe(true);
      // 55 XP at stage 1 → levels up to stage 2 with 5 XP remaining
      expect(result.evolution.currentXp).toBe(5);
      expect(result.evolution.currentStage).toBe(2);
      expect(result.growth.weight.value).toBe(7.5);
      expect(result.growth.height.value).toBe(65);
      expect(result.allergies).toHaveLength(1);
      expect(result.badges).toHaveLength(1);
      expect(result.stageContent.summaryText).toBe('Growing!');
    });

    it('should return null stageContent when not found', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });
      mockPrisma.babyMon.findFirst.mockResolvedValue(mockBabyMon);
      mockPrisma.babyMon.findUnique.mockResolvedValue({ currentXp: 0 });
      mockPrisma.growthRecord.findMany.mockResolvedValue([]);
      mockPrisma.allergy.findMany.mockResolvedValue([]);
      mockPrisma.badge.findMany.mockResolvedValue([]);
      mockStageContent.getByStageKey.mockResolvedValue(null);

      const result = await service.getDashboard(babyMonId, userId);
      expect(result.stageContent).toBeNull();
      expect(result.growth.weight).toBeNull();
    });

    it('should throw NotFoundException when BabyMon is missing', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });
      mockPrisma.babyMon.findFirst.mockResolvedValue(null);

      await expect(service.getDashboard(babyMonId, userId)).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when access denied', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: false });
      await expect(service.getDashboard(babyMonId, userId)).rejects.toThrow(NotFoundException);
    });

    it('should decrypt bloodGroup', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: true });
      mockPrisma.babyMon.findFirst.mockResolvedValue({ ...mockBabyMon, bloodGroup: 'enc' });
      mockPrisma.babyMon.findUnique.mockResolvedValue({ currentXp: 0 });
      mockPrisma.growthRecord.findMany.mockResolvedValue([]);
      mockPrisma.allergy.findMany.mockResolvedValue([]);
      mockPrisma.badge.findMany.mockResolvedValue([]);
      mockStageContent.getByStageKey.mockResolvedValue(null);
      mockCrypto.decrypt.mockReturnValue('O+');

      const result = await service.getDashboard(babyMonId, userId);
      expect(mockCrypto.decrypt).toHaveBeenCalledWith('enc');
      expect(result.babyMon.bloodGroup).toBe('O+');
    });
  });
});
