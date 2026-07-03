import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { SubscriptionsService } from './subscriptions.service';
import { PrismaService } from '../prisma/prisma.service';

describe('SubscriptionsService', () => {
  let service: SubscriptionsService;

  const mockPrisma = {
    subscription: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      upsert: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
      { provide: ConfigService, useValue: { get: jest.fn(() => undefined) } },
        SubscriptionsService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<SubscriptionsService>(SubscriptionsService);
    jest.clearAllMocks();
  });

  describe('getCurrentSubscription', () => {
    it('should return FREE with no access when no subscription exists', async () => {
      mockPrisma.subscription.findFirst.mockResolvedValue(null);

      const result = await service.getCurrentSubscription('user-1');

      expect(result.tier).toBe('FREE');
      expect(result.trialActive).toBe(false);
      expect(result.hasSubscription).toBe(false);
    });

    it('should return trial active when subscription has no stripe ID and trial not expired', async () => {
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 7);
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'FREE',
        stripeSubscriptionId: null,
        trialEndDate: futureDate,
        currentPeriodEnd: null,
      });

      const result = await service.getCurrentSubscription('user-1');

      expect(result.tier).toBe('FREE');
      expect(result.trialActive).toBe(true);
    });

    it('should return trial expired when trial end date has passed', async () => {
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - 7);
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'FREE',
        stripeSubscriptionId: null,
        trialEndDate: pastDate,
        currentPeriodEnd: null,
      });

      const result = await service.getCurrentSubscription('user-1');

      expect(result.trialActive).toBe(false);
    });

    it('should return hasSubscription true for active Stripe subscription', async () => {
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 30);
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'PREMIUM',
        stripeSubscriptionId: 'sub_123',
        trialEndDate: null,
        currentPeriodEnd: futureDate,
      });

      const result = await service.getCurrentSubscription('user-1');

      expect(result.tier).toBe('PREMIUM');
      expect(result.hasSubscription).toBe(true);
    });

    it('should return hasSubscription false when Stripe period has expired', async () => {
      const pastDate = new Date();
      pastDate.setDate(pastDate.getDate() - 30);
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'PREMIUM',
        stripeSubscriptionId: 'sub_123',
        trialEndDate: null,
        currentPeriodEnd: pastDate,
      });

      const result = await service.getCurrentSubscription('user-1');

      expect(result.hasSubscription).toBe(false);
    });
  });

  describe('getHistoryLimitDays', () => {
    it('should return 7 for FREE users', async () => {
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'FREE',
        stripeSubscriptionId: null,
        trialEndDate: new Date(Date.now() + 86400000),
        currentPeriodEnd: null,
      });

      const result = await service.getHistoryLimitDays('user-1');

      expect(result).toBe(7);
    });

    it('should return null for PREMIUM users (unlimited)', async () => {
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + 30);
      mockPrisma.subscription.findFirst.mockResolvedValue({
        tier: 'PREMIUM',
        stripeSubscriptionId: 'sub_123',
        trialEndDate: null,
        currentPeriodEnd: futureDate,
      });

      const result = await service.getHistoryLimitDays('user-1');

      expect(result).toBeNull();
    });
  });

  describe('devOverrideTrial', () => {
    it('should upsert trial for a user', async () => {
      mockPrisma.subscription.findFirst.mockResolvedValue(null);
      mockPrisma.subscription.upsert.mockResolvedValue({ id: 'sub-1' });

      const result = await service.devOverrideTrial('user-1', 30);

      expect(mockPrisma.subscription.upsert).toHaveBeenCalled();
      expect(result).toBeDefined();
    });
  });
});
