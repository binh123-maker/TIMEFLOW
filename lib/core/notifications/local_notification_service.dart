import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Deterministic Notification ID generator using 32-bit FNV-1a hash algorithm
int getDeterministicNotificationId(String taskId) {
  int hash = 0x811c9dc5; // FNV offset basis
  for (int i = 0; i < taskId.length; i++) {
    hash ^= taskId.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF; // FNV prime
  }
  return hash & 0x7FFFFFFF; // 31-bit positive int
}

/// Core Local Notification Service Abstraction
abstract class ILocalNotificationService {
  Future<void> initialize({void Function(String taskId)? onNotificationTap});
  Future<bool> requestPermissions();
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    String? body,
    required DateTime scheduledTime,
  });
  Future<void> cancelTaskReminder(String taskId);
  Future<void> cancelNotificationById(int id);
  Future<void> cancelAllTaskReminders();
  Future<List<int>> getPendingNotificationIds();
}

/// Production implementation using flutter_local_notifications & timezone
class FlutterLocalNotificationService implements ILocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  static const String channelId = 'timeflow_reminders';
  static const String channelName = 'Nhắc nhở công việc TIMEFLOW';
  static const String channelDescription =
      'Thông báo nhắc nhở lịch trình và công việc từ TIMEFLOW';

  FlutterLocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize({
    void Function(String taskId)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings();
      const linuxSettings = LinuxInitializationSettings(
        defaultActionName: 'Open',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!);
              if (data is Map && data.containsKey('taskId')) {
                final taskId = data['taskId'] as String;
                onNotificationTap?.call(taskId);
              }
            } catch (_) {}
          }
        },
      );

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.high,
            ),
          );
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Local Notification init warning: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          final granted = await androidPlugin.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
    return true;
  }

  @override
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    String? body,
    required DateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      return; // Do not schedule past reminders
    }

    final notifId = getDeterministicNotificationId(taskId);
    final payload = jsonEncode({'taskId': taskId});

    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const darwinDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        notifId,
        'TIMEFLOW: $title',
        body ?? 'Sắp đến giờ thực hiện công việc',
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling task reminder [$taskId]: $e');
    }
  }

  @override
  Future<void> cancelTaskReminder(String taskId) async {
    final notifId = getDeterministicNotificationId(taskId);
    await cancelNotificationById(notifId);
  }

  @override
  Future<void> cancelNotificationById(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Error cancelling notification id [$id]: $e');
    }
  }

  @override
  Future<void> cancelAllTaskReminders() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }

  @override
  Future<List<int>> getPendingNotificationIds() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.map((p) => p.id).toList();
    } catch (e) {
      debugPrint('Error fetching pending notifications: $e');
      return [];
    }
  }
}
