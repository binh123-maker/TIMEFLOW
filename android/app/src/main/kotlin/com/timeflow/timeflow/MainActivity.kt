package com.timeflow.timeflow

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        const val LOCKSCREEN_CHANNEL = "com.timeflow.lockscreen/bridge"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCKSCREEN_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateLockscreenNotification" -> {
                    @Suppress("UNCHECKED_CAST")
                    val payload = call.arguments as? Map<String, Any?>
                    val success = LockscreenNotificationManager.updateNotification(context, payload)
                    result.success(success)
                }
                "cancelLockscreenNotification" -> {
                    val success = LockscreenNotificationManager.cancelNotification(context)
                    result.success(success)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
