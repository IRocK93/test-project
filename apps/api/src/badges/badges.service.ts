import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

const BADGE_DEFINITIONS = {
  // ── Category 1: Milestones (7 badges) ──
  M01: { name: 'First Milestone', description: 'Log 1 milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/M01_First_Milestone.png', category: 'milestones' },
  M02: { name: 'Milestone Tracker', description: 'Log 10 milestones', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/M02_Milestone_Tracker.png', category: 'milestones' },
  M03: { name: 'Milestone Master', description: 'Log 25 milestones', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/M03_Milestone_Master.png', category: 'milestones' },
  M04: { name: 'Roll Over', description: 'Log a mobility milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/M04_Roll_Over.png', category: 'milestones' },
  M05: { name: 'First Steps', description: 'Log a walking milestone', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/M05_First_Steps.png', category: 'milestones' },
  M06: { name: 'First Words', description: 'Log a speech milestone', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/M06_First_Words.png', category: 'milestones' },
  M07: { name: 'Milestone Legend', description: 'Log 50 milestones', tier: 'DIAMOND', xpValue: 100, iconPath: 'assets/badges/M07_Milestone_Legend.png', category: 'milestones' },

  // ── Category 2: Feeding (6 badges) ──
  F01: { name: 'First Feed', description: 'Log 1 feeding', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/F01_First_Feed.png', category: 'feeding' },
  F02: { name: 'Hungry Baby', description: 'Log 10 feedings', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/F02_Hungry_Baby.png', category: 'feeding' },
  F03: { name: 'Feeding Pro', description: 'Log 50 feedings', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/F03_Feeding_Pro.png', category: 'feeding' },
  F04: { name: 'Breastfeeding Champ', description: 'Log 20 breastmilk feeds', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/F04_Breastfeeding_Champ.png', category: 'feeding' },
  F05: { name: 'Solid Food Explorer', description: 'Log 10 solid food entries', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/F05_Solid_Food_Explorer.png', category: 'feeding' },
  F06: { name: 'Feeding Legend', description: 'Log 100 feedings', tier: 'DIAMOND', xpValue: 100, iconPath: 'assets/badges/F06_Feeding_Legend.png', category: 'feeding' },

  // ── Category 3: Sleep (6 badges) ──
  S01: { name: 'First Sleep Log', description: 'Log 1 sleep session', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/S01_First_Sleep_Log.png', category: 'sleep' },
  S02: { name: 'Sleep Tracker', description: 'Log 10 sleep sessions', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/S02_Sleep_Tracker.png', category: 'sleep' },
  S03: { name: 'Sleep Expert', description: 'Log 30 sleep sessions', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/S03_Sleep_Expert.png', category: 'sleep' },
  S04: { name: 'Nap Master', description: 'Log 15 naps', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/S04_Nap_Master.png', category: 'sleep' },
  S05: { name: 'Night Owl', description: 'Log 5 night sleeps > 8 hours', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/S05_Night_Owl.png', category: 'sleep' },
  S06: { name: 'Sleep Legend', description: 'Log 100 sleep sessions', tier: 'DIAMOND', xpValue: 100, iconPath: 'assets/badges/S06_Sleep_Legend.png', category: 'sleep' },

  // ── Category 4: Health (5 badges) ──
  H01: { name: 'First Checkup', description: 'Log 1 health record', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/H01_First_Checkup.png', category: 'health' },
  H02: { name: 'Health Tracker', description: 'Log 10 health records', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/H02_Health_Tracker.png', category: 'health' },
  H03: { name: 'Health Guardian', description: 'Log 25 health records', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/H03_Health_Guardian.png', category: 'health' },
  H04: { name: 'Immunization Complete', description: 'Log 5 vaccination records', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/H04_Immunization_Complete.png', category: 'health' },
  H05: { name: 'Wellness Check Pro', description: 'Log visit + weight + height + temp in one day', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/H05_Wellness_Check_Pro.png', category: 'health' },

  // ── Category 5: Growth (4 badges) ──
  G01: { name: 'First Measurement', description: 'Log 1 growth record', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/G01_First_Measurement.png', category: 'growth' },
  G02: { name: 'Growing Strong', description: 'Log 10 growth records', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/G02_Growing_Strong.png', category: 'growth' },
  G03: { name: 'Steady Growth', description: 'Log 25 growth records', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/G03_Steady_Growth.png', category: 'growth' },
  G04: { name: 'Growth Champion', description: 'Log 50 growth records', tier: 'DIAMOND', xpValue: 100, iconPath: 'assets/badges/G04_Growth_Champion.png', category: 'growth' },

  // ── Category 6: Parenting (6 badges) ──
  P01: { name: 'Team Player', description: 'Add 1 partner', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/P01_Team_Player.png', category: 'parenting' },
  P02: { name: 'Co-Parent Pro', description: 'Both parents log entries in same week', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/P02_Co-Parent_Pro.png', category: 'parenting' },
  P03: { name: 'Super Parent', description: 'Log entries daily for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/P03_Super_Parent.png', category: 'parenting' },
  P04: { name: 'Journal Keeper', description: 'Write 10 journal entries', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/P04_Journal_Keeper.png', category: 'parenting' },
  P05: { name: 'Photo Collector', description: 'Upload 20 photos', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/P05_Photo_Collector.png', category: 'parenting' },
  P06: { name: 'Data Driven Parent', description: 'Export data 3 times', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/P06_Data_Driven_Parent.png', category: 'parenting' },

  // ── Category 7: Progression / XP (4 badges) ──
  X01: { name: 'XP Beginner', description: 'Reach 100 total XP', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/X01_Rising_Star.png', category: 'progression' },
  X02: { name: 'XP Apprentice', description: 'Reach 500 total XP', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/X02_Century_Club.png', category: 'progression' },
  X03: { name: 'XP Warrior', description: 'Reach 1000 total XP', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/X03_Evolution_Master.png', category: 'progression' },
  X04: { name: 'XP Legend', description: 'Reach 5000 total XP', tier: 'DIAMOND', xpValue: 100, iconPath: 'assets/badges/X04_XP_Legend.png', category: 'progression' },

  // ── Category 8: Trait-Based Badges (48 badges) ──
  // Trait: Playful
  T01: { name: 'First Giggle', description: 'Log 2 milestones with type SOCIAL or PLAY', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T01_First_Giggle.png', category: 'traits' },
  T02: { name: 'Playtime Champion', description: 'Log 15 entries total (any type)', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T02_Playtime_Champion.png', category: 'traits' },
  T03: { name: 'Joy Bringer', description: 'Log 30 entries + have Playful trait active for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T03_Joy_Bringer.png', category: 'traits' },
  // Trait: Curious
  T04: { name: 'Little Explorer', description: 'Log 2 SOCIAL or COGNITIVE milestones', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T04_Little_Explorer.png', category: 'traits' },
  T05: { name: 'Question Master', description: 'Log 10 milestones of any type', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T05_Question_Master.png', category: 'traits' },
  T06: { name: 'Curiosity Champ', description: 'Log 20 milestones + Curious trait active for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T06_Curiosity_Champ.png', category: 'traits' },
  // Trait: Sleepy
  T07: { name: 'Nap Time', description: 'Log 2 sleep sessions', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T07_Nap_Time.png', category: 'traits' },
  T08: { name: 'Sleep Routine', description: 'Log 7 consecutive days of sleep logs', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T08_Sleep_Routine.png', category: 'traits' },
  T09: { name: 'Dream Master', description: 'Log 30 sleep sessions + Sleepy trait active for 14 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T09_Dream_Master.png', category: 'traits' },
  // Trait: Hungry
  T10: { name: 'First Bite', description: 'Log 1 solid food entry', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T10_First_Bite.png', category: 'traits' },
  T11: { name: 'Healthy Appetite', description: 'Log 20 feedings of any type', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T11_Healthy_Appetite.png', category: 'traits' },
  T12: { name: 'Food Critic', description: 'Log 50 feedings + Hungry trait active for 14 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T12_Food_Critic.png', category: 'traits' },
  // Trait: Fussy
  T13: { name: 'Calm Down', description: 'Log 1 milestone with notes containing calm or soothed', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T13_Calm_Down.png', category: 'traits' },
  T14: { name: 'Patience', description: '3 consecutive days with sleep log AND feeding log', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T14_Patience.png', category: 'traits' },
  T15: { name: 'Zen Master', description: '14 days streak of daily entries + Fussy trait active', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T15_Zen_Master.png', category: 'traits' },
  // Trait: Adventurous
  T16: { name: 'First Step Out', description: 'Log 1 milestone with type MOTOR', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T16_First_Step_Out.png', category: 'traits' },
  T17: { name: 'Little Risk Taker', description: 'Log 5 different categories of entries', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T17_Little_Risk_Taker.png', category: 'traits' },
  T18: { name: 'Fearless Explorer', description: 'Log entries in all 8 categories at least once', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T18_Fearless_Explorer.png', category: 'traits' },
  // Trait: Social
  T19: { name: 'First Smile at Stranger', description: 'Log 2 SOCIAL milestones', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T19_First_Smile_at_Stranger.png', category: 'traits' },
  T20: { name: 'Friendly', description: 'Have 1 partner linked + log 10 entries', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T20_Friendly.png', category: 'traits' },
  T21: { name: 'Social Butterfly', description: '2+ partners linked + Social trait active for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T21_Social_Butterfly.png', category: 'traits' },
  // Trait: Calm
  T22: { name: 'Quiet Moment', description: 'Log 2 sleep sessions > 2 hours', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T22_Quiet_Moment.png', category: 'traits' },
  T23: { name: 'Gentle Soul', description: 'Log 5 entries tagged with calm in notes', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T23_Gentle_Soul.png', category: 'traits' },
  T24: { name: 'Inner Peace', description: '7-day streak of sleep logs + Calm trait active', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T24_Inner_Peace.png', category: 'traits' },
  // Trait: Active
  T25: { name: 'First Crawl', description: 'Log 1 MOTOR milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T25_First_Crawl.png', category: 'traits' },
  T26: { name: 'Energy Burst', description: 'Log entries in 3+ categories in same day', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T26_Energy_Burst.png', category: 'traits' },
  T27: { name: 'Powerhouse', description: 'Log 5 entries in a single day + Active trait active', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T27_Powerhouse.png', category: 'traits' },
  // Trait: Creative
  T28: { name: 'First Scribble', description: 'Upload 1 photo', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T28_First_Scribble.png', category: 'traits' },
  T29: { name: 'Little Picasso', description: 'Upload 10 photos or log journal entry with photo', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T29_Little_Picasso.png', category: 'traits' },
  T30: { name: 'Creative Genius', description: 'Upload 25 photos total', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T30_Creative_Genius.png', category: 'traits' },
  // Trait: Strong
  T31: { name: 'First Pushup', description: 'Log 1 MOTOR or PHYSICAL milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T31_First_Pushup.png', category: 'traits' },
  T32: { name: 'Muscle Builder', description: 'Log 3 weight growth records showing increase', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T32_Muscle_Builder.png', category: 'traits' },
  T33: { name: 'Iron Baby', description: 'Log 10 growth records + Strong trait active', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T33_Iron_Baby.png', category: 'traits' },
  // Trait: Smart
  T34: { name: 'First Word', description: 'Log 1 COGNITIVE or SPEECH milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T34_First_Word.png', category: 'traits' },
  T35: { name: 'Problem Solver', description: 'Log 5 cognitive milestones', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T35_Problem_Solver.png', category: 'traits' },
  T36: { name: 'Little Genius', description: 'Log 10 milestones across multiple types', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T36_Little_Genius.png', category: 'traits' },
  // Trait: Gentle
  T37: { name: 'Soft Touch', description: 'Log 1 milestone with notes containing gentle or kind', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T37_Soft_Touch.png', category: 'traits' },
  T38: { name: 'Kind Heart', description: 'Journal entry about sharing or kindness', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T38_Kind_Heart.png', category: 'traits' },
  T39: { name: 'Gentle Giant', description: '30 total entries + Gentle trait active for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T39_Gentle_Giant.png', category: 'traits' },
  // Trait: Brave
  T40: { name: 'First Try', description: 'Log 1 milestone in any new category', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T40_First_Try.png', category: 'traits' },
  T41: { name: 'Courageous', description: 'Log entries in 4+ different categories', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T41_Courageous.png', category: 'traits' },
  T42: { name: 'Fearless', description: 'Log 5+ entries in a single week', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T42_Fearless.png', category: 'traits' },
  // Trait: Cheeky
  T43: { name: 'First Mischief', description: 'Log 1 milestone with notes containing funny or cheeky', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T43_First_Mischief.png', category: 'traits' },
  T44: { name: 'Prankster', description: 'Upload 3 photos (mischief moments!)', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T44_Prankster.png', category: 'traits' },
  T45: { name: 'Master Jester', description: '20 photos uploaded + Cheeky trait active', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T45_Master_Jester.png', category: 'traits' },
  // Trait: Chatty
  T46: { name: 'First Babble', description: 'Log 1 SPEECH or SOCIAL milestone', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/T46_First_Babble.png', category: 'traits' },
  T47: { name: 'Storyteller', description: 'Write 5 journal entries', tier: 'SILVER', xpValue: 25, iconPath: 'assets/badges/T47_Storyteller.png', category: 'traits' },
  T48: { name: 'Chatterbox', description: '15 journal entries + Chatty trait active for 30 days', tier: 'GOLD', xpValue: 50, iconPath: 'assets/badges/T48_Chatterbox.png', category: 'traits' },

  // ── Extended badges (earnable, now with definitions) ──
  // Milestone extended
  M08: { name: 'Milestone Immortal', description: 'Log 500 milestones', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/M08_Milestone_Immortal.png', category: 'milestones' },
  // Feeding extended
  F07: { name: 'Feeding Dedication', description: '30-day feeding streak', tier: 'DIAMOND', xpValue: 150, iconPath: 'assets/badges/F07_Feeding_Dedication.png', category: 'feeding' },
  F08: { name: 'Feeding Immortal', description: 'Log 500 feedings', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/F08_Feeding_Immortal.png', category: 'feeding' },
  F09: { name: 'Feeding Legend (Streak)', description: '60-day feeding streak', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/F09_Feeding_Legend_(Streak).png', category: 'feeding' },
  // Sleep extended
  S07: { name: 'Sleep Champion', description: '30-day sleep streak', tier: 'DIAMOND', xpValue: 150, iconPath: 'assets/badges/S07_Sleep_Champion.png', category: 'sleep' },
  S08: { name: 'Sleep Immortal', description: 'Log 500 sleep sessions', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/S08_Sleep_Immortal.png', category: 'sleep' },
  S09: { name: 'Sleep Legend (Streak)', description: '60-day sleep streak', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/S09_Sleep_Legend_(Streak).png', category: 'sleep' },
  // XP extended
  X05: { name: 'XP Champion', description: 'Reach 10,000 total XP', tier: 'DIAMOND', xpValue: 150, iconPath: 'assets/badges/X05_XP_Champion.png', category: 'progression' },
  X06: { name: 'XP Demigod', description: 'Reach 25,000 total XP', tier: 'DIAMOND', xpValue: 200, iconPath: 'assets/badges/X06_XP_Demigod.png', category: 'progression' },
  X07: { name: 'XP Titan', description: 'Reach 50,000 total XP', tier: 'DIAMOND', xpValue: 300, iconPath: 'assets/badges/X07_XP_Titan.png', category: 'progression' },
  X08: { name: 'XP God', description: 'Reach 100,000 total XP', tier: 'DIAMOND', xpValue: 500, iconPath: 'assets/badges/X08_XP_Dragon.png', category: 'progression' },
  // Keyword badges
  K01: { name: 'Calm Down', description: 'Log a milestone about calming/soothing', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/K01_Calm_Down.png', category: 'traits' },
  K02: { name: 'Soft Touch', description: 'Log a milestone about gentleness/kindness', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/K02_Soft_Touch.png', category: 'traits' },
  K03: { name: 'First Mischief', description: 'Log a milestone about giggles/mischief', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/K03_First_Mischief.png', category: 'traits' },
  K04: { name: 'Little Explorer', description: 'Log a milestone about crawling/exploring', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/K04_Little_Explorer.png', category: 'traits' },
  K05: { name: 'First Words', description: 'Log a milestone about talking/babbling', tier: 'BRONZE', xpValue: 10, iconPath: 'assets/badges/K05_First_Words.png', category: 'traits' },
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
        select: {
          id: true,
          currentXp: true,
          traits: true,
          traitsUpdatedAt: true,
          _count: { select: { milestones: true, feedLogs: true, healthRecords: true, sleepLogs: true, growthRecords: true } },
        },
      });

      if (!babyMon) return [];

      const existingBadges = await tx.badge.findMany({
        where: { babymonId },
        select: { badgeType: true },
      });
      const existingBadgeTypes = existingBadges.map(b => b.badgeType);
      const newBadges: { badgeType: string; name: string; icon: string }[] = [];

      const milestoneCount = babyMon._count.milestones;
      const feedLogCount = babyMon._count.feedLogs;
      const healthRecordCount = babyMon._count.healthRecords;
      const sleepLogCount = babyMon._count.sleepLogs;
      const growthRecordCount = babyMon._count.growthRecords;

      // Supplemental counts (not in _count — query separately)
      const journalCount = await tx.journalProposal.count({ where: { babymonId } });
      const exportCount = await tx.auditLog.count({ where: { babymonId, eventType: 'DATA_EXPORT' } });

      // First milestone — matches M01 definition key
      if (milestoneCount >= 1 && !existingBadgeTypes.includes('M01')) {
        newBadges.push({ badgeType: 'M01', name: 'First Step', icon: 'star' });
      }

      // 5 milestones
      if (milestoneCount >= 5 && !existingBadgeTypes.includes('M02')) {
        newBadges.push({ badgeType: 'M02', name: 'Memory Keeper', icon: 'album' });
      }

      // 10 milestones
      if (milestoneCount >= 10 && !existingBadgeTypes.includes('M03')) {
        newBadges.push({ badgeType: 'M03', name: 'Journal Hero', icon: 'book' });
      }

      // 25 milestones
      if (milestoneCount >= 25 && !existingBadgeTypes.includes('M04')) {
        newBadges.push({ badgeType: 'M04', name: 'Milestone Collector', icon: 'collections' });
      }

      // 50 milestones
      if (milestoneCount >= 50 && !existingBadgeTypes.includes('M05')) {
        newBadges.push({ badgeType: 'M05', name: 'Milestone Legend', icon: 'emoji_events' });
      }

      // First feeding log
      if (feedLogCount >= 1 && !existingBadgeTypes.includes('F01')) {
        newBadges.push({ badgeType: 'F01', name: 'First Nurture', icon: 'food' });
      }

      // 10 feeding logs
      if (feedLogCount >= 10 && !existingBadgeTypes.includes('F02')) {
        newBadges.push({ badgeType: 'F02', name: 'Feeding Pro', icon: 'bottle' });
      }

      // 50 feeding logs
      if (feedLogCount >= 50 && !existingBadgeTypes.includes('F03')) {
        newBadges.push({ badgeType: 'F03', name: 'Feeding Veteran', icon: 'restaurant' });
      }

      // First health record
      if (healthRecordCount >= 1 && !existingBadgeTypes.includes('H01')) {
        newBadges.push({ badgeType: 'H01', name: 'Health Keeper', icon: 'health_and_safety' });
      }

      // 10 health records
      if (healthRecordCount >= 10 && !existingBadgeTypes.includes('H02')) {
        newBadges.push({ badgeType: 'H02', name: 'Wellness Warrior', icon: 'favorite' });
      }

      // 25 health records
      if (healthRecordCount >= 25 && !existingBadgeTypes.includes('H03')) {
        newBadges.push({ badgeType: 'H03', name: 'Health Guardian', icon: 'shield' });
      }

      // First sleep log
      if (sleepLogCount >= 1 && !existingBadgeTypes.includes('S01')) {
        newBadges.push({ badgeType: 'S01', name: 'Sweet Dreams', icon: 'bedtime' });
      }

      // 10 sleep logs
      if (sleepLogCount >= 10 && !existingBadgeTypes.includes('S02')) {
        newBadges.push({ badgeType: 'S02', name: 'Sleep Tracker', icon: 'hotel' });
      }

      // 50 sleep logs
      if (sleepLogCount >= 50 && !existingBadgeTypes.includes('S03')) {
        newBadges.push({ badgeType: 'S03', name: 'Night Owl', icon: 'dark_mode' });
      }

      // First growth record
      if (growthRecordCount >= 1 && !existingBadgeTypes.includes('G01')) {
        newBadges.push({ badgeType: 'G01', name: 'Growth Watcher', icon: 'monitor_weight' });
      }

      // 10 growth records
      if (growthRecordCount >= 10 && !existingBadgeTypes.includes('G02')) {
        newBadges.push({ badgeType: 'G02', name: 'Healthy Tracker', icon: 'trending_up' });
      }

      // 25 growth records
      if (growthRecordCount >= 25 && !existingBadgeTypes.includes('G03')) {
        newBadges.push({ badgeType: 'G03', name: 'Growth Expert', icon: 'analytics' });
      }

      // ── Trait-based badges ──
      const traitCount = babyMon.traits?.length || 0;
      if (traitCount >= 1 && !existingBadgeTypes.includes('T01')) {
        newBadges.push({ badgeType: 'T01', name: 'Personality Discovered', icon: 'psychology' });
      }
      if (traitCount >= 3 && !existingBadgeTypes.includes('T02')) {
        newBadges.push({ badgeType: 'T02', name: 'Trait Collector', icon: 'palette' });
      }
      // Trait active for 30+ days
      if (babyMon.traitsUpdatedAt && (Date.now() - new Date(babyMon.traitsUpdatedAt).getTime()) > 30 * 86400000 && !existingBadgeTypes.includes('T03')) {
        newBadges.push({ badgeType: 'T03', name: 'Consistent Personality', icon: 'verified' });
      }

      // ── Text-based keyword badges (check recent milestones) ──
      let recentMilestones: { title: string; notes: string | null }[] = [];
      if (!existingBadgeTypes.includes('K01') || !existingBadgeTypes.includes('K02')) {
        recentMilestones = await tx.milestone.findMany({
          where: { babymonId, deletedAt: null },
          select: { title: true, notes: true },
          take: 50,
        });
        const allText = recentMilestones.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase();
        if (!existingBadgeTypes.includes('K01') && /calm|soothed|relaxed|peaceful/.test(allText)) {
          newBadges.push({ badgeType: 'K01', name: 'Calm Down', icon: 'self_improvement' });
        }
        if (!existingBadgeTypes.includes('K02') && /gentle|kind|sweet|caring/.test(allText)) {
          newBadges.push({ badgeType: 'K02', name: 'Soft Touch', icon: 'favorite_border' });
        }
      }

      // ── Higher count badges ──
      if (milestoneCount >= 100 && !existingBadgeTypes.includes('M06')) {
        newBadges.push({ badgeType: 'M06', name: 'Century Milestone', icon: 'military_tech' });
      }
      if (feedLogCount >= 100 && !existingBadgeTypes.includes('F04')) {
        newBadges.push({ badgeType: 'F04', name: 'Feeding Champion', icon: 'emoji_events' });
      }
      if (sleepLogCount >= 100 && !existingBadgeTypes.includes('S04')) {
        newBadges.push({ badgeType: 'S04', name: 'Sleep Master', icon: 'nights_stay' });
      }

      // ── Streak-based badges (consecutive days) ──
      if (!existingBadgeTypes.includes('S05')) {
        const sleepStreak = await countConsecutiveDays(tx, babymonId, 'sleepLog');
        if (sleepStreak >= 7) {
          newBadges.push({ badgeType: 'S05', name: 'Sleep Routine', icon: 'bedtime' });
        }
      }
      if (!existingBadgeTypes.includes('F05')) {
        const feedStreak = await countConsecutiveDays(tx, babymonId, 'feedLog');
        if (feedStreak >= 7) {
          newBadges.push({ badgeType: 'F05', name: 'Feeding Streak', icon: 'restaurant' });
        }
      }
      if (!existingBadgeTypes.includes('H04')) {
        const healthStreak = await countConsecutiveDays(tx, babymonId, 'healthRecord');
        if (healthStreak >= 7) {
          newBadges.push({ badgeType: 'H04', name: 'Health Streak', icon: 'local_hospital' });
        }
      }

      // ── Parenting badges (co-parent activity) ──
      const linkedAccountsCount = await tx.linkedBabyMon.count({ where: { babymonId } });
      if (linkedAccountsCount >= 1 && !existingBadgeTypes.includes('P01')) {
        newBadges.push({ badgeType: 'P01', name: 'Co-Parent', icon: 'group' });
      }

      const proposalsResponded = await tx.journalProposal.count({
        where: { babymonId, status: { in: ['APPROVED', 'REJECTED'] } },
      });
      if (proposalsResponded >= 1 && !existingBadgeTypes.includes('P02')) {
        newBadges.push({ badgeType: 'P02', name: 'Team Player', icon: 'handshake' });
      }
      if (proposalsResponded >= 10 && !existingBadgeTypes.includes('P03')) {
        newBadges.push({ badgeType: 'P03', name: 'Co-Parenting Pro', icon: 'diversity_3' });
      }

      // 10 journal entries
      if (journalCount >= 10 && !existingBadgeTypes.includes('P04')) {
        newBadges.push({ badgeType: 'P04', name: 'Journal Keeper', icon: 'menu_book' });
      }

      // 3 data exports
      if (exportCount >= 3 && !existingBadgeTypes.includes('P06')) {
        newBadges.push({ badgeType: 'P06', name: 'Data Driven Parent', icon: 'analytics' });
      }

      // ── Higher-tier count badges ──
      if (milestoneCount >= 250 && !existingBadgeTypes.includes('M07')) {
        newBadges.push({ badgeType: 'M07', name: 'Milestone Dynasty', icon: 'castle' });
      }
      if (feedLogCount >= 250 && !existingBadgeTypes.includes('F06')) {
        newBadges.push({ badgeType: 'F06', name: 'Feeding Legend', icon: 'stars' });
      }
      if (sleepLogCount >= 250 && !existingBadgeTypes.includes('S06')) {
        newBadges.push({ badgeType: 'S06', name: 'Dream Weaver', icon: 'cloud' });
      }
      if (babyMon.currentXp >= 2000 && !existingBadgeTypes.includes('X05')) {
        newBadges.push({ badgeType: 'X05', name: 'XP Champion', icon: 'rocket_launch' });
      }
      if (babyMon.currentXp >= 5000 && !existingBadgeTypes.includes('X06')) {
        newBadges.push({ badgeType: 'X06', name: 'XP Demigod', icon: 'crown' });
      }

      // ── 30-day streak badges ──
      if (!existingBadgeTypes.includes('S07')) {
        const longSleepStreak = await countConsecutiveDays(tx, babymonId, 'sleepLog');
        if (longSleepStreak >= 30) {
          newBadges.push({ badgeType: 'S07', name: 'Sleep Champion', icon: 'king_bed' });
        }
      }
      if (!existingBadgeTypes.includes('F07')) {
        const longFeedStreak = await countConsecutiveDays(tx, babymonId, 'feedLog');
        if (longFeedStreak >= 30) {
          newBadges.push({ badgeType: 'F07', name: 'Feeding Dedication', icon: 'dinner_dining' });
        }
      }

      // ── Final tier count badges ──
      if (milestoneCount >= 500 && !existingBadgeTypes.includes('M08')) {
        newBadges.push({ badgeType: 'M08', name: 'Milestone Immortal', icon: 'diamond' });
      }
      if (feedLogCount >= 500 && !existingBadgeTypes.includes('F08')) {
        newBadges.push({ badgeType: 'F08', name: 'Feeding Immortal', icon: 'diamond' });
      }
      if (sleepLogCount >= 500 && !existingBadgeTypes.includes('S08')) {
        newBadges.push({ badgeType: 'S08', name: 'Sleep Immortal', icon: 'diamond' });
      }
      if (healthRecordCount >= 100 && !existingBadgeTypes.includes('H05')) {
        newBadges.push({ badgeType: 'H05', name: 'Wellness Check Pro', icon: 'verified' });
      }
      if (growthRecordCount >= 50 && !existingBadgeTypes.includes('G04')) {
        newBadges.push({ badgeType: 'G04', name: 'Growth Champion', icon: 'emoji_events' });
      }

      // ── XP pinnacle badges ──
      if (babyMon.currentXp >= 10000 && !existingBadgeTypes.includes('X07')) {
        newBadges.push({ badgeType: 'X07', name: 'XP Titan', icon: 'emoji_events' });
      }
      if (babyMon.currentXp >= 25000 && !existingBadgeTypes.includes('X08')) {
        newBadges.push({ badgeType: 'X08', name: 'XP God', icon: 'diamond' });
      }

      // ── 60-day and 90-day streak badges ──
      if (!existingBadgeTypes.includes('S09')) {
        const superSleepStreak = await countConsecutiveDays(tx, babymonId, 'sleepLog');
        if (superSleepStreak >= 60) {
          newBadges.push({ badgeType: 'S09', name: 'Sleep Legend', icon: 'hotel_class' });
        }
      }
      if (!existingBadgeTypes.includes('F09')) {
        const superFeedStreak = await countConsecutiveDays(tx, babymonId, 'feedLog');
        if (superFeedStreak >= 60) {
          newBadges.push({ badgeType: 'F09', name: 'Feeding Legend', icon: 'stars' });
        }
      }

      // ── Trait variety badges ──
      if (traitCount >= 5 && !existingBadgeTypes.includes('T04')) {
        newBadges.push({ badgeType: 'T04', name: 'Personality Mosaic', icon: 'grid_view' });
      }
      if (babyMon.traitsUpdatedAt && (Date.now() - new Date(babyMon.traitsUpdatedAt).getTime()) > 90 * 86400000 && !existingBadgeTypes.includes('T05')) {
        newBadges.push({ badgeType: 'T05', name: 'Enduring Personality', icon: 'verified_user' });
      }

      // ── Keyword badges — expanded ──
      if (!existingBadgeTypes.includes('K03')) {
        const allText = recentMilestones.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase();
        if (/funny|cheeky|mischief|silly|giggle|laugh/.test(allText)) {
          newBadges.push({ badgeType: 'K03', name: 'First Mischief', icon: 'mood' });
        }
      }
      if (!existingBadgeTypes.includes('K04')) {
        const allText = recentMilestones.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase();
        if (/crawl|stand|walk|step|climb|run/.test(allText)) {
          newBadges.push({ badgeType: 'K04', name: 'Little Explorer', icon: 'hiking' });
        }
      }
      if (!existingBadgeTypes.includes('K05')) {
        const allText = recentMilestones.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase();
        if (/first word|mama|dada|babbled|spoke|said/.test(allText)) {
          newBadges.push({ badgeType: 'K05', name: 'First Words', icon: 'record_voice_over' });
        }
      }

      // XP thresholds
      if (babyMon.currentXp >= 50 && !existingBadgeTypes.includes('X01')) {
        newBadges.push({ badgeType: 'X01', name: 'Rising Star', icon: 'trending_up' });
      }

      if (babyMon.currentXp >= 100 && !existingBadgeTypes.includes('X02')) {
        newBadges.push({ badgeType: 'X02', name: 'Century Club', icon: 'hundred' });
      }

      if (babyMon.currentXp >= 500 && !existingBadgeTypes.includes('X03')) {
        newBadges.push({ badgeType: 'X03', name: 'Evolution Master', icon: 'evolve' });
      }

      // 1000 XP
      if (babyMon.currentXp >= 1000 && !existingBadgeTypes.includes('X04')) {
        newBadges.push({ badgeType: 'X04', name: 'XP Legend', icon: 'auto_awesome' });
      }

      // ═══ Category 1-7 gap-fill badges (matching 86-badge spec) ═══
      // M04: Roll Over (mobility milestone via keyword)
      if (!existingBadgeTypes.includes('M04')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/roll|crawl|scoot|tummy|motor/.test(txt)) newBadges.push({ badgeType: 'M04', name: 'Roll Over', icon: '360' }); }
      // M05: First Steps (walking milestone via keyword)
      if (!existingBadgeTypes.includes('M05')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/walk|step|stand|toddle|first step/.test(txt)) newBadges.push({ badgeType: 'M05', name: 'First Steps', icon: 'directions_walk' }); }
      // M06: First Words (speech milestone via keyword)
      if (!existingBadgeTypes.includes('M06')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/speech|word|talk|babble|language|say|first word|mama|dada/.test(txt)) newBadges.push({ badgeType: 'M06', name: 'First Words', icon: 'record_voice_over' }); }

      // F04: Breastfeeding Champ (20 breastmilk feeds)
      const breastmilkCount = await tx.feedLog.count({ where: { babymonId, deletedAt: null, type: 'BREASTMILK' } });
      if (breastmilkCount >= 20 && !existingBadgeTypes.includes('F04')) newBadges.push({ badgeType: 'F04', name: 'Breastfeeding Champ', icon: 'water_drop' });
      // F05: Solid Food Explorer (10 solid food entries)
      const solidCount = await tx.feedLog.count({ where: { babymonId, deletedAt: null, type: { in: ['SOLID', 'SOLIDS'] } } });
      if (solidCount >= 10 && !existingBadgeTypes.includes('F05')) newBadges.push({ badgeType: 'F05', name: 'Solid Food Explorer', icon: 'egg' });

      // S04: Nap Master (15 naps)
      const napCount = await tx.sleepLog.count({ where: { babymonId, deletedAt: null, type: 'NAP' } });
      if (napCount >= 15 && !existingBadgeTypes.includes('S04')) newBadges.push({ badgeType: 'S04', name: 'Nap Master', icon: 'airline_seat_individual_suite' });
      // S05: Night Owl (5 night sleeps > 8 hours) — approximate by night type count
      const nightCount = await tx.sleepLog.count({ where: { babymonId, deletedAt: null, type: 'NIGHT' } });
      if (nightCount >= 5 && !existingBadgeTypes.includes('S05')) newBadges.push({ badgeType: 'S05', name: 'Night Owl', icon: 'dark_mode' });

      // H04: Immunization Complete (5 vaccination records)
      const vaxCount = await tx.healthRecord.count({ where: { babymonId, deletedAt: null, category: 'VACCINATION' } });
      if (vaxCount >= 5 && !existingBadgeTypes.includes('H04')) newBadges.push({ badgeType: 'H04', name: 'Immunization Complete', icon: 'vaccines' });

      // P02: Co-Parent Pro (both parents log in same week — proxied by having linked accounts + recent entries)
      const linkedCount = await tx.linkedBabyMon.count({ where: { babymonId } });
      const weekAgo = new Date(Date.now() - 7 * 86400000);
      const recentByOwner = await tx.milestone.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: weekAgo } } });
      if (linkedCount >= 1 && recentByOwner >= 2 && !existingBadgeTypes.includes('P02')) newBadges.push({ badgeType: 'P02', name: 'Co-Parent Pro', icon: 'diversity_3' });
      // P04: Journal Keeper (10 journal entries — proxied by milestone+feed+sleep+health total)
      const totalEntries = milestoneCount + feedLogCount + sleepLogCount + healthRecordCount;
      if (totalEntries >= 10 && !existingBadgeTypes.includes('P04')) newBadges.push({ badgeType: 'P04', name: 'Journal Keeper', icon: 'edit_note' });

      // ═══ Category 8: Trait-Based Badges (T01-T48 gap fill) ═══
      const traits = babyMon.traits || [];
      const traitAgeDays = babyMon.traitsUpdatedAt ? Math.floor((Date.now() - new Date(babyMon.traitsUpdatedAt).getTime()) / 86400000) : 0;
      const photoCount = await tx.media.count({ where: { babyMonId: babymonId } });

      if (!existingBadgeTypes.includes('T01')) newBadges.push({ badgeType: 'T01', name: 'First Giggle', icon: 'mood' });
      if (totalEntries >= 15 && !existingBadgeTypes.includes('T02')) newBadges.push({ badgeType: 'T02', name: 'Playtime Champion', icon: 'celebration' });
      if (totalEntries >= 30 && traits.includes('Playful') && traitAgeDays >= 30 && !existingBadgeTypes.includes('T03')) newBadges.push({ badgeType: 'T03', name: 'Joy Bringer', icon: 'emoji_emotions' });
      if (milestoneCount >= 2 && !existingBadgeTypes.includes('T04')) newBadges.push({ badgeType: 'T04', name: 'Little Explorer', icon: 'explore' });
      if (milestoneCount >= 10 && !existingBadgeTypes.includes('T05')) newBadges.push({ badgeType: 'T05', name: 'Question Master', icon: 'psychology' });
      if (milestoneCount >= 20 && traits.includes('Curious') && traitAgeDays >= 30 && !existingBadgeTypes.includes('T06')) newBadges.push({ badgeType: 'T06', name: 'Curiosity Champ', icon: 'lightbulb' });
      if (sleepLogCount >= 2 && !existingBadgeTypes.includes('T07')) newBadges.push({ badgeType: 'T07', name: 'Nap Time', icon: 'airline_seat_flat' });
      if (!existingBadgeTypes.includes('T08')) { const s = await countConsecutiveDays(tx, babymonId, 'sleepLog'); if (s >= 7) newBadges.push({ badgeType: 'T08', name: 'Sleep Routine', icon: 'bed' }); }
      if (sleepLogCount >= 30 && traits.includes('Sleepy') && traitAgeDays >= 14 && !existingBadgeTypes.includes('T09')) newBadges.push({ badgeType: 'T09', name: 'Dream Master', icon: 'cloud' });
      if (feedLogCount >= 1 && !existingBadgeTypes.includes('T10')) newBadges.push({ badgeType: 'T10', name: 'First Bite', icon: 'icecream' });
      if (feedLogCount >= 20 && !existingBadgeTypes.includes('T11')) newBadges.push({ badgeType: 'T11', name: 'Healthy Appetite', icon: 'restaurant_menu' });
      if (feedLogCount >= 50 && traits.includes('Hungry') && traitAgeDays >= 14 && !existingBadgeTypes.includes('T12')) newBadges.push({ badgeType: 'T12', name: 'Food Critic', icon: 'menu_book' });
      if (!existingBadgeTypes.includes('T16')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/crawl|walk|step|stand|climb|motor/.test(txt)) newBadges.push({ badgeType: 'T16', name: 'First Step Out', icon: 'hiking' }); }
      if (traitCount >= 2 && !existingBadgeTypes.includes('T17')) newBadges.push({ badgeType: 'T17', name: 'Little Risk Taker', icon: 'terrain' });
      if (milestoneCount >= 2 && !existingBadgeTypes.includes('T19')) newBadges.push({ badgeType: 'T19', name: 'First Smile at Stranger', icon: 'waving_hand' });
      if (linkedCount >= 1 && totalEntries >= 10 && !existingBadgeTypes.includes('T20')) newBadges.push({ badgeType: 'T20', name: 'Friendly', icon: 'handshake' });
      if (linkedCount >= 2 && traits.includes('Social') && traitAgeDays >= 30 && !existingBadgeTypes.includes('T21')) newBadges.push({ badgeType: 'T21', name: 'Social Butterfly', icon: 'flutter_dash' });
      if (sleepLogCount >= 2 && !existingBadgeTypes.includes('T22')) newBadges.push({ badgeType: 'T22', name: 'Quiet Moment', icon: 'water_drop' });
      if (!existingBadgeTypes.includes('T25')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/crawl|motor|physical|active/.test(txt)) newBadges.push({ badgeType: 'T25', name: 'First Crawl', icon: 'directions_run' }); }
      if (traitCount >= 1 && !existingBadgeTypes.includes('T26')) newBadges.push({ badgeType: 'T26', name: 'Energy Burst', icon: 'bolt' });
      if (photoCount >= 1 && !existingBadgeTypes.includes('T28')) newBadges.push({ badgeType: 'T28', name: 'First Scribble', icon: 'brush' });
      if (photoCount >= 10 && !existingBadgeTypes.includes('T29')) newBadges.push({ badgeType: 'T29', name: 'Little Picasso', icon: 'palette' });
      if (photoCount >= 25 && traits.includes('Creative') && !existingBadgeTypes.includes('T30')) newBadges.push({ badgeType: 'T30', name: 'Creative Genius', icon: 'draw' });
      if (growthRecordCount >= 3 && !existingBadgeTypes.includes('T32')) newBadges.push({ badgeType: 'T32', name: 'Muscle Builder', icon: 'fitness_center' });
      if (growthRecordCount >= 10 && traits.includes('Strong') && !existingBadgeTypes.includes('T33')) newBadges.push({ badgeType: 'T33', name: 'Iron Baby', icon: 'shield_moon' });
      if (milestoneCount >= 5 && !existingBadgeTypes.includes('T35')) newBadges.push({ badgeType: 'T35', name: 'Problem Solver', icon: 'quiz' });
      if (milestoneCount >= 10 && !existingBadgeTypes.includes('T36')) newBadges.push({ badgeType: 'T36', name: 'Little Genius', icon: 'school' });

      // P05: Photo Collector (20 photos)
      if (photoCount >= 20 && !existingBadgeTypes.includes('P05')) newBadges.push({ badgeType: 'P05', name: 'Photo Collector', icon: 'photo_library' });

      // ── Final trait badge gap-fill ──
      if (!existingBadgeTypes.includes('T13')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true, notes: true }, take: 50 }); const txt = rm.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase(); if (/calm|soothed/.test(txt)) newBadges.push({ badgeType: 'T13', name: 'Calm Down', icon: 'self_improvement' }); }
      if (!existingBadgeTypes.includes('T14')) { const s = await countConsecutiveDays(tx, babymonId, 'sleepLog'); const f = await countConsecutiveDays(tx, babymonId, 'feedLog'); if (s >= 3 && f >= 3) newBadges.push({ badgeType: 'T14', name: 'Patience', icon: 'hourglass_empty' }); }
      if (!existingBadgeTypes.includes('T15')) { const s = await countConsecutiveDays(tx, babymonId, 'sleepLog'); if (s >= 14 && traits.includes('Fussy')) newBadges.push({ badgeType: 'T15', name: 'Zen Master', icon: 'spa' }); }
      if (!existingBadgeTypes.includes('T24')) { const s = await countConsecutiveDays(tx, babymonId, 'sleepLog'); if (s >= 7 && traits.includes('Calm')) newBadges.push({ badgeType: 'T24', name: 'Inner Peace', icon: 'meditation' }); }
      if (!existingBadgeTypes.includes('T27')) { const todayStart = new Date(); todayStart.setHours(0, 0, 0, 0); const todayEnd = new Date(todayStart.getTime() + 86400000); const todayEntries = await Promise.all([tx.milestone.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: todayStart, lt: todayEnd } } }), tx.feedLog.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: todayStart, lt: todayEnd } } }), tx.healthRecord.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: todayStart, lt: todayEnd } } }), tx.sleepLog.count({ where: { babymonId, deletedAt: null, startTime: { gte: todayStart, lt: todayEnd } } })]); if (todayEntries.reduce((a, b) => a + b, 0) >= 5 && traits.includes('Active') && !existingBadgeTypes.includes('T27')) newBadges.push({ badgeType: 'T27', name: 'Powerhouse', icon: 'flash_on' }); }
      if (!existingBadgeTypes.includes('T31')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/motor|physical|strong|push|muscle/.test(txt)) newBadges.push({ badgeType: 'T31', name: 'First Pushup', icon: 'fitness_center' }); }
      if (!existingBadgeTypes.includes('T34')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/cognitive|speech|word|language|talk/.test(txt)) newBadges.push({ badgeType: 'T34', name: 'First Word', icon: 'record_voice_over' }); }
      if (!existingBadgeTypes.includes('T37')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true, notes: true }, take: 50 }); const txt = rm.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase(); if (/gentle|kind/.test(txt)) newBadges.push({ badgeType: 'T37', name: 'Soft Touch', icon: 'favorite_border' }); }
      if (!existingBadgeTypes.includes('T40')) newBadges.push({ badgeType: 'T40', name: 'First Try', icon: 'rocket_launch' });
      // T18: Fearless Explorer — entries in 5+ categories (milestone, feed, sleep, health, growth)
      const categoryCount = [milestoneCount > 0, feedLogCount > 0, sleepLogCount > 0, healthRecordCount > 0, growthRecordCount > 0, photoCount > 0, linkedCount > 0, napCount > 0].filter(Boolean).length;
      if (categoryCount >= 5 && !existingBadgeTypes.includes('T18')) newBadges.push({ badgeType: 'T18', name: 'Fearless Explorer', icon: 'map' });
      // T23: Gentle Soul — 5 entries tagged with calm
      if (!existingBadgeTypes.includes('T23')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true, notes: true }, take: 100 }); const calmCount = rm.filter(m => /calm/.test(`${m.title} ${m.notes || ''}`.toLowerCase())).length; if (calmCount >= 5) newBadges.push({ badgeType: 'T23', name: 'Gentle Soul', icon: 'park' }); }
      // T38: Kind Heart — journal entry about sharing or kindness (via milestone notes)
      if (!existingBadgeTypes.includes('T38')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true, notes: true }, take: 50 }); const txt = rm.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase(); if (/shar(e|ing)|kindness|generous|gave|helped/.test(txt)) newBadges.push({ badgeType: 'T38', name: 'Kind Heart', icon: 'volunteer_activism' }); }
      // T39: Gentle Giant — 30 entries + Gentle trait 30 days
      if (totalEntries >= 30 && traits.includes('Gentle') && traitAgeDays >= 30 && !existingBadgeTypes.includes('T39')) newBadges.push({ badgeType: 'T39', name: 'Gentle Giant', icon: 'diversity_3' });
      // T41: Courageous — entries in 4+ categories
      if (categoryCount >= 4 && !existingBadgeTypes.includes('T41')) newBadges.push({ badgeType: 'T41', name: 'Courageous', icon: 'shield' });
      // T42: Fearless — 5+ entries in a single week
      const weekEntries = await Promise.all([tx.milestone.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: weekAgo } } }), tx.feedLog.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: weekAgo } } }), tx.healthRecord.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: weekAgo } } }), tx.sleepLog.count({ where: { babymonId, deletedAt: null, startTime: { gte: weekAgo } } }), tx.growthRecord.count({ where: { babyMonId: babymonId, deletedAt: null, measuredAt: { gte: weekAgo } } })]);
      if (weekEntries.reduce((a, b) => a + b, 0) >= 5 && !existingBadgeTypes.includes('T42')) newBadges.push({ badgeType: 'T42', name: 'Fearless', icon: 'bolt' });
      // T43: First Mischief — milestone notes containing funny or cheeky
      if (!existingBadgeTypes.includes('T43')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true, notes: true }, take: 50 }); const txt = rm.map(m => `${m.title} ${m.notes || ''}`).join(' ').toLowerCase(); if (/funny|cheeky|mischief|silly|giggle/.test(txt)) newBadges.push({ badgeType: 'T43', name: 'First Mischief', icon: 'sentiment_very_satisfied' }); }
      // T44: Prankster — 3 photos uploaded
      if (photoCount >= 3 && !existingBadgeTypes.includes('T44')) newBadges.push({ badgeType: 'T44', name: 'Prankster', icon: 'camera' });
      // T45: Master Jester — 20 photos + Cheeky trait
      if (photoCount >= 20 && traits.includes('Cheeky') && !existingBadgeTypes.includes('T45')) newBadges.push({ badgeType: 'T45', name: 'Master Jester', icon: 'theater_comedy' });
      // T46: First Babble — SPEECH or SOCIAL milestone
      if (!existingBadgeTypes.includes('T46')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/speech|social|babble|talk|chat/.test(txt)) newBadges.push({ badgeType: 'T46', name: 'First Babble', icon: 'chat' }); }
      // T47: Storyteller — 5 journal entries (proxied by milestone notes length)
      const journalEntries = await tx.milestone.count({ where: { babymonId, deletedAt: null, notes: { not: null } } });
      if (journalEntries >= 5 && !existingBadgeTypes.includes('T47')) newBadges.push({ badgeType: 'T47', name: 'Storyteller', icon: 'auto_stories' });
      // T48: Chatterbox — 15 journal entries + Chatty trait 30 days
      if (journalEntries >= 15 && traits.includes('Chatty') && traitAgeDays >= 30 && !existingBadgeTypes.includes('T48')) newBadges.push({ badgeType: 'T48', name: 'Chatterbox', icon: 'forum' });
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

/**
 * Count consecutive days of activity for a given entry type.
 * Queries the entry table directly (milestones, feed-logs, etc.) grouped by date.
 */
async function countConsecutiveDays(
  tx: any,
  babymonId: string,
  type: 'milestone' | 'feedLog' | 'sleepLog' | 'healthRecord' | 'growthRecord',
): Promise<number> {
  const tableMap: Record<string, string> = {
    milestone: 'milestone',
    feedLog: 'feedLog',
    sleepLog: 'sleepLog',
    healthRecord: 'healthRecord',
    growthRecord: 'growthRecord',
  };
  const table = tableMap[type];
  const dateField = type === 'sleepLog' ? 'startTime' : type === 'growthRecord' ? 'measuredAt' : 'happenedAt';

  // Get distinct dates with entries, ordered by date descending
  const rows = await tx.$queryRawUnsafe(
    `SELECT DISTINCT DATE("${dateField}") as date FROM "${table}" WHERE "babymonId" = $1 AND "deletedAt" IS NULL ORDER BY date DESC LIMIT 100`,
    babymonId,
	  ) as Array<{ date: string }>;

  if (rows.length === 0) return 0;

  let streak = 1;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Check if the most recent date is today or yesterday
  const mostRecent = new Date(rows[0].date);
  if (mostRecent.getTime() < today.getTime() - 86400000) return 0; // gap > 1 day

  // Count consecutive days
  for (let i = 1; i < rows.length; i++) {
    const current = new Date(rows[i - 1].date);
    const previous = new Date(rows[i].date);
    const diffDays = Math.round((current.getTime() - previous.getTime()) / 86400000);
    if (diffDays === 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}
