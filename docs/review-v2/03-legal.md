# S03 — Legal Review

**Date:** 2026-06-18 | **Overall Risk Level:** 🔴 Critical

## Key Legal Classifications

| Classification | Assessment |
|---|---|
| **Medical Device Risk** | HIGH — collects clinical-grade data, attributes advice to named medical professionals, AI generates patient-specific recommendations |
| **Health Data Regulation** | GDPR-Health (Art. 9 special category) applies; HIPAA risk if provider integration planned |
| **AI Regulation Exposure** | EU AI Act — limited-risk to borderline high-risk under Annex III point 11 |

---

## Missing Legal Documents (12 identified)

1. **Privacy Policy (full, standalone)** — only in-app summary exists
2. **Data Processing Agreement (DPA)** — none with any vendor
3. **Data Protection Impact Assessment (DPIA)** — required under GDPR Art. 35
4. **Cookie Policy / Tracking Disclosure**
5. **End-User License Agreement (EULA)**
6. **Acceptable Use Policy** (standalone)
7. **Copyright / DMCA Policy** — no DMCA agent registration
8. **Children's Privacy Notice** — simplified, child-friendly version
9. **Vendor / Subprocessor List** — formal maintained document
10. **Incident Response / Breach Notification Plan**
11. **Model Card / AI Transparency Document**
12. **Accessibility Statement**

---

## Findings

### L-01 | 🔴 CRITICAL | FDA SaMD Classification Risk

**Location:** Full application architecture

**What:** BabyMon collects extensive medical-grade data (growth records with WHO/CDC percentiles, allergies with severity/treatment, vaccination schedules, screening reminders). AI Companion generates advice attributed to named experts ("Dr. Vasquez," "Maria Chen"). This combination strongly resembles "clinical decision support" under FDA's SaMD framework. FDA has issued warning letters to apps with similar patterns.

**Evidence:** `schema.prisma` GrowthRecord, Allergy, MedicalTeam, VaccinationSchedule, ScreeningReminder models; `system_prompt_builder.dart:24-30` (expert attribution); `model-manifest.controller.ts:20-21`

**Recommended Action:** Obtain formal FDA classification analysis from regulatory attorney. Document "intended use" as general wellness. Remove or depersonalize named-expert attribution.

---

### L-02 | 🔴 CRITICAL | Medical Disclaimer Acceptance Not Recorded

**Location:** `apps/mobile/lib/features/companion/presentation/screens/medical_disclaimer_gate.dart`

**What:** Disclaimer gate asks users to accept "I assume all risks" but: (a) appears only once, (b) not recorded on server (no audit trail), (c) uses simplified summary not full disclaimer, (d) "assume all risks" language may not hold up in all jurisdictions.

**Recommended Action:** Record disclaimer acceptance timestamp and version on server. Re-present on content updates. Replace "assume all risks" with more defensible wording.

---

### L-03 | 🟠 HIGH | In-App Terms Are a Legally Inadequate Summary

**Location:** `settings_screen.dart:830-852`

**What:** In-app "Terms & Conditions" is a 23-line summary missing critical provisions: no dispute resolution, no arbitration clause, no governing law, no class action waiver, no severability, no indemnification, no limitation of liability details. Full terms document has all company identifiers as placeholders.

**Recommended Action:** Replace in-app summary with full attorney-reviewed Terms. Complete all placeholder values. Link to full terms on company website.

---

### L-04 | 🔴 CRITICAL | Medical Device Classification is Plausible

**Location:** Entire application

**What:** FDA's 2022 CDS Software guidance factors: (a) generates recommendations based on patient-specific information (child's age, stage, growth, sleep, feeding), (b) attributes advice to named medical professionals creating impression of clinical authority, (c) system prompt instructs LLM to "Attribute specific advice to the experts cited," (d) includes "emergency detection" language.

**Recommended Action:** Commission formal SaMD classification analysis. If determined to be medical device, pursue 510(k) clearance or De Novo classification before US launch. Ensure all marketing positions app as informational/wellness only.

---

### L-05 | 🟠 HIGH | EU AI Act — No Analysis, No Compliance

**Location:** Entire application

**What:** EU AI Act entered into force August 2024. AI system providing health/medical advice could be classified as "high-risk" under Annex III point 11. Even "limited risk" requires transparency obligations. Zero mention of EU AI Act anywhere in codebase or legal documents.

