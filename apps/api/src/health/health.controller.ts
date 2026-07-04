import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private prisma: PrismaService) {}

  @Get()
  @ApiOperation({ summary: 'Health check - verifies API and database status' })
  async check() {
    let dbStatus: 'connected' | 'disconnected' = 'disconnected';
    let dbLatency: number | null = null;

    try {
      const start = Date.now();
      await this.prisma.$queryRaw`SELECT 1`;
      dbLatency = Date.now() - start;
      dbStatus = 'connected';
    } catch (error) {
      dbStatus = 'disconnected';
    }

    const status = dbStatus === 'connected' ? 'ok' : 'degraded';

    return {
      status,
      timestamp: new Date().toISOString(),
      services: {
        api: 'ok',
        database: dbStatus,
        ...(dbLatency && { dbLatency: `${dbLatency}ms` }),
      },
    };
  }

  @Get('live')
  @ApiOperation({ summary: 'Liveness probe - simple ok response' })
  live() {
    return { status: 'ok' };
  }

  @Get('ready')
  @ApiOperation({ summary: 'Readiness probe - checks if app can serve traffic' })
  async ready() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return { ready: true };
    } catch {
      return { ready: false };
    }
  }

  /**
   * Deep health probe — verifies that critical schema columns actually exist
   * in the live database, not just that the DB is reachable. Returns 503 if
   * any expected column is missing.
   *
   * This is the safety net for the 2026-07-04 incident where
   * `User.consentDataAt` was silently dropped from prod by a local
   * `prisma db push`. The basic `/ready` endpoint above would have stayed
   * green throughout — it only checks DB connectivity, not schema shape.
   *
   * Wire this to your uptime monitor (Pingdom, UptimeRobot, BetterStack, etc.)
   * so a schema-drift regression fails the deploy within minutes, not hours.
   *
   * See docs/16-PRISMA-BASELINING-INCIDENT.md for the full postmortem.
   */
  @Get('deep')
  @ApiOperation({
    summary: 'Deep health probe - verifies critical schema columns exist',
  })
  async deep(): Promise<{
    status: 'ok';
    schema: 'verified';
    checks: { userConsentDataAt: 'present' };
  }> {
    const result = await this.prisma.$queryRaw<Array<{ column_name: string }>>`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_schema = current_schema()
        AND table_name = 'User'
        AND column_name = 'consentDataAt'
    `;

    if (!result || result.length === 0) {
      throw new ServiceUnavailableException(
        'Critical schema drift: User.consentDataAt column is missing. ' +
          'See docs/16-PRISMA-BASELINING-INCIDENT.md.',
      );
    }

    return {
      status: 'ok',
      schema: 'verified',
      checks: { userConsentDataAt: 'present' },
    };
  }
}
