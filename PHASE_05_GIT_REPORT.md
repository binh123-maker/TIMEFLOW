# BÁO CÁO TRẠNG THÁI VÀ QUẢN LÝ GIT (PHASE 05 GIT REPORT)
**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian kiểm tra:** 07/11/2026  
**Nguyên tắc tuân thủ:** Không tự ý commit hoặc push khi chưa có phê duyệt từ người dùng.  

---

## 1. THÔNG TIN GIT HIỆN TẠI
- **Branch hiện tại:** `main` (Up to date với `origin/main`).
- **Commit gần nhất trên Git:**
  - `591a3f8`: *Calendar & Task Scheduling* (Commit hoàn thành Phase 03).
  - Trước đó: `70411eb` (*Local Database + Task CRUD*), `069d672` (*Initial commit*).

---

## 2. TRẠNG THÁI WORKING TREE
Working tree hiện đang chứa các thay đổi thuộc về:
- **Phase 04:** Reminder & Local Notifications.
- **Phase 05:** Persistent Theme Settings + Technical Design cho Phase 06 + Các báo cáo QA/Recovery.

```text
On branch main
Changes not staged for commit:
  modified:   android/app/build.gradle.kts
  modified:   android/app/src/main/AndroidManifest.xml
  modified:   lib/core/notifications/notification_helper.dart
  modified:   lib/core/storage/local_storage.dart
  modified:   lib/core/theme/theme_provider.dart
  modified:   lib/data/database/app_database.dart
  modified:   lib/data/database/app_database.g.dart
  modified:   lib/data/database/tables/task_table.dart
  modified:   lib/data/repositories/task_repository_impl.dart
  modified:   lib/features/calendar/presentation/widgets/calendar_task_list.dart
  modified:   lib/features/reminders/presentation/reminders_screen.dart
  modified:   lib/features/tasks/domain/entities/task_entity.dart
  modified:   lib/features/tasks/domain/usecases/create_task.dart
  modified:   lib/features/tasks/domain/usecases/update_task.dart
  modified:   lib/features/tasks/presentation/tasks_screen.dart
  modified:   lib/features/tasks/presentation/widgets/task_form_dialog.dart
  modified:   lib/main.dart
  modified:   pubspec.lock
  modified:   pubspec.yaml
  modified:   test/database_test.dart

Untracked files:
  PROJECT_AUDIT_REPORT.md
  PHASE_05_RECOVERY_REPORT.md
  PHASE_05_TEST_REPORT.md
  PHASE_05_GIT_REPORT.md
  docs/LOCKSCREEN_TECHNICAL_DESIGN.md
  lib/core/notifications/local_notification_service.dart
  lib/core/notifications/reminder_offset.dart
  lib/features/reminders/presentation/providers/reminder_providers.dart
  test/fake_local_notification_service.dart
  test/reminder_test.dart
  test/theme_settings_test.dart
```

---

## 3. TRẠNG THÁI BẢN SAO LƯU (BACKUP STATUS)
- **Đã tạo bản sao lưu an toàn tại:**  
  `C:\Users\Lenovo\.gemini\antigravity\brain\fa9efbb7-7e3c-4aa3-b61e-863d4129a8ab\backups\timeflow_pre_phase05`
- **Thời gian tạo:** 07/11/2026.
- **Tính toàn vẹn:** Khớp 100% toàn bộ source code `lib/` (53 files) và `test/` (6 files ban đầu).
- **Trạng thái:** Sẵn sàng khôi phục bất cứ lúc nào nếu phát sinh sự cố.

---

## 4. PHÂN LOẠI THAY ĐỔI VÀ ĐỀ XUẤT COMMIT (READY TO COMMIT)

Để đảm bảo lịch sử Git trong sạch, chuyên nghiệp và có thể rollback từng phần nếu cần, khuyến nghị chia các thay đổi thành **2 Commit độc lập**:

### Commit 1: Hoàn tất Phase 04 – Reminder & Local Notifications
- **Mục tiêu:** Chốt lại toàn bộ tính năng nhắc việc đã được kiểm thử 100% pass.
- **Danh sách file vào Commit 1:**
  ```text
  android/app/build.gradle.kts
  android/app/src/main/AndroidManifest.xml
  lib/core/notifications/local_notification_service.dart
  lib/core/notifications/notification_helper.dart
  lib/core/notifications/reminder_offset.dart
  lib/data/database/app_database.dart
  lib/data/database/app_database.g.dart
  lib/data/database/tables/task_table.dart
  lib/data/repositories/task_repository_impl.dart
  lib/features/calendar/presentation/widgets/calendar_task_list.dart
  lib/features/reminders/presentation/reminders_screen.dart
  lib/features/reminders/presentation/providers/reminder_providers.dart
  lib/features/tasks/domain/entities/task_entity.dart
  lib/features/tasks/domain/usecases/create_task.dart
  lib/features/tasks/domain/usecases/update_task.dart
  lib/features/tasks/presentation/tasks_screen.dart
  lib/features/tasks/presentation/widgets/task_form_dialog.dart
  test/database_test.dart
  test/fake_local_notification_service.dart
  test/reminder_test.dart
  ```
- **Commit message đề xuất:**
  ```text
  feat(notifications): complete local task reminders with drift schema v2 and startup reconciliation
  ```

### Commit 2: Phase 05 – Persistent Theme Settings & Lockscreen Technical Architecture
- **Mục tiêu:** Lưu trữ cấu hình giao diện vĩnh viễn và bộ tài liệu kiến trúc kỹ thuật.
- **Danh sách file vào Commit 2:**
  ```text
  lib/core/storage/local_storage.dart
  lib/core/theme/theme_provider.dart
  lib/main.dart
  pubspec.yaml
  pubspec.lock
  test/theme_settings_test.dart
  docs/LOCKSCREEN_TECHNICAL_DESIGN.md
  PROJECT_AUDIT_REPORT.md
  PHASE_05_RECOVERY_REPORT.md
  PHASE_05_TEST_REPORT.md
  PHASE_05_GIT_REPORT.md
  ```
- **Commit message đề xuất:**
  ```text
  chore(settings): persist theme settings via shared_preferences and add lockscreen architecture design
  ```

---

## 5. CÁC THAY ĐỔI CẦN PHÊ DUYỆT (CHANGES REQUIRING APPROVAL)
1. **Xóa Dead Code:** Đề xuất xóa 3 file thừa:
   - `lib/data/models/task_model.dart`
   - `lib/core/database/app_database.dart`
   - `lib/services/notification_service.dart`
   *(Chỉ thực hiện xóa sau khi người dùng xác nhận)*.
2. **Thực thi Git Commit:** Chờ lệnh phê duyệt từ người dùng trước khi chạy `git add` và `git commit`.

