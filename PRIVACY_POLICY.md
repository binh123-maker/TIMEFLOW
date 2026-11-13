# TIMEFLOW – Privacy Policy

*Last updated: November 13, 2026*

## 1. Introduction

TIMEFLOW ("we", "our", or "the application") is a free and open-source personal time and task management application built upon **Local-First and Offline-First** architectural principles.

We firmly believe that your personal schedule, tasks, deadlines, and daily routines belong exclusively to you. This Privacy Policy outlines how TIMEFLOW handles your data and confirms our strict commitment to user privacy.

---

## 2. Summary: No Data Collection, No Tracking

- **No User Accounts:** You do not need to register, log in, or provide any personal identification (e.g., name, email address, phone number) to use TIMEFLOW.
- **No Remote Servers or Backend:** TIMEFLOW operates without any remote server or backend database for its core functionality.
- **No Internet Access in Release:** The production Android application (`AndroidManifest.xml`) does **not** declare or request the `android.permission.INTERNET` permission. As a result, the application cannot establish network connections or transmit your data to remote servers.
- **No Analytics, Telemetry, or Advertisements:** TIMEFLOW contains zero analytics SDKs, tracking pixels, crash reporting third-party services, or advertisement libraries.

---

## 3. Data Storage and Retention

### 3.1. What Data Is Stored
TIMEFLOW stores the following information strictly on your local device:
- Task items (title, description, start time, end time, due date, priority, completion status).
- Reminder preferences (notification lead time).
- UI theme preferences (Light Mode, Dark Mode, or System Default).

### 3.2. Where Data Is Stored
All task data is persisted locally in an on-device SQLite database (`timeflow.sqlite`) managed by the Drift persistence library in the private application sandbox directory (`path_provider`).  
Theme preferences and widget bridge payloads are stored locally in Android `SharedPreferences`.

### 3.3. Data Retention and Deletion
Your data remains on your device for as long as you keep the application installed.  
You can permanently delete all stored data at any time by:
1. Clearing the application data in **Android Settings > Apps > TIMEFLOW > Storage & Cache > Clear Storage**, or
2. Uninstalling the TIMEFLOW application from your device.

---

## 4. Android Device Permissions

TIMEFLOW only requests permissions that are strictly necessary to deliver its core features:

| Permission | Purpose | User Action Required |
|---|---|---|
| `POST_NOTIFICATIONS` | Required on Android 13+ (API 33+) to display scheduled task reminders and the persistent lockscreen schedule notification. | Prompted at runtime. You may grant or revoke this permission at any time in Android Settings. |
| `SCHEDULE_EXACT_ALARM` | Required to trigger reminder notifications precisely at the specified minute, even when the device is idle or in battery-saving Doze mode. | Granted according to system policies or managed under *Alarms & reminders* settings. |
| `RECEIVE_BOOT_COMPLETED` | Allows TIMEFLOW to restore your scheduled reminders with the system `AlarmManager` after your device reboots. | Granted automatically by Android upon installation. Does not access personal data. |

---

## 5. Third-Party Services and Code

- **Font Assets:** All font files (Inter typography) are bundled locally within the application package (`assets/fonts/`). No external font servers (e.g., Google Fonts API) are queried at runtime.
- **No Third-Party Trackers:** TIMEFLOW does not integrate with Google Play Services, Firebase, Facebook SDK, or any marketing services.

---

## 6. Open Source Verification

Because TIMEFLOW is licensed under the **GNU General Public License v3.0 (GPLv3)**, the complete source code is publicly accessible and auditable by anyone. You can inspect the source code, verify that no network requests or telemetry exist, and build the application directly from source:

- **Repository:** [https://github.com/binh123-maker/TIMEFLOW](https://github.com/binh123-maker/TIMEFLOW)

---

## 7. Changes to this Policy

If this Privacy Policy is updated in future versions, revisions will be published in this document within the public repository and reflected in the project changelog.

---

## 8. Contact

For technical questions, bug reports, or privacy inquiries regarding TIMEFLOW, please open an issue on our GitHub repository:  
[https://github.com/binh123-maker/TIMEFLOW/issues](https://github.com/binh123-maker/TIMEFLOW/issues)

