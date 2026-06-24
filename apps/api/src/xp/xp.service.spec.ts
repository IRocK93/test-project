import { Test, TestingModule } from '@nestjs/testing';
import { XpService, xpForNextLevel, getLevelName, isPhaseMilestone } from './xp.service';
import { PrismaService } from '../prisma/prisma.service';

describe('XpService', () => {
  let service: XpService;

  const mockPrisma = {
    babyMon: { findUnique: jest.fn(), update: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [XpService, { provide: PrismaService, useValue: mockPrisma }],
    }).compile();
    service = module.get<XpService>(XpService);
    jest.clearAllMocks();
  });

  describe('xpForNextLevel (pure function)', () => {
    it('should return 50 XP for stages 1-5', () => {
      expect(xpForNextLevel(1)).toBe(50);
      expect(xpForNextLevel(5)).toBe(50);
    });
    it('should return 75 XP for stages 6-15', () => {
      expect(xpForNextLevel(10)).toBe(75);
    });
    it('should return 100 XP for stages 16-25', () => {
      expect(xpForNextLevel(20)).toBe(100);
    });
    it('should return 250 XP for stages 46-50', () => {
      expect(xpForNextLevel(49)).toBe(250);
    });
    it('should handle stage 0 gracefully', () => {
      expect(xpForNextLevel(0)).toBe(50);
    });
  });

  describe('getLevelName (pure function)', () => {
    it('should return themed names for known levels', () => {
      expect(getLevelName(1)).toBe('Little Seed');
      expect(getLevelName(5)).toBe('Dewdrop');
      expect(getLevelName(25)).toBe('No-Sayer');
      expect(getLevelName(50)).toBe('LUMINARY');
    });
    it('should return fallback for unknown levels', () => {
      expect(getLevelName(99)).toBe('Level 99');
    });
  });

  describe('isPhaseMilestone (pure function)', () => {
    it('should return true for every 5th level', () => {
      expect(isPhaseMilestone(5)).toBe(true);
      expect(isPhaseMilestone(10)).toBe(true);
      expect(isPhaseMilestone(45)).toBe(true);
    });
    it('should return false for non-milestone levels', () => {
      expect(isPhaseMilestone(3)).toBe(false);
      expect(isPhaseMilestone(7)).toBe(false);
    });
    it('should return false for level 50 (max level)', () => {
      expect(isPhaseMilestone(50)).toBe(false);
    });
    it('should return false for level 0', () => {
      expect(isPhaseMilestone(0)).toBe(false);
    });
  });

  describe('checkAndProcessLevelUp', () => {
    it('should return leveledUp false when BabyMon not found', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue(null);
      const result = await service.checkAndProcessLevelUp('babymon-1');
      expect(result.leveledUp).toBe(false);
    });

    it('should level up when XP exceeds threshold', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        currentXp: 60,
        currentStage: 1,
      });
      mockPrisma.babyMon.update.mockResolvedValue({});

      const result = await service.checkAndProcessLevelUp('babymon-1');

      expect(result.leveledUp).toBe(true);
      expect(result.newStage).toBe(2);
      expect(result.levelName).toBe('Tiny Gripper');
      expect(mockPrisma.babyMon.update).toHaveBeenCalledWith({
        where: { id: 'babymon-1' },
        data: { currentStage: 2, currentXp: 10 },
      });
    });

    it('should handle multi-hop level-ups', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        currentXp: 500,
        currentStage: 1,
      });
      mockPrisma.babyMon.update.mockResolvedValue({});

      const result = await service.checkAndProcessLevelUp('babymon-1');

      expect(result.leveledUp).toBe(true);
      expect(result.newStage).toBeGreaterThan(5); // Should advance multiple levels
    });

    it('should detect phase milestones', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        currentXp: 400,
        currentStage: 1,
      });
      mockPrisma.babyMon.update.mockResolvedValue({});

      const result = await service.checkAndProcessLevelUp('babymon-1');

      expect(result.isPhaseMilestone).toBe(true);
    });

    it('should not level up when XP is insufficient', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        currentXp: 30,
        currentStage: 1,
      });

      const result = await service.checkAndProcessLevelUp('babymon-1');

      expect(result.leveledUp).toBe(false);
    });

    it('should cap at level 50', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        currentXp: 99999,
        currentStage: 49,
      });
      mockPrisma.babyMon.update.mockResolvedValue({});

      const result = await service.checkAndProcessLevelUp('babymon-1');

      expect(result.newStage).toBe(50);
      expect(result.levelName).toBe('LUMINARY');
    });
  });
});
