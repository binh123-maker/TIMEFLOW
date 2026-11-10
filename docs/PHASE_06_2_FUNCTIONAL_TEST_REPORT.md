# BÁO CÁO KIỂM THỬ CHỨC NĂNG SPRINT 6.2 (PHASE 06.2 FUNCTIONAL TEST REPORT)

**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian thực hiện:** 09/11/2026  
**Mục tiêu:** Kiểm thử thực tế toàn diện chức năng Android Home Screen Widget (Compact 2×1 và Expanded 4×2), xác thực tính đồng bộ Drift SQLite → SharedPreferences → RemoteViews, Time Transitions, App Lifecycle và Tương tác.

---

## 1. MÔI TRƯỜNG KIỂM THỬ

- **Hệ điều hành Host:** Windows 11
- **Thiết bị giả lập (Emulator):** Android Emulator `emulator-5554` (AVD: `Medium_Phone_API_36.1`, Android 16 Preview / SDK 36.1, Google Play x86_64)
- **Múi giờ thiết bị:** `Asia/Ho_Chi_Minh` (GMT+7)
- **Flutter SDK:** Flutter 3.x / Dart 3.x (`C:\flutter\flutter\bin\flutter.bat`)
- **Android NDK/Build Tools:** Compile SDK 34 / Java 17 / Kotlin 1.9.0
- **APK thử nghiệm:** `build\app\outputs\flutter-apk\app-debug.apk` (Built: 09/11/2026, Debug build)

---

## 2. MA TRẬN KẾT QUẢ KIỂM THỬ CHI TIẾT (TEST 01 – TEST 19)

| Mã Test | Tên Test Case | Phương Pháp Kiểm Thử | Trạng Thái | Ghi Chú / Bằng Chứng |
| :--- | :--- | :--- | :--- | :--- |
| **Test 01** | Không có Task (Empty State) | Emulator Verified + Unit Tested | **PASS** | Widget hiển thị "Không có công việc đang diễn ra", tiến độ 0/0. Không crash, không null format. Minh chứng: `docs/home_empty.png`. Unit Test #19 pass. |
| **Test 02** | Có một Task đang diễn ra (Current Task) | Emulator Verified + Unit Tested | **PASS** | Nhận diện đúng Current Task, tiêu đề, khung giờ, mức độ ưu tiên "Cao". Đồng bộ qua SharedPreferences key `currentTaskTitle`, `currentTaskTime`, `currentTaskPriority`. Unit Test #20 pass. |
| **Test 03** | Có Task tiếp theo (Next Task) | Emulator Verified + Unit Tested | **PASS** | Expanded Widget hiển thị song song Hiện tại & Tiếp theo. Compact Widget hiển thị Task tiếp theo khi không có task đang chạy với tiêu đề `"TIMEFLOW • TIẾP THEO"`. Unit Test #21 pass. |
| **Test 04** | Nhiều Task trong cùng ngày | Emulator Verified + Unit Tested | **PASS** | Các task sắp xếp theo `startTime` tăng dần (ASC). Phân loại chính xác Current Task và Next Task đầu tiên. Thống nhất giữa Compact và Expanded. Unit Test #23 pass. |
| **Test 05** | Task đã hoàn thành (Completed Exclusion) | Emulator Verified + Unit Tested | **PASS** | Task sau khi hoàn thành bị loại khỏi danh sách chờ, Widget tự động chuyển sang Task chưa hoàn thành tiếp theo. Unit Test #22 pass. |
| **Test 06** | CRUD – Create Task | Emulator Verified + Unit Tested | **PASS** | Tạo task mới trên giao diện ứng dụng kích hoạt Drift SQLite stream, tự động đẩy payload sang `HomeWidgetPreferences.xml` và trigger native appwidget update. Unit Test #29 pass. |
| **Test 07** | CRUD – Update Task | Emulator Verified + Unit Tested | **PASS** | Thay đổi trạng thái, giờ hoặc mức độ ưu tiên lập tức cập nhật `HomeWidgetPreferences.xml` (từ 100% về 50%, tiến độ 2/2 về 1/2). Unit Test #29 pass. |
| **Test 08** | CRUD – Complete Task | Emulator Verified + Unit Tested | **PASS** | Tích chọn hoàn thành task trên UI: SharedPreferences cập nhật `completedTasksToday` từ 1 lên 2, `progressText` từ "1/2" sang "2/2", `progressPercent` từ 50 lên 100%. Unit Test #22, #29 pass. |
| **Test 09** | CRUD – Delete Task | Emulator Verified + Unit Tested | **PASS** | Xóa task: SharedPreferences lập tức cập nhật `totalTasksToday` từ 2 về 1, `progressText` từ "2/2" về "1/1". Unit Test #29 pass. |
| **Test 10** | CRUD – Delete toàn bộ Task thử nghiệm | Emulator Verified + Unit Tested | **PASS** | Xóa toàn bộ task trong ngày: Widget trở về Empty State sạch sẽ (`hasCurrentTask=false`, `hasNextTask=false`, `progressText="0/0"`). Minh chứng: `docs/home_empty.png`. |
| **Test 11** | Chuyển sang thời gian bắt đầu (08:59 → 09:00) | Unit Tested | **PASS** | Logic `evaluateCurrentAndNextTask` và `calculateNextTransitionTime` tại 08:59 nhận diện task A là Current; tại 09:00 task A kết thúc, task B kích hoạt thành Current. Unit Test #7, #8, #26 pass. |
| **Test 12** | Kết thúc Task (Task End Boundary) | Unit Tested | **PASS** | Đúng mốc `endTime`, task không còn được coi là Current Task (quy tắc: `now.isBefore(task.endTime)` độc quyền). Unit Test #9, #27 pass. |
| **Test 13** | Không có Task tiếp theo | Emulator Verified + Unit Tested | **PASS** | Khi các task còn lại đều đã xong hoặc qua giờ, widget hiển thị "Không có công việc tiếp theo". SharedPreferences `hasNextTask=false`. Unit Test #10 pass. |
| **Test 14** | Task chồng lấn (Overlapping Tasks) | Unit Tested + Code Verified | **PASS** | Quy tắc xử lý chồng lấn tất định: Ưu tiên TaskPriority DESC (Khẩn cấp > Cao > Trung bình > Thấp) -> `startTime` ASC -> `endTime` ASC. Đảm bảo 100% nhất quán, không crash. Unit Test #24, #25 pass. |
| **Test 15** | Chuyển sang ngày mới (Midnight Transition) | Unit Tested + Code Verified | **PASS** | `homeWidgetPayloadProvider` lọc task theo ngày của `clock` (Asia/Ho_Chi_Minh). Khi sang 00:00:00 ngày mới, task hôm trước tự động bị loại khỏi tổng số trong ngày, tiến độ reset sạch. Unit Test #28 pass. |
| **Test 16** | Đóng và mở lại ứng dụng (Lifecycle) | Emulator Verified | **PASS** | Force-stop ứng dụng (`am force-stop`), launcher giữ nguyên trạng thái widget. Khi khởi động lại ứng dụng, Riverpod auto-sync kích hoạt và đồng bộ lại SharedPreferences ngay lập tức. Minh chứng: `docs/reopened_home.png`. |
| **Test 17** | Đưa ứng dụng xuống nền (Backgrounding) | Emulator Verified | **PASS** | Nhấn Home (`keyevent 3`), widget tiếp tục hiển thị trạng thái chuẩn xác trên màn hình chính launcher. Minh chứng: `docs/both_widgets.png`. |
| **Test 18** | Khởi động lại thiết bị (Boot Receiver) | Build Verified + Code Verified (Chưa reboot thực tế thiết bị giả lập) | **BLOCKED** | Đã sửa lỗi tên package sai của `ScheduledNotificationBootReceiver` trong `AndroidManifest.xml` và xác minh build thành công. Do giới hạn môi trường chưa thực hiện cold reboot thiết bị giả lập để kiểm tra widget trước khi mở app, phân loại BLOCKED theo đúng quy định. |
| **Test 19** | Nhiều Widget cùng lúc (Multi-Widget) | Emulator Verified | **PASS** | Cùng lúc thêm cả Compact Widget (2×1) và Expanded Widget (4×2) lên launcher: cả hai hiển thị đầy đủ, không xung đột dữ liệu, cùng nhận cập nhật đồng bộ từ SharedPreferences. Minh chứng: `docs/both_widgets.png`. |

