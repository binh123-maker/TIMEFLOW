import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/lockscreen_payload.dart';

/// Contract for communicating between Flutter and Native Lockscreen/Notification
abstract class ILockscreenBridge {
  Future<bool> updateOngoingNotification(LockscreenPayload payload);
  Future<bool> cancelOngoingNotification();
  LockscreenPayload? get lastPayload;
}

/// Production implementation using Flutter MethodChannel
class MethodChannelLockscreenBridge implements ILockscreenBridge {
  static const String channelName = 'com.timeflow.lockscreen/bridge';
  final MethodChannel _channel;
  LockscreenPayload? _lastPayload;

  MethodChannelLockscreenBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  @override
  LockscreenPayload? get lastPayload => _lastPayload;

  @override
  Future<bool> updateOngoingNotification(LockscreenPayload payload) async {
    // Only Android supports Native Ongoing Lockscreen Notification
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    // Deduplication check: Do not invoke native IPC if payload is identical
    if (_lastPayload != null && _lastPayload == payload) {
      return true;
    }

    try {
      final success = await _channel.invokeMethod<bool>(
        'updateLockscreenNotification',
        payload.toJson(),
      );
      if (success == true) {
        _lastPayload = payload;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint(
        'PlatformException in updateOngoingNotification: ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('Unexpected error in updateOngoingNotification: $e');
      return false;
    }
  }

  @override
  Future<bool> cancelOngoingNotification() async {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      final success = await _channel.invokeMethod<bool>(
        'cancelLockscreenNotification',
      );
      _lastPayload = null;
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint(
        'PlatformException in cancelOngoingNotification: ${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('Unexpected error in cancelOngoingNotification: $e');
      return false;
    }
  }
}
