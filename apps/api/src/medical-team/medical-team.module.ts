import { Module } from '@nestjs/common';
import { MedicalTeamService } from './medical-team.service';
import { MedicalTeamController } from './medical-team.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({ imports: [PrismaModule], controllers: [MedicalTeamController], providers: [MedicalTeamService], exports: [MedicalTeamService] })
export class MedicalTeamModule {}