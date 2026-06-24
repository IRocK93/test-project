import { Test, TestingModule } from '@nestjs/testing';
import { BadgesService } from './badges.service';
import { PrismaService } from '../prisma/prisma.service';

describe('BadgesService', () => {
  let service: BadgesService;

  const mockTx = {
    babyMon: { findUnique: jest.fn() },
    badge: { create: jest.fn(), findMany: jest.fn().mockResolvedValue([]) },
    auditLog: { create: jest.fn(), count: jest.fn().mockResolvedValue(0) },
    journalProposal: { count: jest.fn().mockResolvedValue(0) },
    milestone: { findMany: jest.fn().mockResolvedValue([]), count: jest.fn().mockResolvedValue(0) },
    feedLog: { count: jest.fn().mockResolvedValue(0), findMany: jest.fn().mockResolvedValue([]) },
    sleepLog: { findMany: jest.fn().mockResolvedValue([]), count: jest.fn().mockResolvedValue(0) },
    healthRecord: { findMany: jest.fn().mockResolvedValue([]), count: jest.fn().mockResolvedValue(0) },
    growthRecord: { findMany: jest.fn().mockResolvedValue([]), count: jest.fn().mockResolvedValue(0) },
    dailyActivity: { findFirst: jest.fn().mockResolvedValue(null) },
    linkedBabyMon: { count: jest.fn().mockResolvedValue(0), findMany: jest.fn().mockResolvedValue([]) },
    media: { count: jest.fn().mockResolvedValue(0) },
    entryChangeProposal: { findMany: jest.fn().mockResolvedValue([]) },
    $queryRawUnsafe: jest.fn().mockResolvedValue([]),
  };

  const mockPrisma = {
    babyMon: { findFirst: jest.fn() },
    badge: { findMany: jest.fn() },
    linkedAccount: { findFirst: jest.fn() },
    $transaction: jest.fn((cb) => cb(mockTx)),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BadgesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<BadgesService>(BadgesService);
    jest.clearAllMocks();
  });

  describe('getBadgeDefinitions', () => {
    it('should return all badge definitions', async () => {
      const result = await service.getBadgeDefinitions();
      const count = Object.keys(result).length;
      expect(count).toBeGreaterThan(0);
      expect(result['M01'].name).toBe('First Milestone');
    });
  });

  describe('checkAndAwardBadges', () => {
    it('should award FIRST_MILESTONE badge when baby has 1 milestone', async () => {
      mockTx.babyMon.findUnique.mockResolvedValue({
        _count: { milestones: 1, feedLogs: 0, healthRecords: 0, sleepLogs: 0, growthRecords: 0 },
        currentXp: 0,
        traits: [],
        traitsUpdatedAt: null,
        stageStartType: 'BORN',
        birthDate: new Date('2026-01-01'),
      });

      const result = await service.checkAndAwardBadges('babymon-1', 'user-1');

      expect(result.length).toBeGreaterThan(0);
      expect(result[0].badgeType).toBe('M01');
      expect(mockTx.badge.create).toHaveBeenCalled();
    });

    it('should not duplicate badges already awarded', async () => {
      mockTx.badge.findMany.mockResolvedValue([{ badgeType: 'M01' }]);
      mockTx.babyMon.findUnique.mockResolvedValue({
        _count: { milestones: 1, feedLogs: 0, healthRecords: 0, sleepLogs: 0, growthRecords: 0 },
        currentXp: 0,
        traits: [],
        traitsUpdatedAt: null,
        stageStartType: 'BORN',
        birthDate: new Date('2026-01-01'),
      });

      const result = await service.checkAndAwardBadges('babymon-1', 'user-1');

      // M01 should not be re-awarded (already earned)
      expect(result.some((b: any) => b.badgeType === 'M01')).toBe(false);
    });

    it('should award X01 badge when XP reaches 50', async () => {
      mockTx.babyMon.findUnique.mockResolvedValue({
        _count: { milestones: 0, feedLogs: 0, healthRecords: 0, sleepLogs: 0, growthRecords: 0 },
        currentXp: 50,
        traits: [],
        traitsUpdatedAt: null,
        stageStartType: 'BORN',
        birthDate: new Date('2026-01-01'),
      });

      const result = await service.checkAndAwardBadges('babymon-1', 'user-1');

      expect(result.some((b: any) => b.badgeType === 'X01')).toBe(true);
    });

    it('should award F02 badge when 10 feed logs exist', async () => {
      mockTx.babyMon.findUnique.mockResolvedValue({
        _count: { milestones: 0, feedLogs: 10, healthRecords: 0, sleepLogs: 0, growthRecords: 0 },
        currentXp: 0,
        traits: [],
        traitsUpdatedAt: null,
        stageStartType: 'BORN',
        birthDate: new Date('2026-01-01'),
      });

      const result = await service.checkAndAwardBadges('babymon-1', 'user-1');

      expect(result.some((b: any) => b.badgeType === 'F02')).toBe(true);
    });

    it('should return empty array when BabyMon not found', async () => {
      mockTx.babyMon.findUnique.mockResolvedValue(null);

      const result = await service.checkAndAwardBadges('babymon-1', 'user-1');

      expect(result).toEqual([]);
    });
  });
});
