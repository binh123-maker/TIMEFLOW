# PHẦN 13 – BỘ CÂU HỎI PHỎNG VẤN & BẢO VỆ ĐỒ ÁN (INTERVIEW & DEFENSE QUESTIONS)

Bộ câu hỏi này tập trung vào các quyết định kỹ thuật thực tế trong **TIMEFLOW** để bạn tự tin trình bày trước hội đồng bảo vệ đồ án hoặc nhà tuyển dụng Mobile/Flutter.

---

### Nhóm 1: Kiến trúc & Quyết định thiết kế

**Câu 1: Em hãy trình bày kiến trúc tổng thể của TIMEFLOW. Tại sao không áp dụng Clean Architecture 3 tầng cho toàn bộ 100% các module?**
> *Gợi ý trả lời:* TIMEFLOW áp dụng **Feature-First + Clean Architecture (Light) + Repository Pattern**. Module cốt lõi `tasks` có đầy đủ Domain (`TaskEntity`, 5 UseCases), Data (`ITaskRepository`, `TaskRepositoryImpl`, `TaskDao`), và Presentation (`TasksScreen`, Riverpod Providers). Các module đọc dữ liệu như `calendar`, `home`, `reminders` chia sẻ trực tiếp `TaskEntity` và UseCases để tránh dư thừa boilerplate (over-engineering) cho một dự án quy mô vừa, nhưng vẫn giữ được ranh giới rõ ràng qua interface (`ILocalNotificationService`, `ILockscreenBridge`, `IHomeWidgetService`).

**Câu 2: Tại sao TIMEFLOW chọn Drift (SQLite) làm "Single Source of Truth" và không cho Android Native ghi trực tiếp vào database?**
> *Gợi ý trả lời:* Nếu cả Flutter và Kotlin cùng mở file `timeflow.sqlite`, rất dễ xảy ra xung đột khóa file (database lock), race condition và đặc biệt là Drift sẽ không biết dữ liệu bị sửa từ bên ngoài để phát lại `Stream` cho UI. Do đó, mọi thao tác ghi đều đi qua Drift DAO ở Flutter; Native chỉ nhận payload chỉ-đọc qua `MethodChannel` hoặc `SharedPreferences`.

---

### Nhóm 2: Thuật toán & Tối ưu hiệu năng

**Câu 3: Khi có nhiều công việc trùng khung giờ, TIMEFLOW chọn "Công việc hiện tại" trên Widget như thế nào?**
> *Gợi ý trả lời:* Hàm `evaluateCurrentAndNextTask` trong `home_widget_providers.dart` lọc các task chưa hoàn thành có `startTime <= now < endTime`, sau đó sắp xếp tất định theo 3 cấp: (1) Độ ưu tiên giảm dần (`urgent > high > medium > low`), (2) `startTime` tăng dần, (3) `endTime` tăng dần.

**Câu 4: Làm thế nào Home Screen Widget tự cập nhật khi task kết thúc lúc 09:00 mà không làm hao pin điện thoại?**
> *Gợi ý trả lời:* Dự án dùng `homeWidgetClockProvider` kết hợp `calculateNextTransitionTime`. Thay vì chạy `Timer.periodic` mỗi giây, provider tính chính xác mốc `startTime` hoặc `endTime` sắp tới gần nhất (hoặc đầu phút tiếp theo) và dùng `Future.delayed` ngủ đúng khoảng thời gian đó. Ngoài ra, `HomeWidgetServiceImpl` và `MethodChannelLockscreenBridge` đều có **Deduplication Cache** (`_lastPayload == payload`) để không gọi IPC Native nếu nội dung không đổi.

**Câu 5: Tại sao phải tự cài đặt thuật toán băm FNV-1a 32-bit cho Notification ID thay vì dùng `task.id.hashCode`?**
> *Gợi ý trả lời:* Vì `hashCode` mặc định của Dart không ổn định qua các lần khởi động lại tiến trình ứng dụng. Nếu ID thay đổi sau khi tắt mở app, `TaskReminderSyncService.reconcileStartupReminders` sẽ không thể hủy hoặc ghi đè đúng thông báo đã hẹn trước đó. FNV-1a 32-bit (kết hợp mask `0x7FFFFFFF` để ra số nguyên dương 31-bit) đảm bảo cùng một UUID luôn sinh ra đúng một Notification ID duy nhất trên mọi lần chạy.

