# Android Release — Founder Backup Checklist

> **Audience:** the non-technical founder of BabyMon.
>
> **This document explains what you MUST save offline before submitting the
> first build to Google Play.** Without the keystore file + its password,
> no future version of the app can ever be published.

---

## What changed in this commit

| Change | Path | Why |
|--------|------|-----|
| Permanent applicationId + namespace switch | `apps/mobile/android/app/build.gradle.kts` | Lets the app publish on Play Store as `com.babymon.app` (was `com.example.baby_mon`). **Once uploaded, cannot change.** |
| Release-keystore wiring | `apps/mobile/android/app/build.gradle.kts` | Tells Gradle how to sign the release `.aab` using `android/key.properties`. |
| Kotlin source folder move | `android/app/src/main/kotlin/com/example/baby_mon/` → `com/babymon/app/` | Required so the Application + Activity classes live in the same package as `applicationId`. |
| Package declaration update | `android/app/src/main/kotlin/com/babymon/app/MainActivity.kt` | `package com.babymon.app` (was `com.example.baby_mon`). |

## What got generated locally (NOT committed)

| File | Why it is secret | Where it currently lives |
|------|------------------|---------------------------|
| `apps/mobile/android/upload-keystore.jks` | This is the file that signs every release of your app. Google Play checks the SHA-1 fingerprint against every update for the lifetime of the listing. If you lose it, you cannot publish another update. | Local disk only. Already covered by `apps/mobile/android/.gitignore` (`**/*.jks`). |
| `apps/mobile/android/key.properties` | Contains the keystore password and key password. | Local disk only. Already covered by `apps/mobile/android/.gitignore` (`key.properties`). |

Keystore + password are **permanently** generated in the working tree. They
are NOT pushed to git. If you re-clone on a second machine, you must
restore them from your backup before building.

---

## BACK UP THESE NOW (don't skip)

Open your password manager (1Password, Bitwarden, etc.) and create a new
entry titled **"BabyMon Android release keystore"**. Fill in:

```
Title:        BabyMon Android release keystore
Keystore file: <the path of upload-keystore.jks on your disk>
Key alias:     upload
DName:         CN=BabyMon, OU=Mobile, O=BabyMon, L=San Francisco, S=California, C=US
Algorithm:     RSA 2048
Validity:      10000 days from 2026-07-03
Type:          JKS (matches the .jks file extension)
Store password:    <24-char random base64 — same as key password>
Key password:      <24-char random base64 — same as store password>
(Store and key passwords are intentionally identical for simplicity; if you
ever change one, change both, then rebuild.)
```

You should also save the password shown at the bottom of the
`bash generate-keystore` output. If you did not see it, you can recover
the password any time by reading `apps/mobile/android/key.properties`
on your machine.

> **Optional best practice:** also save a copy of `upload-keystore.jks`
> itself to a second cloud (Backblaze B2 / Cloudflare R2 / Google Drive
> / an offline USB stick). Treat the keystore the way a certificate
> authority treats a private CA key — never lose it.

---

## How to build the signed .aab (when you're ready)

From `apps/mobile/` (the Flutter mobile directory):

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The signed artifact will appear at:

```
apps/mobile/build/app/outputs/bundle/release/app-release.aab
```

> The first build will take 5–15 minutes because Flutter compiles every
> Dart package and the native Android shell. Subsequent builds are 30s–2min.

If `flutter clean` complains about anything, ignore it and run the next
step.

### Verify before upload

```bash
"C:\Program Files\Java\jdk-26.0.1\bin\keytool.exe" \
  -list -v -keystore apps/mobile/android/upload-keystore.jks \
  -storepass "$(grep storePassword apps/mobile/android/key.properties | cut -d= -f2)"
```

The output should match the DName you backed up. If it does not, stop and
contact support — DO NOT upload a mismatched keystore.

### Upload to Google Play Console

1. Go to <https://play.google.com/console>.
2. Create app → name "BabyMon" → default language → Baby tracking → App.
3. Under **Release → Internal testing**, upload
   `apps/mobile/build/app/outputs/bundle/release/app-release.aab`.
