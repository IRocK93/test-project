import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';

@ApiTags('subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private subscriptionsService: SubscriptionsService) {}

  @Get('current')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current subscription status' })
  async getCurrent(@CurrentUser('id') userId: string) {
    return this.subscriptionsService.getCurrentSubscription(userId);
  }

  @Public()
  @Post('dev-override-trial')
  @ApiOperation({ summary: 'Dev only: Override trial period (disabled in production)' })
  async devOverrideTrial(@Body() body: { userId: string; days: number }) {
    // Only allow in development
    if (process.env.NODE_ENV === 'production') {
      return { message: 'Not available in production' };
    }
    return this.subscriptionsService.devOverrideTrial(body.userId, body.days);
  }
}
