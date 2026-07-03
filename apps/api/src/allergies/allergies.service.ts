import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { validateAllergySeverity } from '../common/health-value-keys';
import { AllergySeverity } from './dto/allergy.dto';
import { ErrorCode } from '../common/enums/error-code.enum';

@Injectable()
export class AllergiesService {
  constructor(private prisma: PrismaService) {}

  async findAll(babyMonId: string, userId: string, skip?: number, take?: number) {
    return this.prisma.allergy.findMany({
      where: { babyMonId, deletedAt: null },
      include: { events: { orderBy: { happenedAt: 'desc' } } },
      orderBy: { createdAt: 'desc' },
      skip,
      take,
    });
  }

  async create(babyMonId: string, userId: string, data: {
    name: string; triggers?: string; severity?: AllergySeverity; treatment?: string; notes?: string;
    happenedAt?: string;
  }) {
    if (data.severity) {
      try {
        validateAllergySeverity(data.severity);
      } catch (err: any) {
        throw new BadRequestException({ message: err.message, code: ErrorCode.VALIDATION_ERROR });
      }
    }
    // Check for duplicate allergy name for this baby
    const existing = await this.prisma.allergy.findFirst({
      where: { babyMonId, name: data.name, deletedAt: null },
    });
    if (existing) {
      // Allergy already exists — just add a new event to it
      if (existing.status === 'CURED') {
        // Reactivate if previously cured
        await this.prisma.allergy.update({ where: { id: existing.id }, data: { status: 'ACTIVE', curedAt: null } });
      }
      return this.prisma.allergyEvent.create({
        data: {
          allergyId: existing.id,
          babyMonId,
          userId,
          happenedAt: data.happenedAt ? new Date(data.happenedAt) : new Date(),
          notes: data.notes,
        },
        include: { allergy: true },
      });
    }
    // Create new allergy profile + first event
    return this.prisma.allergy.create({
      data: {
        babyMonId, userId, name: data.name, triggers: data.triggers,
        severity: data.severity, treatment: data.treatment, notes: null,
        events: {
          create: {
            babyMonId, userId,
            happenedAt: data.happenedAt ? new Date(data.happenedAt) : new Date(),
            notes: data.notes,
          },
        },
      },
      include: { events: true },
    });
  }

  async addEvent(babyMonId: string, userId: string, allergyId: string, data: { happenedAt?: string; notes?: string }) {
    const allergy = await this.prisma.allergy.findFirst({ where: { id: allergyId, babyMonId, deletedAt: null } });
    if (!allergy) throw new NotFoundException({ message: 'Allergy not found', code: ErrorCode.ALLERGY_NOT_FOUND });
    if (allergy.status === 'CURED') {
      await this.prisma.allergy.update({ where: { id: allergyId }, data: { status: 'ACTIVE', curedAt: null } });
    }
    return this.prisma.allergyEvent.create({
      data: {
        allergyId, babyMonId, userId,
        happenedAt: data.happenedAt ? new Date(data.happenedAt) : new Date(),
        notes: data.notes,
      },
    });
  }

  async deleteEvent(babyMonId: string, eventId: string) {
    const event = await this.prisma.allergyEvent.findFirst({ where: { id: eventId, babyMonId } });
    if (!event) throw new NotFoundException({ message: 'Allergy event not found', code: ErrorCode.ALLERGY_EVENT_NOT_FOUND });
    return this.prisma.allergyEvent.delete({ where: { id: eventId } });
  }

  async cure(babyMonId: string, allergyId: string) {
    const allergy = await this.prisma.allergy.findFirst({ where: { id: allergyId, babyMonId, deletedAt: null } });
    if (!allergy) throw new NotFoundException({ message: 'Allergy not found', code: ErrorCode.ALLERGY_NOT_FOUND });
    if (allergy.status === 'CURED') throw new BadRequestException({ message: 'Allergy is already marked as cured', code: ErrorCode.ALLERGY_ALREADY_CURED });
    return this.prisma.allergy.update({
      where: { id: allergyId },
      data: { status: 'CURED', curedAt: new Date() },
    });
  }

  async reactivate(babyMonId: string, allergyId: string) {
    const allergy = await this.prisma.allergy.findFirst({ where: { id: allergyId, babyMonId, deletedAt: null } });
    if (!allergy) throw new NotFoundException({ message: 'Allergy not found', code: ErrorCode.ALLERGY_NOT_FOUND });
    if (allergy.status === 'ACTIVE') throw new BadRequestException({ message: 'Allergy is already active', code: ErrorCode.ALLERGY_ALREADY_ACTIVE });
    return this.prisma.allergy.update({
      where: { id: allergyId },
      data: { status: 'ACTIVE', curedAt: null },
    });
  }

  async remove(babyMonId: string, allergyId: string) {
    const allergy = await this.prisma.allergy.findFirst({ where: { id: allergyId, babyMonId, deletedAt: null } });
    if (!allergy) throw new NotFoundException({ message: 'Allergy not found', code: ErrorCode.ALLERGY_NOT_FOUND });
    // Hard-delete all events first, then the allergy
    await this.prisma.allergyEvent.deleteMany({ where: { allergyId } });
    return this.prisma.allergy.delete({ where: { id: allergyId } });
  }

  async clearAll(babyMonId: string) {
    const allergies = await this.prisma.allergy.findMany({ where: { babyMonId, deletedAt: null } });
    const allergyIds = allergies.map(a => a.id);
    if (allergyIds.length > 0) {
      await this.prisma.allergyEvent.deleteMany({ where: { allergyId: { in: allergyIds } } });
      await this.prisma.allergy.deleteMany({ where: { id: { in: allergyIds } } });
    }
    return { deleted: allergies.length };
  }

  async clearAllEvents(babyMonId: string) {
    const result = await this.prisma.allergyEvent.deleteMany({ where: { babyMonId } });
    return { deleted: result.count };
  }
}
