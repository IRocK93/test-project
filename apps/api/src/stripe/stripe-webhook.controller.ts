import { Controller, Post, Req, HttpCode, HttpStatus, Logger, BadRequestException } from '@nestjs/common';
import { Request } from 'express';

@Controller('webhooks')
export class StripeWebhookController {
  private readonly logger = new Logger(StripeWebhookController.name);

  constructor() {}

  @Post('stripe')
  @HttpCode(HttpStatus.OK)
  async handleStripeWebhook(@Req() req: Request): Promise<{ received: boolean }> {
    const signature = req.headers['stripe-signature'];
    if (!signature) {
      throw new BadRequestException('No Stripe signature provided');
    }

    const rawBody = (req as any).rawBody || req.body;
    if (!rawBody) {
      throw new BadRequestException('No raw body provided');
    }

    this.logger.log('Received Stripe webhook');

    return { received: true };
  }
}
