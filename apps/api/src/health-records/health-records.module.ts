import { Module } from '@nestjs/common';
import { HealthRecordsService } from './health-records.service';
import { HealthRecordsController } from './health-records.controller';
import { BadgesModule } from '../badges/badges.module';
import { XpModule } from '../xp/xp.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Module({
  imports: [BadgesModule, XpModule, BabyMonModule, SubscriptionsModule],
  controllers: [HealthRecordsController],
  providers: [HealthRecordsService],
  exports: [HealthRecordsService],
})
export class HealthRecordsModule {}
