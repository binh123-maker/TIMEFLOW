import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/core/utils/date_formatter.dart';
import 'package:timeflow/features/tasks/domain/entities/task_entity.dart';

void main() {
  group('TIMEFLOW Core Unit Tests', () {
    test('DateFormatter formats header date in Vietnamese correctly', () {
      final testDate = DateTime(2026, 9, 12);
      final formatted = DateFormatter.formatHeaderDate(testDate);
      expect(formatted, contains('Thứ Bảy'));
      expect(formatted, contains('12 tháng 09, 2026'));
    });

    test('TaskEntity status and priority display names in Vietnamese', () {
      final now = DateTime.now();
      final task = TaskEntity(
        id: 'test-1',
        title: 'Thử nghiệm entity',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
      );

      expect(task.status.displayName, equals('Đang làm'));
      expect(task.priority.displayName, equals('Cao'));
    });
  });
}
