# BabyMon – Smart Evolving Parenting Companion

## 1. Project Overview

**Project Name:** BabyMon
**Project Type:** Mobile Application (iOS/Android) + Backend API
**Core Functionality:** A smart evolving parenting companion that tracks baby development from conception through 24 months, using gamified evolution mechanics (XP, badges, stages), structured educational content, and comprehensive logging (milestones, feeding, health).
**Target Users:** Expecting mothers (primary), co-parents (secondary), global non-technical users

## 2. Technology Stack & Choices

### Frontend
- **Framework:** Flutter 3.x
- **State Management:** Riverpod
- **HTTP Client:** Dio
- **Local Database:** Drift (SQLite)
- **Secure Storage:** flutter_secure_storage
- **Architecture:** Clean Architecture (presentation/domain/data layers)

### Backend
- **Framework:** NestJS (Node.js)
- **ORM:** Prisma
- **Database:** PostgreSQL (via Docker Compose)
- **Authentication:** JWT with refresh token rotation
- **API Style:** REST

### DevOps
- **Containerization:** Docker Compose
- **Package Manager:** npm (backend), flutter pub (mobile)

## 3. Feature List

### Authentication
- Email/password registration and login
- Email verification
- JWT access tokens (15 min expiry)
- Refresh token rotation
- Google OAuth stub (MVP)

### BabyMon Management
- Create BabyMon profile (multiple per user)
- Switch between BabyMons
- Required fields: stage (Idea/Conceived/Born), dates, gender, traits
- Optional fields: middle name, last name, biological parents info, blood group, eye color

### Logging Features
- **Milestones:** Create with title, date/time, notes, photo attachment (local)
- **Feeding:** Log breastmilk/formula/solid with amount, notes, timestamp
- **Health:** Vaccination logs, pediatric visits, notes, document upload (local)

### Evolution & Gamification
- XP system (server-side deterministic)
- Stage progression (week-by-week, then month-by-month)
- Badge system with unlock animations
- Evolution dashboard with progress visualization
- Trait reinforcement through milestones

### Journey Journal
- Unified feed of all entries (milestones, feeding, health, system events)
- Filter by entry type
- Co-parent approval workflow for edits/deletes
- Co-parent linking between two users

### AI Content (Static/Pre-generated)
- Stage-based educational content (summary, nurturing, encouragement)
- Content personalization: name, traits, tone
- Disclaimer: "Educational purposes only. Not medical advice."

### Access Control
- Tier 1 (Core): All tracking, XP, badges, dashboard export
- Tier 2 (AI Companion): Tier 1 + weekly guidance, evolution narratives
- 14-day trial
- Post-trial: paywall makes app view-only

### Offline Support
- Offline log entry creation
- Local reads while offline
- "Pending sync" indicators
- Media remains local-only (MVP)

### Export & Deletion
- PDF/image export (bento box style)
- Delete data functionality
- Delete account functionality
- Soft-delete with tombstone pattern

### Security
- TLS
- JWT authentication
- Rate limiting
- Input validation
- Audit logs
- No third-party tracking

## 4. UI/UX Design Direction

### Visual Style
- Playful/game-like with soft, trustworthy feel
- Rounded corners, gentle animations
- Evolution-themed progression visuals (stages, badges, XP bars)

### Color Scheme
- Primary: Soft purple/lavender (#9C7CF4)
- Secondary: Warm coral/peach (#FF8A65)
- Background: Light cream (#FFF8F0)
- Accent: Mint green (#81D4CA)
- Text: Dark charcoal (#2D2D2D)

### Layout Approach
- Bottom navigation with 5 tabs:
  1. Dashboard (Evolution)
  2. Milestones
  3. Feeding
  4. Health
  5. Journal
- Top app bar with BabyMon switcher
- Floating action buttons for quick entry creation

### Key Screens
1. **Onboarding:** Welcome → Sign Up/Sign In → Create BabyMon flow
2. **Dashboard:** Stage visualization, XP bar, badges, AI content (if tier 2)
3. **Milestones:** List view + create modal
4. **Feeding:** Log entry + history
5. **Health:** Category tabs (vaccination/visits/other)
6. **Journal:** Unified feed with filters
7. **Settings:** Profile, subscription, export, delete options

## 5. Database Schema

### Core Tables
- `users` - User authentication and profile
- `linked_accounts` - Co-parent linking
- `baby_mon` - Child profiles
- `milestones` - Milestone entries
- `feed_logs` - Feeding logs
- `health_records` - Health records
- `badges` - Earned badges
- `stage_content` - Pre-generated AI content
- `audit_logs` - Activity tracking
- `entry_change_proposals` - Edit/delete proposals
- `refresh_tokens` - Token management
- `subscriptions` - Tier/access management

## 6. API Endpoints (MVP)

### Auth
- POST /auth/register
- POST /auth/login
- POST /auth/refresh
- POST /auth/verify-email
- POST /auth/forgot-password

### BabyMon
- GET /baby-mons
- POST /baby-mons
- GET /baby-mons/:id
- PATCH /baby-mons/:id
- DELETE /baby-mons/:id

### Milestones
- GET /baby-mons/:id/milestones
- POST /baby-mons/:id/milestones
- PATCH /milestones/:id
- DELETE /milestones/:id

### Feeding
- GET /baby-mons/:id/feed-logs
- POST /baby-mons/:id/feed-logs
- PATCH /feed-logs/:id
- DELETE /feed-logs/:id

### Health
- GET /baby-mons/:id/health-records
- POST /baby-mons/:id/health-records
- PATCH /health-records/:id
- DELETE /health-records/:id

### Journey
- GET /baby-mons/:id/journal
- POST /baby-mons/:id/journal/proposals

### Badges & Evolution
- GET /baby-mons/:id/badges
- GET /baby-mons/:id/evolution

### Stage Content
- GET /stage-content/:stageKey

### Export
- POST /baby-mons/:id/export

### Subscription
- GET /subscriptions/current
- POST /subscriptions/verify

## 7. Acceptance Criteria

### Authentication
- [ ] User can register with email/password
- [ ] User can login and receive JWT tokens
- [ ] Tokens refresh automatically

### BabyMon
- [ ] User can create a BabyMon with all required fields
- [ ] User can switch between multiple BabyMons
- [ ] Dates calculate correctly based on stage

### Logging
- [ ] User can create milestone entries
- [ ] User can log feeding entries
- [ ] User can create health records

### Evolution
- [ ] XP updates correctly for logged entries
- [ ] Badges unlock at appropriate thresholds
- [ ] Stage progression reflects time passed

### Journal
- [ ] All entries appear in unified feed
- [ ] Filters work correctly
- [ ] Co-parent proposals appear correctly

### Offline
- [ ] Can create entries while offline
- [ ] Entries show "pending sync" status

### Export/Delete
- [ ] Export generates PDF/image
- [ ] Delete data removes all user data
- [ ] Delete account removes user entirely

### Trial/Premium
- [ ] Trial lasts 14 days
- [ ] Post-trial: write operations blocked
- [ ] Settings remain accessible

### Build
- [ ] docker-compose up starts Postgres
- [ ] Backend runs and migrations apply
- [ ] Flutter app builds and runs
- [ ] Tests pass
