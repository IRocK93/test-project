import { Injectable, Logger, BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { S3Service } from '../s3/s3.service';
import { PrismaService } from '../prisma/prisma.service';
import { MAX_UPLOAD_SIZE_BYTES } from '../common/app-constants';

export interface UploadResult {
  id: string;
  url: string;
  thumbnailUrl?: string;
  fileName: string;
  fileType: string;
  fileSize: number;
  createdAt: Date;
}

@Injectable()
export class MediaService {
  private readonly logger = new Logger(MediaService.name);

  constructor(
    private s3Service: S3Service,
    private prisma: PrismaService,
  ) {}

  async uploadMedia(
    userId: string,
    babyMonId: string,
    fileName: string,
    fileBuffer: Buffer,
    contentType: string,
    fileSize: number,
  ): Promise<UploadResult> {
    // Verify user has access to BabyMon
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Check if user is owner or linked
    if (babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: {
          OR: [
            { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
            { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
          ],
        },
      });

      if (!linked) {
        throw new ForbiddenException('Access denied');
      }
    }

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/quicktime'];
    if (!allowedTypes.includes(contentType)) {
      throw new BadRequestException('Invalid file type. Allowed: JPEG, PNG, GIF, WebP, MP4, MOV');
    }

    // Validate file size (max 50MB)
    if (fileSize > MAX_UPLOAD_SIZE_BYTES) {
      throw new BadRequestException('File too large. Maximum size is 50MB');
    }

    // Upload to S3
    const url = await this.s3Service.uploadFile(
      userId,
      babyMonId,
      fileName,
      fileBuffer,
      contentType,
    );

    // Create media record in database
    const media = await this.prisma.media.create({
      data: {
        babyMonId,
        userId,
        fileName,
        fileType: contentType,
        fileSize,
        s3Key: this.s3Service.extractKeyFromUrl(url),
        url,
      },
    });

    return {
      id: media.id,
      url: media.url,
      fileName: media.fileName,
      fileType: media.fileType,
      fileSize: media.fileSize,
      createdAt: media.createdAt,
    };
  }

  async getPresignedUploadUrl(
    userId: string,
    babyMonId: string,
    fileName: string,
    contentType: string,
  ): Promise<{ uploadUrl: string; key: string }> {
    // Verify access
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    if (babyMon.ownerUserId !== userId) {
      throw new ForbiddenException('Only the owner can upload media');
    }

    // Validate file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/quicktime'];
    if (!allowedTypes.includes(contentType)) {
      throw new BadRequestException('Invalid file type');
    }

    const key = `users/${userId}/babymons/${babyMonId}/${Date.now()}-${fileName}`;

    // Generate presigned URL
    const uploadUrl = await this.s3Service.getSignedUploadUrl(userId, babyMonId, fileName, contentType);

    return { uploadUrl, key };
  }

  async getMediaForBabyMon(babyMonId: string, userId: string, skip?: number, take?: number): Promise<any[]> {
    // Verify access
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    if (babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: {
          OR: [
            { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
            { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
          ],
        },
      });

      if (!linked) {
        throw new ForbiddenException('Access denied');
      }
    }

    return this.prisma.media.findMany({
      where: { babyMonId },
      orderBy: { createdAt: 'desc' },
      skip,
      take,
    });
  }

  async deleteMedia(mediaId: string, userId: string): Promise<void> {
    const media = await this.prisma.media.findUnique({
      where: { id: mediaId },
      include: { babymon: true },
    });

    if (!media) {
      throw new NotFoundException('Media not found');
    }

    // Only owner can delete
    if (media.babymon.ownerUserId !== userId) {
      throw new ForbiddenException('Only the owner can delete media');
    }

    // Delete from S3
    try {
      await this.s3Service.deleteFile(media.s3Key);
    } catch (error) {
      this.logger.warn(`Failed to delete S3 file: ${error}`);
    }

    // Delete from database
    await this.prisma.media.delete({
      where: { id: mediaId },
    });
  }
}
