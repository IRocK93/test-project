# Records of Processing Activities (ROPA) — BabyMon

**Document Reference:** ROPA-2026-001
**GDPR Reference:** Art. 30
**Prepared by:** [DPO NAME]
**Last Updated:** [INSERT DATE]

---

## 1. Controller Details

| Field | Value |
|-------|-------|
| Controller name | [COMPANY LEGAL NAME] |
| Registration number | [COMPANY REGISTRATION #] |
| Address | [COMPANY STREET ADDRESS], [CITY], [STATE] [ZIP], [COUNTRY] |
| Data Protection Officer | [DPO NAME] — [DPO@BABYMON.APP] |
| EU Representative | [EU REP NAME] — [EU-REP@BABYMON.APP] |

## 2. Processing Activities

### PA-01: User Account Management

| Field | Value |
|-------|-------|
| Purpose | Creating and managing parent user accounts |
| Legal basis | Contractual necessity (Art. 6(1)(b)), Consent (Art. 6(1)(a) for OAuth) |
| Data categories | Email, password hash (bcrypt), name, date of birth, OAuth tokens, consent records |
| Data subjects | Parents (adults 18+) |
| Recipients | Neon.tech (database), Google/Apple/Facebook (OAuth if used), SendGrid (verification emails) |
| Transfers | US (Neon.tech, SendGrid), Global (OAuth providers) |
| Retention | Until account deletion; audit logs pseudonymized after 30 days post-deletion |
| Security | bcrypt (12 rounds), JWT (15-min access, rotating refresh), TLS 1.3, rate limiting (5/min auth) |

### PA-02: Baby Profile Management

| Field | Value |
|-------|-------|
| Purpose | Creating and managing baby tracking profiles |
| Legal basis | Contractual necessity (Art. 6(1)(b)), Explicit consent for special category data (Art. 9(2)(a)) |
| Data categories | Child name, gender, birth date, conception date, blood group, eye color, biological parents, traits |
| Data subjects | Children (0-24 months), profiled by parents |
| Recipients | Neon.tech (database), AWS S3 (photos) |
| Transfers | US |
| Retention | Until BabyMon profile deletion or account deletion |
| Security | Access control (owner + authorized co-parents only), audit logging |

### PA-03: Health and Developmental Tracking

| Field | Value |
|-------|-------|
| Purpose | Logging child health, growth, feeding, sleep, and milestone data |
| Legal basis | Explicit consent for health data (Art. 9(2)(a)) |
| Data categories | Growth (weight, height, head circumference), allergies (name, triggers, severity, treatment), health records (category, value, notes), feeding logs, sleep logs, milestones |
| Data subjects | Children |
| Recipients | Neon.tech (database) |
| Transfers | US |
| Retention | Until deletion by parent |
| Security | Field-level validation, access control |

### PA-04: Photo and Video Storage

| Field | Value |
|-------|-------|
| Purpose | Storing child photos/videos uploaded by parents |
| Legal basis | Explicit consent (separate media upload permission) |
| Data categories | Photos (JPEG, PNG, GIF, WebP), videos (MP4, MOV) up to 50MB |
| Data subjects | Children |
| Recipients | AWS S3 (us-east-1) |
| Transfers | US |
| Retention | Until deletion by parent or account deletion |
| Security | S3 server-side encryption, presigned URLs (15-min TTL), path-based access control |

### PA-05: Co-parent Data Sharing

| Field | Value |
|-------|-------|
| Purpose | Sharing baby profiles between linked parent accounts |
| Legal basis | Explicit consent (invitation-based linking) |
| Data categories | Baby profile data, tracking data, photos |
| Data subjects | Children (shared between parents) |
| Recipients | Authorized co-parent accounts |
| Transfers | N/A (app-level sharing) |
| Retention | Until co-parent link is revoked |
| Security | Invitation-based, owner-controlled, scoped access per baby |

### PA-06: Push Notifications

| Field | Value |
|-------|-------|
| Purpose | Sending milestone, badge, and co-parent notifications |
| Legal basis | Consent (Art. 6(1)(a)), disable-able in settings |
| Data categories | FCM device token, platform (iOS/Android) |
| Data subjects | Parents |
| Recipients | Google Firebase (FCM) |
| Transfers | US |
| Retention | Until device unregistration or app uninstall |
| Security | Firebase secure token handling |

### PA-07: Subscription Management

| Field | Value |
|-------|-------|
| Purpose | Managing free trials and premium subscriptions |
| Legal basis | Contractual necessity (Art. 6(1)(b)) |
| Data categories | Email, Stripe customer ID, subscription status, price ID |
| Data subjects | Parents |
| Recipients | Stripe, Inc. |
| Transfers | Global (Stripe) |
| Retention | Per Stripe's retention policy |
| Security | Stripe PCI-DSS Level 1, webhook signature verification |

### PA-08: Error Tracking and Service Improvement

| Field | Value |
|-------|-------|
| Purpose | Identifying and fixing application errors |
| Legal basis | Legitimate interest (Art. 6(1)(f)) |
| Data categories | Error stack traces, IP address, user agent, request path |
| Data subjects | Parents |
| Recipients | Functional Software (Sentry) — optional, requires SENTRY_DSN |
| Transfers | US |
| Retention | 90 days (Sentry default) |
| Security | DSN-based opt-in activation |

### PA-09: Audit Logging

| Field | Value |
|-------|-------|
| Purpose | Security monitoring, compliance, debugging |
| Legal basis | Legal obligation (Art. 6(1)(c)), Legitimate interest (Art. 6(1)(f)) |
| Data categories | Actor user ID, event type, payload JSON, IP address, user agent, timestamp |
| Data subjects | Parents (actor tracking) |
| Recipients | Neon.tech (database) |
| Transfers | US |
| Retention | 7 years (configurable via AUDIT_RETENTION_DAYS) |
| Security | Pseudonymized after account deletion |

## 3. Sub-processor Index

| Processor | Processing Activities | DPA Status | Location | SCCs |
|-----------|---------------------|-----------|----------|------|
| Neon.tech | PA-01, PA-02, PA-03, PA-09 | Required | US (us-east-1) | Required |
| AWS (S3) | PA-04 | Required | US (us-east-1) | Required |
| Stripe | PA-07 | Required | Global | Stripe-provided |
| Twilio SendGrid | PA-01 | Required | US | Required |
| Google Firebase | PA-06 | Required | US | Required |
| Google OAuth | PA-01 | Required | Global | Required |
| Apple Sign-In | PA-01 | Required | Global | Required |
| Facebook Login | PA-01 | Required | Global | Required |
| Railway | All (hosting) | Required | US | Required |
| Sentry | PA-08 (optional) | Required if configured | US | Required if used |

## 4. Review Schedule

| Review Type | Frequency | Next Review |
|------------|----------|-------------|
| Full ROPA audit | Annual | [DATE + 1 YEAR] |
| Sub-processor review | Quarterly | [DATE + 3 MONTHS] |
| New feature trigger | On launch | N/A |
| Regulatory change trigger | Within 30 days of change | N/A |

---

*This ROPA reflects BabyMon's actual processing activities verified by code audit (June 2026). Replace [BRACKETED] values. Review by qualified privacy counsel required.*
