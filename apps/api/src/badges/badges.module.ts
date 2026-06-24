import { Module } from '@nestjs/common';
import { BadgesService } from './badges.service';
import { BadgesController, BabyMonBadgesController } from './badges.controller';

@Module({
  controllers: [BadgesController, BabyMonBadgesController],
  providers: [BadgesService],
  exports: [BadgesService],
})
export class BadgesModule {}
