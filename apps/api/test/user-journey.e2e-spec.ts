import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

/**
 * Complete user journey e2e tests.
 *
 * Covers critical paths identified as HIGH RISK in the testing audit:
 *   - User registration + login + token refresh
 *   - Create BabyMon (BORN stage)
 *   - Log a feeding → XP awarded → badge check triggered
 *   - Retrieve feed logs and verify data integrity
 *   - Verify badges were evaluated
 *
 * Runs against the full NestJS application with real Prisma/DB.
 */
describe('User Journey E2E', () => {
  let app: INestApplication;
  const testEmail = `journey-${Date.now()}@babymon.app`;
  const testPassword = 'JourneyPass123!';
  let accessToken: string;
  let refreshToken: string;
  let babyMonId: string;
  let feedLogId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }),
    );
    await app.init();
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 1: Register
  // ─────────────────────────────────────────────────────────────
  describe('Step 1 — Registration', () => {
    it('POST /api/auth/register — creates account with all consent fields', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          name: 'Journey Tester',
          tosAccepted: true,
          privacyAccepted: true,
          consentToDataProcessing: true,
        })
        .expect(201);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      expect(res.body.user.email).toBe(testEmail);
      expect(res.body.user.name).toBe('Journey Tester');
      // Sensitive fields must not leak
      expect(res.body.user).not.toHaveProperty('passwordHash');
      expect(res.body.user).not.toHaveProperty('phone');

      accessToken = res.body.accessToken;
      refreshToken = res.body.refreshToken;
    });

    it('POST /api/auth/register — rejects duplicate email (409)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          name: 'Duplicate',
          tosAccepted: true,
          privacyAccepted: true,
          consentToDataProcessing: true,
        })
        .expect(409);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 2: Login + Token Refresh
  // ─────────────────────────────────────────────────────────────
  describe('Step 2 — Login & Token Refresh', () => {
    it('POST /api/auth/login — returns new token pair', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: testEmail, password: testPassword })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      accessToken = res.body.accessToken;
      refreshToken = res.body.refreshToken;
    });

    it('POST /api/auth/login — rejects wrong password (401)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: testEmail, password: 'WrongPass!!!' })
        .expect(401);
    });

    it('POST /api/auth/refresh — issues fresh access token', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      // New token must differ from the old one
      expect(res.body.accessToken).not.toBe(accessToken);
      accessToken = res.body.accessToken;
    });

    it('GET /api/auth/profile — returns user data when authenticated', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.email).toBe(testEmail);
      expect(res.body).not.toHaveProperty('passwordHash');
    });

    it('GET /api/auth/profile — rejects unauthenticated request (401)', async () => {
      await request(app.getHttpServer())
        .get('/api/auth/profile')
        .expect(401);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 3: Create BabyMon
  // ─────────────────────────────────────────────────────────────
  describe('Step 3 — Create BabyMon', () => {
    it('POST /api/baby-mons — creates a new BabyMon (BORN stage)', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          name: 'Journey Baby',
          stageStartType: 'BORN',
          birthDate: '2026-01-15',
          gender: 'MONIESE',
          traits: ['Curious', 'Playful'],
          bloodGroup: 'O+',
          eyeColor: 'Brown',
        })
        .expect(201);

      expect(res.body).toHaveProperty('id');
      expect(res.body.name).toBe('Journey Baby');
      expect(res.body.stageStartType).toBe('BORN');
      expect(res.body.gender).toBe('MONIESE');
      expect(res.body.traits).toEqual(
        expect.arrayContaining(['Curious', 'Playful']),
      );
      expect(res.body.bloodGroup).toBe('O+');
      expect(res.body.eyeColor).toBe('Brown');
      expect(res.body).toHaveProperty('currentXp');
      expect(res.body).toHaveProperty('currentLevel');

      babyMonId = res.body.id;
    });

    it('GET /api/baby-mons — lists user baby-mons', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toHaveProperty('items');
      expect(Array.isArray(res.body.items)).toBe(true);
      expect(res.body.items.length).toBeGreaterThanOrEqual(1);
      const found = res.body.items.find((b: any) => b.id === babyMonId);
      expect(found).toBeDefined();
      expect(found.name).toBe('Journey Baby');
    });

    it('GET /api/baby-mons/:id — returns single BabyMon', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.id).toBe(babyMonId);
      expect(res.body.name).toBe('Journey Baby');
    });

    it('POST /api/baby-mons — rejects unauthenticated request (401)', async () => {
      await request(app.getHttpServer())
        .post('/api/baby-mons')
        .send({
          name: 'Ghost Baby',
          stageStartType: 'BORN',
          birthDate: '2026-01-15',
          gender: 'MONIESE',
        })
        .expect(401);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 4: Log Feeding → XP + Badges
  // ─────────────────────────────────────────────────────────────
  describe('Step 4 — Log Feeding (XP + Badge triggers)', () => {
    it('POST /api/baby-mons/:id/feed-logs — logs a feeding', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'BREASTMILK',
          amount: '120',
          unit: 'ml',
          notes: 'Good latch, 15 min per side',
          happenedAt: new Date().toISOString(),
        })
        .expect(201);

      expect(res.body).toHaveProperty('id');
      expect(res.body.type).toBe('BREASTMILK');
      expect(res.body.amount).toBe('120');
      expect(res.body.unit).toBe('ml');
      expect(res.body.xpAwarded).toBe(5);
      expect(res.body.babymonId).toBe(babyMonId);

      feedLogId = res.body.id;
    });

    it('POST /api/baby-mons/:id/feed-logs — logs a second feeding (SOLID)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'SOLID',
          amount: '50',
          unit: 'g',
          notes: 'Banana puree, loved it!',
          happenedAt: new Date().toISOString(),
        })
        .expect(201);

      expect(res.body.type).toBe('SOLID');
      expect(res.body).toHaveProperty('id');
    });

    it('GET /api/baby-mons/:id/feed-logs — retrieves feed log list', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toHaveProperty('items');
      expect(Array.isArray(res.body.items)).toBe(true);
      expect(res.body.items.length).toBeGreaterThanOrEqual(2);
      expect(res.body).toHaveProperty('total');
      expect(res.body.total).toBeGreaterThanOrEqual(2);
    });

    it('GET /api/feed-logs/:id — retrieves single feed log', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/feed-logs/${feedLogId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.id).toBe(feedLogId);
      expect(res.body.type).toBe('BREASTMILK');
      expect(res.body).toHaveProperty('author');
    });

    it('PATCH /api/feed-logs/:id — updates feed log amount', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/feed-logs/${feedLogId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ amount: '150', notes: 'Updated: better latch today' })
        .expect(200);

      // Update may return the log directly or a proposal depending on undo window
      if (res.body.type) {
        expect(res.body.amount).toBe('150');
      } else {
        // Proposal created (outside undo window)
        expect(res.body).toHaveProperty('proposalType');
      }
    });

    it('DELETE /api/feed-logs/:id — soft-deletes (using second feed log)', async () => {
      // Get the second feed log ID
      const listRes = await request(app.getHttpServer())
        .get(`/api/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${accessToken}`);

      const secondId = listRes.body.items.find(
        (f: any) => f.id !== feedLogId,
      )?.id;
      expect(secondId).toBeDefined();

      const res = await request(app.getHttpServer())
        .delete(`/api/feed-logs/${secondId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.message).toContain('deleted');
    });

    it('POST /api/baby-mons/:id/feed-logs — rejects invalid feeding type (400)', async () => {
      await request(app.getHttpServer())
        .post(`/api/baby-mons/${babyMonId}/feed-logs`)
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ type: 'INVALID_TYPE', amount: '100', unit: 'ml' })
        .expect(400);
    });

    it('POST /api/baby-mons/:id/feed-logs — rejects unauthenticated (401)', async () => {
      await request(app.getHttpServer())
        .post(`/api/baby-mons/${babyMonId}/feed-logs`)
        .send({ type: 'BREASTMILK' })
        .expect(401);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 5: Verify XP & Badge Side Effects
  // ─────────────────────────────────────────────────────────────
  describe('Step 5 — Verify XP & Badges', () => {
    it('GET /api/baby-mons/:id — BabyMon XP increased after feedings', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      // At least 10 XP from 2 feedings (5 XP each)
      expect(res.body.currentXp).toBeGreaterThanOrEqual(10);
    });

    it('GET /api/baby-mons/:id/badges — badges endpoint returns list', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/baby-mons/${babyMonId}/badges`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      // Badges should be an array (may be empty if no badge was earned yet)
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('GET /api/badges/definitions — returns badge definitions', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/badges/definitions')
        .expect(200);

      // Should return a map of badge definitions
      expect(typeof res.body).toBe('object');
      expect(Object.keys(res.body).length).toBeGreaterThan(0);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // STEP 6: Edge Cases & Error Handling
  // ─────────────────────────────────────────────────────────────
  describe('Step 6 — Edge Cases', () => {
    it('GET /api/baby-mons/:id — returns 404 for non-existent BabyMon', async () => {
      await request(app.getHttpServer())
        .get('/api/baby-mons/non-existent-id-12345')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });

    it('POST /api/baby-mons/:id/feed-logs — returns 404 for non-existent BabyMon', async () => {
      await request(app.getHttpServer())
        .post('/api/baby-mons/non-existent-id-12345/feed-logs')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ type: 'BREASTMILK' })
        .expect(404);
    });

    it('POST /api/auth/register — rejects missing consent fields (400)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'noconsent@test.com',
          password: 'Test12345!',
          name: 'No Consent',
        })
        .expect(400);
    });

    it('POST /api/auth/register — rejects weak password (400)', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: 'weakpw@test.com',
          password: '123',
          name: 'Weak PW',
          tosAccepted: true,
          privacyAccepted: true,
          consentToDataProcessing: true,
        })
        .expect(400);
    });

    it('POST /api/baby-mons — rejects missing required fields (400)', async () => {
      await request(app.getHttpServer())
        .post('/api/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ name: 'Incomplete' })
        .expect(400);
    });
  });
});
