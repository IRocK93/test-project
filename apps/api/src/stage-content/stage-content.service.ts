import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StageContentService {
  constructor(private prisma: PrismaService) {}

  async getByStageKey(stageKey: string, babyMonId: string) {
    // First try to find BabyMon-specific content
    let content = await this.prisma.stageContent.findFirst({
      where: { stageKey, babymonId: babyMonId },
    });

    // Fall back to default content if BabyMon-specific not found
    if (!content) {
      content = await this.prisma.stageContent.findFirst({
        where: { stageKey, babymonId: null },
      });
    }

    if (!content) {
      throw new NotFoundException('Stage content not found');
    }

    return content;
  }

  async getForBabyMon(babyMonId: string, babyMonName?: string, traits?: string[]) {
    const babyMon = await this.prisma.babyMon.findUnique({
      where: { id: babyMonId },
    });

    if (!babyMon) {
      throw new NotFoundException('BabyMon not found');
    }

    // Calculate stage key
    let stageKey: string;
    if (babyMon.stageStartType === 'CONCEIVED' && babyMon.conceptionDate) {
      const weeks = Math.floor((Date.now() - new Date(babyMon.conceptionDate).getTime()) / (1000 * 60 * 60 * 24 * 7));
      stageKey = `preg_week_${Math.min(weeks, 40)}`;
    } else if (babyMon.stageStartType === 'BORN' && babyMon.birthDate) {
      const months = Math.floor((Date.now() - new Date(babyMon.birthDate).getTime()) / (1000 * 60 * 60 * 24 * 30));
      if (months < 3) {
        const weeks = Math.floor((Date.now() - new Date(babyMon.birthDate).getTime()) / (1000 * 60 * 60 * 24 * 7));
        stageKey = `born_week_${weeks}`;
      } else {
        stageKey = `born_month_${Math.min(months, 24)}`;
      }
    } else {
      stageKey = 'preg_week_1';
    }

    const content = await this.getByStageKey(stageKey, babyMonId);

    // Personalize content
    const name = babyMonName || babyMon.name;
    const personalizedContent = {
      ...content,
      summaryText: content.summaryText.replace(/{name}/g, name),
      nurturingText: content.nurturingText.replace(/{name}/g, name),
      encouragementText: content.encouragementText.replace(/{name}/g, name),
    };

    return personalizedContent;
  }
}
