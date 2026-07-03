import { Injectable, ForbiddenException } from '@nestjs/common';
import { ErrorCode } from '../common/enums/error-code.enum';
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

  // ── Locale-aware badge name/description overrides ──
  // Keys are locale codes; values map badgeType → { name?, description? }
  private static readonly badgeLocaleOverrides: Record<string, Record<string, { name?: string; description?: string }>> = {
    ar: {
      M01: { name: 'أول إنجاز', description: 'سجل إنجازًا واحدًا' },
      M02: { name: 'متتبع الإنجازات', description: 'سجل 10 إنجازات' },
      M03: { name: 'خبير الإنجازات', description: 'سجل 25 إنجازًا' },
      M04: { name: 'التدحرج', description: 'سجل إنجازًا حركيًا' },
      M05: { name: 'الخطوات الأولى', description: 'سجل إنجازًا للمشي' },
      M06: { name: 'الكلمات الأولى', description: 'سجل إنجازًا للكلام' },
      M07: { name: 'أسطورة الإنجازات', description: 'سجل 50 إنجازًا' },
      F01: { name: 'أول رضعة', description: 'سجل تغذية واحدة' },
      F02: { name: 'طفل جائع', description: 'سجل 10 رضعات' },
      F03: { name: 'محترف التغذية', description: 'سجل 50 رضعة' },
      F04: { name: 'بطل الرضاعة', description: 'سجل 20 رضعة طبيعية' },
      F05: { name: 'مستكشف الطعام الصلب', description: 'سجل 10 وجبات صلبة' },
      F06: { name: 'أسطورة التغذية', description: 'سجل 100 رضعة' },
      S01: { name: 'أول سجل نوم', description: 'سجل جلسة نوم واحدة' },
      S02: { name: 'متتبع النوم', description: 'سجل 10 جلسات نوم' },
      S03: { name: 'خبير النوم', description: 'سجل 30 جلسة نوم' },
      S04: { name: 'سيد القيلولة', description: 'سجل 15 قيلولة' },
      S05: { name: 'بومة الليل', description: 'سجل 5 نومات ليلية > 8 ساعات' },
      S06: { name: 'أسطورة النوم', description: 'سجل 100 جلسة نوم' },
      H01: { name: 'أول فحص', description: 'سجل سجلًا صحيًا واحدًا' },
      H02: { name: 'متتبع الصحة', description: 'سجل 10 سجلات صحية' },
      H03: { name: 'حارس الصحة', description: 'سجل 25 سجلًا صحيًا' },
      H04: { name: 'اكتمال التطعيم', description: 'سجل 5 تطعيمات' },
      H05: { name: 'محترف الفحص', description: 'سجل زيارة + وزن + طول + حرارة في يوم واحد' },
      G01: { name: 'أول قياس', description: 'سجل قياس نمو واحد' },
      G02: { name: 'ينمو بقوة', description: 'سجل 10 قياسات نمو' },
      G03: { name: 'نمو ثابت', description: 'سجل 25 قياس نمو' },
      G04: { name: 'بطل النمو', description: 'سجل 50 قياس نمو' },
      P01: { name: 'لاعب الفريق', description: 'أضف شريكًا واحدًا' },
      P02: { name: 'محترف المشاركة', description: 'كلا الوالدين يسجلان في نفس الأسبوع' },
      P03: { name: 'والد خارق', description: 'سجل يوميًا لمدة 30 يومًا' },
      P04: { name: 'حافظ اليوميات', description: 'اكتب 10 تدوينات يومية' },
      P05: { name: 'جامع الصور', description: 'ارفع 20 صورة' },
      P06: { name: 'والد معتمد على البيانات', description: 'صدر البيانات 3 مرات' },
      X01: { name: 'نجم صاعد', description: 'اكسب 100 نقطة خبرة' },
      X02: { name: 'نادي المئة', description: 'اكسب 500 نقطة خبرة' },
      X03: { name: 'سيد التطور', description: 'اكسب 1000 نقطة خبرة' },
      X04: { name: 'أسطورة الخبرة', description: 'اكسب 5000 نقطة خبرة' },
      X05: { name: 'بطل الخبرة', description: 'اكسب 10000 نقطة خبرة' },
      X06: { name: 'نصف إله الخبرة', description: 'اكسب 25000 نقطة خبرة' },
      X07: { name: 'عملاق الخبرة', description: 'اكسب 50000 نقطة خبرة' },
      X08: { name: 'إله الخبرة', description: 'اكسب 100000 نقطة خبرة' },
      K01: { name: 'اهدأ', description: 'سجل إنجازًا عن التهدئة' },
      K02: { name: 'لمسة ناعمة', description: 'سجل إنجازًا عن اللطف' },
      K03: { name: 'أول شقاوة', description: 'سجل إنجازًا عن الضحك' },
      K04: { name: 'مستكشف صغير', description: 'سجل إنجازًا عن الزحف' },
      K05: { name: 'الكلمات الأولى', description: 'سجل إنجازًا عن الكلام' },
      // checkAndAwardBadges override descriptions
      M08: { description: 'سجل 100 إنجاز' },
      M09: { description: 'سجل إنجاز التدحرج' },
      M10: { description: 'سجل إنجاز الخطوات الأولى' },
      M11: { description: 'سجل إنجاز الكلمات الأولى' },
      F07: { description: 'حافظ على سلسلة تغذية لمدة 7 أيام' },
      F08: { description: 'سجل 500 رضعة' },
      F09: { description: 'حافظ على سلسلة تغذية لمدة 30 يومًا' },
      F10: { description: 'سجل 20 رضعة طبيعية' },
      F11: { description: 'سجل 10 أطعمة صلبة' },
      S07: { description: 'حافظ على سلسلة نوم لمدة 7 أيام' },
      S08: { description: 'سجل 500 جلسة نوم' },
      S09: { description: 'حافظ على سلسلة نوم لمدة 30 يومًا' },
      S10: { description: 'سجل 15 قيلولة' },
      S11: { description: 'سجل 5 نومات ليلية' },
      H06: { description: 'سجل 5 تطعيمات' },
      P07: { description: 'شارك في التربية مع شريك' },
      P08: { description: 'اكتب 10 تدوينات يومية' },
      T01: { description: 'سجل سمة الفضول' },
      T02: { description: 'سجل سمة اللعب' },
      T03: { description: 'سجل سمة الفرح' },
      T04: { description: 'سجل سمة الاستكشاف' },
      T05: { description: 'سجل سمة طرح الأسئلة' },
      T06: { description: 'سجل سمة الفضول 5 مرات' },
      T07: { description: 'سجل سمة القيلولة' },
      T08: { description: 'سجل سمة روتين النوم' },
      T09: { description: 'سجل سمة الأحلام' },
      T10: { description: 'سجل سمة الطعام الأول' },
      T11: { description: 'سجل سمة الشهية الصحية' },
      T12: { description: 'سجل سمة النقد الغذائي' },
      T13: { description: 'سجل سمة الهدوء' },
      T14: { description: 'سجل سمة الصبر' },
      T15: { description: 'سجل سمة zen' },
      T16: { description: 'سجل سمة الخروج الأول' },
      T17: { description: 'سجل سمة المخاطرة' },
      T18: { description: 'سجل سمة الاستكشاف الشجاع' },
      T19: { description: 'سجل سمة الابتسام للغرباء' },
      T20: { description: 'سجل سمة الود' },
      T21: { description: 'سجل سمة الفراشة الاجتماعية' },
      T22: { description: 'سجل سمة اللحظة الهادئة' },
      T23: { description: 'سجل سمة الروح اللطيفة' },
      T24: { description: 'سجل سمة السلام الداخلي' },
      T25: { description: 'سجل سمة الزحف الأول' },
      T26: { description: 'سجل سمة انفجار الطاقة' },
      T27: { description: 'سجل سمة القوة' },
      T28: { description: 'سجل سمة الخربشة الأولى' },
      T29: { description: 'سجل سمة بيكاسو الصغير' },
      T30: { description: 'سجل سمة العبقرية الإبداعية' },
      T31: { description: 'سجل سمة أول تمرين ضغط' },
      T32: { description: 'سجل سمة بناء العضلات' },
      T33: { description: 'سجل سمة الطفل الحديدي' },
      T34: { description: 'سجل سمة الكلمة الأولى' },
      T35: { description: 'سجل سمة حل المشكلات' },
      T36: { description: 'سجل سمة العبقري الصغير' },
      T37: { description: 'سجل سمة اللمسة الناعمة' },
      T38: { description: 'سجل سمة القلب الطيب' },
      T39: { description: 'سجل سمة العملاق اللطيف' },
      T40: { description: 'سجل سمة المحاولة الأولى' },
      T41: { description: 'سجل سمة الشجاعة' },
      T42: { description: 'سجل سمة الجرأة' },
      T43: { description: 'سجل سمة الشقاوة الأولى' },
      T44: { description: 'سجل سمة المخادع' },
      T45: { description: 'سجل سمة المهرج الرئيسي' },
      T46: { description: 'سجل سمة الثرثرة الأولى' },
      T47: { description: 'سجل سمة الراوي' },
      T48: { description: 'سجل سمة الثرثار' },
    },
    pt: {
      M01: { description: 'Registe 1 marco' }, M02: { description: 'Registe 10 marcos' }, M03: { description: 'Registe 25 marcos' },
      M04: { description: 'Registe um marco de mobilidade' }, M05: { description: 'Registe um marco de caminhada' },
      M06: { description: 'Registe um marco de fala' }, M07: { description: 'Registe 50 marcos' }, M08: { description: 'Registe 500 marcos' },
      F01: { description: 'Registe 1 alimentacao' }, F02: { description: 'Registe 10 alimentacoes' }, F03: { description: 'Registe 50 alimentacoes' },
      F04: { description: 'Registe 20 mamadas' }, F05: { description: 'Registe 10 alimentos solidos' }, F06: { description: 'Registe 100 alimentacoes' },
      F07: { description: 'Sequencia de 30 dias de alimentacao' }, F08: { description: 'Registe 500 alimentacoes' }, F09: { description: 'Sequencia de 60 dias de alimentacao' },
      S01: { description: 'Registe 1 sessao de sono' }, S02: { description: 'Registe 10 sessoes de sono' }, S03: { description: 'Registe 30 sessoes de sono' },
      S04: { description: 'Registe 15 sestas' }, S05: { description: 'Registe 5 noites de sono > 8 horas' }, S06: { description: 'Registe 100 sessoes de sono' },
      S07: { description: 'Sequencia de 30 dias de sono' }, S08: { description: 'Registe 500 sessoes de sono' }, S09: { description: 'Sequencia de 60 dias de sono' },
      H01: { description: 'Registe 1 registo de saude' }, H02: { description: 'Registe 10 registos de saude' }, H03: { description: 'Registe 25 registos de saude' },
      H04: { description: 'Registe 5 registos de vacinacao' }, H05: { description: 'Registe consulta + peso + altura + temp num dia' },
      G01: { description: 'Registe 1 medico de crescimento' }, G02: { description: 'Registe 10 medicoes de crescimento' },
      G03: { description: 'Registe 25 medicoes de crescimento' }, G04: { description: 'Registe 50 medicoes de crescimento' },
      P01: { description: 'Adicione 1 parceiro' }, P02: { description: 'Ambos os pais registam na mesma semana' },
      P03: { description: 'Registe entradas diarias por 30 dias' }, P04: { description: 'Escreva 10 entradas no diario' },
      P05: { description: 'Carregue 20 fotos' }, P06: { description: 'Exporte dados 3 vezes' },
      X01: { description: 'Alcance 100 XP total' }, X02: { description: 'Alcance 500 XP total' }, X03: { description: 'Alcance 1000 XP total' },
      X04: { description: 'Alcance 5000 XP total' }, X05: { description: 'Alcance 10.000 XP total' }, X06: { description: 'Alcance 25.000 XP total' },
      X07: { description: 'Alcance 50.000 XP total' }, X08: { description: 'Alcance 100.000 XP total' },
      T01: { description: 'Registe 2 marcos do tipo SOCIAL ou PLAY' }, T02: { description: 'Registe 15 entradas no total' },
      T03: { description: '30 entradas + traco Brincalhao ativo por 30 dias' }, T04: { description: 'Registe 2 marcos SOCIAIS ou COGNITIVOS' },
      T05: { description: 'Registe 10 marcos de qualquer tipo' }, T06: { description: '20 marcos + traco Curioso ativo por 30 dias' },
      T07: { description: 'Registe 2 sessoes de sono' }, T08: { description: '7 dias consecutivos de registos de sono' },
      T09: { description: '30 sessoes de sono + traco Sonolento ativo por 14 dias' },
      T10: { description: 'Registe 1 alimento solido' }, T11: { description: 'Registe 20 alimentacoes de qualquer tipo' },
      T12: { description: '50 alimentacoes + traco Faminto ativo por 14 dias' },
      T13: { description: 'Registe 1 marco com notas contendo calmo ou acalmado' }, T14: { description: '3 dias seguidos com registo de sono E alimentacao' },
      T15: { description: '14 dias de sequencia diaria + traco Irritado ativo' },
      T16: { description: 'Registe 1 marco do tipo MOTOR' }, T17: { description: 'Registe entradas em 5 categorias diferentes' },
      T18: { description: 'Registe entradas em todas as 8 categorias pelo menos uma vez' },
      T19: { description: 'Registe 2 marcos SOCIAIS' }, T20: { description: 'Tenha 1 parceiro vinculado + registe 10 entradas' },
      T21: { description: '2+ parceiros vinculados + traco Social ativo por 30 dias' },
      T22: { description: 'Registe 2 sessoes de sono > 2 horas' }, T23: { description: 'Registe 5 entradas com calmo nas notas' },
      T24: { description: 'Sequencia de 7 dias de sono + traco Calmo ativo' },
      T25: { description: 'Registe 1 marco MOTOR' }, T26: { description: 'Registe entradas em 3+ categorias no mesmo dia' },
      T27: { description: 'Registe 5 entradas num unico dia + traco Ativo ativo' },
      T28: { description: 'Carregue 1 foto' }, T29: { description: 'Carregue 10 fotos ou entrada no diario com foto' },
      T30: { description: 'Carregue 25 fotos no total' },
      T31: { description: 'Registe 1 marco MOTOR ou FISICO' }, T32: { description: 'Registe 3 medicoes de peso mostrando aumento' },
      T33: { description: '10 medicoes de crescimento + traco Forte ativo' },
      T34: { description: 'Registe 1 marco COGNITIVO ou de FALA' }, T35: { description: 'Registe 5 marcos cognitivos' },
      T36: { description: 'Registe 10 marcos de varios tipos' },
      T37: { description: 'Registe 1 marco com notas contendo gentil ou bondoso' }, T38: { description: 'Entrada no diario sobre partilha ou bondade' },
      T39: { description: '30 entradas totais + traco Gentil ativo por 30 dias' },
      T40: { description: 'Registe 1 marco em qualquer nova categoria' }, T41: { description: 'Registe entradas em 4+ categorias diferentes' },
      T42: { description: 'Registe 5+ entradas numa unica semana' },
      T43: { description: 'Registe 1 marco com notas contendo engracado ou travesso' }, T44: { description: 'Carregue 3 fotos (momentos de travessura!)' },
      T45: { description: '20 fotos carregadas + traco Travesso ativo' },
      T46: { description: 'Registe 1 marco de FALA ou SOCIAL' }, T47: { description: 'Escreva 5 entradas no diario' },
      T48: { description: '15 entradas no diario + traco Falador ativo por 30 dias' },
      K01: { description: 'Registe um marco sobre acalmar' }, K02: { description: 'Registe um marco sobre gentileza' },
      K03: { description: 'Registe um marco sobre risos' }, K04: { description: 'Registe um marco sobre gatinhar' },
      K05: { description: 'Registe um marco sobre falar' },
    },
    es: {
      M01: { description: 'Registra 1 hito' }, M02: { description: 'Registra 10 hitos' }, M03: { description: 'Registra 25 hitos' },
      M04: { description: 'Registra un hito de movilidad' }, M05: { description: 'Registra un hito de caminar' },
      M06: { description: 'Registra un hito de habla' }, M07: { description: 'Registra 50 hitos' }, M08: { description: 'Registra 500 hitos' },
      F01: { description: 'Registra 1 alimentacion' }, F02: { description: 'Registra 10 alimentaciones' }, F03: { description: 'Registra 50 alimentaciones' },
      F04: { description: 'Registra 20 tomas de pecho' }, F05: { description: 'Registra 10 alimentos solidos' }, F06: { description: 'Registra 100 alimentaciones' },
      F07: { description: 'Racha de 30 dias de alimentacion' }, F08: { description: 'Registra 500 alimentaciones' }, F09: { description: 'Racha de 60 dias de alimentacion' },
      S01: { description: 'Registra 1 sesion de sueno' }, S02: { description: 'Registra 10 sesiones de sueno' }, S03: { description: 'Registra 30 sesiones de sueno' },
      S04: { description: 'Registra 15 siestas' }, S05: { description: 'Registra 5 noches de sueno > 8 horas' }, S06: { description: 'Registra 100 sesiones de sueno' },
      S07: { description: 'Racha de 30 dias de sueno' }, S08: { description: 'Registra 500 sesiones de sueno' }, S09: { description: 'Racha de 60 dias de sueno' },
      H01: { description: 'Registra 1 registro de salud' }, H02: { description: 'Registra 10 registros de salud' }, H03: { description: 'Registra 25 registros de salud' },
      H04: { description: 'Registra 5 vacunas' }, H05: { description: 'Registra visita + peso + altura + temp en un dia' },
      G01: { description: 'Registra 1 medicion de crecimiento' }, G02: { description: 'Registra 10 mediciones de crecimiento' },
      G03: { description: 'Registra 25 mediciones de crecimiento' }, G04: { description: 'Registra 50 mediciones de crecimiento' },
      P01: { description: 'Agrega 1 companero' }, P02: { description: 'Ambos padres registran en la misma semana' },
      P03: { description: 'Registra diariamente por 30 dias' }, P04: { description: 'Escribe 10 entradas de diario' },
      P05: { description: 'Sube 20 fotos' }, P06: { description: 'Exporta datos 3 veces' },
      X01: { description: 'Alcanza 100 XP total' }, X02: { description: 'Alcanza 500 XP total' }, X03: { description: 'Alcanza 1000 XP total' },
      X04: { description: 'Alcanza 5000 XP total' }, X05: { description: 'Alcanza 10.000 XP total' }, X06: { description: 'Alcanza 25.000 XP total' },
      X07: { description: 'Alcanza 50.000 XP total' }, X08: { description: 'Alcanza 100.000 XP total' },
      T01: { description: 'Registra 2 hitos de tipo SOCIAL o JUEGO' }, T02: { description: 'Registra 15 entradas en total' },
      T03: { description: '30 entradas + rasgo Jugueton activo por 30 dias' }, T04: { description: 'Registra 2 hitos SOCIALES o COGNITIVOS' },
      T05: { description: 'Registra 10 hitos de cualquier tipo' }, T06: { description: '20 hitos + rasgo Curioso activo por 30 dias' },
      T07: { description: 'Registra 2 sesiones de sueno' }, T08: { description: '7 dias consecutivos de registros de sueno' },
      T09: { description: '30 sesiones de sueno + rasgo Sonoliento activo por 14 dias' },
      T10: { description: 'Registra 1 alimento solido' }, T11: { description: 'Registra 20 alimentaciones de cualquier tipo' },
      T12: { description: '50 alimentaciones + rasgo Hambriento activo por 14 dias' },
      T13: { description: 'Registra 1 hito con notas que contienen calma o tranquilizado' }, T14: { description: '3 dias seguidos con registro de sueno Y alimentacion' },
      T15: { description: '14 dias de racha diaria + rasgo Irritable activo' },
      T16: { description: 'Registra 1 hito de tipo MOTOR' }, T17: { description: 'Registra entradas en 5 categorias diferentes' },
      T18: { description: 'Registra entradas en las 8 categorias al menos una vez' },
      T19: { description: 'Registra 2 hitos SOCIALES' }, T20: { description: 'Ten 1 companero vinculado + registra 10 entradas' },
      T21: { description: '2+ companeros vinculados + rasgo Social activo por 30 dias' },
      T22: { description: 'Registra 2 sesiones de sueno > 2 horas' }, T23: { description: 'Registra 5 entradas con calma en notas' },
      T24: { description: 'Racha de 7 dias de sueno + rasgo Calmado activo' },
      T25: { description: 'Registra 1 hito MOTOR' }, T26: { description: 'Registra entradas en 3+ categorias el mismo dia' },
      T27: { description: 'Registra 5 entradas en un solo dia + rasgo Activo activo' },
      T28: { description: 'Sube 1 foto' }, T29: { description: 'Sube 10 fotos o entrada de diario con foto' },
      T30: { description: 'Sube 25 fotos en total' },
      T31: { description: 'Registra 1 hito MOTOR o FISICO' }, T32: { description: 'Registra 3 mediciones de peso mostrando aumento' },
      T33: { description: '10 mediciones de crecimiento + rasgo Fuerte activo' },
      T34: { description: 'Registra 1 hito COGNITIVO o de HABLA' }, T35: { description: 'Registra 5 hitos cognitivos' },
      T36: { description: 'Registra 10 hitos de varios tipos' },
      T37: { description: 'Registra 1 hito con notas que contienen gentil o amable' }, T38: { description: 'Entrada de diario sobre compartir o bondad' },
      T39: { description: '30 entradas totales + rasgo Gentil activo por 30 dias' },
      T40: { description: 'Registra 1 hito en cualquier nueva categoria' }, T41: { description: 'Registra entradas en 4+ categorias diferentes' },
      T42: { description: 'Registra 5+ entradas en una sola semana' },
      T43: { description: 'Registra 1 hito con notas que contienen divertido o travieso' }, T44: { description: 'Sube 3 fotos (momentos traviesos!)' },
      T45: { description: '20 fotos subidas + rasgo Travieso activo' },
      T46: { description: 'Registra 1 hito de HABLA o SOCIAL' }, T47: { description: 'Escribe 5 entradas de diario' },
      T48: { description: '15 entradas de diario + rasgo Charlatan activo por 30 dias' },
      K01: { description: 'Registra un hito sobre calmar' }, K02: { description: 'Registra un hito sobre amabilidad' },
      K03: { description: 'Registra un hito sobre risas' }, K04: { description: 'Registra un hito sobre gatear' },
      K05: { description: 'Registra un hito sobre hablar' },
    },
    fr: {
      M01: { description: 'Enregistrez 1 etape' }, M02: { description: 'Enregistrez 10 etapes' }, M03: { description: 'Enregistrez 25 etapes' },
      M04: { description: 'Enregistrez une etape de mobilite' }, M05: { description: 'Enregistrez une etape de marche' },
      M06: { description: 'Enregistrez une etape de parole' }, M07: { description: 'Enregistrez 50 etapes' }, M08: { description: 'Enregistrez 500 etapes' },
      F01: { description: 'Enregistrez 1 repas' }, F02: { description: 'Enregistrez 10 repas' }, F03: { description: 'Enregistrez 50 repas' },
      F04: { description: 'Enregistrez 20 tetees' }, F05: { description: 'Enregistrez 10 aliments solides' }, F06: { description: 'Enregistrez 100 repas' },
      F07: { description: 'Serie de 30 jours de repas' }, F08: { description: 'Enregistrez 500 repas' }, F09: { description: 'Serie de 60 jours de repas' },
      S01: { description: 'Enregistrez 1 sommeil' }, S02: { description: 'Enregistrez 10 sommeils' }, S03: { description: 'Enregistrez 30 sommeils' },
      S04: { description: 'Enregistrez 15 siestes' }, S05: { description: 'Enregistrez 5 nuits > 8 heures' }, S06: { description: 'Enregistrez 100 sommeils' },
      S07: { description: 'Serie de 30 jours de sommeil' }, S08: { description: 'Enregistrez 500 sommeils' }, S09: { description: 'Serie de 60 jours de sommeil' },
      H01: { description: 'Enregistrez 1 dossier sante' }, H02: { description: 'Enregistrez 10 dossiers sante' }, H03: { description: 'Enregistrez 25 dossiers sante' },
      H04: { description: 'Enregistrez 5 vaccins' }, H05: { description: 'Enregistrez visite + poids + taille + temp en un jour' },
      G01: { description: 'Enregistrez 1 mesure de croissance' }, G02: { description: 'Enregistrez 10 mesures de croissance' },
      G03: { description: 'Enregistrez 25 mesures de croissance' }, G04: { description: 'Enregistrez 50 mesures de croissance' },
      P01: { description: 'Ajoutez 1 partenaire' }, P02: { description: 'Les deux parents enregistrent la meme semaine' },
      P03: { description: 'Enregistrez quotidiennement pendant 30 jours' }, P04: { description: 'Ecrivez 10 entrees de journal' },
      P05: { description: 'Telechargez 20 photos' }, P06: { description: 'Exportez les donnees 3 fois' },
      X01: { description: 'Atteignez 100 XP total' }, X02: { description: 'Atteignez 500 XP total' }, X03: { description: 'Atteignez 1000 XP total' },
      X04: { description: 'Atteignez 5000 XP total' }, X05: { description: 'Atteignez 10.000 XP total' }, X06: { description: 'Atteignez 25.000 XP total' },
      X07: { description: 'Atteignez 50.000 XP total' }, X08: { description: 'Atteignez 100.000 XP total' },
      T01: { description: 'Enregistrez 2 etapes de type SOCIAL ou JEU' }, T02: { description: 'Enregistrez 15 entrees au total' },
      T03: { description: '30 entrees + trait Joueur actif pendant 30 jours' }, T04: { description: 'Enregistrez 2 etapes SOCIALES ou COGNITIVES' },
      T05: { description: 'Enregistrez 10 etapes de tout type' }, T06: { description: '20 etapes + trait Curieux actif pendant 30 jours' },
      T07: { description: 'Enregistrez 2 sommeils' }, T08: { description: '7 jours consecutifs de journal de sommeil' },
      T09: { description: '30 sommeils + trait Endormi actif pendant 14 jours' },
      T10: { description: 'Enregistrez 1 aliment solide' }, T11: { description: 'Enregistrez 20 repas de tout type' },
      T12: { description: '50 repas + trait Affame actif pendant 14 jours' },
      T13: { description: 'Enregistrez 1 etape avec notes contenant calme ou apaise' }, T14: { description: '3 jours consecutifs avec sommeil ET repas' },
      T15: { description: '14 jours de serie quotidienne + trait Difficile actif' },
      T16: { description: 'Enregistrez 1 etape de type MOTEUR' }, T17: { description: 'Enregistrez des entrees dans 5 categories differentes' },
      T18: { description: 'Enregistrez des entrees dans les 8 categories au moins une fois' },
      T19: { description: 'Enregistrez 2 etapes SOCIALES' }, T20: { description: 'Ayez 1 partenaire lie + enregistrez 10 entrees' },
      T21: { description: '2+ partenaires lies + trait Social actif pendant 30 jours' },
      T22: { description: 'Enregistrez 2 sommeils > 2 heures' }, T23: { description: 'Enregistrez 5 entrees avec calme dans les notes' },
      T24: { description: 'Serie de 7 jours de sommeil + trait Calme actif' },
      T25: { description: 'Enregistrez 1 etape MOTEUR' }, T26: { description: 'Enregistrez des entrees dans 3+ categories le meme jour' },
      T27: { description: 'Enregistrez 5 entrees en un seul jour + trait Actif actif' },
      T28: { description: 'Telechargez 1 photo' }, T29: { description: 'Telechargez 10 photos ou entree de journal avec photo' },
      T30: { description: 'Telechargez 25 photos au total' },
      T31: { description: 'Enregistrez 1 etape MOTEUR ou PHYSIQUE' }, T32: { description: 'Enregistrez 3 mesures de poids montrant une augmentation' },
      T33: { description: '10 mesures de croissance + trait Fort actif' },
      T34: { description: 'Enregistrez 1 etape COGNITIVE ou de PAROLE' }, T35: { description: 'Enregistrez 5 etapes cognitives' },
      T36: { description: 'Enregistrez 10 etapes de types varies' },
      T37: { description: 'Enregistrez 1 etape avec notes contenant doux ou gentil' }, T38: { description: 'Entree de journal sur le partage ou la gentillesse' },
      T39: { description: '30 entrees totales + trait Doux actif pendant 30 jours' },
      T40: { description: 'Enregistrez 1 etape dans toute nouvelle categorie' }, T41: { description: 'Enregistrez des entrees dans 4+ categories differentes' },
      T42: { description: 'Enregistrez 5+ entrees en une seule semaine' },
      T43: { description: 'Enregistrez 1 etape avec notes contenant drole ou coquin' }, T44: { description: 'Telechargez 3 photos (moments coquins!)' },
      T45: { description: '20 photos telechargees + trait Coquin actif' },
      T46: { description: 'Enregistrez 1 etape de PAROLE ou SOCIALE' }, T47: { description: 'Ecrivez 5 entrees de journal' },
      T48: { description: '15 entrees de journal + trait Bavard actif pendant 30 jours' },
      K01: { description: 'Enregistrez une etape sur l\'apaisement' }, K02: { description: 'Enregistrez une etape sur la douceur' },
      K03: { description: 'Enregistrez une etape sur les rires' }, K04: { description: 'Enregistrez une etape sur ramper' },
      K05: { description: 'Enregistrez une etape sur parler' },
    },
    de: {
      M01: { description: '1 Meilenstein protokollieren' }, M02: { description: '10 Meilensteine protokollieren' }, M03: { description: '25 Meilensteine protokollieren' },
      M04: { description: 'Mobilitats-Meilenstein protokollieren' }, M05: { description: 'Lauf-Meilenstein protokollieren' },
      M06: { description: 'Sprach-Meilenstein protokollieren' }, M07: { description: '50 Meilensteine protokollieren' }, M08: { description: '500 Meilensteine protokollieren' },
      F01: { description: '1 Futterung protokollieren' }, F02: { description: '10 Futterungen protokollieren' }, F03: { description: '50 Futterungen protokollieren' },
      F04: { description: '20 Stillmahlzeiten protokollieren' }, F05: { description: '10 feste Nahrung protokollieren' }, F06: { description: '100 Futterungen protokollieren' },
      F07: { description: '30-Tage-Futterungsserie' }, F08: { description: '500 Futterungen protokollieren' }, F09: { description: '60-Tage-Futterungsserie' },
      S01: { description: '1 Schlaf protokollieren' }, S02: { description: '10 Schlaf protokollieren' }, S03: { description: '30 Schlaf protokollieren' },
      S04: { description: '15 Nickerchen protokollieren' }, S05: { description: '5 Nachte > 8 Std. protokollieren' }, S06: { description: '100 Schlaf protokollieren' },
      S07: { description: '30-Tage-Schlafserie' }, S08: { description: '500 Schlaf protokollieren' }, S09: { description: '60-Tage-Schlafserie' },
      H01: { description: '1 Gesundheitsakte protokollieren' }, H02: { description: '10 Gesundheitsakten protokollieren' }, H03: { description: '25 Gesundheitsakten protokollieren' },
      H04: { description: '5 Impfungen protokollieren' }, H05: { description: 'Besuch + Gewicht + Grose + Temp an einem Tag protokollieren' },
      G01: { description: '1 Wachstumsmessung protokollieren' }, G02: { description: '10 Wachstumsmessungen protokollieren' },
      G03: { description: '25 Wachstumsmessungen protokollieren' }, G04: { description: '50 Wachstumsmessungen protokollieren' },
      P01: { description: '1 Partner hinzufugen' }, P02: { description: 'Beide Eltern protokollieren in derselben Woche' },
      P03: { description: 'Taglich 30 Tage lang protokollieren' }, P04: { description: '10 Tagebucheintrage schreiben' },
      P05: { description: '20 Fotos hochladen' }, P06: { description: 'Daten 3x exportieren' },
      X01: { description: '100 Gesamt-XP erreichen' }, X02: { description: '500 Gesamt-XP erreichen' }, X03: { description: '1000 Gesamt-XP erreichen' },
      X04: { description: '5000 Gesamt-XP erreichen' }, X05: { description: '10.000 Gesamt-XP erreichen' }, X06: { description: '25.000 Gesamt-XP erreichen' },
      X07: { description: '50.000 Gesamt-XP erreichen' }, X08: { description: '100.000 Gesamt-XP erreichen' },
      T01: { description: '2 Meilensteine vom Typ SOZIAL oder SPIEL protokollieren' }, T02: { description: '15 Eintrage insgesamt protokollieren' },
      T03: { description: '30 Eintrage + Eigenschaft Verspielt 30 Tage aktiv' }, T04: { description: '2 SOZIALE oder KOGNITIVE Meilensteine protokollieren' },
      T05: { description: '10 Meilensteine beliebigen Typs protokollieren' }, T06: { description: '20 Meilensteine + Eigenschaft Neugierig 30 Tage aktiv' },
      T07: { description: '2 Schlaf protokollieren' }, T08: { description: '7 aufeinanderfolgende Tage Schlafprotokolle' },
      T09: { description: '30 Schlaf + Eigenschaft Schlafer 14 Tage aktiv' },
      T10: { description: '1 feste Nahrung protokollieren' }, T11: { description: '20 Futterungen beliebigen Typs protokollieren' },
      T12: { description: '50 Futterungen + Eigenschaft Hungrig 14 Tage aktiv' },
      T13: { description: '1 Meilenstein mit Notiz ruhig oder beruhigt protokollieren' }, T14: { description: '3 aufeinanderfolgende Tage mit Schlaf UND Futterung' },
      T15: { description: '14 Tage tagliche Serie + Eigenschaft Quengelig aktiv' },
      T16: { description: '1 Meilenstein vom Typ MOTORIK protokollieren' }, T17: { description: 'Eintrage in 5 verschiedenen Kategorien protokollieren' },
      T18: { description: 'Eintrage in allen 8 Kategorien mindestens einmal protokollieren' },
      T19: { description: '2 SOZIALE Meilensteine protokollieren' }, T20: { description: '1 Partner verknupft + 10 Eintrage protokollieren' },
      T21: { description: '2+ Partner verknupft + Eigenschaft Sozial 30 Tage aktiv' },
      T22: { description: '2 Schlaf > 2 Stunden protokollieren' }, T23: { description: '5 Eintrage mit ruhig in Notizen protokollieren' },
      T24: { description: '7-Tage-Schlafserie + Eigenschaft Ruhig aktiv' },
      T25: { description: '1 MOTORIK-Meilenstein protokollieren' }, T26: { description: 'Eintrage in 3+ Kategorien am selben Tag protokollieren' },
      T27: { description: '5 Eintrage an einem Tag + Eigenschaft Aktiv aktiv' },
      T28: { description: '1 Foto hochladen' }, T29: { description: '10 Fotos oder Tagebucheintrag mit Foto hochladen' },
      T30: { description: '25 Fotos insgesamt hochladen' },
      T31: { description: '1 MOTORIK- oder KORPER-Meilenstein protokollieren' }, T32: { description: '3 Gewichtsmessungen mit Anstieg protokollieren' },
      T33: { description: '10 Wachstumsmessungen + Eigenschaft Stark aktiv' },
      T34: { description: '1 KOGNITIVEN oder SPRACH-Meilenstein protokollieren' }, T35: { description: '5 kognitive Meilensteine protokollieren' },
      T36: { description: '10 Meilensteine verschiedener Typen protokollieren' },
      T37: { description: '1 Meilenstein mit Notiz sanft oder freundlich protokollieren' }, T38: { description: 'Tagebucheintrag uber Teilen oder Freundlichkeit' },
      T39: { description: '30 Eintrage insgesamt + Eigenschaft Sanft 30 Tage aktiv' },
      T40: { description: '1 Meilenstein in einer neuen Kategorie protokollieren' }, T41: { description: 'Eintrage in 4+ verschiedenen Kategorien protokollieren' },
      T42: { description: '5+ Eintrage in einer Woche protokollieren' },
      T43: { description: '1 Meilenstein mit Notiz lustig oder frech protokollieren' }, T44: { description: '3 Fotos hochladen (Streich-Momente!)' },
      T45: { description: '20 Fotos hochgeladen + Eigenschaft Frech aktiv' },
      T46: { description: '1 SPRACH- oder SOZIAL-Meilenstein protokollieren' }, T47: { description: '5 Tagebucheintrage schreiben' },
      T48: { description: '15 Tagebucheintrage + Eigenschaft Geschwatzig 30 Tage aktiv' },
      K01: { description: 'Meilenstein uber Beruhigung protokollieren' }, K02: { description: 'Meilenstein uber Sanftheit protokollieren' },
      K03: { description: 'Meilenstein uber Kichern protokollieren' }, K04: { description: 'Meilenstein uber Krabbeln protokollieren' },
      K05: { description: 'Meilenstein uber Sprechen protokollieren' },
    },
    he: {
      M01: { description: 'רשום אבן דרך אחת' }, M02: { description: 'רשום 10 אבני דרך' }, M03: { description: 'רשום 25 אבני דרך' },
      M04: { description: 'רשום אבן דרך ניידות' }, M05: { description: 'רשום אבן דרך הליכה' },
      M06: { description: 'רשום אבן דרך דיבור' }, M07: { description: 'רשום 50 אבני דרך' }, M08: { description: 'רשום 500 אבני דרך' },
      F01: { description: 'רשום האכלה אחת' }, F02: { description: 'רשום 10 האכלות' }, F03: { description: 'רשום 50 האכלות' },
      F04: { description: 'רשום 20 הנקות' }, F05: { description: 'רשום 10 מזונות מוצקים' }, F06: { description: 'רשום 100 האכלות' },
      F07: { description: 'רצף האכלה של 30 יום' }, F08: { description: 'רשום 500 האכלות' }, F09: { description: 'רצף האכלה של 60 יום' },
      S01: { description: 'רשום שנת לילה אחת' }, S02: { description: 'רשום 10 שנות לילה' }, S03: { description: 'רשום 30 שנות לילה' },
      S04: { description: 'רשום 15 תנומות' }, S05: { description: 'רשום 5 לילות שינה > 8 שעות' }, S06: { description: 'רשום 100 שנות לילה' },
      S07: { description: 'רצף שינה של 30 יום' }, S08: { description: 'רשום 500 שנות לילה' }, S09: { description: 'רצף שינה של 60 יום' },
      H01: { description: 'רשום רישום בריאות אחד' }, H02: { description: 'רשום 10 רישומי בריאות' }, H03: { description: 'רשום 25 רישומי בריאות' },
      H04: { description: 'רשום 5 חיסונים' }, H05: { description: 'רשום ביקור + משקל + גובה + חום ביום אחד' },
      G01: { description: 'רשום מדידת גדילה אחת' }, G02: { description: 'רשום 10 מדידות גדילה' },
      G03: { description: 'רשום 25 מדידות גדילה' }, G04: { description: 'רשום 50 מדידות גדילה' },
      P01: { description: 'הוסף שותף אחד' }, P02: { description: 'שני ההורים רושמים באותו שבוע' },
      P03: { description: 'רשום מדי יום במשך 30 יום' }, P04: { description: 'כתוב 10 רישומי יומן' },
      P05: { description: 'העלה 20 תמונות' }, P06: { description: 'יצא נתונים 3 פעמים' },
      X01: { description: 'השג 100 נקודות XP סה"כ' }, X02: { description: 'השג 500 נקודות XP סה"כ' }, X03: { description: 'השג 1000 נקודות XP סה"כ' },
      X04: { description: 'השג 5000 נקודות XP סה"כ' }, X05: { description: 'השג 10,000 נקודות XP סה"כ' }, X06: { description: 'השג 25,000 נקודות XP סה"כ' },
      X07: { description: 'השג 50,000 נקודות XP סה"כ' }, X08: { description: 'השג 100,000 נקודות XP סה"כ' },
      T01: { description: 'רשום 2 אבני דרך מסוג SOCIAL או PLAY' }, T02: { description: 'רשום 15 רשומות בסך הכל' },
      T03: { description: '30 רשומות + תכונה שובב פעילה למשך 30 יום' }, T04: { description: 'רשום 2 אבני דרך SOCIAL או COGNITIVE' },
      T05: { description: 'רשום 10 אבני דרך מכל סוג' }, T06: { description: '20 אבני דרך + תכונה סקרן פעילה למשך 30 יום' },
      T07: { description: 'רשום 2 שינות' }, T08: { description: '7 ימים רצופים של רישומי שינה' },
      T09: { description: '30 שינות + תכונה ישנוני פעילה למשך 14 יום' },
      T10: { description: 'רשום מזון מוצק אחד' }, T11: { description: 'רשום 20 האכלות מכל סוג' },
      T12: { description: '50 האכלות + תכונה רעב פעילה למשך 14 יום' },
      T13: { description: 'רשום אבן דרך עם הערות המכילות רגוע או מורגע' }, T14: { description: '3 ימים רצופים עם רישום שינה והאכלה' },
      T15: { description: '14 ימי רצף יומי + תכונה קפריזי פעילה' },
      T16: { description: 'רשום אבן דרך מסוג MOTOR' }, T17: { description: 'רשום רשומות ב-5 קטגוריות שונות' },
      T18: { description: 'רשום רשומות בכל 8 הקטגוריות לפחות פעם אחת' },
      T19: { description: 'רשום 2 אבני דרך SOCIAL' }, T20: { description: 'יש שותף אחד מקושר + רשום 10 רשומות' },
      T21: { description: '2+ שותפים מקושרים + תכונה חברותי פעילה למשך 30 יום' },
      T22: { description: 'רשום 2 שינות > 2 שעות' }, T23: { description: 'רשום 5 רשומות עם רגוע בהערות' },
      T24: { description: 'רצף שינה של 7 ימים + תכונה רגוע פעילה' },
      T25: { description: 'רשום אבן דרך MOTOR' }, T26: { description: 'רשום רשומות ב-3+ קטגוריות באותו יום' },
      T27: { description: 'רשום 5 רשומות ביום אחד + תכונה פעיל פעילה' },
      T28: { description: 'העלה תמונה אחת' }, T29: { description: 'העלה 10 תמונות או רישום יומן עם תמונה' },
      T30: { description: 'העלה 25 תמונות בסך הכל' },
      T31: { description: 'רשום אבן דרך MOTOR או PHYSICAL' }, T32: { description: 'רשום 3 מדידות משקל המראות עליה' },
      T33: { description: '10 מדידות גדילה + תכונה חזק פעילה' },
      T34: { description: 'רשום אבן דרך COGNITIVE או SPEECH' }, T35: { description: 'רשום 5 אבני דרך קוגניטיביות' },
      T36: { description: 'רשום 10 אבני דרך מסוגים שונים' },
      T37: { description: 'רשום אבן דרך עם הערות המכילות עדין או טוב' }, T38: { description: 'רישום יומן על שיתוף או טוב לב' },
      T39: { description: '30 רשומות בסך הכל + תכונה עדין פעילה למשך 30 יום' },
      T40: { description: 'רשום אבן דרך בכל קטגוריה חדשה' }, T41: { description: 'רשום רשומות ב-4+ קטגוריות שונות' },
      T42: { description: 'רשום 5+ רשומות בשבוע אחד' },
      T43: { description: 'רשום אבן דרך עם הערות המכילות מצחיק או חצוף' }, T44: { description: 'העלה 3 תמונות (רגעי שובבות!)' },
      T45: { description: '20 תמונות שהועלו + תכונה חצוף פעילה' },
      T46: { description: 'רשום אבן דרך SPEECH או SOCIAL' }, T47: { description: 'כתוב 5 רישומי יומן' },
      T48: { description: '15 רישומי יומן + תכונה פטפטן פעילה למשך 30 יום' },
      K01: { description: 'רשום אבן דרך על הרגעה' }, K02: { description: 'רשום אבן דרך על עדינות' },
      K03: { description: 'רשום אבן דרך על צחוק' }, K04: { description: 'רשום אבן דרך על זחילה' },
      K05: { description: 'רשום אבן דרך על דיבור' },
    },
  };

  async getBadgeDefinitions(locale?: string) {
    const defs = { ...BADGE_DEFINITIONS };
    if (locale && BadgesService.badgeLocaleOverrides[locale]) {
      const overrides = BadgesService.badgeLocaleOverrides[locale];
      for (const [key, override] of Object.entries(overrides)) {
        if (defs[key]) {
          if (override.name) defs[key] = { ...defs[key], name: override.name };
          if (override.description) defs[key] = { ...defs[key], description: override.description };
        }
      }
    }
    return defs;
  }

  async findAll(babymonId: string, userId: string) {
    const babyMon = await this.prisma.babyMon.findFirst({ where: { id: babymonId, deletedAt: null } });
    if (!babyMon || babyMon.ownerUserId !== userId) {
      const linked = await this.prisma.linkedAccount.findFirst({
        where: { OR: [{ userAId: userId, userBId: babyMon?.ownerUserId }, { userBId: userId, userAId: babyMon?.ownerUserId }] },
      });
      if (!linked) throw new ForbiddenException({ message: 'Access denied', code: ErrorCode.UNAUTHORIZED });
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
      if (!existingBadgeTypes.includes('M09')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/roll|crawl|scoot|tummy|motor/.test(txt)) newBadges.push({ badgeType: 'M09', name: 'Roll Over', icon: '360' }); }
      // M10: First Steps (walking milestone via keyword)
      if (!existingBadgeTypes.includes('M10')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/walk|step|stand|toddle|first step/.test(txt)) newBadges.push({ badgeType: 'M10', name: 'First Steps', icon: 'directions_walk' }); }
      // M11: First Words (speech milestone via keyword)
      if (!existingBadgeTypes.includes('M11')) { const rm = await tx.milestone.findMany({ where: { babymonId, deletedAt: null }, select: { title: true }, take: 50 }); const txt = rm.map(m => m.title.toLowerCase()).join(' '); if (/speech|word|talk|babble|language|say|first word|mama|dada/.test(txt)) newBadges.push({ badgeType: 'M11', name: 'First Words', icon: 'record_voice_over' }); }

      // F10: Breastfeeding Champ (20 breastmilk feeds)
      const breastmilkCount = await tx.feedLog.count({ where: { babymonId, deletedAt: null, type: 'BREASTMILK' } });
      if (breastmilkCount >= 20 && !existingBadgeTypes.includes('F10')) newBadges.push({ badgeType: 'F10', name: 'Breastfeeding Champ', icon: 'water_drop' });
      // F11: Solid Food Explorer (10 solid food entries)
      const solidCount = await tx.feedLog.count({ where: { babymonId, deletedAt: null, type: { in: ['SOLID', 'SOLIDS'] } } });
      if (solidCount >= 10 && !existingBadgeTypes.includes('F11')) newBadges.push({ badgeType: 'F11', name: 'Solid Food Explorer', icon: 'egg' });

      // S10: Nap Master (15 naps)
      const napCount = await tx.sleepLog.count({ where: { babymonId, deletedAt: null, type: 'NAP' } });
      if (napCount >= 15 && !existingBadgeTypes.includes('S10')) newBadges.push({ badgeType: 'S10', name: 'Nap Master', icon: 'airline_seat_individual_suite' });
      // S11: Night Owl (5 night sleeps > 8 hours) — approximate by night type count
      const nightCount = await tx.sleepLog.count({ where: { babymonId, deletedAt: null, type: 'NIGHT' } });
      if (nightCount >= 5 && !existingBadgeTypes.includes('S11')) newBadges.push({ badgeType: 'S11', name: 'Night Owl', icon: 'dark_mode' });

      // H06: Immunization Complete (5 vaccination records)
      const vaxCount = await tx.healthRecord.count({ where: { babymonId, deletedAt: null, category: 'VACCINATION' } });
      if (vaxCount >= 5 && !existingBadgeTypes.includes('H06')) newBadges.push({ badgeType: 'H06', name: 'Immunization Complete', icon: 'vaccines' });

      // P07: Co-Parent Pro (both parents log in same week)
      const linkedCount = await tx.linkedBabyMon.count({ where: { babymonId } });
      const weekAgo = new Date(Date.now() - 7 * 86400000);
      const recentByOwner = await tx.milestone.count({ where: { babymonId, deletedAt: null, happenedAt: { gte: weekAgo } } });
      if (linkedCount >= 1 && recentByOwner >= 2 && !existingBadgeTypes.includes('P07')) newBadges.push({ badgeType: 'P07', name: 'Co-Parent Pro', icon: 'diversity_3' });
      // P08: Journal Keeper (10 journal entries)
      const totalEntries = milestoneCount + feedLogCount + sleepLogCount + healthRecordCount;
      if (totalEntries >= 10 && !existingBadgeTypes.includes('P08')) newBadges.push({ badgeType: 'P08', name: 'Journal Keeper', icon: 'edit_note' });

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
        await tx.badge.upsert({
          where: { babymonId_badgeType: { babymonId, badgeType: badge.badgeType } },
          create: { babymonId, badgeType: badge.badgeType, name: badge.name, icon: badge.icon },
          update: {},
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
    milestone: 'Milestone',
    feedLog: 'FeedLog',
    sleepLog: 'SleepLog',
    healthRecord: 'HealthRecord',
    growthRecord: 'GrowthRecord',
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
