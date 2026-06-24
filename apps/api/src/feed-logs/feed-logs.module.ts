import { Module } from '@nestjs/common';
import { FeedLogsService } from './feed-logs.service';
import { FeedLogsController } from './feed-logs.controller';
import { BadgesModule } from '../badges/badges.module';
import { XpModule } from '../xp/xp.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Module({
  imports: [BadgesModule, XpModule, BabyMonModule, SubscriptionsModule],
  controllers: [FeedLogsController],
  providers: [FeedLogsService],
  exports: [FeedLogsService],
})
export class FeedLogsModule {}
