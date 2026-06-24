/**
 * Infrastructure domain barrel module.
 *
 * Aggregates cross-cutting infrastructure: Prisma, S3, Mail, Notifications,
 * Subscriptions (Stripe), and Export.
 */
import { Module, Global } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { S3Module } from '../s3/s3.module';
import { MailModule } from '../mail/mail.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Global()
@Module({
  imports: [PrismaModule, S3Module, MailModule, SubscriptionsModule],
  exports: [PrismaModule, S3Module, MailModule, SubscriptionsModule],
})
export class InfrastructureModule {}
