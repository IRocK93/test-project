import { Controller, Get } from '@nestjs/common';
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
}
