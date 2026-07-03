import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as Sentry from '@sentry/nestjs';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { Logger } from 'nestjs-pino';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { AuditInterceptor } from './common/interceptors/audit.interceptor';
import { LocaleInterceptor } from './common/interceptors/locale.interceptor';
import { AuditService } from './common/audit.service';
import { IdempotencyMiddleware } from './common/middleware/idempotency.middleware';
import { ErrorCode } from './common/enums/error-code.enum';
import { mapValidationErrors } from './common/utils/validation-error.mapper';
import helmet from 'helmet';
import compression from 'compression';
import * as express from 'express';

async function bootstrap() {
  // Sentry error tracking (disabled if SENTRY_DSN not set)
  if (process.env.SENTRY_DSN) {
    Sentry.init({
      dsn: process.env.SENTRY_DSN,
      environment: process.env.NODE_ENV || 'development',
      tracesSampleRate: 0.1,
    });
  }

  const app = await NestFactory.create(AppModule, {
    rawBody: true,
  });

  const configService = app.get(ConfigService);

  // Security headers
  app.use(helmet());

  // Response compression
  app.use(compression());

  // Rate limit headers (Retry-After) on 429 responses
  app.use((req: any, res: any, next: () => void) => {
    const originalSend = res.json;
    res.json = function (body: any) {
      if (res.statusCode === 429) {
        res.setHeader('Retry-After', '60');
      }
      return originalSend.call(this, body);
    };
    next();
  });

  // Idempotency key support for mutation endpoints
  app.use(new IdempotencyMiddleware().use.bind(new IdempotencyMiddleware()));

  // Global exception filter (maps Prisma errors to proper HTTP codes)
  app.useGlobalFilters(new GlobalExceptionFilter());

  // Global audit interceptor (logs every request with method, URL, userId, duration)
  app.useGlobalInterceptors(new AuditInterceptor(app.get(AuditService)));

  // Global locale interceptor (resolves effective locale per request)
  app.useGlobalInterceptors(new LocaleInterceptor());

  // Use pino logger
  app.useLogger(app.get(Logger));

  // Enable CORS
  app.enableCors({
    origin: configService.get<string[]>('corsOrigins') || ['http://localhost:5173'],
    credentials: true,
  });

  // IMPORTANT: Stripe webhook needs raw body for signature verification
  app.use('/api/subscriptions/webhook', express.raw({ type: 'application/json' }), (req: any, res: any, next: () => void) => {
    if (Buffer.isBuffer(req.body)) {
      req.rawBody = req.body.toString('utf8');
    }
    next();
  });

  // API versioning
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });

  // Global prefix
  app.setGlobalPrefix('api');

  // Validation pipe — maps class-validator errors to field-level codes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
      exceptionFactory: (errors) =>
        new BadRequestException({
          code: ErrorCode.VALIDATION_ERROR,
          message: 'Validation failed',
          details: mapValidationErrors(errors),
        }),
    }),
  );

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('BabyMon API')
    .setDescription('Smart Evolving Parenting Companion API')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('auth', 'Authentication endpoints')
    .addTag('users', 'User management')
    .addTag('baby-mons', 'BabyMon profiles')
    .addTag('milestones', 'Milestone entries')
    .addTag('feed-logs', 'Feeding logs')
    .addTag('health-records', 'Health records')
    .addTag('evolution', 'Evolution and badges')
    .addTag('journal', 'Journey journal')
    .addTag('subscriptions', 'Subscription management')
    .addTag('linked-accounts', 'Co-parent linking')
    .addTag('export', 'Data export')
    .addTag('growth', 'Growth tracking')
    .addTag('media', 'Media uploads')
    .addTag('notifications', 'Push notifications')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get<number>('port') || 3000;
  await app.listen(port);

  const logger = app.get(Logger);

  // Graceful shutdown — handles Docker/K8s SIGTERM for rolling updates
  const signals: NodeJS.Signals[] = ['SIGTERM', 'SIGINT'];
  for (const signal of signals) {
    process.on(signal, async () => {
      logger.log(`Received ${signal}, shutting down gracefully...`);
      await app.close();
      process.exit(0);
    });
  }

  const nodeEnv = configService.get<string>('nodeEnv') || 'development';
  logger.log(`
╔═══════════════════════════════════════════════════════════╗
║                    BabyMon API Server                     ║
╠═══════════════════════════════════════════════════════════╣
║  Environment: ${nodeEnv}                            ║
║  Server:     http://localhost:${port}                          ║
║  Swagger:    http://localhost:${port}/api/docs                 ║
║  Health:     http://localhost:${port}/health                   ║
╚═══════════════════════════════════════════════════════════╝
  `);
}

bootstrap();
