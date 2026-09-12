# TIMEFLOW ⏳

Ứng dụng quản lý thời gian, công việc, lịch trình và nhắc nhở theo hướng **Local-first / Offline-first**.

---

## 1. GIỚI THIỆU DỰ ÁN

**TIMEFLOW** giúp người dùng tối ưu hóa thời gian trong ngày với trải nghiệm mượt mà, trực quan và hiện đại trên cả thiết bị di động (Android) và máy tính (Windows Desktop).

### Mục tiêu chính
* **Tạo & theo dõi công việc**: Quản lý task với thời gian bắt đầu, kết thúc và thứ tự ưu tiên.
* **Theo dõi lịch trình trong ngày**: Nắm rõ công việc đang diễn ra (Current Task) và công việc tiếp theo (Next Task).
* **Local-first / Offline-first**: Dữ liệu lưu giữ trực tiếp trên thiết bị, hoạt động phản hồi tức thì không cần kết nối mạng.
* **Đa nền tảng**: Hỗ trợ tối ưu giao diện cho Android (Mobile Navigation) và Windows (Desktop Sidebar Navigation).
* **Khả năng mở rộng**: Chuẩn bị sẵn kiến trúc cho Cloud Sync, Tài khoản Plus và Hệ thống Admin ở các Phase sau.

---

## 2. TECH STACK

* **Framework**: Flutter (Dart)
* **Design System**: Material 3 (Light Mode & Dark Mode)
* **State Management**: Riverpod (`flutter_riverpod`)
* **Routing**: GoRouter (`go_router`)
* **Formatting & i18n**: `intl` (Hỗ trợ tiếng Việt)
* **Typography**: Google Fonts (Inter)
* **Local Database Structure**: Chuẩn bị kiến trúc SQLite / Drift
* **Network Architecture**: Chuẩn bị kiến trúc Dio REST Client

---

## 3. KIẾN TRÚC DỰ ÁN

Dự án áp dụng kiến trúc:
> **Feature-First + Clean Architecture (Light) + Repository Pattern**

Tách biệt rõ ràng các tầng:
* `core/`: Chứa hằng số, chủ đề (theme), router, tiện ích, và các cấu trúc hạ tầng (database, network, storage, notification).
* `data/`: Chứa Data Models, Interfaces và Repositories.
* `features/`: Chia theo từng tính năng độc lập (home, calendar, tasks, statistics, timeline, settings, profile,...), mỗi feature chứa giao diện (`presentation`) và logic (`providers`).
* `services/`: Chứa các service stub cho Auth, Cloud Sync, Notification và Subscription cho các Phase tiếp theo.

---

## 4. CẤU TRÚC THƯ MỤC (FOLDER STRUCTURE)

```text
lib/
├── core/
│   ├── constants/       # Hằng số màu sắc, chữ, layout breakpoint
│   ├── theme/           # Cấu hình Light Mode, Dark Mode & Theme Provider
│   ├── router/          # Cấu hình GoRouter đa nền tảng
│   ├── utils/           # Helper format ngày tháng Tiếng Việt
│   ├── network/         # Client Dio kết nối REST API (chuẩn bị)
│   ├── database/        # Cấu trúc Local Database (chuẩn bị)
│   ├── notifications/   # Cấu trúc thông báo nhắc việc (chuẩn bị)
│   └── storage/         # Lưu trữ key-value cài đặt local
│
├── data/
│   ├── models/          # TaskModel, Enums status & priority
│   └── repositories/    # TaskRepository Interface & Mock implementation
│
├── features/
│   ├── main_layout/     # Responsive Shell (BottomNav cho Mobile, NavigationRail cho Desktop)
│   ├── home/            # Giao diện Hôm nay (Header, Live Clock, Task hiện tại, Task tiếp theo, Schedule)
│   ├── calendar/        # Giao diện Lịch trình (Skeleton)
│   ├── tasks/           # Giao diện Danh sách công việc (Skeleton)
│   ├── statistics/      # Giao diện Thống kê năng suất (Skeleton)
│   ├── timeline/        # Giao diện Lịch trình chi tiết (Skeleton)
│   ├── reminders/       # Giao diện Nhắc nhở (Skeleton)
│   ├── focus/           # Giao diện Tập trung Pomodoro (Skeleton)
│   ├── subscription/    # Giao diện Gói TIMEFLOW Plus (Skeleton)
│   ├── profile/         # Giao diện Hồ sơ cá nhân (Skeleton)
│   └── settings/        # Giao diện Cài đặt (Chuyển đổi Light/Dark mode)
│
├── services/            # Stub services cho Auth, Sync, Notifications, Subscription
└── main.dart            # Khởi chạy ProviderScope và MaterialApp.router
```

---

## 5. CÁCH CHẠY DỰ ÁN

### Yêu cầu tiên quyết
* Flutter SDK (phiên bản >= 3.19.0)
* Dart SDK (phiên bản >= 3.3.0)

### Cài đặt thư viện & Sinh mã Drift Database
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Format code & Kiểm tra mã nguồn
```bash
dart format lib test
flutter analyze
```

### Chạy Unit & Database Tests
```bash
flutter test
```

### Chạy ứng dụng trên Android
```bash
flutter run -d android
```

### Chạy ứng dụng trên Windows Desktop
```bash
flutter run -d windows
```

---

## 6. CÁC PHASE PHÁT TRIỂN TIẾP THEO

* **Phase 1 (HOÀN THÀNH)**: Khởi tạo dự án, kiến trúc Clean Architecture + Riverpod + GoRouter, Material 3 Light/Dark theme, Responsive layout Mobile/Desktop.
* **Phase 2 (HOÀN THÀNH)**: Tích hợp Local Database bằng Drift & SQLite (`timeflow.sqlite`), hoàn thiện Task CRUD (Create, Watch Stream, Update, Delete, Toggle Completion), Title & Time Validation, kết nối dữ liệu thật cho Home Screen và Tasks Screen.
* **Phase 3**: Tích hợp Local Notifications nhắc giờ công việc trên Android và Windows.
* **Phase 4**: Hoàn thiện chế độ Tập trung (Pomodoro Timer) và Biểu đồ Thống kê Năng suất.
* **Phase 5**: Backend API, Google Login, Đồng bộ dữ liệu Cloud Sync cho tài khoản TIMEFLOW Plus và Hệ thống Admin.

