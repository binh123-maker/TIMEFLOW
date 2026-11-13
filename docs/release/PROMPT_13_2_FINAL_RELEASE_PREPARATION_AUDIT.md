# TIMEFLOW – BÁO CÁO KIỂM TOÁN PHÁT HÀNH CUỐI CÙNG
## Final Release Preparation Audit & Pre-Sprint 7 Readiness
### Phiên bản: Release Candidate 0.6.2+2 (Prompt 13.2)

---

- **Dự án:** TIMEFLOW – To-do List & Lockscreen Application
- **Thư mục gốc:** `D:\TODOLIST AND LOCKSCREEN`
- **Application ID:** `com.timeflow.timeflow`
- **Phiên bản chuẩn:** `0.6.2+2` (`versionName`: `0.6.2`, `versionCode`: `2`)
- **Giấy phép phần mềm:** GNU General Public License v3.0 (GNU GPLv3)
- **Kiến trúc:** Flutter Feature-first + Light Clean Architecture + Drift SQLite
- **Ngày thực hiện kiểm toán:** 13/11/2026
- **Chế độ kiểm toán:** **AUDIT ONLY (Read-Only Forensic Audit)**
- **Kỹ sư thực hiện:** Senior Flutter / Android & Open-Source Release Engineer

---

## 1. EXECUTIVE SUMMARY (TỔNG QUAN KIỂM TOÁN)

Cuộc kiểm toán cuối cùng **Prompt 13.2** được thực hiện nhằm rà soát pháp y toàn diện (forensic audit) kho mã nguồn, working tree, lịch sử Git, tính toàn vẹn bảo mật, cấu trúc tài liệu và trạng thái sẵn sàng phát hành của dự án TIMEFLOW trước khi chủ dự án thực hiện commit chính thức đưa lên GitHub và mở Sprint 7.

### Kết quả đánh giá chung:

1. **Working Tree & Git Forensic:**
   - Git branch: `main` (đồng bộ với `origin/main` tại commit `89cb1b6`).
   - Git Tag lịch sử: duy nhất `v0.6.2` (trỏ tại commit `44126a0`).
   - Trạng thái staging: **0 file staged** (`git diff --cached` hoàn toàn sạch).
   - Không có bất kỳ lệnh Git nào làm thay đổi lịch sử commit hoặc xóa mất dữ liệu.
2. **Bảo mật & Bí mật (Secrets Audit):**
   - **Xác nhận 100% An toàn:** Không có bất kỳ file keystore (`*.jks`, `*.keystore`), file chứa mật khẩu (`key.properties`), token API hay biến môi trường (`.env`) nào từng bị commit vào lịch sử Git hay đang trôi nổi trong kho mã nguồn.
   - Các quy tắc ignore trong `.gitignore` và `android/.gitignore` hoạt động chuẩn xác và bảo vệ tuyệt đối.
3. **Phân định file phát hành:**
   - Lập danh mục kiểm kê chi tiết toàn bộ file: phân tách rõ ràng giữa **Mã nguồn bắt buộc (Group A)**, **Tài liệu dự án (Group B)**, **Tài sản phát hành (Group C)**, **File tạm cục bộ cần loại trừ (Group D)** và **Build outputs/Cache (Group E)**.
   - 2 file tạm cục bộ (`emulator_screen.png` dung lượng 0 byte và `sprint_6_2_widget_error.txt` dung lượng 99 KB) được xếp loại dứt khoát vào nhóm **EXCLUDE FROM GIT**.
4. **Trạng thái sẵn sàng theo kênh phát hành:**
   - **GitHub Source:** **READY FOR NEXT PHASE** (Sẵn sàng 100% để commit và push public).
   - **F-Droid Repository:** **READY FOR NEXT PHASE** (Đáp ứng đầy đủ tiêu chí build độc lập ngoại tuyến, font offline, không tracker, release APK unsigned không fallback debug key).
   - **GitHub Signed Release APK:** **CONDITIONALLY READY** (Hiện tại chưa có `key.properties` và keystore cá nhân của nhà phát triển trên máy; bản APK release hiện tại là unsigned chuẩn F-Droid).
5. **Sẵn sàng cho Sprint 7:**
   - Đã xác định rõ điểm khác biệt logic giữa `task_providers.dart` và `home_widget_providers.dart`. Toàn bộ 87 tests hiện tại pass 100%; kế hoạch refactor thành `TaskTimeDomainService` và cải tiến Permission Onboarding đã được vạch rõ ràng cho Sprint 7.

---

## 2. PREVIOUS REPORTS VERIFICATION (ĐỐI CHIẾU CÁC BÁO CÁO CŨ)

Đã đối chiếu trực tiếp mã nguồn với 3 báo cáo kiểm tra tiền nhiệm:

