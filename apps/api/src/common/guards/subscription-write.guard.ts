import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { SubscriptionsService } from '../../subscriptions/subscriptions.service';

@Injectable()
export class SubscriptionWriteGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private subscriptionsService: SubscriptionsService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      return true; // Let JWT guard handle this
    }

    const { canWrite, reason } = await this.subscriptionsService.canWrite(user.id);

    if (!canWrite) {
      throw new ForbiddenException({
        message: reason,
        code: 'TRIAL_EXPIRED',
        error: 'Payment Required',
      });
    }

    return true;
  }
}
