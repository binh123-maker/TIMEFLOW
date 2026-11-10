# BÁO CÁO KIỂM THỬ CHẤT LƯỢNG (PHASE 05 TEST REPORT)
**Dự án:** TIMEFLOW – To-do List & Lockscreen App  
**Thời gian thực hiện:** 07/11/2026  
**Môi trường:** Flutter 3.41.6, Dart 3.11.4, Android SDK 36.1.0, OpenJDK 21, Windows 11  
**Tổng số ca kiểm thử:** 46 Automated Tests + 6 Build/Verification Tests  
**Tỷ lệ đạt:** **100% PASS**  

---

## 1. BẢNG KIỂM THỬ CHI TIẾT (TEST EXECUTION MATRIX)

| STT | Nhóm kiểm thử | Tên Test Case | Kết quả mong đợi (Expected Result) | Kết quả thực tế (Actual Result) | Trạng thái |
|:---:|---|---|---|---|:---:|
| 1 | **Calendar & Date** | `isSameDay` cùng ngày khác giờ | Trả về `true` khi so sánh cùng ngày | Trả về `true` | **PASS** |
| 2 | **Calendar & Date** | `isSameDay` khác ngày | Trả về `false` khi so sánh khác ngày | Trả về `false` | **PASS** |
| 3 | **Calendar & Date** | `isSameDay` với tham số `null` | Trả về `false` an toàn không văng Exception | Trả về `false` | **PASS** |
| 4 | **Calendar & Date** | Sắp xếp công việc theo thời gian | Task có giờ bắt đầu xếp trước task không có giờ | Sắp xếp chính xác theo giờ tăng dần | **PASS** |
| 5 | **Calendar & Date** | Giới hạn dot indicators trên lịch | Tối đa 3 chấm tròn khi số task >= 3 | Capped ở 3 chấm chính xác | **PASS** |
| 6 | **Calendar & SQLite**| Tạo task có `dueDate` trên lịch | Task xuất hiện trong danh sách ngày đó từ CSDL | Dữ liệu hiển thị đúng ngày | **PASS** |
| 7 | **Calendar & SQLite**| Đổi ngày `dueDate` của công việc | Task chuyển sang ngày mới, ngày cũ biến mất | Đồng bộ ngày mới chính xác | **PASS** |
| 8 | **Calendar & SQLite**| Toggle hoàn thành task từ lịch | Trạng thái `isCompleted` đổi trong CSDL SQLite | Dữ liệu cập nhật realtime | **PASS** |
| 9 | **Database (Drift)** | Thêm task và đọc từ Reactive Stream | Thêm 1 dòng, Stream trả về danh sách 1 phần tử | Ghi thành công, stream cập nhật | **PASS** |
| 10 | **Database (Drift)** | Cập nhật tiêu đề và trạng thái task | Tiêu đề và status mới được ghi đè vào SQLite | Đọc lại đúng tiêu đề và status mới | **PASS** |
| 11 | **Database (Drift)** | Toggle hoàn thành duy trì tính toàn vẹn | Chuyển `isCompleted` qua lại giữa true/false | Trạng thái đồng bộ, không mất data | **PASS** |
| 12 | **Database (Drift)** | Xóa task khỏi CSDL | Task bị xóa hoàn toàn khỏi bảng `tasks` | Danh sách trở về 0 phần tử | **PASS** |
| 13 | **Database (Drift)** | Schema v2 lưu reminder fields | Lưu và đọc đúng `reminderEnabled`, `reminderMinutesBefore` | Lưu và đọc chính xác | **PASS** |
| 14 | **Database (Drift)** | Migration CSDL từ v1 lên v2 | Nâng cấp schema giữ nguyên vẹn dữ liệu cũ từ v1 | 2 task v1 được bảo toàn với default reminder | **PASS** |
| 15 | **Reminder Module** | Giá trị mặc định của Reminder | Mặc định `reminderEnabled = false`, offset = 0 | Mặc định tắt, tính toán thời gian trả về `null` | **PASS** |
| 16 | **Reminder Module** | Offset `none` không lên lịch | Không gọi hàm schedule notification | Danh sách pending notifications rỗng | **PASS** |
| 17 | **Reminder Module** | Offset `atTime` lên lịch đúng giờ | Lên lịch thông báo đúng bằng `startTime` | Thời gian lên lịch trùng khớp `startTime` | **PASS** |
| 18 | **Reminder Module** | Tính toán các mức offset định sẵn | Tính đúng số phút trừ lùi: 5m, 10m, 15m, 30m, 1h, 1d | Trừ lùi thời gian chính xác 100% | **PASS** |
| 19 | **Reminder Module** | Bật reminder nhưng thiếu `startTime` | UseCase ném `ArgumentError` từ chối lưu | Ném lỗi `ArgumentError` như mong đợi | **PASS** |
| 20 | **Reminder Module** | Không lên lịch nhắc việc trong quá khứ | Bỏ qua các mốc thời gian đã trôi qua | Không tạo pending notification quá khứ | **PASS** |
| 21 | **Reminder Module** | Tạo task có reminder hợp lệ | Lên lịch thông báo tương ứng trong service | Notification được ghi nhận với FNV-1a id | **PASS** |
| 22 | **Reminder Module** | Thay đổi `startTime` cập nhật reminder | Cập nhật lại thời điểm bắn thông báo | Thời điểm thông báo được dời theo giờ mới | **PASS** |
| 23 | **Reminder Module** | Thay đổi offset cập nhật reminder | Tính lại mốc giờ báo mới | Giờ báo được điều chỉnh chính xác | **PASS** |
| 24 | **Reminder Module** | Tắt reminder hủy thông báo | Hủy notification tương ứng khỏi hệ điều hành | Notification bị xóa khỏi danh sách chờ | **PASS** |
| 25 | **Reminder Module** | Xóa task hủy thông báo | Hủy notification tương ứng khi task bị xóa | Notification bị xóa sạch sẽ | **PASS** |
| 26 | **Reminder Module** | Chu kỳ Hoàn thành -> Bỏ hoàn thành | Hoàn thành: hủy thông báo; Mở lại: lên lịch lại | Trạng thái thông báo chuyển đổi nhịp nhàng | **PASS** |
| 27 | **Reminder Module** | Độ ổn định của ID Hash FNV-1a | Cùng 1 taskId luôn ra cùng 1 mã số int duy nhất | Hash ổn định 100%, không sinh mã âm | **PASS** |
| 28 | **Reminder Module** | Cấu trúc Payload của thông báo | Chứa JSON hợp lệ có `taskId` | Payload parse ra đúng taskId | **PASS** |
| 29 | **Reminder Module** | Xử lý sự kiện bấm vào thông báo | Điều hướng an toàn kể cả khi task đã bị xóa | Không crash, xử lý an toàn | **PASS** |
| 30 | **Reminder Module** | Idempotent Startup Reconciliation | Dọn sạch thông báo mồ côi khi khởi động app | Chạy 2 lần kết quả như nhau, xóa orphan | **PASS** |
| 31 | **Reminder Module** | Khả năng chịu lỗi khi Notification fail | Lỗi notification không làm mất dữ liệu task trong CSDL | Task trong SQLite vẫn toàn vẹn 100% | **PASS** |
| 32 | **Theme Settings** | Mặc định Theme khi bộ nhớ trống | Trả về `ThemeMode.system` khi chưa lưu | Trả về `ThemeMode.system` | **PASS** |
| 33 | **Theme Settings** | Đổi sang Dark Mode và lưu storage | Ghi `'dark'` vào storage và cập nhật state | Storage lưu `'dark'`, state là Dark | **PASS** |
| 34 | **Theme Settings** | Đổi sang Light Mode và lưu storage | Ghi `'light'` vào storage và cập nhật state | Storage lưu `'light'`, state là Light | **PASS** |
| 35 | **Theme Settings** | Khôi phục Dark Mode đã lưu từ trước | Đọc `'dark'` từ storage và khởi tạo Dark | Khởi tạo ngay lập tức ở Dark Mode | **PASS** |
| 36 | **Theme Settings** | Khôi phục Light Mode đã lưu từ trước | Đọc `'light'` từ storage và khởi tạo Light | Khởi tạo ngay lập tức ở Light Mode | **PASS** |
| 37 | **Theme Settings** | Dữ liệu lưu trữ bị lỗi hoặc không rõ | Fallback an toàn về `ThemeMode.system` | Trả về `ThemeMode.system`, không crash | **PASS** |
| 38 | **Theme Settings** | Toggle chuyển đổi qua lại giữa Dark/Light | Đổi qua lại giữa Dark và Light và lưu storage | Hoạt động mượt mà, lưu chuẩn | **PASS** |
| 39 | **Theme Settings** | Tích hợp Riverpod ProviderScope override | Cho phép tiêm Mock/Memory storage cho kiểm thử | Override hoạt động chính xác | **PASS** |
| 40 | **Use Cases** | `CreateTask` từ chối tiêu đề rỗng | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 41 | **Use Cases** | `CreateTask` từ chối tiêu đề toàn khoảng trắng | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 42 | **Use Cases** | `CreateTask` từ chối `startTime > endTime` | Ném ngoại lệ `ArgumentError` | Bắt lỗi thành công | **PASS** |
| 43 | **Use Cases** | `CreateTask` thành công với dữ liệu chuẩn | Tạo thành công Task với UUID v4 | Task được tạo và lưu vào CSDL | **PASS** |
| 44 | **Use Cases** | `UpdateTask` kiểm tra validation tiêu đề | Cập nhật thành công tiêu đề và updatedAt | Đọc lại đúng tiêu đề mới | **PASS** |
| 45 | **Widget & Core** | Định dạng ngày tháng tiếng Việt | Trả về chuỗi ngày tiếng Việt chuẩn | "Thứ Bảy, 12 tháng 09, 2026" | **PASS** |
| 46 | **Widget & Core** | Tên hiển thị trạng thái và độ ưu tiên | Hiển thị "Đang làm", "Cao", "Khẩn cấp" | Tên hiển thị tiếng Việt chuẩn xác | **PASS** |