---

### Nhóm 3: Android Native, Lockscreen & Giới hạn hệ điều hành

**Câu 6: Tại sao ứng dụng không đặt thẳng Widget lên màn hình khóa Android mà lại dùng Ongoing Notification?**
> *Gợi ý trả lời:* Trên Android 12–15 hiện đại, phần lớn các hãng (OEM) không cho phép ứng dụng bên thứ ba đặt tự do `AppWidget` lên màn hình khóa. Vì vậy, giải pháp chuẩn và tương thích rộng nhất là dùng **Ongoing Notification** (`setOngoing(true)`, `VISIBILITY_PUBLIC`, `IMPORTANCE_LOW`) thông qua `LockscreenNotificationManager.kt` cho màn hình khóa, kết hợp **Home Screen Widget** (`TimeflowWidgetCompactProvider` 2×1 và `TimeflowWidgetExpandedProvider` 4×2) cho màn hình chính.

**Câu 7: Trong quá trình làm Home Screen Widget, nhóm/em từng gặp lỗi gì đáng chú ý và đã xử lý ra sao?**
> *Gợi ý trả lời:* Trong Sprint 6.2 từng gặp lỗi `"Can't load widget"` trên Android Launcher do file XML `RemoteViews` sử dụng thẻ `<View>` làm spacer và `<clip>` trong progress bar drawable. Sau khi kiểm tra log và thay thế bằng `<TextView>` và `<scale>`, cả hai kích thước Widget đã render ổn định trên Emulator API 36.1.

**Câu 8: Điều gì xảy ra nếu người dùng Force-Stop ứng dụng hoặc khởi động lại máy?**
> *Gợi ý trả lời:* Nếu người dùng Force-Stop, Android OS chặn mọi background execution cho đến khi mở lại app (Widget giữ nguyên trạng thái cuối, khi mở app `didChangeAppLifecycleState` sẽ đồng bộ lại ngay). Khi khởi động lại máy, `ScheduledNotificationBootReceiver` được khai báo trong `AndroidManifest.xml` giúp `flutter_local_notifications` khôi phục các lịch nhắc (tuy nhiên cần ghi nhận trung thực là kịch bản Cold Reboot mới ở mức Build Verified, chưa test thực tế trên Emulator).

---

### Nhóm 4: Trung thực về Hạn chế & Hướng phát triển

**Câu 9: Nếu hội đồng hỏi "Điểm yếu lớn nhất hiện tại của TIMEFLOW là gì?", em sẽ trả lời thế nào?**
> *Gợi ý trả lời:* Có 4 điểm yếu chính cần xử lý ở Sprint 7: (1) Bản release trong `build.gradle.kts` đang dùng debug signing key; (2) Logic chọn Current/Next Task trên `HomeScreen` (`task_providers.dart`) chưa đồng bộ với thuật toán ưu tiên của `HomeWidget`; (3) Xin quyền thông báo ngay khi mở app chưa có màn hình Onboarding giải thích trước; (4) Đã có 87 unit/integration tests rất tốt cho tầng logic/DB, nhưng chưa có Widget Test cho tầng UI và một số tab như `Statistics`, `Focus` mới ở mức khung giao diện.

**Câu 10: Tại sao chưa tích hợp AI hay Cloud Sync vào TIMEFLOW ở giai đoạn này?**
> *Gợi ý trả lời:* Vì TIMEFLOW định vị là ứng dụng **Local-First**. Việc ưu tiên hoàn thiện trải nghiệm offline (Recurring Tasks, Statistics thật, Pomodoro Focus, Snooze, Export/Import JSON) mang lại giá trị trực tiếp cho người dùng với chi phí vận hành bằng 0, trước khi đầu tư hạ tầng Backend/AI phức tạp.

