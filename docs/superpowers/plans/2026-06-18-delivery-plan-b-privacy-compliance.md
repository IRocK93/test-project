# Delivery Plan B: Privacy Compliance Foundation

> **📋 Historical plan — pre-fix snapshot (June 18, 2026).** All findings referenced here were addressed in the v2 remediation waves and consolidated into the canonical tracker: [`../../review-v4/ROADMAP.md`](../../review-v4/ROADMAP.md). For pre-fix review content that this plan cites (S02, S03), see [`../../_archive/old_docs/reviews_v2_jun2026/`](../../_archive/old_docs/reviews_v2_jun2026/).

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Make BabyMon pass basic COPPA/GDPR/CCPA registration requirements — age gate, consent checkboxes, Terms/Privacy acceptance with audit trail, and fix false compliance claims.

**Architecture:** Add date-of-birth field to User model and registration flow, add consent tracking to database, record acceptance timestamps, and replace false COPPA/GDPR-K claim. Build the minimum viable consent system required for a soft launch.

**Tech Stack:** NestJS, Prisma, Flutter/Dart, PostgreSQL

**Related Reports:** S02 (PC01-PC04), S03 (L-10, L-11, L-17) — *v2 finding IDs (now archived). For resolution status, see [review-v4/ROADMAP.md](../../review-v4/ROADMAP.md).*

---

## Phase B-1: Backend — Registration Age Gate + Consent

### Task B-1: Add dateOfBirth and consent fields to User model

**Files:**
- Modify: `apps/api/prisma/schema.prisma`
- Create migration

- [ ] **Step 1: Add fields to User model in schema.prisma**

Add to the User model (after `deletedAt`):
```prisma
dateOfBirth       DateTime?
tosAcceptedAt     DateTime?
tosVersion        String?
privacyAcceptedAt DateTime?
privacyVersion    String?
consentToDataProcessing Boolean @default(false)
consentToPhotos    Boolean @default(false)
marketingConsent   Boolean @default(false)
```

- [ ] **Step 2: Generate and apply migration**

```bash
cd apps/api && npx prisma migrate dev --name add_user_age_and_consent
```

Expected: Migration created without errors.

---

### Task B-2: Add age validation to RegisterDto

**Files:**
- Modify: `apps/api/src/auth/dto/auth.dto.ts`

- [ ] **Step 1: Add dateOfBirth field to RegisterDto**

After the `name` field, add:
```typescript
@ApiProperty({ description: 'Date of birth for age verification' })
@IsDate()
@Type(() => Date)
@Transform(({ value }) => new Date(value))
dateOfBirth!: Date;
```

- [ ] **Step 2: Add consent fields**

```typescript
@ApiProperty({ description: 'User accepted Terms of Service' })
@IsBoolean()
tosAccepted!: boolean;

@ApiProperty({ description: 'User accepted Privacy Policy' })
@IsBoolean()
privacyAccepted!: boolean;

@ApiProperty({ description: 'User consented to data processing including child health data' })
@IsBoolean()
consentToDataProcessing!: boolean;
```

- [ ] **Step 3: Add age validation in auth.service.ts register method**

At the top of the `register` method in `apps/api/src/auth/auth.service.ts`, add:
```typescript
const today = new Date();
const age = today.getFullYear() - dto.dateOfBirth.getFullYear();
const monthDiff = today.getMonth() - dto.dateOfBirth.getMonth();

const exactAge = monthDiff < 0 || (monthDiff === 0 && today.getDate() < dto.dateOfBirth.getDate())
  ? age - 1
  : age;

if (exactAge < 18) {
  throw new BadRequestException('You must be at least 18 years old to create an account');
}

if (exactAge > 120) {
  throw new BadRequestException('Invalid date of birth');
}
```

- [ ] **Step 4: Store consent data during registration**

In the User create call within the `register` method, add the consent fields:
```typescript
data: {
  email: dto.email,
  passwordHash: hashedPassword,
  name: dto.name,
  dateOfBirth: dto.dateOfBirth,
  tosAcceptedAt: dto.tosAccepted ? new Date() : null,
  tosVersion: dto.tosAccepted ? '1.0' : null,
  privacyAcceptedAt: dto.privacyAccepted ? new Date() : null,
  privacyVersion: dto.privacyAccepted ? '1.0' : null,
  consentToDataProcessing: dto.consentToDataProcessing,
  // ... rest of existing fields
}
```

- [ ] **Step 5: Commit**

```bash
git add apps/api/prisma/ apps/api/src/auth/
git commit -m "feat(compliance): add age gate and consent tracking to registration"
```

---

## Phase B-2: Mobile — Age Gate UI

### Task B-3: Add date of birth and consent to register screen

**Files:**
- Modify: `apps/mobile/lib/features/auth/presentation/screens/register_screen.dart`
- Modify: `apps/api/src/auth/dto/auth.dto.ts` (already done)

- [ ] **Step 1: Add dateOfBirth field to registration form**

In `register_screen.dart`, add a date picker field before the email field:
```dart
GestureDetector(
  onTap: () async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );
    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  },
  child: AbsorbPointer(
    child: TextFormField(
      controller: TextEditingController(
        text: _dateOfBirth != null
          ? DateFormat.yMMMMd().format(_dateOfBirth!)
          : '',
      ),
      decoration: const InputDecoration(
        labelText: 'Date of Birth',
        hintText: 'You must be 18 or older',
        prefixIcon: Icon(PhosphorIconsLight.calendar),
      ),
      validator: (_) => _dateOfBirth == null ? 'Date of birth is required' : null,
    ),
  ),
),
```

