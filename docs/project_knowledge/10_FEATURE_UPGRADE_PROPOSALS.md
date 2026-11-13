# PHẦN 10 – ĐỀ XUẤT TÍNH NĂNG NÂNG CẤP (FEATURE UPGRADE PROPOSALS)

**Ngày phân tích:** 12/11/2026  
**Nguyên tắc đề xuất:** Chỉ đề xuất các tính năng mang lại giá trị thực tế cho định vị **Local-First Time-blocking & Lockscreen To-do App**, phân biệt rõ Offline vs Backend/AI.

---

## Bảng đánh giá các nhóm tính năng nâng cấp

| Nhóm | Tính năng | Giá trị | Độ khó | Công nghệ / Quyền cần thêm | Phụ thuộc | Hạ tầng | Ưu tiên |
|---|---|---|---|---|---|---|---|
| **A. Task** | Tags / Categories + Màu sắc | Cao | Thấp | Bảng `Categories` (Drift Migration v3) | Schema DB | **100% Offline** | **P1** |
| **A. Task** | Subtasks / Checklist | Cao | Trung bình | Bảng `Subtasks` (FK `task_id`) | Schema DB | **100% Offline** | **P1** |
| **A. Task** | Recurring Tasks (Lặp lại hằng ngày/tuần) | Rất cao | Trung bình–Cao | Rule lặp (RRULE đơn giản) + sinh instance | `TaskDao`, Reminder | **100% Offline** | **P1** |
| **A. Task** | Pomodoro Timer (hoàn thiện `FocusScreen`) | Cao | Trung bình | Timer + Foreground notification khi đếm | `FocusScreen` (đã có route) | **100% Offline** | **P2** |
| **B. Calendar** | Weekly View & Agenda View | Cao | Trung bình | UI `PageView` / Timeline dọc theo giờ | `calendar_providers.dart` | **100% Offline** | **P2** |
| **B. Calendar** | Phát hiện xung đột lịch trình (Time Conflict Warning) | Cao | Thấp | Logic kiểm tra giao khoảng `[start, end)` trong `TaskFormDialog` | `CreateTask`, `UpdateTask` | **100% Offline** | **P1** |
| **C. Reminder** | Snooze (Hoãn 5/10/15 phút) từ Notification | Rất cao | Trung bình | `AndroidNotificationAction` + BroadcastReceiver/Callback | `local_notification_service.dart` | **100% Offline** | **P1** |
| **C. Reminder** | Nhắc việc theo địa điểm (Geofencing) | Thấp–TB | Cao | `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, Google Play Services | Chính sách quyền nhạy cảm | **Android Permission + GPS** | **P4 (Không khuyến nghị sớm)** |
| **D. Lockscreen & Widget** | Quick Action "Hoàn thành" trên Ongoing Notification & Widget | Rất cao | Trung bình | `PendingIntent` + BroadcastReceiver gọi Flutter/Service | `LockscreenNotificationManager.kt` | **100% Offline** | **P1** |
| **D. Lockscreen & Widget** | Permission Onboarding (Giải thích trước khi xin quyền) | Rất cao | Thấp | UI Screen + `SharedPreferences` (`keyIsFirstLaunch`) | `main.dart` | **100% Offline** | **P0 (Làm ngay)** |
| **D. Lockscreen & Widget** | Full-screen Reminder (`USE_FULL_SCREEN_INTENT`) | Trung bình | Cao | Permission Android 14+, Activity `showWhenLocked` | Chính sách Google Play | **Android Permission** | **P3** |
| **E. Trải nghiệm** | Statistics Dashboard (hoàn thiện `StatisticsScreen`) | Cao | Trung bình | Truy vấn SQLite tổng hợp + `fl_chart` (hoặc CustomPainter) | Tab 4 đang là Skeleton | **100% Offline** | **P1** |
| **F. Công nghệ** | Backup & Restore thủ công (Export/Import JSON) | Rất cao | Thấp | `file_picker` / `share_plus`, JSON serialization | `TaskDao` | **100% Offline** | **P1** |
| **F. Công nghệ** | Cloud Sync & Auth (Google Sign-In + Backend) | Trung bình | Rất cao | Firebase / Supabase hoặc REST API (`dio`), Conflict resolution | `AuthService`, `SyncService` | **Cần Backend + Chi phí vận hành** | **P3 (Sau khi ổn định Offline)** |
| **G. AI** | AI Task Assistant / Gợi ý lịch trình | Thấp–TB | Cao | LLM API (Gemini API) + API Key + Internet | Cần mạng, tốn chi phí token | **Cần External API + Chi phí** | **P4 (Chưa cần thiết)** |

---

## Khuyến nghị kiến trúc về Backend & AI

- **Không nên tích hợp Backend/Cloud Sync ngay lập tức:** TIMEFLOW đang định vị là ứng dụng **Local-First**. Việc thêm Backend sẽ kéo theo bài toán Authentication, đồng bộ xung đột offline-online (CRDT/Last-write-wins), bảo mật dữ liệu và chi phí duy trì server. Thay vào đó, **Export/Import file JSON** giải quyết 80% nhu cầu sao lưu dữ liệu với 0 đồng chi phí vận hành.
- **Không nên tích hợp AI khi phần lõi chưa hoàn thiện:** Các tab `StatisticsScreen` và `FocusScreen` vẫn đang là placeholder, và người dùng cần **Recurring Tasks**, **Snooze**, **Quick Complete trên Widget/Lockscreen** hơn nhiều so với chatbot AI.

