import { Module } from '@nestjs/common';
import { MilestonesService } from './milestones.service';
import { MilestonesController } from './milestones.controller';
import { BadgesModule } from '../badges/badges.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';

@Module({
  imports: [BadgesModule, BabyMonModule],
  controllers: [MilestonesController],
  providers: [MilestonesService],
  exports: [MilestonesService],
})
export class MilestonesModule {}
