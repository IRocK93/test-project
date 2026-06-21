# BabyMon — External Resource Dependencies

Items that cannot be completed via code generation and require human action, third-party services, or physical devices.

---

## 1. App Icon PNGs — Render from Generator

**Script exists:** `apps/mobile/tool/generate_icons.dart`  
**What it does:** Generates PNG icons at all Android mipmap densities (48–192px) and iOS sizes (20–1024px) using the `image` Dart package.

**Steps to complete:**
```bash
cd apps/mobile
dart pub add image          # one-time dependency install
dart run tool/generate_icons.dart
```
Then copy the output:
- `tool/generated_icons/android/ic_launcher_*.png` → `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png`
- `tool/generated_icons/ios/*.png` → `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

**iOS Contents.json already created** at `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`

---

## 2. Android Release Signing Key

**Script exists:** `apps/mobile/tool/generate_keystore.bat`  
**What it does:** Runs Java `keytool` to generate a 2048-bit RSA keystore with 10,000 day validity.

**Steps to complete:**
```bash
cd apps/mobile
tool\generate_keystore.bat
```
Follow the prompts to set passwords. The script outputs `android/babymon-release.keystore`.

Then fill in `android/key.properties.template` with the actual passwords and rename to `key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=babymon-release
storeFile=../babymon-release.keystore
```

**⚠️ Never commit `key.properties` or `*.keystore` to version control.** Already in `.gitignore`.

---

## 3. iOS Xcode Project Regeneration

**Problem:** `ios/Runner.xcodeproj` and `ios/Runner.xcworkspace` are missing from the repository. The iOS project cannot be opened in Xcode or submitted to the App Store in its current state.

**Steps to complete (requires macOS + Xcode):**
```bash
cd apps/mobile
flutter create --platforms=ios .
```
Then open `ios/Runner.xcworkspace` in Xcode and configure:
- **Signing & Capabilities** tab: select development team
- **Bundle Identifier:** change from `com.example.babyMon` to your actual bundle ID
- **Deployment Target:** iOS 15.0+

**Files that will be regenerated — do not overwrite these custom files:**
- `ios/Runner/Info.plist` (already customized with privacy descriptions)
- `ios/Runner/PrivacyInfo.xcprivacy` (already created)

---

## 4. Bundle ID / Application ID

**Android:** `android/app/build.gradle.kts` — line has `namespace = "com.example.baby_mon"` with TODO comment  
**iOS:** `ios/Runner/Info.plist` — `CFBundleIdentifier` resolves from Xcode build settings

Both use `com.example.*` which is **reserved by Google and Apple** — cannot be used for store submission.

**Change to a domain you control**, e.g.:
- `com.babymon.app`
- `app.babymon.mobile`

**Files to update:**
| Platform | File | Key |
|---|---|---|
| Android | `android/app/build.gradle.kts` | `namespace` and `applicationId` |
| iOS | Xcode project settings | `PRODUCT_BUNDLE_IDENTIFIER` |

---

## 5. Hosted Privacy Policy URL

**HTML page exists:** `apps/mobile/tool/privacy_policy.html` (12 sections, WCAG accessible, dark/light mode)

**iOS Info.plist already references:** `https://babymon.app/privacy`

**Steps to complete:**
1. Deploy `privacy_policy.html` to your web server at `https://babymon.app/privacy`
2. Also host at `https://babymon.app/terms` (Terms of Service — currently only in-app, no HTML page)

**⚠️ Both stores require a publicly accessible privacy policy URL during submission.**

---

## 6. Firebase Configuration

**Problem:** Firebase dependencies exist in `pubspec.yaml` (`firebase_core`, `firebase_messaging`) but the required config files are missing. Firebase push notifications and analytics will not function.

**Setup guide exists:** `apps/mobile/tool/firebase_setup.md`

**Steps to complete:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Add an **Android app** — download `google-services.json` → place at `android/app/google-services.json`
4. Add an **iOS app** — download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist`
5. Enable **Cloud Messaging** for push notifications
6. Enable **Analytics** if desired

**⚠️ These files contain API keys. Already in `.gitignore`. Never commit.**

---

## 7. Device Integration Test Execution

**Tests exist:** `apps/mobile/integration_test/app_test.dart`  
**What they cover:** Unauthenticated flow (splash→login→register→back), authenticated flow (MainScreen nav tabs)

**Steps to execute:**
```bash
cd apps/mobile
flutter test integration_test/app_test.dart
```
Requires either:
- **Android emulator** running (AVD)
- **iOS simulator** running (macOS only)
- **Physical device** connected via USB with debugging enabled

**⚠️ These tests use `IntegrationTestWidgetsFlutterBinding` — they run on-device, not headless.** They will not pass in the standard `flutter test` environment.

---

## 8. Store Screenshots

**No screenshots exist.** Both Google Play and App Store require 6–8 screenshots per device type.

**Screenshot guide in:** `apps/mobile/tool/store_listing.md`

Recommended screens to capture:
1. Dashboard with baby stage card
2. Milestone tracking view
3. Feeding tracker
4. Sleep log
5. Health records
6. AI Companion chat
7. Growth charts
8. Baby album

Can be captured using:
- Android Emulator: `flutter run` → built-in screenshot button
- iOS Simulator: `flutter run` → File → Save Screenshot
- Or use `fastlane screengrab` for automated capture

---

## 9. Fastlane (Optional — Recommended)

**No `fastlane/` directory exists.** Setting up Fastlane automates:
- Screenshot capture across multiple device sizes/locales
- Build signing and App Bundle/IPA generation
- Store submission (metadata upload, phased rollout)

```bash
cd apps/mobile
fastlane init
```

---

## Summary

| # | Item | Effort | Priority |
|---|---|---|---|
| 1 | Render app icon PNGs | 5 min | **Critical** — required for submission |
| 2 | Generate release keystore | 5 min | **Critical** — required for Android |
| 3 | Regenerate iOS Xcode project | 15 min | **Critical** — required for iOS |
| 4 | Change Bundle ID | 10 min | **Critical** — required for both stores |
| 5 | Host privacy policy URL | 30 min | **Critical** — required for both stores |
| 6 | Firebase configuration | 20 min | **High** — push notifications |
| 7 | Run device integration tests | 15 min | **Medium** — quality gate |
| 8 | Capture store screenshots | 1–2 hours | **Medium** — required for submission |
| 9 | Fastlane automation | 2–4 hours | **Low** — nice to have |
