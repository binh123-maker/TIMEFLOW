# PHẦN 5 – PHÂN TÍCH THUẬT TOÁN VÀ LOGIC NGHIỆP VỤ

**Ngày phân tích:** 12/11/2026  
**Khẳng định quan trọng:** Qua kiểm tra toàn bộ mã nguồn, TIMEFLOW **KHÔNG sử dụng bất kỳ thuật toán AI, Machine Learning hay Deep Learning nào**. Toàn bộ logic trong dự án là các thuật toán xử lý dữ liệu, sắp xếp tất định (deterministic sorting), tính toán thời gian, hàm băm (FNV-1a), đối soát tập hợp (reconciliation) và caching chống trùng lặp.

---

## Phân loại tổng quan

| Nhóm | Thuật toán / Cơ chế | Nguồn gốc |
|---|---|---|
| **A. Xử lý dữ liệu** | 1. Hàm băm 32-bit FNV-1a tạo Notification ID | Tự triển khai (`local_notification_service.dart`) |
| **A. Xử lý dữ liệu** | 2. Payload Deduplication Cache | Tự triển khai (`home_widget_service.dart`, `lockscreen_bridge_service.dart`) |
| **B. Sắp xếp & Lựa chọn Task** | 3. Đánh giá Current & Next Task + Giải quyết trùng giờ (Tie-breaker) | Tự triển khai (`home_widget_providers.dart`) |
| **B. Sắp xếp & Lựa chọn Task** | 4. Sắp xếp Task theo ngày trên Calendar | Tự triển khai (`calendar_providers.dart`) |
| **C. Xử lý thời gian** | 5. Tính mốc chuyển tiếp & Dynamic Transition Clock | Tự triển khai (`home_widget_providers.dart`) |
| **C. Xử lý thời gian** | 6. Lọc ngày & Chuyển giao qua nửa đêm (Midnight Transition) | Tự triển khai (`home_widget_providers.dart`, `task_providers.dart`) |
| **C. Xử lý thời gian** | 7. Sinh lưới lịch tháng 7 cột (Monday-based Grid) | Tự triển khai (`calendar_month_view.dart`) |
| **D. Đồng bộ & Hiệu năng** | 8. Idempotent Startup Reminder Reconciliation | Tự triển khai (`reminder_providers.dart`) |
| **E. Logic nghiệp vụ & Hệ thống** | 9. Quy tắc Validate UseCase, Compact Widget Fallback, Android Exact Alarm | Kết hợp Logic nghiệp vụ + Thư viện (`drift`, `flutter_local_notifications`) + OS Android |

---

## Chi tiết từng thuật toán và cơ chế

### 1. Thuật toán băm 32-bit FNV-1a tạo Notification ID (Nhóm A)
- **Mục đích:** Chuyển đổi `task.id` (chuỗi UUID v4 dài 36 ký tự) thành một số nguyên dương 31-bit ổn định (`int`) để làm `notificationId` cho `flutter_local_notifications` trên Android.
- **File & Function:** `lib/core/notifications/local_notification_service.dart` — `getDeterministicNotificationId(String taskId)` (dòng 9–16).
- **Input:** `taskId` (`String`, ví dụ `"550e8400-e29b-41d4-a716-446655440000"`).
- **Output:** Số nguyên dương 31-bit (`0` đến `2,147,483,647`).
- **Các bước xử lý:**
  1. Khởi tạo `hash = 0x811c9dc5` (FNV-1a 32-bit offset basis).
  2. Duyệt từng ký tự `i` của `taskId`: `hash ^= taskId.codeUnitAt(i)`.
  3. Nhân với FNV prime và giữ 32-bit: `hash = (hash * 0x01000193) & 0xFFFFFFFF`.
  4. Trả về `hash & 0x7FFFFFFF` để đảm bảo không âm (yêu cầu của Android `NotificationManager.notify(int id, ...)`).
- **Độ phức tạp:** Time $O(L)$ với $L$ là độ dài `taskId` (UUID luôn 36 ký tự $\Rightarrow O(1)$ thực tế); Space $O(1)$.
- **Ưu điểm:** Tất định 100% qua mọi lần khởi động app (không bị lệch như `Object.hash()` của Dart vốn thay đổi theo tiến trình), phân bố đều, không cần lưu thêm cột `notificationId` trong SQLite.
- **Nhược điểm:** Về mặt lý thuyết có xác suất va chạm (hash collision) cực nhỏ trong không gian 31-bit nếu có rất nhiều task.

