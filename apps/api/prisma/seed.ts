import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// System IDs - using fixed UUIDs for consistency
const SYSTEM_USER_ID = '00000000-0000-0000-0000-000000000001';
const SYSTEM_BABYMON_ID = '00000000-0000-0000-0000-000000000000';

async function main() {
  console.log('Seeding database...');

  // Ensure system user exists
  let user = await prisma.user.findUnique({ where: { id: SYSTEM_USER_ID } });
  if (!user) {
    user = await prisma.user.create({
      data: {
        id: SYSTEM_USER_ID,
        email: 'system@babymon.local',
        name: 'System',
      },
    });
    console.log('Created system user');
  }

  // Ensure system BabyMon exists for default content
  let babyMon = await prisma.babyMon.findUnique({ where: { id: SYSTEM_BABYMON_ID } });
  if (!babyMon) {
    babyMon = await prisma.babyMon.create({
      data: {
        id: SYSTEM_BABYMON_ID,
        ownerUserId: SYSTEM_USER_ID,
        name: 'System Default',
        stageStartType: 'IDEA',
        gender: 'UNKNOWN',
      },
    });
    console.log('Created system BabyMon for default content');
  }

  // Seed stage content for pregnancy weeks
  for (let week = 1; week <= 40; week++) {
    await prisma.stageContent.upsert({
      where: {
        babymonId_stageKey: {
          babymonId: SYSTEM_BABYMON_ID,
          stageKey: `preg_week_${week}`,
        },
      },
      update: {},
      create: {
        babymonId: SYSTEM_BABYMON_ID,
        stageKey: `preg_week_${week}`,
        weekNumber: week,
        isPostBirth: false,
        summaryText: `Week ${week} of pregnancy: Your baby is growing beautifully. This is a crucial development stage where {name} is forming all their major organs.`,
        nurturingText: `Take time to rest and nourish yourself. Gentle movement, healthy eating, and plenty of water support {name}'s growth. Consider talking to your baby - they can hear you now!`,
        encouragementText: `You're doing amazing! Every day you nurture {name} brings you closer to meeting your little one. This week marks important milestones in development.`,
        xpThreshold: week * 10,
      },
    });
  }

  // Seed stage content for post-birth weeks (0-12)
  for (let week = 0; week <= 12; week++) {
    await prisma.stageContent.upsert({
      where: {
        babymonId_stageKey: {
          babymonId: SYSTEM_BABYMON_ID,
          stageKey: `born_week_${week}`,
        },
      },
      update: {},
      create: {
        babymonId: SYSTEM_BABYMON_ID,
        stageKey: `born_week_${week}`,
        weekNumber: week,
        isPostBirth: true,
        summaryText: `Week ${week} after birth: {name} is developing new skills every day. ${week === 0 ? 'Welcome to the world, little one!' : ''}`,
        nurturingText: `Bonding time is precious. Respond to {name}'s cues - crying is their only way to communicate. Skin-to-skin contact helps regulate their temperature and builds connection.`,
        encouragementText: `You're an incredible parent! {name} feels safe and loved in your arms. Each day brings new discoveries as you learn each other's rhythms.`,
        xpThreshold: week * 15,
      },
    });
  }

  // Seed stage content for post-birth months (3-24)
  for (let month = 3; month <= 24; month++) {
    await prisma.stageContent.upsert({
      where: {
        babymonId_stageKey: {
          babymonId: SYSTEM_BABYMON_ID,
          stageKey: `born_month_${month}`,
        },
      },
      update: {},
      create: {
        babymonId: SYSTEM_BABYMON_ID,
        stageKey: `born_month_${month}`,
        monthNumber: month,
        isPostBirth: true,
        summaryText: `Month ${month}: {name} continues to grow and discover the world. ${month >= 6 ? 'They may be starting solids soon!' : ''} ${month >= 12 ? 'Happy first birthday!' : ''}`,
        nurturingText: `Encourage exploration and play. {name} learns so much through interaction with you. ${month >= 6 ? 'This is a great time to introduce age-appropriate foods.' : ''}`,
        encouragementText: `What a journey! {name} is thriving thanks to your loving care. ${month >= 12 ? 'One year of amazing parenting!' : 'Enjoy each moment of this precious time.'}`,
        xpThreshold: month * 50,
      },
    });
  }

  console.log('Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
