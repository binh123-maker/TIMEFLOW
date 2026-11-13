# PHẦN 4 – KIỂM KÊ CHỨC NĂNG (FEATURE INVENTORY)

**Ngày kiểm kê:** 12/11/2026  
**Phương pháp:** Đọc trực tiếp toàn bộ file trong `lib/`, `android/`, `test/` và đối chiếu với các báo cáo trong `docs/`.

---

## Bảng kiểm kê chức năng tổng hợp

| Nhóm | Chức năng | Trạng thái | File triển khai chính | Công nghệ | Mức độ kiểm thử |
|---|---|---|---|---|---|
| **4.1 Task Management** | Tạo Task (Create) | **Đã triển khai** | `create_task.dart`, `task_form_dialog.dart` | Dart, Riverpod, Drift, UUID | Unit test validation (`usecases_test.dart`) + DB test (`database_test.dart`) |
| **4.1 Task Management** | Sửa Task (Update) | **Đã triển khai** | `update_task.dart`, `task_form_dialog.dart` | Dart, Riverpod, Drift | Unit test validation + DB test |
| **4.1 Task Management** | Xóa Task (Delete) | **Đã triển khai** | `delete_task.dart`, `tasks_screen.dart` | Dart, Riverpod, Drift | DB test (`database_test.dart`) |
| **4.1 Task Management** | Hoàn thành / Hủy hoàn thành | **Đã triển khai** | `toggle_task_completion.dart`, `task_repository_impl.dart` | Dart, Drift | DB test + Calendar integration test |
| **4.1 Task Management** | Độ ưu tiên (4 mức) | **Đã triển khai** | `task_entity.dart` (`low`, `medium`, `high`, `urgent`) | Dart enum | Unit test (`widget_test.dart`, `home_widget_test.dart`) |
| **4.1 Task Management** | Thời gian bắt đầu / kết thúc & ngày hạn | **Đã triển khai** | `task_form_dialog.dart`, `task_table.dart` | DateTime, DatePicker, TimePicker | Unit test (`usecases_test.dart`) |
| **4.1 Task Management** | Trạng thái Task (4 trạng thái) | **Đã triển khai** | `task_entity.dart` (`pending`, `inProgress`, `completed`, `cancelled`) | Dart enum | Unit test (`widget_test.dart`) |
| **4.1 Task Management** | Tìm kiếm & Lọc trạng thái (Tất cả / Chưa xong / Đã xong) | **Đã triển khai** | `tasks_screen.dart` | StatefulWidget + Stream | Chưa có WidgetTester UI test |
| **4.2 Calendar & Scheduling** | Lưới lịch tháng 7 cột (T2–CN) & chuyển tháng | **Đã triển khai** | `calendar_month_view.dart`, `calendar_header.dart`, `calendar_providers.dart` | Riverpod, GridView | Unit test logic lưới & dot (`calendar_test.dart`) |
| **4.2 Calendar & Scheduling** | Chấm chỉ báo số Task theo ngày (tối đa 3 chấm) | **Đã triển khai** | `monthTaskCountsProvider`, `calendar_month_view.dart` | Riverpod Derived Provider | Unit test (`calendar_test.dart`) |
| **4.2 Calendar & Scheduling** | Lọc & Sắp xếp Task theo ngày chọn | **Đã triển khai** | `selectedDateTasksProvider`, `calendar_task_list.dart` | Riverpod, Drift | Integration test (`calendar_test.dart`) |
| **4.2 Calendar & Scheduling** | Xác định Current Task & Next Task (Home Screen) | **Đã triển khai (có lệch nhẹ với Widget)** | `task_providers.dart` (`currentTaskStreamProvider`, `nextTaskStreamProvider`), `home_screen.dart` | Riverpod | Chưa có test riêng cho `task_providers.dart` (chỉ test ở `lockscreen_test.dart`) |
| **4.2 Calendar & Scheduling** | Xác định Current & Next Task + Xử lý trùng giờ (Widget) | **Đã triển khai** | `home_widget_providers.dart` (`evaluateCurrentAndNextTask`) | Dart pure function | 29 tests (`home_widget_test.dart`) |
| **4.3 Reminder & Notification** | Cấu hình offset nhắc nhở (`ReminderOffset`) | **Đã triển khai** | `reminder_offset.dart`, `task_form_dialog.dart` | Dart enum | Unit test (`reminder_test.dart`) |
| **4.3 Reminder & Notification** | Lập lịch thông báo chính xác (`exactAllowWhileIdle`) | **Đã triển khai** | `local_notification_service.dart` | `flutter_local_notifications`, `timezone` | Unit test với `FakeLocalNotificationService` (`reminder_test.dart`) |
| **4.3 Reminder & Notification** | Hủy thông báo khi xóa / xong / tắt nhắc | **Đã triển khai** | `reminder_providers.dart` (`TaskReminderSyncService`) | Riverpod | Unit test (`reminder_test.dart`) |
| **4.3 Reminder & Notification** | Đối soát & khôi phục lịch nhắc khi mở app | **Đã triển khai** | `reconcileStartupReminders`, `appReminderSyncListenerProvider` | Riverpod + FNV-1a | Unit test (`reminder_test.dart`) |
| **4.3 Reminder & Notification** | Khôi phục lịch nhắc sau khi khởi động lại máy | **Đã triển khai nhưng chưa kiểm chứng thực tế** | `AndroidManifest.xml` (`ScheduledNotificationBootReceiver`) | Android BroadcastReceiver | Build Verified; **BLOCKED** ở Test 18 (chưa cold-reboot emulator) |
| **4.3 Reminder & Notification** | Màn hình danh sách nhắc nhở (`RemindersScreen`) | **Đã triển khai** | `reminders_screen.dart` | Flutter + Riverpod | Chưa có WidgetTester UI test |
| **4.3 Reminder & Notification** | Xin quyền thông báo (`POST_NOTIFICATIONS`) | **Đã triển khai (cơ bản)** | `local_notification_service.dart` (`requestPermissions`) | `flutter_local_notifications` | Chưa có Onboarding UI giải thích trước |
| **4.4 Lockscreen** | Ongoing Notification trên thanh thông báo & Lockscreen | **Đã triển khai** | `lockscreen_providers.dart`, `lockscreen_bridge_service.dart`, `MainActivity.kt`, `LockscreenNotificationManager.kt` | `MethodChannel`, `NotificationCompat` | Unit test Payload & Bridge (`lockscreen_test.dart`) |
| **4.4 Lockscreen** | Nút "Xong" trực tiếp trên Lockscreen & Full-screen Reminder | **Mới có thiết kế / Chưa triển khai** | Chỉ có trong `docs/LOCKSCREEN_TECHNICAL_DESIGN.md` | — | Chưa triển khai |
| **4.5 Home Screen Widget** | Compact Widget (2×1) với fallback sang Next Task | **Đã triển khai** | `TimeflowWidgetCompactProvider.kt`, `timeflow_widget_compact.xml` | Android AppWidget, `RemoteViews` | Emulator Verified + 29 Unit tests |
| **4.5 Home Screen Widget** | Expanded Widget (4×2) (Current + Next + Progress Bar) | **Đã triển khai** | `TimeflowWidgetExpandedProvider.kt`, `timeflow_widget_expanded.xml` | Android AppWidget, `RemoteViews` | Emulator Verified + 29 Unit tests |
| **4.5 Home Screen Widget** | Đồng bộ tự động, Empty State, Time Transition, Lifecycle | **Đã triển khai** | `home_widget_providers.dart`, `home_widget_service.dart`, `main.dart` | `home_widget`, Riverpod, `WidgetsBindingObserver` | Emulator Verified (18/19 functional tests) |
| **4.6 Settings & Personalization** | Đổi Theme (System / Light / Dark) & Lưu bền vững | **Đã triển khai** | `settings_screen.dart`, `theme_provider.dart`, `local_storage.dart` | Riverpod, `SharedPreferences` | 8 Unit tests (`theme_settings_test.dart`) |
| **4.6 Settings & Personalization** | Đổi ngôn ngữ / Cài đặt khác | **Chưa triển khai** | Có key `keyUserLanguage` trong `app_constants.dart` nhưng chưa có UI | — | Chưa triển khai |
| **4.7 Khác (Skeleton / Stub)** | Focus (Pomodoro), Statistics, Timeline, Profile, Subscription | **Mới có khung giao diện (Skeleton)** | `focus_screen.dart`, `statistics_screen.dart`, `timeline_screen.dart`, `profile_screen.dart`, `subscription_screen.dart` | Flutter StatelessWidget | Chưa có logic nghiệp vụ |
| **4.7 Khác (Stub)** | Auth, Cloud Sync, Subscription Service, Dio REST Client | **Mới có Stub rỗng** | `lib/services/*.dart`, `lib/core/network/dio_client.dart` | Dart, `dio` | Chưa kết nối backend |

