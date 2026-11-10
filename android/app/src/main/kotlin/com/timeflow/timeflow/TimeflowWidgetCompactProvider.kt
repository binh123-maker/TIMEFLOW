package com.timeflow.timeflow

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TimeflowWidgetCompactProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.timeflow_widget_compact)

            val progressText = widgetData.getString("progressText", "0/0") ?: "0/0"
            val hasCurrentTask = widgetData.getBoolean("hasCurrentTask", false)
            val currentTaskTitle = widgetData.getString("currentTaskTitle", "Không có công việc đang diễn ra") ?: "Không có công việc đang diễn ra"
            val currentTaskTime = widgetData.getString("currentTaskTime", "") ?: ""
            val currentTaskPriority = widgetData.getString("currentTaskPriority", "") ?: ""

            val hasNextTask = widgetData.getBoolean("hasNextTask", false)
            val nextTaskTitle = widgetData.getString("nextTaskTitle", "") ?: ""
            val nextTaskTime = widgetData.getString("nextTaskTime", "") ?: ""
            val nextTaskPriority = widgetData.getString("nextTaskPriority", "") ?: ""

            views.setTextViewText(R.id.widget_header_progress, progressText)

            if (hasCurrentTask) {
                views.setTextViewText(R.id.widget_header_title, "TIMEFLOW")
                views.setViewVisibility(R.id.widget_task_content, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                views.setTextViewText(R.id.widget_task_title, currentTaskTitle)

                if (currentTaskTime.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_task_time, View.VISIBLE)
                    views.setTextViewText(R.id.widget_task_time, currentTaskTime)
                } else {
                    views.setViewVisibility(R.id.widget_task_time, View.GONE)
                }

                if (currentTaskPriority.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_task_priority, View.VISIBLE)
                    views.setTextViewText(R.id.widget_task_priority, currentTaskPriority)
                } else {
                    views.setViewVisibility(R.id.widget_task_priority, View.GONE)
                }
            } else if (hasNextTask) {
                // When there is no active task running, compact widget displays the upcoming next task
                views.setTextViewText(R.id.widget_header_title, "TIMEFLOW • TIẾP THEO")
                views.setViewVisibility(R.id.widget_task_content, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                views.setTextViewText(R.id.widget_task_title, nextTaskTitle)

                if (nextTaskTime.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_task_time, View.VISIBLE)
                    views.setTextViewText(R.id.widget_task_time, nextTaskTime)
                } else {
                    views.setViewVisibility(R.id.widget_task_time, View.GONE)
                }

                if (nextTaskPriority.isNotEmpty()) {
                    views.setViewVisibility(R.id.widget_task_priority, View.VISIBLE)
                    views.setTextViewText(R.id.widget_task_priority, nextTaskPriority)
                } else {
                    views.setViewVisibility(R.id.widget_task_priority, View.GONE)
                }
            } else {
                views.setTextViewText(R.id.widget_header_title, "TIMEFLOW")
                views.setViewVisibility(R.id.widget_task_content, View.GONE)
                views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
                views.setTextViewText(R.id.widget_empty_state, "Không có công việc đang diễn ra")
            }

            // Click pending intent launches MainActivity
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_compact_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

