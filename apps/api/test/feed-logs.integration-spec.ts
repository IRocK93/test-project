import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Feed Logs Integration', () => {
  let app: INestApplication;
  let token: string;
  let babyMonId: string;
  let feedLogId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    await app.init();

    // Create test user
    const email = `feed-test-${Date.now()}@test.com`;
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email, password: 'Test123456' });

    const loginRes = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'Test123456' });
    token = loginRes.body.accessToken;

    // Create BabyMon
    const babyRes = await request(app.getHttpServer())
      .post('/api/v1/baby-mons')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'Feeding Baby',
        stageStartType: 'BORN',
        birthDate: '2026-06-01T00:00:00Z',
        gender: 'MONIESE',
      });
    babyMonId = babyRes.body.id;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('Feed log lifecycle', () => {
    it('should create a feed log', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/v1/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          type: 'BREASTMILK',
          amount: '120',
          unit: 'ml',
          notes: 'Left side',
          happenedAt: '2026-06-20T10:00:00Z',
        });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.type).toBe('BREASTMILK');
      expect(res.body.amount).toBe('120');
      feedLogId = res.body.id;
    });

    it('should soft-delete and return 200', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/feed-logs/${feedLogId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/deleted/i);
    });

    it('should return 200 on idempotent delete', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/feed-logs/${feedLogId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/already deleted/i);
    });

    it('should create a SOLID feed log (regression: FeedingType enum)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/v1/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          type: 'SOLID',
          amount: '50',
          unit: 'g',
          happenedAt: '2026-06-22T10:00:00Z',
        });

      expect(res.status).toBe(201);
      expect(res.body.type).toBe('SOLID');
    });
  });
});
