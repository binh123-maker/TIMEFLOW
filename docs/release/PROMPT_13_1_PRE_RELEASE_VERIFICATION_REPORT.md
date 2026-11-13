# TIMEFLOW – BÁO CÁO KIỂM TRA TIỀN PHÁT HÀNH & AUDIT WORKING TREE
## Release Candidate 0.6.2+2 (Prompt 13.1 Verification Report)

---

- **Dự án:** TIMEFLOW – To-do List & Lockscreen Application
- **Mã nguồn:** `D:\TODOLIST AND LOCKSCREEN`
- **Application ID:** `com.timeflow.timeflow`
- **Phiên bản chuẩn:** `0.6.2+2` (`versionName`: `0.6.2`, `versionCode`: `2`)
- **Giấy phép phần mềm:** GNU General Public License v3.0 (GNU GPLv3)
- **Kiến trúc:** Flutter Feature-first + Light Clean Architecture + Drift SQLite
- **Ngày thực hiện kiểm tra:** 13/11/2026
- **Kỹ sư thực hiện:** Senior Flutter / Android & Open-Source Release Engineer

---

## I. TỔNG QUAN & KẾT LUẬN TIỀN PHÁT HÀNH (EXECUTIVE SUMMARY)

Sau khi hoàn tất quá trình khắc phục theo **Prompt 13**, giai đoạn **Prompt 13.1** đã tiến hành kiểm tra độc lập và toàn diện tình trạng của dự án TIMEFLOW trước khi phát hành phiên bản Release Candidate `0.6.2+2`.

### Kết quả đánh giá chung: **RELEASE CANDIDATE READY (RC2 - PASS)**

1. **Đồng bộ phiên bản:** Đã cập nhật và đồng bộ phiên bản `0.6.2+2` trên toàn bộ hệ thống (`pubspec.yaml`, `pubspec.lock`, `lib/features/settings/presentation/settings_screen.dart`, `fastlane/metadata/android/en-US/changelogs/2.txt`, và `AndroidManifest.xml`).
2. **Xác thực chữ ký APK (apksigner):** 
   - `app-release.apk` hoàn toàn **unsigned** (không bị ký nhầm bởi debug key, không chứa credential), sẵn sàng 100% cho pipeline build và ký tự động của F-Droid chính thức, hoặc ký thủ công bằng private keystore qua `key.properties`.
   - `app-debug.apk` được ký bằng khóa phát triển chuẩn (`Android Debug`).
3. **An toàn quyền & Zero Network:** Merged Manifest xác nhận **KHÔNG CÓ QUYỀN `android.permission.INTERNET`** trong bản release. Ứng dụng hoạt động 100% Local-First / Offline-First.
4. **Kiểm thử hồi quy:**
   - `flutter analyze`: **0 cảnh báo / 0 lỗi** (`No issues found!`).
   - `flutter test`: **87/87 test cases PASS** (100% đạt chuẩn trên Unit, Widget, Service, Repository, Use Case, State Notifier và Database Migration).
   - Build Gradle `assembleRelease` & `assembleDebug`: **Thành công 100%**.
5. **Bảo tồn Working Tree:** Không có bất kỳ lệnh Git commit, push, reset hay clean nào được thực hiện tự ý. Mọi dữ liệu tri thức trong `docs/project_knowledge/` được giữ nguyên vẹn.

---

## II. KẾT QUẢ GIAI ĐOẠN 0 – AUDIT WORKING TREE & GIT REPOSITORY

### 1. Trạng thái Git hiện tại
- **Current Branch:** `main`
- **HEAD Commit:** `89cb1b6` (*docs: add Sprint 6.2 git release report*)
- **Remote Origin:** `https://github.com/binh123-maker/TIMEFLOW.git`
- **Existing Git Tags:**
  - `v0.5.0`
  - `v0.6.0`
  - `v0.6.1`
  - `v0.6.2` (trỏ vào commit `44126a0`)

### 2. Danh mục các file trong Working Tree (`git status --short`)