---

### 2. Cơ chế Payload Deduplication Cache (Nhóm D)
- **Mục đích:** Tránh gọi `MethodChannel` hoặc ghi `SharedPreferences` + gửi broadcast `APPWIDGET_UPDATE` dư thừa khi dữ liệu hiển thị không hề thay đổi, giúp tiết kiệm pin và CPU.
- **File & Function:**
  - `lib/features/home_widget/data/services/home_widget_service.dart` (`HomeWidgetServiceImpl.updateWidgets`, dòng 37–42)
  - `lib/features/lockscreen/data/services/lockscreen_bridge_service.dart` (`MethodChannelLockscreenBridge.updateOngoingNotification`, dòng 32–34)
- **Input:** `HomeWidgetPayload` hoặc `LockscreenPayload`.
- **Output:** `Future<bool>` (`true` ngay lập tức nếu trùng cache).
- **Các bước xử lý:**
  1. So sánh `_lastPayload != null && _lastPayload == payload` (sử dụng `operator ==` đã override trên các field nội dung, **bỏ qua** `lastUpdatedAt` ở `HomeWidgetPayload` nên 2 payload cùng nội dung ở 2 phút khác nhau vẫn được coi là bằng nhau).
  2. Nếu bằng nhau: return `true`, bỏ qua toàn bộ lời gọi IPC Native.
  3. Nếu khác: gửi xuống Native; nếu thành công thì cập nhật `_lastPayload = payload`.
- **Độ phức tạp:** $O(1)$.
- **Ưu điểm:** Rất hiệu quả khi app `resumed` hoặc stream phát lại dữ liệu giống hệt cũ.
- **Nhược điểm:** Cache lưu trong RAM (`_lastPayload`), sẽ reset về `null` khi app bị tắt hoàn toàn (chấp nhận được vì lần mở lại cần đồng bộ lại 1 lần).

---

### 3. Thuật toán xác định Current Task & Next Task và Giải quyết trùng giờ (Nhóm B)
- **Mục đích:** Tại thời điểm `now`, chọn ra tối đa 1 **Current Task** (đang diễn ra) và 1 **Next Task** (sắp diễn ra gần nhất), xử lý được trường hợp nhiều task trùng khung giờ.
- **File & Function:** `lib/features/home_widget/presentation/providers/home_widget_providers.dart` — `evaluateCurrentAndNextTask(List<TaskEntity> tasks, DateTime now)` (dòng 54–99) và `_priorityWeight` (dòng 33–44).
- **Input:** `tasks` (`List<TaskEntity>` đã lọc theo ngày), `now` (`DateTime`).
- **Output:** Dart Record `({TaskEntity? currentTask, TaskEntity? nextTask})`.
- **Các bước xử lý:**
  1. Bỏ qua mọi task đã hoàn thành (`t.isCompleted || t.status == TaskStatus.completed`).
  2. Phân loại từng task:
     - **Active candidate:** Có cả `startTime` và `endTime`, thỏa mãn `startTime <= now` (inclusive) và `endTime > now` (exclusive).
     - **Upcoming candidate:** Có `startTime != null` và `startTime > now`.
  3. Sắp xếp `activeCandidates`:
     - Tiêu chí 1: Độ ưu tiên giảm dần (`urgent=4 > high=3 > medium=2 > low=1`).
     - Tiêu chí 2: `startTime` tăng dần (bắt đầu sớm hơn được chọn).
     - Tiêu chí 3: `endTime` tăng dần (kết thúc sớm hơn được chọn).
  4. Sắp xếp `upcomingCandidates`:
     - Tiêu chí 1: `startTime` tăng dần (sắp diễn ra gần nhất).
     - Tiêu chí 2: Độ ưu tiên giảm dần.
  5. Trả về `activeCandidates.first` (hoặc `null`) và `upcomingCandidates.first` (hoặc `null`).
