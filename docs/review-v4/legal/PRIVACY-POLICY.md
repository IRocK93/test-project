# Privacy Policy — BabyMon

**Effective Date:** [INSERT DATE]
**Last Updated:** [INSERT DATE]

## 1. Introduction

BabyMon ("we," "our," or "us") is a gamified baby-tracking and parenting companion application. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and related services (the "Service").

By using BabyMon, you agree to the collection and use of information in accordance with this policy. If you are located in the European Economic Area (EEA), United Kingdom, or California, additional rights apply as described below.

## 2. Information We Collect

### 2.1 Information You Provide

| Category | Data | Purpose |
|----------|------|---------|
| Account | Email, name, password (hashed with bcrypt) | Authentication, communication |
| Child Profile | Name, gender, birth date, conception date, blood group, eye color, traits | Developmental tracking |
| Health Data | Growth measurements (weight, height, head circumference), allergies (name, triggers, severity), health records (category, value, notes) | Health and development monitoring |
| Developmental | Milestones, feeding logs (type, amount), sleep logs (start/end, quality) | Progress tracking and gamification |
| Media | Photos and videos of your child | Memory album, milestone documentation |
| Medical Contacts | Healthcare provider name, specialty, facility | Emergency reference |
| Payment | Stripe processes payments; we receive subscription status and customer ID only | Subscription management |
| Communications | Email verification status, password reset requests, support inquiries | Account security, customer support |

### 2.2 Information Collected Automatically

| Category | Data | Purpose |
|----------|------|---------|
| Device | Platform (iOS/Android), FCM device token | Push notifications |
| Usage | Feature usage, screen views, session duration (via Sentry if configured) | Error tracking, service improvement |
| Logs | IP address, request timestamp, user agent | Security, debugging, audit trail |

### 2.3 Information We Do NOT Collect

- Precise location data (GPS)
- Contacts or address book
- Browsing history from other apps
- Advertising identifiers
- Voice recordings

## 3. How We Use Your Information

We use your information exclusively for:

1. **Service delivery**: Tracking your baby's development, displaying milestones, calculating growth percentiles
2. **Gamification**: Awarding XP, badges, and evolution stages based on your tracking activity
3. **AI Companion** (Premium tier): Delivering stage-appropriate advice, routines, and milestone expectations
4. **Co-parent features**: Sharing baby profiles with linked parent accounts you invite
5. **Notifications**: Push notifications for milestones, badge unlocks, and co-parent proposals (can be disabled)
6. **Account management**: Authentication, password reset, email verification
7. **Subscription**: Managing free trial and premium subscription via Stripe
8. **Security**: Fraud prevention, abuse detection, audit logging
9. **Legal compliance**: Responding to legal requests, enforcing our Terms

We do NOT sell your data. We do NOT use your data for advertising. We do NOT build marketing profiles.

## 4. How We Share Your Information

### 4.1 Service Providers (Sub-processors)

| Provider | Data Shared | Purpose | Location |
|----------|------------|---------|----------|
| Neon.tech | All database content | PostgreSQL hosting | US |
| AWS (Amazon S3) | Photos and videos | Media storage | US (us-east-1) |
| Stripe | Email, customer ID, subscription status | Payment processing | Global |
| Twilio SendGrid | Email address, name | Transactional emails | US |
| Google Firebase | FCM device token, platform | Push notifications | US |
| Google Sign-In | Email, profile (OAuth) | Authentication (optional) | Global |
| Apple Sign-In | Email, name (OAuth) | Authentication (optional) | Global |
| Facebook Login | Email, public profile (OAuth) | Authentication (optional) | Global |
| Railway | Application hosting | Backend deployment | US |
| Sentry (if configured) | Error data, IP | Error tracking | US |

All sub-processors are bound by Data Processing Agreements. Contact us at [LEGAL@BABYMON.APP] for copies.

### 4.2 Other Disclosures

- **Co-parents**: Baby profile data is shared with parent accounts you explicitly link and authorize
- **Legal requirements**: We may disclose information if required by law, court order, or government request
- **Business transfers**: In the event of a merger, acquisition, or asset sale, your data may be transferred with notice

## 5. Data Retention

| Data Category | Retention Period | Deletion Method |
|--------------|-----------------|----------------|
| Account data | Until account deletion | Hard delete of PII; audit records anonymized after 30 days |
| Child profile & tracking data | Until BabyMon profile deletion | Permanent deletion |
| Photos and videos | Until deletion by user | Deleted from S3 upon account/BabyMon deletion |
| Audit logs | 7 years (configurable) | Pseudonymized after account deletion |
| Payment records | Per Stripe retention policy | Managed by Stripe |
| Email verification tokens | 24 hours | Automatic expiry |
| Password reset tokens | 1 hour | Automatic expiry |
| Refresh tokens | 7 days (configurable) | Revoked on logout or rotation |

