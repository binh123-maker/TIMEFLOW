# TIMEFLOW – PHASE 06.2 IMPLEMENTATION REPORT
**Sprint:** 6.2 – Android Home Screen Widget  
**Date:** 2026-11-07  
**Author:** Senior Flutter Developer & Android Architect  
**Status:** IMPLEMENTATION COMPLETE

---

## 1. Scope & Objectives

Sprint 6.2 delivers the Android Home Screen Widget for TIMEFLOW with two sizes:
1. **Compact Widget (2×1):** Displays the current task title, time range, priority tag, today's completion progress (`X/Y`), and an empty state if no active task is running.
2. **Expanded Widget (4×2):** Displays app branding, header date (Vietnamese formatted), progress counter, determinate progress bar, two structured cards for "ĐANG DIỄN RA" (Current Task) and "TIẾP THEO" (Next Task), and a quick-launch action button.

---

## 2. Architecture & File Inventory

### A. Flutter Layer
- **`lib/features/home_widget/domain/models/home_widget_payload.dart`:**
  - `HomeWidgetTaskSummary`: Immutable model holding `id`, `title`, `description`, `timeRange`, `priority`, and `isCompleted`. Full JSON serialization and value equality.
  - `HomeWidgetPayload`: Root payload containing `version`, `currentTask`, `nextTask`, `totalTasksToday`, `completedTasksToday`, `headerDate`, and `lastUpdatedAt`. Provides helper properties `progressPercent` (0..100) and `progressFractionText` (`X/Y`).
- **`lib/features/home_widget/data/services/home_widget_service.dart`:**
  - Interface `IHomeWidgetService` and implementation `HomeWidgetServiceImpl`.
  - Platform guard: Bypasses native calls on non-Android environments (e.g. Windows Desktop) without exceptions.
  - In-memory payload deduplication cache: Identical consecutive payloads do not trigger redundant native IPC calls.
  - Saves individual keys (`currentTaskTitle`, `currentTaskTime`, `progressPercent`, etc.) and the serialized JSON payload via `HomeWidget.saveWidgetData`.
  - Pushes updates to both `TimeflowWidgetCompactProvider` and `TimeflowWidgetExpandedProvider`.
- **`lib/features/home_widget/presentation/providers/home_widget_providers.dart`:**
  - `evaluateCurrentAndNextTask(tasks, now)`: Pure helper evaluating active and upcoming tasks based on exact moment `now`.
  - `calculateNextTransitionTime(tasks, now)`: Calculates the exact earliest boundary (`startTime` or `endTime`) in the future to schedule updates.
  - `homeWidgetClockProvider`: Stream ticking at exact task transition boundaries or minute flips without battery-draining continuous polling.
  - `homeWidgetPayloadProvider`: Derived provider computing the latest `HomeWidgetPayload` from Drift SQLite task streams and dynamic clock.
  - `homeWidgetAutoSyncListenerProvider`: Auto-sync listener triggering native widget refresh on task changes.
- **`lib/main.dart`:**
  - Registered `homeWidgetAutoSyncListenerProvider`.
  - Initial startup sync in `initState` post-frame callback.
  - Added `WidgetsBindingObserver` to re-sync widgets whenever the app transitions to `AppLifecycleState.resumed`.

### B. Android Native Layer
- **Layouts (`android/app/src/main/res/layout/`):**
  - `timeflow_widget_compact.xml`: 2×1 widget layout with header progress badge, task title, time, priority pill, and empty state placeholder.
  - `timeflow_widget_expanded.xml`: 4×2 widget layout with date, progress text, horizontal ProgressBar, two task cards (Current & Next), and "Mở TIMEFLOW" action button.
- **Metadata (`android/app/src/main/res/xml/`):**
  - `timeflow_widget_compact_info.xml`: AppWidgetProvider configuration (minWidth: 110dp, minHeight: 40dp, targetCell: 2×1, category: home_screen).
  - `timeflow_widget_expanded_info.xml`: AppWidgetProvider configuration (minWidth: 250dp, minHeight: 110dp, targetCell: 4×2, category: home_screen).
- **Drawables (`android/app/src/main/res/drawable/`):**
  - `widget_background.xml`: Dark slate rectangle (`#18181B`) with 16dp rounded corners and border.
  - `widget_card_background.xml`: Inner panel rectangle (`#27272A`) with 12dp rounded corners.
  - `widget_priority_badge.xml`: Pill shape background for priority text.
  - `widget_progress_bar.xml`: Layer-list progress bar with accent fill (`#6366F1`).
  - `widget_button_background.xml`: Rounded button background (`#4F46E5`).
- **Kotlin Providers (`android/app/src/main/kotlin/com/timeflow/timeflow/`):**
  - `TimeflowWidgetCompactProvider.kt`: Extends `HomeWidgetProvider`, reads data from SharedPreferences, updates RemoteViews for 2×1 widget, attaches `HomeWidgetLaunchIntent` to open `MainActivity`.
  - `TimeflowWidgetExpandedProvider.kt`: Extends `HomeWidgetProvider`, reads data from SharedPreferences, updates RemoteViews for 4×2 widget, populates progress bar and dual task cards, attaches `HomeWidgetLaunchIntent` to both widget root and open button.
- **Manifest (`android/app/src/main/AndroidManifest.xml`):**
  - Registered both `TimeflowWidgetCompactProvider` and `TimeflowWidgetExpandedProvider` as exported broadcast receivers with `android.appwidget.action.APPWIDGET_UPDATE`.

---

## 3. Time Transition Handling (08:59 → 09:00 Problem)

- **Root Cause:** Drift SQLite stream fires on database writes. If no database write occurs, time advancement alone will not trigger the Drift stream.
- **Solution Implementation:**
  1. `calculateNextTransitionTime` scans uncompleted tasks for today and finds the nearest future timestamp among `startTime` and `endTime`.
  2. `homeWidgetClockProvider` sleeps until `min(nextTransitionTime, nextMinute)`, then yields the updated clock.
  3. `homeWidgetPayloadProvider` watches this clock and immediately re-evaluates `evaluateCurrentAndNextTask`.
  4. At 09:00:00 sharp, the former Next Task automatically becomes Current Task, and the update is dispatched to native widgets.
  5. Zero continuous polling loops; CPU sleeps between transitions.

---

## 4. Platform Safety (Windows Desktop)

- All native platform channel calls inside `HomeWidgetServiceImpl` are guarded by `if (kIsWeb || defaultTargetPlatform != TargetPlatform.android)`.
- On Windows Desktop, the service logs a debug message and gracefully records `lastPayload` without invoking `MethodChannel`.
- Verified in automated tests with `debugDefaultTargetPlatformOverride = TargetPlatform.windows`.