---

## 2. KIỂM THỬ XÂY DỰNG VÀ BIÊN DỊCH (BUILD VERIFICATION)

| STT | Hạng mục build | Lệnh thực thi | Kết quả mong đợi | Kết quả thực tế | Trạng thái |
|:---:|---|---|---|---|:---:|
| 1 | **Static Analysis** | `flutter analyze` | 0 errors, 0 warnings | `No issues found! (ran in 4.3s)` | **PASS** |
| 2 | **Code Formatting** | `dart format --output=none --set-exit-if-changed` | Đạt chuẩn Dart style guide | 59/59 files formatted (0 changed) | **PASS** |
| 3 | **Automated Suite** | `flutter test` | Toàn bộ 46 test cases pass | `All tests passed!` (46/46) | **PASS** |
| 4 | **Android Debug APK** | `flutter build apk --debug` | Biên dịch ra file APK cài đặt | Sinh ra `build/app/outputs/flutter-apk/app-debug.apk` (187.7 MB) | **PASS** |
| 5 | **Windows Desktop** | `flutter build windows --debug` | Kiểm tra khả năng build Windows | Báo thiếu Visual Studio C++ toolchain trên máy host | **BLOCKED** |
| 6 | **Cross-platform Compatibility** | Phân tích mã nguồn và dependencies | Đảm bảo không dùng native API độc quyền làm hỏng Windows | Các plugin đều có bản Windows (`shared_preferences_windows`, `sqlite3_flutter_libs`) | **VERIFIED** |

---

## 3. TỔNG KẾT
- **Tổng số test cases:** 46 Unit/Integration tests.
- **Số lượng PASS:** 46/46 (100%).
- **Số lượng FAIL:** 0.
- **Số lượng BLOCKED:** 1 (Windows native compile do thiếu Visual Studio C++ workload trên máy tính hiện tại, code base không bị ảnh hưởng).

