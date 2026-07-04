// Override DATABASE_URL to use the test database for integration tests.
// Must run before any module that reads process.env.
//
// Local dev: docker-compose brings up `postgres-test` on port 5433 with
//   user=test / password=test / db=babymon_test. The default below matches
//   that. Override by setting TEST_DATABASE_URL before running tests if
//   you have a different local setup.
//
// CI (.github/workflows/ci.yml): the github-actions `postgres` service runs
//   on port 5432 with user=postgres / password=postgres / db=babymon_test.
//   The CI workflow sets DATABASE_URL directly, so the default below is
//   only a fallback for the rare case where it's not set.
if (!process.env['DATABASE_URL']) {
  process.env['DATABASE_URL'] =
    process.env['TEST_DATABASE_URL'] ||
    'postgresql://test:test@127.0.0.1:5433/babymon_test?schema=public';
}
process.env['JWT_SECRET'] = process.env['JWT_SECRET'] || 'test-jwt-secret-for-integration-tests';
process.env['JWT_EXPIRES_IN'] = '15m';
process.env['JWT_REFRESH_EXPIRES_IN'] = '7d';
process.env['NODE_ENV'] = 'test';
process.env['TRIAL_DAYS'] = '14';
process.env['SKIP_TIER_GUARD'] = 'true';
process.env['SENDGRID_API_KEY'] = '';
process.env['STRIPE_SECRET_KEY'] = '';
process.env['AWS_ACCESS_KEY_ID'] = '';
process.env['AWS_SECRET_ACCESS_KEY'] = '';
process.env['AWS_REGION'] = '';
process.env['AWS_S3_BUCKET'] = '';
