# PHẦN 8 – PHÂN TÍCH TEST VÀ CHẤT LƯỢNG

**Ngày phân tích:** 12/11/2026  
**Nguồn kiểm chứng:** Kiểm kê trực tiếp 9 file trong thư mục `test/` và đối chiếu với `docs/PHASE_06_2_GIT_RELEASE_REPORT.md` (commit `44126a0`) và `docs/PHASE_06_2_FUNCTIONAL_TEST_REPORT.md`.  
**Lưu ý về môi trường kiểm kê:** Trong phiên kiểm kê hiện tại (12/11/2026), lệnh `flutter test` và `dart analyze` bị treo khi chạy trong terminal sandbox do SDK đặt tại `C:\flutter\flutter` (ngoài phạm vi workspace). Vì vậy, số liệu chạy PASS/FAIL dưới đây được trích dẫn từ báo cáo release `PHASE_06_2_GIT_RELEASE_REPORT.md` (commit `44126a0`), còn số lượng test case từng file được đếm trực tiếp từ mã nguồn `test/*.dart` hiện tại.

---

## 8.1. Bảng kiểm kê Test Suite thực tế

| File Test / Module | Loại Test | Số test trong code | PASS (theo báo cáo `v0.6.2`) | FAIL | NOT TESTED / Thiếu gì |
|---|---|---:|---:|---:|---|
| `test/database_test.dart` | Integration (In-memory SQLite) | **6** | 6 | 0 | Thiếu test truy vấn hiệu năng với lượng lớn dữ liệu (>1000 tasks) |
| `test/calendar_test.dart` | Unit + Integration (SQLite) | **8** | 8 | 0 | Thiếu WidgetTester cho `CalendarMonthView` & tap chọn ngày trên UI |
| `test/usecases_test.dart` | Unit Test (Validation) | **5** | 5 | 0 | Thiếu test cho `DeleteTask`, `ToggleTaskCompletion`, `GetTasks` |
| `test/reminder_test.dart` | Unit Test (với `FakeLocalNotificationService`) | **18** | 18 | 0 | Chưa test `FlutterLocalNotificationService` thật với plugin mock |
| `test/lockscreen_test.dart` | Unit + Provider Test (với `FakeLockscreenBridge`) | **11** | 11 | 0 | Chưa test Kotlin `LockscreenNotificationManager` (Android Native Unit Test) |
| `test/home_widget_test.dart` | Unit + Provider + Edge Case Test | **29** | 29 | 0 | Chưa test Kotlin `TimeflowWidgetCompactProvider` & `ExpandedProvider` |
| `test/theme_settings_test.dart` | Unit Test (`MemoryLocalStorage`) | **8** | 8 | 0 | Chưa test `SharedPrefsLocalStorage` và Widget `SettingsScreen` |
| `test/widget_test.dart` | Core Unit Test (`DateFormatter`, `TaskEntity`) | **2** | 2 | 0 | Tên là `widget_test.dart` nhưng không có `testWidgets()` nào! |
| **UI Screens (`WidgetTester`)** | Widget / UI Test | **0** | 0 | 0 | **Chưa có** test UI cho `HomeScreen`, `TasksScreen`, `TaskFormDialog`, `CalendarScreen`, `RemindersScreen`, `SettingsScreen` |
| **Integration Test (E2E trên thiết bị)** | `integration_test/` | **0** | — | — | Chưa có thư mục `integration_test/` (chỉ test thủ công trên Emulator API 36.1 với 18/19 PASS, 1 BLOCKED) |
| **Android Native Test (JUnit/Robolectric)** | Gradle `gradlew test` | **0** | — | — | **BLOCKED** trên Windows đa ổ đĩa (`D:\` vs `C:\...Pub\Cache`) theo báo cáo `v0.6.2` |
| **Tổng cộng Automated Dart Tests** | | **87** | **87** | **0** | *Lưu ý: Báo cáo cũ `PHASE_06_2_GIT_RELEASE_REPORT.md` ghi nhầm phân bổ (14 DB, 5 Core, thiếu dòng Lockscreen 11) nhưng tổng 87/87 khớp hoàn toàn.* |

---

## 8.2. Đánh giá chất lượng kỹ thuật tổng quan

1. **Code Coverage (Chưa đo lường bằng `lcov`):** Chưa có báo cáo `flutter test --coverage` trong repo. Theo ước lượng cấu trúc code, tầng Domain/Providers/Database có độ phủ test rất tốt, trong khi tầng Presentation UI (`lib/features/*/presentation/*.dart`) có độ phủ bằng **0%**.
2. **Khả năng bảo trì (Maintainability):** Tốt nhờ phân tách interface (`ITaskRepository`, `ILocalNotificationService`, `ILockscreenBridge`, `IHomeWidgetService`, `LocalStorage`) giúp dễ thay thế implementation và viết test double (`FakeLocalNotificationService`, `FakeLockscreenBridge`, `FakeHomeWidgetService`).
3. **Khả năng mở rộng (Scalability):** Kiến trúc Feature-first + Riverpod cho phép thêm tính năng mới (như Statistics, Focus) mà không sửa code cốt lõi của Tasks. Tuy nhiên, việc `watchAllTasks()` tải toàn bộ bảng về RAM sẽ trở thành điểm nghẽn nếu người dùng tích lũy dữ liệu nhiều năm.
4. **Khả năng tương thích Android:** Tốt ở mức API hiện đại (`compileSdk`/`targetSdk` theo Flutter, `FLAG_IMMUTABLE`, `POST_NOTIFICATIONS` check). Cần kiểm thử thêm trên thiết bị thật các hãng OEM (Xiaomi, Oppo, Samsung) về chế độ tiết kiệm pin và Lockscreen privacy.
5. **Khả năng tương thích Windows:** Có `NavigationRail` responsive và platform guard (`defaultTargetPlatform != TargetPlatform.android`) trong `HomeWidgetServiceImpl` và `MethodChannelLockscreenBridge`. Tuy nhiên, chưa có bằng chứng build/chạy thực tế bản Windows gần đây.
6. **Hiệu năng (Performance):** Rất tốt nhờ Deduplication Cache ở Bridge/Widget và `homeWidgetClockProvider` ngủ theo mốc chuyển tiếp thay vì polling mỗi giây.
7. **Bảo mật dữ liệu cục bộ (Local Data Security):** Dữ liệu lưu dạng SQLite thuần (`timeflow.sqlite`) và `SharedPreferences` không mã hóa. Với app To-do List cá nhân offline, mức này là tiêu chuẩn; nếu sau này lưu dữ liệu nhạy cảm hoặc token đăng nhập, cần dùng `flutter_secure_storage` / SQLCipher.

