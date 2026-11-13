# PHẦN 3 – PHÂN TÍCH KIẾN TRÚC PHẦN MỀM (SYSTEM ARCHITECTURE)

**Ngày phân tích:** 12/11/2026  
**Phạm vi kiểm tra:** Toàn bộ `lib/`, `android/`, `test/`

---

## 3.1. Kiến trúc thực tế đang áp dụng

Qua kiểm tra toàn bộ mã nguồn, TIMEFLOW **không** áp dụng Clean Architecture thuần túy đồng đều ở mọi module, mà đang áp dụng mô hình **Feature-First + Clean Architecture (Light) + Repository Pattern**:

1. **Feature-First Organization (`lib/features/`):** Mã nguồn được chia theo từng tính năng nghiệp vụ (`tasks`, `calendar`, `home`, `reminders`, `lockscreen`, `home_widget`, `settings`, `main_layout`, và các module skeleton `focus`, `statistics`, `timeline`, `profile`, `subscription`).
2. **Clean Architecture (Light):**
   - Chỉ module `tasks` có đủ 3 tầng rõ rệt: `domain/` (`TaskEntity`, 5 UseCases), `presentation/` (`TasksScreen`, `TaskFormDialog`, `task_providers.dart`), và dùng chung tầng `data/` ở root (`lib/data/`).
   - Các module `home_widget` và `lockscreen` có `domain/models/` (Payload), `data/services/` (Bridge/Widget service), và `presentation/providers/`.
   - Các module `calendar`, `reminders`, `home`, `settings` không có tầng `domain/` riêng mà đọc trực tiếp `TaskEntity` và UseCases từ `tasks` hoặc gọi `LocalStorage` từ `core/`.
3. **Repository Pattern:** `ITaskRepository` (`lib/data/repositories/task_repository.dart`) định nghĩa hợp đồng trừu tượng; `TaskRepositoryImpl` (`lib/data/repositories/task_repository_impl.dart`) chuyển đổi giữa Drift `Task`/`TasksCompanion` và `TaskEntity`.
4. **Dependency Injection (DI) qua Riverpod:** Toàn bộ dependency (`AppDatabase`, `TaskDao`, `ITaskRepository`, UseCases, `ILocalNotificationService`, `ILockscreenBridge`, `IHomeWidgetService`, `LocalStorage`) đều được cung cấp qua Riverpod `Provider` và có thể override khi test.
5. **Reactive Auto-Sync Listeners:** Trong `TimeFlowApp.build()` (`lib/main.dart`), 3 listener chạy ngầm theo cơ chế phản ứng:
   - `appReminderSyncListenerProvider`
   - `lockscreenAutoSyncListenerProvider`
   - `homeWidgetAutoSyncListenerProvider`
6. **Flutter–Native Communication:** Tách biệt hoàn toàn quyền ghi DB. Chỉ Flutter được phép ghi vào `timeflow.sqlite` (Single Source of Truth); Android Native chỉ nhận dữ liệu đọc (read-only payload) qua `MethodChannel` hoặc `SharedPreferences`.

---

## 3.2. Sơ đồ 1: Tổng quan kiến trúc hệ thống

```mermaid
flowchart LR
    subgraph Presentation["Presentation Layer (lib/features/*/presentation)"]
        Screens["Screens & Widgets\n(Home, Calendar, Tasks, Reminders, Settings)"]
        Providers["Riverpod Providers & Listeners\n(task_providers, calendar_providers,\nhome_widget_providers, lockscreen_providers, reminder_providers)"]
    end

    subgraph Domain["Domain Layer (lib/features/tasks/domain & models)"]
        Entities["TaskEntity, TaskStatus, TaskPriority"]
        UseCases["CreateTask, UpdateTask, DeleteTask,\nToggleTaskCompletion, GetTasks"]
        Payloads["LockscreenPayload, HomeWidgetPayload"]
    end

    subgraph Data["Data & Core Layer (lib/data & lib/core)"]
        Repo["ITaskRepository -> TaskRepositoryImpl"]
        DAO["TaskDao (Drift)"]
        DB[("AppDatabase\ntimeflow.sqlite")]
        Storage["LocalStorage -> SharedPrefsLocalStorage"]
        NotifSvc["ILocalNotificationService -> FlutterLocalNotificationService"]
        LockBridge["ILockscreenBridge -> MethodChannelLockscreenBridge"]
        WidgetSvc["IHomeWidgetService -> HomeWidgetServiceImpl"]
    end

    subgraph Native["Android Native (android/)"]
        AndroidNotif["NotificationManager / AlarmManager"]
        LockNative["MainActivity -> LockscreenNotificationManager"]
        WidgetNative["TimeflowWidgetCompactProvider\nTimeflowWidgetExpandedProvider"]
    end

    Screens <--> Providers
    Providers --> UseCases
    UseCases --> Entities
    UseCases --> Repo
    Repo --> DAO
    DAO <--> DB
    Providers --> Storage
    Providers --> NotifSvc
    Providers --> LockBridge
    Providers --> WidgetSvc
    Providers --> Payloads

    NotifSvc --> AndroidNotif
    LockBridge -->|"MethodChannel"| LockNative
    WidgetSvc -->|"SharedPreferences + Broadcast"| WidgetNative
```

---

## 3.3. Sơ đồ 2: Luồng dữ liệu từ UI đến Database (và phản hồi ngược)

