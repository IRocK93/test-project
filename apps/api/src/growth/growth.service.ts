import { Injectable, Logger, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AccessControlService } from '../common/access-control.service';

// WHO Growth Standards (simplified - for 0-24 months)
const WHO_STANDARDS = {
  male: {
    weight: {
      // Age in months -> p50 (median) in kg
      0: 3.3, 1: 4.3, 2: 5.2, 3: 6.0, 4: 6.6, 5: 7.0, 6: 7.4, 7: 7.7, 8: 8.0, 9: 8.2,
      10: 8.5, 11: 8.7, 12: 8.9, 13: 9.1, 14: 9.3, 15: 9.5, 16: 9.7, 17: 9.9, 18: 10.1,
      19: 10.3, 20: 10.5, 21: 10.7, 22: 10.9, 23: 11.1, 24: 11.3
    },
    height: {
      // Age in months -> p50 (median) in cm
      0: 49.9, 1: 54.7, 2: 58.4, 3: 61.4, 4: 63.9, 5: 65.9, 6: 67.6, 7: 69.2, 8: 70.6, 9: 72.0,
      10: 73.3, 11: 74.5, 12: 75.7, 13: 76.9, 14: 78.0, 15: 79.1, 16: 80.2, 17: 81.2, 18: 82.3,
      19: 83.2, 20: 84.2, 21: 85.1, 22: 86.0, 23: 86.9, 24: 87.8
    }
  },
  female: {
    weight: {
      0: 3.2, 1: 3.9, 2: 4.5, 3: 5.2, 4: 5.7, 5: 6.0, 6: 6.4, 7: 6.7, 8: 6.9, 9: 7.1,
      10: 7.4, 11: 7.6, 12: 7.7, 13: 7.9, 14: 8.1, 15: 8.3, 16: 8.5, 17: 8.7, 18: 8.9,
      19: 9.1, 20: 9.2, 21: 9.4, 22: 9.6, 23: 9.8, 24: 10.0
    },
    height: {
      0: 49.1, 1: 53.7, 2: 57.1, 3: 59.8, 4: 62.1, 5: 64.0, 6: 65.7, 7: 67.3, 8: 68.7, 9: 70.1,
      10: 71.5, 11: 72.8, 12: 74.0, 13: 75.2, 14: 76.4, 15: 77.5, 16: 78.6, 17: 79.7, 18: 80.7,
      19: 81.7, 20: 82.7, 21: 83.7, 22: 84.6, 23: 85.5, 24: 86.4
    }
  }
};

export interface GrowthPercentile {
  value: number;
  percentile: number;
  p3: number;
  p15: number;
  p50: number;
  p85: number;
  p97: number;
}

export interface GrowthTrend {
  current: number;
  previous: number;
  change: number;
  trend: 'increasing' | 'decreasing' | 'stable';
}

@Injectable()
export class GrowthService {
  private readonly logger = new Logger(GrowthService.name);

  constructor(
    private prisma: PrismaService,
    private accessControl: AccessControlService,
  ) {}

  async addGrowthRecord(
    userId: string,
    babyMonId: string,
    type: 'HEIGHT' | 'WEIGHT' | 'HEAD_CIRCUMFERENCE',
    value: number,
    unit: string,
    measuredAt: Date,
    notes?: string,
  ) {
    // Verify access
    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    if (babyMon.ownerUserId !== userId) {
      throw new ForbiddenException('Only owner can add growth records');
    }

    // Convert units if needed
    let valueInStandardUnit = value;
    if (type === 'HEIGHT') {
      if (unit === 'in') valueInStandardUnit = value * 2.54; // inches to cm
    } else if (type === 'WEIGHT') {
      if (unit === 'lb') valueInStandardUnit = value * 0.453592; // lbs to kg
    }

    const record = await this.prisma.growthRecord.create({
      data: {
        babyMonId,
        userId,
        type,
        value: valueInStandardUnit,
        unit: type === 'HEIGHT' ? 'cm' : (type === 'WEIGHT' ? 'kg' : 'cm'),
        measuredAt,
        notes,
      },
    });

    return record;
  }

  async getGrowthRecords(
    babyMonId: string,
    userId: string,
    type?: string,
  ) {
    // Verify access
    await this.verifyAccess(babyMonId, userId);

    const where: any = { babyMonId };
    if (type) {
      where.type = type;
    }

    return this.prisma.growthRecord.findMany({
      where,
      orderBy: { measuredAt: 'desc' },
    });
  }