---

## 4.1 – 4.7. Giải thích luồng hoạt động từng nhóm chức năng

### 4.1. Task Management
Người dùng mở tab **Công việc** (`TasksScreen`) hoặc nhấn nút `+` ở thanh điều hướng (`MainLayoutScreen`) để mở `TaskFormDialog`. Sau khi nhập tiêu đề, mô tả, ngày (`dueDate`), giờ bắt đầu/kết thúc (`startTime`, `endTime`), mức độ ưu tiên, trạng thái và mức nhắc nhở (`ReminderOffset`), UI gọi `CreateTask` hoặc `UpdateTask`. UseCase kiểm tra tính hợp lệ (tiêu đề không rỗng, `startTime < endTime`, nếu bật nhắc nhở phải có `startTime`) rồi chuyển xuống `TaskRepositoryImpl` ghi vào Drift SQLite. Bảng `tasks` phát Stream mới qua `allTasksStreamProvider`, làm giao diện cập nhật ngay lập tức.

### 4.2. Calendar & Scheduling
`CalendarScreen` (responsive: dọc trên Mobile, 2 cột trên Desktop) theo dõi `displayedMonthProvider` và `selectedDateProvider`. `CalendarMonthView` tính lưới ngày bắt đầu từ Thứ Hai (`leadingDays = firstDayOfMonth.weekday - 1`) và đọc số lượng task từng ngày từ `monthTaskCountsProvider` để vẽ 0–3 chấm xanh dưới mỗi ô ngày. Khi người dùng chọn một ngày, `selectedDateTasksProvider` lọc các task có `dueDate` trùng ngày đó và sắp xếp task có giờ lên trước theo `startTime ASC`.

