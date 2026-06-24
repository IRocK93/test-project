/**
 * Joi validation schema for environment variables.
 *
 * Runs at application startup via ConfigModule.forRoot({ validationSchema }).
 * If any required variable (marked .required()) is missing or invalid, the app
 * refuses to start with a clear error message instead of failing mysteriously
 * at runtime.
 *
 * Variables marked .optional() that are missing just log a warning via their
 * respective service constructors — they don't prevent startup.
 */

import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  // ── Core ──────────────────────────────────────────────────────
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),

  PORT: Joi.number().default(3000),

  LOG_LEVEL: Joi.string()
    .valid('trace', 'debug', 'info', 'warn', 'error', 'fatal')
    .default('info'),

  CORS_ORIGINS: Joi.string().default('http://localhost:5173'),

  // ── Rate Limiting ─────────────────────────────────────────────
  RATE_LIMIT_TTL: Joi.number().default(60000),
  RATE_LIMIT_MAX: Joi.number().default(100),

  // ── JWT ──────────────────────────────────────────────────────
  // Required in production, optional in dev/test
  JWT_SECRET: Joi.string().when('NODE_ENV', {
    is: 'production',
    then: Joi.string().min(32).required().messages({
      'any.required': 'JWT_SECRET is required in production (min 32 chars)',
      'string.min': 'JWT_SECRET must be at least 32 characters in production',
    }),
    otherwise: Joi.string().optional().allow(''),
  }),

  // ── Trial ────────────────────────────────────────────────────
  TRIAL_DAYS: Joi.number().min(0).max(365).default(14),

  // ── URLs ─────────────────────────────────────────────────────
  APP_URL: Joi.string().uri().default('http://localhost:3000'),
  FRONTEND_URL: Joi.string().uri().default('http://localhost:5173'),

  // ── SendGrid ─────────────────────────────────────────────────
  SENDGRID_API_KEY: Joi.string().optional().allow(''),
  SENDGRID_FROM_EMAIL: Joi.string().email().default('noreply@babymon.app'),

  // ── Stripe ───────────────────────────────────────────────────
  STRIPE_SECRET_KEY: Joi.string().optional().allow(''),
  STRIPE_WEBHOOK_SECRET: Joi.string().optional().allow(''),
  STRIPE_PRICE_PREMIUM_MONTHLY: Joi.string().optional().allow(''),
  STRIPE_PRICE_PREMIUM_YEARLY: Joi.string().optional().allow(''),

  // ── AWS S3 ───────────────────────────────────────────────────
  AWS_ACCESS_KEY_ID: Joi.string().optional().allow(''),
  AWS_SECRET_ACCESS_KEY: Joi.string().optional().allow(''),
  AWS_REGION: Joi.string().default('us-east-1'),
  S3_BUCKET_NAME: Joi.string().default('babymon-media'),

  // ── Firebase ─────────────────────────────────────────────────
  FIREBASE_CONFIG: Joi.string().optional().allow(''),

  // ── AI Companion ─────────────────────────────────────────────
  COMPANION_MODEL_URL: Joi.string().default(
    '/api/models/companion-llm/download',
  ),
  COMPANION_MODEL_SHA256: Joi.string().optional().allow('', null),

  // ── Database ─────────────────────────────────────────────────
  // DATABASE_URL is validated by Prisma itself; we just pass it through.
  DATABASE_URL: Joi.string().optional(),
});
