import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { FeedLogsService } from './feed-logs.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { FeedingType } from './dto/feed-log.dto';

/**
 * FeedLogsService unit tests — CRUD + validation + side effects.
 *
 * Covers item #2 from the Testing Audit top-10 missing tests.
 */
describe('FeedLogsService', () => {
  let service: FeedLogsService;
  let prisma: any;

  const babyMonId = 'baby-1';
  const userId = 'user-1';
  const feedLogId = 'feed-1';

  const mockBabyMon = {
    id: babyMonId,
    name: 'Test Baby',
    stageStartType: 'BORN',
    birthDate: new Date('2026-01-15'),
    currentXp: 0,
    currentLevel: 1,
    deletedAt: null,
  };

  const mockFeedLog = {
    id: feedLogId,
    babymonId: babyMonId,
    authorUserId: userId,
    type: 'BREASTMILK',
    amount: '120',
    unit: 'ml',
    notes: 'Good latch',
    happenedAt: new Date(),
    localMediaRefs: [],
    syncStatus: 'SYNCED',
    xpAwarded: 5,
    createdAt: new Date(),
    deletedAt: null,
    author: { id: userId, name: 'Test User' },
  };

  // ── Mock factories ──────────────────────────────────────────
  const mockPrisma = {
    babyMon: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    feedLog: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      count: jest.fn(),
    },
    auditLog: { create: jest.fn() },
    entryChangeProposal: { create: jest.fn() },
    dailyActivity: {
      upsert: jest.fn(),
      findUnique: jest.fn(),
    },
  };

  const mockBadges = {
    checkAndAwardBadges: jest.fn().mockResolvedValue([]),
  };

  const mockXp = {
    checkAndProcessLevelUp: jest.fn().mockResolvedValue(undefined),
    awardXp: jest.fn(),
  };

  const mockAccessControl = {
    checkAccess: jest.fn().mockResolvedValue({ hasAccess: true }),
  };

  const mockSubscriptions = {
    getCurrentSubscription: jest
      .fn()
      .mockResolvedValue({ tier: 'PREMIUM', trialActive: true, hasSubscription: true }),
    getHistoryLimitDays: jest.fn().mockResolvedValue(null),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FeedLogsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: BadgesService, useValue: mockBadges },
        { provide: XpService, useValue: mockXp },
        { provide: AccessControlService, useValue: mockAccessControl },
        { provide: SubscriptionsService, useValue: mockSubscriptions },
      ],
    }).compile();

    service = module.get<FeedLogsService>(FeedLogsService);
    prisma = module.get(PrismaService);
    jest.clearAllMocks();
  });

  // ─────────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────────
  describe('create', () => {
    const validDto = {
      type: FeedingType.BREASTMILK,
      amount: '120',
      unit: 'ml',
      notes: 'Good latch',
      happenedAt: new Date().toISOString(),
    };

    it('should create a feed log and award XP', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(mockBabyMon);
      mockPrisma.feedLog.create.mockResolvedValue(mockFeedLog);
      mockPrisma.babyMon.update.mockResolvedValue({ ...mockBabyMon, currentXp: 5 });

      const result = await service.create(babyMonId, userId, validDto);

      expect(result).toBeDefined();
      expect(result.id).toBe(feedLogId);
      expect(result.type).toBe('BREASTMILK');
      expect(result.xpAwarded).toBe(5);

      // XP increment side effect
      expect(mockPrisma.babyMon.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: babyMonId },
          data: { currentXp: { increment: 5 } },
        }),
      );

      // Badge check side effect
      expect(mockBadges.checkAndAwardBadges).toHaveBeenCalledWith(
        babyMonId,
        userId,
      );

      // Level-up check side effect
      expect(mockXp.checkAndProcessLevelUp).toHaveBeenCalledWith(babyMonId);

      // Audit log side effect
      expect(mockPrisma.auditLog.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            babymonId: babyMonId,
            actorUserId: userId,
            eventType: 'FEED_LOG_CREATED',
          }),
        }),
      );
    });

    it('should create a SOLID feeding log with full details', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(mockBabyMon);
      const solidLog = { ...mockFeedLog, type: 'SOLID', amount: '80', unit: 'g' };
      mockPrisma.feedLog.create.mockResolvedValue(solidLog);

      const result = await service.create(babyMonId, userId, {
        type: FeedingType.SOLID,
        amount: '80',
        unit: 'g',
        notes: 'Banana puree',
        happenedAt: new Date().toISOString(),
        localMediaRefs: ['photo-1'],
      });

      expect(result.type).toBe('SOLID');
      expect(result.amount).toBe('80');
      expect(result.unit).toBe('g');
    });

    it('should use happenedAt date from DTO', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(mockBabyMon);
      const customDate = '2026-03-15T10:30:00.000Z';
      mockPrisma.feedLog.create.mockResolvedValue({
        ...mockFeedLog,
        happenedAt: new Date(customDate),
      });

      const result = await service.create(babyMonId, userId, {
        type: FeedingType.FORMULA,
        happenedAt: customDate,
      });

      expect(mockPrisma.feedLog.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            happenedAt: new Date(customDate),
          }),
        }),
      );
    });

    it('should throw NotFoundException when BabyMon does not exist', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(null);

      await expect(
        service.create('non-existent-id', userId, validDto),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw NotFoundException when BabyMon is soft-deleted', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(null); // query filters deletedAt: null

      await expect(
        service.create(babyMonId, userId, validDto),
      ).rejects.toThrow(NotFoundException);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // FIND ALL
  // ─────────────────────────────────────────────────────────────
  describe('findAll', () => {
    it('should return paginated feed logs', async () => {
      mockPrisma.feedLog.findMany.mockResolvedValue([mockFeedLog]);
      mockPrisma.feedLog.count.mockResolvedValue(1);

      const result = await service.findAll(babyMonId, userId, 0, 20);

      expect(result.items).toHaveLength(1);
      expect(result.items[0].id).toBe(feedLogId);
      expect(result.total).toBe(1);
      expect(result.skip).toBe(0);
      expect(result.take).toBe(20);
    });

    it('should enforce access control', async () => {
      mockAccessControl.checkAccess.mockResolvedValue({ hasAccess: false });

      await expect(service.findAll(babyMonId, userId)).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('should return empty list when no feed logs exist', async () => {
      mockPrisma.feedLog.findMany.mockResolvedValue([]);
      mockPrisma.feedLog.count.mockResolvedValue(0);

      const result = await service.findAll(babyMonId, userId);

      expect(result.items).toHaveLength(0);
      expect(result.total).toBe(0);
    });

    it('should respect pagination skip/take', async () => {
      mockPrisma.feedLog.findMany.mockResolvedValue([mockFeedLog]);
      mockPrisma.feedLog.count.mockResolvedValue(5);

      await service.findAll(babyMonId, userId, 10, 5);

      expect(mockPrisma.feedLog.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ skip: 10, take: 5 }),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // FIND ONE
  // ─────────────────────────────────────────────────────────────
  describe('findOne', () => {
    it('should return a single feed log', async () => {
      mockPrisma.feedLog.findUnique.mockResolvedValue(mockFeedLog);

      const result = await service.findOne(feedLogId, userId);

      expect(result.id).toBe(feedLogId);
      expect(result.type).toBe('BREASTMILK');
      expect(result).toHaveProperty('author');
    });

    it('should throw NotFoundException when feed log does not exist', async () => {
      mockPrisma.feedLog.findUnique.mockResolvedValue(null);

      await expect(service.findOne('non-existent', userId)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw NotFoundException when feed log is soft-deleted', async () => {
      mockPrisma.feedLog.findUnique.mockResolvedValue({
        ...mockFeedLog,
        deletedAt: new Date(),
      });

      await expect(service.findOne(feedLogId, userId)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────────
  describe('update', () => {
    const updateDto = { amount: '150', notes: 'Updated notes' };

    it('should update feed log within undo window', async () => {
      // Feed log created "just now" — within undo window
      const recentLog = { ...mockFeedLog, createdAt: new Date() };
      mockPrisma.feedLog.findUnique.mockResolvedValue(recentLog);
      mockPrisma.feedLog.update.mockResolvedValue({
        ...recentLog,
        amount: '150',
        notes: 'Updated notes',
      });

      const result = await service.update(feedLogId, userId, updateDto);

      expect(result).toBeDefined();
      const feedLog = result as any;
      expect(feedLog.amount).toBe('150');
      expect(feedLog.notes).toBe('Updated notes');
    });

    it('should create change proposal outside undo window', async () => {
      // Feed log created 8 days ago — outside 7-day undo window
      const oldDate = new Date();
      oldDate.setDate(oldDate.getDate() - 8);
      const oldLog = { ...mockFeedLog, createdAt: oldDate };
      mockPrisma.feedLog.findUnique.mockResolvedValue(oldLog);
      mockPrisma.entryChangeProposal.create.mockResolvedValue({
        id: 'proposal-1',
        proposalType: 'EDIT',
      });

      const result = await service.update(feedLogId, userId, updateDto);

      expect(result).toHaveProperty('proposalType');
      const proposal = result as any;
      expect(proposal.proposalType).toBe('EDIT');
      expect(mockPrisma.entryChangeProposal.create).toHaveBeenCalled();
    });
  });

  // ─────────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────────
  describe('delete', () => {
    it('should soft-delete feed log and decrement XP', async () => {
      const recentLog = { ...mockFeedLog, createdAt: new Date() };
      mockPrisma.feedLog.findUnique.mockResolvedValue(recentLog);
      mockPrisma.feedLog.update.mockResolvedValue({
        ...recentLog,
        deletedAt: new Date(),
      });

      const result = await service.delete(feedLogId, userId);

      expect(result.message).toContain('deleted');

      // Soft delete
      expect(mockPrisma.feedLog.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: feedLogId },
          data: expect.objectContaining({ deletedAt: expect.any(Date) }),
        }),
      );

      // XP decrement
      expect(mockPrisma.babyMon.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: babyMonId },
          data: { currentXp: { decrement: 5 } },
        }),
      );
    });

    it('should throw NotFoundException when feed log does not exist', async () => {
      mockPrisma.feedLog.findUnique.mockResolvedValue(null);

      await expect(service.delete('non-existent', userId)).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
