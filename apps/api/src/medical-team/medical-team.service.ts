import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MedicalTeamService {
  constructor(private prisma: PrismaService) {}

  async findAll(babyMonId: string) {
    return this.prisma.medicalTeam.findMany({ where: { babyMonId, deletedAt: null }, orderBy: { createdAt: 'desc' } });
  }

  async create(babyMonId: string, userId: string, d: any) {
    return this.prisma.medicalTeam.create({ data: { babyMonId, userId, name: d.name, specialty: d.specialty, facility: d.facility, notes: d.notes } });
  }

  async remove(id: string) {
    return this.prisma.medicalTeam.update({ where: { id }, data: { deletedAt: new Date() } });
  }
}