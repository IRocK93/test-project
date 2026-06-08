import { Controller, Post, Get, Body, UseGuards, Req, HttpCode, HttpStatus, RawBodyRequest, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { Request } from 'express';
import { StripeService } from './stripe.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('subscriptions')
@Controller('subscriptions')
export class StripeController {
  constructor(private stripeService: StripeService) {}

  @Public()
  @Post('webhook')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Stripe webhook endpoint' })
  async handleWebhook(@Req() req: any) {
    const signature = req.headers['stripe-signature'];
    if (!signature) {
      throw new BadRequestException('No Stripe signature provided');
    }

    // Get raw body - either from our middleware or directly from express
    const rawBody = req.rawBody || (req.body && Buffer.isBuffer(req.body) ? req.body.toString('utf8') : JSON.stringify(req.body));
    if (!rawBody) {
      throw new BadRequestException('No raw body provided');
    }

    return this.stripeService.handleWebhook(rawBody, signature as string);
  }

  @Post('create-checkout-session')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Create Stripe checkout session' })
  async createCheckoutSession(
    @CurrentUser('id') userId: string,
    @Body() body: { priceId: string },
  ) {
    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    const successUrl = `${baseUrl}/subscription/success?session_id={CHECKOUT_SESSION_ID}`;
    const cancelUrl = `${baseUrl}/subscription/canceled`;

    const session = await this.stripeService.createCheckoutSession(
      userId,
      body.priceId,
      successUrl,
      cancelUrl,
    );

    return { url: session.url };
  }

  @Post('create-portal-session')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Create Stripe billing portal session' })
  async createPortalSession(@CurrentUser('id') userId: string) {
    const baseUrl = process.env.FRONTEND_URL || 'http://localhost:5173';
    const returnUrl = `${baseUrl}/settings`;

    const session = await this.stripeService.createPortalSession(userId, returnUrl);
    return { url: session.url };
  }

  @Post('cancel')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Cancel subscription at period end' })
  async cancelSubscription(@CurrentUser('id') userId: string) {
    return this.stripeService.cancelSubscription(userId);
  }
}
