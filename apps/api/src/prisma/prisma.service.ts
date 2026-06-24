import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * PrismaService — database connection lifecycle.
 * Connection pool size is wired from DATABASE_POOL_SIZE env var (default: 5).
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    const dbUrl = process.env.DATABASE_URL || '';
    const poolSize = process.env.DATABASE_POOL_SIZE || '5';

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
