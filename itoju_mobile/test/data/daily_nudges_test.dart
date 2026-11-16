import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/daily_nudges.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late tz.Location lagos;
  setUp(() => lagos = tz.getLocation('Africa/Lagos'));

  tz.TZDateTime at(int y, int m, int d, [int h = 0, int min = 0]) =>
      tz.TZDateTime(lagos, y, m, d, h, min);

  List<NudgeNote> plan(tz.TZDateTime now,
          {NudgePrefs prefs = NudgePrefs.defaults,
          bool tracked = false,
          int streak = 0}) =>
      planNudges(now: now, prefs: prefs, trackedToday: tracked, streak: streak);

  Iterable<NudgeNote> of(List<NudgeNote> p, NudgeKind k) =>
      p.where((n) => n.kind == k);

  group('the plan', () {
    test('a morning note every day at 7:00 and an evening nudge at 6 PM', () {
      final p = plan(at(2026, 11, 16, 6)); // 6 AM Monday, nothing logged
      final mornings = of(p, NudgeKind.morning).toList();
      final evenings = of(p, NudgeKind.evening).toList();
      expect(mornings, hasLength(kNudgeDays));
      expect(evenings, hasLength(kNudgeDays));
      expect(mornings.first.when, at(2026, 11, 16, 7));
      expect(evenings.first.when, at(2026, 11, 16, 18));
      expect(mornings.last.when, at(2026, 11, 22, 7));
    });

    test('times already gone today are skipped', () {
      final p = plan(at(2026, 11, 16, 7, 30)); // after the morning note
      expect(of(p, NudgeKind.morning).first.when, at(2026, 11, 17, 7));
      expect(of(p, NudgeKind.evening).first.when, at(2026, 11, 16, 18));

      final late = plan(at(2026, 11, 16, 19));
      expect(of(late, NudgeKind.evening).first.when, at(2026, 11, 17, 18));
    });

    test('logging today cancels today\'s evening nudge, nothing else', () {
      final before = plan(at(2026, 11, 16, 9));
      final after = plan(at(2026, 11, 16, 9), tracked: true);
      expect(of(before, NudgeKind.evening).first.when, at(2026, 11, 16, 18));
      expect(of(after, NudgeKind.evening).first.when, at(2026, 11, 17, 18));
      expect(of(after, NudgeKind.evening), hasLength(kNudgeDays - 1));
      // Mornings are for everyone, logged or not.
      expect(of(after, NudgeKind.morning).map((n) => n.id),
          of(before, NudgeKind.morning).map((n) => n.id));
    });

    test('each can be switched off', () {
      final noMorning =
          plan(at(2026, 11, 16, 6), prefs: const NudgePrefs(morningOn: false));
      expect(of(noMorning, NudgeKind.morning), isEmpty);
      expect(of(noMorning, NudgeKind.evening), isNotEmpty);

      final noEvening =
          plan(at(2026, 11, 16, 6), prefs: const NudgePrefs(eveningOn: false));
      expect(of(noEvening, NudgeKind.evening), isEmpty);
      expect(of(noEvening, NudgeKind.morning), isNotEmpty);

      expect(
          plan(at(2026, 11, 16, 6),
              prefs: const NudgePrefs(morningOn: false, eveningOn: false)),
          isEmpty);
    });

    test('times follow the chosen minutes', () {
      final p = plan(at(2026, 11, 16, 5),
          prefs: const NudgePrefs(morningMinutes: 8 * 60 + 15, eveningMinutes: 21 * 60 + 5));
      expect(of(p, NudgeKind.morning).first.when, at(2026, 11, 16, 8, 15));
      expect(of(p, NudgeKind.evening).first.when, at(2026, 11, 16, 21, 5));
    });

    test('a clock change keeps every note at its local time', () {
      final ny = tz.getLocation('America/New_York'); // DST ends 1 Nov 2026
      final p = plan(tz.TZDateTime(ny, 2026, 10, 30, 6));
      for (final n in p) {
        expect(n.when.hour, n.kind == NudgeKind.morning ? 7 : 18, reason: '${n.when}');
      }
      expect(of(p, NudgeKind.morning), hasLength(kNudgeDays));
    });

    test('ids are unique, in the reserved range, and stable for a date', () {
      final p = plan(at(2026, 11, 16, 6));
      final ids = p.map((n) => n.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.every(isNudgeId), isTrue);

      // Rebuilding later the same day gives the same note the same id, so it
      // is left alone rather than rescheduled.
      final later = plan(at(2026, 11, 16, 12));
      final byWhen = {for (final n in p) n.when: n};
      for (final n in later) {
        final earlier = byWhen[n.when];
        if (earlier == null) continue;
        expect(n.id, earlier.id);
        expect(n.title, earlier.title);
        expect(n.body, earlier.body);
        expect(n.payload, earlier.payload);
      }
    });

    test('a note\'s payload marks it as a check-in and changes with its time', () {
      final a = plan(at(2026, 11, 16, 6)).first;
      final b = plan(at(2026, 11, 16, 6),
              prefs: const NudgePrefs(morningMinutes: 8 * 60))
          .first;
      expect(isNudgePayload(a.payload), isTrue);
      expect(a.payload, contains('Africa/Lagos'));
      expect(b.payload, isNot(a.payload),
          reason: 'a new time must reschedule the note');
      expect(isNudgePayload('some-reminder-id|1|08:00|UTC'), isFalse);
      expect(isNudgePayload(null), isFalse);
    });

    test('check-in ids never overlap the ids medication reminders use', () {
      // Reminders probe past the reserved block, whatever their hash was.
      final slots = [
        for (var i = 0; i < 2000; i++) ReminderSlot('rem-$i', 1 + i % 7, 8, 0),
      ];
      expect(notificationIds(slots).values.any(isNudgeId), isFalse);
      expect(isNudgeId(kNudgeIdBase), isTrue);
      expect(isNudgeId(kNudgeIdBase + kNudgeIdCount - 1), isTrue);
      expect(isNudgeId(kNudgeIdBase + kNudgeIdCount), isFalse);
      expect(isNudgeId(kNudgeIdBase - 1), isFalse);
    });
  });

  group('streaks', () {
    String eveningTitle(List<NudgeNote> p, int dayOffset) => of(p, NudgeKind.evening)
        .firstWhere((n) => n.when.day == 16 + dayOffset)
        .title;

    test('an unlogged day with a streak says it ends tonight, once', () {
      final p = plan(at(2026, 11, 16, 9), streak: 5);
      expect(eveningTitle(p, 0), contains('5'));
      expect(eveningTitle(p, 0), isNot(contains('{n}')));
      // Later evenings would need a log first, and a log rebuilds this plan.
      for (var d = 1; d < kNudgeDays; d++) {
        expect(eveningTitle(p, d), isNot(contains('5')), reason: 'day $d');
      }
    });

    test('once today is logged the streak shows on tomorrow\'s evening', () {
      final p = plan(at(2026, 11, 16, 9), tracked: true, streak: 5);
      expect(of(p, NudgeKind.evening).first.when, at(2026, 11, 17, 18));
      expect(eveningTitle(p, 1), contains('5'));
      expect(eveningTitle(p, 2), isNot(contains('5')));
    });

    test('a streak of one is not worth mentioning', () {
      final p = plan(at(2026, 11, 16, 9), streak: 1);
      expect(of(p, NudgeKind.evening).first.body,
          eveningMessage(nudgeEpochDay(2026, 11, 16)).body);
    });
  });

  group('the words', () {
    test('there are plenty, so days don\'t repeat quickly', () {
      expect(kMorningMessages.length, greaterThanOrEqualTo(14));
      expect(kEveningMessages.length, greaterThanOrEqualTo(10));
      expect(kStreakMessages.length, greaterThanOrEqualTo(6));
      expect({for (final m in kMorningMessages) m.body}, hasLength(kMorningMessages.length));
      expect({for (final m in kEveningMessages) m.body}, hasLength(kEveningMessages.length));
    });

    test('a different morning note on each of the next days', () {
      final start = nudgeEpochDay(2026, 11, 16);
      final week = {for (var i = 0; i < 7; i++) morningMessage(start + i).body};
      expect(week, hasLength(7));
      expect(morningMessage(start), morningMessage(start),
          reason: 'the same date always gets the same words');
    });

    test('all of them fit a notification and read as statements', () {
      for (final m in [...kMorningMessages, ...kEveningMessages, ...kStreakMessages]) {
        expect(m.title.trim(), isNotEmpty);
        expect(m.body.trim(), isNotEmpty);
        expect(m.title.length, lessThanOrEqualTo(40), reason: m.title);
        expect(m.body.length, lessThanOrEqualTo(130), reason: m.body);
      }
      // The evening nudge tells people the day is going, rather than asking
      // "have you tracked?".
      for (final m in [...kEveningMessages, ...kStreakMessages]) {
        expect('${m.title} ${m.body}'.contains('?'), isFalse, reason: m.body);
        expect('${m.title} ${m.body}'.toLowerCase(), isNot(contains('have you')));
      }
    });

    test('streak templates fill in the number and nothing else is templated', () {
      for (var i = 0; i < kStreakMessages.length; i++) {
        final m = eveningMessage(i, streak: 12);
        // Streak variants are picked by date; find the one for this day.
        expect(m.title.contains('{n}') || m.body.contains('{n}'), isFalse);
      }
      for (final m in [...kMorningMessages, ...kEveningMessages]) {
        expect(m.title.contains('{n}') || m.body.contains('{n}'), isFalse);
      }
      expect(kStreakMessages.every((m) => '${m.title}${m.body}'.contains('{n}')), isTrue);
    });

    test('nothing health-specific shows on a lock screen', () {
      for (final m in [...kMorningMessages, ...kEveningMessages, ...kStreakMessages]) {
        final text = '${m.title} ${m.body}'.toLowerCase();
        for (final word in ['period', 'bp ', 'blood pressure', 'diagnos', 'pain', 'symptom']) {
          expect(text, isNot(contains(word)), reason: m.body);
        }
      }
    });
  });

  test('times read the way a person says them', () {
    expect(nudgeTimeLabel(7 * 60), '7:00 AM');
    expect(nudgeTimeLabel(18 * 60), '6:00 PM');
    expect(nudgeTimeLabel(0), '12:00 AM');
    expect(nudgeTimeLabel(12 * 60), '12:00 PM');
    expect(nudgeTimeLabel(13 * 60 + 5), '1:05 PM');
  });
}
