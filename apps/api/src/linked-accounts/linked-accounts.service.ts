import { Injectable, NotFoundException, BadRequestException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../mail/mail.service';
import { PartnerRole } from './dto/linked-accounts.dto';

type ClientStatus = 'ACCEPTED' | 'PENDING' | 'DECLINED';
const INVITATION_TTL_DAYS = 7;

@Injectable()
export class LinkedAccountsService {
  private readonly logger = new Logger(LinkedAccountsService.name);

  constructor(
    private prisma: PrismaService,
    private mailService: MailService,
  ) {}

  // ── Reads (user-level, kept for admin / non-mobile callers) ────────────

  async getLinkedAccounts(userId: string, skip?: number, take?: number) {
    const rows = await this.prisma.linkedAccount.findMany({
      where: {
        OR: [
          { userAId: userId, status: 'LINKED' },
          { userBId: userId, status: 'LINKED' },
        ],
      },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
      skip,
      take,
    });
    return rows.map((r) => this.toPartnerDto(r, userId));
  }

  async getPendingInvitations(userId: string) {
    const rows = await this.prisma.linkedAccount.findMany({
      where: {
        OR: [
          { userAId: userId, status: 'PENDING' },
          { userBId: userId, status: 'PENDING' },
        ],
      },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
    });
    return rows.map((r) => this.toPartnerDto(r, userId));
  }

  // ── Partners for a specific BabyMon (mobile-facing) ─────────────────────

  /**
   * Returns partners relative to the CURRENT user for a specific BabyMon.
   * Admits the owner, any linked co-parent, and a user holding a PENDING
   * invitation for this baby — so the invitee CAN discover & accept.
   */
  async getPartnersForBabyMon(userId: string, babyMonId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    // Access gate: must be owner, linked co-parent, or invited (pending).
    // REJECTED / EXPIRED invitees are treated as strangers.
    if (babyMon.ownerUserId !== userId) {
      const related = await this.prisma.linkedAccount.findFirst({
        where: {
          babyMonId,
          status: { in: ['LINKED', 'PENDING'] },
          OR: [{ userAId: userId }, { userBId: userId }],
        },
      });
      if (!related) throw new ForbiddenException('Access denied');
    }

    // Return only rows where the caller is a direct participant.
    // This prevents partner B from seeing partner C (who was separately
    // invited by the owner for the same baby) via a row B isn't party to.
    const accounts = await this.prisma.linkedAccount.findMany({
      where: {
        babyMonId,
        AND: [
          { OR: [{ userAId: userId }, { userBId: userId }] },
          { status: { in: ['LINKED', 'PENDING'] } },
        ],
      },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
    });

    return accounts.map((a) => this.toPartnerDto(a, userId));
  }

  // ── Invite ──────────────────────────────────────────────────────────────

  /**
   * Invite a registered user to co-parent a BabyMon.
   *
   *  - No prior link      → new PENDING + email        (7-day expiry)
   *  - Already LINKED     → idempotent — just ensure LinkedBabyMon access
   *  - PENDING / REJECTED / EXPIRED → reset to PENDING (re-invite)
   */
  async invitePartner(
    userId: string,
    babyMonId: string,
    email: string,
    role: PartnerRole = 'PARENT',
  ) {
    // 1. Own the BabyMon
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });
    if (!babyMon) throw new NotFoundException('BabyMon not found');
    if (babyMon.ownerUserId !== userId) {
      throw new ForbiddenException('Only the BabyMon owner can invite partners');
    }

    // 2. Registered users only
    const partner = await this.prisma.user.findUnique({ where: { email } });
    if (!partner) throw new NotFoundException('User not found with this email');
    if (partner.id === userId) throw new BadRequestException('Cannot link to yourself');

    // 3. Look for an existing link (either direction)
    const existing = await this.prisma.linkedAccount.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: partner.id },
          { userAId: partner.id, userBId: userId },
        ],
      },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
    });

    // Already co-parents — just grant this baby access, no new invite needed.
    if (existing?.status === 'LINKED') {
      await this.prisma.linkedBabyMon.upsert({
        where: { userId_babymonId: { userId: partner.id, babymonId: babyMonId } },
        create: { userId: partner.id, babymonId: babyMonId, access: 'EDIT' },
        update: { access: 'EDIT' },
      });
      return this.toPartnerDto(existing, userId);
    }

    // 4. Create or reset to PENDING
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + INVITATION_TTL_DAYS);

    const invitation = existing
      ? await this.prisma.linkedAccount.update({
          where: { id: existing.id },
          data: { status: 'PENDING', role, babyMonId, expiresAt, linkedAt: null },
          include: {
            userA: { select: { id: true, email: true, name: true } },
            userB: { select: { id: true, email: true, name: true } },
          },
        })
      : await this.prisma.linkedAccount.create({
          data: { userAId: userId, userBId: partner.id, status: 'PENDING', role, babyMonId, expiresAt },
          include: {
            userA: { select: { id: true, email: true, name: true } },
            userB: { select: { id: true, email: true, name: true } },
          },
        });

    // 5. Email (fire-and-forget — never fail the request on it)
    this.sendInvitationEmail(userId, partner.email, invitation.id).catch((err) =>
      this.logger.error(`Failed to send partner invitation email: ${err?.message ?? err}`),
    );

    return this.toPartnerDto(invitation, userId);
  }

  // ── Respond ─────────────────────────────────────────────────────────────

  /**
   * Invitee (userB) accepts or declines PENDING invitation.
   *
   * On ACCEPT  → LinkedAccount = LINKED  +  LinkedBabyMon(userB, babyMon, EDIT)
   *              in a single transaction so you're never "linked but locked out".
   * On DECLINE → LinkedAccount = REJECTED
   */
  async respondToInvitation(userId: string, invitationId: string, status: 'ACCEPTED' | 'DECLINED') {
    const invitation = await this.prisma.linkedAccount.findUnique({
      where: { id: invitationId },
    });
    if (!invitation) throw new NotFoundException('Invitation not found');

    // Only the invitee may respond
    if (invitation.userBId !== userId) {
      throw new ForbiddenException('You cannot respond to this invitation');
    }
    if (invitation.status !== 'PENDING') {
      throw new BadRequestException('Invitation already processed');
    }
    if (invitation.expiresAt && invitation.expiresAt < new Date()) {
      throw new BadRequestException('Invitation has expired');
    }

    if (status === 'ACCEPTED') {
      return this.prisma.$transaction(async (tx) => {
        // Grant access for the baby this invitation was about
        if (invitation.babyMonId) {
          await tx.linkedBabyMon.upsert({
            where: { userId_babymonId: { userId, babymonId: invitation.babyMonId } },
            create: { userId, babymonId: invitation.babyMonId, access: 'EDIT' },
            update: { access: 'EDIT' },
          });
        }
        const updated = await tx.linkedAccount.update({
          where: { id: invitationId },
          data: { status: 'LINKED', linkedAt: new Date(), expiresAt: null },
          include: {
            userA: { select: { id: true, email: true, name: true } },
            userB: { select: { id: true, email: true, name: true } },
          },
        });
        return this.toPartnerDto(updated, userId);
      });
    }

    const rejected = await this.prisma.linkedAccount.update({
      where: { id: invitationId },
      data: { status: 'REJECTED', expiresAt: null },
      include: {
        userA: { select: { id: true, email: true, name: true } },
        userB: { select: { id: true, email: true, name: true } },
      },
    });
    return this.toPartnerDto(rejected, userId);
  }

  // ── Remove ──────────────────────────────────────────────────────────────

  /**
   * Remove a partner or cancel an invitation.
   *  - PENDING → delete the invitation outright.
   *  - LINKED  → revoke LinkedBabyMon for the invited baby only.
   *              The LinkedAccount row is kept if the partner still has
   *              access to other babies so future baby-scoped access checks
   *              in getPartnersForBabyMon continue to work.
   *
   * partnerId here is the LinkedAccount id (the `id` returned in partner lists).
   */
  async removeLink(userId: string, linkId: string) {
    const link = await this.prisma.linkedAccount.findUnique({
      where: { id: linkId },
    });
    if (!link) throw new NotFoundException('Link not found');
    if (link.userAId !== userId && link.userBId !== userId) {
      throw new ForbiddenException('You are not part of this link');
    }

    if (link.status === 'PENDING') {
      await this.prisma.linkedAccount.delete({ where: { id: linkId } });
      return { message: 'Invitation cancelled' };
    }

    // LINKED: revoke the partner's access to THIS baby only.
    const otherUserId = link.userAId === userId ? link.userBId : link.userAId;
    if (link.babyMonId) {
      await this.prisma.linkedBabyMon.deleteMany({
        where: { userId: otherUserId, babymonId: link.babyMonId },
      });
    }

    // Only delete the user-to-user link if no other shared babies remain.
    const remaining = await this.prisma.linkedBabyMon.count({
      where: { userId: otherUserId },
    });
    if (remaining === 0) {
      await this.prisma.linkedAccount.delete({ where: { id: linkId } });
      return { message: 'Link removed successfully' };
    }

    return { message: 'Partner access revoked for this baby' };
  }

  // ── Direct BabyMon linking (existing standalone endpoint) ───────────────

  async linkBabyMonToUser(userId: string, babymonId: string, access: 'READ' | 'EDIT' | 'ADMIN' = 'EDIT') {
    const babyMon = await this.prisma.babyMon.findUnique({ where: { id: babymonId } });
    if (!babyMon) throw new NotFoundException('BabyMon not found');

    const link = await this.prisma.linkedAccount.findFirst({
      where: {
        OR: [
          { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
          { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
        ],
      },
    });
    if (!link) throw new ForbiddenException('You are not linked to this BabyMon owner');

    return this.prisma.linkedBabyMon.upsert({
      where: { userId_babymonId: { userId, babymonId } },
      create: { userId, babymonId, access },
      update: { access },
    });
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  private async sendInvitationEmail(inviterId: string, inviteeEmail: string, invitationId: string) {
    const inviter = await this.prisma.user.findUnique({
      where: { id: inviterId },
      select: { name: true, email: true },
    });
    const inviterName = inviter?.name || inviter?.email || 'Someone';
    await this.mailService.sendLinkedAccountInvitation(inviterName, inviteeEmail, invitationId);
  }

  /**
   * Normalises a LinkedAccount row → mobile partner shape:
   *  { id, status: ACCEPTED|PENDING|DECLINED, role, user: {id,name,email} }
   */
  private toPartnerDto(
    row: {
      id: string;
      userAId: string;
      userBId: string;
      status: string;
      role?: string | null;
      linkedAt?: Date | null;
      userA: { id: string; email: string; name: string | null };
      userB: { id: string; email: string; name: string | null };
    },
    viewerId: string,
  ) {
    const isUserA = row.userAId === viewerId;
    const partner = isUserA ? row.userB : row.userA;
    return {
      id: row.id,
      status: this.toClientStatus(row.status),
      role: row.role ?? 'PARENT',
      user: partner,
      linkedAt: row.linkedAt,
    };
  }

  private toClientStatus(dbStatus: string): ClientStatus {
    switch (dbStatus) {
      case 'LINKED':
      case 'ACTIVE':
        return 'ACCEPTED';
      case 'REJECTED':
      case 'EXPIRED':
        return 'DECLINED';
      case 'PENDING':
      default:
        return 'PENDING';
    }
  }
}
