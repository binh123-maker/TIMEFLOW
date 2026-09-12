import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/core/utils/date_formatter.dart';
import 'package:timeflow/data/repositories/task_repository.dart';

void main() {
  group('TIMEFLOW Core Unit Tests', () {
    test('DateFormatter formats header date in Vietnamese correctly', () {
      final testDate = DateTime(2026, 9, 12);
      final formatted = DateFormatter.formatHeaderDate(testDate);
      expect(formatted, contains('Thứ Bảy'));
      expect(formatted, contains('12 tháng 09, 2026'));
    });

    test('MockTaskRepository returns today schedule items', () async {
      final repository = MockTaskRepository();
      final tasks = await repository.getTodayTasks();

      expect(tasks, isNotEmpty);
      expect(tasks.length, equals(4));
    });

    test('MockTaskRepository identifies current in-progress task', () async {
      final repository = MockTaskRepository();
      final currentTask = await repository.getCurrentTask();

      expect(currentTask, isNotNull);
      expect(currentTask?.title, contains('TIMEFLOW'));
    });
  });
}
