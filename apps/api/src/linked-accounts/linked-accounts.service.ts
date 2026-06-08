import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LinkedAccountsService {
  constructor(private prisma: PrismaService) {}

  async getLinkedAccounts(userId: string) {
    // Get accounts where user is userA or userB
    const linkedAccounts = await this.prisma.linkedAccount.findMany({
      where: {
        OR: [
          { userAId: userId, status: 'LINKED' },
          { userBId: userId, status: 'LINKED' },
        ],
      },
      include: {
        userA: {
          select: { id: true, email: true, name: true },
        },
        userB: {
          select: { id: true, email: true, name: true },
        },
      },
    });

    // Format response
    return linkedAccounts.map((account) => {
      const isUserA = account.userAId === userId;
      return {
        id: account.id,
        partner: isUserA ? account.userB : account.userA,
        linkedAt: account.linkedAt,
      };
    });
  }

  async getPendingInvitations(userId: string) {
    const pending = await this.prisma.linkedAccount.findMany({
      where: {
        OR: [
          { userAId: userId, status: 'PENDING' },
          { userBId: userId, status: 'PENDING' },
        ],
      },
      include: {
        userA: {
          select: { id: true, email: true, name: true },
        },
        userB: {
          select: { id: true, email: true, name: true },
        },
      },
    });

    return pending.map((invitation) => {
      const isUserA = invitation.userAId === userId;
      return {
        id: invitation.id,
        from: isUserA ? invitation.userB : invitation.userA,
        to: isUserA ? invitation.userA : invitation.userB,
        status: invitation.status,
        createdAt: invitation.createdAt,
        expiresAt: invitation.expiresAt,
      };
    });
  }

  async invitePartner(userId: string, partnerEmail: string) {
    // Find partner user
    const partner = await this.prisma.user.findUnique({
      where: { email: partnerEmail },
    });

    if (!partner) {
      throw new NotFoundException('User not found with this email');
    }

    if (partner.id === userId) {
      throw new BadRequestException('Cannot link to yourself');
    }

    // Check if already linked
    const existing = await this.prisma.linkedAccount.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: partner.id },
          { userAId: partner.id, userBId: userId },
        ],
      },
    });

    if (existing) {
      if (existing.status === 'LINKED') {
        throw new BadRequestException('Already linked with this user');
      }
      if (existing.status === 'PENDING') {
        throw new BadRequestException('Invitation already pending');
      }
    }

    // Create invitation (expires in 7 days)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const invitation = await this.prisma.linkedAccount.create({
      data: {
        userAId: userId,
        userBId: partner.id,
        status: 'PENDING',
        expiresAt,
      },
      include: {
        userB: {
          select: { id: true, email: true, name: true },
        },
      },
    });

    return {
      id: invitation.id,
      partner: invitation.userB,
      status: invitation.status,
      expiresAt: invitation.expiresAt,
    };
  }

  async respondToInvitation(userId: string, invitationId: string, accept: boolean) {
    const invitation = await this.prisma.linkedAccount.findUnique({
      where: { id: invitationId },
    });

    if (!invitation) {
      throw new NotFoundException('Invitation not found');
    }

    // Verify user is the invitee (userB)
    if (invitation.userBId !== userId) {
      throw new ForbiddenException('You cannot respond to this invitation');
    }

    if (invitation.status !== 'PENDING') {
      throw new BadRequestException('Invitation already processed');
    }

    // Check if expired
    if (invitation.expiresAt && invitation.expiresAt < new Date()) {
      throw new BadRequestException('Invitation has expired');
    }

    if (accept) {
      return this.prisma.linkedAccount.update({
        where: { id: invitationId },
        data: {
          status: 'LINKED',
          linkedAt: new Date(),
          expiresAt: null,
        },
      });
    } else {
      return this.prisma.linkedAccount.update({
        where: { id: invitationId },
        data: {
          status: 'REJECTED',
          expiresAt: null,
        },
      });
    }
  }

  async removeLink(userId: string, linkId: string) {
    const link = await this.prisma.linkedAccount.findUnique({
      where: { id: linkId },
    });

    if (!link) {
      throw new NotFoundException('Link not found');
    }

    // Verify user is part of this link
    if (link.userAId !== userId && link.userBId !== userId) {
      throw new ForbiddenException('You are not part of this link');
    }

    // Get BabyMon IDs that were shared in this link before deleting
    const sharedBabyMons = await this.prisma.linkedBabyMon.findMany({
      where: {
        OR: [
          { userId: link.userAId },
          { userId: link.userBId },
        ],
      },
      select: { babymonId: true },
    });
    const sharedBabyMonIds = sharedBabyMons.map(b => b.babymonId);

    // Delete link
    await this.prisma.linkedAccount.delete({
      where: { id: linkId },
    });

    // Remove only the LinkedBabyMon entries that were shared in this specific link
    // (i.e., the BabyMons that were accessible to both users via this link)
    if (sharedBabyMonIds.length > 0) {
      await this.prisma.linkedBabyMon.deleteMany({
        where: {
          babymonId: { in: sharedBabyMonIds },
          userId: { in: [link.userAId, link.userBId] },
        },
      });
    }

    return { message: 'Link removed successfully' };
  }

  async getPartnersForBabyMon(userId: string, babyMonId: string) {
    // Verify BabyMon exists
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Check access
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

    // Get all linked accounts for the BabyMon's owner
    const ownerId = babyMon.ownerUserId;
    const linkedAccounts = await this.prisma.linkedAccount.findMany({
      where: {
        OR: [
          { userAId: ownerId, status: 'LINKED' },
          { userBId: ownerId, status: 'LINKED' },
        ],
      },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
    });

    // Return only the partner info (not the owner)
    return linkedAccounts.map((account) => {
      const isOwnerA = account.userAId === ownerId;
      return {
        id: account.id,
        partner: isOwnerA ? account.userB : account.userA,
        linkedAt: account.linkedAt,
      };
    });
  }

  async linkBabyMonToUser(userId: string, babymonId: string, access: 'READ' | 'EDIT' | 'ADMIN' = 'EDIT') {
    // Verify BabyMon exists
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babymonId },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Verify user is linked to BabyMon owner
    const link = await this.prisma.linkedAccount.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
          { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
        ],
      },
    });

    if (!link) {
      throw new ForbiddenException('You are not linked to this BabyMon owner');
    }

    return this.prisma.linkedBabyMon.upsert({
      where: {
        userId_babymonId: {
          userId,
          babymonId,
        },
      },
      create: {
        userId,
        babymonId,
        access,
      },
      update: {
        access,
      },
    });
  }
}
