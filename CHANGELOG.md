# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GNU General Public License v3.0 (`LICENSE`).
- Comprehensive Privacy Policy (`PRIVACY_POLICY.md`).
- Fastlane metadata structure for F-Droid (`fastlane/metadata/android/en-US/`).
- Bundled offline Inter typography (`assets/fonts/Inter-*.ttf`) with SIL Open Font License.
- Android release signing template (`android/key.properties.example`) with secure unsigned release fallback for F-Droid.
- Bilingual documentation: English (`README.md`) and Vietnamese (`README_VI.md`).
- Community guidelines (`CONTRIBUTING.md`, `SECURITY.md`).

### Changed
- Refactored `AppTheme` to use bundled offline Inter typography instead of runtime network font fetching.
- Optimized Gradle JVM heap allocation from `-Xmx8G` to `-Xmx2048m -XX:MaxMetaspaceSize=1024m` in `android/gradle.properties` for F-Droid build container compatibility.
- Hardened `.gitignore` to protect `.env`, `key.properties`, and keystore certificates.

### Removed
- Removed unused network stub `lib/core/network/dio_client.dart` and `dio` dependency to maintain a pure offline-first codebase.
- Removed runtime dependency on `google_fonts` package.

---

## [0.6.2] - 2026-11-09

### Added
- **Android Home Screen Widgets:**
  - Compact Widget (2×1): Real-time progress bar, Current Task, and Next Task display (`TimeflowWidgetCompactProvider.kt`).
  - Expanded Widget (4×2): Header statistics, detailed time block, and remaining schedule (`TimeflowWidgetExpandedProvider.kt`).
- **Lockscreen Ongoing Notification:**
  - Silent, persistent system notification (`IMPORTANCE_LOW`, `VISIBILITY_PUBLIC`) displaying active task and next upcoming task on lockscreen (`LockscreenNotificationManager.kt`).
  - Native MethodChannel bridge `com.timeflow.lockscreen/bridge`.
- Real-time clock synchronization provider (`homeWidgetClockProvider`) updating widgets exactly on task boundaries.
- Android Desugaring support with `desugar_jdk_libs:2.1.4` for Java 8+ time APIs on older Android versions.

### Fixed
- Fixed RemoteViews compatibility issues in widget layouts (replaced unsupported `<View>` and `<clip>` tags with `<TextView>` and `<scale>`).
- Resolved launcher crash loops during initial widget placement.

---

## [0.5.0] - 2026-11-07

### Added
- Local notification scheduling service with `flutter_local_notifications` and `timezone`.
- Deterministic 32-bit FNV-1a notification ID generator for robust cancellation.
- Automatic reminder reconciliation stream (`appReminderSyncListenerProvider`).
- Drift SQLite Database migration strategy (v1 to v2).
- Theme mode persistence using `SharedPreferences`.

---

## [0.3.0] - 2026-09-12

### Added
- Calendar month view with 7-column grid and adjacent month boundary dates.
- Task count dot indicators on calendar days (up to 3 indicator dots).
- Date-based task filtering and schedule list.

---

## [0.2.0] - 2026-09-12

### Added
- Local SQLite database layer using Drift ORM (`timeflow.sqlite`).
- Task CRUD operations (Create, Read Stream, Update, Delete, Toggle Completion).
- Task title and time range validation logic.

---

## [0.1.0] - 2026-09-12

### Added
- Initial project architecture: Feature-first + Clean Architecture Light + Riverpod.
- Declarative routing with `go_router` (`StatefulShellRoute.indexedStack`).
- Material 3 Light and Dark theme design system.

