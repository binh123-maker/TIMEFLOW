# PHẦN 12 – TÀI LIỆU HỌC TẬP CHO NGƯỜI MỚI (LEARNING GUIDE)

**Mục tiêu:** Giúp bạn tự hiểu, tự giải thích, tự đọc code và tự phát triển tiếp dự án TIMEFLOW mà không phụ thuộc vào công cụ bên ngoài.

---

## 12.1. Giải thích 19 khái niệm cốt lõi từ cơ bản

| Khái niệm | Định nghĩa dễ hiểu | Vai trò trong TIMEFLOW | Ví dụ thực tế trong code | Khi nào sử dụng |
|---|---|---|---|---|
| **1. Dart** | Ngôn ngữ lập trình hướng đối tượng, tối ưu cho UI và bất đồng bộ. | Ngôn ngữ viết toàn bộ logic, DB và UI Flutter. | `TaskEntity` (`lib/features/tasks/domain/entities/task_entity.dart`) | Mọi file `.dart` trong `lib/` và `test/`. |
| **2. Flutter** | Framework đa nền tảng vẽ UI bằng engine riêng (Skia/Impeller). | Dựng giao diện Android & Desktop từ 1 codebase. | `MaterialApp.router(...)` (`lib/main.dart`) | Khi xây dựng màn hình, điều hướng, animation. |
| **3. Widget** | Mọi thành phần giao diện trong Flutter (nút, chữ, layout, cả màn hình). | Tạo các card, dialog, trang màn hình. | `CurrentTaskCard extends StatelessWidget` (`current_task_card.dart`) | Khi cần hiển thị hoặc bố cục giao diện. |
| **4. State Management** | Cách lưu và cập nhật dữ liệu thay đổi theo thời gian để UI tự vẽ lại. | Đồng bộ danh sách Task, Theme, ngày chọn trên Lịch. | `SelectedDateNotifier` (`calendar_providers.dart`) | Khi dữ liệu thay đổi và nhiều chỗ cần cập nhật theo. |
| **5. Riverpod** | Thư viện State Management & DI an toàn, không cần `BuildContext`. | Kết nối DB Stream với UI và các listener nền. | `ref.watch(allTasksStreamProvider)` (`tasks_screen.dart`) | Quản lý state chia sẻ giữa nhiều màn hình/service. |
| **6. Provider** | "Ống dẫn" hoặc "nhà máy" cung cấp đối tượng/dữ liệu trong Riverpod. | Cung cấp `AppDatabase`, `TaskDao`, `ITaskRepository`, payload. | `final taskRepositoryProvider = Provider<ITaskRepository>(...)` (`task_providers.dart`) | Khi muốn tạo và chia sẻ 1 instance hoặc giá trị dẫn xuất. |
| **7. Repository Pattern** | Lớp trung gian giấu chi tiết lưu trữ (SQLite/API) khỏi tầng nghiệp vụ. | Tách biệt `TaskEntity` khỏi `TasksCompanion` của Drift. | `ITaskRepository` & `TaskRepositoryImpl` (`lib/data/repositories/`) | Khi muốn dễ thay đổi nguồn dữ liệu hoặc mock khi test. |
| **8. Clean Architecture** | Kiến trúc chia code thành Domain (luật), Data (lưu trữ), Presentation (UI). | Áp dụng rõ nhất ở module `tasks` (Entity, UseCase, Repo, UI). | `CreateTask` (`lib/features/tasks/domain/usecases/create_task.dart`) | Khi nghiệp vụ phức tạp cần tách khỏi UI và thư viện ngoài. |
| **9. SQLite** | Hệ quản trị CSDL quan hệ gọn nhẹ lưu trong 1 file duy nhất trên máy. | Lưu trữ bền vững toàn bộ công việc offline. | File `timeflow.sqlite` tạo ở `app_database.dart` | Khi cần lưu dữ liệu có cấu trúc, truy vấn nhanh offline. |
| **10. Drift** | Thư viện ORM cho SQLite viết bằng Dart, hỗ trợ type-safe & Stream. | Định nghĩa bảng `Tasks`, viết DAO, chạy migration v1 $\rightarrow$ v2. | `@DriftDatabase(tables: [Tasks], daos: [TaskDao])` (`app_database.dart`) | Khi dùng SQLite trong Flutter và muốn UI tự cập nhật theo DB. |
| **11. Stream** | Dòng dữ liệu phát ra nhiều giá trị liên tiếp theo thời gian (như băng chuyền). | Phát danh sách task mới mỗi khi DB thay đổi; phát tick đồng hồ. | `Stream<List<Task>> watchAllTasks()` (`task_dao.dart`) | Khi dữ liệu thay đổi liên tục (DB reactive, clock, sensor). |
| **12. Future** | Lời hứa trả về 1 giá trị (hoặc lỗi) tại một thời điểm trong tương lai. | Đọc/ghi DB 1 lần, gọi MethodChannel, xin quyền. | `Future<void> createTask(TaskEntity task)` (`task_repository.dart`) | Tác vụ bất đồng bộ chạy 1 lần rồi xong. |
| **13. Async / Await** | Từ khóa giúp viết code bất đồng bộ (`Future`) trông tuần tự như code đồng bộ. | Đợi khởi tạo `SharedPreferences` trước khi `runApp()`. | `final prefs = await SharedPreferences.getInstance();` (`main.dart`) | Bất cứ khi nào cần lấy kết quả từ `Future`. |
| **14. MethodChannel** | Cầu nối gửi thông điệp tên hàm + dữ liệu JSON giữa Dart và Kotlin/Swift. | Gửi `LockscreenPayload` sang Android để hiện Ongoing Notification. | `const MethodChannel('com.timeflow.lockscreen/bridge')` (`lockscreen_bridge_service.dart`) | Khi cần gọi API Native mà chưa có plugin pub.dev đáp ứng. |
| **15. Android Native** | Code chạy trực tiếp trên nền tảng Android (Kotlin/Java + Android SDK). | Tạo NotificationChannel, cập nhật AppWidget trên Launcher. | `MainActivity.kt`, `LockscreenNotificationManager.kt` | Khi tương tác với hệ điều hành Android ở tầng sâu. |
| **16. RemoteViews** | Cơ chế đặc biệt của Android cho phép app gửi layout XML sang Launcher hiển thị. | Dựng giao diện Compact (2×1) và Expanded (4×2) Widget. | `RemoteViews(context.packageName, R.layout.timeflow_widget_compact)` | Bắt buộc khi viết Android Home Screen AppWidget truyền thống. |
| **17. BroadcastReceiver** | Thành phần Android lắng nghe sự kiện phát thanh từ hệ thống hoặc app khác. | Nhận sự kiện khởi động máy (`BOOT_COMPLETED`) hoặc cập nhật Widget. | `TimeflowWidgetCompactProvider : HomeWidgetProvider()` | Khi cần phản ứng với sự kiện hệ thống dù app không mở. |
| **18. Notification** | Thông báo hiển thị trên thanh trạng thái và màn hình khóa Android. | Có 2 loại: Nhắc giờ (`timeflow_reminders`) và Ghim (`timeflow_lockscreen_status`). | `NotificationCompat.Builder(...).setOngoing(true)` (`LockscreenNotificationManager.kt`) | Nhắc nhở đúng giờ hoặc hiển thị trạng thái liên tục. |
| **19. Background Execution** | Thực thi tác vụ khi app không nằm trên màn hình chính. | `AlarmManager` gọi Receiver khi đến giờ nhắc; `homeWidgetClockProvider` chạy khi engine sống. | `AndroidScheduleMode.exactAllowWhileIdle` (`local_notification_service.dart`) | Hẹn giờ báo thức, đồng bộ nền (lưu ý giới hạn Doze/Force-stop). |

