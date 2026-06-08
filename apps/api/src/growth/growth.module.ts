import { Module } from '@nestjs/common';
import { GrowthController } from './growth.controller';
import { GrowthService } from './growth.service';
import { BabyMonModule } from '../baby-mon/baby-mon.module';

@Module({
  controllers: [GrowthController],
  imports: [BabyMonModule],
  providers: [GrowthService],
  exports: [GrowthService],
})
export class GrowthModule {}
