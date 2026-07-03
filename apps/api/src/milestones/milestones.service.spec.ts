import { Test, TestingModule } from '@nestjs/testing';
import { MilestonesService } from './milestones.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadgesService } from '../badges/badges.service';
import { XpService } from '../xp/xp.service';
import { AccessControlService } from '../common/access-control.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { NotFoundException } from '@nestjs/common';

describe('MilestonesService', () => {
  let service: MilestonesService;

  const mockPrisma = {
    babyMon: {
      findFirst: jest.fn().mockResolvedValue({ id: 'bm-1', ownerUserId: 'user-1' }),
      findUnique: jest.fn().mockResolvedValue({ id: 'bm-1', ownerUserId: 'user-1', currentXp: 0, currentStage: 1 }),
      update: jest.fn().mockResolvedValue({ id: 'bm-1' }),
    },
    milestone: {
      create: jest.fn().mockResolvedValue({ id: 'm-1', babymonId: 'bm-1', title: 'Test', xpAwarded: 10 }),
      findMany: jest.fn().mockResolvedValue([{ id: 'm-1', title: 'Test' }]),
      findFirst: jest.fn().mockResolvedValue({ id: 'm-1', babymonId: 'bm-1', title: 'Test', deletedAt: null }),
      findUnique: jest.fn().mockResolvedValue({
        id: 'm-1', babymonId: 'bm-1', title: 'Test', deletedAt: null, xpAwarded: 10,
        createdAt: new Date(),
        author: { id: 'user-1', name: 'Test User' },
      }),
      update: jest.fn().mockResolvedValue({ id: 'm-1' }),
      count: jest.fn().mockResolvedValue(5),
    },
    dailyActivity: {
      upsert: jest.fn().mockResolvedValue({}),
    },
    auditLog: {
      create: jest.fn().mockResolvedValue({}),
    },
    entryChangeProposal: {
      create: jest.fn().mockResolvedValue({}),
    },
  };

  const mockAccessControl = { checkAccess: jest.fn().mockResolvedValue({ hasAccess: true }) };
  const mockSubscriptions = { getHistoryLimitDays: jest.fn().mockResolvedValue(null) };
  const mockBadges = { checkAndAwardBadges: jest.fn().mockResolvedValue([]) };
  const mockXp = { checkAndProcessLevelUp: jest.fn().mockResolvedValue({ leveledUp: false }) };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MilestonesService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: AccessControlService, useValue: mockAccessControl },
        { provide: SubscriptionsService, useValue: mockSubscriptions },
        { provide: BadgesService, useValue: mockBadges },
        { provide: XpService, useValue: mockXp },
      ],
    }).compile();

    service = module.get<MilestonesService>(MilestonesService);
  });

  describe('create', () => {
    const dto = { title: 'First smile', happenedAt: '2026-06-01', notes: 'So happy!' };

    it('should create a milestone and award XP', async () => {
      const result = await service.create('bm-1', 'user-1', dto);
      expect(result).toHaveProperty('id', 'm-1');
      expect(mockPrisma.milestone.create).toHaveBeenCalled();
      expect(mockPrisma.babyMon.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: { currentXp: { increment: 10 } } })
      );
      expect(mockXp.checkAndProcessLevelUp).toHaveBeenCalledWith('bm-1');
      expect(mockBadges.checkAndAwardBadges).toHaveBeenCalledWith('bm-1', 'user-1');
    });

    it('should throw NotFoundException when BabyMon not found', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValueOnce(null);
      await expect(service.create('bm-1', 'user-1', dto)).rejects.toThrow(NotFoundException);
    });

    it('should handle soft-deleted BabyMon', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValueOnce(null);
      await expect(service.create('bm-1', 'user-1', dto)).rejects.toThrow(NotFoundException);
    });

    it('should award 10 XP per milestone', async () => {
      await service.create('bm-1', 'user-1', dto);
      expect(mockPrisma.milestone.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ xpAwarded: 10 }) })
      );
    });
  });

  describe('findAll', () => {
    it('should return paginated milestones', async () => {
      const result = await service.findAll('bm-1', 'user-1', 0, 20);
      expect(result).toHaveProperty('items');
      expect(Array.isArray(result.items)).toBe(true);
      expect(result).toHaveProperty('total');
    });

    it('should apply history limit for FREE tier', async () => {
      mockSubscriptions.getHistoryLimitDays.mockResolvedValueOnce(7);
      const result = await service.findAll('bm-1', 'user-1', 0, 20);
      expect(result).toHaveProperty('items');
      expect(result).toHaveProperty('total');
    });
  });

  describe('update', () => {
    it('should update a milestone', async () => {
      const dto = { title: 'Updated milestone' };
      const result = await service.update('m-1', 'user-1', dto);
      expect(result).toHaveProperty('id', 'm-1');
    });
  });

  describe('delete', () => {
    it('should soft-delete a milestone', async () => {
      const result = await service.delete('m-1', 'user-1');
      expect(result.success).toBe(true);
    });
  });
});
