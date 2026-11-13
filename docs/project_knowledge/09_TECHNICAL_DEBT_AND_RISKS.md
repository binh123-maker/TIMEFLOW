# PHẦN 9 – ĐÁNH GIÁ CÁC ĐIỂM YẾU VÀ THIẾU SÓT (TECHNICAL DEBT & RISKS)

**Ngày đánh giá:** 12/11/2026  
**Vai trò đánh giá:** Senior Flutter Engineer & Software Architect  
**Nguyên tắc:** Mọi nhận định đều có dẫn chứng trực tiếp từ mã nguồn thực tế.

---

## Tổng hợp các vấn đề theo mức độ nghiêm trọng

### CRITICAL (Cần xử lý trước khi phát hành chính thức / Google Play)

1. **[Release Readiness] Cấu hình ký bản Release đang dùng Debug Key**
   - **Bằng chứng:** `android/app/build.gradle.kts` (dòng 35–39): `release { signingConfig = signingConfigs.getByName("debug") }`, kèm `TODO` chưa thay đổi `applicationId` nếu cần.
   - **Rủi ro:** Không thể upload lên Google Play Store bằng debug keystore.

---

### HIGH (Nên xử lý sớm để đảm bảo tính đúng đắn và trải nghiệm)

2. **[State Management & Logic Consistency] Lệch logic xác định Current/Next Task giữa UI chính (`HomeScreen` + `Lockscreen`) và `HomeWidget`**
   - **Bằng chứng:**
     - `lib/features/home_widget/presentation/providers/home_widget_providers.dart` dùng `evaluateCurrentAndNextTask()` (có tie-breaker theo `TaskPriority` khi trùng giờ, loại trừ task không có `startTime` khỏi Next Task) và được kích hoạt lại theo thời gian thực bởi `homeWidgetClockProvider`.
     - Trong khi đó, `lib/features/tasks/presentation/providers/task_providers.dart` (`currentTaskStreamProvider` dòng 80–99, `nextTaskStreamProvider` dòng 102–124) dùng `tasks.firstWhere(...)` (lấy task đầu tiên theo thứ tự DB, bỏ qua độ ưu tiên khi trùng giờ), cho phép task không có `startTime` thành `nextTask`, và dùng `DateTime.now()` tĩnh (không tự chuyển task khi sang phút mới trừ khi DB đổi).
     - `LockscreenPayload` (`lockscreen_providers.dart` dòng 34–35) lại đọc từ `currentTaskStreamProvider` và `nextTaskStreamProvider`!
   - **Hệ quả:** Khi có 2 task trùng giờ hoặc khi task kết thúc lúc app đang mở, Home Screen Widget có thể hiển thị **khác** với `HomeScreen` và Lockscreen Ongoing Notification.

3. **[Permission Management & UX] Xin quyền `POST_NOTIFICATIONS` đột ngột ngay lần mở app đầu tiên**
   - **Bằng chứng:** `lib/main.dart` (dòng 54) gọi `await notifService.requestPermissions();` ngay trong `addPostFrameCallback` mà không có màn hình giải thích lợi ích trước.
   - **Hệ quả:** Dễ bị người dùng từ chối; chưa kiểm tra quyền `SCHEDULE_EXACT_ALARM` trên Android 14+ (`canScheduleExactAlarms()`).

4. **[Testing] Hoàn toàn thiếu Widget Test (`WidgetTester`) cho toàn bộ màn hình UI**
   - **Bằng chứng:** Thư mục `test/` có 87 unit/integration tests nhưng **0 test** sử dụng `testWidgets()`. Ngay cả `test/widget_test.dart` cũng chỉ chứa unit test cho `DateFormatter` và `TaskEntity`.
   - **Hệ quả:** Không tự động phát hiện được lỗi layout overflow, lỗi render hoặc hỏng luồng tương tác UI khi refactor.