---

## 12.2. Hướng dẫn thứ tự đọc code (từ dễ đến khó)

1. **Bước 1 – Cấu trúc & Hằng số:**
   - `lib/core/constants/app_constants.dart` & `app_colors.dart` (biết tên app, breakpoints, bảng màu).
   - `lib/core/utils/date_formatter.dart` (biết cách format ngày giờ tiếng Việt).
2. **Bước 2 – Dữ liệu & Domain cốt lõi:**
   - `lib/features/tasks/domain/entities/task_entity.dart` (nắm cấu trúc 1 Task).
   - `lib/data/database/tables/task_table.dart` $\rightarrow$ `task_dao.dart` $\rightarrow$ `app_database.dart` (hiểu DB SQLite & Migration).
   - `lib/data/repositories/task_repository_impl.dart` (hiểu cách map Entity $\leftrightarrow$ DB).
   - `lib/features/tasks/domain/usecases/create_task.dart` (hiểu luật validation).
3. **Bước 3 – Điểm khởi đầu & Điều hướng:**
   - `lib/core/router/app_router.dart` (nắm toàn bộ đường dẫn màn hình).
   - `lib/main.dart` (hiểu thứ tự khởi tạo `SharedPreferences`, `HomeWidget`, `ProviderScope`, 3 auto-sync listeners).
