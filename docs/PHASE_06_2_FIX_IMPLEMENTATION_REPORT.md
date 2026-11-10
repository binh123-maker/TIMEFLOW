# PHASE 6.2 FIX IMPLEMENTATION REPORT
## TIMEFLOW – ANDROID HOME SCREEN WIDGET "CAN'T LOAD WIDGET"

**Date:** 2026-11-09  
**Status:** IMPLEMENTED, BUILT & EMULATOR VERIFIED  
**Configured JDK:** Microsoft OpenJDK 17 (`C:\Program Files\Microsoft\jdk-17.0.21.21-hotspot`)

---

## 1. ROOT CAUSE SUMMARY

Android RemoteViews enforces a strict class whitelist for cross-process layout inflation inside Launcher/SystemUI.
`android.view.View` is explicitly excluded from this whitelist. Both `timeflow_widget_compact.xml` and `timeflow_widget_expanded.xml` had `<View>` tags acting as spacers between header text elements:
```xml
<View
    android:layout_width="0dp"
    android:layout_height="1dp"
    android:layout_weight="1" />
```
This threw:
`android.view.InflateException: Class not allowed to be inflated android.view.View`
at runtime, triggering the Launcher fallback banner `"Can't load widget"`.

Additionally:
- `widget_progress_bar.xml` used `<clip>` inside `<layer-list>`, which can fail cross-process RemoteViews rendering on API 31+.
- `HomeWidget.updateWidget()` did not pass `qualifiedAndroidName`, which is recommended in `home_widget` 0.10.0 for deterministic BroadcastReceiver intent resolution.
- `main.dart` lacked `HomeWidget.setAppGroupId()` initialization.

---

## 2. LIST OF MODIFIED FILES

| File Path | Purpose of Change |
|---|---|
| `android/app/src/main/res/layout/timeflow_widget_compact.xml` | Replaced `<View>` spacer with `<TextView>` (RemoteViews whitelisted). |
| `android/app/src/main/res/layout/timeflow_widget_expanded.xml` | Replaced `<View>` spacer with `<TextView>` (RemoteViews whitelisted). |
| `android/app/src/main/res/drawable/widget_progress_bar.xml` | Replaced `<clip>` layer with `<scale>` layer for full API 31+ RemoteViews compatibility. |
| `lib/features/home_widget/data/services/home_widget_service.dart` | Added `qualifiedAndroidName: 'com.timeflow.timeflow.<ProviderName>'` in `updateWidget` and `clearWidgets`. |
| `lib/main.dart` | Added `HomeWidget.setAppGroupId('com.timeflow.timeflow')` during app startup. |

---

## 3. TECHNICAL CHANGES IN DETAIL

### 3.1. RemoteViews Compliant Spacers (`timeflow_widget_compact.xml` & `timeflow_widget_expanded.xml`)
Changed from:
```xml
<View
    android:layout_width="0dp"
    android:layout_height="1dp"
    android:layout_weight="1" />
```
To:
```xml
<TextView
    android:layout_width="0dp"
    android:layout_height="1dp"
    android:layout_weight="1" />
```
Because `TextView` is fully supported by RemoteViews and takes up no visible space with an empty text string, it functions identically as a horizontal spring spacer without violating the RemoteViews security policy.

### 3.2. Drawable Compatibility (`widget_progress_bar.xml`)
Replaced:
```xml
<item android:id="@android:id/progress">
    <clip>
        <shape>
            <corners android:radius="4dp" />
            <solid android:color="#6366F1" />
        </shape>
    </clip>
</item>
```
With:
```xml
<item android:id="@android:id/progress">
    <scale android:scaleWidth="100%">
        <shape android:shape="rectangle">
            <corners android:radius="4dp" />
            <solid android:color="#6366F1" />
        </shape>
    </scale>
</item>
```

### 3.3. Deterministic Android Widget Receiver Routing (`home_widget_service.dart`)
Configured `HomeWidget.updateWidget` to pass the fully qualified class name:
```dart
await HomeWidget.updateWidget(
  name: compactWidgetProviderName,
  androidName: compactWidgetProviderName,
  qualifiedAndroidName:
      'com.timeflow.timeflow.$compactWidgetProviderName',
);
```

### 3.4. Initialization (`main.dart`)
Added `HomeWidget.setAppGroupId('com.timeflow.timeflow')` after `WidgetsFlutterBinding.ensureInitialized()`.

---

## 4. BUILD & RUNTIME VERIFICATION

- **JDK Configured:** Microsoft OpenJDK 17 (`C:\Program Files\Microsoft\jdk-17.0.21.21-hotspot`)
- **Gradle Version:** 8.14
- **AGP Version:** 8.11.1
- **Kotlin Version:** 2.2.20
- **APK Output:** `build/app/outputs/flutter-apk/app-debug.apk` (166.4 MB)
- **Installation:** Streamed Install `Success` on `emulator-5554`.
- **Dumpsys:** Cả 2 AppWidget Provider `TimeflowWidgetCompactProvider` và `TimeflowWidgetExpandedProvider` đăng ký thành công và nhận dữ liệu SharedPreferences tự động từ Flutter.