- **Độ phức tạp:** Time $O(N \log N)$ với $N$ là số task trong ngày; Space $O(N)$.
- **Ví dụ thực tế:**
  - `08:00 - 10:00`: Task A (*Họp nhóm*, `medium`).
  - `09:00 - 11:00`: Task B (*Sửa bug khẩn*, `urgent`).
  - Tại `09:15`: Cả A và B đều thuộc `activeCandidates`. Vì `urgent (4) > medium (2)` $\Rightarrow$ `currentTask` = Task B.
  - Tại `10:00`: Nếu chỉ có Task A (`08:00 - 10:00`) và Task C (`10:00 - 11:00`), vì `endTime` là exclusive (`10:00 > 10:00` là `false`) và `startTime` là inclusive (`10:00 <= 10:00` là `true`) $\Rightarrow$ Task A kết thúc, Task C lập tức trở thành `currentTask`.
- **Lưu ý quan trọng (Sự không đồng nhất trong code hiện tại):** `currentTaskStreamProvider` và `nextTaskStreamProvider` trong `lib/features/tasks/presentation/providers/task_providers.dart` (dùng cho `HomeScreen` và `LockscreenPayload`) **không dùng** `evaluateCurrentAndNextTask`, mà dùng `tasks.firstWhere(...)` (không xét độ ưu tiên khi trùng giờ) và `nextTaskStreamProvider` lại cho phép task không có `startTime` lọt vào danh sách upcoming.

---

### 4. Thuật toán sắp xếp Task trên Calendar (Nhóm B)
- **Mục đích:** Hiển thị danh sách công việc trong ngày được chọn một cách khoa học (việc có giờ cụ thể lên trên, việc cả ngày/chưa đặt giờ xuống dưới).
- **File & Function:** `lib/features/calendar/presentation/providers/calendar_providers.dart` — `selectedDateTasksProvider` (dòng 61–89).
- **Độ phức tạp:** $O(N \log N)$.
- **Quy tắc:** Lọc `DateFormatter.isSameDay(t.dueDate, selectedDate)` $\rightarrow$ Task có `startTime != null` đứng trước task `startTime == null`; giữa 2 task có giờ thì so `startTime ASC`, bằng giờ thì so `createdAt ASC`.

---

### 5. Cơ chế tính thời điểm chuyển Task & Dynamic Clock (Nhóm C + D)
- **Mục đích:** Cập nhật Home Screen Widget đúng khoảnh khắc task bắt đầu, kết thúc hoặc sang ngày mới mà **không dùng `Timer.periodic(1s)`** gây hao pin.
- **File & Function:** `lib/features/home_widget/presentation/providers/home_widget_providers.dart`:
  - `calculateNextTransitionTime(List<TaskEntity> tasks, DateTime now)` (dòng 15–31)
  - `homeWidgetClockProvider` (dòng 121–151)
- **Các bước xử lý:**
  1. `calculateNextTransitionTime` duyệt qua các task chưa hoàn thành, tìm thời điểm nhỏ nhất (`earliest`) trong tập `{startTime, endTime}` mà lớn hơn `now`. Độ phức tạp $O(N)$.
  2. `homeWidgetClockProvider` tính `nextMinute = đầu phút tiếp theo` (ví dụ `08:59:12` $\rightarrow$ `09:00:00`).
  3. Chọn `targetTime = min(nextTransition, nextMinute)`.
  4. Ngủ bằng `await Future.delayed(targetTime.difference(DateTime.now()))` rồi `yield DateTime.now()`.
- **Ưu điểm:** Nếu task bắt đầu lúc `09:00:00` hoặc `09:00:30`, đồng hồ thức dậy đúng giây đó; tiết kiệm tài nguyên hơn nhiều so với polling mỗi giây.
- **Nhược điểm:** Chỉ hoạt động khi Flutter engine còn sống (foreground hoặc background chưa bị OS kill). Khi app bị force-stop, Android OS chặn mọi background Dart isolate cho đến khi người dùng mở lại app.

---

### 6. Lọc ngày & Chuyển giao qua nửa đêm (Midnight Transition) (Nhóm C)
- **File & Function:** `homeWidgetPayloadProvider` (`home_widget_providers.dart`, dòng 159–171) và `todayTasksStreamProvider` (`task_providers.dart`, dòng 67–75).
- **Logic nghiệp vụ:**
  - Nếu task có `dueDate != null`: khớp năm/tháng/ngày với `clock`.
  - Else nếu `startTime != null`: khớp năm/tháng/ngày với `clock`.
  - Else (task không có cả `dueDate` lẫn `startTime`): mặc định luôn thuộc danh sách "Hôm nay" (`return true`).
