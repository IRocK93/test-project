import { ConfigService } from '@nestjs/config';
import { randomBytes } from 'crypto';

/**
 * Centralized JWT configuration — single source of truth for JWT secret.
 *
 * Used by: auth.module.ts (JwtModule.registerAsync), jwt.strategy.ts, auth.service.ts
 *
 * In production, JWT_SECRET is always required (app refuses to start without it
 * thanks to Joi validation in env.validation.ts).
 * In development/test, a random secret is generated per startup and logged
 * prominently so developers are aware. No hardcoded fallback ever.
 */

export function getJwtSecret(config: ConfigService): string {
  const secret = config.get<string>('jwt.secret');

  if (secret) {
    return secret;
  }

  const nodeEnv = config.get<string>('nodeEnv');
  if (nodeEnv === 'production') {
    throw new Error(
      'FATAL: JWT_SECRET environment variable is required in production',
    );
  }

  // Dev/test: generate a random secret per startup. Tokens from
  // previous runs will be invalid — acceptable for development.
  const randomSecret = randomBytes(64).toString('hex');
  if (nodeEnv !== 'test') {
    console.warn(
      '⚠ JWT_SECRET not set — generated random secret for this session.\n' +
      '  Set JWT_SECRET in your .env for persistent tokens across restarts.',
    );
  }
  return randomSecret;
}
