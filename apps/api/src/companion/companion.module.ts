import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CompanionController } from './companion.controller';
import { CompanionService } from './companion.service';
import { TierGuard } from './tier.guard';
import { ModelManifestController } from './model-manifest.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { StageCalculatorService } from '../common/stage-calculator.service';

@Module({
  imports: [PrismaModule, ConfigModule],
  controllers: [CompanionController, ModelManifestController],
  providers: [CompanionService, TierGuard, StageCalculatorService],
  exports: [CompanionService],
})
export class CompanionModule {}
