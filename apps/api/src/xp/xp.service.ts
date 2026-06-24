import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const MAX_LEVEL = 50;
const PHASE_MILESTONE_INTERVAL = 5; // every 5th level is a phase milestone

// XP thresholds per stage bracket
const XP_BRACKETS: { maxStage: number; xp: number }[] = [
  { maxStage: 5, xp: 50 },
  { maxStage: 15, xp: 75 },
  { maxStage: 25, xp: 100 },
  { maxStage: 35, xp: 150 },
  { maxStage: 45, xp: 200 },
  { maxStage: MAX_LEVEL, xp: 250 },
];

/**
 * XP required to advance from the given stage to the next.
 */
export function xpForNextLevel(stage: number): number {
  if (stage < 1) return XP_BRACKETS[0].xp;
  for (const bracket of XP_BRACKETS) {
    if (stage <= bracket.maxStage) return bracket.xp;
  }
  return XP_BRACKETS[XP_BRACKETS.length - 1].xp;
}

/**
 * All 50 level names from the BabyMon Bloom Journey.
 */
export function getLevelName(stage: number): string {
  const names: Record<number, string> = {
    1: 'Little Seed',
    2: 'Tiny Gripper',
    3: 'Sleep Sprout',
    4: 'Gaze Keeper',
    5: 'Dewdrop',
    6: 'Burble Bud',
    7: 'Smile Weaver',
    8: 'Neck Knight',
    9: 'Tummy Roller',
    10: 'Giggle Pod',
    11: 'Reach Star',
    12: 'Babble Scholar',
    13: 'Sitter Supreme',
    14: 'Taste Adventurer',
    15: 'Scoot Scout',
    16: 'Cruiser Cadet',
    17: 'Wave Wizard',
    18: 'Pincer Prince/ss',
    19: 'Stack Master',
    20: 'Step Seeker',
    21: 'Word Hoarder',
    22: 'Melody Hummer',
    23: 'Puzzle Prodigy',
    24: 'Spoon Warrior',
    25: 'No-Sayer',
    26: 'Tower Climber',
    27: 'Scribble Sage',
    28: 'Dress Dancer',
    29: 'Question Storm',
    30: 'Story Dreamer',
    31: 'Count Keeper',
    32: 'Friend Finder',
    33: 'Brave Heart',
    34: 'Emotion Sage',
    35: 'Jump Master',
    36: 'Rhyme Weaver',
    37: 'Helper Hand',
    38: 'Joke Crafter',
    39: 'Memory Vault',
    40: 'Promise Keeper',
    41: 'Pattern Seer',
    42: 'Kindness Bloom',
    43: 'Peace Maker',
    44: 'Path Finder',
    45: 'Song Weaver',
    46: 'Wisdom Seed',
    47: 'Story Teller',
    48: 'Light Keeper',
    49: 'Trail Blazer',
    50: 'LUMINARY',
  };
  return names[stage] ?? `Level ${stage}`;
}

/**
 * Returns true for every 5th level (5, 10, 15 … 45).
 */
export function isPhaseMilestone(stage: number): boolean {
  return stage > 0 && stage < MAX_LEVEL && stage % PHASE_MILESTONE_INTERVAL === 0;
}

@Injectable()
export class XpService {
  constructor(private prisma: PrismaService) {}

  /**
   * Checks if the BabyMon has enough XP to advance to the next stage.
   * Loops to handle multi-hop level-ups (e.g. large XP gains crossing
   * multiple thresholds in a single action). Returns the final stage
   * reached so the frontend can trigger the celebration once.
   */
  async checkAndProcessLevelUp(babymonId: string): Promise<{
    leveledUp: boolean;
    newStage?: number;
    levelName?: string;
    isPhaseMilestone?: boolean;
  }> {
    // Use interactive transaction for atomic read-modify-write
    return this.prisma.$transaction(async (tx) => {
      const babyMon = await tx.babyMon.findUnique({
        where: { id: babymonId },
      });

      if (!babyMon) return { leveledUp: false };

      let currentXp = babyMon.currentXp;
      let currentStage = babyMon.currentStage;
      let hasAdvanced = false;
      let hitMilestone = false;

      while (currentStage < MAX_LEVEL) {
        const needed = xpForNextLevel(currentStage);
        if (currentXp < needed) break;

        currentXp -= needed;
        currentStage++;
        hasAdvanced = true;
        if (isPhaseMilestone(currentStage)) hitMilestone = true;
      }

      if (!hasAdvanced) return { leveledUp: false };

      await tx.babyMon.update({
        where: { id: babymonId },
        data: { currentStage, currentXp },
      });

      return {
        leveledUp: true,
        newStage: currentStage,
        levelName: getLevelName(currentStage),
        isPhaseMilestone: hitMilestone,
      };
    });
  }
}