```mermaid
sequenceDiagram
    actor User
    participant UI as TaskFormDialog / TasksScreen
    participant UC as CreateTask / UpdateTask / Toggle
    participant Repo as TaskRepositoryImpl
    participant DAO as TaskDao
    participant DB as SQLite (timeflow.sqlite)
    participant Stream as allTasksStreamProvider

    User->>UI: Nhập task & nhấn Lưu (hoặc tick Checkbox)
    UI->>UC: Gọi UseCase(params)
    UC->>UC: Validate (title không rỗng, start < end, reminder hợp lệ)
    UC->>Repo: createTask(TaskEntity) / updateTask()
    Repo->>Repo: Map TaskEntity -> TasksCompanion
    Repo->>DAO: insertTask / updateTask
    DAO->>DB: INSERT OR REPLACE / UPDATE bảng tasks
    DB-->>DAO: Phát sự kiện bảng thay đổi
    DAO-->>Stream: Stream<List<Task>> mới
    Stream-->>UI: AsyncValue<List<TaskEntity>> cập nhật tự động
```

---

## 3.4. Sơ đồ 3: Luồng dữ liệu từ Flutter sang Android Native (Lockscreen)

```mermaid
sequenceDiagram
    participant Stream as todayTasks / currentTask / nextTask
    participant Provider as lockscreenPayloadProvider
    participant Listener as lockscreenAutoSyncListenerProvider
    participant Bridge as MethodChannelLockscreenBridge
    participant MainAct as MainActivity.kt
    participant Mgr as LockscreenNotificationManager.kt
    participant OS as Android NotificationManager

    Stream-->>Provider: Task thay đổi hoặc App Resumed
    Provider->>Provider: Đóng gói LockscreenPayload
    Provider-->>Listener: Phát payload mới
    Listener->>Bridge: updateOngoingNotification(payload)
    Bridge->>Bridge: Kiểm tra Platform == Android & Deduplication (_lastPayload == payload)
    Bridge->>MainAct: invokeMethod("updateLockscreenNotification", payload.toJson())
    MainAct->>Mgr: updateNotification(context, payloadMap)
    Mgr->>Mgr: Kiểm tra quyền POST_NOTIFICATIONS (Android 13+)
    Mgr->>Mgr: Tạo NotificationChannel (IMPORTANCE_LOW, VISIBILITY_PUBLIC)
    Mgr->>OS: notify(NOTIFICATION_ID = 1001, BigTextStyle, ongoing = true)
```

---

## 3.5. Sơ đồ 4: Luồng hoạt động của Reminder & Startup Reconciliation

```mermaid
sequenceDiagram
    participant App as TimeFlowApp (initState)
    participant Stream as allTasksStreamProvider
    participant Listener as appReminderSyncListenerProvider
    participant Sync as TaskReminderSyncService
    participant Notif as FlutterLocalNotificationService
    participant OS as Android AlarmManager / Receiver

    App->>Notif: initialize() & requestPermissions()
    Stream-->>Listener: Danh sách tasks từ SQLite
    Listener->>Sync: reconcileStartupReminders(tasks)
    Sync->>Notif: getPendingNotificationIds()
    Notif-->>Sync: Danh sách pending IDs hiện có trên OS
    loop Duyệt từng Task trong SQLite
        Sync->>Sync: Tính notifId = getDeterministicNotificationId(task.id) [FNV-1a]
        alt Task chưa xong, chưa hủy, reminderEnabled, thời gian nhắc > now
            Sync->>Notif: scheduleTaskReminder(taskId, title, body, scheduledTime)
            Notif->>OS: zonedSchedule(exactAllowWhileIdle, TZDateTime)
        else Không đủ điều kiện nhưng đang nằm trong pendingIds
            Sync->>Notif: cancelTaskReminder(task.id)
        end
    end
    loop Duyệt pendingIds còn sót (Orphaned)
        opt Không nằm trong validActiveNotificationIds
            Sync->>Notif: cancelNotificationById(pendingId)
        end
    end
```

---

## 3.6. Sơ đồ 5: Luồng đồng bộ Home Screen Widget (bao gồm Time Transition)

```mermaid
sequenceDiagram
    participant Clock as homeWidgetClockProvider
    participant Tasks as todayTasksStreamProvider
    participant Payload as homeWidgetPayloadProvider
    participant Listener as homeWidgetAutoSyncListenerProvider
    participant Svc as HomeWidgetServiceImpl
    participant Prefs as HomeWidgetPreferences.xml
    participant Prov as Compact & Expanded AppWidgetProvider

    Clock->>Clock: Tính nextTransition = min(startTime/endTime > now, nextMinute)
    Clock->>Clock: await Future.delayed(duration) -> yield DateTime.now()
    Clock-->>Payload: Tick tại đúng mốc chuyển task hoặc đầu phút
    Tasks-->>Payload: Hoặc dữ liệu SQLite thay đổi
    Payload->>Payload: Lọc task theo ngày clock & gọi evaluateCurrentAndNextTask()
    Payload-->>Listener: Phát HomeWidgetPayload mới
    Listener->>Svc: updateWidgets(payload)
    Svc->>Svc: Guard Android + Deduplication (_lastPayload == payload)
    Svc->>Prefs: HomeWidget.saveWidgetData(...) (headerDate, progress, current, next, payloadJson)
    Svc->>Prov: HomeWidget.updateWidget(qualifiedAndroidName)
    Prov->>Prefs: Đọc SharedPreferences
    Prov->>Prov: Render RemoteViews (Compact 2x1 & Expanded 4x2) + gắn PendingIntent mở MainActivity
```