4. Fill in:
   - **Privacy policy URL:** the URL where you host
     `apps/mobile/tool/privacy_policy.html` once you've replaced the
     `[COMPANY LEGAL NAME]` placeholders (suggested host:
     `https://babymon.app/privacy`).
   - **App category:** Parenting.
   - **Target audience:** Adult (the parent operates the app on
     behalf of the child).
   - **Content rating questionnaire:** answer per the Parenting
     category — no violence, no mature content, no ads by default.
5. **Data safety form** — declare that the App: registers an account
   with email + password; processes user-entered data about a child
   (baby); uploads photos to AWS S3; sends push notifications via
   Firebase; processes subscription payments via Stripe; has an
   optional on-device AI Companion that runs locally. All answers are
   informed by `apps/mobile/tool/privacy_policy.html` and
   `apps/mobile/tool/eula.html`.

---

## If you ever lose the keystore

You cannot.

This is the single point of failure for the BabyMon Android listing.
Most "lost my Play Store keystore" stories end with the founder having
to publish a brand-new app under a brand-new applicationId, losing all
installed users and reviews. Spend 10 minutes backing it up now.

---

## If you want to re-mint with your real company name

If you've since incorporated as "BabyMon, Inc." (or any other legal
name), you can re-mint the keystore with the correct DName:

```bash
"C:\Program Files\Java\jdk-26.0.1\bin\keytool.exe" -genkey -noprompt \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=BabyMon Inc., OU=Mobile, O=BabyMon Inc., L=New York, S=NY, C=US" \
  -keystore apps/mobile/android/upload-keystore.jks \
  -storepass <NEW_PASSWORD> \
  -keypass <NEW_PASSWORD>
```

Only do this **before** the first Play Store upload. After upload, the
keystore is locked.

---

## If you ever lose the keystore OR key.properties (but not both)

If only `key.properties` is gone but `upload-keystore.jks` is intact, the
next regen would mismatch — so you must delete BOTH files and re-run
`apps/mobile/tool/regen-release-keystore.sh` together to re-mint with a
new password. The keystore file content will be totally different and
**the new keystore will NOT match any previously uploaded `.aab`** — so
this path is only safe BEFORE your first Play Store upload.

The script:

```bash
bash apps/mobile/tool/regen-release-keystore.sh
```

It will print a clear warning if either file already exists, then
require a manual yes-confirmation before deleting anything.

## AFTER first Play Store upload: re-run `flutterfire configure`

The applicationId change from `com.example.baby_mon` to `com.babymon.app`
breaks the auto-generated file `apps/mobile/lib/firebase_options.dart`.
When you add Firebase / FCM:

1. **First**, add the new Android app to your Firebase project:
   - Open <https://console.firebase.google.com/>
   - Select your project → ⚙ Project settings → Your apps → **Add app**
   - Choose **Android**.
   - **Application ID: type `com.babymon.app`** exactly (must match the
     `applicationId` in `apps/mobile/android/app/build.gradle.kts`).
   - Download the resulting `google-services.json` and place it at
     `apps/mobile/android/app/google-services.json`.
2. **Then**, regenerate the Dart-side config:
   ```bash
   cd apps/mobile
   npx flutterfire configure --project=<your-firebase-project-id>
   ```
   This re-generates `apps/mobile/lib/firebase_options.dart` with the
   new Android `applicationId` baked into the `messagingSenderId` /
   `gcm_sender_id` fields. Without this re-run, **push notifications
   will silently fail on Android** (Firebase rejects inbound FCM
   messages keyed to the old `com.example.baby_mon`).

## Where to look for things in this codebase

- `apps/mobile/android/app/build.gradle.kts` — applicationId + signingConfig
- `apps/mobile/android/app/src/main/kotlin/com/babymon/app/MainActivity.kt` — Flutter host activity
- `apps/mobile/android/upload-keystore.jks` — **the release signing key (SECRET)**
- `apps/mobile/android/key.properties` — **keystore password (SECRET)**
- `apps/mobile/tool/privacy_policy.html` — Google Play data safety policy URL
- `apps/mobile/tool/eula.html` — In-app license reference
- `apps/mobile/build/app/outputs/bundle/release/app-release.aab` — **the signed upload artifact**
