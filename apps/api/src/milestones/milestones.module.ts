import { Module } from '@nestjs/common';
import { MilestonesService } from './milestones.service';
import { MilestonesController } from './milestones.controller';
import { BadgesModule } from '../badges/badges.module';
import { XpModule } from '../xp/xp.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';

@Module({
  imports: [BadgesModule, BabyMonModule, SubscriptionsModule, XpModule],
  controllers: [MilestonesController],
  providers: [MilestonesService],
  exports: [MilestonesService],
})
export class MilestonesModule {}
