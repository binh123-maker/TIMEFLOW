/// Standardized Reminder Offsets for TIMEFLOW
enum ReminderOffset {
  none,
  atTime,
  min5,
  min10,
  min15,
  min30,
  hour1,
  day1;

  bool get isEnabled => this != ReminderOffset.none;

  int get minutes {
    switch (this) {
      case ReminderOffset.none:
        return 0;
      case ReminderOffset.atTime:
        return 0;
      case ReminderOffset.min5:
        return 5;
      case ReminderOffset.min10:
        return 10;
      case ReminderOffset.min15:
        return 15;
      case ReminderOffset.min30:
        return 30;
      case ReminderOffset.hour1:
        return 60;
      case ReminderOffset.day1:
        return 1440;
    }
  }

  String get displayName {
    switch (this) {
      case ReminderOffset.none:
        return 'Không nhắc';
      case ReminderOffset.atTime:
        return 'Đúng giờ';
      case ReminderOffset.min5:
        return '5 phút trước';
      case ReminderOffset.min10:
        return '10 phút trước';
      case ReminderOffset.min15:
        return '15 phút trước';
      case ReminderOffset.min30:
        return '30 phút trước';
      case ReminderOffset.hour1:
        return '1 giờ trước';
      case ReminderOffset.day1:
        return '1 ngày trước';
    }
  }

  static ReminderOffset fromValues({
    required bool enabled,
    required int minutesBefore,
  }) {
    if (!enabled) return ReminderOffset.none;
    switch (minutesBefore) {
      case 0:
        return ReminderOffset.atTime;
      case 5:
        return ReminderOffset.min5;
      case 10:
        return ReminderOffset.min10;
      case 15:
        return ReminderOffset.min15;
      case 30:
        return ReminderOffset.min30;
      case 60:
        return ReminderOffset.hour1;
      case 1440:
        return ReminderOffset.day1;
      default:
        return ReminderOffset.atTime;
    }
  }
}