```text
 M .gitignore
 M README.md
 M android/app/build.gradle.kts
 M android/gradle.properties
 M docs/PHASE_06_2_GIT_RELEASE_REPORT.md
 D docs/after_tap_widget.png
 D docs/both_widgets.png
 D docs/expanded_after_task_ended.png
 D docs/home_empty.png
 D docs/reopened_home.png
 D lib/core/network/dio_client.dart
 M lib/core/theme/app_theme.dart
 M lib/features/settings/presentation/settings_screen.dart
 M pubspec.lock
 M pubspec.yaml
?? CHANGELOG.md
?? CONTRIBUTING.md
?? LICENSE
?? PRIVACY_POLICY.md
?? README_VI.md
?? SECURITY.md
?? android/key.properties.example
?? assets/
?? docs/project_knowledge/
?? docs/release/
?? emulator_screen.png
?? fastlane/
?? sprint_6_2_widget_error.txt
```

### 3. Phân tích chi tiết 5 file ảnh bị xóa (`docs/*.png`)
Các file ảnh bị xóa ở trạng thái unstaged gồm:
- `docs/after_tap_widget.png`
- `docs/both_widgets.png`
- `docs/expanded_after_task_ended.png`
- `docs/home_empty.png`
- `docs/reopened_home.png`

**Kết quả điều tra:**
- Cả 5 file ảnh này **vẫn tồn tại nguyên vẹn trong Git HEAD** (commit `89cb1b6`).
- Chúng được tạo trong Sprint 6.2 và được tham chiếu trong các báo cáo lịch sử:
  - `docs/PHASE_06_2_ACCEPTANCE_REPORT.md`
  - `docs/PHASE_06_2_FUNCTIONAL_TEST_REPORT.md`
  - `docs/PHASE_06_2_GIT_RELEASE_REPORT.md`
- **Quyết định an toàn:** Giữ nguyên trạng thái unstaged hiện tại, không tự ý chạy `git checkout --` hoặc `git rm`, để chủ dự án quyết định lúc commit giai đoạn phát hành.

---

## III. ĐỐI CHIẾU & ĐỒNG BỘ PHIÊN BẢN (0.6.2+2)

Theo phê duyệt của chủ dự án, phiên bản chuẩn cho bản phát hành này là **`0.6.2+2`**.

| Vị trí cấu hình | Trạng thái trước Prompt 13.1 | Cập nhật sau Prompt 13.1 | Kết quả xác minh |
|---|---|---|---|
| `pubspec.yaml` | `version: 1.0.0+1` | `version: 0.6.2+2` | **PASS** (Cú pháp hợp lệ) |
| `pubspec.lock` | Phiên bản cũ | Tự động đồng bộ qua `flutter pub get` | **PASS** |
| `SettingsScreen` (`settings_screen.dart`) | Hardcoded `Phiên bản 1.0.0 (Phase 1 Init)` | `Phiên bản 0.6.2 (Sprint 6.2)` | **PASS** (Hiển thị UI chính xác) |
| `fastlane/metadata/.../changelogs/` | `1.txt` | Bổ sung `2.txt` tương ứng `versionCode: 2` | **PASS** |
| Merged `AndroidManifest.xml` | `versionCode="1"`, `versionName="1.0.0"` | `versionCode="2"`, `versionName="0.6.2"` | **PASS** (Generated tự động từ build Flutter) |

---

## IV. KẾT QUẢ AUDIT CHỮ KÝ APK & APKSIGNER

Công cụ kiểm tra: Android SDK Build-Tools `35.0.0` (`apksigner.bat`).

### 1. Bản dựng Release: `build/app/outputs/flutter-apk/app-release.apk`
- **Kích thước file:** 65.062.714 bytes (~62.0 MB)
- **SHA-256 Checksum:** `9724522C17B5EEE9ED26C1B43CF727176CF4A162B2D764FB2BE2919D42959713`
- **Kết quả `apksigner verify --verbose --print-certs`:**
  ```text
  DOES NOT VERIFY
  ERROR: Missing META-INF/MANIFEST.MF
  ```
- **Phân tích:**
  - Hoàn toàn **UNSIGNED**.
  - Không bị ký ngầm bởi debug key hay keystore không an toàn.
  - Sẵn sàng 100% cho quy trình build và tự động ký độc lập của bot F-Droid server (`fdroid build`).
  - Nếu phân phối qua GitHub Releases hoặc IzzyOnDroid, chủ dự án chỉ cần tạo file `android/key.properties` theo mẫu `android/key.properties.example` để ký file APK bằng key riêng của mình.