5. **[Notification Reliability] Chưa kiểm chứng thực tế `ScheduledNotificationBootReceiver` khi Cold Reboot**
   - **Bằng chứng:** `docs/PHASE_06_2_FUNCTIONAL_TEST_REPORT.md` (Test 18: **BLOCKED**) và `docs/PHASE_06_2_GIT_RELEASE_REPORT.md` (Mục 6).
   - **Hệ quả:** Chưa có bằng chứng thực tế xác nhận lịch nhắc vẫn kêu sau khi tắt nguồn bật lại máy.

---

### MEDIUM (Cần cải thiện để nâng cao chất lượng và bảo trì)

6. **[Database Design & Performance] Thiếu Index và tải toàn bộ bảng `Tasks` vào RAM**
   - **Bằng chứng:** `lib/data/database/tables/task_table.dart` không có index trên `dueDate`, `startTime`, `isCompleted`; `TaskDao.watchAllTasks()` (`task_dao.dart` dòng 12) lấy toàn bộ bảng rồi lọc bằng Dart ở `todayTasksStreamProvider` và `selectedDateTasksProvider`.
   - **Hệ quả:** Tốn bộ nhớ và thời gian lọc khi số lượng task tăng lớn.

7. **[User Experience] 5 màn hình trong Router mới chỉ là Placeholder (Skeleton)**
   - **Bằng chứng:** `FocusScreen`, `StatisticsScreen`, `TimelineScreen`, `ProfileScreen`, `SubscriptionScreen` đều chỉ hiển thị chữ thông báo chờ Phase sau. Đáng chú ý, **tab thứ 4 trên BottomNavigationBar** (`Thống kê` $\rightarrow$ `StatisticsScreen`) là tab chính nhưng chưa có chức năng thật.

8. **[Code Quality] Tồn tại Dead Code, File thừa và Stub chưa dọn**
   - **Bằng chứng:**
     - `lib/data/models/task_model.dart`: Không được import ở bất kỳ đâu.
     - `lib/core/database/app_database.dart`: Chỉ có 1 dòng `export` dư thừa.
     - `lib/services/notification_service.dart`: Stub cũ trùng vai trò với `lib/core/notifications/local_notification_service.dart`.
     - `lib/features/home/providers/today_schedule_provider.dart` (`liveClockProvider`): Khai báo nhưng `HomeScreen` hiện tại dùng `DateTime.now()` trực tiếp (dòng 20), không `watch(liveClockProvider)`.

9. **[Error Handling] Lỗi IPC hoặc DB chỉ in `debugPrint` hoặc nuốt lỗi**
   - **Bằng chứng:** `local_notification_service.dart` (dòng 184–186) bắt mọi exception khi `zonedSchedule` và chỉ `debugPrint`, không thông báo cho UI biết nếu thiếu quyền `SCHEDULE_EXACT_ALARM`.

10. **[Accessibility] Chưa tối ưu Semantics / Screen Reader**
    - **Bằng chứng:** Các custom card (`CurrentTaskCard`, `TimelineScheduleWidget`) và ô lịch (`CalendarMonthView`) chưa khai báo `Semantics` label cho người dùng khiếm thị (TalkBack).

---

### LOW (Có thể thực hiện sau)

11. **[Security] Dữ liệu SQLite chưa mã hóa:** Chấp nhận được cho To-do app offline, nhưng cần lưu ý nếu mở rộng sang thông tin cá nhân/tài khoản.
12. **[Architecture] `flutter_svg` và `dio` đã thêm vào `pubspec.yaml` nhưng chưa sử dụng thực tế:** Làm tăng nhẹ kích thước dependency khi chưa cần thiết.
13. **[Settings] Key `keyUserLanguage` đã khai báo ở `app_constants.dart` nhưng chưa có tính năng đổi ngôn ngữ Anh/Việt.**
14. **[Build] `gradlew.bat test` bị lỗi trên Windows khi workspace ở ổ `D:\` còn Pub Cache ở ổ `C:\`** (`PHASE_06_2_GIT_RELEASE_REPORT.md` mục 2.4).
15. **[Android Compatibility] Phiên bản hiển thị trong `SettingsScreen` (dòng 66) vẫn ghi cứng `'Phiên bản 1.0.0 (Phase 1 Init)'`** thay vì đọc động hoặc cập nhật theo Sprint 6.2 (`v0.6.2`).

