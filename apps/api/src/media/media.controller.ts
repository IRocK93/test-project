import { Controller, Get, Post, Delete, Body, Param, UseGuards, Query, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TierGuard } from '../companion/tier.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { UploadMediaDto, PresignedUrlDto } from './dto/media.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@ApiTags('media')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId/media')
export class MediaController {
  constructor(private mediaService: MediaService) {}

  @Post('upload')
  @UseGuards(TierGuard)
  @ApiOperation({ summary: 'Upload media file (PREMIUM only)' })
  @ApiConsumes('multipart/form-data')
  async upload(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() dto: UploadMediaDto,
  ) {
    if (!dto.fileData) {
      throw new BadRequestException('No file data provided');
    }

    const buffer = Buffer.from(dto.fileData, 'base64');

    return this.mediaService.uploadMedia(
      userId,
      babyMonId,
      dto.fileName || 'upload',
      buffer,
      dto.fileType || 'image/jpeg',
      dto.fileSize || buffer.length,
    );
  }

  @Post('presigned-url')
  @UseGuards(TierGuard)
  @ApiOperation({ summary: 'Get presigned URL for direct upload (PREMIUM only)' })
  async getPresignedUrl(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() dto: PresignedUrlDto,
  ) {
    return this.mediaService.getPresignedUploadUrl(
      userId,
      babyMonId,
      dto.fileName,
      dto.contentType,
    );
  }

  @Get()
  @ApiOperation({ summary: 'Get all media for BabyMon' })
  async getAll(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination?: PaginationDto,
  ) {
    return this.mediaService.getMediaForBabyMon(babyMonId, userId, pagination?.skip, pagination?.take);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete media' })
  async delete(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    await this.mediaService.deleteMedia(id, userId);
    return { message: 'Media deleted successfully' };
  }

  // ── /photos alias routes (backward compatibility with Flutter client) ──

  @Post('photos/upload')
  @UseGuards(TierGuard)
  @ApiOperation({ summary: '[DEPRECATED] Upload photo — use POST /media/upload' })
  async uploadPhoto(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() dto: UploadMediaDto,
  ) {
    if (!dto.fileData) throw new BadRequestException('No file data provided');
    const buffer = Buffer.from(dto.fileData, 'base64');
    return this.mediaService.uploadMedia(userId, babyMonId, dto.fileName || 'upload', buffer, dto.fileType || 'image/jpeg', dto.fileSize || buffer.length);
  }

  @Get('photos')
  @ApiOperation({ summary: '[DEPRECATED] Get photos — use GET /media' })
  async getPhotos(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Query() pagination?: PaginationDto,
  ) {
    return this.mediaService.getMediaForBabyMon(babyMonId, userId, pagination?.skip, pagination?.take);
  }

  @Delete('photos/:id')
  @ApiOperation({ summary: '[DEPRECATED] Delete photo — use DELETE /media/:id' })
  async deletePhoto(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
  ) {
    await this.mediaService.deleteMedia(id, userId);
    return { message: 'Photo deleted successfully' };
  }
}