| Báo cáo | Tình trạng file | Kết quả xác minh thực tế | Ghi chú đối chiếu |
|---|:---:|---|---|
| `docs/release/PROMPT_12_FDROID_OPEN_SOURCE_AUDIT.md` | **TỒN TẠI** | Xác nhận đúng các cảnh báo cũ: font online, dead code `dio_client.dart`, thiếu GPLv3. | Toàn bộ các tồn đọng đã được khắc phục triệt để trong Prompt 13 & 13.1. |
| `docs/release/PROMPT_13_FDROID_REMEDIATION_REPORT.md` | **TỒN TẠI** | Xác nhận đã hoàn tất: tạo `LICENSE` GPLv3, nhúng Inter OFL fonts, xóa `dio`, tối ưu `android/gradle.properties`. | Các file mới tạo nằm trong working tree, chưa staged. |
| `docs/release/PROMPT_13_1_PRE_RELEASE_VERIFICATION_REPORT.md` | **TỒN TẠI** | Xác nhận: cập nhật phiên bản `0.6.2+2` trong `pubspec.yaml`, `settings_screen.dart`, `fastlane`, test 87/87 pass, apksigner verified. | Khớp 100% với trạng thái tệp tin và bản build APK hiện thời. |

---

## 3. GIT REPOSITORY FORENSIC AUDIT (PHÁP Y KHO MÃ NGUỒN GIT)

### 3.1. Thông tin cấu hình Git
- **Current Branch:** `main` (lệnh kiểm tra: `git branch --show-current`).
- **HEAD Commit:** `89cb1b6` (`docs: add Sprint 6.2 git release report`).
- **Remote Origin URL:** `https://github.com/binh123-maker/TIMEFLOW.git` (lệnh kiểm tra: `git remote -v`).
- **Danh sách Tag hiện có:** `v0.6.2` (trỏ trực tiếp vào commit `44126a0`).
- **Trạng thái đồng bộ:** Working tree sạch ở vùng staging (`no changes added to commit`).

### 3.2. Lịch sử Commit gần nhất (`git log -10 --oneline --decorate`)
```text
89cb1b6 (HEAD -> main, origin/main, origin/HEAD) docs: add Sprint 6.2 git release report
44126a0 (tag: v0.6.2) feat(android): complete Sprint 6.2 widgets and native fixes
591a3f8 Calendar & Task Scheduling
70411eb Local Database + Task CRUD
069d672 Initial commit
```

### 3.3. Chi tiết biến động file trong Working Tree

#### A. File đã theo dõi bị thay đổi (Modified - Unstaged): 9 files
1. `.gitignore`: Bổ sung quy tắc bảo vệ `.env`, `key.properties`, `*.jks`, `*.keystore`, `*.pem`, `*.key`.
2. `README.md`: Cập nhật huy hiệu GPLv3, tài liệu hướng dẫn build ngoại tuyến, giải thích quyền.
3. `android/app/build.gradle.kts`: Cấu hình signing release an toàn (unsigned khi không có `key.properties`).
4. `android/gradle.properties`: Thiết lập heap JVM `-Xmx2048m -XX:MaxMetaspaceSize=1024m` và `kotlin.incremental=false`.
5. `docs/PHASE_06_2_GIT_RELEASE_REPORT.md`: Báo cáo phát hành lịch sử của Sprint 6.2.
6. `lib/core/theme/app_theme.dart`: Chuyển sang font Inter nhúng cục bộ, gỡ bỏ `google_fonts`.
7. `lib/features/settings/presentation/settings_screen.dart`: Cập nhật hiển thị UI thành `Phiên bản 0.6.2 (Sprint 6.2)`.
8. `pubspec.yaml`: Cập nhật `version: 0.6.2+2`, gỡ bỏ `dio` và `google_fonts`, khai báo font Inter.
9. `pubspec.lock`: Đồng bộ cây phụ thuộc theo `pubspec.yaml`.

#### B. File đã theo dõi bị xóa (Deleted - Unstaged): 6 files
1. `lib/core/network/dio_client.dart`: Dead code (stub network client), xóa để đạt chuẩn 100% offline F-Droid.
2. `docs/after_tap_widget.png`: File ảnh chụp màn hình minh chứng Sprint 6.2.
3. `docs/both_widgets.png`: File ảnh chụp màn hình minh chứng Sprint 6.2.
4. `docs/expanded_after_task_ended.png`: File ảnh chụp màn hình minh chứng Sprint 6.2.
5. `docs/home_empty.png`: File ảnh chụp màn hình minh chứng Sprint 6.2.
6. `docs/reopened_home.png`: File ảnh chụp màn hình minh chứng Sprint 6.2.

#### C. File mới chưa theo dõi (Untracked): 12 mục
1. `CHANGELOG.md`: Lịch sử thay đổi chuẩn Keep a Changelog.
2. `CONTRIBUTING.md`: Hướng dẫn đóng góp cộng đồng mã nguồn mở.
3. `LICENSE`: Văn bản giấy phép GNU General Public License v3.0 chính thức.
4. `PRIVACY_POLICY.md`: Chính sách quyền riêng tư Local-First / Zero-Network.
5. `README_VI.md`: Bản dịch tiếng Việt đầy đủ của README.
6. `SECURITY.md`: Chính sách báo cáo lỗ hổng bảo mật có trách nhiệm.
7. `android/key.properties.example`: File mẫu hướng dẫn cấu hình ký APK.
8. `assets/`: Thư mục font Inter TTF và `LICENSE_OFL.txt`.
9. `docs/project_knowledge/`: 14 tài liệu kiến trúc, database, roadmap của dự án.
10. `docs/release/`: Các báo cáo kiểm toán Prompt 12, 13, 13.1 và 13.2.
11. `fastlane/`: Metadata F-Droid tiếng Anh và changelogs.
12. `emulator_screen.png` & `sprint_6_2_widget_error.txt`: File tạm phát sinh trong quá trình debug cục bộ.

