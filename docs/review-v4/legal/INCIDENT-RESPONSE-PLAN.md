# Incident Response & Breach Notification Plan — BabyMon

**Document Reference:** IRP-2026-001
**GDPR Reference:** Art. 33, 34
**Version:** 1.0
**Effective Date:** [INSERT DATE]

---

## 1. Purpose and Scope

This plan defines BabyMon's procedures for detecting, responding to, and notifying personal data breaches. It applies to all personal data processed by BabyMon, with escalated requirements for special category data (child health, biometric, and developmental data).

## 2. Breach Definition

A personal data breach is a breach of security leading to the accidental or unlawful destruction, loss, alteration, unauthorized disclosure of, or access to, personal data (GDPR Art. 4(12)).

### Examples Specific to BabyMon

| Scenario | Severity |
|----------|----------|
| Unauthorized access to another user's baby profile | **HIGH** |
| Database dump leaked publicly | **CRITICAL** |
| S3 bucket misconfigured — child photos publicly accessible | **CRITICAL** |
| Stripe payment data accessed (PCI-DSS) | **CRITICAL** |
| SendGrid API key compromised — emails intercepted | **HIGH** |
| Firebase admin credential leaked — push notifications hijacked | **MEDIUM** |
| Individual account compromised via credential stuffing | **LOW** (notify user) |
| Accidental email sent to wrong recipient | **LOW** |

## 3. Incident Response Team

| Role | Responsibility | Contact |
|------|---------------|---------|
| Incident Commander | Leads response, makes notification decisions | [NAME] — [PHONE] |
| Technical Lead | Investigates root cause, implements fix | [NAME] — [PHONE] |
| Data Protection Officer | Assesses regulatory impact, manages notifications | [DPO NAME] — [DPO@BABYMON.APP] |
| Communications | Drafts user notifications, manages PR | [NAME] — [PHONE] |
| Legal Counsel | Advises on legal obligations | [LAW FIRM] — [PHONE] |

## 4. Detection Mechanisms

| Mechanism | What It Detects | Responsible |
|-----------|----------------|-------------|
| Audit logs (Prisma AuditLog table) | Unauthorized data access patterns | Technical Lead |
| Server logs (Pino structured logging) | Failed auth attempts, anomalies | Technical Lead |
| Rate limit violations (ThrottlerGuard) | Brute force, scraping attempts | Automated |
| GitHub Dependabot alerts | Vulnerable dependencies | Technical Lead |
| Sentry error tracking (if configured) | Application errors, crashes | Technical Lead |
| Stripe webhook events | Payment anomalies | Automated (+ review) |
| User reports | Account compromise, data exposure | Support → DPO |

## 5. Response Procedure

### Phase 1: Detection & Triage (0-2 hours)

1. **Identify**: Confirm the breach from detection mechanism or user report
2. **Classify**: Assign severity (LOW, MEDIUM, HIGH, CRITICAL)
3. **Notify Incident Commander**: Immediately for HIGH/CRITICAL
4. **Convene Response Team**: Within 1 hour for HIGH/CRITICAL

### Phase 2: Containment (0-24 hours)

| Scenario | Containment Action |
|----------|-------------------|
| Database breach | Rotate database credentials; restrict to whitelisted IPs |
| S3 breach | Apply bucket policy to deny public access; rotate AWS keys |
| API key compromise | Revoke and rotate affected keys immediately |
| Account compromise | Force password reset; revoke all refresh tokens |
| Credential stuffing | Temporary rate limit reduction on auth endpoints |
| Dependency vulnerability | Evaluate and patch; deploy fix |

### Phase 3: Investigation (24-72 hours)

1. Determine root cause
2. Identify affected data subjects and data categories
3. Assess risk to rights and freedoms (likelihood × impact)
4. Document findings in breach log
5. Preserve forensic evidence

### Phase 4: Notification (Per GDPR timelines)

| Recipient | Timeline | When |
|-----------|----------|------|
| Supervisory Authority | **72 hours** from awareness | All breaches (GDPR Art. 33) |
| Affected Data Subjects | **Without undue delay** | HIGH/CRITICAL risk to rights and freedoms (GDPR Art. 34) |
| Sub-processors | **Immediately** | If breach originated at or affects processor |

#### Notification Contents (Supervisory Authority)

1. Nature of the breach
2. Categories and approximate number of data subjects affected
3. Categories and approximate number of personal data records affected
4. Name and contact details of DPO
5. Likely consequences of the breach
6. Measures taken or proposed to address the breach
7. Measures to mitigate possible adverse effects

#### Notification Contents (Data Subjects)

1. Nature of the breach (in clear, plain language)
2. Name and contact details of DPO
3. Likely consequences
4. Measures taken by BabyMon
5. Steps data subjects can take to protect themselves

### Phase 5: Remediation & Closure

1. Implement permanent fix
2. Verify fix with security testing
3. Update incident response plan based on lessons learned
4. Schedule post-mortem within 1 week
5. Document closure report

## 6. Breach Log Template

| Field | Value |
|-------|-------|
| Breach ID | IR-[YEAR]-[NNN] |
| Date/Time Detected | |
| Date/Time of Breach | |
| Detected By | |
| Severity | LOW / MEDIUM / HIGH / CRITICAL |
| Data Categories Affected | |
| Number of Data Subjects | |
| Root Cause | |
| Containment Actions | |
| Supervisory Authority Notified? | Yes / No / N/A (Date: _____) |
| Data Subjects Notified? | Yes / No / N/A (Date: _____) |
| Remediation Complete? | Yes / No (Date: _____) |
| Post-mortem Complete? | Yes / No (Date: _____) |
| Lessons Learned | |

## 7. Testing and Drills

| Activity | Frequency | Responsible |
|----------|----------|------------|
| Tabletop exercise | Quarterly | DPO + Technical Lead |
| Full simulation drill | Annually | Incident Commander |
| Plan review and update | Annually (or after any incident) | DPO |

## 8. Integration with Sub-processors

All sub-processors are contractually required (via DPA) to:
- Notify BabyMon within 24 hours of becoming aware of a breach
- Cooperate with BabyMon's investigation
- Provide necessary information for regulatory notifications

## 9. Regulatory Contact List

| Authority | Jurisdiction | Contact |
|-----------|-------------|---------|
| [LEAD SUPERVISORY AUTHORITY] | [COUNTRY] | [CONTACT INFO] |
| UK ICO | United Kingdom | https://ico.org.uk |
| CNIL | France | https://www.cnil.fr |
| Various (per user location) | EU Member States | Per DPO register |

---

*This plan reflects BabyMon's actual infrastructure and data flows verified by code audit (June 2026). Replace [BRACKETED] values with real contacts before activation. Regular testing and updates required.*
