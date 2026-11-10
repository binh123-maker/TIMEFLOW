# BÁO CÁO LỖI CHỨC NĂNG SPRINT 6.2 (PHASE 06.2 FUNCTIONAL BUG REPORT)

**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian thực hiện:** 09/11/2026  
**Mục tiêu:** Ghi nhận toàn bộ lỗi, vấn đề biên và thiếu sót phát hiện được trong quá trình kiểm thử chức năng Sprint 6.2, kèm Root Cause, giải pháp sửa lỗi và kết quả sau khi khắc phục.

---

## 1. TỔNG QUAN CÁC VẤN ĐỀ ĐƯỢC PHÁT HIỆN

| ID Lỗi | Mức Độ | Khu Vực | Mô Tả Lỗi | Trạng Thái |
| :--- | :--- | :--- | :--- | :--- |
| **BUG-01** | CRITICAL | Android Manifest (`AndroidManifest.xml`) | Sai package name của `ScheduledNotificationBootReceiver` dẫn đến crash `ClassNotFoundException` khi hệ thống kích hoạt boot receiver. | **ĐÃ SỬA (FIXED)** |
| **BUG-02** | MEDIUM | Kotlin Native (`TimeflowWidgetCompactProvider.kt`) | Compact Widget (2×1) chỉ kiểm tra `hasCurrentTask`. Khi không có task đang diễn ra mà có task tiếp theo trong ngày, widget báo trống thay vì hiển thị Task tiếp theo. | **ĐÃ SỬA (FIXED)** |
| **BUG-03** | LOW / EDGE CASE | Dart Logic (`home_widget_providers.dart`) | Chưa có quy tắc xử lý tất định cho các task chồng lấn thời gian (Overlapping tasks). | **ĐÃ SỬA (FIXED)** |
| **BUG-04** | LOW / EDGE CASE | Dart Logic (`home_widget_providers.dart`) | Khi đồng hồ chuyển sang ngày mới (Midnight Transition), danh sách task của ngày hôm trước chưa được lọc chặt chẽ theo ngày của `clock`. | **ĐÃ SỬA (FIXED)** |

---

## 2. CHI TIẾT TỪNG VẤN ĐỀ & BIỆN PHÁP KHẮC PHỤC

### BUG-01: Sai Package Name trong AndroidManifest.xml Gây Crash Khởi Động

- **Hiện tượng:** Khi emulator khởi động hoặc hệ thống gửi intent khởi động máy (`BOOT_COMPLETED`), Android logcat ghi nhận ngoại lệ nghiêm trọng:
  ```
  java.lang.RuntimeException: Unable to instantiate receiver com.dexterkrishnan.flutter_local_notifications.ScheduledNotificationBootReceiver:
  java.lang.ClassNotFoundException: Didn't find class "com.dexterkrishnan.flutter_local_notifications.ScheduledNotificationBootReceiver"
  ```
- **Root Cause:** Trong `android/app/src/main/AndroidManifest.xml`, receiver của thư viện thông báo cục bộ bị khai báo sai tên package:
  `com.dexterkrishnan.flutter_local_notifications...` (sai tên tác giả / thư viện).
  Tên package đúng của thư viện `flutter_local_notifications` là:
  `com.dexterous.flutterlocalnotifications...`.
- **Phạm vi ảnh hưởng:** Gây crash ứng dụng khi thiết bị khởi động lại hoặc khi hệ thống quét receiver, ảnh hưởng đến độ tin cậy của ứng dụng và widget.
- **Biện pháp sửa đổi:**
  Chỉnh sửa `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <!-- Thay thế com.dexterkrishnan bằng com.dexterous.flutterlocalnotifications -->
  <receiver
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
      android:exported="false">
      <intent-filter>
          <action android:name="android.intent.action.BOOT_COMPLETED"/>
          <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
          <action android:name="android.intent.action.QUICKBOOT_POWERON" />
          <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
      </intent-filter>
  </receiver>
  <receiver
      android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
      android:exported="false" />
  ```
- **Kết quả xác minh:** Ứng dụng khởi động mượt mà trên Android 16 API 36.1, `adb logcat -b crash` hoàn toàn không còn ghi nhận bất kỳ ngoại lệ nào.

---

### BUG-02: Compact Widget Không Hiển Thị Fallback Task Tiếp Theo

