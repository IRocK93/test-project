# S02 — Privacy & Compliance Audit

**Date:** 2026-06-18 | **Overall Verdict:** 🔴 COPPA: FAIL | GDPR: FAIL | CCPA: FAIL

BabyMon collects extensive children's health and growth data — full names, birth/conception dates, gender, biological parents, blood type, eye color, weight, height, head circumference, allergies with severity and treatments, sleep patterns, feeding data, developmental milestones, medical team contacts, and photographs of children stored in AWS S3. The app in its current state would not pass a COPPA, GDPR, or CCPA audit.

---

## Data Inventory

| Model | Fields Collected | Sensitivity |
|---|---|---|
| **User** | email, passwordHash, name, role, verifiedAt, deletedAt | Parent PII, credentials |
| **BabyMon** | name, middleName, lastName, gender, conceptionDate, lmpDate, birthDate, ideaDate, traits[], biologicalMother, biologicalFather, bloodGroup, eyeColor, currentXp, currentStage | Child PII (full name), biometric data, parent names, gestatiional/birth dates |
| **Milestone** | title, notes, happenedAt, localMediaRefs[], isCustom, xpAwarded | Developmental data |
| **FeedLog** | type, amount, unit, notes, happenedAt | Nutritional data |
| **HealthRecord** | category, title, notes, happenedAt | Health records |
| **SleepLog** | type, startTime, endTime, quality, notes | Behavioral/health data |
| **GrowthRecord** | type (HEIGHT/WEIGHT/HEAD_CIRCUMFERENCE), value, unit, measuredAt | Growth/health data |
| **Allergy** | name, triggers, severity (Mild/Moderate/Severe), treatment (EpiPen/Antihistamine/Avoidance), status (ACTIVE/CURED) | Medical data — special category under GDPR Art. 9 |
| **AllergyEvent** | happenedAt, notes | Medical event data |
| **MedicalTeam** | name, specialty, facility, notes | Healthcare provider contact info |
| **Media** | fileName, fileType, fileSize, s3Key, url, thumbnailUrl | Child photographs in AWS S3 (us-east-1) |
| **Device** | deviceToken, platform | Push notification token (PII) |
| **AuditLog** | eventType, payloadJson, ipAddress, userAgent | IP address logging (PII under GDPR) |

---

## Regulatory Checklist

| Framework | Requirement | Status |
|---|---|---|
| **COPPA** | Age gate (verify user is 13+) | FAIL |
| **COPPA** | Verifiable parental consent | FAIL |
| **COPPA** | Privacy policy (accessible, complete) | FAIL |
| **COPPA** | Parental right to review child's data | PARTIAL |
| **COPPA** | Parental right to delete child's data | FAIL |
| **COPPA** | Data retention (delete when no longer needed) | FAIL |
| **GDPR Art. 7/8** | Consent (freely given, specific, informed) | FAIL |
| **GDPR Art. 9** | Explicit consent for special category data | FAIL |
| **GDPR Art. 13/14** | Transparency / privacy notice | FAIL |
| **GDPR Art. 15** | Right of access | PARTIAL |
| **GDPR Art. 17** | Right to erasure | FAIL |
| **GDPR Art. 20** | Data portability | PARTIAL |
| **GDPR Art. 25** | Data protection by design/default | FAIL |
| **GDPR Art. 28** | DPA with processors | FAIL |
| **GDPR Art. 30** | Records of processing activities | FAIL |
| **GDPR Art. 32** | Security of processing | PARTIAL |
| **GDPR Art. 33/34** | Breach notification | FAIL |
| **GDPR Art. 37** | Data Protection Officer | FAIL |
| **GDPR Art. 44-49** | International transfers | FAIL |
| **CCPA** | Notice at collection | FAIL |
| **CCPA** | Right to know / access | PARTIAL |
| **CCPA** | Right to delete | FAIL |
| **CCPA** | Right to opt-out of sale | PARTIAL |
| **CCPA** | Non-discrimination | PASS |

---

## Findings

### PC01 | 🔴 CRITICAL | COPPA/GDPR | No Age Gate at Registration

**Location:** `apps/api/src/auth/dto/auth.dto.ts:4-24`, `apps/mobile/lib/features/auth/presentation/screens/register_screen.dart:91-408`

**What:** Registration collects only email, password, and optional name. No date-of-birth field, no age verification, no mechanism to block users under 13 (COPPA) or 16 (GDPR). Users can immediately create BabyMon profiles collecting deep child data.

**Remediation:** Add required date-of-birth field. Block users under 13 (US) or 16 (EU). Detect user jurisdiction to apply correct minimum age.

