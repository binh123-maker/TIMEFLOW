# TIMEFLOW – PHASE 06.2 PREFLIGHT AUDIT REPORT
**Sprint:** 6.2 – Android Home Screen Widget  
**Date:** 2026-11-07  
**Author:** Senior Flutter Developer & Android Architect  
**Status:** AUDIT PASSED – READY FOR IMPLEMENTATION

---

## 1. Executive Summary & Objective

The objective of Sprint 6.2 is to implement the **Android Home Screen Widget** for TIMEFLOW, enabling users to glance at their active schedule directly from their launcher without launching the app.
This audit validates the existing system baseline, inspects dependencies, checks regression constraints, and formulates the technical architecture for both Flutter and Android Native components.

---

## 2. Environment & Dependency Audit

| Component | Target / Current Version | Status | Notes |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | 3.41.6 | Verified | Channel stable |
| **Dart SDK** | 3.11.4 | Verified | Strict typing, sound null safety |
| **Android SDK / NDK** | compileSdk 36, minSdk 26, targetSdk 36 | Verified | Configured in `app/build.gradle.kts` |
| **Kotlin JVM** | 17 / 21 | Verified | Compatible with AGP 8.x |
| **home_widget** | 0.10.0 | Added & Verified | Compatible with Android RemoteViews & Flutter 3.41 |
| **Drift / SQLite** | 2.18.0 / Schema v2 | Verified | Single Source of Truth |
| **Existing Tests** | 57/57 Passed | Verified | Baseline intact |
| **Windows Desktop** | Guarded / Fallback | Verified | Native bridge calls safely skipped |

---

## 3. Architecture & Single Source of Truth (SSOT)

```
+-------------------------------------------------------------+
|                      FLUTTER LAYER                          |
|                                                             |
|   Drift SQLite (SSOT) ----> TaskStream                      |
|                                  |                          |
|   Clock / Minute Tick Stream ----+                          |
|                                  v                          |
|                     homeWidgetPayloadProvider               |
|                                  |                          |
|                     HomeWidgetService (Bridge)              |
|                     (Deduplication + Non-Android Guard)     |
+----------------------------------+--------------------------+
                                   | HomeWidget.saveWidgetData()
                                   | HomeWidget.updateWidget()
                                   v
+-------------------------------------------------------------+
|                   ANDROID NATIVE LAYER                      |
|                                                             |
|   SharedPreferences (home_widget internal storage)          |
|                                  |                          |
|   TimeflowWidgetProvider (AppWidgetProvider)                |
|           |                                                 |
|           +---> timeflow_widget_compact (2x1)               |
|           |                                                 |
|           +---> timeflow_widget_expanded (4x2)              |
+-------------------------------------------------------------+
```

**Key Architectural Rules:**
1. **Drift SQLite is the single source of truth:** Android Native does NOT connect to or query SQLite directly. Flutter processes all database streams, evaluates task statuses, formats Vietnamese strings, and pushes structured key-value payloads into the widget's storage.
2. **Platform Guarding:** All widget interactions must check `defaultTargetPlatform == TargetPlatform.android` to ensure Windows Desktop never encounters missing plugin channel errors.
3. **Decoupling from Lockscreen Ongoing Notification:** Home Widget operates independently from `LockscreenBridgeService` (Ongoing Notification ID 1001), preventing any collision or state cross-contamination.

---

## 4. Time-Based Transition Strategy (The 08:59 → 09:00 Problem)

- **Issue:** When the clock turns from 08:59 to 09:00, a task that was "Next" becomes "Current". Since the database has not changed, Drift's reactive query stream will not emit.
- **Solution:**
  1. **Dynamic Transition Boundary Calculation:** The provider computes `nextTransitionTime` as `min(currentTask.endTime, nextTask.startTime)` among today's tasks.
  2. **Reactive Minute/Boundary Stream:** In addition to the database stream, Flutter observes a minute-tick or precise timer scheduled at `nextTransitionTime`. When the moment arrives, the provider re-evaluates the payload and pushes an updated view.
  3. **Android Lifecycle / Resume Refresh:** Whenever the application resumes (`AppLifecycleState.resumed`), a sync is triggered to ensure the widget reflects any time passage during sleep or background state.
  4. **Low Battery Impact:** No high-frequency polling. Only exact boundary timers or standard minute ticks are observed when active.

---

## 5. Specification for Widget Sizes

### A. Compact Widget (2×1)
- **Target dimensions:** minWidth 110dp, minHeight 40dp (resizes horizontally/vertically).
- **Contents:**
  - Header badge / Title: "TIMEFLOW" & Today's Progress `(X/Y)`.
  - Current Task title (or "Không có công việc đang diễn ra" if none).
  - Time interval (e.g. `08:00 - 09:30`).
  - Priority indicator or status tag.
  - Tap action: opens app via `MainActivity` PendingIntent.

### B. Expanded Widget (4×2)
- **Target dimensions:** minWidth 250dp, minHeight 110dp.
- **Contents:**
  - Header: App Title, formatted date (e.g., `Thứ Bảy, 07/11/2026`), and progress counter (`X/Y hoàn thành`).
  - Visual Progress Bar (determinate `ProgressBar` reflecting completion %).
  - **Current Task Box:** Title, start/end time, priority, empty placeholder if none.
  - **Next Task Box:** Upcoming task title, scheduled time, empty placeholder if none.
  - Quick action button: "Mở ứng dụng".
  - Tap action on items to deep-link or launch app.

---

## 6. Preflight Conclusion & Green Light

- Dependencies: OK (`home_widget: 0.10.0`).
- Test Suite: 57/57 PASS.
- Architecture: Approved.
- **Proceeding to Step 1: Implementation of Flutter domain, data, and presentation layers.**

