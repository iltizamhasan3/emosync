# Bug Fixes Design Document - 2026-07-04

We are fixing 6 distinct user-reported bugs/issues in the EmoSync Flutter application.

## 1. Onboarding Screen Layout Cut Off
- **Problem**: Onboarding illustrations and text overflow on smaller screens.
- **Proposed Solution**: 
  - Change onboarding layout from fixed height proportions to `Expanded` for `PageView.builder` in [onboarding_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/onboarding_screen.dart).
  - Cap the illustration widgets (quadrant page grid, activities grid, and stats chart) to `28%` of the screen height.
  - Enable Bouncing/AlwaysScrollable scroll physics so users can scroll if overflow still happens on tiny screens.

## 2. Logo Header Overlaps System Status Bar
- **Problem**: Header row containing 'EmoSync' sits at top 0, overlapping status bar/notches.
- **Proposed Solution**:
  - Wrap the header containers in a `SafeArea(bottom: false)` inside the page files:
    - [home_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/home_screen.dart)
    - [journal_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/journal_screen.dart)
    - [content_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/content_screen.dart)
    - [friend_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/friend_screen.dart)
    - [profile_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/profile_screen.dart) (clean up outer `SafeArea`).

## 3. Back Button Logging Out (Navigation History Stack)
- **Problem**: Successive presses on system back button on the Home Page displays the Login Screen again.
- **Proposed Solution**:
  - In [login_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/login_screen.dart), change successful login navigation to `Navigator.pushAndRemoveUntil` with `(route) => false`. This clears the stack and sets `HomePage` as root.
  - In [register_screen.dart](file:///mnt/d/Projects/emosync_app/lib/screens/register_screen.dart), change successful registration navigation to `Navigator.pop(context)` instead of pushing a new `LoginPage` instance.

## 4. Streak and Dominant Mood Cards Alignment
- **Problem**: Uneven heights and asymmetric layout of the two widgets on the dashboard.
- **Proposed Solution**:
  - Standardize paddings (16), font sizes (24 for values, 10 for headers), and top row structures (Icon + Text header).
  - Wrap both cards in a Row with `IntrinsicHeight` and `CrossAxisAlignment.stretch` to ensure they match exactly in height.

## 5. Application Name Change
- **Problem**: The app installs as "emosync_app" instead of "EmoSync".
- **Proposed Solution**:
  - Update `android:label` in [AndroidManifest.xml](file:///mnt/d/Projects/emosync_app/android/app/src/main/AndroidManifest.xml) to `EmoSync`.
  - Update `CFBundleDisplayName` and `CFBundleName` in [Info.plist](file:///mnt/d/Projects/emosync_app/ios/Runner/Info.plist) to `EmoSync`.

## 6. App Launcher Icon
- **Problem**: Default Flutter icon is shown when installed.
- **Proposed Solution**:
  - Generate a modern vector launcher icon matching the 4 splash screen blobs using AI image generation.
  - Add `flutter_launcher_icons` dependency to `pubspec.yaml`.
  - Save generated icon to `assets/icon/app_icon.png`.
  - Configure and run `flutter pub run flutter_launcher_icons` to replace launcher resources.
