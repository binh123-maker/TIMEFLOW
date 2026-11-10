# BÁO CÁO TRIỂN KHAI SPRINT 6.1 (PHASE 06.1 IMPLEMENTATION REPORT)
## MODULE ONGOING LOCKSCREEN NOTIFICATION & NATIVE BRIDGE
**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian thực hiện:** 07/11/2026  
**Chuyên môn:** Senior Flutter Developer & Android Native (Kotlin) Architect  
**Trạng thái:** **HOÀN THÀNH TOÀN DIỆN SPRINT 6.1 (CODE VERIFIED, 57/57 TESTS PASS, BUILD VERIFIED)**  

---

## 1. CÁC FILE ĐÃ TẠO MỚI TRONG SPRINT 6.1

### A. Tầng Flutter (Dart):
1. `lib/features/lockscreen/domain/models/lockscreen_payload.dart`:
   - `LockscreenTaskSummary`: Thực thể tóm tắt công việc (ID, tiêu đề, mô tả, khung giờ, mức độ ưu tiên, trạng thái hoàn thành).
   - `LockscreenPayload`: Cấu trúc dữ liệu gốc chứa `version: 1`, `currentTask`, `nextTask`, `totalTasksToday`, `completedTasksToday`, `headerDate`.
   - Cung cấp `toJson()`, `fromJson()`, và toán tử `operator ==` / `hashCode` phục vụ chống trùng lặp (deduplication).
2. `lib/features/lockscreen/data/services/lockscreen_bridge_service.dart`:
   - `ILockscreenBridge`: Interface trừu tượng giao tiếp với tầng Native.
   - `MethodChannelLockscreenBridge`: Triển khai qua `MethodChannel('com.timeflow.lockscreen/bridge')`.
   - Tích hợp bộ nhớ đệm `_lastPayload` để bỏ qua các cuộc gọi IPC khi dữ liệu không thay đổi.
   - Bắt và xử lý `PlatformException` an toàn, không bao giờ gây crash ứng dụng.
   - Kiểm tra nền tảng (`defaultTargetPlatform != TargetPlatform.android`), đảm bảo tương thích 100% với Windows Desktop (không gọi lệnh Android trên Windows).
3. `lib/features/lockscreen/presentation/providers/lockscreen_providers.dart`:
   - `lockscreenBridgeProvider`: Provider cung cấp service bridge.
   - `lockscreenPayloadProvider`: Provider tính toán `LockscreenPayload` từ `currentTaskStreamProvider`, `nextTaskStreamProvider` và `todayTasksStreamProvider`.
   - `lockscreenAutoSyncListenerProvider`: Listener tự động kích hoạt cập nhật notification khi có thay đổi từ luồng CSDL.
4. `test/lockscreen_test.dart`:
   - 11 automated test cases kiểm thử toàn diện: serialization, null safety, deduplication, error handling, task selection, completed task filtering.

### B. Tầng Android Native (Kotlin):
1. `android/app/src/main/kotlin/com/timeflow/timeflow/LockscreenNotificationManager.kt`:
   - Tạo Notification Channel: `timeflow_lockscreen_status` (`IMPORTANCE_LOW` – im lặng, không phát âm thanh làm phiền mỗi lần cập nhật).
   - Thiết lập `VISIBILITY_PUBLIC` để hiển thị trên màn hình khóa.
   - Xây dựng Ongoing Notification với Notification ID cố định `1001` (chống sinh nhiều thông báo rác).
   - Hỗ trợ hiển thị Current Task ("Đang làm: ..."), Next Task ("Kế tiếp: ..."), và định dạng mở rộng `NotificationCompat.BigTextStyle`.
   - Cung cấp nút hành động ("Mở TIMEFLOW") kèm `PendingIntent` điều hướng an toàn (`FLAG_IMMUTABLE`).
   - Kiểm tra quyền `POST_NOTIFICATIONS` trên Android 13+ (API 33+).
2. `android/app/src/main/kotlin/com/timeflow/timeflow/MainActivity.kt`:
   - Đăng ký `MethodChannel("com.timeflow.lockscreen/bridge")`.
   - Xử lý các method: `updateLockscreenNotification` và `cancelLockscreenNotification`.

---

## 2. CÁC FILE ĐÃ CHỈNH SỬA
1. `lib/main.dart`:
   - Khởi tạo lắng nghe `ref.watch(lockscreenAutoSyncListenerProvider)` trong hàm `build()`.
   - Kích hoạt cập nhật thông báo khởi động ban đầu trong `addPostFrameCallback`.
2. `docs/LOCKSCREEN_TECHNICAL_DESIGN.md`:
   - Cập nhật và điều chỉnh các giả định kỹ thuật theo đúng nguyên tắc bảo mật và hạn chế của hệ điều hành Android.

---

## 3. SO SÁNH KIẾN TRÚC TRƯỚC VÀ SAU SPRINT 6.1

