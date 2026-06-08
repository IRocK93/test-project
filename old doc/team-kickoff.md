# BabyMon Team Kickoff

## Project: BabyMon
**Path:** `/mnt/d/Claude Workspace/Projects/00. Test Project/`
**Spec:** `SPEC.md` (read this first)

## Team Roles

### 🧑‍💻 PROGRAMMER
**Mandate:** Implement features. Follow `subagent-driven-development` skill for all implementation.
- Backend: NestJS + Prisma + PostgreSQL
- Mobile: Flutter + Riverpod + Drift + Dio
- Implement tasks in order as dispatched by orchestrator
- Two-stage review: spec compliance → code quality
- Write tests, commit per task

### 🏗️ ARCHITECT
**Mandate:** Technology and structure decisions. Answer questions, review designs.
- Clean Architecture patterns
- API design (REST)
- Data modeling (Prisma schema)
- Flutter architecture (presentation/domain/data layers)
- Offline-first data flow
- Security patterns (JWT, rate limiting, input validation)
- **Review all module designs before implementation begins**

### 🎨 DESIGNER
**Mandate:** UI/UX and visual design.
- Color scheme: Primary #9C7CF4, Secondary #FF8A65, Background #FFF8F0, Accent #81D4CA, Text #2D2D2D
- 5-tab navigation: Dashboard, Milestones, Feeding, Health, Journal
- Evolution-themed gamification visuals (XP bars, badges, stage progression)
- Screen designs needed: Onboarding, Dashboard, Milestones, Feeding, Health, Journal, Settings
- Provide specific Flutter widget/layout recommendations per screen

### 🧪 QA / TESTING
**Mandate:** Testing strategy and quality assurance.
- Testing pyramid: unit → integration → e2e
- Backend: Jest tests for all modules
- Mobile: Flutter tests (widget, unit)
- E2E: Playwright or equivalent
- Define test plan per module before implementation
- Review test coverage, identify gaps

### 🚀 DEVOPS
**Mandate:** Infrastructure, CI/CD, and deployment.
- Docker Compose setup (Postgres + backend)
- GitHub Actions CI pipeline
- Mobile build (iOS/Android)
- Deployment target (where?)
- Environment management
- Security scanning (dependabot, secrets)

## Communication Protocol
- Orchestrator (me) dispatches tasks to Programmer via delegate_task
- Architect, Designer, QA, DevOps provide guidance on request
- All agents read SPEC.md for context
- All work happens in project path above

## Current Phase
**Planning / Orchestration Setup**

## Priority Order
1. Architect reviews current backend structure → identifies gaps
2. Designer produces screen designs / Flutter widget specs
3. QA produces testing plan
4. DevOps reviews Docker Compose + CI/CD setup
5. Programmer executes: Backend → Mobile (per the todo queue)
