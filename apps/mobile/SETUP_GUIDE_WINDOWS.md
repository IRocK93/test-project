# SETUP GUIDE: Building BabyTracker App in Windows Environment

Due to WSL/Flutter CLI compatibility issues encountered in this environment, here's the recommended setup for Windows to build and test the BabyTracker mobile app.

## 🛠️ REQUIRED TOOLS FOR WINDOWS

### 1. Flutter SDK
- **Download**: https://flutter.dev/docs/get-started/install/windows
- **Installation**: Extract zip to `C:\src\flutter` (recommended path)
- **Add to PATH**: 
  - `C:\src\flutter\bin`
  - `C:\src\flutter\bin\cache\dart-sdk`

### 2. Android Development Setup
**Option A: Android Studio (Recommended)**
- Download: https://developer.android.com/studio
- During install, select:
  - Android Studio
  - Android Virtual Device
  - Android SDK Platform
  - Android SDK Build-Tools
  - Android Emulator

**Option B: Command Line Tools Only**
- Download: https://developer.android.com/studio#commandools
- Install via: `sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2" "emulator"`

### 3. Git for Windows
- Download: https://git-scm.com/download/win
- During install: 
  - Select "Use Git from Windows Command Prompt"
  - Checkout as-is, commit Unix-style line endings (important for Flutter)

### 4. IDE (Choose One)
**VS Code (Lightweight)**
- Download: https://code.visualstudio.com/
- Extensions to install:
  - Flutter
  - Dart

**Android Studio (Full-featured)**
- Already includes Flutter/Dart plugin setup wizard
- Or install plugins manually: Preferences > Plugins > Marketplace > search "Flutter"

### 5. Optional but Helpful
- **Physical Android Device** + USB cable (for real device testing)
- **Postman** - For API testing if integrating with backend
- **GitHub Desktop** - If preferring GUI for Git

## ✅ VERIFICATION STEPS

After installation, open **Command Prompt or PowerShell** (NOT WSL bash) and run:

```bash
# Check Flutter
flutter --version
# Should show Flutter version, channel, etc.

# Check Android tooling
flutter doctor -v
# Should show [✓] for Flutter, Android toolchain, Chrome, VS Code/Android Studio

# Accept Android licenses (if prompted)
flutter doctor --android-licenses
```

## 📱 GETTING THE APP RUNNING

1. **Clone/Get the Code**: 
   - Place the BabyTracker code in a Windows-accessible folder (e.g., `C:\projects\baby_tracker`)

2. **Fetch Dependencies**:
   ```bash
   cd C:\projects\baby_tracker
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   # List available devices
   flutter devices
   
   # Run on emulator or device
   flutter run
   ```

## 🔧 TROUBLESHOOTING COMMON ISSUES

### If you see "Failed to find Dart SDK" error:
- Ensure `C:\src\flutter\bin\cache\dart-sdk\bin` is in your PATH
- Restart terminal after installing Flutter

### If Android emulator won't start:
- Enable Virtualization in BIOS/UEFI settings
- Disable Hyper-V if using VMware/VirtualBox (or use Hyper-V emulator)
- Increase RAM allocation for emulator in Android Studio settings

### If you get line ending errors:
- Ensure Git is configured correctly: `git config --global core.autocrlf true`
- Re-clone the repository after setting this

### If flutter doctor shows missing Android licenses:
- Run: `flutter doctor --android-licenses` and accept all

## 📁 PROJECT STRUCTURE VERIFICATION

After `flutter pub get`, your `lib/` directory should contain:
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── di/
│   │   └── service_locator.dart
│   ├── services/
│   │   └── local_storage_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── loading_widget.dart
├── features/
│   ├── auth/...
│   ├── dashboard/...
│   ├── feeding/...
│   ├── health/...
│   ├── journal/...
│   ├── milestones/...
│   ├── tracking/...  ← Fully implemented
│   └── profile/...   ← Fully implemented
└── presentation/
    ├── providers/
    │   └── auth_provider.dart
    ├── router/
    │   └── app_router.dart
    └── screens/
        ├── auth/...
        ├── main/...  ← Unified navigation screens
        └── ...
```

## 🎯 EXPECTED FUNCTIONALITY WHEN RUNNING

Once built successfully, you should be able to:
1. See login/register screens on first launch
2. Log in with test credentials (any email + 6+ char password)
3. Navigate between Dashboard, Tracking, and Profile tabs
4. In Tracking:
   - Add activities (feeding, diaper, sleep, growth)
   - Filter by activity type
   - Swipe to delete activities
   - See XP and level updates
5. In Profile:
   - View user information
   - Edit baby information
   - See achievements with progress bars
6. Data persists between app restarts (via local storage)

## 📝 NOTES ON THIS SPECIFIC CODEBASE

- **Authentication**: Uses simulated login (any email with password ≥6 chars works)
- **Data Persistence**: All tracking/profile data saved locally via SharedPreferences
- **XP System**: 
  - Feeding: +10 XP
  - Diaper: +5 XP  
  - Sleep: +15 XP
  - Growth: +20 XP
- **Leveling**: Every 100 XP = Level up (starts at Level 1)
- **Architecture**: Clean Architecture with Provider state management
- **Dependencies**: Uses Flutter Riverpod, GetIt, SharedPreferences, intl

## 🚨 IF YOU STILL ENCOUNTER ISSUES

1. **Delete and reconnect**: Sometimes IDE caches cause issues - restart IDE
2. **Flutter clean**: Run `flutter clean` then `flutter pub get` again
3. **Check Dart SDK**: Ensure `dart --version` works from command line
4. **Verify git settings**: `git config --global core.autocrlf` should be `true`

This setup will give you a fully functional development environment to build, test, and iterate on the BabyTracker mobile app. The code follows Flutter best practices with Clean Architecture, proper state management, and local data persistence - ready for extension with real backend APIs when needed.