4. **Bước 4 – State Management & UI:**
   - `lib/features/tasks/presentation/providers/task_providers.dart` $\rightarrow$ `tasks_screen.dart` $\rightarrow$ `task_form_dialog.dart`.
   - `lib/features/calendar/presentation/providers/calendar_providers.dart` $\rightarrow$ `calendar_month_view.dart`.
   - `lib/features/home/presentation/home_screen.dart`.
5. **Bước 5 – Tích hợp Hệ thống & Android Native (Nâng cao):**
   - `lib/core/notifications/local_notification_service.dart` $\rightarrow$ `lib/features/reminders/presentation/providers/reminder_providers.dart`.
   - `lib/features/home_widget/presentation/providers/home_widget_providers.dart` $\rightarrow$ `home_widget_service.dart`.
   - `android/app/src/main/AndroidManifest.xml` $\rightarrow$ `MainActivity.kt` $\rightarrow$ `LockscreenNotificationManager.kt` $\rightarrow$ `TimeflowWidgetCompactProvider.kt`.

---

## 12.3. Bộ 30 câu hỏi tự kiểm tra kiến thức TIMEFLOW (Có đáp án)

### Nhóm Cơ bản (10 câu)
1. **TIMEFLOW lưu dữ liệu công việc ở đâu?**  
   *Đáp án:* Trong file SQLite cục bộ tên `timeflow.sqlite` tại thư mục tài liệu của ứng dụng (`app_database.dart`), quản lý qua thư viện Drift.
2. **File `lib/data/models/task_model.dart` hiện tại có được sử dụng không?**  
   *Đáp án:* Không. Đây là dead code từ giai đoạn đầu; toàn bộ ứng dụng dùng `TaskEntity` (`lib/features/tasks/domain/entities/task_entity.dart`).
3. **Màn hình `FocusScreen` và `StatisticsScreen` hiện tại làm được gì?**  
   *Đáp án:* Mới chỉ là màn hình giữ chỗ (placeholder/skeleton), chưa có logic đếm giờ hay biểu đồ thật.
4. **ThemeMode (Sáng/Tối/Hệ thống) được lưu bằng cơ chế nào?**  
   *Đáp án:* Lưu qua `SharedPreferences` thông qua `SharedPrefsLocalStorage` với key `timeflow_theme_mode` (`local_storage.dart`, `theme_provider.dart`).
5. **Một Task có mấy mức độ ưu tiên và mấy trạng thái?**  
   *Đáp án:* 4 mức ưu tiên (`low`, `medium`, `high`, `urgent`) và 4 trạng thái (`pending`, `inProgress`, `completed`, `cancelled`) trong `task_entity.dart`.
6. **Vì sao `CreateTask` ném `ArgumentError` nếu `reminderEnabled = true` mà `startTime = null`?**  
   *Đáp án:* Vì thời điểm nhắc nhở (`calculatedReminderTime`) được tính bằng `startTime - reminderMinutesBefore`. Không có `startTime` thì không tính được giờ nhắc.
