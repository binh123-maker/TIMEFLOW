# TIMEFLOW – PROJECT KNOWLEDGE BASE & TECHNICAL AUDIT

**Dự án:** TIMEFLOW – To-do List & Lockscreen Application  
**Thư mục gốc:** `D:\TODOLIST AND LOCKSCREEN`  
**Ngày phân tích:** 12/11/2026  
**Branch / Commit được phân tích:** `main` — HEAD `89cb1b6` (`docs: add Sprint 6.2 git release report`), Release Tag `v0.6.2` (`44126a0`)  
**Trạng thái Working Tree tại thời điểm kiểm kê:** Có một số thay đổi chưa commit ở tài liệu/ảnh minh chứng (`docs/PHASE_06_2_GIT_RELEASE_REPORT.md` modified, 5 file PNG trong `docs/` deleted, 2 file tạm untracked `emulator_screen.png`, `sprint_6_2_widget_error.txt`). Không ảnh hưởng đến mã nguồn `lib/`, `android/`, `test/`.

---

## MỤC LỤC TÀI LIỆU CHÍNH THỨC

Bộ tài liệu này được biên soạn dựa trên **kiểm tra trực tiếp mã nguồn thực tế** nhằm giúp bạn nắm vững toàn bộ kiến trúc, công nghệ, thuật toán, database, Android Native, kiểm thử, nợ kỹ thuật và lộ trình phát triển tiếp theo của **TIMEFLOW**.

| STT | Tài liệu | Nội dung chính | Đối tượng đọc phù hợp |
|:---:|---|---|---|
| 01 | [01_PROJECT_OVERVIEW.md](./01_PROJECT_OVERVIEW.md) | Tổng quan sản phẩm, bài toán, giá trị, nền tảng, góc nhìn 3 vai trò, sơ đồ thành phần | Tất cả mọi người, Hội đồng bảo vệ |
| 02 | [02_TECH_STACK.md](./02_TECH_STACK.md) | Kiểm kê toàn bộ ngôn ngữ, SDK, thư viện (`pubspec.yaml`, `pubspec.lock`, Gradle), phân tích ưu/nhược & phương án thay thế | Developer, Tech Lead |
| 03 | [03_SYSTEM_ARCHITECTURE.md](./03_SYSTEM_ARCHITECTURE.md) | Kiến trúc thực tế (Feature-first, Clean Architecture Light, Repository, Riverpod DI), 5 sơ đồ luồng dữ liệu Mermaid | Developer, Software Architect |
| 04 | [04_FEATURE_INVENTORY.md](./04_FEATURE_INVENTORY.md) | Kiểm kê chi tiết toàn bộ tính năng (Đã triển khai / Một phần / Thiết kế / Skeleton / Chưa kiểm chứng) | Product Owner, QA, Developer |
| 05 | [05_ALGORITHMS_AND_BUSINESS_LOGIC.md](./05_ALGORITHMS_AND_BUSINESS_LOGIC.md) | Phân tích sâu các thuật toán & logic nghiệp vụ (Current/Next Task, Overlapping tie-breaker, Dynamic Clock, FNV-1a, Reconciliation, Deduplication) | Developer, Hội đồng kỹ thuật |
| 06 | [06_DATABASE_DESIGN.md](./06_DATABASE_DESIGN.md) | Schema Drift SQLite (`timeflow.sqlite`), bảng `Tasks`, Migration v1→v2, CRUD flow, ERD, rủi ro tiềm ẩn | Backend/Mobile Developer |
| 07 | [07_ANDROID_NATIVE_AND_PERMISSIONS.md](./07_ANDROID_NATIVE_AND_PERMISSIONS.md) | `AndroidManifest.xml`, Ongoing Lockscreen Notification, AppWidgetProvider, BootReceiver, bảng quyền Android & thiết kế Permission Onboarding | Android Developer, Security/UX |
| 08 | [08_TESTING_AND_QUALITY.md](./08_TESTING_AND_QUALITY.md) | Kiểm kê 8 file test (87 test cases), đối chiếu báo cáo cũ, đánh giá coverage, khả năng bảo trì, tương thích & bảo mật | QA Engineer, Developer |
| 09 | [09_TECHNICAL_DEBT_AND_RISKS.md](./09_TECHNICAL_DEBT_AND_RISKS.md) | Đánh giá 15 tiêu chí theo mức độ `CRITICAL / HIGH / MEDIUM / LOW` kèm bằng chứng cụ thể trong source code | Senior Engineer, Tech Lead |
| 10 | [10_FEATURE_UPGRADE_PROPOSALS.md](./10_FEATURE_UPGRADE_PROPOSALS.md) | Đề xuất nâng cấp nhóm A–G, phân tích giá trị/độ khó/phụ thuộc/chi phí, phân biệt Offline vs Cloud/AI | Product Manager, Developer |
| 11 | [11_DEVELOPMENT_ROADMAP.md](./11_DEVELOPMENT_ROADMAP.md) | Lộ trình phát triển từ Sprint 7 trở đi, tiêu chí nghiệm thu, phân biệt MVP vs Advanced Features | Project Manager, Developer |
| 12 | [12_LEARNING_GUIDE.md](./12_LEARNING_GUIDE.md) | Giải thích 19 khái niệm nền tảng từ cơ bản, thứ tự đọc code, 30+ câu hỏi tự kiểm tra (có đáp án), 10 bài tập thực hành | Sinh viên, Người mới tiếp cận |
| 13 | [13_INTERVIEW_AND_DEFENSE_QUESTIONS.md](./13_INTERVIEW_AND_DEFENSE_QUESTIONS.md) | Bộ câu hỏi phỏng vấn & bảo vệ đồ án chuyên sâu về chính TIMEFLOW kèm gợi ý trả lời chuẩn kỹ thuật | Sinh viên bảo vệ đồ án / Phỏng vấn |

---

## HƯỚNG DẪN ĐỌC NHANH THEO MỤC TIÊU

- **Nếu bạn muốn hiểu nhanh dự án để tự học từ đầu:** Đọc theo thứ tự `01` → `12` → `03` → `05` → `06`.
- **Nếu bạn chuẩn bị bảo vệ đồ án / phỏng vấn:** Tập trung `01`, `03`, `05`, `07`, `09`, `13`.
- **Nếu bạn chuẩn bị code Sprint tiếp theo:** Tập trung `04`, `08`, `09`, `10`, `11`.

---

## QUY ƯỚC TRẠNG THÁI SỬ DỤNG TRONG BỘ TÀI LIỆU

Để tránh nhầm lẫn giữa thiết kế trên giấy và code chạy thực tế, mọi chức năng đều được gắn nhãn rõ ràng:

- **Đã triển khai (Implemented):** Đã có code hoàn chỉnh, kết nối với UI/DB/Native.
- **Đã triển khai một phần (Partially Implemented):** Có khung giao diện hoặc một phần logic nhưng chưa hoàn thiện luồng end-to-end.
- **Mới có thiết kế / Stub (Designed / Stub Only):** Có tài liệu thiết kế (như `docs/LOCKSCREEN_TECHNICAL_DESIGN.md`) hoặc class/màn hình placeholder (`lib/services/*`, `FocusScreen`, `StatisticsScreen`,...).
- **Chưa triển khai (Not Implemented):** Chưa có code.
- **Đã triển khai nhưng chưa kiểm chứng thực tế (Implemented - Unverified at Runtime):** Code đã viết và build thành công nhưng chưa kiểm chứng trên thiết bị thật hoặc chưa test tình huống thực tế (ví dụ: cold reboot cho `ScheduledNotificationBootReceiver`).

