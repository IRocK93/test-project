import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto, DeleteAccountDto } from './dto/user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
        verifiedAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
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
        throw new BadRequestException('Email already in use');
      }
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        name: dto.name,
        email: dto.email,
      },
      select: {
        id: true,
        email: true,
        name: true,
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
      throw new NotFoundException('User not found');
    }

    // Import bcrypt here to avoid circular dependency
    const { default: bcrypt } = await import('bcrypt');
    const isValid = await bcrypt.compare(dto.password, user.passwordHash || '');

    if (!isValid) {
      throw new BadRequestException('Invalid password');
    }

    // Soft delete user and all related data
    const result = await this.prisma.$transaction(async (tx) => {
      // Delete refresh tokens
      await tx.refreshToken.deleteMany({
        where: { userId },
      });

      // Get all babyMons owned by user
      const babyMons = await tx.babyMon.findMany({
        where: { ownerUserId: userId },
        select: { id: true },
      });

      // Delete all related data for each BabyMon
      for (const bm of babyMons) {
        await tx.entryChangeProposal.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.auditLog.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.badge.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.stageContent.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.milestone.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.feedLog.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.healthRecord.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.linkedBabyMon.deleteMany({
          where: { babymonId: bm.id },
        });
        await tx.babyMon.delete({
          where: { id: bm.id },
        });
      }

      // Delete linked accounts
      await tx.linkedAccount.deleteMany({
        where: {
          OR: [{ userAId: userId }, { userBId: userId }],
        },
      });

      // Delete subscriptions
      await tx.subscription.deleteMany({
        where: { userId },
      });

      // Soft delete user
      await tx.user.update({
        where: { id: userId },
        data: { deletedAt: new Date() },
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
        createdAt: true,
        verifiedAt: true,
      },
    });
  }
}
