/**
 * Tracking domain barrel module.
 *
 * Aggregates all baby-tracking modules: milestones, feed-logs, sleep-logs,
 * health-records, growth, allergies, journal, and media.
 *
 * Import this single module instead of registering each tracking module
 * individually in AppModule.
 */
import { Module } from '@nestjs/common';
import { MilestonesModule } from '../milestones/milestones.module';
import { FeedLogsModule } from '../feed-logs/feed-logs.module';
import { SleepLogsModule } from '../sleep-logs/sleep-logs.module';
import { HealthRecordsModule } from '../health-records/health-records.module';
import { GrowthModule } from '../growth/growth.module';
import { MediaModule } from '../media/media.module';
import { JournalModule } from '../journal/journal.module';

@Module({
  imports: [
    MilestonesModule,
    FeedLogsModule,
    SleepLogsModule,
    HealthRecordsModule,
    GrowthModule,
    MediaModule,
    JournalModule,
  ],
  exports: [
    MilestonesModule,
    FeedLogsModule,
    SleepLogsModule,
    HealthRecordsModule,
    GrowthModule,
    MediaModule,
    JournalModule,
  ],
})
export class TrackingModule {}
