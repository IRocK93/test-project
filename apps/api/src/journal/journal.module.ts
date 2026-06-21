import { Module } from '@nestjs/common';
import { JournalService } from './journal.service';
import { JournalProposalsService } from './journal-proposals.service';
import { JournalController } from './journal.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AccessControlService } from '../common/access-control.service';

@Module({
  imports: [PrismaModule],
  controllers: [JournalController],
  providers: [JournalService, JournalProposalsService, AccessControlService],
  exports: [JournalService, JournalProposalsService],
})
export class JournalModule {}
