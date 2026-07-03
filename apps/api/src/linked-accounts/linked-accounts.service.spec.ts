import { Test, TestingModule } from '@nestjs/testing';
import { LinkedAccountsService } from './linked-accounts.service';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../mail/mail.service';
import { NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';

describe('LinkedAccountsService', () => {
  let service: LinkedAccountsService;

  const userA = { id: 'user-a', name: 'Alice', email: 'alice@test.com', locale: 'en' };
  const userB = { id: 'user-b', name: 'Bob',   email: 'bob@test.com',   locale: 'en' };
  const baby  = { id: 'baby-1', ownerUserId: userA.id, deletedAt: null };

  const mockPrisma = {
    babyMon:        { findFirst: jest.fn(), findUnique: jest.fn() },
    user:           { findUnique: jest.fn() },
    linkedAccount:  { findFirst: jest.fn(), findMany: jest.fn(), findUnique: jest.fn(),
                      create: jest.fn(), update: jest.fn(), delete: jest.fn() },
    linkedBabyMon:  { upsert: jest.fn(), deleteMany: jest.fn(), findMany: jest.fn(), count: jest.fn() },
    $transaction:   jest.fn((fn: any) => fn(mockPrisma)),
  };

  const mockMailService = { sendLinkedAccountInvitation: jest.fn().mockResolvedValue(true) };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LinkedAccountsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: MailService,   useValue: mockMailService },
      ],
    }).compile();
    service = module.get<LinkedAccountsService>(LinkedAccountsService);
    jest.clearAllMocks();
  });

  // ──────────────── invitePartner ────────────────

  describe('invitePartner', () => {
    it('creates PENDING with role + babyMonId', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique.mockResolvedValue(userB);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue(null);
      mockPrisma.linkedAccount.create.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'PENDING', role: 'GUARDIAN', babyMonId: baby.id, linkedAt: null,
        userA, userB,
      });
      const r = await service.invitePartner(userA.id, baby.id, userB.email, 'GUARDIAN');
      expect(mockPrisma.linkedAccount.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ role: 'GUARDIAN', babyMonId: baby.id }) }));
      expect(r.status).toBe('PENDING');
      expect(r.role).toBe('GUARDIAN');
      expect(r.user).toEqual(userB);
    });

    it('throws NotFound for non-registered invitee', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique.mockResolvedValue(null);
      await expect(service.invitePartner(userA.id, baby.id, 'ghost@t.com', 'PARENT'))
        .rejects.toThrow(NotFoundException);
    });

    it('throws Forbidden if caller is not the owner', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue({ ...baby, ownerUserId: 'other' });
      await expect(service.invitePartner(userA.id, baby.id, userB.email, 'PARENT'))
        .rejects.toThrow(ForbiddenException);
    });

    it('throws BadRequest on self-invite', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique.mockResolvedValue(userA);
      await expect(service.invitePartner(userA.id, baby.id, userA.email, 'PARENT'))
        .rejects.toThrow(BadRequestException);
    });

    it('is idempotent when already LINKED — just grants baby access', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique.mockResolvedValue(userB);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'LINKED', role: 'PARENT', babyMonId: null, linkedAt: new Date(), userA, userB,
      });
      await service.invitePartner(userA.id, baby.id, userB.email, 'PARENT');
      expect(mockPrisma.linkedAccount.create).not.toHaveBeenCalled();
      expect(mockPrisma.linkedBabyMon.upsert).toHaveBeenCalled();
    });

    it('resets a REJECTED invitation to PENDING', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique.mockResolvedValue(userB);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'REJECTED', role: 'PARENT', babyMonId: null, linkedAt: null, userA, userB,
      });
      mockPrisma.linkedAccount.update.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'PENDING', role: 'PARENT', babyMonId: baby.id, linkedAt: null, userA, userB,
      });
      const r = await service.invitePartner(userA.id, baby.id, userB.email, 'PARENT');
      expect(r.status).toBe('PENDING');
    });

    it('sends invitation email fire-and-forget', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.user.findUnique
        .mockResolvedValueOnce(userB).mockResolvedValueOnce(userA);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue(null);
      mockPrisma.linkedAccount.create.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'PENDING', role: 'PARENT', babyMonId: baby.id, linkedAt: null, userA, userB,
      });
      await service.invitePartner(userA.id, baby.id, userB.email, 'PARENT');
      await new Promise((r) => setImmediate(r));
      expect(mockMailService.sendLinkedAccountInvitation).toHaveBeenCalledWith(userA.name, userB.email, 'la-1', userA.locale);
    });
  });

  // ──────────────── respondToInvitation ────────────────

  describe('respondToInvitation', () => {
    const pending = { id: 'la-1', userAId: userA.id, userBId: userB.id,
                       status: 'PENDING', babyMonId: baby.id, expiresAt: null };

    it('on ACCEPT: grants LinkedBabyMon + flips to LINKED (atomic)', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue(pending);
      mockPrisma.linkedAccount.update.mockResolvedValue({ ...pending, status: 'LINKED',
        linkedAt: new Date(), userA, userB });
      const r = await service.respondToInvitation(userB.id, 'la-1', 'ACCEPTED');
      expect(mockPrisma.linkedBabyMon.upsert).toHaveBeenCalled();
      expect(r.status).toBe('ACCEPTED');
    });

    it('throws Forbidden if responder is not userB', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue(pending);
      await expect(service.respondToInvitation(userA.id, 'la-1', 'ACCEPTED'))
        .rejects.toThrow(ForbiddenException);
    });

    it('throws BadRequest if already processed', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({ ...pending, status: 'LINKED' });
      await expect(service.respondToInvitation(userB.id, 'la-1', 'ACCEPTED'))
        .rejects.toThrow(BadRequestException);
    });

    it('throws BadRequest if expired', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({ ...pending,
        expiresAt: new Date('2020-01-01') });
      await expect(service.respondToInvitation(userB.id, 'la-1', 'ACCEPTED'))
        .rejects.toThrow(BadRequestException);
    });

    it('DECLINE marks REJECTED without granting access', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue(pending);
      mockPrisma.linkedAccount.update.mockResolvedValue({ ...pending,
        status: 'REJECTED', userA, userB });
      const r = await service.respondToInvitation(userB.id, 'la-1', 'DECLINED');
      expect(mockPrisma.linkedBabyMon.upsert).not.toHaveBeenCalled();
      expect(r.status).toBe('DECLINED');
    });
  });

  // ──────────────── removeLink ────────────────

  describe('removeLink', () => {
    it('deletes PENDING invitation outright', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'PENDING', babyMonId: baby.id });
      await service.removeLink(userA.id, 'la-1');
      expect(mockPrisma.linkedAccount.delete).toHaveBeenCalledWith({ where: { id: 'la-1' } });
    });

    it('revokes LinkedBabyMon access and deletes link when no other babies remain', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'LINKED', babyMonId: baby.id });
      mockPrisma.linkedBabyMon.count.mockResolvedValue(0); // no other babies
      await service.removeLink(userA.id, 'la-1');
      expect(mockPrisma.linkedBabyMon.deleteMany).toHaveBeenCalledWith({
        where: { userId: userB.id, babymonId: baby.id } });
      expect(mockPrisma.linkedAccount.delete).toHaveBeenCalled();
    });

    it('keeps LinkedAccount when partner still shares other babies', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({
        id: 'la-1', userAId: userA.id, userBId: userB.id,
        status: 'LINKED', babyMonId: baby.id });
      mockPrisma.linkedBabyMon.count.mockResolvedValue(2); // 2 other shared babies
      await service.removeLink(userA.id, 'la-1');
      expect(mockPrisma.linkedBabyMon.deleteMany).toHaveBeenCalledWith({
        where: { userId: userB.id, babymonId: baby.id } });
      // LinkedAccount survives because of remaining access
      expect(mockPrisma.linkedAccount.delete).not.toHaveBeenCalled();
    });

    it('throws Forbidden if caller not in the link', async () => {
      mockPrisma.linkedAccount.findUnique.mockResolvedValue({
        id: 'la-1', userAId: 'other-a', userBId: 'other-b',
        status: 'LINKED', babyMonId: baby.id });
      await expect(service.removeLink(userA.id, 'la-1')).rejects.toThrow(ForbiddenException);
    });
  });

  // ──────────────── status normalization ────────────────

  describe('getPartnersForBabyMon', () => {
    it('maps DB LINKED → ACCEPTED and PENDING → PENDING', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.linkedAccount.findMany.mockResolvedValue([
        { id:'la-1', userAId:userA.id, userBId:userB.id, status:'LINKED',
          role:'PARENT', linkedAt:new Date(), userA, userB },
        { id:'la-2', userAId:userA.id, userBId:{ id:'c', name:'Cleo', email:'c@t.com' },
          status:'PENDING', role:'GUARDIAN', linkedAt:null, userA,
          userB:{ id:'c', name:'Cleo', email:'c@t.com' } },
      ]);
      const r = await service.getPartnersForBabyMon(userA.id, baby.id);
      expect(r).toEqual(expect.arrayContaining([
        expect.objectContaining({ status:'ACCEPTED' }),
        expect.objectContaining({ status:'PENDING' }),
      ]));
    });

    it('lets an invitee view the partner roster while PENDING', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue({
        id:'la-1', userAId:userA.id, userBId:userB.id, babyMonId:baby.id });
      mockPrisma.linkedAccount.findMany.mockResolvedValue([]);
      const r = await service.getPartnersForBabyMon(userB.id, baby.id);
      expect(r).toEqual([]);
    });

    it('denies a stranger', async () => {
      mockPrisma.babyMon.findFirst.mockResolvedValue(baby);
      mockPrisma.linkedAccount.findFirst.mockResolvedValue(null);
      await expect(service.getPartnersForBabyMon('stranger', baby.id))
        .rejects.toThrow(ForbiddenException);
    });
  });
});
