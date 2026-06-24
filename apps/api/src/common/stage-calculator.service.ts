import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface StageInfo {
  stageKey: string;
  currentStage: number;
  stageLabel: string;
  daysInStage: number;
}

@Injectable()
export class StageCalculatorService {
  constructor(private prisma: PrismaService) {}

  /**
   * Calculate the current developmental stage for a BabyMon.
   * Single source of truth — used by BabyMonService, CompanionService, and StageContentService.
   */
  async calculateStage(babyMonId: string): Promise<StageInfo> {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
    });

    if (!babyMon) {
      throw new Error(`BabyMon ${babyMonId} not found`);
    }

    const now = new Date();

    if (babyMon.birthDate) {
      // Post-birth: calculate weeks then months
      const birthDate = new Date(babyMon.birthDate);
      const daysSinceBirth = Math.floor((now.getTime() - birthDate.getTime()) / (1000 * 60 * 60 * 24));
      const weeksSinceBirth = Math.floor(daysSinceBirth / 7);
      const monthsSinceBirth = Math.floor(daysSinceBirth / 30.4375);

      let stageKey: string;
      let stageLabel: string;

      if (weeksSinceBirth < 12) {
        const week = Math.max(1, weeksSinceBirth + 1);
        stageKey = `born_week_${week}`;
        stageLabel = `Week ${week}`;
      } else {
        const month = Math.min(24, monthsSinceBirth);
        stageKey = `born_month_${month}`;
        stageLabel = `${month} month${month > 1 ? 's' : ''}`;
      }

      return {
        stageKey,
        currentStage: babyMon.currentStage,
        stageLabel,
        daysInStage: daysSinceBirth,
      };
    }

    if (babyMon.conceptionDate) {
      // Pregnancy: calculate weeks since conception
      const conceptionDate = new Date(babyMon.conceptionDate);
      const daysSinceConception = Math.floor((now.getTime() - conceptionDate.getTime()) / (1000 * 60 * 60 * 24));
      const weeksPregnant = Math.max(1, Math.min(40, Math.floor(daysSinceConception / 7) + 4));

      return {
        stageKey: `pregnant_week_${weeksPregnant}`,
        currentStage: babyMon.currentStage,
        stageLabel: `Week ${weeksPregnant} of pregnancy`,
        daysInStage: daysSinceConception,
      };
    }

    // IDEA/PLAN stage: pre-conception content
    return {
      stageKey: 'idea',
      currentStage: babyMon.currentStage,
      stageLabel: 'Planning phase',
      daysInStage: 0,
    };
  }

  /**
   * Convenience: calculate stage + return the stage key only.
   */
  async getStageKey(babyMonId: string): Promise<string> {
    const info = await this.calculateStage(babyMonId);
    return info.stageKey;
  }

  /**
   * Calculate stage key from an already-fetched babyMon object (no DB lookup).
   * Shared algorithm — single source of truth for stage key computation.
   */
  static computeStageKey(babyMon: {
    stageStartType: string;
    conceptionDate?: Date | string | null;
    birthDate?: Date | string | null;
    gestationalAgeAtBirth?: number | null;
  }): string {
    if (babyMon.stageStartType === 'PLAN') return 'idea';
    if (babyMon.stageStartType === 'INCUBATING' && babyMon.conceptionDate) {
      const weeks = Math.floor((Date.now() - new Date(babyMon.conceptionDate).getTime()) / (1000 * 60 * 60 * 24 * 7));
      return `preg_week_${Math.min(weeks, 40)}`;
    }
    if (babyMon.stageStartType === 'BORN' && babyMon.birthDate) {
      // Use corrected age for premature babies (< 37 weeks)
      const birthDate = new Date(babyMon.birthDate);
      let adjustedDate = birthDate;
      if (babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37) {
        adjustedDate = new Date(birthDate.getTime() + (40 - babyMon.gestationalAgeAtBirth) * 7 * 86400000);
      }
      const months = Math.floor((Date.now() - adjustedDate.getTime()) / (1000 * 60 * 60 * 24 * 30));
      if (months < 3) {
        const weeks = Math.floor((Date.now() - adjustedDate.getTime()) / (1000 * 60 * 60 * 24 * 7));
        return `born_week_${weeks}`;
      }
      return `born_month_${Math.min(months, 24)}`;
    }
    return 'born_week_0';
  }

  /**
   * Compute human-readable age string from an already-fetched babyMon.
   */
  static computeAge(babyMon: {
    birthDate?: Date | string | null;
    conceptionDate?: Date | string | null;
    gestationalAgeAtBirth?: number | null;
  }): string {
    if (babyMon.birthDate) {
      let adjustedDate = new Date(babyMon.birthDate);
      if (babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37) {
        adjustedDate = new Date(adjustedDate.getTime() + (40 - babyMon.gestationalAgeAtBirth) * 7 * 86400000);
      }
      const days = Math.floor((Date.now() - adjustedDate.getTime()) / (1000 * 60 * 60 * 24));
      if (days < 7) return `${days} days old${babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37 ? ' (corrected)' : ''}`;
      if (days < 90) {
        const weeks = Math.floor(days / 7);
        return `${weeks} week${weeks > 1 ? 's' : ''} old${babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37 ? ' (corrected)' : ''}`;
      }
      const months = Math.floor(days / 30);
      return `${months} month${months > 1 ? 's' : ''} old${babyMon.gestationalAgeAtBirth && babyMon.gestationalAgeAtBirth < 37 ? ' (corrected)' : ''}`;
    }
    if (babyMon.conceptionDate) {
      const weeks = Math.floor((Date.now() - new Date(babyMon.conceptionDate).getTime()) / (1000 * 60 * 60 * 24 * 7));
      return `${weeks} weeks pregnant`;
    }
    return 'Planning phase';
  }
}
