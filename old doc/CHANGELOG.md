# Changelog

All notable changes to the BabyMon API will be documented in this file.

---

## [Unreleased]

### Added

- **Database Indexes**: Added indexes on frequently queried fields for performance optimization
  - BabyMon: ownerUserId, deletedAt
  - Milestone, FeedLog, HealthRecord: babymonId, authorUserId, happenedAt, deletedAt
  - LinkedAccount: userAId, userBId, status
  - LinkedBabyMon: userId, babymonId
  - StageContent: stageKey

- **Pagination**: Added pagination to all list endpoints
  - Endpoints: BabyMon, Milestones, FeedLogs, HealthRecords
  - Query params: `?skip=0&take=20`
  - Response format: `{ items: [], total: number, skip: number, take: number }`

- **JWT Secret Validation**: Added fail-fast validation for JWT_SECRET in production

- **Stage Content Fallback**: Added logic to fall back to default stage content when BabyMon-specific content not found

- **PaginationDto**: Created common DTO for pagination parameters

### Changed

- **Array Fields**: Changed from JSON.stringify to native PostgreSQL arrays
  - BabyMon.traits
  - Milestone.localMediaRefs
  - FeedLog.localMediaRefs
  - HealthRecord.localMediaRefs

- **HTTP Exceptions**: Replaced generic `throw new Error()` with proper NestJS exceptions
  - ForbiddenException for access denied
  - NotFoundException for not found
  - BadRequestException for bad requests

- **Module Dependencies**: Added missing module imports
  - BadgesModule imported in MilestonesModule
  - BadgesModule imported in FeedLogsModule
  - BabyMonModule imported in EvolutionModule

- **LinkedBabyMon Deletion**: Fixed to only delete entries for BabyMons in the specific link being removed

- **Stripe Webhook**: Added raw body middleware for proper Stripe signature verification

### Fixed

- **Prisma Field Names**: Fixed babymonId vs babyMonId casing inconsistencies
- **Access Control**: Fixed NPE in verifyAccess methods by checking babyMon existence first

---

## [1.0.0] - 2026-02-20

### Added

- Initial release with complete backend implementation:
  - User authentication (JWT + refresh tokens)
  - BabyMon management (pregnancy, born, idea stages)
  - Entry tracking (milestones, feed logs, health records)
  - Gamification (XP, badges)
  - Co-parent linking with proposal workflow
  - Trial/subscription management (Stripe)
  - Data export (HTML)
  - OpenAPI/Swagger documentation
  - Rate limiting
  - Docker & Docker Compose setup

### Database

- PostgreSQL with Prisma ORM
- Soft deletes for BabyMon, entries
- Audit logging
- Cascade deletes

---

## Migration Notes

### v1.0.0 → Unreleased

If upgrading from initial release:

1. **Run migrations** to add indexes:
   ```bash
   npx prisma migrate dev
   ```

2. **Seed stage content** (if needed):
   ```bash
   npm run prisma:seed
   ```

3. **Set JWT_SECRET** in environment (required for production):
   ```bash
   JWT_SECRET="your-secure-secret-key"
   ```
