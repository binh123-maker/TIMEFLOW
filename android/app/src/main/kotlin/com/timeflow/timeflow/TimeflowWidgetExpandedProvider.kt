package com.timeflow.timeflow

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TimeflowWidgetExpandedProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.timeflow_widget_expanded)

            val headerDate = widgetData.getString("headerDate", "Hôm nay") ?: "Hôm nay"
            val progressText = widgetData.getString("progressText", "0/0") ?: "0/0"
            val progressPercent = widgetData.getInt("progressPercent", 0)

            // Current task
            val hasCurrentTask = widgetData.getBoolean("hasCurrentTask", false)
            val currentTaskTitle = widgetData.getString("currentTaskTitle", "Không có công việc đang diễn ra") ?: "Không có công việc đang diễn ra"
            val currentTaskTime = widgetData.getString("currentTaskTime", "") ?: ""
            val currentTaskPriority = widgetData.getString("currentTaskPriority", "") ?: ""

            // Next task
            val hasNextTask = widgetData.getBoolean("hasNextTask", false)
            val nextTaskTitle = widgetData.getString("nextTaskTitle", "Không có công việc tiếp theo") ?: "Không có công việc tiếp theo"
            val nextTaskTime = widgetData.getString("nextTaskTime", "") ?: ""
            val nextTaskPriority = widgetData.getString("nextTaskPriority", "") ?: ""

            // Header & progress
            views.setTextViewText(R.id.widget_date_text, headerDate)
            views.setTextViewText(R.id.widget_progress_counter, "$progressText hoàn thành")
            views.setProgressBar(R.id.widget_progress_bar, 100, progressPercent, false)

            // Current Task Box
            if (hasCurrentTask) {
                views.setViewVisibility(R.id.widget_current_task_info, View.VISIBLE)
                views.setViewVisibility(R.id.widget_current_task_empty, View.GONE)
                views.setTextViewText(R.id.widget_current_title, currentTaskTitle)

                if (currentTaskTime.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_current_time, View.VISIBLE)
                    views.setTextViewText(R.id.widget_current_time, currentTaskTime)
                } else {
                    views.setViewVisibility(R.id.widget_current_time, View.GONE)
                }

                if (currentTaskPriority.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_current_priority, View.VISIBLE)
                    views.setTextViewText(R.id.widget_current_priority, currentTaskPriority)
                } else {
                    views.setViewVisibility(R.id.widget_current_priority, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.widget_current_task_info, View.GONE)
                views.setViewVisibility(R.id.widget_current_task_empty, View.VISIBLE)
            }

            // Next Task Box
            if (hasNextTask) {
                views.setViewVisibility(R.id.widget_next_task_info, View.VISIBLE)
                views.setViewVisibility(R.id.widget_next_task_empty, View.GONE)
                views.setTextViewText(R.id.widget_next_title, nextTaskTitle)

                if (nextTaskTime.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_next_time, View.VISIBLE)
                    views.setTextViewText(R.id.widget_next_time, nextTaskTime)
                } else {
                    views.setViewVisibility(R.id.widget_next_time, View.GONE)
                }

                if (nextTaskPriority.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_next_priority, View.VISIBLE)
                    views.setTextViewText(R.id.widget_next_priority, nextTaskPriority)
                } else {
                    views.setViewVisibility(R.id.widget_next_priority, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.widget_next_task_info, View.GONE)
                views.setViewVisibility(R.id.widget_next_task_empty, View.VISIBLE)
            }

            // PendingIntent handlers to open app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_expanded_root, pendingIntent)
            views.setOnClickPendingIntent(R.id.widget_open_app_btn, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

