import { Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger, Inject, forwardRef } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Request } from 'express';
import { AuditService } from '../audit.service';
import { AuditEvent } from '../audit-event.enum';

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AuditInterceptor.name);

  constructor(private auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<Request>();
    const { method, url, ip, headers } = request;
    const user = request.user as { id?: string };
    const userId = user?.id;
    const startTime = Date.now();

    const event = this.determineEvent(method, request.path);

    return next.handle().pipe(
      tap({
        next: async (responseBody) => {
          const duration = Date.now() - startTime;

          // Log to console (existing behavior)
          this.logger.log(
            `[AUDIT] ${method} ${url} - ${userId || 'anonymous'} - ${duration}ms`,
          );

          // Write to AuditLog table (new behavior)
          if (userId && event) {
            const babyMonId = this.extractBabyMonId(request);
            const resourceId = this.extractResourceId(request, responseBody);

            await this.auditService.log({
              event,
              userId,
              babyMonId,
              resourceType: this.determineResourceType(request.path),
              resourceId,
              ipAddress: ip,
              userAgent: headers['user-agent'] as string,
            });
          }
        },
        error: (error) => {
          const duration = Date.now() - startTime;
          this.logger.error(
            `[AUDIT] ${method} ${url} - ${userId || 'anonymous'} - ${duration}ms - ERROR: ${error.message}`,
          );
        },
      }),
    );
  }

  private determineEvent(method: string, path: string): AuditEvent | null {
    const normalizedPath = path.toLowerCase();

    // Auth events
    if (normalizedPath.includes('/auth/register')) return AuditEvent.USER_REGISTERED;
    if (normalizedPath.includes('/auth/login')) return AuditEvent.USER_LOGIN;
    if (normalizedPath.includes('/auth/logout')) return AuditEvent.USER_LOGOUT;

    // BabyMon CRUD
    if (method === 'POST' && normalizedPath.match(/\/babymons$/)) return AuditEvent.BABYMON_CREATED;
    if (method === 'PATCH' && normalizedPath.match(/\/babymons\/[^/]+$/)) return AuditEvent.BABYMON_UPDATED;
    if (method === 'DELETE' && normalizedPath.match(/\/babymons\/[^/]+$/)) return AuditEvent.BABYMON_DELETED;

    // Milestone
    if (method === 'POST' && normalizedPath.includes('/milestones')) return AuditEvent.MILESTONE_CREATED;
    if (method === 'PATCH' && normalizedPath.includes('/milestones')) return AuditEvent.MILESTONE_UPDATED;

    // FeedLog
    if (method === 'POST' && normalizedPath.includes('/feed-logs')) return AuditEvent.FEED_LOG_CREATED;
    if (method === 'PATCH' && normalizedPath.includes('/feed-logs')) return AuditEvent.FEED_LOG_UPDATED;
    if (method === 'DELETE' && normalizedPath.includes('/feed-logs')) return AuditEvent.FEED_LOG_DELETED;

    // HealthRecord
    if (method === 'POST' && normalizedPath.includes('/health-records')) return AuditEvent.HEALTH_RECORD_CREATED;
    if (method === 'PATCH' && normalizedPath.includes('/health-records')) return AuditEvent.HEALTH_RECORD_UPDATED;
    if (method === 'DELETE' && normalizedPath.includes('/health-records')) return AuditEvent.HEALTH_RECORD_DELETED;

    // Subscription
    if (method === 'POST' && normalizedPath.includes('/subscriptions')) return AuditEvent.SUBSCRIPTION_CREATED;
    if (method === 'DELETE' && normalizedPath.includes('/subscriptions')) return AuditEvent.SUBSCRIPTION_CANCELLED;

    // Linked accounts
    if (method === 'POST' && normalizedPath.includes('/linked-accounts') && normalizedPath.includes('/accept')) {
      return AuditEvent.ACCESS_GRANTED;
    }
    if (method === 'DELETE' && normalizedPath.includes('/linked-accounts')) {
      return AuditEvent.ACCESS_REVOKED;
    }

    return null;
  }

  private extractBabyMonId(request: Request): string | undefined {
    // Try route params first
    const babymonId = request.params.babyMonId || request.params.id;
    if (babymonId) return babymonId;

    // Try query params
    if (request.query.babyMonId) return request.query.babyMonId as string;

    // Try body
    if (request.body?.babyMonId) return request.body.babyMonId;

    return undefined;
  }

  private extractResourceId(request: Request, responseBody: any): string | undefined {
    // From route params
    if (request.params.resourceId) return request.params.resourceId;
    if (request.params.id) return request.params.id;

    // From response body (created resource)
    if (responseBody && typeof responseBody === 'object' && responseBody.id) {
      return responseBody.id;
    }

    return undefined;
  }

  private determineResourceType(path: string): string | undefined {
    if (path.includes('/babymons')) return 'BabyMon';
    if (path.includes('/milestones')) return 'Milestone';
    if (path.includes('/feed-logs')) return 'FeedLog';
    if (path.includes('/health-records')) return 'HealthRecord';
    if (path.includes('/subscriptions')) return 'Subscription';
    if (path.includes('/linked-accounts')) return 'LinkedAccount';
    return undefined;
  }
}