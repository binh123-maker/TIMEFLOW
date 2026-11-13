# PHẦN 2 – KIỂM KÊ TOÀN BỘ CÔNG NGHỆ (TECH STACK)

**Ngày kiểm kê:** 12/11/2026  
**Nguồn kiểm chứng:** `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/src/main/AndroidManifest.xml`.

---

## Bảng tổng hợp công nghệ thực tế

| Công nghệ / Package | Phiên bản (Lock / Config) | Vai trò | Đang sử dụng ở đâu | Lý do sử dụng |
|---|---|---|---|---|
| **Dart SDK** | `^3.11.4` (`pubspec.yaml`) | Ngôn ngữ lập trình chính | Toàn bộ `lib/`, `test/` | Ngôn ngữ bắt buộc của Flutter, hỗ trợ sound null-safety, async/await, Records |
| **Flutter SDK** | 3.x (Material 3) | UI Framework đa nền tảng | Toàn bộ ứng dụng | Xây dựng giao diện 60fps trên Android & Windows từ 1 codebase |
| **Kotlin** | `2.2.20` (`settings.gradle.kts`), JVM 17 | Ngôn ngữ Android Native | `android/app/src/main/kotlin/.../*.kt` | Viết `MainActivity`, `LockscreenNotificationManager`, 2 `AppWidgetProvider` |
| **XML (Android)** | Android SDK standard | Khai báo Manifest, Widget Layout, Drawables | `AndroidManifest.xml`, `res/layout/`, `res/xml/`, `res/drawable/` | RemoteViews cho AppWidget bắt buộc dùng XML truyền thống của Android |
| **Android Gradle Plugin (AGP)** | `8.11.1` | Công cụ build Android | `android/settings.gradle.kts` | Đóng gói APK/AAB, tích hợp Flutter Gradle Plugin |
| **Gradle Wrapper** | `8.14` (`gradle-8.14-all.zip`) | Hệ thống tự động build Java/Kotlin | `android/gradle/wrapper/gradle-wrapper.properties` | Quản lý dependencies và build pipeline Android |
| **Java / Desugaring** | Java 17 + `desugar_jdk_libs:2.1.4` | Tương thích API Java 8+ trên Android cũ | `android/app/build.gradle.kts` | Bắt buộc bởi `flutter_local_notifications` cho `java.time` |
| **flutter_riverpod** | `^2.5.1` (resolved `2.6.1`) | State Management & Dependency Injection | `lib/main.dart`, `lib/features/*/providers/` | Quản lý Reactive Streams, tách UI khỏi logic, dễ test bằng `overrideWithValue` |
| **go_router** | `^14.2.0` (resolved `14.8.1`) | Điều hướng (Routing) | `lib/core/router/app_router.dart` | Hỗ trợ `StatefulShellRoute.indexedStack` giữ state giữa 4 tab chính |
| **drift** | `^2.18.0` (resolved `2.34.4`) | ORM cho SQLite (Reactive) | `lib/data/database/` | Type-safe SQL, hỗ trợ `Stream.watch()` tự cập nhật UI khi DB đổi |
| **sqlite3_flutter_libs** | `^0.5.24` (resolved `0.5.42`) | Thư viện nhị phân SQLite native | Phụ thuộc runtime của `drift` | Đảm bảo có thư viện SQLite chuẩn trên Android & Windows |
| **drift_dev** & **build_runner** | `2.34.0` / `2.15.1` (dev) | Code Generation cho Drift | Sinh `app_database.g.dart`, `task_dao.g.dart` | Tự sinh code DAO và mapping bảng an toàn kiểu dữ liệu |
| **shared_preferences** | `^2.5.6` (resolved `2.5.6`) | Lưu trữ Key-Value bền vững | `lib/core/storage/local_storage.dart`, `lib/main.dart` | Lưu cấu hình `ThemeMode` bền vững qua các lần mở app |
| **flutter_local_notifications** | `^18.0.1` (resolved `18.0.1`) | Lập lịch thông báo cục bộ | `lib/core/notifications/local_notification_service.dart` | Gọi `zonedSchedule` với `exactAllowWhileIdle` trên Android |
| **timezone** | `^0.9.4` (resolved `0.9.4`) | Xử lý múi giờ cho lịch nhắc | `lib/core/notifications/local_notification_service.dart` | Tạo `TZDateTime` chính xác cho `zonedSchedule` |
| **home_widget** | `^0.10.0` (resolved `0.10.0`) | Cầu nối Flutter ↔ Android Home Widget | `lib/main.dart`, `home_widget_service.dart`, `TimeflowWidget*.kt` | Lưu key-value vào `HomeWidgetPreferences` và gọi `onUpdate` của Widget |
| **intl** | `^0.20.2` (resolved `0.20.2`) | Định dạng ngày/giờ & Localization | `lib/core/utils/date_formatter.dart`, `tasks_screen.dart` | Format ngày/giờ theo chuẩn tiếng Việt (`'vi'`) |
| **google_fonts** | `^6.2.1` (resolved `6.3.3`) | Font chữ Inter | `lib/core/theme/app_theme.dart` | Đồng bộ typography hiện đại cho Light/Dark theme |
| **uuid** | `^4.4.0` (resolved `4.6.0`) | Sinh định danh duy nhất UUID v4 | `lib/features/tasks/domain/usecases/create_task.dart` | Tạo `task.id` duy nhất không trùng lặp offline |
| **path_provider** & **path** | `2.1.6` / `1.9.1` | Lấy thư mục tài liệu & ghép đường dẫn | `lib/data/database/app_database.dart` | Xác định đường dẫn lưu file `timeflow.sqlite` |
| **dio** | `^5.5.0+1` (resolved `5.11.1`) | HTTP Client (Stub) | `lib/core/network/dio_client.dart` | **Mới chỉ cấu hình stub**, chưa gọi API thực tế |
| **flutter_svg** | `^2.0.10+1` (resolved `2.3.0`) | Render ảnh vector SVG | Khai báo trong `pubspec.yaml` | **Chưa thấy file sử dụng** trong `lib/` (chuẩn bị cho UI/icon) |
| **cupertino_icons** | `^1.0.8` | Icon phong cách iOS | Khai báo mặc định trong `pubspec.yaml` | Thư viện icon mặc định của template Flutter |
| **flutter_lints** | `^6.0.0` (resolved `6.0.0`) | Bộ quy tắc phân tích tĩnh | `analysis_options.yaml` | Kiểm tra chất lượng code Dart qua `flutter analyze` |
| **flutter_test** | Flutter SDK | Framework kiểm thử tự động | Toàn bộ thư mục `test/` | Chạy 87 unit/integration tests |