---

## 4. RELEASE FILE INVENTORY (KIỂM KÊ TOÀN DIỆN DANH MỤC FILE)

Toàn bộ tập tin trong workspace được phân loại chính xác thành 5 nhóm:

### GROUP A – REQUIRED SOURCE FILES (Bắt buộc để biên dịch ứng dụng)
- `lib/` (32 tệp Dart: Core, Data, Domain, Presentation, Routers, Entities, Providers).
- `android/` (Toàn bộ source Kotlin, Manifests debug/profile/main, layout XML, drawables, gradle build scripts, trừ file tạm).
- `test/` (9 tệp kiểm thử tự động đảm bảo chất lượng).
- `assets/fonts/Inter-*.ttf` (4 tệp font Inter: Regular, Medium, SemiBold, Bold) và `assets/fonts/LICENSE_OFL.txt`.
- `pubspec.yaml` & `pubspec.lock`.
- `analysis_options.yaml`.
- `.gitignore` & `android/.gitignore`.
- `android/key.properties.example`.

### GROUP B – PROJECT DOCUMENTATION (Tài liệu dự án & Tri thức phát triển)
- `README.md` & `README_VI.md`.
- `LICENSE` (GNU GPLv3).
- `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `PRIVACY_POLICY.md`.
- `docs/project_knowledge/`:
  - `01_PROJECT_OVERVIEW.md`
  - `02_TECH_STACK.md`
  - `03_SYSTEM_ARCHITECTURE.md`
  - `04_FEATURE_INVENTORY.md`
  - `05_ALGORITHMS_AND_BUSINESS_LOGIC.md`
  - `06_DATABASE_DESIGN.md`
  - `07_ANDROID_NATIVE_AND_PERMISSIONS.md`
  - `08_TESTING_AND_QUALITY.md`
  - `09_TECHNICAL_DEBT_AND_RISKS.md`
  - `10_FEATURE_UPGRADE_PROPOSALS.md`
  - `11_DEVELOPMENT_ROADMAP.md`
  - `12_LEARNING_GUIDE.md`
  - `13_INTERVIEW_AND_DEFENSE_QUESTIONS.md`
  - `README.md`
- `docs/release/`:
  - `PROMPT_12_FDROID_OPEN_SOURCE_AUDIT.md`
  - `PROMPT_13_FDROID_REMEDIATION_REPORT.md`
  - `PROMPT_13_1_PRE_RELEASE_VERIFICATION_REPORT.md`
  - `PROMPT_13_2_FINAL_RELEASE_PREPARATION_AUDIT.md`
- `docs/PHASE_06_2_*.md` (Các báo cáo lịch sử Sprint 6.2).

### GROUP C – RELEASE ASSETS & METADATA (Dành cho kho ứng dụng F-Droid)
- `fastlane/metadata/android/en-US/title.txt` (`TIMEFLOW`).
- `fastlane/metadata/android/en-US/short_description.txt`.
- `fastlane/metadata/android/en-US/full_description.txt`.
- `fastlane/metadata/android/en-US/changelogs/1.txt`.
- `fastlane/metadata/android/en-US/changelogs/2.txt`.
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (App Icons đa độ phân giải).

### GROUP D – LOCAL TEMPORARY FILES (File tạm cục bộ – Cấm đưa lên Git)
- `emulator_screen.png`: Dung lượng 0 byte, tạo lúc 09/11/2026. File rỗng không có giá trị.
- `sprint_6_2_widget_error.txt`: Dung lượng 99.698 bytes, tạo lúc 08/11/2026. Là file logcat Android tạm thời khi debug widget.

### GROUP E – BUILD OUTPUTS & CACHES (Sản phẩm biên dịch – Bị Git Ignore)
- `build/`: Thư mục build của Flutter và Gradle (bao gồm `build/app/outputs/flutter-apk/app-release.apk` và `app-debug.apk`).
- `.dart_tool/`: Cache của Dart analysis và build runner.
- `.idea/`: Thư mục cấu hình Android Studio cục bộ.
- `windows/flutter/ephemeral/`: Cache của Windows Flutter engine.

---

## 5. DELETED FILES AUDIT (AUDIT CÁC FILE ĐÃ BỊ XÓA)

Bảng đối chiếu pháp y cho 6 file ở trạng thái Deleted trong working tree:

| File path | Tồn tại trong Git HEAD | Tồn tại trên ổ đĩa | Được tham chiếu trong tài liệu | Đánh giá & Đề xuất |
|---|:---:|:---:|:---:|---|
| `docs/after_tap_widget.png` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Có trong `PHASE_06_2_*.md` | Ảnh chụp màn hình kiểm thử cũ. **Đề xuất: Chờ chủ dự án quyết định** (Khôi phục nếu muốn lưu hồ sơ nghiệm thu; Commit xóa nếu muốn repo gọn nhẹ). |
| `docs/both_widgets.png` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Có trong `PHASE_06_2_*.md` | Như trên. |
| `docs/expanded_after_task_ended.png` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Có trong `PHASE_06_2_*.md` | Như trên. |
| `docs/home_empty.png` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Có trong `PHASE_06_2_*.md` | Như trên. |
| `docs/reopened_home.png` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Có trong `PHASE_06_2_*.md` | Như trên. |
| `lib/core/network/dio_client.dart` | **CÓ** (commit `89cb1b6`) | **KHÔNG** | Không còn tham chiếu | Code chết vi phạm nguyên tắc Offline-First của F-Droid. **Đề xuất: COMMIT XÓA CHÍNH THỨC (`git rm`)**. |

---

## 6. SECURITY & SECRET AUDIT (KIỂM TOÁN AN NINH & BÍ MẬT)

### 6.1. Kiểm tra khoá bí mật & Mật khẩu
- **File Keystore (`*.jks`, `*.keystore`):** Hoàn toàn KHÔNG tồn tại trên ổ đĩa và chưa từng bị commit trong lịch sử Git.
- **File `android/key.properties`:** KHÔNG tồn tại trên ổ đĩa. Chỉ có file mẫu `android/key.properties.example` chứa các trường rỗng và hướng dẫn.
- **Biến môi trường (`.env`, `.env.*`):** Không có file `.env` nào trong dự án.
- **Database Credentials / API Tokens:** Đã quét toàn bộ mã nguồn Dart và Kotlin; không có bất kỳ chuỗi token, API key hay secret nào bị hardcode.

### 6.2. Kiểm tra quy tắc Ignore (`git check-ignore -v`)
- `git check-ignore -v android/key.properties` $\rightarrow$ `android/.gitignore:12:key.properties` (**PASS**)
- `git check-ignore -v android/app/release.keystore` $\rightarrow$ `android/.gitignore:13:**/*.keystore` (**PASS**)
- `git check-ignore -v .env` $\rightarrow$ `.gitignore:50:.env` (**PASS**)
- `git check-ignore -v build/app/outputs/flutter-apk/app-release.apk` $\rightarrow$ `.gitignore:35:/build/` (**PASS**)

### 6.3. Đánh giá phân loại an ninh
- **SAFE TO COMMIT:** Mã nguồn, tài liệu, font OFL, cấu hình Gradle, fastlane metadata.
- **EXCLUDE FROM GIT:** `emulator_screen.png`, `sprint_6_2_widget_error.txt`.
- **MUST NEVER COMMIT:** Keystore thực tế, mật khẩu ký, `key.properties`, file private key.
- **KẾT LUẬN:** **KHÔNG CÓ DẤU HIỆU LỘ BÍ MẬT (NO SECRET EXPOSURE SUSPECTED)**.

---

## 7. RELEASE SIGNING STRATEGY (CHIẾN LƯỢC KÝ BẢN PHÁT HÀNH)

### 7.1. Phân biệt hai kênh phát hành độc lập

```
                            MÃ NGUỒN TIMEFLOW (GNU GPLv3)
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
         KÊNH GITHUB RELEASES                             KÊNH F-DROID CHÍNH THỨC
                  │                                               │
       Biên dịch: Chủ dự án                             Biên dịch: F-Droid Build Server
                  │                                               │
         Ký: Developer Key                                 Ký: F-Droid Master Key
   (yêu cầu android/key.properties)                   (tự động ký từ mã nguồn sạch)
                  │                                               │
         Phát hành: APK Ký sẵn                           Phát hành: APK F-Droid Store
```

### 7.2. Tình trạng sẵn sàng ký hiện tại
- **GitHub Signed Release:** **NOT READY**. Vì trên máy phát triển hiện tại chưa thiết lập file `android/key.properties` và keystore cá nhân của chủ dự án. Bản `app-release.apk` vừa build là unsigned APK.
- **F-Droid Release:** **READY**. Gradle đã được cấu hình chuẩn: nếu không có `key.properties`, tác vụ `assembleRelease` sẽ tự động tạo ra file APK chưa ký (unsigned APK) mà không tự ý dùng Debug Key để ký đè. Bot F-Droid sẽ lấy bản unsigned này và ký bằng khoá chính thức của F-Droid.

### 7.3. Rủi ro di chuyển kênh cài đặt (Channel Migration Risk)
Do chữ ký số (Certificate Fingerprint) của Developer Key trên GitHub Releases và chữ ký của F-Droid là hoàn toàn khác nhau, hệ điều hành Android sẽ từ chối cài đặt đè (Package Signature Mismatch).

| Tiêu chí | Kênh GitHub Releases | Kênh F-Droid |
|---|---|---|
| Người biên dịch | Chủ dự án (Local/CI) | Server độc lập của F-Droid |
| Khóa ký APK | Developer Private Keystore | F-Droid Release Signing Key |
| Cập nhật chéo kênh | **KHÔNG THỂ CẬP NHẬT ĐÈ** | **KHÔNG THỂ CẬP NHẬT ĐÈ** |
| Hậu quả khi đổi kênh | Phải gỡ app cũ trước khi cài app mới | Phải gỡ app cũ trước khi cài app mới |
| **Rủi ro mất dữ liệu** | **Mất toàn bộ database SQLite nếu chưa sao lưu!** | **Mất toàn bộ database SQLite nếu chưa sao lưu!** |

> [!CAUTION]
> **CẢNH BÁO MẤT DỮ LIỆU KHI CHUYỂN KÊNH:**
> Cần đưa khuyến cáo rõ ràng trong `README.md` và `docs`: Khi người dùng chuyển đổi giữa bản cài đặt từ GitHub Releases và bản cài đặt từ F-Droid, họ bắt buộc phải gỡ phiên bản cũ. Hệ điều hành Android sẽ xóa sạch thư mục ứng dụng nội bộ (`timeflow.sqlite`). Vì vậy, tính năng Backup/Restore (được lên kế hoạch trong Roadmap) sẽ là giải pháp cứu cánh quan trọng.

---

## 8. GITIGNORE FINAL REVIEW (ĐÁNH GIÁ QUY TẮC IGNORE)

### 8.1. Đánh giá file `.gitignore` gốc
- Đã bỏ qua đúng các thư mục cache: `.dart_tool/`, `.pub/`, `.pub-cache/`, `/build/`, `/coverage/`.
- Đã bỏ qua file IDE: `.idea/`, `*.iml`, `*.ipr`, `*.iws`.
- Đã bảo vệ các file nhạy cảm: `key.properties`, `*.jks`, `*.keystore`, `.env`, `*.pem`, `*.key`.
- **Khuyến nghị bổ sung trong tương lai (không sửa ngay lúc này):**
  Nên thêm quy tắc ignore cho các file log và screenshot debug ở root:
  ```gitignore
  # Local debug logs & screenshots
  sprint_*_error.txt
  emulator_screen.png
  ```

### 8.2. Đánh giá file `android/.gitignore`
- Đã bỏ qua `key.properties`, `**/*.keystore`, `**/*.jks`, `/local.properties`, `/.gradle`.
- Đảm bảo các file cấu hình máy local không bị commit nhầm.

---

## 9. RELEASE DOCUMENTATION AUDIT (KIỂM TOÁN TÀI LIỆU PHÁT HÀNH)

### 9.1. Định danh dự án (Project Identity)
- Tên: TIMEFLOW.
- Application ID: `com.timeflow.timeflow`.
- Giấy phép: GNU General Public License v3.0 (`LICENSE`).
- Phiên bản: `0.6.2+2` (Semantic Versioning 2.0.0).

### 9.2. Tính xác thực của các tuyên bố tính năng (Feature Claims)
- **Xác nhận tính năng ĐÃ HOÀN THÀNH có bằng chứng:**
  - [x] Local SQLite Task CRUD (bằng chứng: 11 tests trong `database_test.dart` pass).
  - [x] Android Compact Widget 2x1 & Expanded Widget 4x2 (bằng chứng: Kotlin RemoteViews providers và tests trong `home_widget_test.dart` pass).
  - [x] Lockscreen Ongoing Notification (bằng chứng: `LockscreenNotificationManager.kt` và 23 tests trong `notification_service_test.dart` pass).
  - [x] Exact Task Reminders (bằng chứng: 18 tests trong `reminder_test.dart` pass).
  - [x] Monthly Calendar View (bằng chứng: 4 tests trong `calendar_test.dart` pass).
  - [x] Material 3 Light/Dark Theme với font Inter ngoại tuyến (bằng chứng: 8 tests trong `theme_settings_test.dart` pass).
- **Xác nhận KHÔNG TUYÊN BỐ các tính năng chưa làm:**
  - Không tuyên bố có Cloud Sync, AI Assistant, Pomodoro Timer, Thống kê biểu đồ, Công việc lặp lại (Recurring Tasks), hay JSON Backup/Restore.

### 9.3. Tuyên bố về Quyền riêng tư (Privacy Claims)
- Tuyên bố trong `PRIVACY_POLICY.md` hoàn toàn chính xác với mã nguồn thực tế:
  - 100% dữ liệu nằm trên điện thoại của người dùng (`timeflow.sqlite` và `SharedPreferences`).
  - Không tạo tài khoản, không đăng nhập.
  - Bản release không khai báo quyền `android.permission.INTERNET`.
  - Không có Firebase, Google Analytics hay bất kỳ mã theo dõi của bên thứ ba nào.

---

## 10. VERSION & RELEASE ARTIFACT AUDIT (KIỂM TOÁN PHIÊN BẢN & ARTIFACT)

### 10.1. Đồng bộ giá trị phiên bản trên toàn bộ dự án
- `pubspec.yaml`: `version: 0.6.2+2`
- `pubspec.lock`: `0.6.2+2`
- `android/app/src/main/AndroidManifest.xml` (Merged): `android:versionCode="2"`, `android:versionName="0.6.2"`
- `lib/features/settings/presentation/settings_screen.dart`: `Phiên bản 0.6.2 (Sprint 6.2)`
- `fastlane/metadata/android/en-US/changelogs/2.txt`: Đã tạo changelog cho phiên bản mã `2`.
- `CHANGELOG.md`: Đã có mục ghi nhận cho `[0.6.2]`.

### 10.2. Bảng kiểm kê hiện vật biên dịch (Artifact Inventory)

| Artifact File | Build Type | Kích thước | SHA-256 Checksum | Trạng thái Chữ ký (apksigner) |
|---|---|---|---|---|
| `build/app/outputs/flutter-apk/app-release.apk` | Release | 65.062.714 bytes (~62.0 MB) | `9724522C17B5EEE9ED26C1B43CF727176CF4A162B2D764FB2BE2919D42959713` | **Unsigned** (Missing META-INF/MANIFEST.MF) – Chuẩn F-Droid |
| `build/app/outputs/flutter-apk/app-debug.apk` | Debug | 164.710.714 bytes (~157.0 MB) | `3B26F89CBE6055F33606688EEDCA43E88BAD95F43B33187E124C1CF52F94ABF4` | **Signed** by Android Debug Certificate (`CN=Android Debug`) |

---

## 11. F-DROID READINESS (MỨC ĐỘ SẴN SÀNG CHO F-DROID)

Dự án TIMEFLOW đáp ứng đầy đủ tất cả các yêu cầu khắt khe của F-Droid Inclusion Policy:
1. **Hoàn toàn Open-Source:** Giấy phép GNU GPLv3 hợp lệ và đầy đủ ([LICENSE](file:///D:/TODOLIST%20AND%20LOCKSCREEN/LICENSE)).
2. **Không có Antifeatures:** Không chứa quảng cáo, không theo dõi người dùng, không phụ thuộc dịch vụ mạng không tự do.
3. **Biên dịch ngoại tuyến tái lập (Reproducible Offline Build):**
   - Bộ font Inter nhúng cục bộ tại `assets/fonts/` kèm giấy phép SIL OFL 1.1.
   - Không thực hiện bất kỳ network request nào trong quá trình chạy ứng dụng.
   - Cấu hình Gradle `kotlin.incremental=false` và giới hạn RAM hợp lý (`2048m`) đảm bảo build ổn định trong container CI của F-Droid.
4. **Fastlane Metadata:** Có cấu trúc `fastlane/metadata/android/en-US/` hoàn chỉnh.

---

## 12. SPRINT 7 READINESS & LOGIC GAP AUDIT (SẴN SÀNG CHO SPRINT 7)

### 12.1. Phân tích bất đồng bộ logic: `task_providers.dart` vs `home_widget_providers.dart`

```
┌────────────────────────────────────────────────────────────────────────┐
│                        todayTasksStreamProvider                        │
└───────────────────┬────────────────────────────────┬───────────────────┘
                    │                                │
                    ▼                                ▼
┌──────────────────────────────────────┐ ┌───────────────────────────────┐
│         task_providers.dart          │ │  home_widget_providers.dart   │
├──────────────────────────────────────┤ ├───────────────────────────────┤
│ • firstWhere (thứ tự query DB)       │ │ • evaluateCurrentAndNextTask  │
│ • Bỏ qua priority khi task overlap   │ │ • Priority tie-breaker chuẩn  │
│ • startTime == null lọt vào NextTask │ │ • startTime != null nghiêm ngặt│
│ • Clock tĩnh (chờ DB mutation)       │ │ • Clock động (tick theo task) │
└──────────────────────────────────────┘ └───────────────────────────────┘
```

1. **Vấn đề Current Task Overlap:**
   - Trong `task_providers.dart`: Nếu có 2 task cùng diễn ra lúc 10:00 (Task A: 09:00-11:00 Low; Task B: 09:30-10:30 Urgent), `currentTaskStreamProvider` sẽ lấy Task A vì nó xuất hiện trước trong mảng trả về của DB, bỏ qua mức độ ưu tiên Urgent của Task B.
   - Trong `home_widget_providers.dart`: Sắp xếp ưu tiên tuyệt đối theo `_priorityWeight` (Urgent > High > Medium > Low), nên Task B sẽ được chọn chính xác.
2. **Vấn đề Next Task không có giờ:**
   - Trong `task_providers.dart`: Các task không có `startTime` (`startTime == null`) được đưa vào danh sách upcoming (`return true;`). Khi không còn task có giờ nào, một task không giờ sẽ biến thành Next Task.
   - Trong `home_widget_providers.dart`: Bắt buộc `t.startTime != null && t.startTime!.isAfter(now)`.
3. **Vấn đề Đồng hồ thời gian thực:**
   - Trong `task_providers.dart`: Sử dụng `DateTime.now()` một lần khi provider tính toán. Nếu người dùng mở app và để màn hình sáng qua giờ kết thúc của task, màn hình không tự nhảy sang task tiếp theo trừ khi có thao tác ghi dữ liệu vào SQLite.
   - Trong `home_widget_providers.dart`: Sử dụng `homeWidgetClockProvider` tính toán ranh giới chuyển đổi sớm nhất (`calculateNextTransitionTime`) để tự động thức dậy và cập nhật lại widget đúng từng phút.

### 12.2. Kế hoạch kỹ thuật chi tiết cho Sprint 7

| Hạng mục Sprint 7 | Vấn đề kỹ thuật | Tệp tin liên quan | Mức độ ưu tiên | Tiêu chí nghiệm thu (Acceptance Criteria) | Bộ Test cần bổ sung |
|---|---|---|:---:|---|---|
| **1. Domain Service thống nhất** | Logic Current/Next Task bị phân mảnh 2 nơi | `lib/core/domain/services/task_time_service.dart` (tạo mới) | **P1 (Cao nhất)** | Trích xuất toàn bộ thuật toán `evaluateCurrentAndNextTask` và `calculateNextTransitionTime` thành Service thuần túy dùng chung cho cả App và Widget. | Unit test 15 kịch bản overlap, priority tie-breaker, ranh giới nửa đêm. |
| **2. Tái cấu trúc Task Providers** | `task_providers.dart` dùng clock tĩnh và `firstWhere` | `lib/features/tasks/presentation/providers/task_providers.dart` | **P1** | `currentTaskStreamProvider` và `nextTaskStreamProvider` chuyển sang dùng Domain Service chung và lắng nghe clock động. | Widget test màn hình Home tự động chuyển task khi đồng hồ trôi qua ranh giới. |
| **3. Permission Onboarding Dialog** | Người dùng từ chối quyền thông báo/báo thức làm hỏng tính năng | `lib/features/onboarding/presentation/` | **P2** | Hiển thị hộp thoại giải thích lý do cần quyền `POST_NOTIFICATIONS` và `SCHEDULE_EXACT_ALARM` kèm nút điều hướng đến Cài đặt hệ thống nếu bị từ chối vĩnh viễn. | Unit/Widget test trạng thái cấp quyền (Granted, Denied, PermanentlyDenied). |
| **4. Widget Deep Link Handling** | Chạm vào task cụ thể trên Expanded Widget mở thẳng chi tiết task | `lib/core/router/app_router.dart`, `MainActivity.kt` | **P3** | Intent URI từ widget truyền `taskId` vào `GoRouter` để mở thẳng màn hình chỉnh sửa task. | Tích hợp Router test với URI payload. |

---

## 13. FINAL COMMIT CANDIDATE MANIFEST (DANH MỤC CÁC FILE ĐƯỢC ĐỀ XUẤT COMMIT)

Chủ dự án có thể tham chiếu bảng này để rà soát chính xác trước khi thực hiện các lệnh Git:

| File / Folder Path | Trạng thái hiện tại | Phân loại | Mục đích & Lý do | Hành động đề xuất |
|---|---|:---:|---|---|
| `.gitignore` | Modified | A (Source) | Bảo vệ secret, keystore, env | `git add .gitignore` |
| `README.md` | Modified | B (Docs) | Tài liệu chính thức tiếng Anh | `git add README.md` |
| `README_VI.md` | Untracked | B (Docs) | Tài liệu chính thức tiếng Việt | `git add README_VI.md` |
| `LICENSE` | Untracked | B (Docs) | Văn bản giấy phép GNU GPLv3 | `git add LICENSE` |
| `CHANGELOG.md` | Untracked | B (Docs) | Lịch sử thay đổi Keep a Changelog | `git add CHANGELOG.md` |
| `CONTRIBUTING.md` | Untracked | B (Docs) | Hướng dẫn đóng góp cộng đồng | `git add CONTRIBUTING.md` |
| `SECURITY.md` | Untracked | B (Docs) | Chính sách báo cáo lỗ hổng an ninh | `git add SECURITY.md` |
| `PRIVACY_POLICY.md` | Untracked | B (Docs) | Chính sách quyền riêng tư Local-First | `git add PRIVACY_POLICY.md` |
| `pubspec.yaml` | Modified | A (Source) | Phiên bản 0.6.2+2, Inter fonts, gỡ dio | `git add pubspec.yaml` |
| `pubspec.lock` | Modified | A (Source) | Cây phụ thuộc đồng bộ | `git add pubspec.lock` |
| `android/app/build.gradle.kts` | Modified | A (Source) | Cấu hình release signing an toàn | `git add android/app/build.gradle.kts` |
| `android/gradle.properties` | Modified | A (Source) | Tối ưu JVM heap & compiler fix | `git add android/gradle.properties` |
| `android/key.properties.example` | Untracked | A (Source) | File mẫu signing template | `git add android/key.properties.example` |
| `assets/fonts/Inter-*.ttf` | Untracked | A (Source) | 4 tệp font Inter ngoại tuyến | `git add assets/fonts/` |
| `assets/fonts/LICENSE_OFL.txt` | Untracked | A (Source) | Giấy phép SIL OFL của font Inter | `git add assets/fonts/LICENSE_OFL.txt` |
| `lib/core/theme/app_theme.dart` | Modified | A (Source) | Sử dụng typography Inter ngoại tuyến | `git add lib/core/theme/app_theme.dart` |
| `lib/features/settings/presentation/settings_screen.dart` | Modified | A (Source) | Cập nhật nhãn version 0.6.2 trên UI | `git add lib/features/settings/...` |
| `lib/core/network/dio_client.dart` | Deleted | A (Source) | Xóa bỏ dead code | `git rm lib/core/network/dio_client.dart` |
| `fastlane/metadata/android/` | Untracked | C (Metadata) | Metadata cửa hàng ứng dụng F-Droid | `git add fastlane/` |
| `docs/project_knowledge/` | Untracked | B (Docs) | 14 tài liệu tri thức hệ thống | `git add docs/project_knowledge/` |
| `docs/release/` | Untracked | B (Docs) | Các báo cáo kiểm toán Prompt 12-13.2 | `git add docs/release/` |
| `docs/PHASE_06_2_GIT_RELEASE_REPORT.md` | Modified | B (Docs) | Báo cáo lịch sử Sprint 6.2 | `git add docs/PHASE_06_2_GIT_RELEASE_REPORT.md` |
| `docs/*.png` (5 ảnh bị xóa) | Deleted | D (Tùy chọn) | Minh chứng kiểm thử Sprint 6.2 cũ | **Chờ chủ dự án quyết định** |
| `emulator_screen.png` | Untracked | D (Local) | File rỗng 0 bytes tạm thời | **LOẠI BỎ (Không add)** |
| `sprint_6_2_widget_error.txt` | Untracked | D (Local) | Logcat debug tạm thời | **LOẠI BỎ (Không add)** |
| `build/` | Ignored | E (Build) | Thư mục build output | **BỊ IGNORE BỞI GIT** |

---

## 14. PROPOSED COMMIT GROUPS (KẾ HOẠCH PHÂN NHÓM COMMIT TƯƠNG LAI)

Để lịch sử Git của dự án TIMEFLOW mạch lạc, chuyên nghiệp và chuẩn mực mã nguồn mở quốc tế, đề xuất chủ dự án chia các thay đổi thành 3 commit riêng biệt khi tiến hành Prompt 14:

### Commit 1: Cấu hình mã nguồn mở, Giấy phép & Bảo mật
```bash
git add LICENSE .gitignore README.md README_VI.md CONTRIBUTING.md SECURITY.md PRIVACY_POLICY.md
git commit -m "chore(oss): establish GNU GPLv3 license, open-source governance and security policies"
```

### Commit 2: Tái cấu trúc chuẩn F-Droid & Đồng bộ phiên bản 0.6.2+2
```bash
git rm lib/core/network/dio_client.dart
git add pubspec.yaml pubspec.lock assets/fonts/ lib/core/theme/app_theme.dart lib/features/settings/presentation/settings_screen.dart android/app/build.gradle.kts android/gradle.properties android/key.properties.example fastlane/
git commit -m "feat(release): upgrade to v0.6.2+2 with offline Inter typography and secure release signing"
```

### Commit 3: Hồ sơ tri thức dự án & Báo cáo kiểm toán phát hành
```bash
git add docs/project_knowledge/ docs/release/ docs/PHASE_06_2_GIT_RELEASE_REPORT.md
# (Nếu quyết định xóa 5 ảnh cũ: git add docs/*.png; nếu giữ lại: git checkout HEAD -- docs/*.png)
git commit -m "docs: add comprehensive project knowledge base and release audit reports"
```

---

## 15. RELEASE CHANNEL ASSESSMENT (ĐÁNH GIÁ CÁC KÊNH PHÁT HÀNH)

| Tiêu chí đánh giá | Kênh 1: GitHub Source Code | Kênh 2: GitHub Release APK | Kênh 3: F-Droid Official Repository |
|---|:---:|:---:|:---:|
| **Source Repository Integrity** | **PASS** | **PASS** | **PASS** |
| **GPLv3 Compliance** | **PASS** | **PASS** | **PASS** |
| **Dependency Licensing** | **PASS** (MIT/BSD/Apache) | **PASS** | **PASS** |
| **Build Reproducibility** | **PASS** | **PASS** | **PASS** (Font offline, no network) |
| **Signing Readiness** | N/A (Source code) | **BLOCKED (Chưa có private key)** | **PASS (F-Droid tự ký)** |
| **Store Metadata** | **PASS** (README) | **PASS** (Changelog) | **PASS** (Fastlane structure) |
| **Privacy / No Trackers** | **PASS** | **PASS** | **PASS** (Zero telemetry, no INTERNET) |
| **Migration Risk Warning** | Đã ghi nhận | Cần cảnh báo user | Cần cảnh báo user |
| **ĐÁNH GIÁ CHUNG** | **READY FOR NEXT PHASE** | **CONDITIONALLY READY** | **READY FOR NEXT PHASE** |

---

## 16. REMAINING BLOCKERS (CÁC ĐIỂM NGHẼN CÒN LẠI)

1. **Khóa ký Developer Release Keystore (Dành riêng cho GitHub Releases APK):**
   - Dự án hiện chưa có keystore cá nhân của chủ dự án để tạo file APK đã ký đưa lên GitHub Releases.
   - *Cách tháo gỡ:* Nếu chủ dự án muốn phát hành APK trực tiếp qua GitHub, chỉ cần tạo file `android/key.properties` theo mẫu có sẵn trước khi chạy lệnh build ký. Nếu chỉ ưu tiên đưa source lên GitHub và nộp F-Droid thì đây không phải là blocker.
2. **Quyết định về 5 file ảnh minh chứng cũ trong `docs/`:**
   - 5 file ảnh minh chứng của Sprint 6.2 đang ở trạng thái deleted trong working tree.
   - *Cách tháo gỡ:* Chủ dự án chọn khôi phục (`git checkout HEAD -- docs/*.png`) hoặc xác nhận xóa (`git add docs/*.png`) trước khi commit.

---

## 17. FINAL RECOMMENDATIONS (KHUYẾN NGHỊ CUỐI CÙNG CHO CHỦ DỰ ÁN)

1. **Phê duyệt danh mục file:** Tiến hành xem xét và phê duyệt bảng kiểm kê file tại Mục 13.
2. **Loại trừ file rác:** Không đưa `emulator_screen.png` và `sprint_6_2_widget_error.txt` vào bất kỳ lệnh `git add` nào.
3. **Thực hiện theo 3 nhóm commit có cấu trúc:** Áp dụng đề xuất phân nhóm commit tại Mục 14 để duy trì lịch sử Git đẹp và chuyên nghiệp.
4. **Tiến sang Prompt 14:** Dự án đã hoàn toàn sẵn sàng về mặt pháp lý, cấu trúc mã nguồn, an ninh bí mật và chất lượng kiểm thử để bước vào giai đoạn thực thi Git commit, gắn tag phát hành và mở Sprint 7.

---
*Báo cáo kiểm toán được thực hiện độc lập, khách quan với đầy đủ bằng chứng pháp y từ mã nguồn và kho Git của dự án TIMEFLOW.*

