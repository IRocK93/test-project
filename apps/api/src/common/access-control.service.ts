import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AccessLevel, AccessCheckResult } from './access-control.types';

@Injectable()
export class AccessControlService {
  constructor(private prisma: PrismaService) {}

  async checkAccess(userId: string, babyMonId: string): Promise<AccessCheckResult> {
    // 1. Check if user owns the BabyMon
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
      select: { ownerUserId: true },
    });

    if (!babyMon) {
      return { hasAccess: false, level: null, babyMonId, userId };
    }

    // Owner has EDIT access
    if (babyMon.ownerUserId === userId) {
      return { hasAccess: true, level: AccessLevel.EDIT, babyMonId, userId };
    }

    // 2. Check if user is a linked co-parent
    const linked = await this.prisma.linkedBabyMon.findFirst({
      where: {
        babymonId: babyMonId,
        userId: userId,
      },
    });

    if (linked) {
      // Access is either 'VIEW' or 'EDIT' based on the field
      const level = linked.access === 'EDIT' ? AccessLevel.EDIT : AccessLevel.VIEW;
      return { hasAccess: true, level, babyMonId, userId };
    }

    return { hasAccess: false, level: null, babyMonId, userId };
  }
}