---

## 2.1. Ngôn ngữ lập trình

### Dart (`^3.11.4`)
- **Là gì:** Ngôn ngữ hướng đối tượng, tối ưu cho UI và xử lý bất đồng bộ, biên dịch AOT (máy thật) và JIT (hot reload).
- **Giải quyết vấn đề:** Xây dựng toàn bộ logic nghiệp vụ, giao diện, truy vấn DB và kiểm thử trong một ngôn ngữ duy nhất.
- **Vì sao cần:** Bắt buộc khi phát triển với Flutter; tính năng Records `({TaskEntity? currentTask, TaskEntity? nextTask})` trong `home_widget_providers.dart` giúp trả về cặp kết quả gọn gàng không cần tạo class phụ.
- **Thay thế:** Không thể thay thế trong Flutter (trừ khi bỏ Flutter để viết Android Native thuần bằng Kotlin hoặc React Native bằng TypeScript).
- **Ưu / Nhược trong TIMEFLOW:** Ưu điểm là null-safety chặt chẽ, `Stream`/`Future` rất hợp với Reactive DB. Nhược điểm là không truy cập trực tiếp được Android `RemoteViews` hay `NotificationCompat` nên vẫn phải viết cầu nối sang Kotlin.

### Kotlin (`2.2.20`)
- **Là gì:** Ngôn ngữ chính thức của Google cho phát triển Android Native trên JVM.
- **Giải quyết vấn đề:** Xử lý các API hệ điều hành mà Flutter không tự làm được: tạo `NotificationChannel` với `VISIBILITY_PUBLIC` và `setOngoing(true)`, render `RemoteViews` cho Home Screen Widget.
- **Thay thế:** Java (dài dòng hơn, ít an toàn null hơn).
- **Ưu / Nhược trong TIMEFLOW:** Code ngắn gọn, an toàn (`?`, `?:`), tương thích hoàn toàn với `home_widget` (`HomeWidgetProvider`). Nhược điểm là phải đồng bộ thủ công tên key/field giữa Dart và Kotlin (không có type-safety xuyên biên giới `MethodChannel`).

