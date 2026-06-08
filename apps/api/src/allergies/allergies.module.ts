import { Module } from '@nestjs/common';
import { AllergiesService } from './allergies.service';
import { AllergiesController } from './allergies.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/access-control.service';
import { BabyMonModule } from '../baby-mon/baby-mon.module';

@Module({
  imports: [PrismaModule, BabyMonModule],
  controllers: [AllergiesController],
  providers: [AllergiesService, AccessControlService],
  exports: [AllergiesService],
})
export class AllergiesModule {}