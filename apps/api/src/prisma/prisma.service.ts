import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

/**
 * PrismaService — database connection lifecycle.
 * Connection pool size is wired from DATABASE_POOL_SIZE env var (default: 5).
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(configService: ConfigService) {
    const dbUrl = (configService.get('database.url') as string) || '';
    const poolSize = (configService.get('database.poolSize') as number) ?? 5;

    // Append connection_limit if not already present in the URL
    const url = dbUrl.includes('connection_limit')
      ? dbUrl
      : `${dbUrl}${dbUrl.includes('?') ? '&' : '?'}connection_limit=${poolSize}`;

    super({ datasources: { db: { url } } });
    this.logger.log(`PrismaClient initialized (pool: ${poolSize})`);
  }

  async onModuleInit() {
    await this.$connect();
    this.logger.log('Database connected');
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