7. **`GoRouter` dùng widget nào để giữ nguyên trạng thái 4 tab chính?**  
   *Đáp án:* `StatefulShellRoute.indexedStack` trong `lib/core/router/app_router.dart`.
8. **Breakpoint chuyển từ Mobile BottomNavigationBar sang Desktop NavigationRail là bao nhiêu?**  
   *Đáp án:* `768.0` px (`AppConstants.kMobileBreakpoint` trong `app_constants.dart`).
9. **Kênh thông báo nhắc việc và kênh thông báo Lockscreen khác nhau thế nào?**  
   *Đáp án:* `timeflow_reminders` dùng `Importance.high` (kêu/hiện popup khi đến giờ); `timeflow_lockscreen_status` dùng `IMPORTANCE_LOW` và `setOngoing(true)` (im lặng, ghim thường trực).
10. **TIMEFLOW có sử dụng AI hay Machine Learning không?**  
    *Đáp án:* Không. Toàn bộ logic đều là thuật toán tất định và quy tắc nghiệp vụ thông thường.

### Nhóm Trung cấp (10 câu)
11. **Tại sao `TaskDao.watchAllTasks()` trả về `Stream<List<Task>>` thay vì `Future`?**  
    *Đáp án:* Để UI và các listener tự động nhận dữ liệu mới mỗi khi bảng `tasks` có bất kỳ thay đổi INSERT/UPDATE/DELETE nào mà không cần gọi load lại thủ công.
12. **Điều gì xảy ra khi nâng cấp DB từ `schemaVersion 1` lên `2`?**  
    *Đáp án:* Hàm `onUpgrade` trong `AppDatabase` chạy `m.addColumn` để thêm 2 cột `reminderEnabled` và `reminderMinutesBefore` mà không làm mất dữ liệu task cũ.
13. **Tại sao `TaskEntity.id` dùng UUID v4 thay vì số tự tăng `1, 2, 3`?**  
    *Đáp án:* Để tạo ID duy nhất ở phía client ngay khi offline, không lo trùng lặp nếu sau này đồng bộ đa thiết bị.
14. **Trong `CalendarMonthView`, công thức `leadingDays = firstDayOfMonth.weekday - 1` có ý nghĩa gì?**  
    *Đáp án:* Vì Dart quy ước Thứ Hai = 1 ... Chủ Nhật = 7, công thức này tính số ô trống đầu tuần (từ lịch tháng trước) khi lịch bắt đầu từ Thứ Hai (`T2`).
15. **Hàm `selectedDateTasksProvider` sắp xếp task trong ngày theo thứ tự nào?**  
    *Đáp án:* Task có `startTime` lên trước (xếp theo `startTime ASC`, bằng giờ thì `createdAt ASC`), task không có `startTime` xếp sau cùng (`createdAt ASC`).
16. **Tại sao `HomeWidgetServiceImpl` phải kiểm tra `defaultTargetPlatform != TargetPlatform.android`?**  
    *Đáp án:* Vì `HomeWidget.saveWidgetData` / `updateWidget` chỉ cấu hình cho Android; nếu gọi trên Windows Desktop sẽ gây lỗi `MissingPluginException`.
17. **Compact Widget (2×1) hiển thị gì khi không có Current Task nhưng có Next Task?**  
    *Đáp án:* Nhờ logic fallback trong `TimeflowWidgetCompactProvider.kt`, nó hiển thị Next Task kèm tiêu đề `"TIMEFLOW • TIẾP THEO"`.
18. **Tại sao `HomeWidgetPayload.operator ==` lại bỏ qua trường `lastUpdatedAt`?**  
    *Đáp án:* Để Deduplication Cache nhận biết được 2 payload có nội dung giống hệt nhau dù được tạo ở 2 thời điểm khác nhau, tránh render lại Widget vô ích.
