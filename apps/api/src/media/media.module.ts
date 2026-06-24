import { Module } from '@nestjs/common';
import { MediaController } from './media.controller';
import { MediaService } from './media.service';
import { S3Module } from '../s3/s3.module';
import { TierGuard } from '../companion/tier.guard';

@Module({
  imports: [S3Module],
  controllers: [MediaController],
  providers: [MediaService, TierGuard],
  exports: [MediaService],
})
export class MediaModule {}
