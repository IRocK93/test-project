import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request, ForbiddenException, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('media')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('baby-mons/:babyMonId/media')
export class MediaController {
  constructor(private mediaService: MediaService) {}

  @Post('upload')
  @ApiOperation({ summary: 'Upload media file' })
  @ApiConsumes('multipart/form-data')
  async upload(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() body: any,
  ) {
    // Handle file upload - in NestJS would use FileInterceptor
    // For now, accept base64 or URL
    const { fileName, fileType, fileSize, fileData } = body;

    if (!fileData) {
      throw new BadRequestException('No file data provided');
    }

    // Decode base64
    const buffer = Buffer.from(fileData, 'base64');

    return this.mediaService.uploadMedia(
      userId,
      babyMonId,
      fileName || 'upload',
      buffer,
      fileType || 'image/jpeg',
      fileSize || buffer.length,
    );
  }

  @Post('presigned-url')
  @ApiOperation({ summary: 'Get presigned URL for direct upload' })
  async getPresignedUrl(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
    @Body() body: { fileName: string; contentType: string },
  ) {
    return this.mediaService.getPresignedUploadUrl(
      userId,
      babyMonId,
      body.fileName,
      body.contentType,
    );
  }

  @Get()
  @ApiOperation({ summary: 'Get all media for BabyMon' })
  async getAll(
    @CurrentUser('id') userId: string,
    @Param('babyMonId') babyMonId: string,
  ) {
    return this.mediaService.getMediaForBabyMon(babyMonId, userId);
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
}