**Recommended Action:** Conduct EU AI Act classification analysis. If high-risk: conformity assessment, technical documentation, human oversight mechanisms. If limited-risk: ensure AI interaction disclosure. Register in EU database if required.

---

### L-06 | 🟡 MEDIUM | HIPAA Business Associate Risk

**Location:** `schema.prisma:470-489` (MedicalTeam model)

**What:** HIPAA marked "N/A" in prior review but MedicalTeam model stores provider name, specialty, facility. If app integrates with healthcare providers or processes data on behalf of covered entity, it becomes a business associate requiring BAA.

**Recommended Action:** If any provider integration planned, prepare BAA templates. Avoid creating PHI unless BAA in place.

---

### L-07 | 🟠 HIGH | No Model Card, No Bias Testing, Hallucination Risk

**Location:** `llamadart_engine.dart`, `system_prompt_builder.dart`

**What:** AI model (Gemma 4 E2B from Google) lacks: (a) model version and training data disclosure, (b) limitation and bias documentation, (c) accuracy benchmarking, (d) content grounding creates false impression all advice is expert-verified, (e) no red-teaming documentation.

**Recommended Action:** Publish model card per Google's framework. Document content grounding process and limitations. Implement automated factuality testing. Add "Why this answer?" feature showing source content.

---

### L-08 | 🟡 MEDIUM | Redistributing Gemma Without License Compliance

**Location:** `model-manifest.controller.ts`, `llamadart_engine.dart`

**What:** App redistributes Gemma 4 E2B as downloadable GGUF from `cdn.babymon.app`. Gemma's license imposes specific use restrictions, attribution requirements, and prohibited use cases. No evidence of license compliance.

**Recommended Action:** Review and comply with Gemma's license terms. Include required attribution and license notices. Address prohibited use cases in ToS.

---

### L-09 | 🟡 MEDIUM | Emergency Detection in System Prompt Creates Liability

**Location:** `system_prompt_builder.dart:27-28`

**What:** System prompt instructs LLM: "If a question relates to a medical emergency, IMMEDIATELY instruct the parent to call emergency services." Implies AI can reliably detect emergencies — but LLMs are prone to miss or over-trigger. Both failure modes create liability.

**Recommended Action:** Remove automated emergency detection. Replace with static always-visible banner: "If this is a medical emergency, stop using this app and call 911 immediately."

---

### L-10 | 🔴 CRITICAL | No ToS Acceptance or Age Verification at Registration

**Location:** `register_screen.dart`

**What:** Registration form has no "I agree to Terms of Service" checkbox, no "I agree to Privacy Policy" checkbox, no date-of-birth field, no "I am 18+" checkbox. User can create account and add child health data without ever accepting Terms. Browse-wrap/click-wrap formation not established. Contracts voidable by minors.

**Recommended Action:** Add mandatory checkboxes: (a) "I am at least 18 years of age," (b) "I agree to the Terms of Service," (c) "I agree to the Privacy Policy." Record timestamp, IP, and accepted document version in database.

---

### L-11 | 🔴 CRITICAL | All Legal Entity Identifiers Are Placeholders

**Location:** `docs/legal/terms-and-conditions.md:1-7,143,160,162,179-181`

**What:** Every critical legal identifier is missing: [COMPANY LEGAL NAME], [EFFECTIVE DATE], [COMPANY STREET ADDRESS], [STATE], [LEGAL@BABYMON.APP]. Contract without contracting party identified is unenforceable. Indemnification names "[COMPANY LEGAL NAME]" — no entity exists to be indemnified. Governing law specifies "State of [STATE]" — no jurisdiction selected.

**Recommended Action:** Form legal entity (LLC/corporation). Complete all placeholders. Select favorable governing law and venue. Re-execute Terms through proper click-wrap formation.

---

### L-12 | 🟠 HIGH | Contradictory Refund Policies + Broken Legal Links

**Location:** `subscription_screen.dart:57,126-129,241-243,526-533`

**What:** Subscription screen displays "30-day money-back guarantee" but Terms state "All subscription fees are non-refundable." Directly contradictory. "Terms," "Privacy," "Restore purchases," "Support" links all trigger `_showComingSoon()` — deceptive and likely violates app store guidelines.

**Recommended Action:** Resolve refund policy contradiction. Implement functional Terms/Privacy/Support links. Remove or implement Restore purchases.

---

### L-13 | 🟠 HIGH | No Pre-Renewal Notices; Auto-Renewal Disclosures Incomplete

**Location:** `stripe.service.ts`

