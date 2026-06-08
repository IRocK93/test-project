# BabyMon - Smart Evolving Parenting Companion

A mobile application that acts as a smart evolving parenting companion, tracking baby development from conception through early childhood (up to 24 months).

## Features

- **BabyMon Profiles**: Create and manage multiple baby profiles
- **Stage Tracking**: Track pregnancy (week-by-week) or post-birth development
- **Milestones**: Log and track baby milestones with photos (local storage)
- **Feeding Logs**: Track breastmilk, formula, and solid food feedings
- **Health Records**: Store vaccination and pediatric visit records
- **Evolution System**: XP, badges, and stage progression gamification
- **Journey Journal**: Unified feed of all entries with co-parent approval workflow
- **Subscription Tiers**: Core (tracking) and AI Companion (stage guidance)
- **14-Day Trial**: Test all features before subscribing
- **Paywall**: View-only mode after trial expiry
- **Export**: HTML/PDF-style export of BabyMon data

## Tech Stack

- **Backend**: Node.js with NestJS framework
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with refresh token rotation
- **Storage**: AWS S3 for media files (optional)
- **Payments**: Stripe for subscriptions
- **API**: REST API with OpenAPI/Swagger documentation

## Getting Started

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL (or use Docker)

### Quick Start

1. **Start PostgreSQL with Docker:**
```bash
docker compose up -d
```

2. **Install dependencies:**
```bash
cd apps/api
npm install
```

3. **Copy environment variables:**
```bash
cp .env.example .env
```

4. **Generate Prisma client:**
```bash
npx prisma generate
```

5. **Run migrations:**
```bash
npx prisma migrate dev --name init
```

6. **Seed the database (optional):**
```bash
npm run prisma:seed
```

7. **Start the development server:**
```bash
npm run start:dev
```

The API will be available at:
- Server: `http://localhost:3000`
- Swagger docs: `http://localhost:3000/api/docs`
- Health check: `http://localhost:3000/health`

## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL="postgresql://babymon:babymon_dev_password@localhost:5432/babymon?schema=public"

# JWT (generate with: openssl rand -hex 64)
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Stripe (test mode)
STRIPE_SECRET_KEY="sk_test_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# AWS S3 (optional)
AWS_REGION="us-east-1"
AWS_ACCESS_KEY_ID="your-access-key"
AWS_SECRET_ACCESS_KEY="your-secret-key"
S3_BUCKET_NAME="babymon-media"

# App
PORT=3000
NODE_ENV="development"
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/refresh` - Refresh tokens
- `GET /api/auth/profile` - Get user profile
- `POST /api/auth/logout` - Logout

### Users
- `GET /api/users/me` - Get current user
- `PATCH /api/users/me` - Update current user
- `DELETE /api/users/me` - Delete account

### BabyMon
- `GET /api/baby-mons` - List all BabyMons
- `POST /api/baby-mons` - Create BabyMon
- `GET /api/baby-mons/:id` - Get BabyMon
- `PATCH /api/baby-mons/:id` - Update BabyMon
- `DELETE /api/baby-mons/:id` - Delete BabyMon
- `GET /api/baby-mons/:id/evolution` - Get evolution data
- `GET /api/baby-mons/:id/badges` - Get badges
- `GET /api/baby-mons/:id/stage-content` - Get stage content

### Milestones
- `GET /api/baby-mons/:id/milestones` - List milestones
- `POST /api/baby-mons/:id/milestones` - Create milestone
- `GET /api/baby-mons/:id/milestones/:milestoneId` - Get milestone
- `PATCH /api/baby-mons/:id/milestones/:milestoneId` - Update milestone
- `DELETE /api/baby-mons/:id/milestones/:milestoneId` - Delete milestone

### Feeding Logs
- `GET /api/baby-mons/:id/feed-logs` - List feeding logs
- `POST /api/baby-mons/:id/feed-logs` - Create feeding log

### Health Records
- `GET /api/baby-mons/:id/health-records` - List health records
- `POST /api/baby-mons/:id/health-records` - Create health record

### Journal
- `GET /api/baby-mons/:id/journal` - Get journey journal
- `GET /api/baby-mons/:id/journal/proposals` - Get pending proposals
- `POST /api/baby-mons/:id/journal/proposals/:id/respond` - Respond to proposal

### Linked Accounts
- `GET /api/linked-accounts` - List linked accounts
- `POST /api/linked-accounts/invite` - Invite co-parent
- `DELETE /api/linked-accounts/:id` - Remove co-parent

### Subscriptions
- `GET /api/subscriptions/current` - Get subscription status
- `POST /api/subscriptions/create-checkout-session` - Create Stripe checkout
- `POST /api/subscriptions/create-portal-session` - Manage subscription
- `POST /api/subscriptions/dev-override-trial` - Dev: Override trial

### Export
- `GET /api/baby-mons/:id/export` - Export BabyMon data

## Testing

### Run tests:
```bash
npm run test
```

### Run tests with coverage:
```bash
npm run test:cov
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

## Testing the Paywall

The app includes a dev endpoint to test the trial/paywall functionality:

```bash
# Override trial to expired
curl -X POST http://localhost:3000/api/subscriptions/dev-override-trial \
  -H "Content-Type: application/json" \
  -d '{"userId": "user-uuid", "days": -1}'

# Extend trial by 30 days
curl -X POST http://localhost:3000/api/subscriptions/dev-override-trial \
  -H "Content-Type: application/json" \
  -d '{"userId": "user-uuid", "days": 30}'
```

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

## Project Structure

```
babymon/
├── apps/
│   ├── api/                 # NestJS backend
│   │   ├── src/
│   │   │   ├── auth/       # Authentication
│   │   │   ├── users/      # User management
│   │   │   ├── baby-mon/   # BabyMon CRUD
│   │   │   ├── milestones/ # Milestones
│   │   │   ├── feed-logs/ # Feeding logs
│   │   │   ├── health-records/
│   │   │   ├── badges/     # Badges & gamification
│   │   │   ├── evolution/
│   │   │   ├── stage-content/
│   │   │   ├── journal/
│   │   │   ├── export/
│   │   │   ├── subscriptions/
│   │   │   ├── linked-accounts/
│   │   │   ├── stripe/
│   │   │   ├── s3/
│   │   │   └── common/     # Shared guards, decorators
│   │   └── prisma/        # Database schema & seeds
│   │
│   └── mobile/            # Flutter app
│
├── docker-compose.yml
└── README.md
```

## License

MIT License - See LICENSE file for details

## Support

For issues and questions, contact: support@babymon.app
