import { Injectable, CanActivate, ExecutionContext, HttpException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TierGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id;
    if (!userId) return false;

    // Dev bypass — set SKIP_TIER_GUARD=true in .env to skip subscription checks
    if (process.env.SKIP_TIER_GUARD === 'true') {
      return true;
    }

    // Check active subscription
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId },
    });

    if (!subscription) {
      throw new HttpException(
        {
          statusCode: 402,
          message: 'Premium tier required',
          code: 'UPGRADE_REQUIRED',
        },
        402,
      );
    }

    // Allow if subscription is active and tier is PREMIUM
    if (subscription.isActive && subscription.tier === 'PREMIUM') {
      return true;
    }

    // Allow during active trial (any tier with valid trialEndDate)
    if (subscription.isActive) {
      const now = new Date();
      if (subscription.trialEndDate && now < subscription.trialEndDate) {
        return true;
      }
    }

    throw new HttpException(
      {
        statusCode: 402,
        message: 'Premium tier required. Upgrade to access expert guidance, adaptive routines, and milestone tracking.',
        code: 'UPGRADE_REQUIRED',
      },
      402,
    );
  }
}
