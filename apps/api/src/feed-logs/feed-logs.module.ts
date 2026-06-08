import { Module } from '@nestjs/common';
import { FeedLogsService } from './feed-logs.service';
import { FeedLogsController } from './feed-logs.controller';
import { BadgesModule } from '../badges/badges.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';

@Module({
  imports: [BadgesModule, BabyMonModule],
  controllers: [FeedLogsController],
  providers: [FeedLogsService],
  exports: [FeedLogsService],
})
export class FeedLogsModule {}
