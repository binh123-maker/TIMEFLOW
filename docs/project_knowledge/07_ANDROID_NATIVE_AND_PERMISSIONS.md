# PHẦN 7 – PHÂN TÍCH ANDROID NATIVE VÀ QUYỀN HỆ THỐNG

**Ngày phân tích:** 12/11/2026  
**File kiểm tra:** `android/app/src/main/AndroidManifest.xml`, `MainActivity.kt`, `LockscreenNotificationManager.kt`, `TimeflowWidgetCompactProvider.kt`, `TimeflowWidgetExpandedProvider.kt`, `res/xml/timeflow_widget_*_info.xml`.

---

## 7.1. Thành phần Android Native thực tế

1. **Notification Channels (2 kênh):**
   - `timeflow_reminders` (tạo từ Flutter `local_notification_service.dart`, `Importance.high`): Dùng cho thông báo nhắc giờ công việc có âm thanh/pop-up.
   - `timeflow_lockscreen_status` (tạo từ Kotlin `LockscreenNotificationManager.kt`, `IMPORTANCE_LOW`, `VISIBILITY_PUBLIC`, `setShowBadge(false)`): Dùng cho Ongoing Notification (`NOTIFICATION_ID = 1001`) hiển thị im lặng trên thanh trạng thái & Lockscreen.
2. **Receivers trong `AndroidManifest.xml`:**
   - `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver` (`exported="false"`): Nhận alarm khi đến giờ nhắc.
   - `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver` (`exported="false"`): Lắng nghe `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON` để khôi phục alarm sau khi khởi động lại máy.
   - `TimeflowWidgetCompactProvider` & `TimeflowWidgetExpandedProvider` (`exported="true"`): Lắng nghe `android.appwidget.action.APPWIDGET_UPDATE`.
3. **MethodChannel:** `com.timeflow.lockscreen/bridge` trong `MainActivity.kt` xử lý 2 hàm: `updateLockscreenNotification` và `cancelLockscreenNotification`.
4. **PendingIntent:** Sử dụng cờ `FLAG_UPDATE_CURRENT | FLAG_IMMUTABLE` (tương thích Android 12+ yêu cầu mutability flag) để mở `MainActivity` khi người dùng chạm vào Ongoing Notification hoặc Home Screen Widget (`HomeWidgetLaunchIntent.getActivity`).
5. **AlarmManager / WorkManager / Full-screen Intent:**
   - `AlarmManager` được sử dụng gián tiếp thông qua `flutter_local_notifications` (`AndroidScheduleMode.exactAllowWhileIdle`).
   - **WorkManager:** **Chưa triển khai**.
   - **Full-screen Intent (`USE_FULL_SCREEN_INTENT`):** **Chưa triển khai** (chỉ mới nêu trong tài liệu thiết kế `docs/LOCKSCREEN_TECHNICAL_DESIGN.md`).

---

## 7.2. Bảng kiểm kê Quyền và Cơ chế Android

| Quyền / Cơ chế | Mục đích | Đã triển khai | Cần người dùng cấp quyền? | Giới hạn thực tế |
|---|---|:---:|---|---|
| `POST_NOTIFICATIONS` | Hiển thị thông báo nhắc nhở và Ongoing Lockscreen Notification | **Có** (Manifest + `requestPermissions()` + check ở Kotlin) | **Có (Android 13+ / API 33+)**; tự cấp trên Android $\le 12$ | Nếu từ chối, cả nhắc việc và Lockscreen Ongoing Notification đều không hiển thị |
| `SCHEDULE_EXACT_ALARM` | Lập lịch nhắc nhở chính xác từng phút (`exactAllowWhileIdle`) | **Có** (khai báo trong Manifest) | **Tùy phiên bản:** Android 12 tự cấp; **Android 13–14+** có thể bị thu hồi trong Settings (*Alarms & reminders*) trừ khi app thuộc danh mục alarm/calendar | Nếu bị thu hồi, `zonedSchedule` với `exactAllowWhileIdle` có thể ném `PlatformException` (đã bọc `try/catch` trong `local_notification_service.dart`, nhưng chưa có fallback sang `inexact`) |
| `RECEIVE_BOOT_COMPLETED` | Khôi phục lịch nhắc nhở sau khi khởi động lại thiết bị | **Có** (Manifest + `ScheduledNotificationBootReceiver`) | **Tự động cấp** bởi hệ thống | Một số hãng Trung Quốc (Xiaomi MIUI/HyperOS, Oppo ColorOS, Vivo) chặn auto-start sau reboot nếu người dùng không bật quyền *Autostart* |
| `Home Screen Widget` (`AppWidgetProvider`) | Đặt Widget 2×1 và 4×2 ra màn hình chính | **Có** | Không cần runtime permission (người dùng tự kéo widget ra Home) | Không tự động chạy khi app bị *Force Stop*; `updatePeriodMillis="1800000"` (30 phút) là chu kỳ tối thiểu Android cho phép cập nhật tĩnh |
| `USE_FULL_SCREEN_INTENT` | Bật sáng màn hình khóa khi có việc khẩn cấp | **Chưa** | Android 14+ yêu cầu người dùng bật thủ công trong Settings | Chưa có trong Manifest và Kotlin |
| `SYSTEM_ALERT_WINDOW` | Vẽ đè lên màn hình khác | **Không dùng** (chủ đích loại bỏ theo thiết kế) | — | Tránh bị Google Play từ chối vì lạm dụng overlay |

---

## 7.3. Đề xuất thiết kế Permission Onboarding chuẩn UX

Hiện tại trong `lib/main.dart` (dòng 54), ứng dụng gọi thẳng `await notifService.requestPermissions();` ngay ở `initState()` lần mở app đầu tiên mà **không giải thích trước**. Điều này dễ khiến người dùng bấm "Từ chối" theo phản xạ, và từ Android 13 nếu từ chối 2 lần sẽ không hiện popup xin lại nữa.

**Kiến trúc Permission Onboarding đề xuất (3 bước, tận dụng key `keyIsFirstLaunch` đã có sẵn trong `app_constants.dart`):**

1. **Bước 1 – Giải thích giá trị (Pre-permission Rationale Screen/Sheet):**
   - Hiển thị màn hình giới thiệu nhẹ nhàng: *"Bật thông báo để TIMEFLOW nhắc bạn đúng giờ và hiển thị việc đang làm ngay trên màn hình khóa."*
   - Có 2 nút rõ ràng: **"Bật thông báo ngay"** và **"Để sau"**.
2. **Bước 2 – Xin quyền hệ thống đúng ngữ cảnh (Just-in-time Request):**
   - Chỉ khi người dùng bấm **"Bật thông báo ngay"** (hoặc khi lần đầu người dùng gạt bật Reminder trong `TaskFormDialog`), ứng dụng mới gọi `requestPermissions()`.
   - Kiểm tra thêm quyền `exactAlarm` (qua `canScheduleExactAlarms()` của `flutter_local_notifications`); nếu chưa có trên Android 14+, hướng dẫn mở trang cài đặt *Alarms & reminders*.
3. **Bước 3 – Trạng thái Fallback & Mở lại từ Settings:**
   - Nếu người dùng đã từ chối vĩnh viễn, hiển thị banner nhỏ trong `RemindersScreen` / `SettingsScreen` kèm nút **"Mở Cài đặt ứng dụng"** để họ tự cấp lại bất cứ lúc nào.