### 4.3. Reminder & Notification
Mỗi khi `allTasksStreamProvider` phát danh sách task mới, `appReminderSyncListenerProvider` (được `watch` trong `TimeFlowApp.build`) gọi `TaskReminderSyncService.reconcileStartupReminders(tasks)`. Dịch vụ này lấy danh sách `pendingNotificationRequests` từ OS, đối chiếu từng task trong SQLite: nếu task chưa hoàn thành, chưa hủy, có bật `reminderEnabled` và `calculatedReminderTime` nằm trong tương lai thì gọi `zonedSchedule(..., androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle)` với ID sinh bằng hàm băm FNV-1a từ `task.id`. Các thông báo thừa (task đã xong/xóa/tắt nhắc) bị hủy bỏ.

### 4.4. Lockscreen
`lockscreenPayloadProvider` lấy dữ liệu từ `currentTaskStreamProvider`, `nextTaskStreamProvider` và `todayTasksStreamProvider`, đóng gói thành `LockscreenPayload`. Mỗi khi payload thay đổi (và khi app `resumed`), `MethodChannelLockscreenBridge` kiểm tra trùng lặp (`_lastPayload == payload`), nếu khác thì gửi JSON qua `MethodChannel('com.timeflow.lockscreen/bridge')` sang `MainActivity.kt` → `LockscreenNotificationManager.updateNotification()`. Kotlin tạo notification channel `timeflow_lockscreen_status` (`IMPORTANCE_LOW`, `VISIBILITY_PUBLIC`), hiển thị thông báo `setOngoing(true)` với `BigTextStyle` gồm việc đang làm, việc kế tiếp và tiến độ `completed/total`.
*Giới hạn thực tế:* Android 12–15 không cho phép app bên thứ 3 đặt tự do AppWidget lên màn hình khóa chuẩn của hệ thống, nên TIMEFLOW hiển thị trên Lockscreen thông qua **Ongoing Notification** (tuân thủ cài đặt ẩn/hiện nội dung thông báo trên màn hình khóa của người dùng và OEM).

### 4.5. Home Screen Widget
`homeWidgetPayloadProvider` kết hợp `todayTasksStreamProvider` với `homeWidgetClockProvider` (stream tự thức dậy đúng lúc task bắt đầu/kết thúc hoặc đầu phút tiếp theo). Khi có thay đổi, `HomeWidgetServiceImpl` lưu 14 key dữ liệu (bao gồm `payloadJson`) vào `HomeWidgetPreferences.xml` qua `HomeWidget.saveWidgetData` và gửi broadcast `APPWIDGET_UPDATE` đến `TimeflowWidgetCompactProvider` (2×1) và `TimeflowWidgetExpandedProvider` (4×2). Widget 2×1 có logic fallback: nếu không có Current Task nhưng có Next Task, nó hiển thị Next Task với tiêu đề `TIMEFLOW • TIẾP THEO`. Nhấn vào widget sẽ kích hoạt `PendingIntent` mở `MainActivity`.

### 4.6. Settings & Personalization
`SettingsScreen` cho phép chọn `ThemeMode.system`, `ThemeMode.light` hoặc `ThemeMode.dark` thông qua `ThemeNotifier` (`theme_provider.dart`). Giá trị được lưu xuống `SharedPreferences` với key `timeflow_theme_mode` thông qua `SharedPrefsLocalStorage` và khôi phục ngay trong `main()` trước khi `runApp()`.

