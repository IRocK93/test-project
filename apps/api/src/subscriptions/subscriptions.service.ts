import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SubscriptionsService {
  constructor(private prisma: PrismaService) {}

  async getCurrentSubscription(userId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    if (!subscription) {
      return {
        tier: 'CORE',
        trialActive: false,
        hasSubscription: false,
      };
    }

    // Check if it's a trial (no stripe subscription)
    if (!subscription.stripeSubscriptionId) {
      const now = new Date();
      const trialEnd = new Date(subscription.trialEndDate);
      const trialActive = trialEnd > now;

      return {
        tier: subscription.tier,
        trialActive,
        hasSubscription: false,
        trialEndDate: subscription.trialEndDate,
        daysRemaining: trialActive ? Math.ceil((trialEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)) : 0,
      };
    }

    // Real subscription
    const now = new Date();
    const periodEnd = subscription.currentPeriodEnd ? new Date(subscription.currentPeriodEnd) : null;
    const isActive = periodEnd ? periodEnd > now : true;

    return {
      tier: subscription.tier,
      trialActive: false,
      hasSubscription: isActive,
      periodEnd: subscription.currentPeriodEnd,
      cancelAtPeriodEnd: subscription.cancelAtPeriodEnd,
      daysRemaining: periodEnd ? Math.ceil((periodEnd.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)) : 0,
    };
  }

  async canWrite(userId: string): Promise<{ canWrite: boolean; reason?: string }> {
    const subscription = await this.getCurrentSubscription(userId);

    // If has active Stripe subscription, can write
    if (subscription.hasSubscription) {
      return { canWrite: true };
    }

    // If trial is active, can write
    if (subscription.trialActive) {
      return { canWrite: true };
    }

    return {
      canWrite: false,
      reason: 'Trial expired. Please subscribe to continue tracking your parenting journey.',
    };
  }

  async checkWriteAccess(userId: string) {
    const { canWrite, reason } = await this.canWrite(userId);
    if (!canWrite) {
      throw new ForbiddenException({
        message: reason,
        code: 'TRIAL_EXPIRED',
        error: 'Payment Required',
      });
    }
  }

  // Dev override for testing (only available in development)
  async devOverrideTrial(userId: string, days: number) {
    if (process.env.NODE_ENV === 'production') {
      throw new ForbiddenException('Dev override not available in production');
    }

    const trialEnd = new Date();
    trialEnd.setDate(trialEnd.getDate() + days);

    await this.prisma.subscription.upsert({
      where: { id: `dev-${userId}` },
      create: {
        id: `dev-${userId}`,
        userId,
        tier: 'CORE',
        trialStartDate: new Date(),
        trialEndDate: trialEnd,
        isActive: true,
      },
      update: {
        trialEndDate: trialEnd,
      },
    });

    return {
      message: `Trial extended by ${days} days`,
      newTrialEnd: trialEnd,
    };
  }

  async getSubscriptionByUserId(userId: string) {
    return this.prisma.subscription.findFirst({
      where: { userId, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}
