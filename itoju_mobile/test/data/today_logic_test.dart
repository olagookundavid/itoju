import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/today_logic.dart';

void main() {
  group('parseClockMinutes', () {
    test('reads 12 h times', () {
      expect(parseClockMinutes('10:30 PM'), 22 * 60 + 30);
      expect(parseClockMinutes('06:05 AM'), 6 * 60 + 5);
      expect(parseClockMinutes('6:05 am'), 6 * 60 + 5);
    });
    test('12 AM is midnight and 12 PM is noon', () {
      expect(parseClockMinutes('12:00 AM'), 0);
      expect(parseClockMinutes('12:30 AM'), 30);
      expect(parseClockMinutes('12:00 PM'), 12 * 60);
    });
    test('tolerates the narrow no-break space newer ICU data uses', () {
      expect(parseClockMinutes('10:30 PM'), 22 * 60 + 30);
      expect(parseClockMinutes('10:30 PM'), 22 * 60 + 30);
    });
    test('rejects anything else', () {
      for (final s in ['', 'noon', '25:00 PM', '13:00 PM', '0:30 AM', '10:75 PM', '22:30']) {
        expect(parseClockMinutes(s), isNull, reason: s);
      }
    });
  });

  group('sleepMinutes', () {
    test('wraps past midnight', () {
      expect(sleepMinutes('11:00 PM', '06:30 AM'), 7 * 60 + 30);
      expect(sleepMinutes('10:30 PM', '6:30 AM'), 8 * 60);
    });
    test('a same-day nap', () {
      expect(sleepMinutes('01:00 PM', '01:45 PM'), 45);
    });
    test('unreadable or identical times give nothing to show', () {
      expect(sleepMinutes('', '06:30 AM'), isNull);
      expect(sleepMinutes('11:00 PM', 'soon'), isNull);
      expect(sleepMinutes('07:00 AM', '07:00 AM'), isNull);
    });
  });

  test('formatDuration', () {
    expect(formatDuration(450), '7h 30m');
    expect(formatDuration(480), '8h');
    expect(formatDuration(45), '45m');
    expect(formatDuration(0), '0m');
  });

  test('plural', () {
    expect(plural(1, 'meal'), '1 meal');
    expect(plural(3, 'meal'), '3 meals');
    expect(plural(1, 'activity', 'activities'), '1 activity');
    expect(plural(2, 'activity', 'activities'), '2 activities');
  });

  group('computeStreak', () {
    final today = DateTime(2026, 10, 28);
    test('counts consecutive days ending today', () {
      expect(computeStreak({'2026-10-28', '2026-10-27', '2026-10-26'}, today), 3);
    });
    test('stays alive when today is not logged yet but yesterday was', () {
      expect(computeStreak({'2026-10-27', '2026-10-26'}, today), 2);
    });
    test('breaks once a whole day is missed', () {
      expect(computeStreak({'2026-10-26', '2026-10-25'}, today), 0);
      expect(computeStreak({'2026-10-28', '2026-10-26'}, today), 1);
    });
    test('is zero with no history', () {
      expect(computeStreak({}, today), 0);
    });
    test('crosses month and year ends', () {
      expect(computeStreak({'2027-01-02', '2027-01-01', '2026-12-31', '2026-12-30'}, DateTime(2027, 1, 2)), 4);
    });
    test('ignores future dates', () {
      expect(computeStreak({'2026-10-29', '2026-10-28'}, today), 1);
    });
  });

  test('relativeDay', () {
    final today = DateTime(2026, 10, 28);
    expect(relativeDay('2026-10-28', today), 'today');
    expect(relativeDay('2026-10-27', today), 'yesterday');
    expect(relativeDay('2026-10-25', today), '3 days ago');
    expect(relativeDay('2026-09-01', today), '1 Sep');
    expect(relativeDay('garbage', today), 'garbage');
  });
}
