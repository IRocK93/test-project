# Data Processing Agreement (DPA) — BabyMon

**Version:** 1.0
**Effective Date:** [INSERT DATE]
**Between:** [COMPANY LEGAL NAME] ("Controller") and Sub-processor ("Processor")

---

This Data Processing Agreement forms part of the Master Services Agreement between BabyMon and each sub-processor listed below. It complies with GDPR Art. 28, UK GDPR, and CCPA requirements.

## 1. Definitions

- **Controller**: BabyMon / [COMPANY LEGAL NAME] — determines the purposes and means of processing personal data
- **Processor**: The sub-processor receiving personal data for processing on behalf of the Controller
- **Personal Data**: Any information relating to an identified or identifiable natural person
- **Special Category Data**: Health data, genetic data, biometric data (GDPR Art. 9)
- **Data Subject**: The individual to whom the personal data relates

## 2. Sub-processors and Data Categories

| Processor | Service | Personal Data Processed | Special Category? | Location |
|-----------|---------|------------------------|-------------------|----------|
| Neon.tech | Database hosting | All application data (user accounts, baby profiles, health records, developmental data, media metadata) | Yes (child health data) | US (us-east-1) |
| Amazon Web Services (S3) | Media storage | Photos and videos of children | Yes (child photographs) | US (us-east-1) |
| Stripe, Inc. | Payment processing | Email, subscription status, customer ID | No | Global |
| Twilio Inc. (SendGrid) | Transactional email | Email address, user name, verification links, invitation content | No | US |
| Google LLC (Firebase) | Push notifications | FCM device token, platform (iOS/Android) | No | US |
| Google LLC (OAuth) | Social login | Email, profile name (if user chooses Google Sign-In) | No | Global |
| Apple Inc. (Sign-In) | Social login | Email, full name (if user chooses Sign in with Apple) | No | Global |
| Meta Platforms (Facebook) | Social login | Email, public profile (if user chooses Facebook Login) | No | Global |
| Railway Corp. | Application hosting | All application data in transit | Yes (transient) | US |
| Functional Software (Sentry) | Error tracking | Error data, IP address, user agent (if configured) | No | US |

## 3. Processor Obligations

The Processor agrees to:

### 3.1 Processing Limitations
- Process personal data only on documented instructions from the Controller
- Not use personal data for any purpose other than providing the contracted service
- Not sell, rent, or share personal data with third parties except as authorized

### 3.2 Confidentiality
- Ensure persons authorized to process personal data are bound by confidentiality obligations
- Restrict access to personal data to employees who need it to perform the service

### 3.3 Security Measures
- Implement appropriate technical and organizational measures (TOMs) including:
  - Encryption in transit (TLS 1.2+) and at rest (AES-256 or equivalent)
  - Access controls and authentication
  - Regular security testing and vulnerability scanning
  - Incident response procedures
  - Business continuity and disaster recovery plans

### 3.4 Sub-processing
- Not engage any sub-processor without prior written authorization from the Controller
- Flow down equivalent data protection obligations to any authorized sub-processor
- Remain fully liable for sub-processor compliance

### 3.5 Data Subject Rights
- Assist the Controller in responding to data subject requests (access, rectification, erasure, portability)
- Notify the Controller within 48 hours of receiving a data subject request directly

### 3.6 Breach Notification
- Notify the Controller without undue delay (within 24 hours) of becoming aware of a personal data breach
- Provide: nature of breach, categories and approximate number of data subjects affected, likely consequences, measures taken or proposed
- Cooperate with the Controller's investigation and notification obligations

### 3.7 Data Protection Impact Assessment
- Assist the Controller in conducting DPIAs and prior consultations with supervisory authorities

### 3.8 Audit Rights
- Make available all information necessary to demonstrate compliance
- Allow and contribute to audits, including inspections, conducted by the Controller or an authorized auditor
- Provide compliance certifications (SOC 2, ISO 27001) upon request

### 3.9 Deletion or Return
- At the Controller's choice, delete or return all personal data after the end of service provision
- Delete existing copies unless EU or Member State law requires storage

## 4. Controller Obligations

The Controller agrees to:

- Ensure lawful basis for processing (consent, contract, legitimate interest)
- Provide transparent notice to data subjects (Privacy Policy)
- Honor data subject rights requests
- Notify the Processor of any changes to processing instructions
- Conduct due diligence on Processor security measures

## 5. International Transfers

For transfers of EEA/UK personal data to the US:

- The Processor maintains Standard Contractual Clauses (SCCs) as adopted by the European Commission
- The Processor conducts and documents Transfer Impact Assessments (TIAs)
- The Processor implements supplementary measures where TIAs identify risks

## 6. Liability and Indemnification

Each party's liability arising from this DPA is subject to the liability cap in the Master Services Agreement, except where superseded by applicable data protection law.

## 7. Term and Termination

This DPA remains in effect for the duration of the Master Services Agreement. Provisions related to confidentiality, data deletion, and audit rights survive termination.

## 8. Governing Law

This DPA is governed by the law specified in the Master Services Agreement. For data subjects in the EEA, the laws of the data subject's member state also apply.

## 9. Execution

This DPA is incorporated by reference into the Master Services Agreement with each Processor listed in Section 2. Each Processor's acceptance of the Master Services Agreement constitutes acceptance of this DPA.

**Controller:**
[COMPANY LEGAL NAME]
By: ___________________________
Name: _________________________
Title: _________________________
Date: _________________________

---

*This DPA template is based on GDPR Art. 28 requirements. Execute individually with each processor before processing personal data. Review by qualified privacy counsel required.*
