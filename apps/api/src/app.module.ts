import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { LoggerModule } from 'nestjs-pino';
import { PrismaModule } from './prisma/prisma.module';
import { AuditService } from './common/audit.service';
import { StageCalculatorService } from './common/stage-calculator.service';
import configuration from './config/configuration';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { BabyMonModule } from './baby-mon/baby-mon.module';
import { MilestonesModule } from './milestones/milestones.module';
import { FeedLogsModule } from './feed-logs/feed-logs.module';
import { HealthRecordsModule } from './health-records/health-records.module';
import { AllergiesModule } from './allergies/allergies.module';
import { MedicalTeamModule } from './medical-team/medical-team.module';
import { BadgesModule } from './badges/badges.module';
import { EvolutionModule } from './evolution/evolution.module';
import { StageContentModule } from './stage-content/stage-content.module';
import { CompanionModule } from './companion/companion.module';
import { JournalModule } from './journal/journal.module';
import { ExportModule } from './export/export.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { LinkedAccountsModule } from './linked-accounts/linked-accounts.module';
import { StripeModule } from './stripe/stripe.module';
import { S3Module } from './s3/s3.module';
import { SleepLogsModule } from './sleep-logs/sleep-logs.module';
import { HealthModule } from './health/health.module';
import { MediaModule } from './media/media.module';
import { GrowthModule } from './growth/growth.module';
import { NotificationsModule } from './notifications/notifications.module';
import { MailModule } from './mail/mail.module';
import { AdminModule } from './admin/admin.module';
import { XpModule } from './xp/xp.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL || 'info',
        genReqId: () => require('crypto').randomUUID(),
        autoLogging: true,
      },
    }),
    ThrottlerModule.forRoot([
      { name: 'AUTH', ttl: 60000, limit: 5 },
      { name: 'SENSITIVE', ttl: 60000, limit: 10 },
      { name: 'DEFAULT', ttl: parseInt(process.env.RATE_LIMIT_TTL || '60000', 10), limit: parseInt(process.env.RATE_LIMIT_MAX || '100', 10) },
    ]),
    PrismaModule,
    AuthModule,
    UsersModule,
    BabyMonModule,
    MilestonesModule,
    FeedLogsModule,
    HealthRecordsModule,
    AllergiesModule,
    MedicalTeamModule,
    BadgesModule,
    EvolutionModule,
    StageContentModule,
    CompanionModule,
    JournalModule,
    ExportModule,
    SubscriptionsModule,
    LinkedAccountsModule,
    StripeModule,
    S3Module,
    SleepLogsModule,
    HealthModule,
    MediaModule,
    GrowthModule,
    NotificationsModule,
    MailModule,
    AdminModule,
    XpModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    AuditService,
    StageCalculatorService,
  ],
})
export class AppModule {}
