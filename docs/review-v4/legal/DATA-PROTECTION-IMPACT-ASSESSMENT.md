# Data Protection Impact Assessment (DPIA) — BabyMon

**Document Reference:** DPIA-2026-001
**Date:** [INSERT DATE]
**Conducted by:** [DPO NAME], Data Protection Officer
**GDPR Reference:** Art. 35

---

## 1. Executive Summary

BabyMon processes special category data (child health, developmental, and biometric data) and uses AI-generated content for parenting advice. This DPIA assesses the risks to data subjects' rights and freedoms and documents mitigating measures.

**Risk Rating After Mitigation:** MEDIUM

## 2. Description of Processing

### 2.1 Nature of Processing

BabyMon is a mobile application that allows parents to:
- Track their baby's development (milestones, feeding, sleep, growth, health records)
- Receive AI-generated stage-appropriate parenting advice (Premium tier)
- Upload and store photos/videos of their child
- Share baby profiles with co-parents
- Earn gamification rewards (XP, badges) based on tracking activity

### 2.2 Scope

| Dimension | Detail |
|-----------|--------|
| Data subjects | Parents (account holders) and their children (profiled) |
| Geographic scope | Global (US-hosted infrastructure) |
| Data volume | 31 database models; up to 24 months of tracking data per child |
| Processing frequency | Real-time (mobile app interactions) |
| Retention | Until account deletion (PII); 7 years (audit logs) |

### 2.3 Context

- Relationship: B2C (direct to parents/consumers)
- Control: Parents have full control over data entry and deletion
- Independence: Parents are not obligated to use the service
- Expectations: Parents expect privacy for their child's health data

### 2.4 Purposes

All processing is for the legitimate purposes of:
1. Providing the baby tracking service (contractual necessity)
2. Gamification based on tracking activity (contractual necessity)
3. AI-generated parenting content (Premium tier, contractual)
4. Co-parent data sharing (explicit consent)
5. Service improvement and error tracking (legitimate interest)
6. Legal compliance and security (legal obligation)

## 3. Data Flow Mapping

```
Parent (Data Subject)
    │
    ├──> Mobile App (Flutter)
    │       │
    │       ├──> OAuth (Google/Apple/Facebook) ──> Auth tokens
    │       │
    │       └──> BabyMon API (NestJS / Railway)
    │               │
    │               ├──> Neon.tech (PostgreSQL) ──> All structured data
    │               ├──> AWS S3 ──> Photos/videos
    │               ├──> Stripe ──> Payment data
    │               ├──> SendGrid ──> Emails
    │               ├──> Firebase ──> Push notifications
    │               └──> Sentry ──> Error data (optional)
    │
    └──> Co-parent (authorized by parent) ──> Shared baby profile
```

## 4. Necessity and Proportionality Assessment

| Processing | Necessary? | Less Intrusive Alternative? | Proportional? |
|-----------|-----------|---------------------------|---------------|
| Child health data collection | Yes — core service | No — tracking requires data | Yes — parent-controlled entry |
| Photo/video storage | Yes — memory album feature | Optional — parent can skip | Yes — encrypted, access-controlled |
| AI Companion content | Yes — Premium tier feature | N/A — contractual feature | Yes — optional tier |
| Co-parent sharing | Yes — co-parenting feature | N/A — opt-in only | Yes — explicit invitation |
| Push notifications | Not strictly necessary | Disable via settings | Yes — opt-out available |
| Error tracking (Sentry) | Yes — service reliability | Disable by not configuring DSN | Yes — DSN-based activation |
| Audit logging | Yes — security, compliance | Anonymize after account deletion | Yes — pseudonymized |

## 5. Risk Assessment

### 5.1 Identified Risks

| ID | Risk | Likelihood | Impact | Inherent Risk |
|----|------|-----------|--------|---------------|
| R1 | Unauthorized access to child health data | Low | Very High | **HIGH** |
| R2 | Data breach at sub-processor | Low | High | **MEDIUM** |
| R3 | Co-parent accessing beyond authorized scope | Low | Medium | **LOW** |
| R4 | AI-generated advice misinterpreted as medical guidance | Medium | High | **HIGH** |
| R5 | Inadequate consent management (GDPR Art. 7) | Low | High | **MEDIUM** |
| R6 | Cross-border transfer without adequate safeguards | Low | High | **MEDIUM** |
| R7 | Excessive data retention | Low | Medium | **LOW** |
| R8 | Re-identification from pseudonymized data | Very Low | High | **LOW** |
| R9 | Child data used for unintended purposes | Very Low | Very High | **LOW** |
| R10 | Insufficient deletion on account closure | Low | High | **MEDIUM** |

### 5.2 Residual Risk After Mitigation

| ID | Mitigation | Residual Risk |
|----|-----------|---------------|
| R1 | bcrypt hashing, JWT rotation, access control, audit logging, rate limiting | **LOW** |
| R2 | DPAs with all processors, SCCs, encryption, vendor security review | **LOW** |
| R3 | BabyMon-scoped LinkedBabyMon table, owner-only invite/revoke | **LOW** |
| R4 | Medical AI Disclaimer gate, "not medical advice" labels on all content | **MEDIUM** |
| R5 | Consent checkboxes at registration, timestamped + stored, re-presented on policy updates | **LOW** |
| R6 | SCCs with US processors, TIA conducted, EU representative appointed | **LOW** |
| R7 | Automated data retention policy, hard delete on account closure, configurable TTLs | **LOW** |
| R8 | Pseudonymization of audit logs after account deletion | **LOW** |
| R9 | Strict purpose limitation in Privacy Policy, no advertising SDKs, no data sharing agreements | **LOW** |
| R10 | Automated S3 object deletion, cascading database deletes, audit trail of deletion | **LOW** |

## 6. Data Subject Rights Implementation

| Right | Implementation |
|-------|---------------|
| Access (Art. 15) | In-app data export (JSON/CSV); API endpoint GET /users/me |
| Rectification (Art. 16) | In-app editing of all profile and tracking data |
| Erasure (Art. 17) | Account deletion (DELETE /users/me); BabyMon deletion with cascade |
| Restriction (Art. 18) | Disable features; temporary account suspension |
| Portability (Art. 20) | Export endpoint returns all user data in structured format |
| Objection (Art. 21) | Contact DPO; processing halted pending review |
| Automated decisions (Art. 22) | No automated decisions with legal/significant effects |

## 7. Consultation

### 7.1 DPO Involvement

The Data Protection Officer was involved from the design phase and has reviewed this DPIA.

### 7.2 Supervisory Authority Consultation

Given the residual MEDIUM risk for AI-generated health content, consultation with the relevant supervisory authority is recommended but not mandated by GDPR Art. 36 (no high residual risk identified).

## 8. Monitoring and Review

This DPIA will be reviewed:
- Annually (minimum)
- Upon significant changes to processing activities
- Upon new feature launches involving personal data
- Upon regulatory changes affecting data protection obligations

## 9. Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Data Protection Officer | [DPO NAME] | ___________ | [DATE] |
| CTO / Technical Lead | [NAME] | ___________ | [DATE] |
| CEO / Legal Representative | [NAME] | ___________ | [DATE] |

---

*This DPIA is based on BabyMon's architecture and data flows verified by code audit (June 2026). To be completed and signed before processing special category data in production. Review by qualified privacy counsel required.*
