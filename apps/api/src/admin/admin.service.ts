import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getAllUsers(page = 1, limit = 20, role?: string) {
    const skip = (page - 1) * limit;
    const where: any = {};

    if (role) {
      where.role = role;
    }

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          isActive: true,
          verifiedAt: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      items: users,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getUserById(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        isActive: true,
        verifiedAt: true,
        createdAt: true,
        _count: {
          select: {
            babyMons: true,
            subscriptions: true,
          },
        },
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateUserStatus(userId: string, isActive: boolean) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { isActive },
      select: {
        id: true,
        email: true,
        isActive: true,
      },
    });
  }

  async updateUserRole(userId: string, role: string) {
    if (!['USER', 'ADMIN'].includes(role)) {
      throw new ForbiddenException('Invalid role');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.prisma.user.update({
      where: { id: userId },
      data: { role },
      select: {
        id: true,
        email: true,
        role: true,
      },
    });
  }

  async getAuditLogs(page = 1, limit = 20, userId?: string, babymonId?: string) {
    const skip = (page - 1) * limit;
    const where: any = {};

    if (userId) {
      where.actorUserId = userId;
    }

    if (babymonId) {
      where.babymonId = babymonId;
    }

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          actor: {
            select: { id: true, email: true, name: true },
          },
        },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      items: logs,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getSystemStats() {
    const [
      totalUsers,
      activeUsers,
      totalBabyMons,
      totalMilestones,
      totalFeedLogs,
      totalHealthRecords,
      totalSubscriptions,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { isActive: true } }),
      this.prisma.babyMon.count({ where: { deletedAt: null } }),
      this.prisma.milestone.count(),
      this.prisma.feedLog.count(),
      this.prisma.healthRecord.count(),
      this.prisma.subscription.count({ where: { isActive: true } }),
    ]);

    return {
      users: {
        total: totalUsers,
        active: activeUsers,
      },
      babyMons: {
        total: totalBabyMons,
      },
      entries: {
        milestones: totalMilestones,
        feedLogs: totalFeedLogs,
        healthRecords: totalHealthRecords,
      },
      subscriptions: {
        active: totalSubscriptions,
      },
    };
  }
}
