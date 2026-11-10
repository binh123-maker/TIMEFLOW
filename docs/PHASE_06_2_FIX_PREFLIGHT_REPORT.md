# PHASE 6.2 FIX PREFLIGHT & ROOT CAUSE INVESTIGATION REPORT
## TIMEFLOW – ANDROID HOME SCREEN WIDGET "CAN'T LOAD WIDGET"

**Date:** 2026-11-09  
**Target Device:** Medium Phone (Android API 36.1 / emulator-5554)  
**Package:** `com.timeflow.timeflow`

---

## 1. INVESTIGATION SUMMARY & LOG ANALYSIS

Using live ADB logcat extracted from `emulator-5554` during AppWidget addition, we identified the exact runtime exception causing `"Can't load widget"`:

```text
11-08 15:02:02.961   875  2118 I AppWidgetServiceImpl: Bound widget 3 to provider ProviderId{user:0, app:10227, cmp:ComponentInfo{com.timeflow.timeflow/com.timeflow.timeflow.TimeflowWidgetCompactProvider}}
11-08 15:02:02.964  1310  1310 I LauncherAppWidgetHostView: App widget created with id: 3
11-08 15:02:02.974   875  1109 D AppWidgetServiceImpl: Trying to notify widget update for package com.timeflow.timeflow with widget id: 3
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: Error inflating AppWidget AppWidgetProviderInfo(UserHandle{0}/ComponentInfo{com.timeflow.timeflow/com.timeflow.timeflow.TimeflowWidgetCompactProvider})
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: android.view.InflateException: Binary XML file line #29 in com.timeflow.timeflow:layout/timeflow_widget_compact: Binary XML file line #29 in com.timeflow.timeflow:layout/timeflow_widget_compact: Error inflating class android.view.View
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: Caused by: android.view.InflateException: Binary XML file line #29 in com.timeflow.timeflow:layout/timeflow_widget_compact: Class not allowed to be inflated android.view.View
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at android.view.LayoutInflater.failNotAllowed(LayoutInflater.java:786)
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at android.view.LayoutInflater.createView(LayoutInflater.java:729)
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at android.view.LayoutInflater.createView(LayoutInflater.java:665)
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at android.view.LayoutInflater.onCreateView(LayoutInflater.java:802)
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at com.android.internal.policy.PhoneLayoutInflater.onCreateView(PhoneLayoutInflater.java:68)
11-08 15:02:02.976  1310  1310 W AppWidgetHostView: 	at android.view.LayoutInflater.createViewFromTag(LayoutInflater.java:893)
```

---

## 2. PREFLIGHT COMPONENT AUDIT TABLE

| Thành phần | Kết quả | Nguyên nhân nếu lỗi |
|---|---|---|
| **AndroidManifest.xml** | **PASS** | Cả hai Provider đã khai báo đúng tên `.TimeflowWidgetCompactProvider`, `.TimeflowWidgetExpandedProvider`, `exported="true"`, intent-filter `APPWIDGET_UPDATE`, và metadata `@xml/timeflow_widget_*_info`. |
| **Compact Provider Kotlin** | **PASS** | Kế thừa `HomeWidgetProvider`, override `onUpdate` với `widgetData: SharedPreferences`, fallback default strings an toàn khi rỗng. |
| **Expanded Provider Kotlin** | **PASS** | Kế thừa `HomeWidgetProvider`, override `onUpdate`, hỗ trợ state empty fallback an toàn. |
| **Widget XML Layouts** | **FAIL** | Sử dụng thẻ `<View>` làm spacer trong cả `timeflow_widget_compact.xml` (line 26-29) và `timeflow_widget_expanded.xml` (line 37-40). Thẻ `<View>` **bị cấm tuyệt đối** trong `RemoteViews`. |
| **Drawable Resources** | **FAIL** (Potential) | `widget_progress_bar.xml` sử dụng thẻ `<clip>` trong `<layer-list>`, dễ gây lỗi render cross-process trên API 31+. Cần chuyển sang `<scale>`. |
| **AppWidgetProviderInfo** | **PASS** | `initialLayout`, `minWidth`, `minHeight`, `resizeMode`, `widgetCategory="home_screen"` chuẩn chỉ. Không nhầm lẫn với keyguard. |
| **SharedPreferences Key/Prefix** | **PASS** | Decompiled bytecode xác nhận `HomeWidgetProvider` và Flutter `home_widget` đều dùng chung file SharedPreferences `"HomeWidgetPreferences"`. |
| **RemoteViews Compatibility** | **FAIL** | Bị từ chối bởi `LayoutInflater.failNotAllowed` vì thẻ `<View>` không thuộc danh sách View được whitelist của `RemoteViews`. |
| **Android Runtime** | **FAIL** (Host JDK) | Máy phát triển có JDK 25 (`25.0.4` / `25.0.1`), Gradle 8.14 Kotlin DSL compiler ném `IllegalArgumentException: 25.0.1` khi build Gradle daemon. |

---

## 3. ROOT CAUSE IDENTIFICATION

1. **Nguyên nhân trực tiếp (Direct Root Cause):**  
   Trong Android `RemoteViews`, hệ điều hành (thông qua Launcher3 / SystemUI) chỉ cho phép một danh sách trắng (whitelist) các lớp View cụ thể:
   - Layouts: `FrameLayout`, `LinearLayout`, `RelativeLayout`, `GridLayout`
   - Widgets: `TextView`, `ImageView`, `ProgressBar`, `Button`, `ImageButton`, `AnalogClock`, `Chronometer`, v.v.
   
   Lớp gốc **`android.view.View` KHÔNG nằm trong danh sách được phép**.
   Khi layout chứa:
   ```xml
   <View
       android:layout_width="0dp"
       android:layout_height="1dp"
       android:layout_weight="1" />
   ```
   Hệ thống gọi `LayoutInflater.failNotAllowed()`, ném ra `InflateException: Class not allowed to be inflated android.view.View`. Launcher lập tức hủy inflate và hiển thị `"Can't load widget"`.

2. **File gây lỗi:**  
   - `android/app/src/main/res/layout/timeflow_widget_compact.xml` (dòng 26)
   - `android/app/src/main/res/layout/timeflow_widget_expanded.xml` (dòng 37)

3. **Phạm vi ảnh hưởng:**  
   Cả Compact Widget và Expanded Widget đều bị lỗi `"Can't load widget"` ngay khi người dùng kéo widget ra màn hình chính, bất kể ứng dụng có dữ liệu hay chưa.

