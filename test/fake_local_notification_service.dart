import 'package:timeflow/core/notifications/local_notification_service.dart';

/// Fake implementation of ILocalNotificationService for unit and integration tests
class FakeLocalNotificationService implements ILocalNotificationService {
  final Map<int, Map<String, dynamic>> scheduledReminders = {};
  bool permissionGranted = true;
  String? lastTappedTaskId;

  @override
  Future<void> initialize({
    void Function(String taskId)? onNotificationTap,
  }) async {}

  @override
  Future<bool> requestPermissions() async {
    return permissionGranted;
  }

  @override
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    String? body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) return;
    final id = getDeterministicNotificationId(taskId);
    scheduledReminders[id] = {
      'taskId': taskId,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime,
    };
  }

  @override
  Future<void> cancelTaskReminder(String taskId) async {
    final id = getDeterministicNotificationId(taskId);
    scheduledReminders.remove(id);
  }

  @override
  Future<void> cancelNotificationById(int id) async {
    scheduledReminders.remove(id);
  }

  @override
  Future<void> cancelAllTaskReminders() async {
    scheduledReminders.clear();
  }

  @override
  Future<List<int>> getPendingNotificationIds() async {
    return scheduledReminders.keys.toList();
  }
}