### XML (Android Layouts & Manifest)
- **Là gì:** Ngôn ngữ đánh dấu dùng để khai báo cấu hình ứng dụng (`AndroidManifest.xml`), thông số widget (`appwidget-provider`), và giao diện widget (`LinearLayout`, `TextView`, `ProgressBar`).
- **Giải quyết vấn đề:** Android `AppWidgetManager` chạy tiến trình riêng (Launcher) và chỉ nhận `RemoteViews` dựng từ layout XML truyền thống (không dùng trực tiếp Jetpack Compose hay Flutter Widget).
- **Thay thế:** Jetpack Glance (Compose-style cho Widget, nhưng phức tạp hơn khi tích hợp vào dự án Flutter không dùng Compose).
- **Ưu / Nhược trong TIMEFLOW:** Nhẹ, ổn định, ít lỗi tương thích launcher. Nhược điểm là dễ gặp lỗi crash launcher nếu dùng View không được `RemoteViews` hỗ trợ (dự án từng gặp lỗi dùng `<View>` thay vì `<TextView>` và `<clip>` thay vì `<scale>` ở Sprint 6.2, đã sửa).

---

## 2.2. Framework và Nền tảng

- **Flutter & Material Design 3:** Cung cấp hệ thống theme `useMaterial3: true` tại `lib/core/theme/app_theme.dart` với Light/Dark theme đầy đủ, `NavigationBar` cho mobile và `NavigationRail` cho desktop (`kMobileBreakpoint = 768.0`).
- **Android SDK & Native:** Sử dụng `flutter.compileSdkVersion`, `flutter.minSdkVersion`, `flutter.targetSdkVersion` (kế thừa từ Flutter tool). Đã bật `isCoreLibraryDesugaringEnabled = true` với `desugar_jdk_libs:2.1.4` để chạy các API thời gian của `flutter_local_notifications` trên các bản Android cũ.

---

## 2.3. Quản lý trạng thái và Điều hướng

### Riverpod (`flutter_riverpod: ^2.5.1`)
- **Là gì:** Thư viện State Management & Dependency Injection an toàn tại compile-time, không phụ thuộc `BuildContext`.
- **Giải quyết vấn đề:** Kết nối luồng dữ liệu từ SQLite (`StreamProvider`) xuống các màn hình UI và các service nền (`appReminderSyncListenerProvider`, `lockscreenAutoSyncListenerProvider`, `homeWidgetAutoSyncListenerProvider`) một cách tự động.
- **Thay thế:** BLoC/Cubit, Provider cũ, GetX.
- **Ưu / Nhược trong TIMEFLOW:** Rất mạnh khi kết hợp với Drift Stream và cực kỳ dễ viết Unit Test nhờ `ProviderContainer(overrides: [...])`. Nhược điểm là nếu không cẩn thận với vòng đời provider (`ref.watch` vs `ref.read`), dễ tạo ra provider tính toán tĩnh theo `DateTime.now()` mà không tự cập nhật theo thời gian (ví dụ `currentTaskStreamProvider` trong `task_providers.dart`).

### GoRouter (`go_router: ^14.2.0`)
- **Là gì:** Thư viện điều hướng khai báo (declarative routing) chính thức được khuyến nghị cho Flutter.
- **Giải quyết vấn đề:** Quản lý 4 nhánh điều hướng chính (`/home`, `/calendar`, `/tasks`, `/statistics`) bằng `StatefulShellRoute.indexedStack` (giữ nguyên trạng thái scroll/input khi chuyển tab) và các route phụ (`/settings`, `/reminders`, `/focus`, `/timeline`, `/profile`, `/subscription`). Cho phép điều hướng từ ngoài `BuildContext` khi nhấn vào thông báo (`appRouter.go('/tasks')` trong `main.dart`).
- **Thay thế:** `Navigator 1.0`, `auto_route`.

