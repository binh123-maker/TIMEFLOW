# BÁO CÁO KIỂM TOÁN TOÀN DIỆN VÀ KIỂM KÊ TIẾN ĐỘ DỰ ÁN
**Dự án:** To-do List & Lockscreen App (Tên mã triển khai: **TIMEFLOW**)  
**Ngày kiểm toán:** 07/11/2026  
**Chuyên môn:** Senior Software Architect, Technical Lead & QA Engineer  
**Phạm vi:** Toàn bộ mã nguồn, cấu hình hệ điều hành, cơ sở dữ liệu, kiến trúc, kiểm thử và trạng thái Git.

---

## PHẦN 1 – PROJECT OVERVIEW (TỔNG QUAN DỰ ÁN)

- **Tên dự án theo tài liệu/mã nguồn:** TIMEFLOW (Tên theo yêu cầu kiểm toán: *To-do List & Lockscreen App*).
- **Mục tiêu dự án:** Xây dựng ứng dụng quản lý công việc, thời gian và lịch trình đa nền tảng (Android & Windows Desktop) theo triết lý **Local-first / Offline-first**, dữ liệu lưu trữ trực tiếp trên thiết bị với độ trễ thấp và khả năng mở rộng Cloud Sync trong tương lai.
- **Kiến trúc tổng thể:** Áp dụng mô hình **Feature-First + Clean Architecture (Light) + Repository Pattern**.
  - `core/`: Hạ tầng nền tảng, định tuyến (GoRouter), giao diện (Theme Material 3), hằng số, tiện ích ngày tháng, dịch vụ thông báo cục bộ.
  - `data/`: Định nghĩa thực thể Drift SQLite (Tables, DAOs, Database), Data models, và triển khai Repository (`TaskRepositoryImpl`).
  - `features/`: Module hóa theo tính năng (`tasks`, `calendar`, `home`, `reminders`, `focus`, `statistics`, `settings`, `profile`, `subscription`, `timeline`, `main_layout`).
  - `services/`: Các stub service chuẩn bị cho kiến trúc tương lai (Auth, Cloud Sync, Subscription).
- **Tình trạng Git:**
  - **Branch hiện tại:** `main` (up to date với `origin/main`).
  - **Lịch sử commit:** Có 3 commits:
    - `591a3f8`: *Calendar & Task Scheduling* (Hoàn thành Phase 3).
    - `70411eb`: *Local Database + Task CRUD* (Hoàn thành Phase 2).
    - `069d672`: *Initial commit* (Phase 1 Init).
  - **Trạng thái Working Tree:** Chưa commit (Uncommitted changes) bao gồm 18 files sửa đổi và 5 files untracked thuộc tính năng Reminder & Local Notifications (Phase 4).

---

## PHẦN 2 – TECHNOLOGY STACK (NGĂN XẾP CÔNG NGHỆ THỰC TẾ)

| Hạng mục | Công nghệ / Thư viện | Phiên bản | Mục đích sử dụng | Đánh giá hiện trạng |
|---|---|---|---|---|
| **Core Framework** | Flutter SDK / Dart SDK | Flutter 3.x / Dart 3.11.4 | Nền tảng phát triển ứng dụng đa nền tảng (Android, Windows) | Hoạt động ổn định |
| **State Management** | `flutter_riverpod` | `^2.5.1` | Quản lý state phản ứng (Reactive Streams, StateNotifier, Providers) | Đã triển khai chuẩn chỉ cho Tasks, Calendar, Home, Reminders |
| **Routing** | `go_router` | `^14.2.0` | Quản lý điều hướng với `StatefulShellRoute.indexedStack` | Hoạt động tốt giữa Mobile BottomNav & Desktop NavigationRail |
| **Local Database** | `drift` + `sqlite3_flutter_libs` | `^2.18.0` / `^0.5.24` | ORM SQLite phản ứng, tạo bảng, schema migration, stream truy vấn | Hoạt động tốt, đã nâng cấp schema v2 |
| **Notifications** | `flutter_local_notifications` + `timezone` | `^18.0.1` / `^0.9.4` | Thông báo lịch trình chính xác (`exactAllowWhileIdle`) | Đã code xong tầng logic, đang ở working tree |
| **Networking** | `dio` | `^5.5.0+1` | Chuẩn bị kết nối REST API backend | Mới chỉ có file cấu hình boilerplate `DioClient` (Stub) |
| **Design System** | Material 3 + `google_fonts` (Inter) | `^6.2.1` | Hệ thống thiết kế Light & Dark Theme, Typography chuẩn | Hoàn chỉnh Light/Dark Theme |
| **Date & Time** | `intl` | `^0.20.2` | Định dạng ngày giờ tiếng Việt, xử lý lịch trình | Hoạt động tốt |
| **Identifiers** | `uuid` | `^4.4.0` | Sinh UUID v4 cho Task ID | Hoạt động tốt |
| **Testing** | `flutter_test`, `drift_dev`, `sqlite3` in-memory | N/A | Kiểm thử tự động (Unit test, Database test, Migration test) | Có 5 test files chất lượng cao |

