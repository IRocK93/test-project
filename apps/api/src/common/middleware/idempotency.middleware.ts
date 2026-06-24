import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

/**
 * Idempotency middleware — prevents duplicate mutations.
 * Checks for Idempotency-Key header on POST/PATCH/PUT/DELETE requests.
 * Keys are cached in-memory for 24 hours (production: use Redis).
 */
@Injectable()
export class IdempotencyMiddleware implements NestMiddleware {
  private readonly logger = new Logger(IdempotencyMiddleware.name);
  private readonly cache = new Map<string, { status: number; body: any; timestamp: number }>();
  private readonly TTL = 24 * 60 * 60 * 1000; // 24 hours

  use(req: Request, res: Response, next: NextFunction) {
    // Only apply to mutating methods
    if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(req.method)) {
      return next();
    }

    const key = req.headers['idempotency-key'] as string;
    if (!key) {
      // Optional: key is not required, just pass through
      return next();
    }

    // Clean expired entries
    const now = Date.now();
    for (const [k, v] of this.cache) {
      if (now - v.timestamp > this.TTL) this.cache.delete(k);
    }

    // Check for duplicate
    const cached = this.cache.get(key);
    if (cached) {
      this.logger.log(`Duplicate request blocked: ${key}`);
      res.status(cached.status).json(cached.body);
      return;
    }

    // Capture response for caching
    const originalSend = res.json.bind(res);
    res.json = (body: any) => {
      this.cache.set(key, { status: res.statusCode, body, timestamp: Date.now() });
      return originalSend(body);
    };

    next();
  }
}
