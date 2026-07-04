import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Milestones Integration', () => {
  let app: INestApplication;
  let token: string;
  let babyMonId: string;
  let milestoneId: string;

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
    const email = `milestone-test-${Date.now()}@test.com`;
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email, password: 'Test123456' })
      .expect(201);

    const loginRes = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: 'Test123456' });
    token = loginRes.body.accessToken;

    // Create BabyMon
    const babyRes = await request(app.getHttpServer())
      .post('/api/v1/baby-mons')
      .set('Authorization', `Bearer ${token}`)
      .send({
        name: 'Test Baby',
        stageStartType: 'BORN',
        birthDate: '2026-06-01T00:00:00Z',
        gender: 'MONIESE',
      });
    babyMonId = babyRes.body.id;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('Full milestone lifecycle', () => {
    it('should create a milestone and return 201', async () => {
      // Use a recent happenedAt so the FREE-tier 7-day date filter
      // (buildHistoryDateFilter in apps/api/src/common/history-filter.helper.ts)
      // doesn't exclude the milestone from the list endpoint tests below.
      const recentHappenedAt = new Date().toISOString();
      const res = await request(app.getHttpServer())
        .post(`/api/v1/baby-mons/${babyMonId}/milestones`)
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'First smile', notes: 'Happened at playtime', happenedAt: recentHappenedAt });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.title).toBe('First smile');
      expect(res.body.notes).toBe('Happened at playtime');
      expect(res.body.babymonId).toBe(babyMonId);
      milestoneId = res.body.id;
    });

    it('should return the milestone in the list', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/v1/baby-mons/${babyMonId}/milestones`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const ids = (res.body.items || res.body).map((m: any) => m.id);
      expect(ids).toContain(milestoneId);
    });

    it('should soft-delete the milestone and return 200', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/milestones/${milestoneId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/deleted/i);
    });

    it('should NOT return deleted milestone in the list', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/v1/baby-mons/${babyMonId}/milestones`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      const items = res.body.items || res.body;
      const deleted = items.find((m: any) => m.id === milestoneId);
      expect(deleted).toBeUndefined();
    });

    it('should return 200 on idempotent delete (already soft-deleted)', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/api/v1/milestones/${milestoneId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toMatch(/already deleted/i);
    });

    it('should return 404 for non-existent milestone', async () => {
      const res = await request(app.getHttpServer())
        .delete('/api/v1/milestones/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(404);
    });
  });
});
