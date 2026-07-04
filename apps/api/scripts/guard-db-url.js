#!/usr/bin/env node
/**
 * guard-db-url.js
 *
 * Pre-flight guard that blocks Prisma commands from running against a non-local
 * database. This prevents the 2026-07-04 incident where a local `prisma db push`
 * silently dropped the User.consentDataAt column from prod because the local
 * `.env` pointed at the production Neon DB.
 *
 * Usage: automatically prepended to all Prisma npm scripts in package.json:
 *   "prisma:migrate":      "node scripts/guard-db-url.js && prisma migrate dev"
 *   "prisma:migrate:prod": "node scripts/guard-db-url.js && prisma migrate deploy"
 *   "prisma:push":         "node scripts/guard-db-url.js && prisma db push"
 *
 * Bypass (emergencies only): set ALLOW_PROD_DB_MUTATION=true in your shell.
 *
 * Exits 0 if the DATABASE_URL host is on the allow-list; exits 1 otherwise.
 */

'use strict';

const url = process.env.DATABASE_URL;

if (!url) {
  console.error('❌ guard-db-url: DATABASE_URL is not set.');
  console.error('   Copy apps/api/.env.example to apps/api/.env and fill in the values.');
  process.exit(1);
}

if (process.env.ALLOW_PROD_DB_MUTATION === 'true') {
  console.warn('⚠️  guard-db-url: ALLOW_PROD_DB_MUTATION=true — bypassing database guard.');
  console.warn('   This is a destructive operation. Make sure you know what you\'re doing.');
  process.exit(0);
}

let parsed;
try {
  parsed = new URL(url);
} catch (e) {
  console.error(`❌ guard-db-url: Invalid DATABASE_URL format: ${e.message}`);
  process.exit(1);
}

// Allowed hosts:
//   - localhost / 127.0.0.1 / ::1   → local dev
//   - postgres                       → Docker / CI container hostname
//   - host.docker.internal           → Docker Desktop (host loopback)
//
// NOTE: This is defense-in-depth, not a security boundary. `new URL()` correctly
// extracts the hostname for well-formed URLs, but a few malformed inputs can
// slip past the allow-list (e.g. `postgresql://localhost#@evil.com` parses as
// hostname=localhost because the `@evil.com` is a fragment, not an authority).
// The realistic threat model is a developer accidentally running
// `prisma db push` against prod from a local machine — this guard stops that.
const ALLOWED_HOSTS = new Set([
  'localhost',
  '127.0.0.1',
  '::1',
  'postgres',
  'host.docker.internal',
]);

if (!ALLOWED_HOSTS.has(parsed.hostname)) {
  console.error(`❌ guard-db-url: DENIED — refusing to run Prisma command against non-local database.`);
  console.error(`   DATABASE_URL host: ${parsed.hostname}`);
  console.error(`   Allowed hosts:     ${[...ALLOWED_HOSTS].join(', ')}`);
  console.error('');
  console.error('   If you need to run migrations against a remote database:');
  console.error('   1. Use the Railway CLI:  railway run npx prisma migrate deploy');
  console.error('   2. Or set ALLOW_PROD_DB_MUTATION=true to bypass this guard (DANGEROUS).');
  console.error('');
  console.error('   See docs/16-PRISMA-BASELINING-INCIDENT.md for context.');
  process.exit(1);
}

console.log(`✅ guard-db-url: DATABASE_URL host "${parsed.hostname}" is on the allow-list.`);
