import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';

/**
 * REGRESSION TEST FOR THE 2026-07-04 INCIDENT
 * ============================================
 *
 * On 2026-07-04, GET /api/v1/baby-mons returned 500 with P2022:
 *   "The column BabyMon.gestationalAgeAtBirth does not exist"
 *
 * Root cause: migration 0004 (align_schema_with_migrations) was incomplete.
 * It added some BabyMon-related changes (Gender/StageStartType enums, the
 * gender/stageStartType column conversion, several indexes) but missed 6
 * new columns that a recent commit to `schema.prisma` had added to the
 * BabyMon model:
 *   - gestationalAgeAtBirth (Int?)
 *   - dueDate               (DateTime?)
 *   - traitsUpdatedAt       (DateTime?)
 *   - siblingGroupId        (String?)
 *   - isGraduated           (Boolean, NOT NULL DEFAULT false)
 *   - graduatedAt           (DateTime?)
 * Plus the missing index BabyMon_siblingGroupId_idx.
 *
 * The runtime symptom was identical to the earlier § 2 incident (0004
 * failed to apply), but the audit trail differed: 0004 had succeeded, the
 * columns were simply never created. The findMany in `BabyMonService.findAll`
 * (apps/api/src/baby-mon/baby-mon.service.ts:findAll) selects all columns,
 * so a missing column there caused a P2022 every time the endpoint was
 * called.
 *
 * Fixed by migration 0005_align_babymon_fields (commit f1d785f).
 *
 * This test creates a user, hits GET /api/v1/baby-mons (the exact query
 * path that was 500ing), and asserts:
 *   1. Empty-list case returns 200 with the expected shape
 *   2. Non-empty case (after creating a BabyMon) returns 200 and includes
 *      ALL 6 columns added in 0005
 *
 * If any of those columns are missing from the test DB, Prisma throws
 * P2022 during the findMany and this test fails. See
 * docs/16-PRISMA-BASELINING-INCIDENT.md § 7 and docs/15 § 0005 for the
 * full postmortems.
 *
 * IMPORTANT: This test only catches the regression if the test DB is
 * hydrated via `prisma migrate deploy` (not `prisma db push`). The CI
 * workflow (.github/workflows/ci.yml) already runs migrate deploy + status
 * + diff before tests, so a missing migration would be caught at the
 * migration layer too. This test is the application-level confirmation.
 */
describe('BabyMon Schema Drift Regression (2026-07-04 incident)', () => {
  let app: INestApplication;
  let accessToken: string;

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

    // Each test run uses a unique email so we don't collide with other
    // integration specs sharing the same test DB
    const userEmail = `drift-${Date.now()}-${Math.random().toString(36).slice(2, 8)}@test.com`;

    await request(app.getHttpServer())
      .post('/api/v1/auth/register')
      .send({ email: userEmail, password: 'Test123456' })
      .expect(201);

    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: userEmail, password: 'Test123456' })
      .expect(200);

    accessToken = login.body.accessToken;
  }, 30000);

  afterAll(async () => {
    await app.close();
  });

  describe('GET /api/v1/baby-mons (the failing query path in the 2026-07-04 incident)', () => {
    it('should return 200 with empty list for a new user with no BabyMons', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body).toMatchObject({ items: [], total: 0 });
      expect(res.body).toHaveProperty('skip');
      expect(res.body).toHaveProperty('take');
      expect(Array.isArray(res.body.items)).toBe(true);
    });

    it('should return 200 with one BabyMon after create, including all 0005 fields', async () => {
      // Create a BabyMon first — this also exercises the POST path,
      // which would fail if `gender` (the enum) were missing
      const create = await request(app.getHttpServer())
        .post('/api/v1/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          name: 'Drift Test Baby',
          stageStartType: 'BORN',
          birthDate: '2026-07-01T00:00:00Z',
          gender: 'MONIOUS',
        })
        .expect(201);

      expect(create.body).toHaveProperty('id');

      // The actual failing query in the 2026-07-04 incident.
      // If any of the 6 columns 0005 added are missing from the test DB,
      // Prisma throws P2022 and the request returns 500 (or 400 from the
      // global exception filter), not 200.
      const res = await request(app.getHttpServer())
        .get('/api/v1/baby-mons')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.total).toBe(1);
      expect(res.body.items).toHaveLength(1);
      expect(res.body.items[0].name).toBe('Drift Test Baby');

      // The 6 columns added in 0005 — toHaveProperty is the right shape
      // because if the column is missing from the DB, Prisma throws
      // P2022 BEFORE serializing the response (we never get here).
      // The properties existing in the JSON response means:
      //   1. The column exists in the DB
      //   2. Prisma's generated client can read it
      //   3. The DTO/serializer passes it through
      expect(res.body.items[0]).toHaveProperty('gestationalAgeAtBirth');
      expect(res.body.items[0]).toHaveProperty('dueDate');
      expect(res.body.items[0]).toHaveProperty('traitsUpdatedAt');
      expect(res.body.items[0]).toHaveProperty('siblingGroupId');
      expect(res.body.items[0]).toHaveProperty('isGraduated');
      expect(res.body.items[0]).toHaveProperty('graduatedAt');

      // isGraduated is the only NOT NULL column added in 0005; it has
      // DEFAULT false so the row we just created should be false
      expect(res.body.items[0].isGraduated).toBe(false);
    });
  });
});
