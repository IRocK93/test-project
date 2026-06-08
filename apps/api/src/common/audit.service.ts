import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditEvent } from './audit-event.enum';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private prisma: PrismaService) {}

  async log(params: {
    event: AuditEvent;
    userId: string;
    babyMonId?: string;
    resourceType?: string;
    resourceId?: string;
    metadata?: Record<string, any>;
    ipAddress?: string;
    userAgent?: string;
  }): Promise<void> {
    try {
      const payload = {
        resourceType: params.resourceType,
        resourceId: params.resourceId,
        ...params.metadata,
      };

      await this.prisma.auditLog.create({
        data: {
          eventType: params.event,
          actorUserId: params.userId,
          babymonId: params.babyMonId,
          payloadJson: JSON.stringify(payload),
          ipAddress: params.ipAddress,
          userAgent: params.userAgent,
        },
      });
    } catch (error) {
      // Non-blocking — log error but don't crash the request
      this.logger.error(`Failed to write audit log: ${error.message}`);
    }
  }
}