19. **Trong `TaskReminderSyncService`, "orphaned pending notification" là gì và được xử lý ra sao?**  
    *Đáp án:* Là thông báo còn nằm trong hàng đợi OS nhưng task tương ứng đã bị xóa hoặc không còn hợp lệ. `reconcileStartupReminders` so sánh `pendingIds` với `validActiveNotificationIds` và hủy các ID thừa.
20. **Vì sao `MainActivity.kt` phải đặt `PendingIntent.FLAG_IMMUTABLE`?**  
    *Đáp án:* Từ Android 12 (API 31+), hệ điều hành bắt buộc mọi `PendingIntent` phải khai báo rõ `FLAG_IMMUTABLE` hoặc `FLAG_MUTABLE`, nếu thiếu sẽ crash `IllegalArgumentException`.

### Nhóm Nâng cao (10 câu)
21. **Tại sao TIMEFLOW không dùng `task.id.hashCode` của Dart để làm `notificationId`?**  
    *Đáp án:* Vì `String.hashCode` trong Dart VM không đảm bảo giống nhau giữa các lần chạy app khác nhau (non-deterministic across runs). Nếu đổi ID, app sẽ không hủy được thông báo đã hẹn ở lần chạy trước. Vì vậy dự án tự cài đặt hàm băm **FNV-1a 32-bit** trong `getDeterministicNotificationId`.
22. **Giải thích thuật toán `evaluateCurrentAndNextTask` khi có 2 task trùng khung giờ.**  
    *Đáp án:* Cả 2 task đều vào `activeCandidates` nếu `startTime <= now < endTime`. Sau đó danh sách được sort theo: `priorityWeight` giảm dần (`urgent > high > medium > low`) $\rightarrow$ `startTime` tăng dần $\rightarrow$ `endTime` tăng dần. Task đầu danh sách được chọn làm Current Task.
23. **Vì sao `endTime` được so sánh bằng `isAfter(now)` (exclusive) còn `startTime` dùng `isBefore(now) || isAtSameMomentAs(now)` (inclusive)?**  
    *Đáp án:* Để tại đúng ranh giới chuyển giao (ví dụ `09:00:00` khi Task A `08:00-09:00` kết thúc và Task B `09:00-10:00` bắt đầu), Task A lập tức hết hiệu lực và Task B lập tức được kích hoạt, không bị trùng lặp ở giây `09:00:00`.
24. **Cơ chế `homeWidgetClockProvider` tối ưu pin hơn `Timer.periodic(Duration(seconds: 1))` như thế nào?**  
    *Đáp án:* Thay vì đánh thức CPU mỗi giây (86.400 lần/ngày), nó dùng `calculateNextTransitionTime` tìm mốc `startTime`/`endTime` gần nhất hoặc đầu phút tiếp theo, rồi `await Future.delayed(duration)` ngủ đúng khoảng thời gian đó.
25. **Chỉ ra điểm bất nhất giữa `HomeScreen` (`task_providers.dart`) và `HomeWidget` (`home_widget_providers.dart`) hiện nay.**  
    *Đáp án:* `currentTaskStreamProvider` trong `task_providers.dart` dùng `tasks.firstWhere(...)` (không ưu tiên theo `TaskPriority` khi trùng giờ) và không gắn với `homeWidgetClockProvider` nên không tự chuyển task theo thời gian thực khi đứng yên trên màn hình.
26. **Tại sao kiến trúc TIMEFLOW cấm Kotlin Native mở trực tiếp file `timeflow.sqlite` để ghi dữ liệu?**  
    *Đáp án:* Tránh xung đột khóa file SQLite (database lock), tránh race condition, và vì Drift chỉ phát hiện thay đổi để đẩy `Stream` khi thao tác ghi đi qua chính Drift DAO ở tầng Flutter.
27. **Tại sao trong Sprint 6.2 phải đổi `<View>` thành `<TextView>` và `<clip>` thành `<scale>` trong XML Widget?**  
    *Đáp án:* Vì `RemoteViews` của Android AppWidget chỉ hỗ trợ một tập con các View/Drawable cơ bản (`LinearLayout`, `TextView`, `ProgressBar`,...); dùng `<View>` hoặc một số thẻ drawable không tương thích gây lỗi `"Can't load widget"` trên Launcher.
