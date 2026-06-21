import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TierGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id;
    if (!userId) return false;

    // Check active subscription
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId },
    });

    if (!subscription) {
      throw new ForbiddenException({
        statusCode: 402,
        message: 'AI_COMPANION tier required',
        code: 'UPGRADE_REQUIRED',
      });
    }

    // Allow if subscription is active and tier is AI_COMPANION or higher
    const allowedTiers = ['AI_COMPANION', 'EXPERT', 'ULTIMATE'];
    if (subscription.isActive && allowedTiers.includes(subscription.tier)) {
      return true;
    }

    // Allow during trial for AI_COMPANION+ tiers only
    // (During trial the tier is set to AI_COMPANION — this guards against
    //  edge cases where a CORE-tier subscription has an active trialEndDate.)
    if (subscription.isActive && allowedTiers.includes(subscription.tier)) {
      const now = new Date();
      if (subscription.trialEndDate && now < subscription.trialEndDate) {
        return true;
      }
    }

    throw new ForbiddenException({
      statusCode: 402,
      message: 'AI_COMPANION tier required. Upgrade to access expert guidance, adaptive routines, and milestone tracking.',
      code: 'UPGRADE_REQUIRED',
    });
  }
}
