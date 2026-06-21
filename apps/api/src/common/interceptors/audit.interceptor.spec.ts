import { Test, TestingModule } from '@nestjs/testing';
import { ExecutionContext, CallHandler } from '@nestjs/common';
import { of } from 'rxjs';
import { lastValueFrom } from 'rxjs';
import { AuditInterceptor } from './audit.interceptor';
import { AuditService } from '../audit.service';
import { AuditEvent } from '../audit-event.enum';

describe('AuditInterceptor', () => {
  let interceptor: AuditInterceptor;
  let auditService: { log: jest.Mock };

  const mockAuditService = {
    log: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuditInterceptor,
        { provide: AuditService, useValue: mockAuditService },
      ],
    }).compile();

    interceptor = module.get<AuditInterceptor>(AuditInterceptor);
    auditService = mockAuditService;
    jest.clearAllMocks();
  });

  function createMockContext(method: string, path: string, userId?: string) {
    const request = {
      method,
      path,
      url: path,
      ip: '127.0.0.1',
      headers: { 'user-agent': 'test-agent' },
      user: userId ? { id: userId } : undefined,
      params: {},
      query: {},
      body: {},
    };

    const response = { statusCode: 200 };

    const context = {
      switchToHttp: () => ({
        getRequest: () => request,
        getResponse: () => response,
      }),
    } as ExecutionContext;

    const next: CallHandler = {
      handle: () => of({ id: 'resource-1' }),
    };

    return { context, next, request };
  }

  it('should be defined', () => {
    expect(interceptor).toBeDefined();
  });

  it('should log MILESTONE_CREATED for POST to milestones', async () => {
    const { context, next } = createMockContext(
      'POST',
      '/api/v1/baby-mons/bm-1/milestones',
      'user-1',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    expect(auditService.log).toHaveBeenCalledWith(
      expect.objectContaining({
        event: AuditEvent.MILESTONE_CREATED,
        userId: 'user-1',
        ipAddress: '127.0.0.1',
        userAgent: 'test-agent',
      }),
    );
  });

  it('should log FEED_LOG_CREATED for POST to feed-logs', async () => {
    const { context, next } = createMockContext(
      'POST',
      '/api/v1/baby-mons/bm-1/feed-logs',
      'user-1',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    expect(auditService.log).toHaveBeenCalledWith(
      expect.objectContaining({ event: AuditEvent.FEED_LOG_CREATED }),
    );
  });

  it('should log FEED_LOG_DELETED for DELETE to feed-logs', async () => {
    const { context, next } = createMockContext(
      'DELETE',
      '/api/v1/baby-mons/bm-1/feed-logs/fl-1',
      'user-1',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    expect(auditService.log).toHaveBeenCalledWith(
      expect.objectContaining({ event: AuditEvent.FEED_LOG_DELETED }),
    );
  });

  it('should log USER_LOGIN for POST to /auth/login', async () => {
    const { context, next } = createMockContext(
      'POST',
      '/api/v1/auth/login',
      'user-1',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    expect(auditService.log).toHaveBeenCalledWith(
      expect.objectContaining({ event: AuditEvent.USER_LOGIN }),
    );
  });

  it('should not log events for GET requests to unregistered paths', async () => {
    const { context, next } = createMockContext(
      'GET',
      '/api/v1/health',
      'user-1',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    // determineEvent returns null for GET to /health — no audit log written
    // The interceptor only calls auditService.log when event is non-null AND userId exists
    expect(auditService.log).not.toHaveBeenCalled();
  });

  it('should not log for anonymous (no user) requests', async () => {
    const { context, next } = createMockContext(
      'POST',
      '/api/v1/baby-mons/bm-1/milestones',
    );

    await lastValueFrom(interceptor.intercept(context, next));

    expect(auditService.log).not.toHaveBeenCalled();
  });
});
