# BabyMon - Smart Evolving Parenting Companion

A mobile application that acts as a smart evolving parenting companion, tracking baby development from conception through early childhood (up to 24 months).

## Features

- **BabyMon Profiles**: Create and manage multiple baby profiles
- **Stage Tracking**: Track pregnancy (week-by-week) or post-birth development
- **Milestones**: Log and track baby milestones with photos
- **Feeding Logs**: Track breastmilk, formula, and solid food feedings
- **Health Records**: Store vaccination and pediatric visit records
- **Evolution System**: XP, badges, and stage progression gamification
- **Journey Journal**: Unified feed of all entries with co-parent approval workflow
- **Subscription Tiers**: Core (tracking) and AI Companion (stage guidance)
- **14-Day Trial**: Test all features before subscribing

## Tech Stack

- **Backend**: Node.js with NestJS framework
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with refresh token rotation
- **Storage**: AWS S3 for media files
- **Payments**: Stripe for subscriptions
- **API**: REST API with OpenAPI/Swagger documentation

## Quick Start (Development)

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL (or use Docker)

### Setup

1. **Clone the repository**

2. **Start PostgreSQL with Docker:**
```bash
docker compose up -d
```

3. **Install dependencies:**
```bash
cd apps/api
npm install
```

4. **Generate Prisma client:**
```bash
npx prisma generate
```

5. **Run migrations:**
```bash
npx prisma migrate dev --name init
```

6. **Seed the database:**
```bash
npm run prisma:seed
```

7. **Start the development server:**
```bash
npm run start:dev
```

The API will be available at `http://localhost:3000`
- Swagger docs: `http://localhost:3000/api/docs`
- Health check: `http://localhost:3000/health`

## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL="postgresql://babymon:babymon_dev_password@localhost:5432/babymon?schema=public"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Stripe (Test Mode)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# AWS S3
AWS_ACCESS_KEY_ID="your-access-key"
AWS_SECRET_ACCESS_KEY="your-secret-key"
AWS_REGION="us-east-1"
S3_BUCKET_NAME="babymon-media"

# App
PORT=3000
NODE_ENV="development"
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh tokens
- `GET /auth/profile` - Get user profile
- `POST /auth/logout` - Logout

### Users
- `GET /users/me` - Get current user
- `PATCH /users/me` - Update current user
- `DELETE /users/me` - Delete account

### BabyMon
- `GET /baby-mons` - List all BabyMons
- `POST /baby-mons` - Create BabyMon
- `GET /baby-mons/:id` - Get BabyMon
- `PATCH /baby-mons/:id` - Update BabyMon
- `DELETE /baby-mons/:id` - Delete BabyMon
- `GET /baby-mons/:id/evolution` - Get evolution data
- `GET /baby-mons/:id/badges` - Get badges
- `GET /baby-mons/:id/stage-content` - Get stage content

### Milestones
- `GET /baby-mons/:id/milestones` - List milestones
- `POST /baby-mons/:id/milestones` - Create milestone
- `GET /baby-mons/:id/milestones/:milestoneId` - Get milestone
- `PATCH /baby-mons/:id/milestones/:milestoneId` - Update milestone
- `DELETE /baby-mons/:id/milestones/:milestoneId` - Delete milestone

### Feeding Logs
- `GET /baby-mons/:id/feed-logs` - List feeding logs
- `POST /baby-mons/:id/feed-logs` - Create feeding log

### Health Records
- `GET /baby-mons/:id/health-records` - List health records
- `POST /baby-mons/:id/health-records` - Create health record

### Journal
- `GET /baby-mons/:id/journal` - Get journey journal
- `GET /baby-mons/:id/journal/proposals` - Get pending proposals
- `POST /baby-mons/:id/journal/proposals/:id/respond` - Respond to proposal

### Linked Accounts
- `GET /linked-accounts` - List linked accounts
- `POST /linked-accounts` - Invite co-parent
- `DELETE /linked-accounts/:id` - Remove co-parent

### Subscriptions
- `GET /subscriptions/current` - Get subscription status
- `POST /subscriptions/verify` - Verify subscription
- `POST /subscriptions/dev-override-trial` - Dev: Override trial

### Export
- `GET /baby-mons/:id/export` - Export BabyMon data

## Testing

### Run tests:
```bash
npm run test
```

### Run tests with coverage:
```bash
npm run test:cov
```

### Run e2e tests:
```bash
npm run test:e2e
```

## Subscription Tiers

| Feature | Core | AI Companion |
|---------|------|--------------|
| BabyMon profiles | ✓ | ✓ |
| Milestones | ✓ | ✓ |
| Feeding logs | ✓ | ✓ |
| Health records | ✓ | ✓ |
| XP & badges | ✓ | ✓ |
| Stage content | ✓ | ✓ |
| Weekly guidance | ✗ | ✓ |
| Evolution narrative | ✗ | ✓ |

## Security

- JWT authentication with short-lived access tokens
- Refresh token rotation
- Rate limiting on all endpoints
- Input validation on all DTOs
- SQL injection prevention via Prisma
- XSS prevention
- CORS configuration
- HTTPS enforced in production

## Compliance

- GDPR ready
- CCPA ready
- No third-party tracking
- No advertising
- Data stored securely with encryption at rest
- Audit logging for all data access

## License

MIT License - See LICENSE file for details

## Support

For issues and questions, contact: support@babymon.app