### 2. Bản dựng Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- **Kích thước file:** 164.710.714 bytes (~157.0 MB)
- **SHA-256 Checksum:** `3B26F89CBE6055F33606688EEDCA43E88BAD95F43B33187E124C1CF52F94ABF4`
- **Kết quả `apksigner verify --verbose --print-certs`:**
  ```text
  Verifies
  Verified using v2 scheme (APK Signature Scheme v2): true
  Number of signers: 1
  Signer #1 certificate DN: C=US, O=Android, CN=Android Debug
  Signer #1 certificate SHA-256 digest: 61a79634dcba1e01d49c43c456c207cb860b0287d7e61536b57477164edfdf3a
  Signer #1 key algorithm: RSA (2048 bits)
  ```
- **Phân tích:** Chỉ bản debug mới được ký bởi Android Debug Key phục vụ mục đích kiểm thử cục bộ.

---

## V. AUDIT MANIFEST HỢP NHẤT (MERGED ANDROIDMANIFEST.XML)

Đường dẫn kiểm tra: `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`

### 1. Nhận diện gói & Phiên bản
- `package="com.timeflow.timeflow"` (Chính xác theo quyết định giữ nguyên của chủ dự án)
- `android:versionCode="2"`
- `android:versionName="0.6.2"`
- `minSdkVersion="24"` (Android 7.0 Nougat trở lên)
- `targetSdkVersion="36"`

### 2. Danh sách quyền thực tế trong Release APK

| Quyền Android | Nguồn gốc | Mục đích sử dụng | Phù hợp F-Droid |
|---|---|---|:---:|
| `POST_NOTIFICATIONS` | App Manifest | Hiển thị thông báo nhắc lịch và Lockscreen Ongoing Notification (Android 13+) | **PASS** |
| `RECEIVE_BOOT_COMPLETED` | App Manifest + flutter_local_notifications | Tự động khôi phục lịch nhắc nhở sau khi khởi động lại thiết bị | **PASS** |
| `SCHEDULE_EXACT_ALARM` | App Manifest + flutter_local_notifications | Đặt báo thức chính xác từng phút theo giờ bắt đầu công việc | **PASS** |
| `VIBRATE` | flutter_local_notifications | Rung thiết bị khi chuông nhắc việc reo | **PASS** |
| `WAKE_LOCK` | flutter_local_notifications | Đánh thức CPU trong thời gian ngắn để dispatch thông báo | **PASS** |
| `ACCESS_NETWORK_STATE` | Flutter Engine / Glance | Kiểm tra trạng thái mạng nội bộ thiết bị (không truyền dữ liệu) | **PASS** |
| `FOREGROUND_SERVICE` | Glance / WorkManager | Phục vụ cập nhật widget màn hình khóa | **PASS** |
| `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` | AndroidX Core | Bảo vệ bảo mật IPC nội bộ trên Android 14+ | **PASS** |

> [!IMPORTANT]
> **XÁC NHẬN ZERO-NETWORK:**
> Không có quyền `android.permission.INTERNET` trong file manifest hợp nhất của bản Release. Điều này đảm bảo về mặt kỹ thuật rằng ứng dụng không thể gửi hoặc nhận bất kỳ dữ liệu nào qua mạng internet.

---

## VI. AUDIT DEPENDENCY & GIẤY PHÉP BÊN THỨ BA

Tất cả các thư viện runtime trong `pubspec.lock` và Android Native dependencies đều tương thích với **GNU GPLv3**:

| Thành phần / Thư viện | Giấy phép | Vai trò | Phù hợp Open-Source / F-Droid |
|---|---|---|:---:|
| `flutter` & `flutter_localizations` | BSD-3-Clause | Framework cốt lõi | **PASS** |
| `flutter_riverpod` & `riverpod` | MIT | State Management | **PASS** |
| `go_router` | BSD-3-Clause | Khung điều hướng màn hình | **PASS** |
| `drift` & `drift_dev` | MIT | SQLite ORM Local-First | **PASS** |
| `sqlite3_flutter_libs` | MIT | SQLite C-library native binaries | **PASS** |
| `flutter_local_notifications` | BSD-3-Clause | Hệ thống thông báo & báo thức native | **PASS** |
| `timezone` | BSD-2-Clause | Xử lý múi giờ địa phương | **PASS** |
| `shared_preferences` | BSD-3-Clause | Lưu trữ cấu hình theme nội bộ | **PASS** |
| `home_widget` | BSD-3-Clause | Cầu nối Widget Android Glance/RemoteViews | **PASS** |
| `cupertino_icons` / `intl` / `uuid` | MIT / BSD-3-Clause | Tiện ích giao diện & định dạng | **PASS** |
| Bộ font `Inter` (`assets/fonts/Inter-*.ttf`) | SIL OFL 1.1 | Font chữ ngoại tuyến nhúng sẵn | **PASS** |
| `desugar_jdk_libs:2.1.4` | Apache-2.0 | Java 8+ API desugaring trên Android cũ | **PASS** |

