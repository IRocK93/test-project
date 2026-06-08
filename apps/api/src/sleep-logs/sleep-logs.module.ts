import { Module } from '@nestjs/common';
import { SleepLogsController } from './sleep-logs.controller';
import { SleepLogsService } from './sleep-logs.service';
import { PrismaModule } from '../prisma/prisma.module';
import { BabyMonModule } from '../baby-mon/baby-mon.module';

@Module({
  imports: [PrismaModule, BabyMonModule],
  controllers: [SleepLogsController],
  providers: [SleepLogsService],
  exports: [SleepLogsService],
})
export class SleepLogsModule {}
