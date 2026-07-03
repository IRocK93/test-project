import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { ErrorCode } from '../common/enums/error-code.enum';
import Stripe from 'stripe';

@Injectable()
export class StripeService {
  private readonly logger = new Logger(StripeService.name);
  private stripe: Stripe;
  private readonly webhookSecret: string | undefined;
  private readonly pricePremiumMonthly: string | undefined;
  private readonly pricePremiumYearly: string | undefined;

  constructor(
    private prisma: PrismaService,
    private notifications: NotificationsService,
    private configService: ConfigService,
  ) {
    const apiKey = this.configService.get('stripe.secretKey') as string | undefined;
    if (apiKey) {
      this.stripe = new Stripe(apiKey, {
        apiVersion: '2023-10-16',
      });
    } else {
      this.logger.warn('Stripe API key not configured - Stripe features disabled');
    }
    this.webhookSecret = this.configService.get('stripe.webhookSecret') as string | undefined;
    this.pricePremiumMonthly = this.configService.get('stripe.pricePremiumMonthly') as string | undefined;
    this.pricePremiumYearly = this.configService.get('stripe.pricePremiumYearly') as string | undefined;
  }

  isConfigured(): boolean {
    return !!this.stripe;
  }

  async createCustomer(userId: string, email: string, name?: string) {
    if (!this.stripe) {
      throw new BadRequestException({ message: 'Stripe is not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    const customer = await this.stripe.customers.create({
      email,
      name: name || undefined,
      metadata: {
        userId,
      },
    });

    return customer;
  }

  async createCheckoutSession(
    userId: string,
    priceId: string,
    successUrl: string,
    cancelUrl: string,
  ) {
    if (!this.stripe) {
      throw new BadRequestException({ message: 'Stripe is not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    // Get or create customer
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId, isActive: true },
    });

    let customerId = subscription?.stripeCustomerId;

    if (!customerId) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
      });
      if (user) {
        const customer = await this.createCustomer(userId, user.email, user.name || undefined);
        customerId = customer.id;
      }
    }

    const session = await this.stripe.checkout.sessions.create({
      customer: customerId,
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: successUrl,
      cancel_url: cancelUrl,
      metadata: {
        userId,
        priceId,
      },
    });

    return session;
  }

  async createPortalSession(userId: string, returnUrl: string) {
    if (!this.stripe) {
      throw new BadRequestException({ message: 'Stripe is not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    const subscription = await this.prisma.subscription.findFirst({
      where: { userId, isActive: true },
    });

    if (!subscription?.stripeCustomerId) {
      throw new BadRequestException({ message: 'No subscription found', code: ErrorCode.STRIPE_SUBSCRIPTION_NOT_FOUND });
    }

    const session = await this.stripe.billingPortal.sessions.create({
      customer: subscription.stripeCustomerId,
      return_url: returnUrl,
    });

    return session;
  }

  async handleWebhook(
    payload: Buffer,
    signature: string,
  ): Promise<{ received: boolean }> {
    if (!this.stripe) {
      throw new BadRequestException({ message: 'Stripe is not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    if (!this.webhookSecret) {
      throw new BadRequestException({ message: 'Stripe webhook secret not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(
        payload,
        signature,
        this.webhookSecret,
      );
    } catch (err: any) {
      this.logger.error(`Webhook signature verification failed: ${err.message}`);
      throw new BadRequestException({ message: 'Webhook signature verification failed', code: ErrorCode.STRIPE_WEBHOOK_INVALID });
    }

    // Check if event already processed
    const existingEvent = await this.prisma.stripeEvent.findUnique({
      where: { eventId: event.id },
    });

    if (existingEvent) {
      this.logger.log(`Event ${event.id} already processed`);
      return { received: true };
    }

    // Process event
    await this.handleStripeEvent(event);

    // Store processed event
    await this.prisma.stripeEvent.create({
      data: {
        eventId: event.id,
        type: event.type,
        data: JSON.stringify(event.data.object),
        processed: true,
      },
    });

    return { received: true };
  }

  private async handleStripeEvent(event: Stripe.Event) {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        await this.handleCheckoutCompleted(session);
        break;
      }
      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription;
        await this.handleSubscriptionUpdated(subscription);
        break;
      }
      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription;
        await this.handleSubscriptionDeleted(subscription);
        break;
      }
      case 'invoice.payment_failed': {
        const invoice = event.data.object as Stripe.Invoice;
        await this.handlePaymentFailed(invoice);
        break;
      }
      default:
        this.logger.log(`Unhandled event type: ${event.type}`);
    }
  }

  private async handleCheckoutCompleted(session: Stripe.Checkout.Session) {
    const userId = session.metadata?.userId;
    if (!userId) {
      this.logger.error('No userId in checkout session metadata');
      return;
    }

    const subscriptionId = session.subscription as string;
    const subscription = await this.stripe.subscriptions.retrieve(subscriptionId);
    const priceId = subscription.items.data[0]?.price.id;

    const tier = this.getTierFromPriceId(priceId);

    // Calculate period end
    const currentPeriodEnd = new Date(subscription.current_period_end * 1000);

    await this.prisma.subscription.upsert({
      where: { id: `stripe-${userId}` },
      create: {
        id: `stripe-${userId}`,
        userId,
        stripeSubscriptionId: subscriptionId,
        stripeCustomerId: session.customer as string,
        stripePriceId: priceId,
        tier,
        trialStartDate: new Date(),
        trialEndDate: currentPeriodEnd,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd,
        isActive: true,
      },
      update: {
        stripeSubscriptionId: subscriptionId,
        stripeCustomerId: session.customer as string,
        stripePriceId: priceId,
        tier,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd,
        isActive: true,
        cancelAtPeriodEnd: false,
      },
    });

    this.logger.log(`Subscription created for user ${userId}`);
  }

  private async handleSubscriptionUpdated(subscription: Stripe.Subscription) {
    const priceId = subscription.items.data[0]?.price.id;
    const tier = this.getTierFromPriceId(priceId);

    await this.prisma.subscription.updateMany({
      where: { stripeSubscriptionId: subscription.id },
      data: {
        tier,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        isActive: subscription.status === 'active',
      },
    });

    this.logger.log(`Subscription ${subscription.id} updated`);
  }

  private async handleSubscriptionDeleted(subscription: Stripe.Subscription) {
    await this.prisma.subscription.updateMany({
      where: { stripeSubscriptionId: subscription.id },
      data: {
        isActive: false,
        cancelAtPeriodEnd: false,
      },
    });

    this.logger.log(`Subscription ${subscription.id} deleted`);
  }

  private async handlePaymentFailed(invoice: Stripe.Invoice) {
    const customerId = invoice.customer as string;
    const attemptCount = invoice.attempt_count || 1;

    this.logger.warn(`Payment failed for invoice ${invoice.id} — customer ${customerId}, attempt ${attemptCount}, amount ${(invoice.amount_due || 0) / 100}`);

    // Mark subscription payment status
    if (invoice.subscription) {
      const subId = invoice.subscription as string;
      await this.prisma.subscription.updateMany({
        where: { stripeSubscriptionId: subId },
        data: { isActive: invoice.attempt_count < 4 }, // deactivate after 4 failed attempts
      });

      // Look up user and send push notification
      const subscription = await this.prisma.subscription.findFirst({
        where: { stripeSubscriptionId: subId },
        select: { userId: true, user: { select: { locale: true } } },
      });
      if (subscription?.userId) {
        this.notifications.notifyPaymentFailed(subscription.userId, attemptCount, subscription.user.locale)
          .catch((err) => this.logger.warn({ err }, 'Failed to send payment failure notification'));
      }
    }
  }

  private getTierFromPriceId(priceId: string): 'FREE' | 'PREMIUM' {
    const premiumPriceIds = [
      this.pricePremiumMonthly,
      this.pricePremiumYearly,
    ];

    if (premiumPriceIds.includes(priceId)) {
      return 'PREMIUM';
    }

    return 'FREE';
  }

  async cancelSubscription(userId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId, isActive: true, stripeSubscriptionId: { not: null } },
    });

    if (!subscription?.stripeSubscriptionId) {
      throw new BadRequestException({ message: 'No active subscription found', code: ErrorCode.STRIPE_SUBSCRIPTION_NOT_FOUND });
    }

    if (!this.stripe) {
      throw new BadRequestException({ message: 'Stripe is not configured', code: ErrorCode.STRIPE_NOT_CONFIGURED });
    }

    await this.stripe.subscriptions.update(subscription.stripeSubscriptionId, {
      cancel_at_period_end: true,
    });

    await this.prisma.subscription.update({
      where: { id: subscription.id },
      data: { cancelAtPeriodEnd: true },
    });

    return { success: true };
  }
}
