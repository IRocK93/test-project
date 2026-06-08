import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { PrismaService } from '../prisma/prisma.service';

describe('HealthController', () => {
  let controller: HealthController;

  beforeEach(async () => {
    const mockPrisma = {
      $queryRaw: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  describe('check', () => {
    it('should return ok status when database is connected', async () => {
      const mockPrisma = {
        $queryRaw: jest.fn().mockResolvedValue([]),
      };

      // Replace the prisma service with our mock
      (controller as any).prisma = mockPrisma;

      const result = await controller.check();

      expect(result.status).toBe('ok');
      expect(result.services.database).toBe('connected');
    });
  });

  describe('live', () => {
    it('should return ok for liveness probe', async () => {
      const result = await controller.live();
      expect(result.status).toBe('ok');
    });
  });

  describe('ready', () => {
    it('should return ready true when DB is connected', async () => {
      const mockPrisma = {
        $queryRaw: jest.fn().mockResolvedValue([]),
      };
      (controller as any).prisma = mockPrisma;

      const result = await controller.ready();
      expect(result.ready).toBe(true);
    });
  });
});
