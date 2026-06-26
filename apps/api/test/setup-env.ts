// Override DATABASE_URL to use the test database for integration tests.
// Must run before any module that reads process.env.
process.env['DATABASE_URL'] = 'postgresql://test:test@127.0.0.1:5433/babymon_test?schema=public';
process.env['JWT_SECRET'] = 'test-jwt-secret-for-integration-tests';
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
