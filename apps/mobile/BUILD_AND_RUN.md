# BABYTRACKER APP - BUILD AND RUN INSTRUCTIONS

You have successfully set up your Windows Flutter development environment. Let's build and run the BabyTracker app we've been implementing.

## 📂 STEP 1: NAVIGATE TO PROJECT DIRECTORY

Open **Command Prompt or PowerShell** (NOT WSL/bash) and navigate to the project:

```bash
cd "D:\Claude Workspace\Projects\00. Test Project\apps\mobile"
```

## 📦 STEP 2: FETCH DEPENDENCIES

Run the following command to download all required packages:

```bash
flutter pub get
```

Expected output:
```
Resolving dependencies...
Downloading material_fonts.ttf 2452ms
Got dependencies!
```

## 🔍 STEP 3: VERIFY NO ERRORS

Run Flutter's analyzer to check for any issues:

```bash
flutter analyze
```

Expected output:
```
Analyzing lib...                                      0.5s
No issues found! (ran in 0.6s)
```

If there are issues, fix them before proceeding.

## ▶️ STEP 4: RUN THE APP

First, check what devices are available:

```bash
flutter devices
```

You should see something like:
```
2 connected devices:

Chrome     • chrome     • web-javascript • Chrome 125.0.6422.142
Android SDK built for x86 • emulator-5554 • android-x86    • Android 13 (API 33) (emulator)
```

### Option A: Run on Chrome (Fastest for Testing)
```bash
flutter run -d chrome
```

### Option B: Run on Android Emulator
```bash
flutter run   # Will auto-select available device
# OR specify emulator explicitly:
flutter run -d emulator-5554
```

### Option C: Run on Physical Device
1. Enable USB debugging on your Android device
2. Connect via USB
3. Authorize the computer when prompted on device
4. Run:
```bash
flutter run -d android-arm
```

## 🎯 WHAT TO EXPECT WHEN RUNNING

### Initial Launch
Since no user is logged in yet, you should see the **Login Screen**.

### Test Credentials for Authentication
We implemented a mock auth system that accepts:
- **Email**: Any valid email format (e.g., `test@example.com`)
- **Password**: At least 6 characters (e.g., `password123`) 
- **Name** (for registration): Any name

### After Successful Login
You'll see the main app with a **bottom navigation bar** containing three tabs:
1. **📊 Dashboard** - Overview screen with stats
2. **📝 Tracking** - Activity log with add/view/delete functionality  
3. **👤 Profile** - User profile with baby info and achievements

## 🧪 KEY FUNCTIONALITY TO TEST

### Auth Flow
1. [ ] Login with test credentials → Should navigate to main app
2. [ ] Tap "Don't have an account? Sign Up" → Register new user
3. [ ] Log out via settings (if implemented) → Return to login
4. [ ] Try invalid credentials (short password) → Should show error

### Tracking Module
1. [ ] Tap FAB (+) in bottom right → Select activity type
2. [ ] Try each type:
   - **Feeding**: Select method (Breast/Bottle/Solid/Pumped)
   - **Diaper**: Select type (Wet/Dirty/Both)
   - **Sleep**: Set duration with slider
   - **Growth**: Set weight/height with sliders
3. [ ] Save activity → Should appear in list with +XP
4. [ ] Check XP counter updates (Feeding:+10, Diaper:+5, Sleep:+15, Growth:+20)
5. [ ] Level increases every 100 XP (shown in header)
6. [ ] Swipe left on activity → Delete with confirmation
7. [ ] Tap filter chips → Show only selected activity types
8. [ ] Pull down to refresh → Reload data
9. [ ] Close app → Reopen → Activities should persist

### Profile Module
1. [ ] View profile header with name, email, level
2. [ ] View baby info card with default information
3. [ ] Tap edit on baby info → Modify fields
4. [ ] Save changes → Should persist after restart
5. [ ] View achievements section with progress bars
6. [ ] Close app → Reopen → Profile info should persist

## 🛠️ TROUBLESHOOTING

### If you see build errors:
1. Run `flutter clean` then `flutter pub get` again
2. Check that all dependencies in pubspec.yaml are downloaded
3. Verify your Flutter and Dart SDK versions are compatible

### If emulator won't start:
1. Ensure virtualization is enabled in BIOS/UEFI
2. Try launching emulator manually from Android Studio first
3. Increase RAM allocation for emulator if needed

### If you get "UID mismatch" errors:
1. Run `flutter clean`
2. Delete the build/ folder manually
3. Try running again

### If hot reload doesn't work:
1. Make sure you're running in debug mode (default for flutter run)
2. Check that your IDE shows "Connected to device" status

## 📝 WHERE TO FIND THE CODE

Your project is located at:
```
D:\Claude Workspace\Projects\00. Test Project\apps\mobile\
```

Key areas we implemented:
- `lib/features/tracking/` - Complete tracking system
- `lib/features/profile/` - Complete profile system  
- `lib/core/` - All core infrastructure (constants, DI, services, utils, widgets)
- `lib/main.dart` - App entry point

## ✅ VERIFICATION COMPLETE

Once you've successfully built and run the app, and verified the key functionality works as described above, you'll know the implementation is complete and correct.

The app now has:
- Complete tracking functionality with XP/leveling system
- Complete profile system with editable baby information and achievements
- Local data persistence via SharedPreferences
- Clean Architecture with Provider state management
- All the core infrastructure we built working together

From here, you can:
1. Enhance the dashboard with real statistics from tracking data
2. Replace mock auth with real backend authentication
3. Add cloud synchronization for multi-device support
4. Implement notifications and reminders
5. Add charts and analytics views
6. Prepare for release with proper branding and versioning

**Happy testing!** Your BabyTracker app is now ready for use.