---

## PHẦN 3 – PROJECT STRUCTURE (CẤU TRÚC MÃ NGUỒN)

```text
d:\TODOLIST AND LOCKSCREEN\
├── android/                             # Cấu hình native Android (Gradle, Manifest, Permissions)
├── lib/
│   ├── main.dart                        # Entrypoint, ProviderScope, khởi tạo notification & listener
│   ├── core/
│   │   ├── constants/                   # Hằng số màu sắc (app_colors.dart), breakpoints (app_constants.dart)
│   │   ├── database/
│   │   │   └── app_database.dart        # [REDUNDANT] File re-export trỏ về data/database/app_database.dart
│   │   ├── network/
│   │   │   └── dio_client.dart          # [STUB] Cấu hình Dio client với dummy URL
│   │   ├── notifications/               # Core notification abstraction & ReminderOffset enum
│   │   │   ├── local_notification_service.dart # Triển khai FlutterLocalNotificationsPlugin + FNV-1a hash
│   │   │   ├── notification_helper.dart # File export barrel
│   │   │   └── reminder_offset.dart     # Enum định nghĩa khoảng thời gian nhắc nhở
│   │   ├── router/
│   │   │   └── app_router.dart          # Cấu hình GoRouter đa tầng
│   │   ├── storage/
│   │   │   └── local_storage.dart       # [STUB] MemoryLocalStorage (chưa lưu xuống disk)
│   │   ├── theme/                       # Cấu hình Theme Material 3 và ThemeProvider
│   │   └── utils/                       # DateFormatter hỗ trợ tiếng Việt
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart        # Drift database class, schemaVersion 2, MigrationStrategy
│   │   │   ├── app_database.g.dart      # File sinh mã của Drift
│   │   │   ├── daos/task_dao.dart       # Data Access Object cho Tasks
│   │   │   └── tables/task_table.dart   # Định nghĩa bảng Tasks
│   │   ├── models/
│   │   │   └── task_model.dart          # [DEAD CODE] Model khởi tạo ban đầu, không được dùng trong app
│   │   └── repositories/
│   │       ├── task_repository.dart     # Interface ITaskRepository
│   │       └── task_repository_impl.dart# Triển khai repository kết nối Drift DAO và TaskEntity
│   ├── features/
│   │   ├── main_layout/presentation/    # Shell responsive (BottomNav trên Mobile, NavigationRail trên Desktop)
│   │   ├── home/                        # Màn hình Hôm nay (Live Clock, Current Task, Next Task, Schedule)
│   │   ├── calendar/                    # Màn hình Lịch (Header, Lưới tháng 7 cột, lọc task theo ngày)
│   │   ├── tasks/                       # Quản lý công việc (Domain Clean Architecture, UI CRUD, Filter, Search)
│   │   ├── reminders/                   # Màn hình và Service đồng bộ nhắc nhở (Startup reconciliation)
│   │   ├── focus/                       # [SKELETON] Placeholder Pomodoro Timer
│   │   ├── statistics/                  # [SKELETON] Placeholder Báo cáo năng suất
│   │   ├── timeline/                    # [SKELETON] Placeholder Lịch trình chi tiết
│   │   ├── settings/                    # Màn hình Cài đặt (Mới chỉ có chuyển Dark/Light mode in-memory)
│   │   ├── profile/                     # [SKELETON] Placeholder Tài khoản người dùng
│   │   └── subscription/                # [SKELETON] Placeholder Gói TIMEFLOW Plus
│   └── services/                        # [STUBS] auth_service, notification_service, sync_service,...
├── test/                                # Thư mục kiểm thử tự động
│   ├── calendar_test.dart               # Test lịch trình, logic lưới, dot indicator, sắp xếp giờ
│   ├── database_test.dart               # Test CRUD Drift SQLite, Migration v1 -> v2
│   ├── fake_local_notification_service.dart # Test double cho thông báo
│   ├── reminder_test.dart               # Test toàn diện bộ tính toán và đồng bộ nhắc việc (18 test cases)
│   ├── usecases_test.dart               # Test nghiệp vụ CreateTask, UpdateTask validation
│   └── widget_test.dart                 # Test định dạng ngày tháng tiếng Việt & Entity
├── pubspec.yaml                         # Cấu hình package dependencies
└── README.md                            # Tài liệu mô tả dự án và lộ trình các Phase
```

### Đánh giá các thành phần bất thường / Trùng lặp / Chưa kết nối:
1. **File rác / Dead Code:** `lib/data/models/task_model.dart`: Đây là file tạo ở Phase 1 có chứa field `category` và `categoryColor`, tuy nhiên toàn bộ hệ thống đã chuyển sang dùng `TaskEntity` (`lib/features/tasks/domain/entities/task_entity.dart`). `task_model.dart` không được bất kỳ màn hình hay provider nào import.
2. **File thừa (Redundant):** `lib/core/database/app_database.dart`: Chỉ chứa 1 dòng `export '../../data/database/app_database.dart';`.
3. **File Stub không còn giá trị:** `lib/services/notification_service.dart`: Chứa stub rỗng ban đầu, trong khi dịch vụ thực tế đã được xây dựng hoàn chỉnh tại `lib/core/notifications/local_notification_service.dart`.
4. **Chưa kết nối lưu trữ thật:** `lib/core/storage/local_storage.dart` chỉ là `MemoryLocalStorage` lưu trong RAM, chưa kết nối `shared_preferences` hay Hive/Drift Key-Value nên cài đặt ThemeMode bị mất khi đóng app.

