# Children's Privacy Notice — BabyMon

**Effective Date:** [INSERT DATE]
**Compliance:** Children's Online Privacy Protection Act (COPPA), GDPR-K (Art. 8), California Age-Appropriate Design Code

---

## 1. Our Approach to Children's Privacy

BabyMon is **not directed to children**. It is a parenting tool designed for adults (age 18+) to track their own children's development.

**We do not:**
- Allow children under 16 to create accounts (age-gated at registration)
- Collect personal information directly from children
- Target advertising to children or parents based on child data
- Enable public profiles or social features for children
- Share child data with third parties for marketing or advertising

**Parents control:**
- What data is entered about their child
- Who has access (via co-parent invitations)
- When data is deleted

## 2. Information We Collect About Children

All child data is entered by the parent or legal guardian. The following categories may be collected:

| Category | Examples | Purpose |
|----------|----------|---------|
| Identity | Name, gender, birth date, blood group, eye color | Profile creation, developmental tracking |
| Health & Growth | Weight, height, head circumference, allergies, health events | Growth monitoring, WHO percentile analysis |
| Developmental | Milestones, feeding patterns, sleep patterns | Progress tracking, gamification (XP, badges) |
| Media | Photos and videos | Memory album, milestone documentation |
| Medical Contacts | Healthcare provider details | Emergency reference |

**We do NOT collect**: precise location, biometric data, browsing history, or behavioral profiling of the child.

## 3. How We Use Child Data

Child data is used exclusively for:
- Tracking developmental progress
- Providing stage-appropriate AI Companion content (Premium tier)
- Displaying growth charts and milestone timelines
- Sharing with co-parents explicitly authorized by the account owner
- Exporting data for healthcare provider visits

## 4. Parental Rights

As a parent or legal guardian, you have the right to:

1. **Review** your child's data at any time through the app
2. **Correct** inaccurate information
3. **Delete** your child's profile and all associated data
4. **Export** data in JSON/CSV format
5. **Refuse** further collection or use of your child's data (by not entering it)
6. **Revoke** a co-parent's access at any time

To exercise these rights, use the in-app controls or contact [LEGAL@BABYMON.APP].

## 5. Verifiable Parental Consent

**How we verify you are the parent:**

1. **Age gate**: Users must confirm they are 18+ at registration
2. **Parent affirmation**: At BabyMon creation, you must check "I am the parent or legal guardian of this child" — this affirmation is timestamped and stored
3. **Email verification**: Account email must be verified before full access is granted
4. **Account security**: Password-protected account prevents unauthorized access to your child's data

**For elevated data categories** (photos/videos via S3 uploads, Premium tier), we apply additional consent:
- Explicit acknowledgment of media upload permissions
- Separate acceptance of Medical AI Disclaimer before accessing AI Companion

## 6. Data Deletion

When you delete a BabyMon profile or your account:

| Data | Deletion Method | Timing |
|------|----------------|--------|
| Child profile (name, dates, traits) | Permanent deletion from database | Immediate |
| Tracking data (milestones, logs, records) | Permanent deletion | Immediate |
| Photos and videos | Deletion from AWS S3 | Immediate |
| Audit logs | Actor identifier pseudonymized | Within 30 days |

**You can delete individual records** (milestones, photos, etc.) at any time through the app.

## 7. Third-Party Access

Child data is shared only with:

| Recipient | Data | Purpose | Safeguard |
|-----------|------|---------|-----------|
| Neon.tech (database) | All stored data | Hosting | DPA, encryption at rest |
| AWS S3 | Photos/videos | Media storage | DPA, server-side encryption |
| Co-parents you invite | Shared baby profile | Co-parenting | Explicit invitation required, access can be revoked |

**We do not:**
- Sell child data
- Use child data for advertising
- Share child data with data brokers
- Enable public profiles

## 8. Security Measures for Child Data

- All data encrypted in transit (TLS 1.3)
- Photos encrypted at rest (S3 SSE)
- Access control: only owner + authorized co-parents
- Audit logging: all access and modifications tracked
- Rate limiting to prevent scraping
- Input validation on all endpoints

## 9. COPPA Safe Harbor

BabyMon is not currently a member of a COPPA Safe Harbor program. We directly comply with COPPA requirements as outlined in this notice.

## 10. Contact

For questions about our children's privacy practices:

| Role | Contact |
|------|---------|
| Data Protection Officer | [DPO@BABYMON.APP] |
| Legal inquiries | [LEGAL@BABYMON.APP] |
| FTC complaints | www.ftc.gov/complaint |

## 11. Changes to This Notice

Parents will be notified of material changes via in-app notification and email. Continued use after changes constitutes acceptance of the updated notice.

---

*This document reflects BabyMon's actual data practices verified by code audit (June 2026). To be filed alongside the main Privacy Policy. Replace [BRACKETED] values before publishing. COPPA compliance review by qualified counsel recommended.*
