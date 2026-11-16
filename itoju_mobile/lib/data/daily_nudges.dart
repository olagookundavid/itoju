/// Daily check-in notifications: a good-morning note every day, and an evening
/// nudge only on days nothing has been logged. Pure Dart plus the `timezone`
/// package, like reminder_schedule.dart, so it is unit-testable.
///
/// A phone can't be asked "has this person logged today?" at 6 PM unless the app
/// happens to be open, so the evening nudge is scheduled AHEAD of time for the
/// next few days and the plan is rebuilt whenever something is logged: logging
/// removes today's evening nudge, which is how it "only fires when you haven't".
library;

import 'package:timezone/timezone.dart' as tz;

import 'reminder_schedule.dart' show formatHhmm, kNudgeIdBase, kNudgeIdCount;

/// How many days ahead are scheduled. Someone who stops opening the app gets
/// about a week of nudges and then silence, rather than notifications forever.
const int kNudgeDays = 7;

/// A payload that marks a notification as a check-in (a tap just opens the app).
const String kNudgePayloadTag = 'nudge';

bool isNudgePayload(String? payload) =>
    payload != null && payload.startsWith('$kNudgePayloadTag|');

enum NudgeKind { morning, evening }

/// What the person chose in Settings. Both on by default; times are minutes
/// after midnight, local.
class NudgePrefs {
  const NudgePrefs({
    this.morningOn = true,
    this.morningMinutes = 7 * 60,
    this.eveningOn = true,
    this.eveningMinutes = 18 * 60,
  });

  final bool morningOn;
  final int morningMinutes;
  final bool eveningOn;
  final int eveningMinutes;

  static const defaults = NudgePrefs();

  NudgePrefs copyWith({
    bool? morningOn,
    int? morningMinutes,
    bool? eveningOn,
    int? eveningMinutes,
  }) =>
      NudgePrefs(
        morningOn: morningOn ?? this.morningOn,
        morningMinutes: morningMinutes ?? this.morningMinutes,
        eveningOn: eveningOn ?? this.eveningOn,
        eveningMinutes: eveningMinutes ?? this.eveningMinutes,
      );
}

/// "7:00 AM" / "6:00 PM" for a minutes-after-midnight value.
String nudgeTimeLabel(int minutes) {
  final h = (minutes ~/ 60) % 24, m = minutes % 60;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
}

