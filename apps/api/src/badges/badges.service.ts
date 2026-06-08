import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const BADGE_DEFINITIONS = {
  // ── Category 1: Milestones (7 badges) ──
  M01: { name: 'First Milestone', description: 'Log 1 milestone', tier: 'BRONZE', xpValue: 10, category: 'milestones' },
  M02: { name: 'Milestone Tracker', description: 'Log 10 milestones', tier: 'SILVER', xpValue: 25, category: 'milestones' },
  M03: { name: 'Milestone Master', description: 'Log 25 milestones', tier: 'GOLD', xpValue: 50, category: 'milestones' },
  M04: { name: 'Roll Over', description: 'Log a mobility milestone', tier: 'BRONZE', xpValue: 10, category: 'milestones' },
  M05: { name: 'First Steps', description: 'Log a walking milestone', tier: 'SILVER', xpValue: 25, category: 'milestones' },
  M06: { name: 'First Words', description: 'Log a speech milestone', tier: 'GOLD', xpValue: 50, category: 'milestones' },
  M07: { name: 'Milestone Legend', description: 'Log 50 milestones', tier: 'DIAMOND', xpValue: 100, category: 'milestones' },

  // ── Category 2: Feeding (6 badges) ──
  F01: { name: 'First Feed', description: 'Log 1 feeding', tier: 'BRONZE', xpValue: 10, category: 'feeding' },
  F02: { name: 'Hungry Baby', description: 'Log 10 feedings', tier: 'SILVER', xpValue: 25, category: 'feeding' },
  F03: { name: 'Feeding Pro', description: 'Log 50 feedings', tier: 'GOLD', xpValue: 50, category: 'feeding' },
  F04: { name: 'Breastfeeding Champ', description: 'Log 20 breastmilk feeds', tier: 'SILVER', xpValue: 25, category: 'feeding' },
  F05: { name: 'Solid Food Explorer', description: 'Log 10 solid food entries', tier: 'GOLD', xpValue: 50, category: 'feeding' },
  F06: { name: 'Feeding Legend', description: 'Log 100 feedings', tier: 'DIAMOND', xpValue: 100, category: 'feeding' },

  // ── Category 3: Sleep (6 badges) ──
  S01: { name: 'First Sleep Log', description: 'Log 1 sleep session', tier: 'BRONZE', xpValue: 10, category: 'sleep' },
  S02: { name: 'Sleep Tracker', description: 'Log 10 sleep sessions', tier: 'SILVER', xpValue: 25, category: 'sleep' },
  S03: { name: 'Sleep Expert', description: 'Log 30 sleep sessions', tier: 'GOLD', xpValue: 50, category: 'sleep' },
  S04: { name: 'Nap Master', description: 'Log 15 naps', tier: 'SILVER', xpValue: 25, category: 'sleep' },
  S05: { name: 'Night Owl', description: 'Log 5 night sleeps > 8 hours', tier: 'GOLD', xpValue: 50, category: 'sleep' },
  S06: { name: 'Sleep Legend', description: 'Log 100 sleep sessions', tier: 'DIAMOND', xpValue: 100, category: 'sleep' },

  // ── Category 4: Health (5 badges) ──
  H01: { name: 'First Checkup', description: 'Log 1 health record', tier: 'BRONZE', xpValue: 10, category: 'health' },
  H02: { name: 'Health Tracker', description: 'Log 10 health records', tier: 'SILVER', xpValue: 25, category: 'health' },
  H03: { name: 'Health Guardian', description: 'Log 25 health records', tier: 'GOLD', xpValue: 50, category: 'health' },
  H04: { name: 'Immunization Complete', description: 'Log 5 vaccination records', tier: 'SILVER', xpValue: 25, category: 'health' },
  H05: { name: 'Wellness Check Pro', description: 'Log visit + weight + height + temp in one day', tier: 'GOLD', xpValue: 50, category: 'health' },

  // ── Category 5: Growth (4 badges) ──
  G01: { name: 'First Measurement', description: 'Log 1 growth record', tier: 'BRONZE', xpValue: 10, category: 'growth' },
  G02: { name: 'Growing Strong', description: 'Log 10 growth records', tier: 'SILVER', xpValue: 25, category: 'growth' },
  G03: { name: 'Steady Growth', description: 'Log 25 growth records', tier: 'GOLD', xpValue: 50, category: 'growth' },
  G04: { name: 'Growth Champion', description: 'Log 50 growth records', tier: 'DIAMOND', xpValue: 100, category: 'growth' },

  // ── Category 6: Parenting (6 badges) ──
  P01: { name: 'Team Player', description: 'Add 1 partner', tier: 'BRONZE', xpValue: 10, category: 'parenting' },
  P02: { name: 'Co-Parent Pro', description: 'Both parents log entries in same week', tier: 'SILVER', xpValue: 25, category: 'parenting' },
  P03: { name: 'Super Parent', description: 'Log entries daily for 30 days', tier: 'GOLD', xpValue: 50, category: 'parenting' },
  P04: { name: 'Journal Keeper', description: 'Write 10 journal entries', tier: 'SILVER', xpValue: 25, category: 'parenting' },
  P05: { name: 'Photo Collector', description: 'Upload 20 photos', tier: 'GOLD', xpValue: 50, category: 'parenting' },
  P06: { name: 'Data Driven Parent', description: 'Export data 3 times', tier: 'GOLD', xpValue: 50, category: 'parenting' },

  // ── Category 7: Progression / XP (4 badges) ──
  X01: { name: 'XP Beginner', description: 'Reach 100 total XP', tier: 'BRONZE', xpValue: 10, category: 'progression' },
  X02: { name: 'XP Apprentice', description: 'Reach 500 total XP', tier: 'SILVER', xpValue: 25, category: 'progression' },
  X03: { name: 'XP Warrior', description: 'Reach 1000 total XP', tier: 'GOLD', xpValue: 50, category: 'progression' },
  X04: { name: 'XP Legend', description: 'Reach 5000 total XP', tier: 'DIAMOND', xpValue: 100, category: 'progression' },

  // ── Category 8: Trait-Based Badges (48 badges) ──
  // Trait: Playful
  T01: { name: 'First Giggle', description: 'Log 2 milestones with type SOCIAL or PLAY', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T02: { name: 'Playtime Champion', description: 'Log 15 entries total (any type)', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T03: { name: 'Joy Bringer', description: 'Log 30 entries + have Playful trait active for 30 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Curious
  T04: { name: 'Little Explorer', description: 'Log 2 SOCIAL or COGNITIVE milestones', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T05: { name: 'Question Master', description: 'Log 10 milestones of any type', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T06: { name: 'Curiosity Champ', description: 'Log 20 milestones + Curious trait active for 30 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Sleepy
  T07: { name: 'Nap Time', description: 'Log 2 sleep sessions', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T08: { name: 'Sleep Routine', description: 'Log 7 consecutive days of sleep logs', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T09: { name: 'Dream Master', description: 'Log 30 sleep sessions + Sleepy trait active for 14 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Hungry
  T10: { name: 'First Bite', description: 'Log 1 solid food entry', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T11: { name: 'Healthy Appetite', description: 'Log 20 feedings of any type', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T12: { name: 'Food Critic', description: 'Log 50 feedings + Hungry trait active for 14 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Fussy
  T13: { name: 'Calm Down', description: 'Log 1 milestone with notes containing calm or soothed', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T14: { name: 'Patience', description: '3 consecutive days with sleep log AND feeding log', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T15: { name: 'Zen Master', description: '14 days streak of daily entries + Fussy trait active', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Adventurous
  T16: { name: 'First Step Out', description: 'Log 1 milestone with type MOTOR', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T17: { name: 'Little Risk Taker', description: 'Log 5 different categories of entries', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T18: { name: 'Fearless Explorer', description: 'Log entries in all 8 categories at least once', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Social
  T19: { name: 'First Smile at Stranger', description: 'Log 2 SOCIAL milestones', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T20: { name: 'Friendly', description: 'Have 1 partner linked + log 10 entries', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T21: { name: 'Social Butterfly', description: '2+ partners linked + Social trait active for 30 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Calm
  T22: { name: 'Quiet Moment', description: 'Log 2 sleep sessions > 2 hours', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T23: { name: 'Gentle Soul', description: 'Log 5 entries tagged with calm in notes', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T24: { name: 'Inner Peace', description: '7-day streak of sleep logs + Calm trait active', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Active
  T25: { name: 'First Crawl', description: 'Log 1 MOTOR milestone', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T26: { name: 'Energy Burst', description: 'Log entries in 3+ categories in same day', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T27: { name: 'Powerhouse', description: 'Log 5 entries in a single day + Active trait active', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Creative
  T28: { name: 'First Scribble', description: 'Upload 1 photo', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T29: { name: 'Little Picasso', description: 'Upload 10 photos or log journal entry with photo', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T30: { name: 'Creative Genius', description: 'Upload 25 photos total', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Strong
  T31: { name: 'First Pushup', description: 'Log 1 MOTOR or PHYSICAL milestone', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T32: { name: 'Muscle Builder', description: 'Log 3 weight growth records showing increase', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T33: { name: 'Iron Baby', description: 'Log 10 growth records + Strong trait active', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Smart
  T34: { name: 'First Word', description: 'Log 1 COGNITIVE or SPEECH milestone', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T35: { name: 'Problem Solver', description: 'Log 5 cognitive milestones', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T36: { name: 'Little Genius', description: 'Log 10 milestones across multiple types', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Gentle
  T37: { name: 'Soft Touch', description: 'Log 1 milestone with notes containing gentle or kind', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T38: { name: 'Kind Heart', description: 'Journal entry about sharing or kindness', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T39: { name: 'Gentle Giant', description: '30 total entries + Gentle trait active for 30 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Brave
  T40: { name: 'First Try', description: 'Log 1 milestone in any new category', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T41: { name: 'Courageous', description: 'Log entries in 4+ different categories', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T42: { name: 'Fearless', description: 'Log 5+ entries in a single week', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Cheeky
  T43: { name: 'First Mischief', description: 'Log 1 milestone with notes containing funny or cheeky', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T44: { name: 'Prankster', description: 'Upload 3 photos (mischief moments!)', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T45: { name: 'Master Jester', description: '20 photos uploaded + Cheeky trait active', tier: 'GOLD', xpValue: 50, category: 'traits' },
  // Trait: Chatty
  T46: { name: 'First Babble', description: 'Log 1 SPEECH or SOCIAL milestone', tier: 'BRONZE', xpValue: 10, category: 'traits' },
  T47: { name: 'Storyteller', description: 'Write 5 journal entries', tier: 'SILVER', xpValue: 25, category: 'traits' },
  T48: { name: 'Chatterbox', description: '15 journal entries + Chatty trait active for 30 days', tier: 'GOLD', xpValue: 50, category: 'traits' },
};

@Injectable()
export class BadgesService {
  constructor(private prisma: PrismaService) {}

  async getBadgeDefinitions() {
    return BADGE_DEFINITIONS;
  }

  async findAll(babymonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({ where: { id: babymonId, deletedAt: null } });
    if (!babyMon || babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: { OR: [{ userAId: userId, userBId: babyMon?.ownerUserId }, { userBId: userId, userAId: babyMon?.ownerUserId }] },
      });
      if (!linked) throw new ForbiddenException('Access denied');
    }

    return this.prisma.badge.findMany({ where: { babymonId }, orderBy: { unlockedAt: 'desc' } });
  }

  async checkAndAwardBadges(babymonId: string, userId: string) {
    // Wrap in transaction to prevent race condition where concurrent milestone
    // creations could award the same badge multiple times
    return this.prisma.$transaction(async (tx) => {
      const babyMon = await tx.babyMon.findUnique({
        where: { id: babymonId },
        include: { badges: true, milestones: true, feedLogs: true, healthRecords: true },
      });

      if (!babyMon) return [];

      const existingBadges = babyMon.badges.map(b => b.badgeType);
      const newBadges: { badgeType: string; name: string; icon: string }[] = [];

      // First milestone
      if (babyMon.milestones.length >= 1 && !existingBadges.includes('FIRST_MILESTONE')) {
        newBadges.push({ badgeType: 'FIRST_MILESTONE', name: 'First Step', icon: 'star' });
      }

      // 5 milestones
      if (babyMon.milestones.length >= 5 && !existingBadges.includes('MILESTONES_5')) {
        newBadges.push({ badgeType: 'MILESTONES_5', name: 'Memory Keeper', icon: 'album' });
      }

      // 10 milestones
      if (babyMon.milestones.length >= 10 && !existingBadges.includes('MILESTONES_10')) {
        newBadges.push({ badgeType: 'MILESTONES_10', name: 'Journal Hero', icon: 'book' });
      }

      // First feeding log
      if (babyMon.feedLogs.length >= 1 && !existingBadges.includes('FIRST_FEEDING')) {
        newBadges.push({ badgeType: 'FIRST_FEEDING', name: 'First Nurture', icon: 'food' });
      }

      // 10 feeding logs
      if (babyMon.feedLogs.length >= 10 && !existingBadges.includes('FEEDING_10')) {
        newBadges.push({ badgeType: 'FEEDING_10', name: 'Feeding Pro', icon: 'bottle' });
      }

      // XP thresholds
      if (babyMon.currentXp >= 50 && !existingBadges.includes('XP_50')) {
        newBadges.push({ badgeType: 'XP_50', name: 'Rising Star', icon: 'trending_up' });
      }

      if (babyMon.currentXp >= 100 && !existingBadges.includes('XP_100')) {
        newBadges.push({ badgeType: 'XP_100', name: 'Century Club', icon: 'hundred' });
      }

      if (babyMon.currentXp >= 500 && !existingBadges.includes('XP_500')) {
        newBadges.push({ badgeType: 'XP_500', name: 'Evolution Master', icon: 'evolve' });
      }

      // Award new badges within the same transaction
      for (const badge of newBadges) {
        await tx.badge.create({
          data: { babymonId, badgeType: badge.badgeType, name: badge.name, icon: badge.icon },
        });

        // Audit log
        await tx.auditLog.create({
          data: { babymonId: babymonId, actorUserId: userId, eventType: 'BADGE_UNLOCKED', payloadJson: JSON.stringify(badge) },
        });
      }

      return newBadges;
    });
  }
}