28. **Khi người dùng Force-Stop ứng dụng trên Android, điều gì xảy ra với Home Widget và Reminder?**  
    *Đáp án:* Android chặn mọi background process/receiver của app đó cho đến khi người dùng mở lại app. Do đó Widget giữ nguyên trạng thái cuối cùng trên Launcher và không tự chuyển task cho tới khi app được mở lại.
29. **Trong `LockscreenNotificationManager.kt`, nếu người dùng từ chối quyền `POST_NOTIFICATIONS` trên Android 13+, hàm `updateNotification` xử lý thế nào?**  
    *Đáp án:* Kiểm tra `ContextCompat.checkSelfPermission(...) == PackageManager.PERMISSION_GRANTED`; nếu chưa có thì trả về `false` ngay lập tức, đồng thời bọc `notify()` trong `try/catch (SecurityException)` để không crash.
30. **Nếu muốn thêm tính năng bấm nút "Hoàn thành" ngay trên Lockscreen Notification, luồng dữ liệu chuẩn kiến trúc TIMEFLOW phải đi như thế nào?**  
    *Đáp án:* PendingIntent $\rightarrow$ BroadcastReceiver/MainActivity $\rightarrow$ gửi sự kiện qua `MethodChannel` về Flutter $\rightarrow$ gọi `ToggleTaskCompletion` UseCase $\rightarrow$ ghi vào Drift SQLite $\rightarrow$ Stream tự động cập nhật lại cả UI, Lockscreen Notification và Home Widget.

---

## 12.4. 10 bài tập thực hành tăng dần độ khó (Tự rèn luyện)

1. **(Dễ)** Cập nhật chuỗi phiên bản hiển thị trong `lib/features/settings/presentation/settings_screen.dart` cho khớp với `v0.6.2`.
2. **(Dễ)** Thêm bộ lọc theo mức độ ưu tiên (`Khẩn cấp`, `Cao`,...) vào `TasksScreen` (`tasks_screen.dart`).
3. **(Dễ–TB)** Kết nối `liveClockProvider` (`today_schedule_provider.dart`) vào `HomeScreen` để đồng hồ trên màn hình chính nhảy số theo từng giây/phút.
4. **(Trung bình)** Tạo một `Provider` mới `todayProgressProvider` tính phần trăm hoàn thành công việc trong ngày để dùng chung cho `HomeScreen` và `StatisticsScreen`.
5. **(Trung bình)** Sửa sự bất nhất ở `currentTaskStreamProvider` và `nextTaskStreamProvider` (`task_providers.dart`) để dùng chung hàm `evaluateCurrentAndNextTask` của `home_widget_providers.dart`.
6. **(Trung bình)** Viết thêm 3 `testWidgets` đầu tiên trong `test/` để kiểm thử giao diện `CurrentTaskCard` (khi có task và khi `task == null`) và `SettingsScreen`.
7. **(Trung bình–Khó)** Thêm một phương thức truy vấn mới trong `TaskDao` (`getTasksByDateRange(DateTime start, DateTime end)`) kèm unit test trên `NativeDatabase.memory()`.
8. **(Khó)** Thêm trường mới `estimatedMinutes` (`IntColumn`) vào bảng `Tasks`, viết Migration v2 $\rightarrow$ v3 trong `AppDatabase`, chạy `build_runner` và viết test migration.
9. **(Khó)** Thêm một field mới vào `HomeWidgetPayload` (ví dụ `nextTaskCountdown`: `"Còn 15 phút"`) và hiển thị lên `timeflow_widget_expanded.xml` qua `TimeflowWidgetExpandedProvider.kt`.
10. **(Nâng cao)** Xây dựng hoàn chỉnh màn hình `StatisticsScreen` với số liệu thống kê 7 ngày gần nhất lấy trực tiếp từ Drift SQLite.

