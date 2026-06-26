import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
import { PrismaService } from '../prisma/prisma.service';
import { S3Service } from '../s3/s3.service';
import { UpdateUserDto, DeleteAccountDto } from './dto/user.dto';
import { randomBytes } from 'crypto';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    private prisma: PrismaService,
    private s3Service: S3Service,
  ) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        locale: true,
        createdAt: true,
        verifiedAt: true,
        // Excluded: passwordHash, verificationToken, verificationExpires
      },
    });

    if (!user) {
      throw new NotFoundException({ message: 'User not found', code: ErrorCode.USER_NOT_FOUND });
    }

    return user;
  }

  async updateProfile(userId: string, dto: UpdateUserDto) {
    // If email is being changed, check it's not already in use
    if (dto.email) {
      const existing = await this.prisma.user.findUnique({
        where: { email: dto.email },
      });
      if (existing && existing.id !== userId) {
        throw new BadRequestException({ message: 'Email already in use', code: ErrorCode.EMAIL_IN_USE });
      }
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        name: dto.name,
        email: dto.email,
        phone: dto.phone,
        locale: dto.locale,
      },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        locale: true,
        createdAt: true,
        verifiedAt: true,
      },
    });
  }

  async deleteAccount(userId: string, dto: DeleteAccountDto) {
    // Verify password before deletion
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({ message: 'User not found', code: ErrorCode.USER_NOT_FOUND });
    }

    // OAuth-only users have no password — allow deletion without password check
    const isOAuthUser = !user.passwordHash;
    if (!isOAuthUser) {
      const bcrypt = require('bcryptjs');
      const isValid = await bcrypt.compare(dto.password || '', user.passwordHash || '');
      if (!isValid) {
        throw new BadRequestException({ message: 'Invalid password', code: ErrorCode.INVALID_PASSWORD });
      }
    }

    // Hard-delete PII and all related data
    const anonymizedEmail = `deleted-${randomBytes(8).toString('hex')}@deleted.babymon.app`;
    const result = await this.prisma.$transaction(async (tx) => {
      // Delete refresh tokens
      await tx.refreshToken.deleteMany({ where: { userId } });

      // Get all babyMons owned by user
      const babyMons = await tx.babyMon.findMany({
        where: { ownerUserId: userId },
        select: { id: true },
      });

      // Delete S3 objects for all media associated with each BabyMon (fire-and-forget per file)
      for (const bm of babyMons) {
        const mediaItems = await tx.media.findMany({
          where: { babyMonId: bm.id },
          select: { s3Key: true },
        });
        for (const m of mediaItems) {
          this.s3Service.deleteFile(m.s3Key).catch((err) =>
            this.logger.warn({ err, key: m.s3Key }, 'S3 cleanup failed (non-critical)'),
          );
        }
      }

      // Delete all related data for each BabyMon
      for (const bm of babyMons) {
        await tx.media.deleteMany({ where: { babyMonId: bm.id } });
        await tx.entryChangeProposal.deleteMany({ where: { babymonId: bm.id } });
        await tx.auditLog.deleteMany({ where: { babymonId: bm.id } });
        await tx.badge.deleteMany({ where: { babymonId: bm.id } });
        await tx.stageContent.deleteMany({ where: { babymonId: bm.id } });
        await tx.milestone.deleteMany({ where: { babymonId: bm.id } });
        await tx.feedLog.deleteMany({ where: { babymonId: bm.id } });
        await tx.healthRecord.deleteMany({ where: { babymonId: bm.id } });
        await tx.linkedBabyMon.deleteMany({ where: { babymonId: bm.id } });
        await tx.babyMon.delete({ where: { id: bm.id } });
      }

      // Delete linked accounts
      await tx.linkedAccount.deleteMany({
        where: { OR: [{ userAId: userId }, { userBId: userId }] },
      });

      // Delete subscriptions
      await tx.subscription.deleteMany({ where: { userId } });

      // Hard-delete PII: overwrite email, name, passwordHash; keep deletedAt for audit
      await tx.user.update({
        where: { id: userId },
        data: {
          email: anonymizedEmail,
          name: null,
          passwordHash: null,
          phone: null,
          deletedAt: new Date(),
        },
      });

      return { message: 'Account deleted successfully' };
    });

    return result;
  }

  async getUserById(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        locale: true,
        createdAt: true,
        verifiedAt: true,
      },
    });
  }
}
