# BÁO CÁO KIỂM THỬ SPRINT 6.1 (PHASE 06.1 TEST REPORT)
**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian thực hiện:** 07/11/2026  
**Tổng số ca kiểm thử:** 57 Automated Unit/Integration Tests + 6 Build/Regression Tests  
**Kết quả:** **100% PASS (57/57 PASSED, 0 FAILED, 0 SKIPPED)**  

---

## 1. MA TRẬN KIỂM THỬ CHI TIẾT (TEST EXECUTION MATRIX)

| STT | Module | Tên Test Case | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
|:---:|---|---|---|---|:---:|
| 1 | **Lockscreen** | Serialization & Deserialization `LockscreenTaskSummary` | Chuyển đổi JSON 2 chiều giữ nguyên dữ liệu | Khớp toàn bộ các trường | **PASS** |
| 2 | **Lockscreen** | Xử lý trường `null` trong `LockscreenTaskSummary` | Bỏ qua các trường `null` an toàn, không văng lỗi | Xử lý an toàn, không lỗi | **PASS** |
| 3 | **Lockscreen** | Serialization & Deserialization `LockscreenPayload` | Đóng gói đủ currentTask, nextTask, count, date | Chuyển đổi JSON 2 chiều chính xác | **PASS** |
| 4 | **Lockscreen** | Xử lý Payload khi danh sách công việc trống | Các task là `null`, `hasActiveTasks = false` | Xử lý an toàn, không văng lỗi | **PASS** |
| 5 | **Lockscreen** | Logic so sánh bằng (`operator ==`) và HashCode | 2 payload giống nhau đánh giá `true`, khác nhau `false` | Khớp logic so sánh deduplication | **PASS** |
| 6 | **Lockscreen** | Chống trùng lặp (Deduplication) khi payload không đổi | Không gọi Native MethodChannel khi payload trùng | Bỏ qua cuộc gọi trùng thành công | **PASS** |
| 7 | **Lockscreen** | Kích hoạt cập nhật Native khi dữ liệu thay đổi | Gọi IPC khi có task mới hoặc thay đổi tiến độ | Kích hoạt update call chính xác | **PASS** |
| 8 | **Lockscreen** | Xử lý lỗi `PlatformException` từ Native an toàn | Bắt lỗi an toàn, trả về `false`, không crash app | Xử lý ngoại lệ an toàn | **PASS** |
| 9 | **Lockscreen** | Hủy Ongoing Notification và reset trạng thái | Xóa notification ID và đưa cache về `null` | Hủy và reset cache thành công | **PASS** |
| 10 | **Lockscreen** | Tự động ánh xạ `Current Task` và `Next Task` | Lấy đúng task đang làm và task kế tiếp sắp tới | Ánh xạ chính xác khung giờ | **PASS** |
| 11 | **Lockscreen** | Lọc bỏ công việc đã hoàn thành khỏi Current/Next | Task `isCompleted = true` không được chọn làm active | Lọc sạch các task đã xong | **PASS** |
| 12 | **Theme Settings** | Theme mặc định khi bộ nhớ rỗng | Trả về `ThemeMode.system` | `ThemeMode.system` | **PASS** |
| 13 | **Theme Settings** | Đổi sang Dark Mode và lưu storage | Lưu `'dark'` vào storage và cập nhật state | State Dark, Storage `'dark'` | **PASS** |
| 14 | **Theme Settings** | Đổi sang Light Mode và lưu storage | Lưu `'light'` vào storage và cập nhật state | State Light, Storage `'light'` | **PASS** |
| 15 | **Theme Settings** | Phục hồi Dark Mode đã lưu từ trước | Đọc `'dark'` từ storage lúc khởi tạo | Khởi tạo ngay ở Dark Mode | **PASS** |
| 16 | **Theme Settings** | Phục hồi Light Mode đã lưu từ trước | Đọc `'light'` từ storage lúc khởi tạo | Khởi tạo ngay ở Light Mode | **PASS** |
| 17 | **Theme Settings** | Chuỗi lưu trữ bị lỗi hoặc không hợp lệ | Fallback an toàn về `ThemeMode.system` | Fallback về System an toàn | **PASS** |
| 18 | **Theme Settings** | Toggle chuyển đổi giữa Dark và Light | Đổi qua lại nhịp nhàng và cập nhật storage | Toggle chuẩn xác | **PASS** |
| 19 | **Theme Settings** | Tích hợp Riverpod ProviderScope override | Cho phép tiêm Mock/Memory storage cho test | Override hoạt động chính xác | **PASS** |
| 20 | **Reminder** | Giá trị mặc định của Reminder | Mặc định tắt, offset = 0 | Mặc định tắt | **PASS** |
| 21 | **Reminder** | Offset `none` không lên lịch | Không gọi hàm schedule notification | Danh sách pending rỗng | **PASS** |
| 22 | **Reminder** | Offset `atTime` lên lịch đúng giờ | Lên lịch thông báo đúng bằng `startTime` | Thời gian trùng khớp | **PASS** |
| 23 | **Reminder** | Tính toán các mức offset định sẵn | Tính đúng số phút trừ lùi (5m, 10m, 15m, 30m, 1h, 1d) | Trừ lùi giờ chính xác | **PASS** |
| 24 | **Reminder** | Bật reminder nhưng thiếu `startTime` | Ném lỗi `ArgumentError` từ chối lưu | Bắt lỗi thành công | **PASS** |
| 25 | **Reminder** | Không lên lịch nhắc việc trong quá khứ | Bỏ qua các mốc thời gian đã trôi qua | Không tạo thông báo quá khứ | **PASS** |
| 26 | **Reminder** | Tạo task có reminder hợp lệ | Lên lịch thông báo với ID băm FNV-1a | Tạo thông báo thành công | **PASS** |
| 27 | **Reminder** | Thay đổi `startTime` cập nhật reminder | Dời thời điểm bắn thông báo theo giờ mới | Cập nhật giờ báo chính xác | **PASS** |
| 28 | **Reminder** | Thay đổi offset cập nhật reminder | Tính lại mốc giờ báo mới | Giờ báo được điều chỉnh đúng | **PASS** |
| 29 | **Reminder** | Tắt reminder hủy thông báo | Hủy notification tương ứng khỏi hệ điều hành | Xóa khỏi danh sách chờ | **PASS** |
| 30 | **Reminder** | Xóa task hủy thông báo | Hủy notification tương ứng khi task bị xóa | Xóa thông báo thành công | **PASS** |
| 31 | **Reminder** | Chu kỳ Hoàn thành -> Bỏ hoàn thành | Hoàn thành hủy thông báo, mở lại lên lịch lại | Chuyển đổi nhịp nhàng | **PASS** |
| 32 | **Reminder** | Độ ổn định của ID Hash FNV-1a | Cùng 1 taskId luôn ra cùng 1 ID nguyên dương duy nhất | Hash ổn định 100% | **PASS** |
| 33 | **Reminder** | Cấu trúc Payload của thông báo | Chứa JSON hợp lệ có `taskId` | Payload parse ra đúng taskId | **PASS** |
| 34 | **Reminder** | Xử lý sự kiện bấm vào thông báo | Điều hướng an toàn kể cả khi task đã bị xóa | Không crash, xử lý an toàn | **PASS** |
| 35 | **Reminder** | Idempotent Startup Reconciliation | Dọn sạch thông báo mồ côi khi khởi động app | Chạy 2 lần kết quả như nhau | **PASS** |
| 36 | **Reminder** | Khả năng chịu lỗi khi Notification fail | Lỗi notification không làm mất dữ liệu task trong CSDL | Task trong SQLite toàn vẹn | **PASS** |
| 37 | **Database** | Thêm task và đọc từ Reactive Stream | Thêm 1 dòng, Stream trả về danh sách 1 phần tử | Ghi thành công, stream cập nhật | **PASS** |
| 38 | **Database** | Cập nhật tiêu đề và trạng thái task | Tiêu đề và status mới được ghi đè vào SQLite | Đọc lại đúng tiêu đề mới | **PASS** |
| 39 | **Database** | Toggle hoàn thành duy trì tính toàn vẹn | Chuyển `isCompleted` qua lại giữa true/false | Trạng thái đồng bộ, không mất data | **PASS** |
| 40 | **Database** | Xóa task khỏi CSDL | Task bị xóa hoàn toàn khỏi bảng `tasks` | Danh sách trở về 0 phần tử | **PASS** |
| 41 | **Database** | Schema v2 lưu reminder fields | Lưu và đọc đúng `reminderEnabled`, `reminderMinutesBefore` | Lưu và đọc chính xác | **PASS** |
| 42 | **Database** | Migration CSDL từ v1 lên v2 | Nâng cấp schema giữ nguyên vẹn dữ liệu cũ từ v1 | 2 task v1 được bảo toàn | **PASS** |
| 43 | **Calendar** | `isSameDay` cùng ngày khác giờ | Trả về `true` khi so sánh cùng ngày | Trả về `true` | **PASS** |
| 44 | **Calendar** | `isSameDay` khác ngày | Trả về `false` khi so sánh khác ngày | Trả về `false` | **PASS** |
| 45 | **Calendar** | `isSameDay` với tham số `null` | Trả về `false` an toàn không văng Exception | Trả về `false` | **PASS** |
| 46 | **Calendar** | Sắp xếp công việc theo thời gian | Task có giờ bắt đầu xếp trước task không có giờ | Sắp xếp chính xác theo giờ | **PASS** |
| 47 | **Calendar** | Giới hạn dot indicators trên lịch | Tối đa 3 chấm tròn khi số task >= 3 | Capped ở 3 chấm chính xác | **PASS** |
| 48 | **Calendar** | Tạo task có `dueDate` trên lịch | Task xuất hiện trong danh sách ngày đó từ CSDL | Dữ liệu hiển thị đúng ngày | **PASS** |
| 49 | **Calendar** | Đổi ngày `dueDate` của công việc | Task chuyển sang ngày mới, ngày cũ biến mất | Đồng bộ ngày mới chính xác | **PASS** |
| 50 | **Calendar** | Toggle hoàn thành task từ lịch | Trạng thái `isCompleted` đổi trong CSDL SQLite | Dữ liệu cập nhật realtime | **PASS** |
| 51 | **Use Cases** | `CreateTask` từ chối tiêu đề rỗng | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 52 | **Use Cases** | `CreateTask` từ chối tiêu đề toàn khoảng trắng | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 53 | **Use Cases** | `CreateTask` từ chối `startTime > endTime` | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 54 | **Use Cases** | `CreateTask` thành công với dữ liệu chuẩn | Tạo thành công Task với UUID v4 | Task được tạo và lưu vào CSDL | **PASS** |
| 55 | **Use Cases** | `UpdateTask` kiểm tra validation tiêu đề | Cập nhật thành công tiêu đề và updatedAt | Đọc lại đúng tiêu đề mới | **PASS** |
| 56 | **Widget & Core**| Định dạng ngày tháng tiếng Việt | Trả về chuỗi ngày tiếng Việt chuẩn | "Thứ Bảy, 12 tháng 09, 2026" | **PASS** |
| 57 | **Widget & Core**| Tên hiển thị trạng thái và độ ưu tiên | Hiển thị "Đang làm", "Cao", "Khẩn cấp" | Tên tiếng Việt chuẩn xác | **PASS** |

---

## 2. PHÂN ĐỊNH TRẠNG THÁI NGHIỆM THU RÕ RÀNG
Theo yêu cầu bắt buộc của mục 11:
- **CODE VERIFIED:** Đã kiểm tra cấu trúc mã nguồn, kiểu dữ liệu, null-safety và logic của các file Kotlin và Dart mới. (ĐẠT)
- **UNIT TESTED:** Đã thực thi tự động qua `flutter test` với 57/57 tests PASS 100%. (ĐẠT)
- **BUILD VERIFIED:** Đã biên dịch thành công ứng dụng ra file APK cài đặt `build/app/outputs/flutter-apk/app-debug.apk`. (ĐẠT)
- **DEVICE VERIFIED:** **Chưa kiểm tra trên điện thoại Android vật lý** (Cần thiết bị thực tế để cấp quyền `POST_NOTIFICATIONS` và kiểm tra việc hiển thị trên màn hình khóa của từng dòng máy OEM).