- **Hiệu quả:** Khi đồng hồ bước qua `00:00:00` ngày mới, `clock` đổi ngày $\Rightarrow$ các task của ngày hôm trước tự động bị loại khỏi `totalTasksToday`, tiến độ reset sạch về `0/0` (hoặc số task của ngày mới).

---

### 7. Thuật toán sinh lưới lịch tháng 7 cột (Nhóm C)
- **File & Function:** `lib/features/calendar/presentation/widgets/calendar_month_view.dart` (`build`, dòng 18–54).
- **Các bước:** Tính `firstDayOfMonth`, `daysInMonth` (bằng mẹo `DateTime(year, month + 1, 0).day`), tính `leadingDays = firstDayOfMonth.weekday - 1` (vì Thứ Hai = 1), thêm ngày cuối tháng trước, thêm ngày tháng hiện tại, rồi bù `remainingDays = (7 - (gridDays.length % 7)) % 7` ngày đầu tháng sau để đủ bội số của 7 (35 hoặc 42 ô). Độ phức tạp $O(1)$ (tối đa 42 phần tử).

---

### 8. Thuật toán Idempotent Startup Reminder Reconciliation (Nhóm D + E)
- **Mục đích:** Đồng bộ hai chiều giữa bảng `Tasks` trong SQLite (nguồn chân lý) và hàng đợi thông báo của OS (`pendingNotificationRequests`), đảm bảo không bị sót nhắc nhở và không bị thông báo ma (orphaned notification).
- **File & Function:** `lib/features/reminders/presentation/providers/reminder_providers.dart` — `TaskReminderSyncService.reconcileStartupReminders(List<TaskEntity> tasks)` (dòng 45–82).
- **Input:** Danh sách tất cả `TaskEntity` từ `allTasksStreamProvider`.
- **Các bước xử lý:**
  1. Lấy danh sách `pendingIds` hiện có từ OS.
  2. Khởi tạo tập hợp `validActiveNotificationIds = <int>{}`.
  3. Với mỗi `task`: tính `notifId = getDeterministicNotificationId(task.id)`. Kiểm tra 5 điều kiện hợp lệ (`!isCompleted`, `status != cancelled`, `reminderEnabled`, `calculatedReminderTime != null`, `scheduledTime.isAfter(now)`).
     - Nếu hợp lệ: thêm `notifId` vào `validActiveNotificationIds` và gọi `scheduleTaskReminder` (ghi đè idempotent).
     - Nếu không hợp lệ nhưng `pendingIds.contains(notifId)`: gọi `cancelTaskReminder(task.id)`.
  4. Quét lại `pendingIds`: bất kỳ ID nào không nằm trong `validActiveNotificationIds` (tức task đã bị xóa hẳn khỏi DB) $\rightarrow$ gọi `cancelNotificationById(pendingId)`.
- **Độ phức tạp:** $O(N + P)$ với $N$ là số task và $P$ là số pending notifications (nhờ dùng `Set<int>` để tra cứu $O(1)$).

---

### 9. Phân biệt rõ nguồn gốc cơ chế
- **Tự triển khai:** FNV-1a hash, `evaluateCurrentAndNextTask`, `calculateNextTransitionTime`, `homeWidgetClockProvider`, `reconcileStartupReminders`, Deduplication Cache, Calendar grid.
- **Thư viện thực hiện:** `Drift` `Stream.watch()` (theo dõi thay đổi bảng SQLite), `timezone` `TZDateTime.from()` (chuyển đổi múi giờ), `intl` `DateFormat` (định dạng chuỗi giờ).
- **Logic nghiệp vụ dự án:** Quy tắc validation trong `CreateTask`/`UpdateTask`, `ReminderOffset` (7 mốc), Compact Widget fallback sang Next Task khi rảnh.
- **Cơ chế hệ điều hành Android:** `AlarmManager` kích hoạt `ScheduledNotificationReceiver` ở chế độ `exactAllowWhileIdle`, `ScheduledNotificationBootReceiver` khôi phục sau reboot, `AppWidgetManager` cập nhật `RemoteViews`.

