import { Injectable, ForbiddenException, NotFoundException, BadRequestException } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { PrismaService } from '../prisma/prisma.service';
import { TrialExpiredException } from '../common/exceptions/business.exception';

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
        tier: 'FREE',
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
      throw new TrialExpiredException();
    }
  }

  async getHistoryLimitDays(userId: string): Promise<number | null> {
    const { tier } = await this.getCurrentSubscription(userId);
    if (tier === 'FREE') return 7;  // FREE: last 7 days of history
    return null;  // PREMIUM: unlimited history
  }

  /**
   * Returns trials ending within the specified number of days.
   * Designed to be called by a scheduled job or dashboard check.
   * Returns { userId, trialEndDate, daysRemaining } for each trial ending soon.
   */
  async getTrialsEndingSoon(withinDays: number = 3) {
    const now = new Date();
    const cutoff = new Date(now.getTime() + withinDays * 24 * 60 * 60 * 1000);

    return this.prisma.subscription.findMany({
      where: {
        tier: 'FREE',
        isActive: true,
        trialEndDate: { gte: now, lte: cutoff },
      },
      select: {
        userId: true,
        trialEndDate: true,
        user: { select: { email: true } },
      },
    });
  }

  /**
   * Checks if the current user's trial is ending soon.
   * Returns days remaining, or null if not in trial / already premium.
   */
  async checkTrialEndingSoon(userId: string): Promise<{ daysRemaining: number; trialEndDate: Date } | null> {
    const sub = await this.prisma.subscription.findFirst({
      where: { userId, tier: 'FREE', trialEndDate: { gte: new Date() }, isActive: true },
    });
    if (!sub || !sub.trialEndDate) return null;
    const daysRemaining = Math.ceil((sub.trialEndDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
    return { daysRemaining, trialEndDate: sub.trialEndDate };
  }

  // Dev override for testing (only available in development)
  async devOverrideTrial(userId: string, days: number) {
    if (process.env.NODE_ENV === 'production') {
      throw new ForbiddenException({ message: 'Dev override not available in production', code: ErrorCode.INVALID_OPERATION });
    }

    const trialEnd = new Date();
    trialEnd.setDate(trialEnd.getDate() + days);

    await this.prisma.subscription.upsert({
      where: { id: `dev-${userId}` },
      create: {
        id: `dev-${userId}`,
        userId,
        tier: 'FREE',
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

  // ── Promo Codes ──

  async validatePromoCode(userId: string, code: string) {
    const promo = await this.prisma.promoCode.findUnique({ where: { code: code.toUpperCase() } });
    if (!promo) throw new NotFoundException({ message: 'Invalid promo code', code: ErrorCode.PROMO_CODE_INVALID });

    if (!promo.isActive) throw new BadRequestException({ message: 'This promo code is no longer active', code: ErrorCode.PROMO_CODE_EXPIRED });
    if (promo.expiresAt && new Date() > promo.expiresAt) throw new BadRequestException({ message: 'This promo code has expired', code: ErrorCode.PROMO_CODE_EXPIRED });
    if (promo.maxRedemptions && promo.currentRedemptions >= promo.maxRedemptions) {
      throw new BadRequestException({ message: 'This promo code has reached its usage limit', code: ErrorCode.PROMO_CODE_LIMIT_REACHED });
    }

    // Check user hasn't already redeemed this code
    const existing = await this.prisma.promoRedemption.findUnique({
      where: { promoCodeId_userId: { promoCodeId: promo.id, userId } },
    });
    if (existing) throw new BadRequestException({ message: 'You have already used this promo code', code: ErrorCode.PROMO_CODE_ALREADY_USED });

    return {
      code: promo.code,
      type: promo.type,
      valueDays: promo.valueDays,
      description:
        promo.type === 'TRIAL_EXTEND'
          ? `Extends your free trial by ${promo.valueDays} days`
          : `Grants ${promo.valueDays} days of Premium access`,
    };
  }

  async redeemPromoCode(userId: string, code: string) {
    // Validate first
    const promo = await this.prisma.promoCode.findUnique({ where: { code: code.toUpperCase() } });
    if (!promo) throw new NotFoundException({ message: 'Invalid promo code', code: ErrorCode.PROMO_CODE_INVALID });
    if (!promo.isActive) throw new BadRequestException({ message: 'This promo code is no longer active', code: ErrorCode.PROMO_CODE_EXPIRED });
    if (promo.expiresAt && new Date() > promo.expiresAt) throw new BadRequestException({ message: 'This promo code has expired', code: ErrorCode.PROMO_CODE_EXPIRED });
    if (promo.maxRedemptions && promo.currentRedemptions >= promo.maxRedemptions) {
      throw new BadRequestException({ message: 'This promo code has reached its usage limit', code: ErrorCode.PROMO_CODE_LIMIT_REACHED });
    }

    const existing = await this.prisma.promoRedemption.findUnique({
      where: { promoCodeId_userId: { promoCodeId: promo.id, userId } },
    });
    if (existing) throw new BadRequestException({ message: 'You have already used this promo code', code: ErrorCode.PROMO_CODE_ALREADY_USED });

    // Apply the promo
    const now = new Date();
    const accessUntil = new Date(now.getTime() + promo.valueDays * 24 * 60 * 60 * 1000);

    if (promo.type === 'TRIAL_EXTEND') {
      // Extend existing trial or create one
      const sub = await this.prisma.subscription.findFirst({
        where: { userId, isActive: true },
        orderBy: { createdAt: 'desc' },
      });

      if (sub) {
        const newEnd = new Date(Math.max(sub.trialEndDate.getTime(), now.getTime()) + promo.valueDays * 24 * 60 * 60 * 1000);
        await this.prisma.subscription.update({
          where: { id: sub.id },
          data: { trialEndDate: newEnd },
        });
      } else {
        await this.prisma.subscription.create({
          data: { id: `promo-${userId}-${Date.now()}`, userId, tier: 'FREE', trialStartDate: now, trialEndDate: accessUntil, isActive: true },
        });
      }
    } else if (promo.type === 'FULL_PREMIUM') {
      // Grant PREMIUM tier with expiry
      const sub = await this.prisma.subscription.findFirst({
        where: { userId, isActive: true },
        orderBy: { createdAt: 'desc' },
      });

      if (sub) {
        await this.prisma.subscription.update({
          where: { id: sub.id },
          data: { tier: 'PREMIUM', trialEndDate: accessUntil },
        });
      } else {
        await this.prisma.subscription.create({
          data: { id: `promo-${userId}-${Date.now()}`, userId, tier: 'PREMIUM', trialStartDate: now, trialEndDate: accessUntil, isActive: true },
        });
      }
    }

    // Record redemption
    await this.prisma.promoRedemption.create({ data: { promoCodeId: promo.id, userId } });
    await this.prisma.promoCode.update({
      where: { id: promo.id },
      data: { currentRedemptions: { increment: 1 } },
    });

    return {
      success: true,
      type: promo.type,
      valueDays: promo.valueDays,
      accessUntil,
    };
  }
}
