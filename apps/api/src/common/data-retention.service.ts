import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';

/**
 * GDPR-compliant data retention service.
 *
 * Hard-deletes soft-deleted records that have exceeded the retention period.
 * Default retention: 90 days for soft-deleted user data (GDPR storage limitation).
 *
 * To enable automated cleanup, wire this into a scheduled job:
 *   npm install @nestjs/schedule
 *   @Cron('0 3 * * *') // daily at 3 AM
 *   async scheduledPurge() { await this.purgeExpiredRecords(); }
 */
@Injectable()
export class DataRetentionService {
  private readonly logger = new Logger(DataRetentionService.name);
  private readonly retentionDays: number;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.retentionDays = this.configService.get<number>('dataRetentionDays') ?? 90;
  }

  /**
   * Hard-deletes all soft-deleted records past the retention threshold.
   * Returns counts of purged records per type.
   */
  async purgeExpiredRecords() {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - this.retentionDays);
    this.logger.log(`Purging soft-deleted records older than ${cutoff.toISOString()}`);

    const results = await this.prisma.$transaction(async (tx) => {
      // Users (anonymized after deleteAccount already — double-check)
      const usersPurged = await tx.user.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // BabyMons
      const babyMonsPurged = await tx.babyMon.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // Feed logs
      const feedLogsPurged = await tx.feedLog.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // Milestones
      const milestonesPurged = await tx.milestone.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // Health records
      const healthRecordsPurged = await tx.healthRecord.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // Sleep logs
      const sleepLogsPurged = await tx.sleepLog.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      // Growth records
      const growthRecordsPurged = await tx.growthRecord.deleteMany({
        where: { deletedAt: { lte: cutoff } },
      });

      return {
        users: usersPurged.count,
        babyMons: babyMonsPurged.count,
        feedLogs: feedLogsPurged.count,
        milestones: milestonesPurged.count,
        healthRecords: healthRecordsPurged.count,
        sleepLogs: sleepLogsPurged.count,
        growthRecords: growthRecordsPurged.count,
      };
    });

    const total = Object.values(results).reduce((a, b) => a + b, 0);
    this.logger.log(`Purged ${total} expired records: ${JSON.stringify(results)}`);
    return { purged: total, details: results, retentionDays: this.retentionDays };
  }
}