---

## 3. KIỂM TRA TƯƠNG TÁC (INTERACTION VERIFICATION)

- **Compact Widget (2×1):**
  - Nhấn vào thân widget mở `MainActivity` của ứng dụng TIMEFLOW.
  - Nhấn nút "Mở ứng dụng" (`widget_open_app_btn`) mở ứng dụng ngay lập tức.
  - Minh chứng: `docs/after_tap_widget.png`.
- **Expanded Widget (4×2):**
  - Nhấn vào thân widget hoặc nút điều hướng mở `MainActivity` trực tiếp.
  - Hoạt động ổn định cả khi ứng dụng đang chạy nền lẫn khi ứng dụng đã đóng.
- **Giới hạn tương tác:** Widget trên Android AppWidget hiện tại phục vụ mục đích hiển thị thông tin và điều hướng mở app, chưa hỗ trợ thao tác đánh dấu hoàn thành trực tiếp trên RemoteViews (phù hợp với thiết kế tại `docs/LOCKSCREEN_TECHNICAL_DESIGN.md`).

---

## 4. KẾT QUẢ KIỂM THỬ TỰ ĐỘNG & REGRESSION

### Flutter Analyze
```
Analyzing TODOLIST AND LOCKSCREEN...
No issues found! (ran in 9.5s)
```
- **0 errors, 0 warnings, 0 hints.**

### Flutter Test
```
00:02 +87: All tests passed!
```
- **87/87 tests PASS (100%)**:
  - Drift SQLite Database & Repository Integration Tests: PASS (14/14)
  - Calendar & SQLite Integration Tests: PASS (8/8)
  - Task Use Case Validation Tests: PASS (5/5)
  - Local Notification & Reminder Unit Tests: PASS (18/18)
  - Persistent Theme Settings Unit Tests: PASS (8/8)
  - TIMEFLOW Core Unit Tests: PASS (5/5)
  - HomeWidget Domain, Service, Time Transitions & Edge Cases: PASS (29/29)

### Kiểm Tra Tính Tương Thích & Regression
1. **Drift SQLite Single Source of Truth:** Android Native chỉ đọc SharedPreferences qua `HomeWidgetPreferences`, không có mã ghi can thiệp vào SQLite.
2. **Khóa màn hình & Ongoing Notification ID 1001:** Hoạt động độc lập, không bị ảnh hưởng bởi Home Screen Widget.
3. **Non-Android Compatibility (Windows/Web):** `HomeWidgetServiceImpl` kiểm tra `Platform.isAndroid` trước khi gọi MethodChannel, ngăn chặn crash trên môi trường Windows Desktop.

---

## 5. KẾT LUẬN

18/19 Test Case chức năng đạt trạng thái **PASS**. Riêng Test 18 (Cold Reboot thiết bị) phân loại **BLOCKED** do giới hạn môi trường chưa thực hiện restart emulator hoàn chỉnh, nhưng mã nguồn Boot Receiver đã được sửa đổi và Build Verified thành công. Hệ thống hoạt động ổn định, không còn lỗi tồn đọng.

