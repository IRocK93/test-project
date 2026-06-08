import { Module } from '@nestjs/common';
import { StageContentService } from './stage-content.service';
import { StageContentController } from './stage-content.controller';

@Module({
  controllers: [StageContentController],
  providers: [StageContentService],
  exports: [StageContentService],
})
export class StageContentModule {}
