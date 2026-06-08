import { Injectable, Logger, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class JournalProposalsService {
  private readonly logger = new Logger(JournalProposalsService.name);

  constructor(private prisma: PrismaService) {}

  async createProposal(params: {
    babymonId: string;
    journalEntryId: string;
    entryType: string;
    proposedById: string;
    changes: Record<string, { oldValue: string; newValue: string }>;
  }) {
    return this.prisma.journalProposal.create({
      data: {
        babymonId: params.babymonId,
        journalEntryId: params.journalEntryId,
        entryType: params.entryType,
        proposedById: params.proposedById,
        changes: params.changes,
        status: 'PENDING',
      },
    });
  }

  async getPendingProposals(babymonId: string) {
    return this.prisma.journalProposal.findMany({
      where: { babymonId, status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
    });
  }

  async approveProposal(proposalId: string, ownerId: string) {
    const proposal = await this.prisma.journalProposal.findUnique({ where: { id: proposalId } });
    if (!proposal) throw new NotFoundException('Proposal not found');
    if (proposal.status !== 'PENDING') throw new ForbiddenException('Proposal already resolved');

    // Verify owner is the babyMon owner
    const babyMon = await this.prisma.babyMon.findUnique({ where: { id: proposal.babymonId } });
    if (!babyMon) throw new NotFoundException('BabyMon not found');
    if (babyMon.ownerUserId !== ownerId) throw new ForbiddenException('Only the owner can approve proposals');

    const changes = proposal.changes as Record<string, { oldValue: string; newValue: string }>;

    // Apply changes to the appropriate table
    if (proposal.entryType === 'MILESTONE') {
      for (const [field, change] of Object.entries(changes)) {
        const updateData: any = {};
        updateData[field] = change.newValue;
        await this.prisma.milestone.update({
          where: { id: proposal.journalEntryId },
          data: updateData,
        });
      }
    } else if (proposal.entryType === 'FEED_LOG') {
      for (const [field, change] of Object.entries(changes)) {
        const updateData: any = {};
        updateData[field] = change.newValue;
        await this.prisma.feedLog.update({
          where: { id: proposal.journalEntryId },
          data: updateData,
        });
      }
    } else if (proposal.entryType === 'HEALTH_RECORD') {
      for (const [field, change] of Object.entries(changes)) {
        const updateData: any = {};
        updateData[field] = change.newValue;
        await this.prisma.healthRecord.update({
          where: { id: proposal.journalEntryId },
          data: updateData,
        });
      }
    }

    return this.prisma.journalProposal.update({
      where: { id: proposalId },
      data: { status: 'APPROVED', resolvedAt: new Date(), resolvedById: ownerId },
    });
  }

  async rejectProposal(proposalId: string, ownerId: string) {
    const proposal = await this.prisma.journalProposal.findUnique({ where: { id: proposalId } });
    if (!proposal) throw new NotFoundException('Proposal not found');
    if (proposal.status !== 'PENDING') throw new ForbiddenException('Proposal already resolved');

    const babyMon = await this.prisma.babyMon.findUnique({ where: { id: proposal.babymonId } });
    if (!babyMon) throw new NotFoundException('BabyMon not found');
    if (babyMon.ownerUserId !== ownerId) throw new ForbiddenException('Only the owner can reject proposals');

    return this.prisma.journalProposal.update({
      where: { id: proposalId },
      data: { status: 'REJECTED', resolvedAt: new Date(), resolvedById: ownerId },
    });
  }
}
