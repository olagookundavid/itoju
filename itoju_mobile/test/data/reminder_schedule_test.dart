import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

MedReminderModel rem(String id,
        {String name = 'Metformin',
        int days = kAllDays,
        List<String> times = const ['08:00'],
        bool enabled = true}) =>
    MedReminderModel(id: id, name: name, days: days, times: times, enabled: enabled);

void main() {
  tzdata.initializeTimeZones(); // synchronous; the groups below read locations eagerly

  group('day mask', () {
    test('bits map Monday..Sunday to 1..64', () {
      expect(ReminderDays.bit(DateTime.monday), 1);
      expect(ReminderDays.bit(DateTime.wednesday), 4);
      expect(ReminderDays.bit(DateTime.sunday), 64);
      expect(kAllDays, 127);
    });

    test('toggle adds and removes a day', () {
      var m = 0;
      m = ReminderDays.toggle(m, DateTime.friday);
      expect(ReminderDays.has(m, DateTime.friday), isTrue);
      expect(ReminderDays.has(m, DateTime.thursday), isFalse);
      m = ReminderDays.toggle(m, DateTime.friday);
      expect(m, 0);
    });

    test('summaries read naturally', () {
      expect(ReminderDays.summary(kAllDays), 'Every day');
      expect(ReminderDays.summary(31), 'Weekdays');
      expect(ReminderDays.summary(96), 'Weekends');
      expect(ReminderDays.summary(0), 'No days');
      expect(
          ReminderDays.summary(ReminderDays.bit(1) | ReminderDays.bit(3) | ReminderDays.bit(5)),
          'Mon, Wed, Fri');
    });
  });

  group('times', () {
    test('parses 24 h times and rejects nonsense', () {
      expect(parseHhmm('08:05'), (hour: 8, minute: 5));
      expect(parseHhmm('8:05'), (hour: 8, minute: 5));
      expect(parseHhmm('23:59'), (hour: 23, minute: 59));
      expect(parseHhmm('24:00'), isNull);
      expect(parseHhmm('12:60'), isNull);
      expect(parseHhmm('noon'), isNull);
      expect(parseHhmm(''), isNull);
    });

    test('parsedTimes normalises, de-duplicates and sorts', () {
      expect(parsedTimes(['20:00', '8:00', '08:00', 'bad', '13:30']), ['08:00', '13:30', '20:00']);
    });
  });

  group('validateReminder', () {
    test('a normal reminder is fine', () {
      expect(validateReminder(rem('a', times: ['08:00', '20:00'])), isNull);
    });

    test('needs a name, a day and a time', () {
      expect(validateReminder(rem('a', name: '   ')), isNotNull);
      expect(validateReminder(rem('a', days: 0)), isNotNull);
      expect(validateReminder(rem('a', times: [])), isNotNull);
      expect(validateReminder(rem('a', times: ['25:00'])), isNotNull);
    });

    test('limits the times per day, counting distinct times only', () {
      final seven = ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];
      expect(validateReminder(rem('a', times: seven)), contains('up to $kMaxReminderTimes'));
      expect(validateReminder(rem('a', times: seven.take(kMaxReminderTimes).toList())), isNull);
      expect(validateReminder(rem('a', times: ['08:00', '8:00', '08:00'])), isNull);
    });

    test('quantity and dosage bounds', () {
      expect(
          validateReminder(const MedReminderModel(id: 'a', name: 'X', quantity: 0, times: ['08:00'])),
          isNotNull);
      expect(
          validateReminder(const MedReminderModel(id: 'a', name: 'X', dosage: -1, times: ['08:00'])),
          isNotNull);
    });

    test('refuses a reminder that would push the total over the OS limit', () {
      // 6 times x 7 days = 42 slots per reminder.
      final six = ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'];
      final first = rem('a', times: six);
      expect(first.slotCount, 42);
      expect(validateReminder(first), isNull);
      final second = rem('b', times: six);
      expect(validateReminder(second, others: [first]), contains('more reminders than your phone'));
    });

    test('disabled reminders do not count toward the limit, either way', () {
      final six = ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'];
      final off = rem('a', times: six, enabled: false);
      expect(validateReminder(rem('b', times: six), others: [off]), isNull);
      // Saving a disabled reminder is never blocked by the limit.
      final on = rem('c', times: six);
      expect(validateReminder(rem('d', times: six, enabled: false), others: [on]), isNull);
    });
  });

  group('buildSlots', () {
    test('one slot per enabled (day x time), disabled reminders skipped', () {
      final slots = buildSlots([
        rem('a', days: ReminderDays.bit(1) | ReminderDays.bit(5), times: ['08:00', '20:00']),
        rem('off', enabled: false),
      ]);
      expect(slots, hasLength(4));
      expect(slots.map((s) => s.reminderId).toSet(), {'a'});
      expect(slots.map((s) => s.weekday).toSet(), {1, 5});
    });

    test('is stable and sorted by weekday then time', () {
      final slots = buildSlots([
        rem('b', days: ReminderDays.bit(2), times: ['09:00']),
        rem('a', days: ReminderDays.bit(2) | ReminderDays.bit(1), times: ['07:30', '09:00']),
      ]);
      expect(slots.map((s) => '${s.weekday} ${formatHhmm(s.hour, s.minute)} ${s.reminderId}').toList(),
          ['1 07:30 a', '1 09:00 a', '2 07:30 a', '2 09:00 a', '2 09:00 b']);
    });

    test('ignores invalid and duplicate times, and rows without an id', () {
      final slots = buildSlots([
        rem('a', days: 1, times: ['08:00', '8:00', 'bad']),
        const MedReminderModel(id: null, name: 'unsaved', days: 1, times: ['08:00']),
      ]);
      expect(slots, [const ReminderSlot('a', 1, 8, 0)]);
    });

    test('is capped as a safety net', () {
      final six = ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'];
      final slots = buildSlots([rem('a', times: six), rem('b', times: six)]);
      expect(slots, hasLength(kMaxScheduledNotifications));
    });
  });

  group('nextWeekly', () {
    final london = tz.getLocation('Europe/London');
    final newYork = tz.getLocation('America/New_York');

    test('later today when the time is still ahead', () {
      // Wed 28 Oct 2026 07:00 -> Wed 08:00 the same day.
      final now = tz.TZDateTime(london, 2026, 10, 28, 7, 0);
      final next = nextWeekly(now, DateTime.wednesday, 8, 0);
      expect(next, tz.TZDateTime(london, 2026, 10, 28, 8, 0));
    });

    test('a week later when today\'s time has passed', () {
      final now = tz.TZDateTime(london, 2026, 10, 28, 9, 0);
      expect(nextWeekly(now, DateTime.wednesday, 8, 0), tz.TZDateTime(london, 2026, 11, 4, 8, 0));
    });

    test('the exact current minute counts as passed (strictly after now)', () {
      final now = tz.TZDateTime(london, 2026, 10, 28, 8, 0);
      expect(nextWeekly(now, DateTime.wednesday, 8, 0), tz.TZDateTime(london, 2026, 11, 4, 8, 0));
    });

    test('finds the next matching weekday', () {
      final now = tz.TZDateTime(london, 2026, 10, 28, 12, 0); // Wednesday
      final next = nextWeekly(now, DateTime.sunday, 9, 30);
      expect(next.weekday, DateTime.sunday);
      expect(next, tz.TZDateTime(london, 2026, 11, 1, 9, 30));
    });

    test('rolls over month and year ends', () {
      final now = tz.TZDateTime(london, 2026, 12, 31, 23, 0); // Thursday
      final next = nextWeekly(now, DateTime.friday, 6, 0);
      expect(next, tz.TZDateTime(london, 2027, 1, 1, 6, 0));
    });

    test('keeps the wall-clock hour across a daylight-saving change', () {
      // Europe/London ends DST on Sun 25 Oct 2026. A Monday 08:00 reminder set on
      // the Friday before must still be 08:00 local, not 07:00 or 09:00.
      final now = tz.TZDateTime(london, 2026, 10, 23, 12, 0);
      final next = nextWeekly(now, DateTime.monday, 8, 0);
      expect(next.hour, 8);
      expect(next.day, 26);
      expect(next.timeZoneOffset, Duration.zero, reason: 'now on GMT, not BST');

      final ny = tz.TZDateTime(newYork, 2026, 3, 7, 12, 0); // DST starts Sun 8 Mar
      final nextNy = nextWeekly(ny, DateTime.monday, 8, 0);
      expect([nextNy.day, nextNy.hour], [9, 8]);
    });

    test('handles a time that does not exist (spring-forward gap) without looping', () {
      // 01:30 on Sun 29 Mar 2026 does not exist in London; must still resolve to a Sunday.
      final now = tz.TZDateTime(london, 2026, 3, 27, 12, 0);
      final next = nextWeekly(now, DateTime.sunday, 1, 30);
      expect(next.weekday, DateTime.sunday);
      expect(next.isAfter(now), isTrue);
    });
  });

  group('keeping the OS schedule in step', () {
    const a8 = ReminderSlot('a', 1, 8, 0), a20 = ReminderSlot('a', 1, 20, 0);
    const b8 = ReminderSlot('b', 3, 8, 0);

    test('payload carries the reminder id first, and round-trips', () {
      final p = slotPayload(a8, 'Europe/London');
      expect(p, 'a|1|08:00|Europe/London');
      expect(reminderIdFromPayload(p), 'a');
      expect(reminderIdFromPayload('legacy-bare-id'), 'legacy-bare-id');
      expect(reminderIdFromPayload(null), isNull);
      expect(reminderIdFromPayload(''), isNull);
    });

    test('ids are stable, positive, 31-bit and unique', () {
      final first = notificationIds([a8, a20, b8]);
      final again = notificationIds([a8, a20, b8]);
      expect(first, again);
      expect(first.values.toSet(), hasLength(3));
      for (final id in first.values) {
        expect(id, greaterThan(0));
        expect(id, lessThanOrEqualTo(0x7fffffff));
      }
      // A slot's id does not depend on which other slots exist.
      expect(notificationIds([a8])[a8], first[a8]);
    });

    test('ids stay unique across a full schedule', () {
      final slots = [
        for (var d = 1; d <= 7; d++)
          for (var h = 6; h < 18; h += 2) ReminderSlot('r$h', d, h, 0)
      ];
      expect(notificationIds(slots).values.toSet(), hasLength(slots.length));
    });

    ScheduledNote note(int id, {String title = 'Time for X', String payload = 'p'}) =>
        ScheduledNote(id, title, 'body', payload);

    test('an unchanged schedule touches nothing (shown notifications survive)', () {
      final plan = planReschedule([note(1), note(2)], [note(2), note(1)]);
      expect(plan.cancel, isEmpty);
      expect(plan.schedule, isEmpty);
    });

    test('only what changed is cancelled or rescheduled', () {
      final plan = planReschedule(
        [note(1), note(2, title: 'Time for Y'), note(4)],
        [note(1), note(2), note(3)],
      );
      expect(plan.cancel, [3], reason: 'removed slot');
      expect(plan.schedule.map((n) => n.id), [2, 4], reason: 'changed text, new slot');
    });

    test('a timezone change reschedules everything via the payload', () {
      final plan = planReschedule([note(1, payload: 'a|1|08:00|America/New_York')],
          [note(1, payload: 'a|1|08:00|Europe/London')]);
      expect(plan.schedule.map((n) => n.id), [1]);
      expect(plan.cancel, isEmpty);
    });

    test('from nothing schedules all; to nothing cancels all', () {
      expect(planReschedule([note(1), note(2)], []).schedule, hasLength(2));
      expect(planReschedule([], [note(1), note(2)]).cancel, [1, 2]);
    });
  });
}
