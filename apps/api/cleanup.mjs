import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function cleanup() {
  // Delete all old test data in order (children first)
  await prisma.entryChangeProposal.deleteMany();
  await prisma.journalProposal.deleteMany();
  await prisma.auditLog.deleteMany();
  await prisma.stageContent.deleteMany();
  await prisma.linkedBabyMon.deleteMany();
  await prisma.media.deleteMany();
  await prisma.growthRecord.deleteMany();
  await prisma.badge.deleteMany();
  await prisma.milestone.deleteMany();
  await prisma.feedLog.deleteMany();
  await prisma.healthRecord.deleteMany();
  await prisma.sleepLog.deleteMany();
  
  const result = await prisma.babyMon.deleteMany();
  console.log(`Deleted ${result.count} BabyMons`);
  
  // Keep the newest one by owner
  const babyMons = await prisma.babyMon.findMany();
  console.log(`Remaining BabyMons: ${babyMons.length}`);
  
  await prisma.$disconnect();
}

cleanup().catch(e => { console.error(e); process.exit(1); });