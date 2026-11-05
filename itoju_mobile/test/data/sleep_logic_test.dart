import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/sleep_logic.dart';

void main() {
  final thu5 = DateTime(2026, 11, 5);

  group('sleepWindow', () {
    test('a night ends on the logged day, bed the evening before', () {
      final w = sleepWindow(thu5, true, '10:00 PM', '6:00 AM')!;
      expect(w.start, DateTime(2026, 11, 4, 22));
      expect(w.end, DateTime(2026, 11, 5, 6));
    });
    test('a night with an after-midnight bedtime stays on the logged day', () {
      final w = sleepWindow(thu5, true, '1:30 AM', '8:00 AM')!;
      expect(w.start, DateTime(2026, 11, 5, 1, 30));
      expect(w.end, DateTime(2026, 11, 5, 8));
    });
    test('a nap starts on the logged day', () {
      final w = sleepWindow(thu5, false, '1:00 PM', '2:30 PM')!;
      expect(w.start, DateTime(2026, 11, 5, 13));
      expect(w.end, DateTime(2026, 11, 5, 14, 30));
    });
    test('unreadable or equal times give no window', () {
      expect(sleepWindow(thu5, true, '', '6:00 AM'), isNull);
      expect(sleepWindow(thu5, true, '6:00 AM', '6:00 AM'), isNull);
    });
  });

  group('sleepFutureProblem', () {
    final morning = DateTime(2026, 11, 5, 8, 57);

    test("last night on Today is fine once you're up", () {
      expect(sleepFutureProblem(thu5, true, '10:00 PM', '6:00 AM', morning),
          isNull);
    });
    test('a wake-up later than now is refused', () {
      expect(sleepFutureProblem(thu5, true, '10:00 PM', '9:30 AM', morning),
          contains("hasn't happened yet"));
    });
    test('a bedtime alone is checked as soon as it is picked', () {
      // Evening bedtime on a night = yesterday evening: already happened.
      expect(sleepFutureProblem(thu5, true, '11:00 PM', '', morning), isNull);
      // A nap starting this afternoon hasn't.
      expect(sleepFutureProblem(thu5, false, '1:00 PM', '', morning),
          contains('bedtime'));
    });
    test('the screenshot case: 9 PM to 11 PM tonight is the future', () {
      final evening = DateTime(2026, 11, 5, 21, 25);
      expect(sleepFutureProblem(thu5, false, '9:00 PM', '11:00 PM', evening),
          isNotNull);
    });
    test('any time on a past day is fine', () {
      expect(
          sleepFutureProblem(
              DateTime(2026, 11, 3), false, '9:00 PM', '11:00 PM', morning),
          isNull);
    });
  });

  group('sleepSaveProblem', () {
    final now = DateTime(2026, 11, 5, 12);
    test('needs both times', () {
      expect(sleepSaveProblem(thu5, true, '10:00 PM', '', now),
          contains('both'));
    });
    test('refuses equal times', () {
      expect(sleepSaveProblem(thu5, true, '6:00 AM', '6:00 AM', now),
          contains('same'));
    });
    test('accepts a finished night', () {
      expect(sleepSaveProblem(thu5, true, '10:00 PM', '6:00 AM', now), isNull);
    });
  });

  test('duration wraps past midnight instead of showing the clock gap', () {
    expect(sleepDurationLabel('9:00 PM', '6:00 AM'), '09h 00m');
    expect(sleepDurationLabel('9:00 PM', '11:00 PM'), '02h 00m');
    expect(sleepDurationLabel('', '6:00 AM'), '00h 00m');
  });
}
