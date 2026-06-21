# 12 — Privacy & Compliance Audit

**Date:** 2026-06-17
**Severity Score:** 🔴 Critical (5 Critical, 5 High, 3 Medium)
**Verdict: FAIL — would not pass a COPPA or GDPR audit in current state.**

---

## Summary

This application collects **extensive children's health and growth data** — full names, birth dates, gender, traits, blood type, eye color, weight, height, head circumference, allergies, medications, sleep patterns, feeding data, developmental milestones, medical team contacts, and photographs of children. In its current state, it would **FAIL** a COPPA audit (no age gate, no verifiable parental consent, privacy policy links show "coming soon") and would **FAIL** a GDPR audit (no consent mechanism, non-functional legal links, incomplete erasure — user PII is soft-deleted but retained, children's photos in S3 are never purged). The committed `.env` file with live database credentials represents an active security incident. OAuth logins are stubbed. Data is exclusively US-hosted with no EU option. No Data Processing Agreements exist with any third-party vendor (SendGrid, Firebase, Stripe, AWS). The app must not collect children's personal data in the US or EU without resolving these issues.

---

## Data Inventory

| Category | Fields | Classification |
|---|---|---|
| **User (parent)** | email, name, password hash | Personal identifier |
| **Child profile** | name (first/middle/last), birth date, conception date, gender, traits, biological parents, blood group, eye color | Child PII, biometric/health |
| **Health records** | category, title, notes | Health records |
| **Growth records** | height, weight, head circumference, measured dates | Growth/health data |
| **Allergies** | name, triggers, severity (Mild/Moderate/Severe), treatment (EpiPen/Antihistamine), status, symptoms | Medical data |
| **Sleep logs** | type, start time, end time, quality | Behavioral/health data |
| **Feed logs** | type, amount, duration, notes | Nutritional data |
| **Milestones** | title, description, date | Developmental data |
| **Medical team** | name, specialty, facility | Healthcare provider info |
| **Photos** | images of children stored in AWS S3 (us-east-1) | Child images — highly sensitive |

---

## Findings

| ID | Severity | Category | Finding | Evidence | Recommendation |
|---|---|---|---|---|---|
| PC01 | 🔴 Critical | Secrets | **Live DB credentials + JWT secret committed to repo** | `apps/api/.env:1-2` | Rotate immediately. Add `.env` to `.gitignore`. Scrub git history. |
| PC02 | 🔴 Critical | COPPA | **No age gate** — children can register | `register_screen.dart` — no DOB field. `RegisterDto` (`auth/dto/auth.dto.ts:4-24`) — no age verification. | Add DOB field at registration. Block users under 13 (or 16 in EU). |
| PC03 | 🔴 Critical | COPPA | **No verifiable parental consent** | Absent entirely. App allows anyone to create baby profiles with extensive child data. | At minimum: checkbox "I am the parent/legal guardian of this child". For COPPA: implement VPC mechanism. |
| PC04 | 🔴 Critical | GDPR | **Privacy Policy & Terms links are "coming soon"** | `settings_screen.dart:783-787` | Create and link real privacy policy and terms of service. Must be accessible before data collection. |
| PC05 | 🔴 Critical | GDPR | **No consent checkboxes at registration** | `register_screen.dart:91-408` | Add: "I agree to Privacy Policy" (required), "I agree to Terms of Service" (required), "I consent to marketing emails" (optional). |
| PC06 | 🟠 High | GDPR | **`deleteAccount` is soft-delete — user PII retained** | `users.service.ts:130-133` | User record gets `deletedAt: new Date()` — email, name, password hash persist forever. | Hard-delete user record. Implement retention policy with automatic purge after X days. |
| PC07 | 🟠 High | GDPR | **Children's photos in S3 NOT deleted on account deletion** | `users.service.ts:86-114` — no media deletion | No `tx.media.deleteMany()` in `deleteAccount`. No S3 object deletion. Photos persist after "deletion." | Add media deletion (DB + S3) to `deleteAccount` transaction. |
| PC08 | 🟠 High | GDPR | **Export endpoint limited to 3 entries in mobile app** | `export.service.ts:133-136` — `take: 3` hardcoded | Users cannot get their complete data via the mobile app. GDPR Art. 20 requires full data portability. | Expose full export with progress indicator in mobile. Include media/photos in export. |
| PC09 | 🟠 High | Third-party | **No Data Processing Agreements (DPAs)** | Absent | No DPAs with: SendGrid (email), Firebase (push notifications), Stripe (billing), AWS (file storage), Google/Apple/Facebook (OAuth). | Sign DPAs with all third-party data processors. |
| PC10 | 🟠 High | Retention | **No data retention policy or automatic purge** | No purge code exists. `AUDIT_RETENTION_DAYS=2555` in `.env.example` line 65 but zero code references it. | Implement automatic purge of soft-deleted records after X days. Cron job for audit log retention. Add retention policy to privacy policy. |
| PC11 | 🟡 Medium | Data residency | **All data US-hosted, no EU option** | `apps/api/.env:1` — Neon PostgreSQL (us-east-1). AWS S3 (us-east-1). All vendors US-based. | Offer EU data center option or at minimum clearly document data residency in privacy policy. |
| PC12 | 🟡 Medium | Breach | **Audit logs destroyed on account deletion** | `users.service.ts:91-93` — `tx.auditLog.deleteMany` | Audit trail needed for forensic purposes is wiped on deletion. | Preserve audit logs for retention period even after account deletion. |
| PC13 | 🟡 Medium | Breach | **No breach notification mechanism** | Absent | No way to contact all users in event of a data breach. | Store contact methods. Implement notification capability. Prepare incident response plan. |

