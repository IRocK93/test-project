import { Module } from '@nestjs/common';
import { MediaController } from './media.controller';
import { PhotosController } from './photos.controller';
import { MediaService } from './media.service';
import { S3Module } from '../s3/s3.module';

@Module({
  imports: [S3Module],
  controllers: [MediaController, PhotosController],
  providers: [MediaService],
  exports: [MediaService],
})
export class MediaModule {}
