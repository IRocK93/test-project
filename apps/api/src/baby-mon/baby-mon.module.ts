import { Module } from '@nestjs/common';
import { BabyMonService } from './baby-mon.service';
import { BabyMonController } from './baby-mon.controller';
import { AccessControlService } from '../common/access-control.service';

@Module({
  controllers: [BabyMonController],
  providers: [BabyMonService, AccessControlService],
  exports: [BabyMonService, AccessControlService],
})
export class BabyMonModule {}