---

## Regulatory Checklist

| Requirement | Status | Notes |
|---|---|---|
| COPPA — Age gate | ❌ | No DOB collection, no 13+ verification |
| COPPA — Verifiable parental consent | ❌ | Absent |
| COPPA — Privacy policy accessible | ❌ | "coming soon" |
| COPPA — Data deletion capability | ⚠️ | Soft-delete only; photos not purged |
| COPPA — Parental right to review | ⚠️ | Export limited to 3 entries per category |
| GDPR Art. 7/8 — Consent | ❌ | No consent checkboxes |
| GDPR Art. 13/14 — Transparency | ❌ | No privacy notice at data collection |
| GDPR Art. 17 — Right to erasure | ⚠️ | Soft-delete; photos retained |
| GDPR Art. 20 — Data portability | ⚠️ | Export exists but limited in mobile |
| GDPR — DPA with processors | ❌ | None signed |
| GDPR — DPO contact | ❌ | None |
| HIPAA — BAA | N/A | Not a covered entity |

---

## Things Done Well

1. **GDPR Art. 20 export infrastructure exists** — JSON and CSV formats with full records (`export.service.ts:67-126`)
2. **Account deletion endpoint exists** (`DELETE /users/me`) with password verification required
3. **Audit logging infrastructure** (`AuditService`) with IP/user-agent capture
4. **Rate limiting** on auth endpoints via `@nestjs/throttler`
5. **Email verification** flow with 24-hour token expiry
6. **Password strength requirements** — 8+ chars, upper+lower+number
7. **`ValidationPipe` with `whitelist` and `forbidNonWhitelisted`** globally enforced
8. **CORS configured** (`main.ts:18`)
9. **Pino structured logging** for audit trails
10. **`.env.example` mentions `AUDIT_RETENTION_DAYS=2555`** with comment "7 years for compliance" — awareness exists, implementation missing

---

## Action Plan

| # | Action | Effort |
|---|---|---|
| 1 | **Rotate leaked credentials.** Delete `.env` from git history. | S |
| 2 | **Add age gate** — DOB field at registration, block under 13. | S |
| 3 | **Add parental consent checkbox** — "I am the parent/legal guardian." | S |
| 4 | **Create and link Privacy Policy + Terms of Service.** | L |
| 5 | **Add GDPR consent checkboxes** to registration form. | S |
| 6 | **Change `deleteAccount` to hard-delete** user record + purge S3 media. | M |
| 7 | **Include all data categories + full records in export.** | M |
| 8 | **Sign DPAs** with SendGrid, Firebase, Stripe, AWS, OAuth providers. | M |
| 9 | **Implement data retention policy** with automatic purge cron. | M |
| 10 | **Add EU data residency option** or document US-only. | L |
| 11 | **Implement breach notification capability.** | M |
| 12 | **Preserve audit logs** for retention period after account deletion. | S |
| 13 | **Fix OAuth flows** — implement real backend token verification. | L |
| 14 | **Add photo consent toggle** — separate consent for storing children's photos. | S |
| 15 | **Add Data Protection Officer contact** to the app. | S |