**What:** Auto-renewal correctly implemented at Stripe level but no pre-renewal reminder emails/notifications. Many jurisdictions (California, EU, UK) require specific auto-renewal disclosures and easy cancellation. Code sends no pre-renewal reminders.

**Recommended Action:** Add pre-renewal reminder emails 7 days and 1 day before renewal. Display auto-renewal terms prominently at checkout. Comply with California Auto-Renewal Law and EU Consumer Rights Directive.

---

### L-14 | 🟠 HIGH | No License, No Trademark Registration

**Location:** Project root, `package.json`, `pubspec.yaml`

**What:** No LICENSE file at project root. No "license" field in `package.json` or `pubspec.yaml`. Source code unlicensed — "all rights reserved" by default but ambiguity exists. "BabyMon" used as brand name with no TM/R symbol or evidence of trademark registration.

**Recommended Action:** Add proprietary license to root. Add `"license": "UNLICENSED"` to package.json. Register "BabyMon" trademark (USPTO/EUIPO). Add TM markings.

---

### L-15 | 🟡 MEDIUM | Over-Broad UGC License for Children's Data

**Location:** `docs/legal/terms-and-conditions.md` section 5.3

**What:** UGC license grants BabyMon "non-exclusive, worldwide, royalty-free, sublicensable, and transferable license to use, reproduce, modify, adapt, display, and distribute your User Content." Extremely broad — "sublicensable" and "transferable" would allow licensing children's photos to third parties. Likely unfair under EU Unfair Contract Terms Directive.

**Recommended Action:** Narrow license grant. Remove "sublicensable" for photo/media. Limit "transferable" to corporate restructuring only. Add geographic limitations. Make revocable upon account deletion.

---

### L-16 | 🔵 LOW | Feedback Clause May Violate EU Moral Rights

**Location:** `terms-and-conditions.md` section 5.4

**What:** Feedback clause grants "perpetual, irrevocable, worldwide, royalty-free license... without compensation or attribution." EU moral rights (droit d'auteur) may require attribution.

**Recommended Action:** Add carve-out for jurisdictions where moral rights apply.

---

### L-17 | 🔴 CRITICAL | False Claim of COPPA/GDPR-K Compliance

**Location:** `settings_screen.dart:872`

**What:** In-app Privacy Policy claims "We comply with COPPA and GDPR-K." This is demonstrably false (see S02 report). Making false claims about regulatory compliance is itself a violation of consumer protection laws (FTC Act Section 5).

**Recommended Action:** Immediately remove COPPA/GDPR-K compliance claim until actual compliance achieved. Replace with neutral statement.

---

### L-18 | 🔴 CRITICAL | No Minimum Age Verification — Contracts Voidable by Minors

**Location:** All auth screens

**What:** Terms require users to be 18+ (section 2.1) but no age verification exists anywhere. 15-year-old parent can create account — any contract (including limitation of liability, arbitration clause, class action waiver) could be voided.

**Recommended Action:** Add mandatory date-of-birth field. Reject users under 18. Consult legal counsel on supporting 13-17 year-old parents with enhanced protections.

---

### L-19 | 🟡 MEDIUM | Arbitration Clause Incomplete and Unenforceable in EU

**Location:** `terms-and-conditions.md` section 11.3-11.5

**What:** Arbitration clause requires AAA binding arbitration but: (a) fee allocation not specified, (b) location unspecified ([CITY, STATE]), (c) no small claims court carve-out, (d) binding arbitration not enforceable in many EU member states.

**Recommended Action:** Specify fee allocation (company pays consumer's share). Add small claims carve-out. Specify video conference option. Add EU/UK carve-out.

---

## Liability Hotspots Map

1. **AI Companion chat** — highest liability: hallucinated medical advice attributed to named experts
2. **Vaccination schedules & screening reminders** — if incorrect, direct health harm
3. **Growth percentiles** — if miscalculated, could mask failure to thrive
4. **Allergy tracking** — if wrong allergen identified, anaphylaxis risk
5. **Co-parent data deletion** — one parent deleting another's records
6. **Photo storage** — children's photos stored indefinitely, accessible via URL
7. **Emergency detection** — AI instructed to detect emergencies but unreliable

---

## Summary Statistics

| Severity | Count |
|---|---|
| 🔴 Critical | 7 |
| 🟠 High | 7 |
| 🟡 Medium | 5 |
| 🔵 Low | 1 |
| **Total** | **20** |