## 6. Your Rights

### 6.1 All Users

- **Access**: Request a copy of your data via the in-app Export feature (JSON/CSV)
- **Correction**: Update your profile and baby data at any time
- **Deletion**: Delete your account via Settings → Delete Account (requires password verification)
- **Portability**: Export your data in machine-readable format
- **Opt-out**: Disable push notifications in device settings; unsubscribe from emails

### 6.2 EEA/UK Residents (GDPR)

You have the following additional rights under GDPR:

- **Right to erasure** (Art. 17): Request permanent deletion of all personal data
- **Right to restrict processing** (Art. 18): Limit how we use your data
- **Right to object** (Art. 21): Object to processing based on legitimate interests
- **Right to withdraw consent** (Art. 7): Withdraw consent at any time
- **Right to lodge a complaint**: Contact your local supervisory authority

Legal basis for processing:
| Processing Activity | Legal Basis |
|--------------------|-------------|
| Core tracking service | Contractual necessity (Art. 6(1)(b)) |
| Child health data | Explicit consent (Art. 9(2)(a)) |
| AI Companion content | Contractual necessity (Premium tier) |
| Push notifications | Consent (Art. 6(1)(a)) |
| Email communications | Legitimate interest (Art. 6(1)(f)) |
| Audit logging | Legal obligation / legitimate interest |
| Error tracking (Sentry) | Legitimate interest (Art. 6(1)(f)) |

### 6.3 California Residents (CCPA/CPRA)

You have the right to:
- Know what personal information we collect, use, and disclose
- Delete personal information (with exceptions)
- Opt-out of the sale of personal information (we do not sell data)
- Non-discrimination for exercising your rights

### 6.4 Exercising Your Rights

Contact us at:
- **Email:** [LEGAL@BABYMON.APP]
- **Data Protection Officer:** [DPO NAME] at [DPO@BABYMON.APP]
- **Address:** [COMPANY STREET ADDRESS], [CITY], [STATE] [ZIP]

We will respond within 30 days (GDPR) or 45 days (CCPA).

## 7. Children's Privacy

BabyMon is designed for parents to track their children's development. We do not knowingly collect personal information directly from children under 16. Parents create and manage their child's profile.

If you believe we have inadvertently collected data from a child without parental consent, contact us immediately at [LEGAL@BABYMON.APP].

For detailed COPPA information, see our Children's Privacy Notice.

## 8. Data Security

We implement appropriate technical and organizational measures:

- **Encryption in transit**: TLS 1.3 for all network communications
- **Encryption at rest**: PostgreSQL encryption (Neon.tech); S3 server-side encryption
- **Authentication**: bcrypt password hashing (12 rounds); JWT access tokens (15 min); refresh token rotation
- **Access control**: Co-parent scoped access; owner-only mutations
- **Audit logging**: All data access and modifications logged with actor tracking
- **Security headers**: Helmet (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- **Rate limiting**: Auth: 5/min; Sensitive: 10/min; Default: 100/min
- **Input validation**: All endpoints use typed DTOs with class-validator
- **Dependency scanning**: Dependabot configured for weekly npm updates, monthly Docker and Actions

## 9. International Data Transfers

Our servers and sub-processors are located in the United States. For EEA/UK users, we implement:

- Standard Contractual Clauses (SCCs) with all US-based processors
- Data Processing Agreements (DPAs) with all sub-processors
- Transfer Impact Assessment (TIA) conducted

Contact us for copies of relevant safeguards.

## 10. Data Breach Notification

In the event of a personal data breach, we will:
1. Notify affected users without undue delay if there is high risk to rights and freedoms
2. Notify the relevant supervisory authority within 72 hours (GDPR Art. 33)
3. Document the breach, its effects, and remedial actions taken

## 11. Changes to This Policy

We will notify you of material changes via:
- In-app notification
- Email to registered address
- Updated "Effective Date" at the top of this policy

Continued use after changes constitutes acceptance.

## 12. Contact

| Role | Contact |
|------|---------|
| General inquiries | [SUPPORT@BABYMON.APP] |
| Privacy concerns | [LEGAL@BABYMON.APP] |
| Data Protection Officer | [DPO@BABYMON.APP] |
| EU Representative | [EU-REP@BABYMON.APP] |
| Physical address | [COMPANY NAME], [STREET], [CITY], [STATE] [ZIP], [COUNTRY] |

---

*This document is a template based on BabyMon's actual data practices as verified by code audit (June 2026). Replace all [BRACKETED] values with real identifiers before publishing. Review by qualified privacy counsel required before deployment.*
