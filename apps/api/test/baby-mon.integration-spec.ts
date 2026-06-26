import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('BabyMon Edit Integration', () => {
  let app: INestApplication;
  let ownerToken: string;
  let strangerToken: string;
  let babyMonId: string;

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

    // Create owner user
    const ownerEmail = `owner-${Date.now()}@test.com`;
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email: ownerEmail, password: 'Test123456' });

    const ownerLogin = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: ownerEmail, password: 'Test123456' });
    ownerToken = ownerLogin.body.accessToken;

    // Create stranger user
    const strangerEmail = `stranger-${Date.now()}@test.com`;
    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email: strangerEmail, password: 'Test123456' });

    const strangerLogin = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: strangerEmail, password: 'Test123456' });
    strangerToken = strangerLogin.body.accessToken;

    // Create BabyMon owned by owner
    const babyRes = await request(app.getHttpServer())
      .post('/api/v1/baby-mons')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        name: 'Original Name',
        middleName: 'Original Middle',
        stageStartType: 'BORN',
        birthDate: '2026-06-01T00:00:00Z',
        gender: 'MONIOUS',
        bloodGroup: 'A+',
        eyeColor: 'Brown',
      });
    babyMonId = babyRes.body.id;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('Owner edits BabyMon', () => {
    it('should update BabyMon fields and return 200', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({
          name: 'Updated Name',
          middleName: 'Updated Middle',
          eyeColor: 'Blue',
        });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Updated Name');
      expect(res.body.middleName).toBe('Updated Middle');
      expect(res.body.eyeColor).toBe('Blue');
    });

    it('should persist changes on subsequent GET', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/v1/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${ownerToken}`);

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Updated Name');
      expect(res.body.middleName).toBe('Updated Middle');
    });

    it('should update traits', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ traits: ['Curious', 'Playful'] });

      expect(res.status).toBe(200);
      expect(res.body.traits).toContain('Curious');
      expect(res.body.traits).toContain('Playful');
    });
  });

  describe('Non-owner cannot edit', () => {
    it('should return 403 when stranger tries to update', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${strangerToken}`)
        .send({ name: 'Hacked Name' });

      expect(res.status).toBe(403);
    });
  });

  describe('Validation', () => {
    it('should return 400 for invalid gender', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/v1/baby-mons/${babyMonId}`)
        .set('Authorization', `Bearer ${ownerToken}`)
        .send({ gender: 'INVALID' });

      expect(res.status).toBe(400);
    });
  });
});
