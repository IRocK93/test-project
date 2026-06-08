# BUILD AND RUN INSTRUCTIONS FOR BABYTRACKER APP

You have successfully set up your Windows Flutter development environment. Now let's build and run the BabyTracker app we've been implementing.

## 📂 STEP 1: NAVIGATE TO PROJECT DIRECTORY

Open **Command Prompt or PowerShell** (NOT WSL/bash) and navigate to the project:

```bash
cd "/mnt/d/Claude Workspace/Projects/00. Test Project/apps/mobile"
```

Note: Since you're in Windows Command Prompt/PowerShell, you can also access this via:
```bash
cd "D:\Claude Workspace\Projects\00. Test Project\apps\mobile"
```

## 📦 STEP 2: FETCH DEPENDENCIES

Run the following command to download all required packages:

```bash
flutter pub get
```

You should see output similar to:
```
Resolving dependencies...
Downloading...
Got dependencies!
```

## 🔍 STEP 3: VERIFY NO ERRORS

Run Flutter's analyzer to check for any issues:

```bash
flutter analyze
```

You should see:
```
Analyzing lib...                                      0.5s
No issues found! (ran in 0.6s)
```

If there are any issues, they will be listed here for you to fix.

## ▶️ STEP 4: RUN THE APP

First, check what devices are available:

```bash
flutter devices
```

You should see at least:
- Chrome web browser
- An Android emulator (if you have one set up)
- Possibly a physical device if connected via USB

Now run the app on your preferred device:

### For Chrome (easiest for testing):
```bash
flutter run -d chrome
```

### For Android emulator:
```bash
flutter run   # Will auto-select available device
# OR specify emulator:
flutter run -d emulator-5554
```

### For physical device:
```bash
flutter run -d android-arm   # or your device ID
```

## 🎯 EXPECTED BEHAVIOR WHEN RUNNING

Once the app builds and launches successfully, you should see:

### Initial Screen
- **Login Screen** (since no user is logged in yet)
- Fields for Email and Password
- "Sign In" button
- Link to "Register" screen

### Test Credentials
Since we implemented a mock auth system:
- **Email**: Any valid email format (e.g., test@example.com)
- **Password**: At least 6 characters (e.g., password123)
- **Name**: Any name (for registration)

### After Successful Login
You should see the **bottom navigation bar** with three tabs:
1. **Dashboard** (📊) - Overview with XP, level, badges
2. **Tracking** (📝) - Activity log with add/filter functionality  
3. **Profile** (👤) - User profile with baby info and achievements

### Tracking Module Features
- **Floating Action Button** (+) to add activities
- **Bottom Sheet** for selecting activity type (feeding, diaper, sleep, growth)
- **Activity-specific forms** (method selection for feeding, etc.)
- **List view** of activities with swipe-to-delete
- **XP counter** showing current XP and level progress
- **Filter chips** to show only specific activity types
- **Pull-to-refresh** to reload data

### Profile Module Features
- **Profile Header** showing avatar, name, email, and level
- **Baby Info Card** with editable information (name, DOB, gender, weight, height)
- **Achievements Section** with progress bars for various milestones
- **Edit buttons** to modify information
- **Data persistence** - Information saved between app restarts

### Data Persistence
All tracking activities and profile information are saved locally using SharedPreferences, so:
- Activities persist between app restarts
- Profile information is retained
- XP and level progress are maintained
- Only clearing app data (or uninstalling) will reset everything

## 🛠️ TROUBLESHOOTING COMMON ISSUES

### If you see "Failed to find Dart SDK" error:
1. Ensure `C:\src\flutter\bin\cache\dart-sdk\bin` is in your PATH
2. Restart your terminal/command prompt
3. Verify with: `where dart` (should show path to dart.exe)

### If you get "Timed out waiting for device to be online":
1. Make sure Android Emulator is fully booted before running
2. Try `flutter emulators --launch [emulator-id]` first
3. Check that virtualization is enabled in BIOS

### If you see Gradle build errors:
1. Run `flutter clean` then `flutter pub get` again
2. Make sure you have Java JDK installed (Android Studio usually includes it)
3. Check internet connectivity for dependency downloads

### If you get "UID mismatch" errors:
1. Run `flutter clean`
2. Delete the `build/` folder manually if needed
3. Try running again

### If hot reload/restart doesn't work:
1. Make sure you're running in debug mode (default for flutter run)
2. Check that your IDE is properly connected to the running instance

## 🧪 TESTING SCENARIOS TO VERIFY

### Auth Flow
1. [ ] Launch app → See login screen
2. [ ] Tap "Don't have an account? Sign Up" → See register screen
3. [ ] Register with valid credentials → Should navigate to main app
4. [ ] Log out via settings → Should return to login screen
5. [ ] Log in with same credentials → Should work again
6. [ ] Try invalid credentials (short password) → Should show error