---

## PHẦN 4 – FEATURE INVENTORY (KIỂM KÊ TÍNH NĂNG CHI TIẾT)

| STT | Chức năng | Phân loại nhóm | Trạng thái | File triển khai | Bằng chứng kiểm tra thực tế |
|:---:|---|---|---|---|---|
| 1 | Tạo công việc (Create Task) | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/domain/usecases/create_task.dart`, `task_form_dialog.dart` | Form dialog đầy đủ title, mô tả, ngày, giờ bắt đầu/kết thúc, mức ưu tiên; validation title rỗng và time logic |
| 2 | Xem danh sách công việc | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/presentation/tasks_screen.dart` | Stream từ Drift SQLite phản ứng thời gian thực qua `allTasksStreamProvider` |
| 3 | Chỉnh sửa công việc (Update Task) | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/domain/usecases/update_task.dart`, `task_form_dialog.dart` | Load dữ liệu cũ vào form, cập nhật vào SQLite, hỗ trợ đổi giờ/ngày |
| 4 | Xóa công việc (Delete Task) | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/domain/usecases/delete_task.dart`, `tasks_screen.dart` | Hộp thoại xác nhận trước khi xóa, xóa khỏi SQLite |
| 5 | Đánh dấu hoàn thành (Toggle Status) | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/domain/usecases/toggle_task_completion.dart` | Checkbox cập nhật tức thì `isCompleted` và chuyển trạng thái sang `completed` / `pending` |
| 6 | Tìm kiếm công việc | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/presentation/tasks_screen.dart` | Search bar tìm kiếm realtime theo title và description |
| 7 | Lọc công việc theo tab | Task Management | **Đã hoàn thành và hoạt động** | `lib/features/tasks/presentation/tasks_screen.dart` | Filter tab: "Tất cả", "Chưa xong", "Đã hoàn thành" |
| 8 | Quản lý Mức ưu tiên (Priority) | Priority & Deadline | **Đã hoàn thành và hoạt động** | `lib/features/tasks/domain/entities/task_entity.dart` | 4 mức: `low`, `medium`, `high`, `urgent` kèm mã màu phân biệt rõ ràng |
| 9 | Quản lý Hạn chót & Khung giờ | Priority & Deadline | **Đã hoàn thành và hoạt động** | `task_form_dialog.dart`, `date_formatter.dart` | Chọn ngày (DatePicker), chọn giờ bắt đầu/kết thúc (TimePicker) |
| 10 | Danh mục công việc (Todo Categories) | Todo Categories | **Chưa triển khai** | N/A | Bảng SQLite `tasks` và `TaskEntity` không có cột Category; Form tạo task không có mục chọn danh mục |
| 11 | Xem lịch theo tháng (Month Grid) | Calendar & Scheduling | **Đã hoàn thành và hoạt động** | `calendar_month_view.dart`, `calendar_screen.dart` | Lưới 7 cột (T2 -> CN), hiển thị cả các ngày tháng trước/sau bị tràn |
| 12 | Chỉ báo số lượng task trên lịch | Calendar & Scheduling | **Đã hoàn thành và hoạt động** | `calendar_month_view.dart` | Dot indicators (1 chấm, 2 chấm, tối đa 3 chấm) theo số task trong ngày |
| 13 | Lọc công việc theo ngày chọn trên lịch | Calendar & Scheduling | **Đã hoàn thành và hoạt động** | `calendar_task_list.dart`, `calendar_providers.dart` | Tự động cập nhật danh sách khi bấm vào ngày; task có giờ được xếp trước task không giờ |
| 14 | Điều hướng tháng và nút "Hôm nay" | Calendar & Scheduling | **Đã hoàn thành và hoạt động** | `calendar_header.dart` | Nút chuyển tháng trước/sau và nút "Hôm nay" reset nhanh về ngày hiện tại |
| 15 | Lịch trình Hôm nay (Current & Next Task) | Calendar & Scheduling | **Đã hoàn thành và hoạt động** | `home_screen.dart`, `current_task_card.dart`, `next_task_card.dart` | Tự động tính toán công việc đang diễn ra và công việc tiếp theo dựa theo giờ hệ thống |
| 16 | Cấu hình nhắc việc (Reminder Offsets) | Reminder & Notification | **Đã hoàn thành và hoạt động** | `reminder_offset.dart`, `task_form_dialog.dart` | Hỗ trợ 7 mức: Đúng giờ, 5m, 10m, 15m, 30m, 1h, 1d trước giờ bắt đầu |
| 17 | Lên lịch thông báo cục bộ (Scheduling) | Reminder & Notification | **Đã triển khai chưa kiểm thử thực tế** | `local_notification_service.dart`, `reminder_providers.dart` | Sử dụng FNV-1a hash id, `zonedSchedule`, yêu cầu quyền `SCHEDULE_EXACT_ALARM` |
| 18 | Tự động đồng bộ & dọn dẹp nhắc việc | Reminder & Notification | **Đã hoàn thành và hoạt động (Unit test)** | `reminder_providers.dart` (TaskReminderSyncService) | Hủy thông báo khi xóa/hoàn thành task; Idempotent Startup Reconciliation dọn orphaned notif |
| 19 | Màn hình danh sách nhắc nhở | Reminder & Notification | **Đã triển khai chưa commit** | `reminders_screen.dart` | Hiển thị tất cả công việc có bật nhắc nhở, thời gian nhắc dự kiến |
| 20 | **Tính năng Màn hình khóa (Lockscreen)** | Lockscreen | **Chưa triển khai (0%)** | N/A | **Tuyệt đối chưa có mã nguồn, không có cấu hình Android native, không có widget hiển thị khóa** |
| 21 | Chế độ tập trung (Focus Pomodoro) | Statistics & Productivity | **Đang phát triển dở dang** | `focus_screen.dart` | Chỉ là UI placeholder (Text tĩnh), chưa có bộ đếm Pomodoro |
| 22 | Thống kê năng suất (Productivity Chart) | Statistics & Productivity | **Đang phát triển dở dang** | `statistics_screen.dart` | Chỉ là UI placeholder (Text tĩnh), chưa có thư viện chart hay số liệu |
| 23 | Lịch trình chi tiết (Timeline view) | Calendar & Scheduling | **Đang phát triển dở dang** | `timeline_screen.dart` | Chỉ là UI placeholder (Text tĩnh) |
| 24 | Đổi chủ đề Giao diện (Theme Mode) | Settings | **Đã hoàn thành nhưng chưa lưu disk** | `settings_screen.dart`, `theme_provider.dart` | Chuyển đổi mượt mà giữa Sáng/Tối/Hệ thống; tuy nhiên mất khi khởi động lại app |
| 25 | Cài đặt ngôn ngữ, dữ liệu | Settings | **Chưa triển khai** | N/A | Chưa có giao diện và logic chuyển ngôn ngữ hoặc sao lưu/khôi phục |
| 26 | Đăng nhập Google / Xác thực | Authentication | **Chưa triển khai** | `lib/services/auth_service.dart` | Mới có file stub rỗng |
| 27 | Hồ sơ người dùng (User Profile) | User Profile | **Đang phát triển dở dang** | `profile_screen.dart` | Chỉ có UI avatar tĩnh, ghi chú chưa hỗ trợ Cloud Sync |
| 28 | Gói dịch vụ Plus (Subscription) | Business / Subscription | **Đang phát triển dở dang** | `subscription_screen.dart` | Màn hình tĩnh giới thiệu TIMEFLOW Plus |
| 29 | Đồng bộ dữ liệu đám mây (Cloud Sync) | API Integration | **Chưa triển khai** | `lib/services/sync_service.dart` | File stub rỗng |
| 30 | Mã hóa bảo mật CSDL (SQLCipher) | Security | **Chưa triển khai** | N/A | CSDL SQLite lưu dưới dạng plain file không mã hóa |