class NudgeNote {
  const NudgeNote({
    required this.id,
    required this.when,
    required this.kind,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final tz.TZDateTime when;
  final NudgeKind kind;
  final String title;
  final String body;
  final String payload;
}

// ----- the words ------------------------------------------------------------

/// Good-morning notes: warm, a little different each day, never about health
/// details (they show on a lock screen).
const List<({String title, String body})> kMorningMessages = [
  (title: 'Good morning', body: "Wishing you a lovely day ahead. Don't forget to track along the way."),
  (title: 'Rise and shine', body: "Today is a new page. Jot down how you feel as the day goes."),
  (title: 'Good morning', body: "Take a deep breath, drink some water, and have a great day. Itoju is here whenever you want to log."),
  (title: 'Hello, sunshine', body: "Hope you slept well. Log it while it's fresh, then go enjoy your day."),
  (title: 'A fresh day', body: "Small notes add up to big insight. Track what matters to you today."),
  (title: 'Good morning', body: "Be kind to yourself today. A quick log now and then is all it takes."),
  (title: 'Morning!', body: "Wishing you a calm, bright day. Remember to track as you go."),
  (title: 'Rise and shine', body: "Another day to look after you. Log your meals, meds and mood as they happen."),
  (title: 'Good morning', body: "You've got this. Check in with Itoju whenever something is worth noting."),
  (title: 'New day, new log', body: "However you're feeling, it's worth writing down. Have a good one."),
  (title: 'Good morning', body: "Start the day gently. Log your sleep, then get on with a great day."),
  (title: 'Hi there', body: "A good day starts with a good habit. Don't forget to track today."),
  (title: 'Good morning', body: "Your health story is yours to tell. Add a little to it today."),
  (title: 'Bright and early', body: "Hope today treats you well. Keep an eye on how you feel and log it."),
];

/// Evening nudges, sent only when nothing has been logged. They state the fact
/// ("nothing is logged") rather than ask a question.
const List<({String title, String body})> kEveningMessages = [
  (title: 'Today is almost gone', body: "Nothing is logged yet. A quick entry takes a minute."),
  (title: 'The day is winding down', body: "You haven't tracked anything today. Add a quick note before bed."),
  (title: 'Still time', body: "Today is going off and nothing is logged. Even one entry counts."),
  (title: "Don't let today slip by", body: "Nothing is logged yet. It only takes a minute."),
  (title: "Today's page is empty", body: "Add how you're feeling, what you ate, or how you slept."),
  (title: 'Evening check-in', body: "Nothing tracked today yet. Log one thing before you wind down."),
  (title: "Day's going off", body: "No entries today. One quick log keeps your picture complete."),
  (title: 'Before you rest', body: "You haven't tracked today. Log it now, then switch off."),
  (title: 'A small thing before bed', body: "Today has no entries yet. A minute now saves a gap later."),
  (title: 'Almost bedtime', body: "Nothing tracked today. Add one entry so today isn't blank."),
];

/// Evening nudges for someone with a streak at stake. `{n}` is the streak length.
const List<({String title, String body})> kStreakMessages = [
  (title: 'Your {n}-day streak ends tonight', body: "Nothing is logged today. One quick entry keeps it going."),
  (title: 'Keep your {n}-day streak alive', body: "Today is going off and nothing is logged yet. It only takes a minute."),
  (title: '{n} days in a row, so close', body: "Log one thing before the day ends to keep your streak."),
  (title: "Don't break your {n}-day streak", body: "Nothing is tracked today. A quick entry saves it."),
  (title: '{n} days strong', body: "Today is almost over and still empty. Add an entry to keep going."),
  (title: 'Your streak is at stake', body: "{n} days of tracking, and today isn't logged yet. A minute is enough."),
];

/// A streak shorter than this isn't worth mentioning.
const int kMinStreakToMention = 2;

/// Days since 1970 for a calendar date: the same number everywhere, so message
/// choice and ids depend only on the date.
int nudgeEpochDay(int year, int month, int day) =>
    DateTime.utc(year, month, day).difference(DateTime.utc(1970)).inDays;

({String title, String body}) _fill(({String title, String body}) m, int n) =>
    (title: m.title.replaceAll('{n}', '$n'), body: m.body.replaceAll('{n}', '$n'));

/// The morning message for a date. Deterministic, so a rebuilt schedule keeps
/// the same words (and isn't needlessly rescheduled).
({String title, String body}) morningMessage(int epochDay) =>
    kMorningMessages[epochDay % kMorningMessages.length];

/// The evening message for a date; the streak variant when [streak] is worth
/// mentioning.
({String title, String body}) eveningMessage(int epochDay, {int streak = 0}) {
  if (streak >= kMinStreakToMention) {
    return _fill(kStreakMessages[epochDay % kStreakMessages.length], streak);
  }
  // Offset so the evening isn't always the same number as the morning.
  return kEveningMessages[(epochDay + 3) % kEveningMessages.length];
}

int nudgeId(NudgeKind kind, int epochDay) =>
    kNudgeIdBase + (epochDay % (kNudgeIdCount ~/ 2)) * 2 + (kind == NudgeKind.evening ? 1 : 0);

// ----- the plan -------------------------------------------------------------

/// Every check-in to schedule from [now]: a morning note each day, and an
/// evening nudge each day except today's when [trackedToday].
///
/// [streak] is the run of logging days as of now. It only appears in the one
/// evening where it is really at stake: tonight if today is unlogged, tomorrow
/// if today is logged (every later evening would first need a log, and each log
/// rebuilds this plan).
List<NudgeNote> planNudges({
  required tz.TZDateTime now,
  required NudgePrefs prefs,
  required bool trackedToday,
  required int streak,
  int days = kNudgeDays,
}) {
  final out = <NudgeNote>[];
  for (var d = 0; d < days; d++) {
    final date = tz.TZDateTime(now.location, now.year, now.month, now.day + d);
    final epochDay = nudgeEpochDay(date.year, date.month, date.day);
    final stamp = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    NudgeNote? build(NudgeKind kind, int minutes, ({String title, String body}) text) {
      final when = tz.TZDateTime(
          now.location, date.year, date.month, date.day, minutes ~/ 60, minutes % 60);
      if (!when.isAfter(now)) return null;
      return NudgeNote(
        id: nudgeId(kind, epochDay),
        when: when,
        kind: kind,
        title: text.title,
        body: text.body,
        payload: '$kNudgePayloadTag|${kind.name}|$stamp|'
            '${formatHhmm(minutes ~/ 60, minutes % 60)}|${now.location.name}',
      );
    }

    if (prefs.morningOn) {
      final n = build(NudgeKind.morning, prefs.morningMinutes, morningMessage(epochDay));
      if (n != null) out.add(n);
    }
    if (prefs.eveningOn && !(d == 0 && trackedToday)) {
      final atStake = trackedToday ? d == 1 : d == 0;
      final n = build(NudgeKind.evening, prefs.eveningMinutes,
          eveningMessage(epochDay, streak: atStake ? streak : 0));
      if (n != null) out.add(n);
    }
  }
  return out;
}
