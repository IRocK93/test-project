# BabyMon Privacy & Compliance Audit — v4

**Date:** 2026-06-22
**Overall Grade: D** (incremental improvement from D- in v2)

---

## Regulatory Risk Assessment

| Framework | Grade | Key Issues |
|-----------|-------|------------|
| **GDPR (EU)** | **FAIL** | No DPO, no DPIA, no DPAs, soft-delete violates Art. 17, no consent storage, no ROPA, no breach notification |
| **COPPA (US)** | **FAIL** | No verifiable parental consent, no children's privacy notice |
| **HIPAA / PHI (US)** | **WATCH** | Not a covered entity yet, but health data collection creates BAA exposure |
| **FDA / SaMD (US)** | **WARNING** | Named-expert attribution + patient-specific health data + AI advice skirts CDS classification |
| **CCPA (US)** | **FAIL** | No notice at collection, no right to delete (soft-delete), no opt-out |
| **EU AI Act** | **WARNING** | AI-generated health advice could fall under high-risk classification |

---

## Critical Findings

### F1. Consent Flags Not Persisted to Database
The `RegisterDto` accepts `tosAccepted`, `privacyAccepted`, and `consentToDataProcessing` as optional booleans. The mobile UI enforces all three checkboxes. **But the backend `auth.service.ts::register()` method never reads or stores these values.** The `User` model has no consent columns.

**Impact:** Consent is captured in the UI, transmitted, and silently discarded. This alone fails GDPR Art. 7, Art. 9, and Art. 30.

### F2. deleteAccount is Soft Delete (GDPR Art. 17 Violation)
`users.service.ts:133-135` sets `deletedAt: new Date()` — email, name, and password hash persist permanently. GDPR Art. 17 requires actual deletion of personal data.

### F3. No Verifiable Parental Consent (COPPA)
Any registered user over 18 can create a BabyMon profile and enter extensive child health data. The Terms claim "you represent and warrant that you are the parent" — self-attestation is not verification.

### F4. No Breach Detection or Notification (GDPR Art. 33/34)
No breach detection infrastructure, no incident response plan, no mechanism to notify users or authorities within 72 hours.

### F5. S3 Photos Not Deleted on Account/BabyMon Deletion
On account deletion, Media DB records are deleted but S3 objects with children's photographs are never purged — orphaned and accessible indefinitely.

---

## High Severity

| # | Finding |
|---|---------|
| H1 | No Data Processing Agreements with 8 third-party processors (SendGrid, Stripe, Firebase, AWS S3, Neon.tech, Google, Apple, Facebook) |
| H2 | All data US-hosted (S3 us-east-1, Neon.tech US region), no EU safeguards, no SCCs |
| H3 | Backend OAuth endpoints missing — OAuth buttons in UI return 404 |
| H4 | No data retention policy or automated purge — soft-deleted records accumulate indefinitely |
| H5 | Personal email `merghani93@gmail.com` hardcoded in `.env.example` and seed data |
| H6 | In-app privacy policy contains false compliance claims |

---

## Medium Severity

- M1: No Data Protection Officer appointed (GDPR Art. 37)
- M2: In-app privacy policy embedded as Dart string — not hosted at stable URL
- M3: No Data Protection Impact Assessment (GDPR Art. 35)
- M4: No Records of Processing Activities (GDPR Art. 30)
- M5: Biometrics consent stored on-device only — no server-side audit trail
- M6: OAuth token handling without backend verification
- M7: Export functionality excludes media files, no full-account export

---

## Low Severity

- L1: No field-level encryption for special category data (bloodGroup, allergy treatment)
- L2: Android Manifest missing camera/photo permissions
- L3: SendGrid emails transmit PII in cleartext (standard practice, but document it)

---

## Data Inventory

| Category | Fields | Storage |
|----------|--------|---------|
| Parent PII | email, password hash (bcrypt 12), name, date of birth | Neon PostgreSQL |
| Child Identity | name, gender, birthDate, bloodGroup, eyeColor, biological parents | Neon PostgreSQL |
| Child Health | growth records, allergies, health records | Neon PostgreSQL |
| Child Developmental | milestones, feedLogs, sleepLogs | Neon PostgreSQL |
| Child Media | photos and videos | AWS S3 (us-east-1) |
| Medical Contacts | provider name, specialty, facility | Neon PostgreSQL |
| Device Data | FCM tokens, platform, IP address | Neon PostgreSQL |
| Payment Data | Stripe customer ID, subscription ID | Neon PostgreSQL + Stripe |
| Consent Records | tosAccepted, privacyAccepted, consentToDataProcessing | **NOWHERE — NOT PERSISTED** |

---

## Missing Documents (8 total)

1. Full standalone Privacy Policy
2. Data Processing Agreements (all 8 vendors)
3. Data Protection Impact Assessment
4. Records of Processing Activities
5. Cookie Policy / Tracking Disclosure
6. Children's Privacy Notice
7. Incident Response / Breach Notification Plan
8. AI Model Card / Transparency Document

---

## Compliance Roadmap

### Immediate (Week 1-2)
1. Store consent records in database
2. Complete legal entity identifiers in terms-and-conditions.md
3. Remove false compliance claims from in-app privacy policy
4. Implement hard-delete of PII on account deletion
5. Add S3 object deletion during account/BabyMon deletion

### Short-term (Week 3-6)
6. Host full attorney-reviewed Privacy Policy at babymon.app/privacy
7. Execute DPAs with all 8 third-party processors
8. Implement backend OAuth token verification endpoints
9. Implement verifiable parental consent mechanism
10. Add data retention policy and automated purge
11. Create breach notification / incident response plan

### Medium-term (Month 2-3)
12. Appoint Data Protection Officer
13. Conduct and document DPIA
14. Create and maintain ROPA
15. Obtain formal FDA SaMD classification analysis
16. Implement EU data residency option or execute SCCs
17. Add field-level encryption for special-category data
