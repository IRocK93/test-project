import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ExportService {
  constructor(private prisma: PrismaService) {}

  /**
   * Fetch full BabyMon data for export (all records, not limited)
   */
  async getFullBabyMonData(babyMonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }
    if (babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: {
          OR: [
            { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
            { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
          ],
        },
      });
      if (!linked) throw new ForbiddenException('Access denied');
    }

    const [milestones, feedLogs, healthRecords, growthRecords, badges] = await Promise.all([
      this.prisma.milestone.findMany({
        where: { babymonId: babyMonId, deletedAt: null },
        orderBy: { happenedAt: 'desc' },
      }),
      this.prisma.feedLog.findMany({
        where: { babymonId: babyMonId, deletedAt: null },
        orderBy: { happenedAt: 'desc' },
      }),
      this.prisma.healthRecord.findMany({
        where: { babymonId: babyMonId, deletedAt: null },
        orderBy: { happenedAt: 'desc' },
      }),
      this.prisma.growthRecord.findMany({
        where: { babyMonId: babyMonId },
        orderBy: { measuredAt: 'desc' },
      }),
      this.prisma.badge.findMany({
        where: { babymonId: babyMonId },
        orderBy: { unlockedAt: 'desc' },
      }),
    ]);

    return {
      babyMon,
      milestones,
      feedLogs,
      healthRecords,
      growthRecords,
      badges,
    };
  }

  /**
   * Export BabyMon as JSON
   */
  async exportJson(babyMonId: string, userId: string) {
    const data = await this.getFullBabyMonData(babyMonId, userId);
    return {
      exportedAt: new Date().toISOString(),
      babyMonId,
      ...data,
    };
  }

  /**
   * Export BabyMon as CSV
   */
  async exportCsv(babyMonId: string, userId: string) {
    const data = await this.getFullBabyMonData(babyMonId, userId);

    const lines: string[] = [];

    // Helper to escape CSV fields
    const escapeCsv = (val: any): string => {
      if (val === null || val === undefined) return '';
      const str = String(val);
      if (str.includes(',') || str.includes('"') || str.includes('\n')) {
        return `"${str.replace(/"/g, '""')}"`;
      }
      return str;
    };

    // Helper to write CSV section
    const writeSection = (title: string, headers: string[], rows: any[]) => {
      lines.push(`\n=== ${title} ===`);
      lines.push(headers.join(','));
      for (const row of rows) {
        lines.push(headers.map(h => escapeCsv(row[h])).join(','));
      }
    };

    // BabyMon profile
    lines.push('=== BabyMon Profile ===');
    const profileHeaders = ['id', 'name', 'middleName', 'lastName', 'gender', 'birthDate', 'currentXp', 'currentStage', 'traits', 'biologicalMother', 'biologicalFather', 'bloodGroup', 'eyeColor', 'createdAt'];
    lines.push(profileHeaders.join(','));
    const profileRow = profileHeaders.map(h => escapeCsv(data.babyMon[h as keyof typeof data.babyMon]));
    lines.push(profileRow.join(','));

    // Milestones
    writeSection('Milestones', ['id', 'title', 'notes', 'happenedAt', 'isCustom', 'xpAwarded', 'createdAt'], data.milestones);

    // Feed Logs
    writeSection('Feed Logs', ['id', 'type', 'amount', 'unit', 'notes', 'happenedAt', 'xpAwarded', 'createdAt'], data.feedLogs);

    // Health Records
    writeSection('Health Records', ['id', 'category', 'title', 'notes', 'happenedAt', 'xpAwarded', 'createdAt'], data.healthRecords);

    // Growth Records
    writeSection('Growth Records', ['id', 'type', 'value', 'unit', 'measuredAt', 'notes', 'createdAt'], data.growthRecords);

    // Badges
    writeSection('Badges', ['id', 'badgeType', 'name', 'description', 'xpValue', 'unlockedAt'], data.badges);

    return lines.join('\n');
  }

  async exportBabyMon(babyMonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
      include: {
        badges: { orderBy: { unlockedAt: 'desc' } },
        milestones: { orderBy: { happenedAt: 'desc' }, take: 3 },
        feedLogs: { orderBy: { happenedAt: 'desc' }, take: 3 },
        healthRecords: { orderBy: { happenedAt: 'desc' }, take: 3 },
      },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }
    if (babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: {
          OR: [
            { userAId: userId, userBId: babyMon.ownerUserId, status: 'LINKED' },
            { userBId: userId, userAId: babyMon.ownerUserId, status: 'LINKED' },
          ],
        },
      });
      if (!linked) throw new ForbiddenException('Access denied');
    }

    // Traits is now a native PostgreSQL array
    const traits: string[] = babyMon.traits || [];

    // Generate a simple HTML export (MVP - basic bento box style)
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>BabyMon Export - ${babyMon.name}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #FFF8F0; }
    .header { background: linear-gradient(135deg, #9C7CF4, #FF8A65); color: white; padding: 30px; border-radius: 16px; text-align: center; margin-bottom: 20px; }
    .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
    .card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .full-width { grid-column: span 2; }
    h2 { margin: 0 0 16px 0; color: #2D2D2D; }
    .badge { display: inline-block; background: #81D4CA; color: white; padding: 4px 12px; border-radius: 20px; margin: 4px; font-size: 14px; }
    .entry { border-left: 4px solid #9C7CF4; padding-left: 12px; margin-bottom: 12px; }
    .entry-title { font-weight: bold; color: #2D2D2D; }
    .entry-date { font-size: 12px; color: #666; }
    .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>${babyMon.name}</h1>
    <p>Current XP: ${babyMon.currentXp}</p>
  </div>
  <div class="grid">
    <div class="card">
      <h2>Badges</h2>
      ${babyMon.badges.map(b => `<span class="badge">${b.name}</span>`).join('')}
    </div>
    <div class="card">
      <h2>Traits</h2>
      ${traits.length > 0 ? traits.map(t => `<span class="badge">${t}</span>`).join('') : 'No traits set'}
    </div>
    <div class="card full-width">
      <h2>Recent Milestones</h2>
      ${babyMon.milestones.map(m => `
        <div class="entry">
          <div class="entry-title">${m.title}</div>
          <div class="entry-date">${new Date(m.happenedAt).toLocaleDateString()}</div>
        </div>
      `).join('')}
    </div>
    <div class="card">
      <h2>Recent Feeding</h2>
      ${babyMon.feedLogs.map(f => `
        <div class="entry">
          <div class="entry-title">${f.type}</div>
          <div class="entry-date">${new Date(f.happenedAt).toLocaleDateString()}</div>
        </div>
      `).join('')}
    </div>
    <div class="card">
      <h2>Recent Health</h2>
      ${babyMon.healthRecords.map(h => `
        <div class="entry">
          <div class="entry-title">${h.title}</div>
          <div class="entry-date">${new Date(h.happenedAt).toLocaleDateString()}</div>
        </div>
      `).join('')}
    </div>
  </div>
  <div class="footer">
    <p>Generated by BabyMon - Smart Evolving Parenting Companion</p>
    <p>Educational purposes only. Not medical advice.</p>
  </div>
</body>
</html>
    `.trim();

    return {
      html,
      babyMonName: babyMon.name,
    };
  }
}
