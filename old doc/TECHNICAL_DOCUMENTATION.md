# BabyMon API - Technical Documentation

> Last Updated: 2026-02-20
> Author: Claude (AI Developer)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [API Endpoints](#api-endpoints)
5. [Security](#security)
6. [Features Implemented](#features-implemented)
7. [Setup & Running](#setup--running)
8. [Testing](#testing)
9. [Known Issues](#known-issues)
10. [Future Improvements](#future-improvements)

---

## Project Overview

**BabyMon** is a Smart Evolving Parenting Companion - a mobile application that tracks baby development from conception through early childhood (up to 24 months).

### Tech Stack

| Component | Technology |
|-----------|------------|
| Backend | NestJS (Node.js) |
| Database | PostgreSQL |
| ORM | Prisma |
| Authentication | JWT with refresh tokens |
| Payments | Stripe |
| Storage | AWS S3 (optional) |
| Email | SendGrid |
| Push Notifications | Firebase FCM |
| Logging | Pino (nestjs-pino) |
| API Docs | OpenAPI/Swagger |

---

## Architecture

### Module Structure

```
apps/api/src/
├── app.module.ts              # Root module
├── main.ts                    # Bootstrap with CORS, validation, Swagger, Pino
├── auth/                      # Authentication (JWT, register, login, password reset)
├── users/                     # User management
├── baby-mon/                  # BabyMon CRUD
├── milestones/               # Milestone entries
├── feed-logs/                 # Feeding logs
├── health-records/            # Health records
├── badges/                    # Gamification (XP, badges)
├── evolution/                 # Evolution system
├── stage-content/             # Stage-based content
├── journal/                   # Journey journal with proposals
├── subscriptions/             # Trial/subscription management
├── linked-accounts/           # Co-parent linking
├── stripe/                    # Stripe integration
├── s3/                        # AWS S3 service
├── health/                    # Health check endpoints
├── media/                     # Media upload and storage
├── growth/                    # Growth tracking (height, weight)
├── notifications/             # Push notifications (FCM)
├── mail/                      # Email service (SendGrid)
├── admin/                     # Admin endpoints
├── prisma/                    # Database service
└── common/                    # Guards, decorators, DTOs
```

### Key Features Implemented

- JWT authentication with refresh token rotation
- Email verification with verification tokens
- Password reset with time-limited tokens
- 14-day trial with automatic paywall
- XP and badge gamification system
- Co-parent linking with proposal workflow (7-day auto-accept)
- 10-minute undo window for entries
- Pagination on all list endpoints
- Database indexes for performance
- Tiered rate limiting (5/min auth, 10/min sensitive, 100/min default)
- Health endpoints with database verification
- Media upload with S3 integration
- Growth tracking with WHO percentile calculations
- Badge icon definitions with URLs
- Push notification service with Firebase FCM
- Structured request logging with Pino
- Admin endpoints with role-based access control

---

## Database Schema

### Key Models

| Model | Description |
|-------|-------------|
| User | Registered users with roles (USER, ADMIN) |
| BabyMon | Child profiles (supports pregnancy, born, idea stages) |
| Milestone | Developmental milestones |
| FeedLog | Feeding records (breast, formula, solids) |
| HealthRecord | Health records (vaccinations, visits) |
| Badge | Awarded badges |
| StageContent | Stage-specific content (pregnancy weeks, post-birth) |
| LinkedAccount | Co-parent relationships |
| LinkedBabyMon | Shared BabyMon access |
| Subscription | Trial/subscription status |
| EntryChangeProposal | Co-parent edit proposals |
| AuditLog | Activity tracking |
| Media | Uploaded media files |
| GrowthRecord | Height, weight, head circumference records |
| Device | Registered push notification devices |
| PasswordResetToken | Password reset tokens |

### User Model Fields

```prisma
model User {
  id            String    @id @default(uuid())
  email         String    @unique
  passwordHash  String?
  name          String?
  role          String    @default("USER") // USER, ADMIN
  isActive      Boolean   @default(true)
  verificationToken String?
  verificationExpires DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  verifiedAt    DateTime?
  deletedAt     DateTime?
}
```

### Device Model

```prisma
model Device {
  id           String   @id @default(uuid())
  userId       String
  deviceToken  String   @unique
  platform     String   // ios, android, web
  createdAt    DateTime @default(now())
  lastActiveAt DateTime @default(now())

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

---

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|-------|----------|-------------|
| POST | `/api/auth/register` | Register new user (sends verification email) |
| POST | `/api/auth/login` | Login |
| POST | `/api/auth/refresh` | Refresh tokens |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password` | Reset password with token |
| GET | `/api/auth/verify-email` | Verify email with token |
| GET | `/api/auth/profile` | Get user profile |
| POST | `/api/auth/logout` | Logout |

### Users

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/api/users/me` | Get current user |
| PATCH | `/api/users/me` | Update current user |
| DELETE | `/api/users/me` | Delete account |

### BabyMon

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/api/baby-mons` | List BabyMons (paginated) |
| POST | `/api/baby-mons` | Create BabyMon |
| GET | `/api/baby-mons/:id` | Get BabyMon |
| PATCH | `/api/baby-mons/:id` | Update BabyMon |
| DELETE | `/api/baby-mons/:id` | Delete BabyMon |
| GET | `/api/baby-mons/:id/stage` | Get current stage |

### Entries (Milestones, FeedLogs, HealthRecords)

All support pagination with `?skip=0&take=20`

| Type | Methods |
|------|---------|
| Milestones | `/api/baby-mons/:babyMonId/milestones` |
| Feed Logs | `/api/baby-mons/:babyMonId/feed-logs` |
| Health Records | `/api/baby-mons/:babyMonId/health-records` |

### Media Upload

| Method | Endpoint | Description |
|-------|----------|-------------|
| POST | `/api/baby-mons/:babyMonId/media` | Upload media file |
| GET | `/api/baby-mons/:babyMonId/media` | List media files |
| DELETE | `/api/media/:id` | Delete media file |

### Growth Tracking

| Method | Endpoint | Description |
|-------|----------|-------------|
| POST | `/api/baby-mons/:babyMonId/growth` | Add growth record |
| GET | `/api/baby-mons/:babyMonId/growth` | Get growth records |
| GET | `/api/baby-mons/:babyMonId/growth/analysis` | Get WHO percentile analysis |
| DELETE | `/api/baby-mons/:babyMonId/growth/:id` | Delete growth record |

### Badges

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/api/baby-mons/:babyMonId/badges` | Get all badges |
| GET | `/api/baby-mons/:babyMonId/badges/definitions` | Get badge definitions with icon URLs |

### Push Notifications

| Method | Endpoint | Description |
|-------|----------|-------------|
| POST | `/api/notifications/register-device` | Register device token |
| POST | `/api/notifications/unregister-device` | Unregister device |
| POST | `/api/notifications/test` | Send test notification |

### Admin Endpoints (ADMIN only)

| Method | Endpoint | Description |
|-------|----------|-------------|
| GET | `/api/admin/users` | List all users |
| GET | `/api/admin/users/:id` | Get user details |
| PATCH | `/api/admin/users/:id/status` | Update user active status |
| PATCH | `/api/admin/users/:id/role` | Update user role |
| GET | `/api/admin/audit-logs` | Get audit logs |
| GET | `/api/admin/stats` | Get system statistics |

### Other Endpoints

| Feature | Endpoint |
|---------|----------|
| Evolution | `/api/baby-mons/:babyMonId/evolution` |
| Stage Content | `/api/stage-content/baby-mon/:babyMonId` |
| Journal | `/api/baby-mons/:babyMonId/journal` |
| Linked Accounts | `/api/linked-accounts/*` |
| Subscriptions | `/api/subscriptions/*` |
| Export | `/api/baby-mons/:babyMonId/export` |

---

## Security

### JWT Authentication

- Short-lived access tokens (15 minutes)
- Refresh token rotation (7 days)
- JWT_SECRET must be set in production

### Role-Based Access Control

- USER: Standard user access
- ADMIN: Access to admin endpoints

### Rate Limiting

Three tiers implemented:

| Tier | Limit | Use Case |
|------|-------|----------|
| AUTH | 5/min | Login, register |
| SENSITIVE | 10/min | Password reset |
| DEFAULT | 100/min | General API |

### Health Endpoints

| Endpoint | Purpose |
|----------|---------|
| GET `/api/health` | Full health check with DB status |
| GET `/api/health/live` | Liveness probe |
| GET `/api/health/ready` | Readiness probe |

---

## Features Implemented

### 1. Email Verification

- Registration generates verification token (24h expiry)
- Email sent with verification link
- Token validated on verification endpoint

### 2. Password Reset

- Forgot password generates reset token (1h expiry)
- Email sent with reset link
- All refresh tokens revoked on password change

### 3. Request Logging (Pino)

- Structured JSON logging
- Request/response logging
- Automatic timestamp and correlation IDs

### 4. Admin Endpoints

- User management (list, update status, update role)
- Audit log viewing
- System statistics

### 5. Push Notifications (Firebase FCM)

- Device registration with platform support
- Event-triggered notifications:
  - Milestone added
  - Badge unlocked
  - Growth recorded
  - Proposal received

### 6. Growth Tracking

- WHO growth standards (0-24 months)
- Percentile calculations (P3, P15, P50, P85, P97)
- Trend analysis

---

## Setup & Running

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL

### Environment Variables

```bash
# Database
DATABASE_URL="postgresql://babymon:babymon_dev_password@localhost:5432/babymon?schema=public"

# JWT
JWT_SECRET="your-secret-key"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Stripe
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# AWS S3
AWS_REGION="us-east-1"
AWS_ACCESS_KEY_ID="..."
AWS_SECRET_ACCESS_KEY="..."
S3_BUCKET_NAME="babymon-media"

# SendGrid
SENDGRID_API_KEY="SG...."
SENDGRID_FROM_EMAIL="noreply@babymon.app"

# Firebase (optional)
FIREBASE_CONFIG='{"type":"service_account",...}'

# App
PORT=3000
NODE_ENV="development"
APP_URL="http://localhost:3000"
```

### Commands

```bash
# Install dependencies
npm install

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate dev

# Start development
npm run start:dev

# Run tests
npm test
```

---

## Testing

### Test Suites (4 total, 12 tests)

| Suite | Description |
|-------|-------------|
| auth.service.spec.ts | Authentication tests |
| users.service.spec.ts | User management tests |
| baby-mon.service.spec.ts | BabyMon CRUD tests |
| health.controller.spec.ts | Health endpoint tests |

---

## Known Issues

- Seed data must be run manually if needed
- Firebase FCM requires configuration for push notifications to work

---

## Future Improvements

All high and medium priority items have been implemented. Future enhancements could include:

- API versioning (`/api/v1/`)
- Redis caching
- PDF export
- GraphQL API

---

## Contributing

When making changes:

1. Follow the existing module structure
2. Use proper HTTP exceptions
3. Add database indexes for frequently queried fields
4. Implement pagination for list endpoints
5. Update Swagger decorators
6. Add validation in DTOs
7. Test thoroughly before committing
