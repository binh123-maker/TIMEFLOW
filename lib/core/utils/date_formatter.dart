import 'package:intl/intl.dart';

/// Utilities for Date and Time formatting in Vietnamese
class DateFormatter {
  DateFormatter._();

  static final DateFormat _timeFormat = DateFormat('HH:mm', 'vi');

  /// Formats date into Vietnamese readable string (e.g. "Thứ Bảy, 12/09/2026")
  static String formatHeaderDate(DateTime date) {
    final String dayName = _getDayNameInVietnamese(date.weekday);
    final String dayStr = date.day.toString().padLeft(2, '0');
    final String monthStr = date.month.toString().padLeft(2, '0');
    return '$dayName, $dayStr tháng $monthStr, ${date.year}';
  }

  /// Formats time range (e.g. "09:00 - 10:30")
  static String formatTimeRange(DateTime start, DateTime end) {
    final String startStr = _timeFormat.format(start);
    final String endStr = _timeFormat.format(end);
    return '$startStr - $endStr';
  }

  /// Formats single time (e.g. "14:30")
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  static String _getDayNameInVietnamese(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }
}
