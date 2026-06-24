import { Module } from '@nestjs/common';
import { SleepLogsController } from './sleep-logs.controller';
import { SleepLogsService } from './sleep-logs.service';
import { BadgesModule } from '../badges/badges.module';
import { XpModule } from '../xp/xp.module';
import { PrismaModule } from '../prisma/prisma.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Module({
  imports: [BadgesModule, XpModule, PrismaModule, BabyMonModule, SubscriptionsModule],
  controllers: [SleepLogsController],
  providers: [SleepLogsService],
  exports: [SleepLogsService],
})
export class SleepLogsModule {}
