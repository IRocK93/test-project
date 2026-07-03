import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AccessControlService } from '../common/access-control.service';
import { ErrorCode } from '../common/enums/error-code.enum';

@Injectable()
export class JournalService {
  constructor(
    private prisma: PrismaService,
    private accessControl: AccessControlService,
  ) {}

  async getJournal(babymonId: string, userId: string, type?: string, skip: number = 0, take: number = 20) {
    const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId);
    if (!hasAccess) throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });

    // Fetch take entries from each source — enough to fill a page after merge
    const queryTake = take + skip;

    const [milestones, feedLogs, healthRecords, sleepLogs, growthRecords, proposals] = await Promise.all([
      (!type || type === 'MILESTONE')
        ? this.prisma.milestone.findMany({ where: { babymonId }, orderBy: { happenedAt: 'desc' }, take: queryTake })
        : Promise.resolve([] as any[]),
      (!type || type === 'FEED_LOG')
        ? this.prisma.feedLog.findMany({ where: { babymonId }, orderBy: { happenedAt: 'desc' }, take: queryTake })
        : Promise.resolve([] as any[]),
      (!type || type === 'HEALTH_RECORD')
        ? this.prisma.healthRecord.findMany({ where: { babymonId }, orderBy: { happenedAt: 'desc' }, take: queryTake })
        : Promise.resolve([] as any[]),
      (!type || type === 'SLEEP_LOG')
        ? this.prisma.sleepLog.findMany({ where: { babymonId }, orderBy: { startTime: 'desc' }, take: queryTake })
        : Promise.resolve([] as any[]),
      (!type || type === 'GROWTH_RECORD')
        ? this.prisma.growthRecord.findMany({ where: { babyMonId: babymonId }, orderBy: { measuredAt: 'desc' }, take: queryTake })
        : Promise.resolve([] as any[]),
      this.prisma.entryChangeProposal.findMany({ where: { babymonId, status: 'PENDING' }, orderBy: { createdAt: 'desc' }, take: 10 }),
    ]);

    // Merge all entry types, sort by date descending
    const allEntries = [
      ...milestones.map(m => ({ ...m, entryType: 'MILESTONE', sortDate: m.happenedAt })),
      ...feedLogs.map(f => ({ ...f, entryType: 'FEED_LOG', sortDate: f.happenedAt })),
      ...healthRecords.map(h => ({ ...h, entryType: 'HEALTH_RECORD', sortDate: h.happenedAt })),
      ...sleepLogs.map(s => ({ ...s, entryType: 'SLEEP_LOG', sortDate: s.startTime })),
      ...growthRecords.map(g => ({ ...g, entryType: 'GROWTH_RECORD', sortDate: g.measuredAt })),
    ].sort((a, b) => new Date(b.sortDate).getTime() - new Date(a.sortDate).getTime());

    const total = allEntries.length;
    const entries = allEntries.slice(skip, skip + take);
    const hasMore = skip + take < total;

    return {
      entries,
      proposals,
      total,
      skip,
      take,
      hasMore,
    };
  }

  async getProposals(babymonId: string, userId: string) {
    const { hasAccess } = await this.accessControl.checkAccess(userId, babymonId);
    if (!hasAccess) throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });

    return this.prisma.entryChangeProposal.findMany({
      where: { babymonId: babymonId, status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
      include: { proposer: { select: { id: true, name: true } } },
    });
  }

  async respondToProposal(proposalId: string, userId: string, accept: boolean, reason?: string) {
    const proposal = await this.prisma.entryChangeProposal.findUnique({
      where: { id: proposalId },
    });

    if (!proposal) throw new NotFoundException({ message: 'Proposal not found', code: ErrorCode.PROPOSAL_NOT_FOUND });

    const { hasAccess } = await this.accessControl.checkAccess(userId, proposal.babymonId);
    if (!hasAccess) throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });

    if (accept) {
      // Apply the change
      let payload: any;
      try {
        payload = JSON.parse(proposal.proposedPayloadJson);
      } catch {
        throw new BadRequestException({ message: 'Invalid proposal payload', code: ErrorCode.VALIDATION_ERROR });
      }

      if (proposal.entryType === 'MILESTONE') {
        if (proposal.proposalType === 'EDIT') {
          await this.prisma.milestone.update({ where: { id: proposal.entryId }, data: payload });
        } else if (proposal.proposalType === 'DELETE') {
          await this.prisma.milestone.update({ where: { id: proposal.entryId }, data: { deletedAt: new Date() } });
        }
      } else if (proposal.entryType === 'FEED_LOG') {
        if (proposal.proposalType === 'EDIT') {
          await this.prisma.feedLog.update({ where: { id: proposal.entryId }, data: payload });
        } else if (proposal.proposalType === 'DELETE') {
          await this.prisma.feedLog.update({ where: { id: proposal.entryId }, data: { deletedAt: new Date() } });
        }
      } else if (proposal.entryType === 'HEALTH_RECORD') {
        if (proposal.proposalType === 'EDIT') {
          await this.prisma.healthRecord.update({ where: { id: proposal.entryId }, data: payload });
        } else if (proposal.proposalType === 'DELETE') {
          await this.prisma.healthRecord.update({ where: { id: proposal.entryId }, data: { deletedAt: new Date() } });
        }
      }
    }

    return this.prisma.entryChangeProposal.update({
      where: { id: proposalId },
      data: { status: accept ? 'APPROVED' : 'REJECTED', responseReason: reason, respondedAt: new Date() },
    });
  }
}
