import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

/**
 * PhotosController provides /photos aliases for the Flutter app which calls
 * /api/baby-mons/:babyMonId/photos instead of /media
 */
@ApiTags('photos')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class PhotosController {
  constructor(private mediaService: MediaService) {}

  @Post('baby-mons/:babyMonId/photos')
  @ApiOperation({ summary: 'Upload a photo (base64)' })
  async uploadPhoto(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
    @Body() body: { fileName: string; fileType: string; fileData: string },
  ) {
    const buffer = Buffer.from(body.fileData, 'base64');
    return this.mediaService.uploadMedia(
      req.user.id,
      babyMonId,
      body.fileName,
      buffer,
      body.fileType,
      buffer.length,
    );
  }

  @Get('baby-mons/:babyMonId/photos')
  @ApiOperation({ summary: 'Get all photos for a BabyMon' })
  async getPhotos(
    @Request() req: any,
    @Param('babyMonId') babyMonId: string,
  ) {
    return this.mediaService.getMediaForBabyMon(babyMonId, req.user.id);
  }

  @Delete('baby-mons/photos/:id')
  @ApiOperation({ summary: 'Delete a photo' })
  async deletePhoto(
    @Request() req: any,
    @Param('id') id: string,
  ) {
    return this.mediaService.deleteMedia(id, req.user.id);
  }
}