- **Hiện tượng:** Khi người dùng có Task sắp diễn ra trong ngày nhưng thời điểm hiện tại chưa tới giờ bắt đầu (`hasCurrentTask = false`, `hasNextTask = true`), Compact Widget (2×1) hiển thị `"Không có công việc đang diễn ra"`.
- **Root Cause:** Trong `TimeflowWidgetCompactProvider.kt`, mã nguồn cũ chỉ đọc và kiểm tra cờ `hasCurrentTask`. Nếu cờ này `false`, widget lập tức hiển thị trạng thái rỗng mà không đọc các key `hasNextTask`, `nextTaskTitle`, `nextTaskTime`, `nextTaskPriority` đã được Flutter đồng bộ sang SharedPreferences. Điều này không tương thích với tài liệu thiết kế `docs/LOCKSCREEN_TECHNICAL_DESIGN.md` Mục 7 ("2x1 Công việc hiện tại & tiếp theo").
- **Phạm vi ảnh hưởng:** Trải nghiệm người dùng trên màn hình chính bị gián đoạn, người dùng không nắm bắt được task tiếp theo sắp diễn ra.
- **Biện pháp sửa đổi:**
  Bổ sung logic fallback trong `android/app/src/main/kotlin/com/timeflow/timeflow/TimeflowWidgetCompactProvider.kt`:
  ```kotlin
  val hasCurrent = prefs.getBoolean("hasCurrentTask", false)
  val hasNext = prefs.getBoolean("hasNextTask", false)

  if (hasCurrent) {
      views.setTextViewText(R.id.widget_app_name, "TIMEFLOW")
      views.setTextViewText(R.id.widget_task_title, prefs.getString("currentTaskTitle", "Không có việc") ?: "Không có việc")
      // Hiển thị task hiện tại...
  } else if (hasNext) {
      views.setTextViewText(R.id.widget_app_name, "TIMEFLOW • TIẾP THEO")
      views.setTextViewText(R.id.widget_task_title, prefs.getString("nextTaskTitle", "Không có việc") ?: "Không có việc")
      views.setTextViewText(R.id.widget_task_time, prefs.getString("nextTaskTime", "") ?: "")
      val priority = prefs.getString("nextTaskPriority", "") ?: ""
      // Hiển thị badge độ ưu tiên nếu có...
  } else {
      // Empty state sạch sẽ
      views.setTextViewText(R.id.widget_app_name, "TIMEFLOW")
      views.setTextViewText(R.id.widget_task_title, "Không có công việc đang diễn ra")
      views.setTextViewText(R.id.widget_task_time, "")
      views.setViewVisibility(R.id.widget_priority_badge, View.GONE)
  }
  ```
- **Kết quả xác minh:** Khi task hiện tại kết thúc hoặc chưa đến giờ, Compact Widget tự động chuyển sang hiển thị task tiếp theo với tiêu đề phụ rõ ràng `"TIMEFLOW • TIẾP THEO"`. Unit Test và Emulator xác nhận hoạt động chuẩn xác.

---

### BUG-03: Thiếu Quy Tắc Tất Định Cho Task Chồng Lấn Thời Gian (Overlapping Tasks)

- **Hiện tượng:** Nếu người dùng tạo 2 hoặc nhiều task có khung giờ chồng lấn lên nhau (ví dụ: Task A 10:00 - 12:00, Task B 10:30 - 11:30), việc lựa chọn task nào hiển thị làm Current Task trên Widget không có quy tắc rõ ràng, dẫn đến kết quả phụ thuộc vào thứ tự ngẫu nhiên trong danh sách.
- **Root Cause:** Hàm `evaluateCurrentAndNextTask` trong `home_widget_providers.dart` lọc `activeCandidates` nhưng chưa thực hiện sắp xếp tiebreaker theo mức độ ưu tiên nghiệp vụ.
- **Biện pháp sửa đổi:**
  Bổ sung quy tắc sắp xếp ưu tiên chặt chẽ:
  1. Mức độ ưu tiên cao hơn được chọn làm Current Task: `Urgent` (4) > `High` (3) > `Medium` (2) > `Low` (1).
  2. Nếu cùng mức độ ưu tiên, task có thời gian bắt đầu sớm hơn (`startTime` ASC) được chọn.
  3. Nếu cùng thời gian bắt đầu, task kết thúc sớm hơn (`endTime` ASC) được chọn.
  ```dart
  int priorityWeight(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgent: return 4;
      case TaskPriority.high: return 3;
      case TaskPriority.medium: return 2;
      case TaskPriority.low: return 1;
    }
  }

  activeCandidates.sort((a, b) {
    final pA = priorityWeight(a.priority);
    final pB = priorityWeight(b.priority);
    if (pA != pB) return pB.compareTo(pA); // Ưu tiên cao hơn xếp trước
    final sA = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
    final sB = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
    final startCompare = sA.compareTo(sB);
    if (startCompare != 0) return startCompare;
    final eA = a.endTime ?? DateTime.fromMillisecondsSinceEpoch(0);
    final eB = b.endTime ?? DateTime.fromMillisecondsSinceEpoch(0);
    return eA.compareTo(eB);
  });
  ```
- **Kết quả xác minh:** Đã bổ sung Unit Test #24 và #25 trong `test/home_widget_test.dart`, cả 2 test đều PASS 100%.

---

### BUG-04: Lọc Task Khi Chuyển Sang Ngày Mới (Midnight Transition)

- **Hiện tượng:** Khi qua thời điểm 00:00:00 sang ngày mới, nếu SharedPreferences vẫn lưu giữ `totalTasksToday` của ngày cũ trước khi người dùng tạo task mới, chỉ số tiến độ trên Widget có thể hiển thị sai lệch.
- **Root Cause:** Cần đảm bảo `homeWidgetPayloadProvider` chỉ lấy các task có ngày trùng khớp chính xác với ngày hiện tại của `clock` (theo múi giờ `Asia/Ho_Chi_Minh`), ngay cả khi dữ liệu SQLite chưa phát sinh thay đổi.
- **Biện pháp sửa đổi:**
  Cập nhật logic trong `homeWidgetPayloadProvider`:
  ```dart
  final todayTasks = tasks.where((t) {
    final taskDate = t.startTime ?? t.dueDate;
    if (taskDate == null) return false;
    return taskDate.year == clock.year &&
           taskDate.month == clock.month &&
           taskDate.day == clock.day;
  }).toList();
  ```
- **Kết quả xác minh:** Bổ sung Unit Test #28 xác nhận task của ngày hôm qua lập tức bị loại khỏi payload của ngày hôm nay. Test PASS 100%.

---

## 3. TỔNG KẾT

Tất cả các lỗi và hạn chế biên đã được xử lý triệt để, kiểm thử tự động toàn diện và kiểm tra thực tế trên Android Emulator.
Hệ thống không còn bất kỳ lỗi blocking hoặc crash nào.