---

### PC02 | 🔴 CRITICAL | COPPA | No Verifiable Parental Consent

**Location:** Absent entirely from codebase.

**What:** Any registered user can create a BabyMon and enter extensive child data with zero verification they are the parent/guardian. COPPA requires verifiable parental consent before collecting children's personal information.

**Remediation:** Implement COPPA-compliant VPC mechanism. At minimum, add affirmative checkbox: "I am the parent or legal guardian of this child" with audit trail.

---

### PC03 | 🔴 CRITICAL | COPPA/GDPR | Privacy Policy Not Linked at Data Collection

**Location:** `apps/mobile/lib/features/settings/presentation/screens/settings_screen.dart:830-904`

**What:** Privacy Policy and Terms are hardcoded strings in the settings screen Dart file. No privacy notice at registration. Legal docs in `docs/legal/` have placeholder fields like `[COMPANY LEGAL NAME]`, `[EFFECTIVE DATE]`.

**Remediation:** Host real privacy policy at stable URL. Display at registration BEFORE data collection. Remove placeholder fields. Add effective dates and version tracking.

---

### PC04 | 🔴 CRITICAL | GDPR Art. 7/8 | No Consent Checkboxes at Registration

**Location:** `apps/mobile/lib/features/auth/presentation/screens/register_screen.dart:91-408`

**What:** Zero consent checkboxes at registration. Users are not asked to agree to Privacy Policy, Terms of Service, or consent to processing of special category data (child health data — GDPR Art. 9).

**Remediation:** Add: (1) Privacy Policy agreement checkbox (required), (2) Terms of Service checkbox (required), (3) Child health data processing consent (required for GDPR Art. 9), (4) Photo/media consent (optional), (5) Marketing consent (optional). Store consent timestamps and versions.

---

### PC05 | 🟠 HIGH | GDPR Art. 17 | deleteAccount is Soft-Delete — PII Retained Forever

**Location:** `apps/api/src/users/users.service.ts:56-139`

**What:** `deleteAccount` performs `data: { deletedAt: new Date() }`. User's email, name, and passwordHash preserved permanently. GDPR Art. 17 requires actual deletion of personal data upon request.

**Remediation:** Two-phase deletion: (1) Immediate: nullify all PII fields, set deletedAt. (2) After retention period (e.g., 30 days for dispute resolution), hard-delete the record.

---

### PC06 | 🟠 HIGH | GDPR Art. 17 | Children's Photos in S3 NOT Deleted

**Location:** `users.service.ts:56-139`, `baby-mon.service.ts:148-167`, `media.service.ts:165-191`

**What:** On account/BabyMon deletion, Media DB records are deleted (via cascade or `deleteMany`), but S3 objects containing children's photos are never deleted. Files become orphaned — accessible via URL and retained indefinitely.

**Remediation:** Before bulk-deleting Media records, fetch `s3Key` for each record and call `S3Service.deleteFile(key)`. Add dead-letter queue for failed S3 deletions.

---

### PC07 | 🟠 HIGH | GDPR Art. 20 | Export Limited to 3 Entries Per Category

**Location:** `apps/api/src/export/export.service.ts:128-232`

**What:** `exportBabyMon()` applies `take: 3` to milestones, feedLogs, healthRecords. GDPR Art. 20 requires full data portability — all data in structured, commonly used format.

**Remediation:** Expose `getFullBabyMonData` endpoint in mobile API client. Add pagination for large datasets. Include Media files in export.

---

### PC08 | 🟠 HIGH | GDPR Art. 28 | No DPAs with Third-Party Vendors

**Location:** Absent from codebase.

**What:** App transmits personal data to five third-party processors with zero DPAs: SendGrid/Twilio (emails), Firebase/Google (push), Stripe (payments), AWS S3 (photos), Neon (database). OAuth providers (Google, Apple, Facebook) also integrated client-side.

**Remediation:** Execute DPAs with all vendors. Document agreements. Add DPA compliance to privacy policy.

---

### PC09 | 🟠 HIGH | No Data Retention Policy or Automatic Purge

**Location:** `.env.example:65` (referenced but unused)

**What:** `AUDIT_RETENTION_DAYS=2555` exists in `.env.example` but zero code references it. No cron job, no scheduled task, no purge logic. Soft-deleted records accumulate forever.

**Remediation:** Implement scheduled cron job that reads retention config and purges expired records, tokens, and audit logs. Publish retention policy in privacy policy.

---

### PC10 | 🟡 MEDIUM | Audit Logs Destroyed on Account Deletion

**Location:** `users.service.ts:91-93`, `baby-mon.service.ts:160-161`

