import { Test, TestingModule } from '@nestjs/testing';
import { BabyMonService } from './baby-mon.service';
import { PrismaService } from '../prisma/prisma.service';

describe('BabyMonService', () => {
  let service: BabyMonService;
  let prisma: any;

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
    auditLog: { create: jest.fn() },
    badge: { findMany: jest.fn() },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BabyMonService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<BabyMonService>(BabyMonService);
    prisma = module.get(PrismaService);
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
        stageStartType: 'CONCEIVED',
        conceptionDate: new Date('2024-01-01'),
      });

      const result = await service.calculateCurrentStage('1');

      expect(result).toBeDefined();
    });

    it('should throw if BabyMon not found', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue(null);

      await expect(service.calculateCurrentStage('1')).rejects.toThrow();
    });
  });
});