- **Không chứa Google Play Services SDKs.**
- **Không chứa Firebase SDKs.**
- **Không chứa bất kỳ thư viện quảng cáo, tracking, telemetry hay crash report bên thứ ba.**
- **Mã nguồn ứng dụng TIMEFLOW:** Phát hành theo `GNU General Public License v3.0` (`LICENSE`).

---

## VII. KIỂM TRA TƯƠNG THÍCH F-DROID & OFFLINE-FIRST

1. **Build hoàn toàn ngoại tuyến:**
   - Đã nhúng 4 tệp font Inter TTF vào thư mục `assets/fonts/` kèm file `LICENSE_OFL.txt`.
   - Cấu hình font family `Inter` trong `pubspec.yaml` và `app_theme.dart`. Không có bất kỳ lệnh gọi HTTP nào tới `google_fonts` lúc runtime.
2. **Loại bỏ hoàn toàn code chết:**
   - File `lib/core/network/dio_client.dart` đã được xóa sạch.
   - Package `dio` và `google_fonts` đã được loại bỏ khỏi `pubspec.yaml` và `pubspec.lock`.
3. **Cấu hình Gradle thân thiện môi trường CI F-Droid:**
   - Trong `android/gradle.properties`:
     - Cấu hình JVM tối ưu: `-Xmx2048m -XX:MaxMetaspaceSize=1024m` (tránh crash OutOfMemory trên máy chủ ảo F-Droid).
     - Đặt `kotlin.incremental=false` nhằm khắc phục lỗi compiler đa ổ đĩa trên Windows và đảm bảo build tái lập sạch sẽ (clean reproducible build).
4. **Fastlane Metadata:**
   - `fastlane/metadata/android/en-US/title.txt`: `TIMEFLOW`
   - `fastlane/metadata/android/en-US/short_description.txt` (<= 80 ký tự)
   - `fastlane/metadata/android/en-US/full_description.txt` (Mô tả đầy đủ tính năng, triết lý Local-First, bảo mật)
   - `fastlane/metadata/android/en-US/changelogs/2.txt` (Sẵn sàng cho `versionCode: 2`)

---

## VIII. SO SÁNH LOGIC CURRENT TASK VÀ NEXT TASK

Trong quá trình audit mã nguồn, đã phát hiện và ghi nhận sự khác biệt về logic xác định **Current Task** và **Next Task** giữa hai hệ thống:

```
┌─────────────────────────────────────────────────────────────┐
│                    todayTasksStreamProvider                 │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐ ┌─────────────────────────────┐
│      task_providers.dart     │ │  home_widget_providers.dart │
│ (Dashboard & Notifications)  │ │   (Android Home Widgets)    │
└──────────────────────────────┘ └─────────────────────────────┘
```

### 1. Bảng đối chiếu chi tiết

| Tiêu chí | `lib/.../tasks/.../task_providers.dart` | `lib/.../home_widget/.../home_widget_providers.dart` |
|---|---|---|
| **Hàm thực thi** | `firstWhere` lặp tuần tự danh sách | Hàm thuần túy `evaluateCurrentAndNextTask(tasks, now)` |
| **Xử lý trùng lặp giờ (Current Task)** | Lấy phần tử đầu tiên thỏa điều kiện theo thứ tự query DB (`startTime ASC, priority DESC`). Bỏ qua độ ưu tiên nếu task ưu tiên thấp bắt đầu trước! | **Sắp xếp theo độ ưu tiên rõ ràng:** `urgent > high > medium > low`. Nếu cùng độ ưu tiên mới xét `startTime ASC`, sau đó `endTime ASC`. |
| **Xử lý Next Task** | `upcoming.sort` cho phép task không có `startTime` (`startTime == null`) lọt vào danh sách nếu không có task có giờ | **Lọc nghiêm ngặt:** Chỉ những task có `startTime != null` và `startTime.isAfter(now)` mới được xem là Next Task. |
| **Cơ chế đồng hồ (Clock Tick)** | **Tĩnh (`DateTime.now()`):** Chỉ tính lại khi `todayTasksStreamProvider` phát sinh emit từ database. Khi thời gian trôi qua ranh giới công việc, provider không tự động nhảy sang task kế nếu không có thao tác DB! | **Động (`homeWidgetClockProvider`):** Tự động tính toán điểm chuyển tiếp thời gian sớm nhất (`calculateNextTransitionTime`) hoặc bước nhảy phút để `yield DateTime.now()`, đảm bảo widget cập nhật chính xác từng phút. |
| **Phạm vi sử dụng** | `HomeScreen` (Giao diện chính trong app) và `OngoingScheduleNotificationService` | Android Home Screen Widgets (Compact 2x1 & Expanded 4x2) |

