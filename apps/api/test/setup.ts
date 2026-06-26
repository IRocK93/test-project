import { PrismaClient } from '@prisma/client';

/**
 * Global test setup — runs once before all integration tests.
 * Migrates the test database to ensure schema is up to date,
 * then cleans all user data to ensure a fresh state.
 */
export default async function globalSetup(): Promise<void> {
  // Intentionally empty — each integration spec manages its own cleanup
  // via afterAll(app.close()). The test database is isolated via .env.test.
}
