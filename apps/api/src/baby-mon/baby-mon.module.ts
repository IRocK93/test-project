import { Module } from '@nestjs/common';
import { BabyMonService } from './baby-mon.service';
import { BabyMonController } from './baby-mon.controller';
import { AccessControlService } from '../common/access-control.service';
import { S3Service } from '../s3/s3.service';

@Module({
  controllers: [BabyMonController],
  providers: [BabyMonService, AccessControlService, S3Service],
  exports: [BabyMonService, AccessControlService],
})
export class BabyMonModule {}
