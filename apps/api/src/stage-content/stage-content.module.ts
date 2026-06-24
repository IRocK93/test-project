import { Module } from '@nestjs/common';
import { StageContentService } from './stage-content.service';
import { StageContentController } from './stage-content.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { StageCalculatorService } from '../common/stage-calculator.service';

@Module({
  imports: [PrismaModule],
  controllers: [StageContentController],
  providers: [StageContentService, StageCalculatorService],
  exports: [StageContentService],
})
export class StageContentModule {}
