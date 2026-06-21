import { Module } from '@nestjs/common';
import { CompanionController } from './companion.controller';
import { CompanionService } from './companion.service';
import { TierGuard } from './tier.guard';
import { ModelManifestController } from './model-manifest.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [CompanionController, ModelManifestController],
  providers: [CompanionService, TierGuard],
  exports: [CompanionService],
})
export class CompanionModule {}