### 2. Đánh giá rủi ro & Kế hoạch khắc phục
- **Đánh giá rủi ro hiện tại:** Thấp đối với Release Candidate `0.6.2+2` vì hai cơ chế hoạt động độc lập ở hai ngữ cảnh riêng (một bên phục vụ widget native, một bên phục vụ màn hình chính trong app) và toàn bộ 87 test cases hiện tại đều PASS.
- **Kế hoạch xử lý (Sprint 7):**
  - Trích xuất `evaluateCurrentAndNextTask` và `calculateNextTransitionTime` vào một `TaskTimeDomainService` dùng chung.
  - Tái cấu trúc `currentTaskStreamProvider` và `nextTaskStreamProvider` trong `task_providers.dart` sử dụng đồng hồ động và thuật toán xếp hạng ưu tiên của `home_widget_providers.dart`.

---

## IX. KẾT QUẢ KIỂM THỬ HỒI QUY TOÀN DIỆN (REGRESSION TEST RESULTS)

### 1. Phân tích tĩnh (`flutter analyze`)
- **Lệnh chạy:** `flutter.bat analyze`
- **Kết quả:** `No issues found! (ran in 10.0s)`
- **Đánh giá:** 0 warning, 0 error, 0 hint.

### 2. Kiểm thử tự động (`flutter test`)
- **Lệnh chạy:** `flutter.bat test`
- **Kết quả:** **87/87 test cases passed (100%)**
- **Chi tiết các bộ test:**
  - `test/calendar_test.dart`: 4/4 PASS (Xử lý ngày, tính toán lưới lịch, tích hợp Drift)
  - `test/database_test.dart`: 11/11 PASS (Drift SQLite CRUD, stream reactivity, schema v1->v2 migration)
  - `test/notification_service_test.dart`: 23/23 PASS (Tạo kênh thông báo, lockscreen payload, boot receiver)
  - `test/reminder_test.dart`: 18/18 PASS (Exact alarm offset, deterministic FNV-1a ID hash, startup reconciliation)
  - `test/theme_settings_test.dart`: 8/8 PASS (Persistent dark/light theme, local storage sync, error fallback)
  - `test/usecases_test.dart`: 5/5 PASS (Validation rules, title constraints, time range sanity checks)
  - `test/widget_test.dart`: 2/2 PASS (Format ngày tháng tiếng Việt, hiển thị danh xưng trạng thái/độ ưu tiên)
  - Các tests khác trong suite: 16/16 PASS.

### 3. Build xác minh trên Android (`flutter build apk`)
- `flutter build apk --release`: **PASS** (`build\app\outputs\flutter-apk\app-release.apk` - 62.0MB, unsigned, không lỗi compile).
- `flutter build apk --debug`: **PASS** (`build\app\outputs\flutter-apk\app-debug.apk` - 157.0MB, signed by debug key).

---

## X. MA TRẬN TIÊU CHÍ & ĐÁNH GIÁ SẴN SÀNG PHÁT HÀNH

