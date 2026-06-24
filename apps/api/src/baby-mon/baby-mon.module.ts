import { Module } from '@nestjs/common';
import { BabyMonService } from './baby-mon.service';
import { BabyMonController } from './baby-mon.controller';
import { AccessControlService } from '../common/access-control.service';
import { S3Service } from '../s3/s3.service';
import { CryptoService } from '../common/crypto.service';
import { StageCalculatorService } from '../common/stage-calculator.service';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import { StageContentModule } from '../stage-content/stage-content.module';

@Module({
  imports: [SubscriptionsModule, StageContentModule],
  controllers: [BabyMonController],
  providers: [BabyMonService, AccessControlService, S3Service, CryptoService, StageCalculatorService],
  exports: [BabyMonService, AccessControlService],
})
export class BabyMonModule {}