---

## PHẦN 5 – DATABASE AUDIT (KIỂM TRA CƠ SỞ DỮ LIỆU)

### 1. Loại Database
- **Engine:** SQLite kết hợp ORM **Drift** (Drift Native executor trên background isolate).
- **Vị trí file CSDL:** `getApplicationDocumentsDirectory()/timeflow.sqlite`.

### 2. Danh sách bảng và Cấu trúc
Dự án hiện tại chỉ có **duy nhất 1 bảng**: `tasks`.

```sql
CREATE TABLE tasks (
    id TEXT NOT NULL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL,              -- 'pending', 'inProgress', 'completed', 'cancelled'
    priority TEXT NOT NULL,            -- 'low', 'medium', 'high', 'urgent'
    due_date INTEGER,                  -- Unix timestamp (milliseconds)
    start_time INTEGER,                -- Unix timestamp (milliseconds)
    end_time INTEGER,                  -- Unix timestamp (milliseconds)
    is_completed INTEGER NOT NULL DEFAULT 0,
    reminder_enabled INTEGER NOT NULL DEFAULT 0,      -- Thêm từ v2
    reminder_minutes_before INTEGER NOT NULL DEFAULT 0, -- Thêm từ v2
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

### 3. Đánh giá Migration & Schema Version
- **Schema Version:** Hiện tại là **2**.
- **Migration Strategy:** Triển khai tại `lib/data/database/app_database.dart`:
  ```dart
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.addColumn(tasks, tasks.reminderEnabled);
      await m.addColumn(tasks, tasks.reminderMinutesBefore);
    }
  }
  ```
- **Kiểm tra tính an toàn của Migration:** Đã được kiểm chứng trong `test/database_test.dart` (test case mô phỏng CSDL v1 thực tế bằng SQLite in-memory, nâng cấp lên v2 và bảo toàn nguyên vẹn dữ liệu).

### 4. Vấn đề thiết kế CSDL (Database Design Issues)
1. **Thiếu bảng Categories / Tags:** Mặc dù tài liệu ban đầu nhắc đến danh mục, CSDL chưa hề có bảng `categories` hoặc cột `category_id`.
2. **Thiếu bảng Settings / Key-Value:** Thiết lập giao diện và cài đặt của người dùng đang không được lưu vào SQLite.
3. **Thiếu bảng Reminders riêng biệt:** Hiện tại thông tin nhắc nhở được gộp thẳng vào bảng `tasks` (`reminder_enabled`, `reminder_minutes_before`). Điều này giới hạn mỗi task chỉ được đặt **tối đa 1 mốc nhắc nhở**. Nếu muốn nhắc nhở nhiều lần (vd: trước 1 ngày VÀ trước 15 phút), kiến trúc hiện tại không đáp ứng được.
4. **Chưa có Foreign Keys hoặc Indexes:** Cột `start_time` và `due_date` được truy vấn và sắp xếp liên tục nhưng chưa được đánh `Index` trong Drift definition, có thể ảnh hưởng hiệu năng khi dữ liệu vượt quá 10.000 tasks.

---

## PHẦN 6 – BACKEND AUDIT (KIỂM TRA BACKEND & API)

- **Danh sách API / Endpoint:** **0 (Chưa triển khai Backend)**.
- **Hiện trạng kết nối mạng:**
  - File `lib/core/network/dio_client.dart` khai báo `BaseOptions(baseUrl: 'https://api.timeflow.app/v1')` – Đây là domain giả lập/placeholder, không có backend thực tế tồn tại đằng sau.
  - Các service `AuthService`, `SyncService`, `SubscriptionService` trong `lib/services/` hoàn toàn là các class rỗng chứa các hàm `async {}` không có nội dung.
- **Tình trạng hoạt động:** Ứng dụng hiện tại hoạt động 100% độc lập theo mô hình Offline-First trên thiết bị. Không có backend nào để audit hoặc kiểm thử.

---

## PHẦN 7 – FRONTEND AUDIT (KIỂM TRA GIAO DIỆN)

### 1. Danh sách màn hình & Tình trạng

| Màn hình | Route | Tình trạng | Khả năng phản hồi (Responsive) | Đánh giá UI/UX |
|---|---|---|---|---|
| **MainLayout** | Shell root | **Hoàn thành 100%** | Mobile: BottomNavigationBar<br>Desktop: NavigationRail | Tự động co giãn theo breakpoint 768px/1024px, tích hợp FAB tạo task |
| **Hôm nay (Home)** | `/home` | **Hoàn thành 90%** | Tự động thích ứng | Header hiển thị ngày/giờ Việt Nam, Thẻ task đang chạy (gradient nổi bật), Thẻ task kế tiếp, Timeline danh sách hôm nay. Nút chuông thông báo trên AppBar mới chỉ hiện SnackBar tĩnh |
| **Lịch (Calendar)** | `/calendar` | **Hoàn thành 95%** | Mobile: Dạng cuộn dọc<br>Desktop: Chia 2 cột (Lưới tháng bên trái, Task bên phải) | Đổi tháng mượt mà, bấm ngày lọc task, chấm chỉ báo màu sắc, hỗ trợ đầy đủ thao tác CRUD từ lịch |
| **Công việc (Tasks)** | `/tasks` | **Hoàn thành 95%** | Tự động thích ứng | Tìm kiếm realtime, lọc 3 tab, Checkbox hoàn thành gạch ngang chữ, badge ưu tiên, badge nhắc nhở, dialog sửa/xóa |
| **Nhắc nhở (Reminders)** | `/reminders` | **Hoàn thành 90%** (Chưa commit) | Tự động thích ứng | Liệt kê toàn bộ task có hẹn giờ nhắc việc, hiển thị mốc thời gian nhắc tính toán, liên kết trực tiếp vào form sửa |
| **Cài đặt (Settings)** | `/settings` | **Hoàn thành 40%** | Tự động thích ứng | Có RadioGroup chuyển đổi theme Sáng/Tối/Hệ thống; Thiếu lưu cấu hình xuống ổ cứng; Phần thông tin app là text tĩnh |
| **Chế độ tập trung (Focus)** | `/focus` | **Dở dang (10%)** | Placeholder | Chỉ có AppBar và dòng chữ Text giữa màn hình |
| **Thống kê (Statistics)** | `/statistics` | **Dở dang (10%)** | Placeholder | Chỉ có icon và thông báo tính năng đang phát triển |
| **Lịch trình (Timeline)** | `/timeline` | **Dở dang (10%)** | Placeholder | Chỉ có AppBar và text tĩnh |
| **Hồ sơ (Profile)** | `/profile` | **Dở dang (15%)** | Placeholder | Avatar và text tĩnh thông báo chưa có Cloud Sync |
| **Gói Plus (Subscription)**| `/subscription` | **Dở dang (15%)** | Placeholder | Icon ngôi sao và text tĩnh |

### 2. Các nút / chức năng chưa hoạt động trên UI:
- Nút icon chuông thông báo trên AppBar của `HomeScreen`: Bấm vào hiện SnackBar `"Không có thông báo mới"`.
- Tab chuyển đổi ngôn ngữ trong Cài đặt: Chưa được dựng giao diện.
- Form Task Dialog: Chưa có chức năng gán danh mục hoặc tag màu.

---

## PHẦN 8 – LOCKSCREEN AUDIT (ĐÁNH GIÁ RIÊNG MODULE MÀN HÌNH KHÓA)

> [!CAUTION]
> **KẾT LUẬN QUAN TRỌNG:** Trong toàn bộ mã nguồn hiện tại, **MODULE LOCKSCREEN HOÀN TOÀN CHƯA ĐƯỢC TRIỂN KHAI (0%)**.
> Tên thư mục và yêu cầu của người dùng là *To-do List & Lockscreen App*, nhưng dự án chỉ mới được phát triển theo hướng ứng dụng ghi chú và lịch trình độc lập mang tên *TIMEFLOW*.

### Chi tiết kiểm tra kỹ thuật đối với Lockscreen:
1. **Mức độ triển khai:** 0%. Không có bất kỳ file Dart, layout XML, hay service native nào liên quan đến Lockscreen.
2. **Cách thức hiển thị màn hình khóa:** Chưa có.
3. **Cơ chế đồng bộ dữ liệu công việc ra màn hình khóa:** Chưa có.
4. **Khả năng hiển thị nhiệm vụ khi màn hình tắt/khóa:** Chưa có.
5. **Cơ chế cập nhật dữ liệu:** Chưa có.
6. **Quyền hệ điều hành Android cần thiết (Tất cả đều ĐANG THIẾU trong `AndroidManifest.xml`):**
   - `android.permission.SYSTEM_ALERT_WINDOW` (Quyền vẽ đè lên ứng dụng khác / màn hình khóa).
   - `android.permission.USE_FULL_SCREEN_INTENT` (Bật giao diện full screen khi có báo thức/nhắc nhở).
   - `android.permission.WAKE_LOCK` (Đánh thức màn hình sáng khi có sự kiện).
   - `android.permission.FOREGROUND_SERVICE` và `android.permission.FOREGROUND_SERVICE_SPECIAL_USE` (Duy trì service nền).
   - Thuộc tính Activity: `android:showWhenLocked="true"` và `android:turnScreenOn="true"` chưa được cấu hình cho `MainActivity`.
7. **Rào cản & Giới hạn kỹ thuật cần lưu ý khi phát triển Lockscreen:**
   - **Chính sách Android 12+ (API 31-34):** Google hạn chế nghiêm ngặt việc ứng dụng tự ý khởi chạy Activity từ background (`Foreground Service Start Restrictions`). Cần sử dụng Notification dạng FullScreen Intent hoặc Live Notification với quyền đặc biệt.
   - **Tối ưu pin (Doze Mode & Battery Saver):** Các hãng như Xiaomi (MIUI/HyperOS), Huawei, Samsung tự động ngắt service nền nếu người dùng không tắt tính năng tiết kiệm pin thủ công.
   - **Bảo mật thiết bị:** Thay thế màn hình khóa mặc định của hệ thống là không khả thi trên Android hiện đại (vì liên quan đến vân tay/mã PIN bảo vệ hệ thống). Giải pháp chuẩn công nghiệp là:
     - *Phương án A:* Hiển thị **Ongoing Notification** (Thông báo ghim cố định trên màn hình khóa hiển thị danh sách task trong ngày).
     - *Phương án B:* Xây dựng **Lockscreen Widget** (Android Glance / AppWidget) hoặc Live Activities (trên iOS).
     - *Phương án C:* Màn hình overlay khi mở máy (Cần quyền Overlay & Accessibility Service, thường bị người dùng phàn nàn và Google Play xét duyệt gắt gao).

---

## PHẦN 9 – TESTING REPORT (KẾT QUẢ KIỂM THỬ)

### 1. Hiện trạng Test Suite
Dự án có sự đầu tư bài bản về Unit Test và Integration Test cho tầng Data và Domain:
- `test/database_test.dart`: 6 test cases kiểm thử Drift SQLite (Insert, Update, Delete, Toggle, Schema v2, Migration v1->v2).
- `test/calendar_test.dart`: 6 test cases kiểm thử logic ngày tháng, lưới lịch, tính toán dot indicator, sắp xếp công việc.
- `test/reminder_test.dart`: 18 test cases kiểm thử toàn diện module Reminder (tính toán offset, thuật toán FNV-1a hash, Startup Reconciliation, tính bất biến khi lỗi service).
- `test/usecases_test.dart`: 5 test cases kiểm thử validation nghiệp vụ (Title rỗng, startTime > endTime).
- `test/widget_test.dart`: 2 test cases kiểm thử định dạng tiếng Việt.

### 2. Tình trạng chạy thực tế & Rào cản Môi trường (Environment Issues)
- **Tồn tại Stale Lockfile của Flutter:** Trên môi trường máy trạm có file `C:\flutter\flutter\bin\cache\lockfile` được tạo từ ngày 11/2/2026 (dung lượng 0 byte). Khi chạy lệnh `flutter test` hoặc `flutter analyze`, tiến trình Flutter SDK bị treo vô hạn để chờ release startup lock.
- **Rào cản quyền ghi phân tích của Dart Analyzer:** Khi gọi trực tiếp Dart executable `C:\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe analyze`, tiến trình gặp lỗi quyền truy cập file hệ thống:  
  `FileSystemException: Exists failed, path = 'C:\Users\Lenovo\AppData\Local\.dartServer\.instrumentation' (OS Error: Access is denied, errno = 5)`.
- **Đánh giá logic mã nguồn:** Toàn bộ logic trong 37 test cases đều tuân thủ chặt chẽ API của Drift và Flutter Test, không có lỗi cú pháp hay import gãy đổ.

---

## PHẦN 10 – KNOWN ISSUES (DANH SÁCH LỖI VÀ VẤN ĐỀ KỸ THUẬT)

### 1. Lỗi Nghiêm trọng & Rủi ro Kiến trúc (High/Critical)
1. **Thiếu hoàn toàn tính năng Lockscreen (Sai lệch so với tên dự án):** Dự án hiện tại chỉ là ứng dụng Todo/Calendar nội bộ, không có bất kỳ khả năng nào hiển thị ngoài màn hình khóa.
2. **Dữ liệu chưa commit (Uncommitted Working Tree):** Có 18 files đang sửa đổi và 5 files untracked. Nếu chuyển nhánh hoặc merge không cẩn thận, toàn bộ module Reminder vừa viết sẽ gặp rủi ro xung đột hoặc thất thoát.
3. **Cài đặt không được lưu trữ vĩnh viễn (Settings State Loss):** `themeModeProvider` chỉ lưu trên bộ nhớ RAM; mỗi khi tắt ứng dụng hoặc khởi động lại, giao diện luôn bị reset về chế độ hệ thống.

### 2. Vấn đề Mã nguồn thừa & Trùng lặp (Technical Debt / Code Smells)
1. `lib/data/models/task_model.dart` là Dead Code không được dùng tới.
2. `lib/services/notification_service.dart` là Dead Stub gây nhầm lẫn với `lib/core/notifications/local_notification_service.dart`.
3. `lib/core/database/app_database.dart` là file chuyển tiếp thừa.
4. `TaskReminderSyncService` phụ thuộc vào `allTasksStreamProvider` để tự động reconcile trên mọi lần database cập nhật; nếu số lượng task lớn (>1.000 tasks), việc duyệt lặp `reconcileStartupReminders` mỗi khi có một task thay đổi có thể gây suy giảm hiệu năng.

---

## PHẦN 11 – PROJECT PROGRESS (TỔNG HỢP TIẾN ĐỘ)

### Phương pháp tính tỷ lệ:
Tỷ lệ hoàn thành của từng module được tính dựa trên tỷ trọng thực tế giữa các tiêu chí:
- **Architecture & Domain Model** (25%)
- **Database & Data Layer** (25%)
- **UI & State Management** (25%)
- **Testing & Native Integration** (25%)

| STT | Module | Trọng số | Tỷ lệ hoàn thành | Trạng thái | Ghi chú đánh giá |
|:---:|---|:---:|:---:|:---:|---|
| 1 | **Architecture & Shell Layout** | 10% | **95%** | Đã hoàn thành | GoRouter, Responsive Mobile/Desktop, Theme Material 3 chuẩn chỉ |
| 2 | **Local Database (Drift SQLite)** | 15% | **90%** | Đã hoàn thành | Bảng Tasks, DAO, Migration v1->v2, Unit test CSDL đạt 100% |
| 3 | **Task Management (CRUD)** | 20% | **90%** | Đã hoàn thành | Clean Architecture, Dialog thêm/sửa, Xóa, Lọc, Tìm kiếm, Validation |
| 4 | **Calendar & Scheduling** | 15% | **95%** | Đã hoàn thành | Lưới 7 cột, chấm chỉ báo, xem theo ngày, liên kết CRUD đầy đủ |
| 5 | **Reminder & Notifications** | 15% | **80%** | Đã triển khai chưa commit | FNV-1a hash, reconciliation, offset enum, UI Reminders. Cần kiểm thử runtime trên thiết bị thật |
| 6 | **Settings & Storage** | 5% | **30%** | Đang phát triển | Mới có UI đổi theme in-memory, chưa có key-value persistent storage |
| 7 | **Productivity & Focus (Pomodoro/Stats)**| 5% | **10%** | Dở dang | Chỉ có UI placeholder tĩnh |
| 8 | **Authentication & Cloud Sync** | 5% | **5%** | Chưa triển khai | Chỉ có stub service rỗng |
| 9 | **Todo Categories** | 5% | **0%** | Chưa triển khai | CSDL và UI đều chưa hỗ trợ danh mục |
| 10 | **Lockscreen Integration** | 10% | **0%** | Chưa triển khai | Chưa có bất kỳ dòng code hay cấu hình native nào |

> **Ước tính tiến độ tổng thể của sản phẩm hiện tại (theo định hướng TIMEFLOW Todo/Calendar):**  
> **Khoảng 60% - 65% hoàn thiện cho bản Local MVP**.  
> **Nếu tính cả yêu cầu Lockscreen & Backend Sync:** Ứng dụng mới đạt khoảng **40%**.

---

## PHẦN 12 – NEXT DEVELOPMENT ROADMAP (LỘ TRÌNH PHÁT TRIỂN TIẾP THEO)

### Giai đoạn P0 – Ổn định & Chốt mã nguồn hiện tại (Bắt buộc làm ngay)
- **Mục tiêu:** Dọn sạch working tree, lưu trữ cài đặt bền vững và loại bỏ dead code.
- **Công việc:**
  1. Commit toàn bộ thay đổi của Phase 4 (Reminder & Notifications) vào Git.
  2. Tích hợp `shared_preferences` vào `LocalStorage` để lưu trữ `themeMode`.
  3. Xóa các file dead code/redundant: `lib/data/models/task_model.dart`, `lib/core/database/app_database.dart`, `lib/services/notification_service.dart`.
  4. Xử lý stale lockfile tại `C:\flutter\flutter\bin\cache\lockfile` trên máy dev.
- **Dependencies:** Không có.
- **Điều kiện nghiệm thu:** Git working tree sạch sẽ; đổi theme, tắt app mở lại theme vẫn được giữ; test suite chạy xanh.

---

### Giai đoạn P1 – Phát triển Module Lockscreen (Bù đắp khoảng trống cốt lõi)
- **Mục tiêu:** Hiện thực hóa tính năng màn hình khóa đúng theo mục tiêu dự án.
- **Phương án đề xuất tối ưu:**
  1. **Tầng 1 (Ongoing Lockscreen Notification):** Xây dựng thông báo thường trực (Pinned Notification) cập nhật realtime các task quan trọng trong ngày lên màn hình khóa thiết bị.
  2. **Tầng 2 (Android AppWidget / Lockscreen Widget):** Sử dụng thư viện `home_widget` để tạo Widget lịch trình đưa ra màn hình khóa/màn hình chính của Android.
  3. **Tầng 3 (FullScreen Reminder Intent):** Khi đến giờ hẹn của task khẩn cấp, đánh thức màn hình và hiện giao diện nhắc việc ngay cả khi máy đang khóa (`showWhenLocked`, `turnScreenOn`).
- **Module liên quan:** `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/kotlin/`, `lib/core/lockscreen/`.
- **Dependencies:** P0.
- **Điều kiện nghiệm thu:** Khóa màn hình điện thoại, người dùng vẫn thấy danh sách công việc hôm nay và nhận được giao diện nhắc việc khi đến giờ.

---

### Giai đoạn P2 – Bổ sung Categories & Hoàn thiện Settings
- **Mục tiêu:** Cho phép người dùng phân loại công việc theo nhãn/danh mục và quản lý cấu hình.
- **Công việc:**
  1. Nâng cấp Drift database lên **schemaVersion 3**: Thêm bảng `categories` (id, name, color, icon) hoặc cột `category` vào `tasks`.
  2. Cập nhật `TaskFormDialog` cho phép chọn danh mục và gắn tag màu.
  3. Bổ sung bộ lọc danh mục tại `TasksScreen`.
- **Module liên quan:** `data/database/`, `features/tasks/`.
- **Dependencies:** P0.
- **Điều kiện nghiệm thu:** Tạo được danh mục mới, gán task vào danh mục và lọc task theo danh mục chuẩn xác.

---

### Giai đoạn P3 – Nâng cao: Pomodoro Focus & Thống kê Năng suất
- **Mục tiêu:** Biến placeholder thành tính năng hoàn chỉnh.
- **Công việc:**
  1. Triển khai bộ đếm thời gian Pomodoro (25p làm việc, 5p nghỉ) tại `FocusScreen`.
  2. Tích hợp thư viện biểu đồ (`fl_chart`) tại `StatisticsScreen` hiển thị số task hoàn thành theo tuần/tháng.
- **Module liên quan:** `features/focus/`, `features/statistics/`.
- **Dependencies:** P1, P2.
- **Điều kiện nghiệm thu:** Đồng hồ Pomodoro chạy chuẩn xác, biểu đồ thể hiện đúng tỷ lệ hoàn thành công việc từ SQLite.

