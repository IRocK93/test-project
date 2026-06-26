/**
 * Centralized application configuration — single source of truth for ALL
 * environment variables. Every service that previously referenced process.env
 * directly now uses ConfigService instead.
 *
 * Joi validation runs at startup (see env.validation.ts) — invalid or missing
 * required variables cause the app to refuse to start with a clear message.
 */

export interface AppConfig {
  nodeEnv: string;
  port: number;
  logLevel: string;
  corsOrigins: string[];

  rateLimit: {
    ttl: number;
    max: number;
  };

  jwt: {
    secret: string;
    fallbackDevSecret: string;
  };

  trialDays: number;

  sendgrid: {
    apiKey: string | undefined;
    fromEmail: string;
  };

  appUrl: string;
  frontendUrl: string;

  stripe: {
    secretKey: string | undefined;
    webhookSecret: string | undefined;
    pricePremiumMonthly: string | undefined;
    pricePremiumYearly: string | undefined;
  };

  aws: {
    accessKeyId: string | undefined;
    secretAccessKey: string | undefined;
    region: string;
    s3BucketName: string;
  };

  firebase: {
    configJson: string | undefined;
  };

  companion: {
    modelUrl: string;
    modelSha256: string | null;
    hfToken: string | null;
  };

  database: {
    poolSize: number;
  };
}

export default function configuration(): AppConfig {
  return {
    nodeEnv: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '3000', 10),
    logLevel: process.env.LOG_LEVEL || 'info',
    corsOrigins: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:5173'],

    rateLimit: {
      ttl: parseInt(process.env.RATE_LIMIT_TTL || '60000', 10),
      max: parseInt(process.env.RATE_LIMIT_MAX || '100', 10),
    },

    jwt: {
      secret: process.env.JWT_SECRET || '',
      fallbackDevSecret: process.env.JWT_DEV_SECRET || 'dev-secret-change-me',
    },

    trialDays: parseInt(process.env.TRIAL_DAYS || '14', 10),

    sendgrid: {
      apiKey: process.env.SENDGRID_API_KEY,
      fromEmail: process.env.SENDGRID_FROM_EMAIL || 'noreply@babymon.app',
    },

    appUrl: process.env.APP_URL || 'http://localhost:3000',
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:5173',

    stripe: {
      secretKey: process.env.STRIPE_SECRET_KEY,
      webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
      pricePremiumMonthly: process.env.STRIPE_PRICE_PREMIUM_MONTHLY,
      pricePremiumYearly: process.env.STRIPE_PRICE_PREMIUM_YEARLY,
    },

    aws: {
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION || 'us-east-1',
      s3BucketName: process.env.S3_BUCKET_NAME || 'babymon-media',
    },

    firebase: {
      configJson: process.env.FIREBASE_CONFIG,
    },

  companion: {
    modelUrl:
      process.env.COMPANION_MODEL_URL ||
      '/api/models/companion-llm/download',
    modelSha256: process.env.COMPANION_MODEL_SHA256 || null,
    hfToken: process.env.HF_TOKEN || null,
  },

  database: {
    poolSize: parseInt(process.env.DATABASE_POOL_SIZE || '5', 10),
  },
};
}