**What:** `deleteAccount` deletes audit logs: `tx.auditLog.deleteMany({ where: { babymonId: bm.id } })`. Destroys forensic evidence for breach investigation.

**Remediation:** Never delete audit logs during account deletion. Anonymize by replacing `babymonId` and `actorUserId` with opaque pseudonymous identifiers.

---

### PC11 | 🟡 MEDIUM | No Data Breach Notification Mechanism

**Location:** Absent from codebase.

**What:** No mechanism to notify users of a data breach. GDPR Art. 33/34 requires notification to supervisory authority within 72 hours and notification to affected data subjects.

**Remediation:** Implement breach notification capability via stored email and push notification. Create incident response plan.

---

### PC12 | 🟡 MEDIUM | All Data US-Hosted, No EU Option

**Location:** `.env.example:34`, `s3.service.ts:18-21`

**What:** All infrastructure defaults to US-East-1. No EU data center option. GDPR requires adequate safeguards (SCCs) for EU→US transfers.

**Remediation:** Provide EU data residency option or clearly document US-only residency in privacy policy before data collection. Execute SCCs for all US-based processors.

---

### PC13 | 🟡 MEDIUM | OAuth Login Flows Are Stubbed Client-Side

**Location:** `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart:147-258`

**What:** Google, Apple, Facebook OAuth logins create mock users with hardcoded IDs like `'google-${DateTime.now().millisecondsSinceEpoch}'`. Tokens never sent to backend for verification. No backend OAuth endpoints exist.

**Remediation:** Implement backend OAuth token verification for all three providers before issuing application JWT tokens.

---

### PC14 | 🟡 MEDIUM | GDPR Art. 37 | No Data Protection Officer

**Location:** Absent from codebase and documentation.

**What:** GDPR Art. 37 requires organizations processing special categories of data on a large scale to appoint a DPO. No DPO designated anywhere.

**Remediation:** Appoint DPO (internal or contracted). Add DPO contact to privacy policy and app settings. Register with supervisory authorities.

---

### PC15 | 🟡 MEDIUM | JWT Secret Falls Back to Insecure Default

**Location:** `auth.service.ts:10-14`

**What:** If `JWT_SECRET` not set and `NODE_ENV !== 'production'`, falls back to `'dev-only-secret'`. Fragile defense.

**Remediation:** Throw fatal error and refuse to start if `JWT_SECRET` not set in ANY environment. Never use hardcoded fallback.

---

### PC16 | 🔵 LOW | Sleep Logs Not in Manual Deletion Cascade

**Location:** `baby-mon.service.ts:148-167`, `users.service.ts:86-114`

**What:** Manual cascade deletion incomplete vs known models. SleepLog, Allergy, AllergyEvent, MedicalTeam, BabyMilestone, UserRoutine not manually deleted (relying on Prisma cascade). Fragile.

**Remediation:** Standardize: either rely exclusively on Prisma cascade or manually delete all related models. Add integration tests.

---

### PC17 | 🔵 LOW | No Photo-Specific Consent

**What:** Media upload accepts children's photographs (JPEG, PNG, GIF, WebP, MP4, MOV up to 50MB) with no photo-specific consent beyond JWT guard.

**Remediation:** Add photo/media consent toggle separate from general data processing consent. Allow revocation separately from account deletion.

---

### PC18 | 🔵 LOW | GDPR Art. 30 | No Records of Processing Activities

**What:** No ROPA document exists. GDPR Art. 30 requires documenting data categories, purposes, recipients, transfers, retention periods, and security measures.

**Remediation:** Create and maintain ROPA document.

---

## Things Done Well

1. GDPR Art. 20 export infrastructure exists — `getFullBabyMonData` fetches all records for JSON/CSV
2. Account deletion endpoint exists — `DELETE /api/users/me` with password re-verification
3. Audit logging infrastructure — `AuditService` with IP address and User-Agent capture
4. Email verification flow with 24-hour token expiry
5. Password strength requirements — 8+ chars, uppercase + lowercase + number
6. `ValidationPipe` with `whitelist` and `forbidNonWhitelisted` globally enforced
7. CORS configured with credential support
8. Pino structured logging
9. Bcrypt with 12 salt rounds
10. Terms & Conditions and Medical/AI Disclaimer documents exist in `docs/legal/`
11. `.env` NOT tracked by Git
12. Individual media deletion properly purges S3 objects
13. Prior privacy compliance self-review exists at `docs/review/12-privacy-compliance.md`

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 4 |
| 🟠 High | 5 |
| 🟡 Medium | 6 |
| 🔵 Low | 3 |
| **Total** | **18** |