```text
TRƯỚC SPRINT 6.1:
+-------------------------------------------------------------+
| TIMEFLOW Flutter (Tasks, Calendar, Reminder, Theme)         |
+-------------------------------------------------------------+
                              |
                     (Chưa có kết nối Native)
                              v
             [Màn hình khóa Android: HOÀN TOÀN TRỐNG (0%)]

SAU SPRINT 6.1:
+-------------------------------------------------------------+
| Drift SQLite Database -> Reactive Stream Providers          |
|                           |                                 |
|          +----------------v----------------+                |
|          |    LockscreenPayloadProvider    |                |
|          +----------------+----------------+                |
|                           |                                 |
|          +----------------v----------------+                |
|          |   MethodChannelLockscreenBridge | (Deduplication)|
+---------------------------|---------------------------------+
                            | MethodChannel IPC
+---------------------------v---------------------------------+
| Android MainActivity -> LockscreenNotificationManager       |
|                           |                                 |
|          +----------------v----------------+                |
|          | Channel: timeflow_lockscreen    |                |
|          | ID: 1001 (Ongoing = true)       |                |
|          | VISIBILITY_PUBLIC               |                |
|          +----------------+----------------+                |
|                           |                                 |
|       [Hiển thị trực tiếp trên Màn hình khóa Android]        |
+-------------------------------------------------------------+
```

---

## 4. LUỒNG DỮ LIỆU VÀ CƠ CHẾ METHODCHANNEL

1. **Sinh dữ liệu:** Khi người dùng thêm, sửa, xóa hoặc tick hoàn thành một Task trong ứng dụng, CSDL SQLite kích hoạt stream cập nhật.
2. **Tính toán:** `lockscreenPayloadProvider` tính lại trạng thái:
   - `Current Task`: Tìm task chưa xong có `startTime <= now < endTime`.
   - `Next Task`: Tìm task chưa xong có `startTime > now`, sắp xếp theo giờ bắt đầu tăng dần.
   - Thống kê: Tính tổng số task hôm nay và số task đã hoàn thành.
3. **Lọc trùng lặp (Deduplication):** `MethodChannelLockscreenBridge` so sánh payload với `_lastPayload`. Nếu giống nhau 100%, hủy bỏ lệnh gọi IPC để bảo vệ pin và hiệu năng.
4. **Gửi lệnh Native:** Gọi `MethodChannel.invokeMethod('updateLockscreenNotification', payload.toJson())`.
5. **Hiển thị:** `LockscreenNotificationManager` trên Kotlin cập nhật lại `Notification ID: 1001` bằng `NotificationManagerCompat`.

---

## 5. QUYỀN VÀ BẢO MẬT HỆ ĐIỀU HÀNH ANDROID

1. **Quyền thông báo:**
   - Đã khai báo `android.permission.POST_NOTIFICATIONS` trong `AndroidManifest.xml`.
   - Trong `LockscreenNotificationManager.kt`, kiểm tra quyền runtime qua `ContextCompat.checkSelfPermission` trước khi gọi `notify()`. Nếu chưa được cấp quyền, trả về `false` an toàn mà không làm sập ứng dụng.
2. **Quyền riêng tư (Privacy):**
   - Thiết lập `setVisibility(NotificationCompat.VISIBILITY_PUBLIC)` để hiển thị trên màn hình khóa.
   - Tôn trọng thiết lập bảo mật của hệ điều hành nếu người dùng chọn "Ẩn nội dung nhạy cảm trên màn hình khóa".
3. **Tuyệt đối an toàn:** Không dùng `SYSTEM_ALERT_WINDOW`, không can thiệp vào tiến trình khóa PIN/vân tay của hệ thống, không cho Native Android ghi trực tiếp vào CSDL SQLite.

---

## 6. KẾT QUẢ KIỂM THỬ VÀ BIÊN DỊCH

- **Kiểm thử tĩnh (Static Analysis):** `flutter analyze` đạt **No issues found!**
- **Chuẩn định dạng mã nguồn:** `dart format` đạt 100% (64 files passed).
- **Unit & Integration Tests:** **57/57 tests PASS (100%)**.
  - `lockscreen_test.dart`: 11/11 PASS
  - `theme_settings_test.dart`: 8/8 PASS
  - `reminder_test.dart`: 18/18 PASS
  - `database_test.dart`: 6/6 PASS
  - `calendar_test.dart`: 6/6 PASS
  - `usecases_test.dart`: 6/6 PASS
  - `widget_test.dart`: 2/2 PASS
- **Kiểm tra hồi quy (Regression):** Không có bất kỳ lỗi hồi quy nào đối với Task CRUD, Calendar, Reminder và Theme Settings.
- **Biên dịch Android:** Build Debug APK thành công.

---

## 7. HƯỚNG TRIỂN KHAI CHO SPRINT 6.2
- **Sprint 6.2 – Home Screen Widget:**
  - Tích hợp package `home_widget`.
  - Thiết kế layout Android AppWidget (RemoteViews) dạng 4x2 và 2x1 hiển thị danh sách công việc trong ngày.
  - Tái sử dụng `LockscreenPayload` để chia sẻ dữ liệu sang widget lưu trữ (`SharedPreferences`).