  async getGrowthAnalysis(babyMonId: string, userId: string, type: string) {
    // Verify access
    const babyMon = await this.verifyAccessWithBabyMon(babyMonId, userId);

    const records = await this.prisma.growthRecord.findMany({
      where: { babyMonId, type },
      orderBy: { measuredAt: 'asc' },
    });

    if (records.length === 0) {
      return { message: 'No growth records yet' };
    }

    const latest = records[records.length - 1];
    const gender = babyMon.gender.toLowerCase() as 'male' | 'female';
    const ageInMonths = this.calculateAgeInMonths(babyMon.birthDate);

    // Get WHO standards for percentile calculation
    const standards = type === 'HEIGHT' ? WHO_STANDARDS[gender].height : WHO_STANDARDS[gender].weight;
    const standardValue = standards[Math.min(Math.max(Math.floor(ageInMonths), 0), 24)] || standards[12];

    const percentile = this.calculatePercentile(latest.value, standardValue);
    const percentileData = this.getPercentileData(type, gender, ageInMonths);

    // Calculate trend
    const trend = this.calculateTrend(records);

    return {
      latest: {
        value: latest.value,
        unit: latest.unit,
        measuredAt: latest.measuredAt,
      },
      percentile: {
        value: latest.value,
        percentile,
        ...percentileData,
      },
      trend,
      totalRecords: records.length,
    };
  }

  async deleteGrowthRecord(recordId: string, userId: string) {
    const record = await this.prisma.growthRecord.findUnique({
      where: { id: recordId },
    });

    if (!record) {
      throw new NotFoundException('Growth record not found');
    }

    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: record.babyMonId },
    });

    if (babyMon?.ownerUserId !== userId) {
      throw new ForbiddenException('Only owner can delete growth records');
    }

    await this.prisma.growthRecord.delete({
      where: { id: recordId },
    });

    return { message: 'Growth record deleted' };
  }

  private async verifyAccess(babyMonId: string, userId: string) {
    const result = await this.accessControl.checkAccess(userId, babyMonId);
    if (!result.hasAccess) {
      throw new ForbiddenException('Access denied');
    }
  }

  private async verifyAccessWithBabyMon(babyMonId: string, userId: string) {
    const result = await this.accessControl.checkAccess(userId, babyMonId);
    if (!result.hasAccess) {
      throw new ForbiddenException('Access denied');
    }

    const babyMon = await this.prisma.babyMon.findFirst({
      where: { id: babyMonId, deletedAt: null },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    return babyMon;
  }

  private calculateAgeInMonths(birthDate: Date | null): number {
    if (!birthDate) return 12;
    const months = (Date.now() - new Date(birthDate).getTime()) / (1000 * 60 * 60 * 24 * 30);
    return Math.max(0, Math.min(months, 24));
  }

  private calculatePercentile(value: number, standardValue: number): number {
    // Simplified percentile calculation
    // In reality, this would use WHO LMS parameters
    const ratio = value / standardValue;
    if (ratio < 0.85) return Math.max(1, Math.round((ratio / 0.85) * 15));
    if (ratio < 0.95) return 15 + Math.round((ratio - 0.85) / 0.10) * 35;
    if (ratio < 1.05) return 50 + Math.round((ratio - 0.95) / 0.10) * 35;
    if (ratio < 1.15) return 85 + Math.round((ratio - 1.05) / 0.10) * 12;
    return Math.min(99, 97 + Math.round((ratio - 1.15) / 0.15) * 2);
  }

  private getPercentileData(type: string, gender: string, ageMonths: number) {
    const ageKey = Math.min(Math.floor(ageMonths), 24);
    const standards = type === 'HEIGHT' ? WHO_STANDARDS[gender as 'male' | 'female'].height : WHO_STANDARDS[gender as 'male' | 'female'].weight;
    const p50 = standards[ageKey] || standards[12];

    return {
      p3: p50 * 0.85,
      p15: p50 * 0.92,
      p50: p50,
      p85: p50 * 1.08,
      p97: p50 * 1.15,
    };
  }

  private calculateTrend(records: any[]): { current: number; previous: number; change: number; trend: string } {
    if (records.length < 2) {
      return { current: records[0].value, previous: records[0].value, change: 0, trend: 'stable' };
    }

    const current = records[records.length - 1].value;
    const previous = records[records.length - 2].value;

    // Avoid division by zero
    if (previous === 0) {
      return { current, previous, change: 0, trend: 'stable' };
    }

    const change = ((current - previous) / previous) * 100;

    let trend: string;
    if (Math.abs(change) < 2) trend = 'stable';
    else if (change > 0) trend = 'increasing';
    else trend = 'decreasing';

    return { current, previous, change: Math.round(change * 10) / 10, trend };
  }
}