### Tracking Flow
1. [ ] Navigate to Tracking tab
2. [ ] Tap FAB (+) → See activity type selection
3. [ ] Select Feeding → See method selection (Breast/Bottle/Solid/Pumped)
4. [ ] Save → Should see activity in list with +10 XP
5. [ ] Add Diaper activity → See +5 XP
6. [ ] Add Sleep activity → See +15 XP
7. [ ] Add Growth activity → See +20 XP
8. [ ] Swipe left on activity → Should delete with confirmation
9. [ ] Tap filter chips → Should show only selected activity types
10. [ ] Pull down to refresh → Should reload list
11. [ ] Close app → Reopen → Activities should still be there

### Profile Flow
1. [ ] Navigate to Profile tab
2. [ ] View profile header with name, email, level
3. [ ] View baby info card with default/demo information
4. [ ] Tap edit on baby info → Should allow editing fields
5. [ ] Save changes → Should persist after restart
6. [ ] View achievements section with progress bars
7. [ ] Close app → Reopen → Profile info should persist

### Cross-Module
1. [ ] Add several tracking activities → Check XP increases in Profile header
2. [ ] Level up when reaching 100+ XP → Should see level increase
3. [ ] Achievements should update based on level/activity counts
4. [ ] Data should persist completely between app restarts

## 📝 PRODUCTION NOTES

### Authentication
- Current implementation uses mock auth (any email with password ≥6 chars works)
- For production, replace `AuthRepositoryImpl` with real API calls to your backend
- Consider integrating with Firebase Auth, AWS Cognito, or custom OAuth

### Data Storage
- Current implementation uses SharedPreferences (good for small amounts of data)
- For larger datasets or complex queries, consider:
  - SQLite with Drift package (already in pubspec.yaml)
  - Hive for fast NoSQL storage
  - Firebase Cloud Firestore for cloud synchronization

### State Management
- Uses Provider package with ChangeNotifier (appropriate for app size/scale)
- For more complex state needs, consider:
  - Riverpod (already in use for auth via isLoggedInProvider)
  - Bloc/Cubit for more intricate business logic
  - Redux/MobX for predictable state transitions

### UI/UX Enhancements (Future Work)
- Add animations and transitions
- Implement dark/light theme switching
- Add charts/graphs for activity trends
- Implement local notifications for reminders
- Add export/share functionality for data
- Implement offline-first with sync when online

## ✅ VERIFICATION CHECKLIST

Once the app is running successfully, verify:

[ ] App launches without errors  
[ ] Login/register works with test credentials  
[ ] Bottom navigation shows 3 tabs (Dashboard, Tracking, Profile)  
[ ] Dashboard shows default data (can be enhanced later)  
[ ] Tracking allows adding all 4 activity types  
[ ] Tracking shows correct XP awards (+10, +5, +15, +20)  
[ ] Level increases every 100 XP  
[ ] Activities persist between app restarts  
[ ] Profile information can be edited and saved  
[ ] Achievements show progress based on level/activity  
[ ] No crashes or exceptions during normal use  

## 🚀 NEXT STEPS FOR DEVELOPMENT

Once you've verified the basic functionality works:

1. **Enhance Dashboard**: Replace mock data with real statistics from tracking data
2. **Implement Real Auth**: Connect to your backend authentication service
3. **Add Cloud Sync**: Implement backend API calls for data persistence across devices
4. **Add Notifications**: Local reminders for feeding/diaper/sleep schedules
5. **Improve Visuals**: Add custom animations, theme switching, charts
6. **Add Export/Share**: Allow exporting data as CSV/PDF
7. **Improve Onboarding**: Enhance the baby creation flow
8. **Add Settings**: Allow users to customize units, notifications, etc.
9. **Write Tests**: Add unit, widget, and integration tests
10. **Prepare for Release**: Generate app icons, splash screens, versioning

## 📁 WHERE TO FIND YOUR CODE

Your project is located at:
```
D:\Claude Workspace\Projects\00. Test Project\apps\mobile\
```

Key directories to explore:
- `lib/features/tracking/` - Complete tracking implementation
- `lib/features/profile/` - Complete profile implementation  
- `lib/core/` - All the core infrastructure we built
- `lib/main.dart` - App entry point
- `lib/core/app.dart` - App theme and routing setup

You can now iterate on this foundation, knowing you have a solid, clean architecture base to build upon!

**Happy coding!** Your BabyTracker app now has a complete foundation with tracking, profile, and core infrastructure all implemented following Flutter best practices.