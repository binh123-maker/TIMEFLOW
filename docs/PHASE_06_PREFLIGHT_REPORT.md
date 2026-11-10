# BÁO CÁO TIỀN KHỞI ĐỘNG KỸ THUẬT (PHASE 06 PRE-FLIGHT REPORT)
**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian kiểm tra:** 07/11/2026  
**Chuyên gia:** Senior Flutter Developer & Android Native Architect  

---

## 1. KẾT QUẢ ĐÁNH GIÁ TẦNG FLUTTER (FLUTTER LAYER ASSESSMENT)
- **Task Entity (`lib/features/tasks/domain/entities/task_entity.dart`):** Cung cấp cấu trúc dữ liệu hoàn chỉnh gồm: `id`, `title`, `description`, `status` (`pending`, `inProgress`, `completed`, `cancelled`), `priority` (`low`, `medium`, `high`, `urgent`), `dueDate`, `startTime`, `endTime`, `isCompleted`, `reminderEnabled`, `reminderMinutesBefore`, `createdAt`, `updatedAt`.
- **Task Repository (`lib/data/repositories/task_repository_impl.dart`):** Cầu nối chuẩn Clean Architecture giữa Drift DAO và Domain Layer.
- **Task Streams & Selection Logic (`lib/features/tasks/presentation/providers/task_providers.dart`):**
  - `allTasksStreamProvider`: Lắng nghe thay đổi toàn diện từ CSDL Drift SQLite.
  - `todayTasksStreamProvider`: Lọc các task thuộc ngày hôm nay (`dueDate` hoặc `startTime` trùng khớp ngày hiện tại).
  - `currentTaskStreamProvider`: Lấy công việc chưa hoàn thành đang diễn ra (`startTime <= now < endTime`).
  - `nextTaskStreamProvider`: Lấy công việc chưa hoàn thành kế tiếp (`startTime > now`), sắp xếp tăng dần theo `startTime`.
  - Đánh giá: Logic rõ ràng, chặt chẽ, đóng vai trò **Single Source of Truth** cho toàn bộ ứng dụng.
- **Local Storage & Theme Provider:** Đã hoàn thiện lưu trữ bền vững với `shared_preferences` và `SharedPrefsLocalStorage`, pass 8/8 test cases.
- **Notification Service (`lib/core/notifications/local_notification_service.dart`):** Triển khai thông báo hẹn giờ bằng `flutter_local_notifications` với timezone và ID FNV-1a. Hoạt động độc lập và không xung đột với Ongoing Notification sắp phát triển.

---

## 2. KẾT QUẢ ĐÁNH GIÁ TẦNG ANDROID NATIVE (ANDROID NATIVE LAYER ASSESSMENT)
- **MainActivity (`android/app/src/main/kotlin/com/timeflow/timeflow/MainActivity.kt`):**
  - Hiện tại kế thừa `FlutterActivity()`, chưa đăng ký MethodChannel nào.
  - Sẵn sàng tích hợp `configureFlutterEngine(flutterEngine)` để đăng ký `MethodChannel("com.timeflow.lockscreen/bridge")`.
- **AndroidManifest.xml:**
  - Package: `com.timeflow.timeflow`.
  - Quyền hiện có: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`.
  - Chưa có `timeflow_lockscreen_status` notification channel trong native (sẽ tạo trong Sprint 6.1 bằng `NotificationManager.createNotificationChannel`).
- **Gradle & Toolchain:**
  - `build.gradle.kts`: Gradle 8.11.1, Kotlin 2.2.20, Java 17, `desugar_jdk_libs:2.1.4`.
  - `compileSdk`: 36 (Android 15), `targetSdk`: 36, `minSdk`: 21 (Android 5.0+).
  - Tương thích 100% với các API NotificationCompat của AndroidX.

---

## 3. ĐÁNH GIÁ KIẾN TRÚC DỮ LIỆU & RỦI RO (DATA ARCHITECTURE & SAFETY)
1. **Một nguồn dữ liệu duy nhất:** Drift SQLite là nơi lưu trữ duy nhất. Tầng Native Android chỉ là tầng hiển thị (Presentation / RemoteViews), nhận payload đóng gói từ Flutter thông qua MethodChannel. Không có cơ chế Native tự ý mở file SQLite để tránh xung đột ghi và hỏng CSDL.
2. **Quyền riêng tư màn hình khóa:** Màn hình khóa của Android có các mức cài đặt: "Hiển thị tất cả", "Ẩn nội dung nhạy cảm", và "Không hiển thị thông báo". Do đó, Ongoing Notification không thể đảm bảo hiển thị 100% trên mọi thiết bị nếu người dùng cố ý tắt thông báo màn hình khóa trong Settings hệ điều hành. Ứng dụng sẽ thiết lập `NotificationCompat.VISIBILITY_PUBLIC` và hỗ trợ chế độ tóm tắt nếu cần.
3. **Phân biệt Home Screen Widget & Lockscreen Widget:** Hệ điều hành Android 12-15 không hỗ trợ widget tùy biến của bên thứ ba trên màn hình khóa một cách đồng nhất giữa các hãng (Samsung, Xiaomi, Pixel). Do đó, thành phần Widget trong Phase 06 được định vị chính xác là **Home Screen Widget** (Tiện ích màn hình chính), phân biệt rõ với Ongoing Notification (hiển thị trên màn hình khóa).
4. **Không chạy Background Polling liên tục:** Sử dụng cơ chế lắng nghe phản ứng (Riverpod Stream Listener). Khi dữ liệu thay đổi, so sánh payload mới với payload gần nhất (`previousPayload == newPayload`). Nếu dữ liệu giống hệt nhau, không gọi MethodChannel cập nhật notification để bảo vệ tuổi thọ pin.
5. **Không dùng `SYSTEM_ALERT_WINDOW`:** Tuyệt đối tuân thủ chính sách bảo mật Google Play.

---

## 4. KẾT LUẬN TIỀN KHỞI ĐỘNG
- Mã nguồn và cấu hình môi trường hoàn toàn ổn định, không có xung đột kiến trúc.
- Sẵn sàng tiến hành triển khai **Sprint 6.1: Ongoing Notification + Native Bridge**.

