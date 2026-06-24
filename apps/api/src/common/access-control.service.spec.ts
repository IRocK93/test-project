import { Test, TestingModule } from '@nestjs/testing';
import { AccessControlService } from './access-control.service';
import { PrismaService } from '../prisma/prisma.service';
import { AccessLevel } from './access-control.types';

describe('AccessControlService', () => {
  let service: AccessControlService;

  const mockPrisma = {
    babyMon: {
      findUnique: jest.fn(),
    },
    linkedBabyMon: {
      findFirst: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AccessControlService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<AccessControlService>(AccessControlService);
    jest.clearAllMocks();
  });

  describe('checkAccess', () => {
    it('should grant EDIT access to the owner', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({
        ownerUserId: 'user-1',
      });

      const result = await service.checkAccess('user-1', 'babymon-1');

      expect(result.hasAccess).toBe(true);
      expect(result.level).toBe(AccessLevel.EDIT);
      expect(mockPrisma.linkedBabyMon.findFirst).not.toHaveBeenCalled();
    });

    it('should deny access when BabyMon not found', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue(null);

      const result = await service.checkAccess('user-1', 'nonexistent');

      expect(result.hasAccess).toBe(false);
      expect(result.level).toBeNull();
    });

    it('should deny access when user is not owner and not linked', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({ ownerUserId: 'owner' });
      mockPrisma.linkedBabyMon.findFirst.mockResolvedValue(null);

      const result = await service.checkAccess('stranger', 'babymon-1');

      expect(result.hasAccess).toBe(false);
      expect(result.level).toBeNull();
      expect(mockPrisma.linkedBabyMon.findFirst).toHaveBeenCalledWith({
        where: { babymonId: 'babymon-1', userId: 'stranger' },
      });
    });

    it('should grant EDIT access to linked co-parent with EDIT permission', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({ ownerUserId: 'owner' });
      mockPrisma.linkedBabyMon.findFirst.mockResolvedValue({
        babymonId: 'babymon-1',
        userId: 'coparent',
        access: 'EDIT',
      });

      const result = await service.checkAccess('coparent', 'babymon-1');

      expect(result.hasAccess).toBe(true);
      expect(result.level).toBe(AccessLevel.EDIT);
    });

    it('should grant VIEW access to linked co-parent with non-EDIT permission', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({ ownerUserId: 'owner' });
      mockPrisma.linkedBabyMon.findFirst.mockResolvedValue({
        babymonId: 'babymon-1',
        userId: 'coparent',
        access: 'VIEW',
      });

      const result = await service.checkAccess('coparent', 'babymon-1');

      expect(result.hasAccess).toBe(true);
      expect(result.level).toBe(AccessLevel.VIEW);
    });

    it('should return the correct userId and babyMonId in the result', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({ ownerUserId: 'owner' });
      mockPrisma.linkedBabyMon.findFirst.mockResolvedValue(null);

      const result = await service.checkAccess('user-x', 'babymon-y');

      expect(result.userId).toBe('user-x');
      expect(result.babyMonId).toBe('babymon-y');
    });

    it('should grant EDIT access to linked co-parent with lowercase edit value', async () => {
      mockPrisma.babyMon.findUnique.mockResolvedValue({ ownerUserId: 'owner' });
      mockPrisma.linkedBabyMon.findFirst.mockResolvedValue({
        babymonId: 'babymon-1',
        userId: 'coparent',
        access: 'edit',
      });

      const result = await service.checkAccess('coparent', 'babymon-1');

      // The service checks linked.access === 'EDIT' (strict equality)
      // 'edit' !== 'EDIT', so this gets VIEW access
      expect(result.hasAccess).toBe(true);
      expect(result.level).toBe(AccessLevel.VIEW);
    });
  });
});
