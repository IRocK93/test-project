import { Module } from '@nestjs/common';
import { LinkedAccountsController, BabyMonPartnersController } from './linked-accounts.controller';
import { LinkedAccountsService } from './linked-accounts.service';
import { PrismaModule } from '../prisma/prisma.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [PrismaModule, MailModule],
  controllers: [LinkedAccountsController, BabyMonPartnersController],
  providers: [LinkedAccountsService],
  exports: [LinkedAccountsService],
})
export class LinkedAccountsModule {}