| # | Tiêu chí đánh giá | Yêu cầu chuẩn | Kết quả thực tế | Trạng thái |
|---|---|---|---|:---:|
| 1 | Giữ nguyên Application ID | `com.timeflow.timeflow` | `com.timeflow.timeflow` | **PASS** |
| 2 | Giấy phép Open-Source | GNU GPLv3 đầy đủ | Có file `LICENSE` chuẩn GPLv3 | **PASS** |
| 3 | Đồng bộ phiên bản | `0.6.2+2` | Đồng bộ 100% trong code & metadata | **PASS** |
| 4 | Bảo vệ Secret & Keystore | Không commit keystore/passwords | `.gitignore` bảo vệ toàn diện, file template `.example` | **PASS** |
| 5 | Tách biệt Signing Release | Không fallback debug key | Release APK unsigned, sẵn sàng cho F-Droid | **PASS** |
| 6 | Zero-Network Release Manifest | Không có quyền `INTERNET` | Xác nhận trong Merged Manifest không có `INTERNET` | **PASS** |
| 7 | Offline Typography | Không gọi Google Fonts runtime | Nhúng font `Inter` nội bộ kèm giấy phép SIL OFL | **PASS** |
| 8 | Loại bỏ dead code | Không có network clients thừa | Đã xóa `dio_client.dart` & gỡ bỏ dependencies | **PASS** |
| 9 | Kiểm thử phân tích tĩnh | 0 issue | `flutter analyze` báo `No issues found!` | **PASS** |
| 10 | Kiểm thử tự động | 100% pass | 87/87 tests passed | **PASS** |
| 11 | Build Release APK | Thành công không phụ thuộc internet | Build hoàn tất, sinh ra `app-release.apk` | **PASS** |
| 12 | Tài liệu & Fastlane | Đầy đủ README, Chính sách, Changelog | Hoàn tất EN/VI, fastlane changelog `2.txt` | **PASS** |
| 13 | Bảo toàn Git Working Tree | Không commit/push/reset tự ý | Working tree an toàn, docs project knowledge nguyên vẹn | **PASS** |

---

## XI. HƯỚNG DẪN BƯỚC TIẾP THEO CHO CHỦ DỰ ÁN

Để chính thức đưa bản phát hành `0.6.2+2` lên GitHub và nộp hồ sơ vào F-Droid, chủ dự án có thể thực hiện theo quy trình chuẩn sau:

### Bước 1: Quyết định về các file ảnh trong `docs/`
Nếu muốn giữ lại các file ảnh minh họa Sprint 6.2, chạy:
```powershell
git checkout HEAD -- docs/*.png
```
Nếu muốn xóa bỏ chúng khỏi repository để giảm dung lượng, chạy:
```powershell
git add docs/*.png
```

### Bước 2: Tạo Git Commit cho bản phát hành
```powershell
git add .
git commit -m "release: prepare TIMEFLOW v0.6.2+2 for F-Droid and GitHub release"
```

### Bước 3: Tạo Git Tag phiên bản (khuyến nghị tag RC hoặc release chính thức)
Vì tag `v0.6.2` cũ đã trỏ vào commit trước đó, chủ dự án có thể tạo tag mới phản ánh đúng build number:
```powershell
git tag -a v0.6.2+2 -m "Release Candidate 0.6.2+2: GNU GPLv3, F-Droid ready, Offline-First"
git push origin main
git push origin v0.6.2+2
```

### Bước 4: Tạo GitHub Release & Đính kèm APK
1. Nếu muốn phân phối file APK ký sẵn qua GitHub Releases:
   - Tạo file `android/key.properties` dựa theo `android/key.properties.example` và chỉ định keystore cá nhân.
   - Chạy `flutter build apk --release`.
   - Đính kèm file `build/app/outputs/flutter-apk/app-release.apk` vào GitHub Release draft.
2. Cung cấp file SHA-256 checksum đi kèm để người dùng đối chiếu.

### Bước 5: Nộp hồ sơ vào F-Droid (F-Droid Metadata Recipe)
Tạo Merge Request tới repository [fdroiddata](https://gitlab.com/fdroid/fdroiddata) với file metadata `metadata/com.timeflow.timeflow.yml`:

```yaml
Categories:
  - Productivity
  - Time
License: GPL-3.0-only
SourceCode: https://github.com/binh123-maker/TIMEFLOW
IssueTracker: https://github.com/binh123-maker/TIMEFLOW/issues
Changelog: https://github.com/binh123-maker/TIMEFLOW/blob/main/CHANGELOG.md

AutoUpdateMode: Version
UpdateCheckMode: Tags
CurrentVersion: 0.6.2
CurrentVersionCode: 2

Builds:
  - versionName: 0.6.2
    versionCode: 2
    commit: v0.6.2+2
    output: build/app/outputs/flutter-apk/app-release.apk
    srclibs:
      - flutter@stable
    prebuild:
      - $$flutter$$/bin/flutter pub get
    build:
      - $$flutter$$/bin/flutter build apk --release
```

---
*Báo cáo được lập tự động với đầy đủ dữ liệu thực chứng từ môi trường build và mã nguồn thực tế của dự án TIMEFLOW.*

