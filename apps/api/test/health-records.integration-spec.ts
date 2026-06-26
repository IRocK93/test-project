import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Health Records Integration', () => {
  let app: INestApplication;
  let token: string;
  let babyMonId: string;
  let healthRecordId: string;

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
    const email = `health-test-${Date.now()}@test.com`;
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
        name: 'Health Baby',
        stageStartType: 'BORN',
        birthDate: '2026-06-01T00:00:00Z',
        gender: 'MONIOUS',
      });
    babyMonId = babyRes.body.id;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('Health record with value/unit (measurement)', () => {
    it('should create a health record with value and unit', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/v1/baby-mons/${babyMonId}/health-records`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          category: 'WEIGHT',
          title: 'Morning weigh-in',
          value: '7.5',
          unit: 'kg',
          happenedAt: '2026-06-20T10:00:00Z',
        });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.category).toBe('WEIGHT');
      expect(res.body.value).toBe('7.5');
      expect(res.body.unit).toBe('kg');
      healthRecordId = res.body.id;
    });

    it('should soft-delete and return 200', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/health-records/${healthRecordId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
    });

    it('should return 200 on idempotent delete', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/health-records/${healthRecordId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/already deleted/i);
    });
  });

  describe('Health record — event type (no value/unit)', () => {
    it('should create a vaccination record', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/v1/baby-mons/${babyMonId}/health-records`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          category: 'VACCINATION',
          title: 'MMR Vaccine',
          notes: 'First dose',
          happenedAt: '2026-06-15T10:00:00Z',
        });

      expect(res.status).toBe(201);
      expect(res.body.category).toBe('VACCINATION');
    });
  });
});