- [ ] **Step 2: Add consent checkboxes**

After the password confirmation field, add:
```dart
CheckboxListTile(
  value: _tosAccepted,
  onChanged: (v) => setState(() => _tosAccepted = v ?? false),
  title: RichText(
    text: TextSpan(
      text: 'I am at least 18 years old and agree to the ',
      style: DefaultTextStyle.of(context).style,
      children: [
        WidgetSpan(child: GestureDetector(
          onTap: () => /* open ToS URL */,
          child: Text('Terms of Service', style: TextStyle(color: AppColors.primary)),
        )),
      ],
    ),
  ),
  controlAffinity: ListTileControlAffinity.leading,
),
CheckboxListTile(
  value: _privacyAccepted,
  onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
  title: RichText(
    text: TextSpan(
      text: 'I agree to the ',
      style: DefaultTextStyle.of(context).style,
      children: [
        WidgetSpan(child: GestureDetector(
          onTap: () => /* open Privacy Policy URL */,
          child: Text('Privacy Policy', style: TextStyle(color: AppColors.primary)),
        )),
      ],
    ),
  ),
  controlAffinity: ListTileControlAffinity.leading,
),
CheckboxListTile(
  value: _consentDataProcessing,
  onChanged: (v) => setState(() => _consentDataProcessing = v ?? false),
  title: const Text('I consent to the processing of my child\'s health and development data as described in the Privacy Policy'),
  controlAffinity: ListTileControlAffinity.leading,
),
```

- [ ] **Step 3: Add validation — all three checkboxes required**

In the form validator, add:
```dart
if (!_tosAccepted) return 'You must agree to the Terms of Service';
if (!_privacyAccepted) return 'You must agree to the Privacy Policy';
if (!_consentDataProcessing) return 'You must consent to data processing';
```

- [ ] **Step 4: Disable register button until age 18+ and all consents given**

```dart
final is18Plus = _dateOfBirth != null && 
  DateTime.now().difference(_dateOfBirth!).inDays >= 365 * 18;
final canRegister = is18Plus && _tosAccepted && _privacyAccepted && _consentDataProcessing;
```

- [ ] **Step 5: Pass new fields to register API call**

Update the `_register()` method to send `dateOfBirth`, `tosAccepted`, `privacyAccepted`, `consentToDataProcessing`.

- [ ] **Step 6: Commit**

```bash
git add apps/mobile/lib/features/auth/
git commit -m "feat(compliance): add age gate and consent checkboxes to registration UI"
```

---

## Phase B-3: Legal Claims Fix

### Task B-4: Remove false COPPA/GDPR-K compliance claim

**Files:**
- Modify: `apps/mobile/lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 1: Find and replace the false claim**

Search for "We comply with COPPA and GDPR-K" in `settings_screen.dart`. Replace with:
```dart
'We are committed to protecting children\'s privacy and are working toward full compliance with applicable privacy regulations.',
```

- [ ] **Step 2: Commit**

```bash
git add apps/mobile/lib/features/settings/
git commit -m "fix(compliance): remove false COPPA/GDPR-K compliance claim

The statement 'We comply with COPPA and GDPR-K' was demonstrably false.
Replaced with a neutral commitment statement until actual compliance is
achieved."
```

---

## Phase B-4: Legal Document Hosting

### Task B-5: Create hosted Privacy Policy and Terms pages

**Files:**
- Create: `apps/api/src/legal/legal.controller.ts`
- Create: `apps/api/src/legal/legal.module.ts`
- Modify: `apps/api/src/app.module.ts`

- [ ] **Step 1: Create legal controller**

```typescript
import { Controller, Get } from '@nestjs/common';
import { Public } from '../common/decorators/public.decorator';

@Controller('legal')
export class LegalController {
  @Public()
  @Get('privacy')
  getPrivacyPolicy() {
    return {
      title: 'BabyMon Privacy Policy',
      lastUpdated: '2026-06-18',
      effectiveDate: '2026-06-18',
      sections: [
        { heading: '1. Information We Collect', body: '...' },
        // Full policy content from docs/legal/
      ],
    };
  }

  @Public()
  @Get('terms')
  getTermsOfService() {
    return {
      title: 'BabyMon Terms of Service',
      lastUpdated: '2026-06-18',
      effectiveDate: '2026-06-18',
      sections: [
        // Full ToS content from docs/legal/
      ],
    };
  }
}
```

- [ ] **Step 2: Create legal module and register in app.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { LegalController } from './legal.controller';

@Module({
  controllers: [LegalController],
})
export class LegalModule {}
```

Add `LegalModule` to `app.module.ts` imports.

- [ ] **Step 3: Update registration flow to link to hosted URLs**

Update mobile register screen to open `{APP_URL}/api/legal/privacy` and `{APP_URL}/api/legal/terms` instead of hardcoded text.

- [ ] **Step 4: Commit**

```bash
git add apps/api/src/legal/ apps/api/src/app.module.ts apps/mobile/
git commit -m "feat(compliance): add hosted Privacy Policy and Terms endpoints"
```

---

**Estimated time:** 2-3 days for a developer with both backend and mobile access.
