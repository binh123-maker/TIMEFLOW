# TIMEFLOW ⏳

**A modern, privacy-respecting, Local-First / Offline-First task and schedule management app for Android and Windows.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-green.svg)](https://flutter.dev)
[![Offline-First](https://img.shields.io/badge/Architecture-Offline--First-orange.svg)](PRIVACY_POLICY.md)
[![Zero Trackers](https://img.shields.io/badge/Trackers-0-brightgreen.svg)](PRIVACY_POLICY.md)

*Read this document in other languages: [Tiếng Việt (README_VI.md)](README_VI.md).*

---

## Overview

**TIMEFLOW** helps you organize your daily life with clarity and minimal cognitive friction. While traditional to-do lists present a flat list of tasks, TIMEFLOW provides **real-time time awareness** by dynamically highlighting your **Current Task** (what you should be doing right now) and your **Next Task** (what is coming up next) directly on your device's **Home Screen Widgets** and **Lockscreen Ongoing Notification**.

---

## Key Features

- **100% Offline & Local-First:** Your tasks never leave your phone. All data is persisted in a local SQLite database (`timeflow.sqlite`). No login required, no cloud dependencies, instant UI responsiveness.
- **Android Home Screen Widgets:**
  - **Compact Widget (2×1):** Real-time daily progress bar, Current Task, and Next Task.
  - **Expanded Widget (4×2):** Comprehensive daily schedule, time blocks, and completion metrics.
- **Lockscreen Ongoing Notification:** A silent, persistent status notification (`IMPORTANCE_LOW`, `VISIBILITY_PUBLIC`) that automatically transitions as your tasks start and finish throughout the day.
- **Exact Task Reminders:** Uses Android `AlarmManager` (`exactAllowWhileIdle`) for reliable notifications down to the exact minute. Automatically re-schedules alarms upon system reboot via `ScheduledNotificationBootReceiver`.
- **Calendar & Monthly Planning:** 7-column calendar view with dot indicators showing task density, allowing quick date filtering and time scheduling.
- **Material 3 Design:** Refined Light and Dark themes with bundled offline Inter typography.

---

## Tech Stack & Architecture

TIMEFLOW adheres to **Feature-First + Clean Architecture (Light) + Repository Pattern**:

- **Framework:** [Flutter](https://flutter.dev) (Dart 3.x, sound null-safety).
- **State Management & DI:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`).
- **Local Persistence:** SQLite via [Drift ORM](https://drift.simonbinder.eu) (`drift`, `sqlite3_flutter_libs`).
- **Routing:** [GoRouter](https://pub.dev/packages/go_router) with `StatefulShellRoute.indexedStack`.
- **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) & `timezone`.
- **Android Native Bridge:** Kotlin (`LockscreenNotificationManager.kt`, `TimeflowWidgetCompactProvider.kt`, `TimeflowWidgetExpandedProvider.kt`).
- **Typography:** Bundled offline Inter fonts (`assets/fonts/`).

---

## Folder Structure

```text
lib/
├── core/
│   ├── constants/       # Color palette, spacing, and layout breakpoints
│   ├── notifications/   # Local notification scheduling and hash ID service
│   ├── router/          # Declarative multi-tab GoRouter configuration
│   ├── storage/         # Local settings storage (SharedPreferences)
│   ├── theme/           # Material 3 Light/Dark theme (offline Inter typography)
│   └── utils/           # Date and time formatting helpers
├── data/
│   └── database/        # Drift SQLite database (tables, DAOs, migrations)
├── features/
│   ├── calendar/        # Monthly calendar grid and day filtering
│   ├── home/            # Today screen (Current Task, Next Task, Timeline)
│   ├── home_widget/     # Logic and providers feeding Android Home Widgets
│   ├── lockscreen/      # Native MethodChannel bridge for Lockscreen notification
│   ├── main_layout/     # Adaptive layout (BottomNavBar on mobile, NavRail on desktop)
│   ├── reminders/       # Scheduled task reminders list screen
│   ├── settings/        # Theme switcher (Light, Dark, System)
│   └── tasks/           # Task CRUD operations and form dialogs
└── main.dart            # Application entry point
```

---

## Building and Running

### Prerequisites
- Flutter SDK (version 3.x stable)
- Dart SDK (^3.11.4)
- JDK 17
- Android SDK (API 34/35)

### Setup & Code Generation
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run Tests
```bash
flutter test
```

### Run on Android
```bash
flutter run -d android
```

### Build Debug APK
```bash
flutter build apk --debug
```

### Release Signing
To build signed release APKs for GitHub Releases or IzzyOnDroid:
1. Copy `android/key.properties.example` to `android/key.properties`.
2. Configure your keystore credentials in `android/key.properties`.
3. Run `flutter build apk --release`.

*(Note: When building for F-Droid, F-Droid builds from source using its own signing keys; if `key.properties` is absent, an unsigned release APK is generated automatically).*

---

## Permissions & Privacy

The release version of TIMEFLOW **does not request the `INTERNET` permission**. Your data never leaves your device.

- `POST_NOTIFICATIONS`: Required on Android 13+ to display reminders and the lockscreen schedule notification.
- `SCHEDULE_EXACT_ALARM`: Enables timely alarms down to the exact minute.
- `RECEIVE_BOOT_COMPLETED`: Automatically restores scheduled reminders after your device restarts.

Read our complete [Privacy Policy](PRIVACY_POLICY.md).

---

## License

This project is licensed under the **[GNU General Public License v3.0 (GPLv3)](LICENSE)**.  
The bundled Inter font family is licensed under the **[SIL Open Font License 1.1](assets/fonts/LICENSE_OFL.txt)**.
