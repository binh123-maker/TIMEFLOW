package com.timeflow.timeflow

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat

object LockscreenNotificationManager {
    const val CHANNEL_ID = "timeflow_lockscreen_status"
    const val CHANNEL_NAME = "Lịch trình thường trực TIMEFLOW"
    const val CHANNEL_DESC = "Hiển thị công việc hiện tại và tiếp theo trên màn hình khóa và thanh thông báo"
    const val NOTIFICATION_ID = 1001

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            val existing = notificationManager?.getNotificationChannel(CHANNEL_ID)
            if (existing == null) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_LOW // Low importance = silent, no intrusive popup or ding on update
                ).apply {
                    description = CHANNEL_DESC
                    setShowBadge(false)
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                }
                notificationManager?.createNotificationChannel(channel)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun updateNotification(context: Context, payloadMap: Map<String, Any?>?): Boolean {
        if (payloadMap == null) return false

        // Check POST_NOTIFICATIONS permission on Android 13+ (API 33+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val hasPermission = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!hasPermission) {
                return false
            }
        }

        createNotificationChannel(context)

        val currentTask = payloadMap["currentTask"] as? Map<String, Any?>
        val nextTask = payloadMap["nextTask"] as? Map<String, Any?>
        val totalCount = (payloadMap["totalTasksToday"] as? Number)?.toInt() ?: 0
        val completedCount = (payloadMap["completedTasksToday"] as? Number)?.toInt() ?: 0
        val headerDate = payloadMap["headerDate"] as? String ?: ""

        val currentTitle = currentTask?.get("title") as? String
        val currentTime = currentTask?.get("timeRange") as? String
        val currentPriority = currentTask?.get("priority") as? String

        val nextTitle = nextTask?.get("title") as? String
        val nextTime = nextTask?.get("timeRange") as? String
        val nextPriority = nextTask?.get("priority") as? String

        // Construct Content Title
        val contentTitle = if (!currentTitle.isNullOrBlank()) {
            "Đang làm: $currentTitle"
        } else {
            "TIMEFLOW: Không có việc đang làm"
        }

        // Construct Content Text
        val contentText = if (!nextTitle.isNullOrBlank()) {
            val timePart = if (!nextTime.isNullOrBlank()) " ($nextTime)" else ""
            "Kế tiếp: $nextTitle$timePart"
        } else {
            "Tiến độ: $completedCount/$totalCount hoàn thành"
        }

        // Construct Multi-line BigTextStyle summary for lockscreen expansion
        val bigTextBuilder = StringBuilder()
        if (!currentTitle.isNullOrBlank()) {
            val timeStr = if (!currentTime.isNullOrBlank()) " [$currentTime]" else ""
            val priorityStr = if (!currentPriority.isNullOrBlank()) " • $currentPriority" else ""
            bigTextBuilder.append("📌 ĐANG LÀM: $currentTitle$timeStr$priorityStr\n")
        } else {
            bigTextBuilder.append("📌 Không có việc đang diễn ra\n")
        }

        if (!nextTitle.isNullOrBlank()) {
            val timeStr = if (!nextTime.isNullOrBlank()) " [$nextTime]" else ""
            val priorityStr = if (!nextPriority.isNullOrBlank()) " • $nextPriority" else ""
            bigTextBuilder.append("⏳ KẾ TIẾP: $nextTitle$timeStr$priorityStr\n")
        } else {
            bigTextBuilder.append("⏳ Không có việc tiếp theo\n")
        }

        val datePrefix = if (headerDate.isNotBlank()) "$headerDate • " else ""
        bigTextBuilder.append("📊 $datePrefix$completedCount/$totalCount hoàn thành")

        // Intent to launch/bring to front TimeFlow MainActivity
        val openIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(context, 0, openIntent, flags)

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(contentTitle)
            .setContentText(contentText)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigTextBuilder.toString()))
            .setOngoing(true) // Persistent ongoing notification
            .setAutoCancel(false)
            .setContentIntent(pendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // Visible on lockscreen
            .setPriority(NotificationCompat.PRIORITY_LOW) // Silent
            .addAction(R.mipmap.ic_launcher, "Mở TIMEFLOW", pendingIntent)

        try {
            val notificationManagerCompat = NotificationManagerCompat.from(context)
            notificationManagerCompat.notify(NOTIFICATION_ID, builder.build())
            return true
        } catch (e: SecurityException) {
            // Permission revoked at runtime
            return false
        } catch (e: Exception) {
            return false
        }
    }

    fun cancelNotification(context: Context): Boolean {
        return try {
            val notificationManagerCompat = NotificationManagerCompat.from(context)
            notificationManagerCompat.cancel(NOTIFICATION_ID)
            true
        } catch (e: Exception) {
            false
        }
    }
}

