import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SubscriptionsService } from './subscriptions.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DevOverrideTrialDto, PromoCodeDto } from './dto/subscriptions.dto';
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

  @Get('plans')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get available subscription plans with Stripe price IDs' })
  async getPlans() {
    return {
      plans: [
        {
          name: 'Free',
          tier: 'FREE',
          price: 0,
          period: 'forever',
          features: [
            'Basic tracking (milestones, feeding, health)',
            'Export your data anytime',
            '1 BabyMon profile',
            '7-day history',
            'Push notifications',
            'Offline entry creation',
          ],
        },
        {
          name: 'Premium',
          tier: 'PREMIUM',
          price: 4.99,
          period: 'month',
          stripePriceId: process.env.STRIPE_PRICE_PREMIUM_MONTHLY || null,
          features: [
            'AI-powered stage content & tips',
            'Unlimited history',
            'Multiple BabyMon profiles',
            'Priority support',
            'Badge animations & effects',
            'Evolution narratives',
            'Photo album (S3 storage)',
          ],
        },
      ],
    };
  }

  @Public()
  @Post('dev-override-trial')
  @ApiOperation({ summary: 'Dev only: Override trial period (disabled in production)' })
  async devOverrideTrial(@Body() dto: DevOverrideTrialDto) {
    // Only allow in development
    if (process.env.NODE_ENV === 'production') {
      return { message: 'Not available in production' };
    }
    return this.subscriptionsService.devOverrideTrial(dto.userId, dto.days);
  }

  @Post('validate-promo')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Validate a promo code without redeeming it' })
  async validatePromo(@CurrentUser('id') userId: string, @Body() dto: PromoCodeDto) {
    return this.subscriptionsService.validatePromoCode(userId, dto.code);
  }

  @Post('redeem-promo')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Redeem a promo code and apply its benefits' })
  async redeemPromo(@CurrentUser('id') userId: string, @Body() dto: PromoCodeDto) {
    return this.subscriptionsService.redeemPromoCode(userId, dto.code);
  }
}
