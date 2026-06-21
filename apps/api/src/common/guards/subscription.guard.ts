import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { SubscriptionsService } from '../../subscriptions/subscriptions.service';

/**
 * Guard that enforces subscription write access.
 * Throws ForbiddenException with TRIAL_EXPIRED code if the user's
 * trial has ended or subscription has lapsed.
 *
 * Apply with @UseGuards(SubscriptionGuard) on controllers or routes
 * that create/update/delete data.
 */
@Injectable()
export class SubscriptionGuard implements CanActivate {
  constructor(private subscriptionsService: SubscriptionsService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id;
    if (!userId) return true; // Let JwtAuthGuard handle unauthenticated
    await this.subscriptionsService.checkWriteAccess(userId);
    return true;
  }
}