---

## 2.4. Database và Lưu trữ

### Drift (`^2.18.0`) + SQLite (`sqlite3_flutter_libs`)
- **Là gì:** Thư viện ORM Reactive viết bằng Dart cho SQLite.
- **Giải quyết vấn đề:** Lưu trữ bảng `Tasks` cục bộ, hỗ trợ truy vấn phản ứng (`watchAllTasks()`) và nâng cấp cấu trúc bảng an toàn (`MigrationStrategy` từ v1 lên v2).
- **Thay thế:** `sqflite` (viết SQL thuần, không tự sinh reactive stream), `Hive` / `Isar` (NoSQL, kém mạnh hơn trong truy vấn quan hệ/migration có cấu trúc).
- **Ưu / Nhược trong TIMEFLOW:** Đáng tin cậy, có thể test 100% bằng `NativeDatabase.memory()` trong RAM mà không cần thiết bị thật. Nhược điểm: cần chạy `build_runner` mỗi khi sửa schema bảng.

### SharedPreferences (`^2.5.6`)
- **Là gì:** Cơ chế lưu cặp Key-Value đơn giản xuống file XML (Android) / Registry hoặc file (Windows).
- **Giải quyết vấn đề:** Lưu `timeflow_theme_mode` bền vững qua `SharedPrefsLocalStorage` (`lib/core/storage/local_storage.dart`), đồng thời là kho trung gian `HomeWidgetPreferences.xml` để gói `home_widget` chia sẻ dữ liệu từ Flutter sang Kotlin `AppWidgetProvider`.
- **Thay thế:** `flutter_secure_storage` (nếu cần mã hóa), hoặc bảng `Settings` trong Drift SQLite.

---

## 2.5. Notification và Widget

- **`flutter_local_notifications` (`^18.0.1`) + `timezone` (`^0.9.4`):** Giải quyết bài toán hẹn giờ nhắc nhở chính xác từng phút ngay cả khi app đã tắt hoặc máy ở chế độ Doze (`AndroidScheduleMode.exactAllowWhileIdle`), kèm `ScheduledNotificationBootReceiver` trong `AndroidManifest.xml` để hệ thống Android khôi phục alarm sau khi khởi động lại.
- **`home_widget` (`^0.10.0`):** Gói trung gian ghi dữ liệu vào `SharedPreferences` của Android (`HomeWidget.saveWidgetData`) và gửi broadcast `APPWIDGET_UPDATE` (`HomeWidget.updateWidget`) đến `TimeflowWidgetCompactProvider` và `TimeflowWidgetExpandedProvider`.
- **`MethodChannel` (`com.timeflow.lockscreen/bridge`):** Kênh giao tiếp trực tiếp giữa `MethodChannelLockscreenBridge` (Dart) và `MainActivity.kt` (Kotlin) để gọi `LockscreenNotificationManager.updateNotification()` và `cancelNotification()`. Lý do phải tự viết `MethodChannel` thay vì dùng `flutter_local_notifications` cho Ongoing Notification: cần kiểm soát trực tiếp `NotificationChannel` (`IMPORTANCE_LOW`, `VISIBILITY_PUBLIC`), `BigTextStyle`, `setOngoing(true)`, và action button tùy biến.

---

## 2.6. Testing và Build

- **`flutter_test`:** Đã xây dựng 8 file test với tổng 87 test cases (Unit test, Provider test, In-memory SQLite integration test). Chưa có `WidgetTester` test cho các màn hình UI chính.
- **`flutter_lints` (`^6.0.0`):** Kiểm tra lỗi cú pháp, style, unused imports qua `flutter analyze`.
- **Gradle (`8.14`) & APK Build:** Biên dịch mã nguồn Dart + Kotlin + XML thành `app-debug.apk`. Lưu ý: `android/app/build.gradle.kts` hiện vẫn dùng `signingConfig = signingConfigs.getByName("debug")` cho bản `release`, chưa cấu hình keystore phát hành thật.

