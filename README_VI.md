# TIMEFLOW ⏳

**Ứng dụng quản lý thời gian, công việc và lịch trình cá nhân theo hướng Local-First / Offline-First cho Android & Windows.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-green.svg)](https://flutter.dev)
[![Offline-First](https://img.shields.io/badge/Architecture-Offline--First-orange.svg)](PRIVACY_POLICY.md)
[![Zero Trackers](https://img.shields.io/badge/Trackers-0-brightgreen.svg)](PRIVACY_POLICY.md)

---

## 1. Giới thiệu

**TIMEFLOW** là ứng dụng mã nguồn mở giúp bạn quản lý công việc và thời gian hàng ngày một cách trực quan, mượt mà và tôn trọng tối đa quyền riêng tư. 

Khác với các ứng dụng To-do List thông thường chỉ hiển thị danh sách việc tĩnh, TIMEFLOW tập trung vào **ngữ cảnh thời gian thực (Time-awareness)**: giúp bạn nhìn thấy ngay việc **Đang diễn ra (Current Task)** và việc **Kế tiếp (Next Task)** ngay từ màn hình khóa điện thoại và màn hình chính Android.

### Điểm nổi bật
- **Hoạt động 100% Offline (Local-First):** Toàn bộ dữ liệu nằm trong máy của bạn (`timeflow.sqlite`). Ứng dụng phản hồi tức thì, không cần tài khoản, không cần kết nối mạng.
- **Tiện ích màn hình chính (Android Home Widgets):** Hỗ trợ 2 kích thước widget tiện lợi:
  - **Compact Widget (2×1):** Hiển thị thanh tiến độ trong ngày, công việc đang làm và việc sắp tới.
  - **Expanded Widget (4×2):** Thống kê chi tiết, khung thời gian làm việc và danh sách việc tiếp theo.
- **Thông báo thường trực trên màn hình khóa (Lockscreen Ongoing Notification):** Cập nhật im lặng và tự động chuyển việc theo thời gian thực; không làm phiền người dùng nhưng luôn sẵn sàng khi bạn bật sáng màn hình.
- **Nhắc nhở chính xác (Exact Reminders):** Sử dụng `AlarmManager` của Android để đổ chuông thông báo đúng từng phút theo lịch hẹn, tự khôi phục lịch nhắc sau khi khởi động lại máy.
- **Lịch tháng trực quan:** Lưới lịch 7 cột (T2–CN) với các dấu chấm chỉ báo số lượng công việc, lọc nhanh công việc theo từng ngày.
- **Giao diện Material 3:** Hỗ trợ Light Mode & Dark Mode hoàn chỉnh, typography Inter nạp sẵn offline.

---

## 2. Kiến trúc & Công nghệ

Dự án áp dụng mô hình **Feature-First + Clean Architecture (Light) + Repository Pattern**:

- **Framework:** [Flutter](https://flutter.dev) (Dart 3.x, sound null-safety).
- **Quản lý trạng thái & DI:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`).
- **Cơ sở dữ liệu cục bộ:** SQLite thông qua [Drift ORM](https://drift.simonbinder.eu) (`drift`, `sqlite3_flutter_libs`).
- **Điều hướng:** [GoRouter](https://pub.dev/packages/go_router) (`go_router`) với `StatefulShellRoute.indexedStack`.
- **Thông báo & Nhắc nhở:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) & `timezone`.
- **Cầu nối Android Native:** Kotlin (`LockscreenNotificationManager.kt`, `TimeflowWidgetCompactProvider.kt`, `TimeflowWidgetExpandedProvider.kt`).
- **Typography:** Font chữ Inter nạp hoàn toàn từ tài nguyên cục bộ (`assets/fonts/`).

---

## 3. Cấu trúc thư mục

```text
lib/
├── core/
│   ├── constants/       # Hằng số màu sắc, giao diện, breakpoints
│   ├── notifications/   # Service quản lý thông báo nhắc nhở cục bộ
│   ├── router/          # Cấu hình GoRouter đa tab
│   ├── storage/         # Lưu trữ cài đặt Theme (SharedPreferences)
│   ├── theme/           # Cấu hình Material 3 Light/Dark (font Inter offline)
│   └── utils/           # Định dạng ngày giờ tiếng Việt (DateFormatter)
├── data/
│   └── database/        # Drift SQLite Database (Tables, DAOs, Migrations)
├── features/
│   ├── calendar/        # Màn hình Lịch tháng & lọc task theo ngày
│   ├── home/            # Màn hình Hôm nay (Current Task, Next Task, Schedule)
│   ├── home_widget/     # Logic đồng bộ và cung cấp dữ liệu cho Home Widget
│   ├── lockscreen/      # Cầu nối gửi payload ra Lockscreen Notification
│   ├── main_layout/     # Responsive layout (BottomNav cho mobile, NavRail cho desktop)
│   ├── reminders/       # Màn hình quản lý các lịch hẹn nhắc việc
│   ├── settings/        # Cài đặt giao diện Sáng / Tối / Hệ thống
│   └── tasks/           # Quản lý CRUD công việc (Form tạo, Sửa, Xóa)
└── main.dart            # Điểm vào chính của ứng dụng
```

---

## 4. Hướng dẫn cài đặt & Chạy ứng dụng

### Yêu cầu môi trường
- Flutter SDK (phiên bản 3.x stable)
- Dart SDK (>= 3.11.4)
- JDK 17
- Android SDK (API 34/35)

### Cài đặt thư viện & Sinh mã Drift Database
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Chạy kiểm thử tự động
```bash
flutter test
```

### Chạy trên thiết bị Android
```bash
flutter run -d android
```

### Build APK Debug
```bash
flutter build apk --debug
```

---

## 5. Quyền hệ thống & Tính riêng tư

Ứng dụng **không có quyền `INTERNET` trong bản Release**. Dữ liệu của bạn được đảm bảo an toàn tuyệt đối trên máy.

- `POST_NOTIFICATIONS`: Bắt buộc trên Android 13+ để hiện thông báo nhắc việc và lịch trình trên màn hình khóa.
- `SCHEDULE_EXACT_ALARM`: Dùng để hẹn giờ thông báo chính xác từng phút.
- `RECEIVE_BOOT_COMPLETED`: Tự động khôi phục lịch nhắc việc sau khi khởi động lại điện thoại.

Chi tiết xem tại [Chính sách quyền riêng tư (PRIVACY_POLICY.md)](PRIVACY_POLICY.md).

---

## 6. Giấy phép mã nguồn mở (License)

Dự án phát hành dưới giấy phép **[GNU General Public License v3.0 (GPLv3)](LICENSE)**.
Bộ font chữ Inter phát hành dưới giấy phép **[SIL Open Font License 1.1](assets/fonts/LICENSE_OFL.txt)**.

