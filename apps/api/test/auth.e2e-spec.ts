import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Auth E2E Tests', () => {
  let app: INestApplication;
  const testEmail = `e2e-test-${Date.now()}@babymon.app`;
  const testPassword = 'TestPass123';
  let accessToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({
          email: testEmail,
          password: testPassword,
          name: 'E2E Test User',
          tosAccepted: true,
          privacyAccepted: true,
          consentToDataProcessing: true,
        })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      expect(res.body.user.email).toBe(testEmail);
      accessToken = res.body.accessToken;
    });

    it('should reject duplicate email', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({ email: testEmail, password: testPassword })
        .expect(409);
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login with valid credentials', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: testEmail, password: testPassword })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
      expect(res.body).toHaveProperty('refreshToken');
      accessToken = res.body.accessToken;
    });

    it('should reject invalid password', async () => {
      await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: testEmail, password: 'WrongPass123' })
        .expect(401);
    });
  });

  describe('GET /api/auth/profile', () => {
    it('should return profile with valid token', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.email).toBe(testEmail);
      expect(res.body).not.toHaveProperty('passwordHash');
      expect(res.body).not.toHaveProperty('phone');
    });

    it('should reject request without token', async () => {
      await request(app.getHttpServer())
        .get('/api/auth/profile')
        .expect(401);
    });
  });

  describe('POST /api/auth/refresh', () => {
    it('should refresh access token', async () => {
      const loginRes = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: testEmail, password: testPassword });

      const res = await request(app.getHttpServer())
        .post('/api/auth/refresh')
        .send({ refreshToken: loginRes.body.refreshToken })
        .expect(200);

      expect(res.body).toHaveProperty('accessToken');
    });
  });
});
