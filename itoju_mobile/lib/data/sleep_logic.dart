/// Pure helpers for placing a sleep entry in real time: no database, no Flutter.
///
/// A sleep is stored as the day it was logged on plus two clock strings
/// ("10:00 PM", "6:00 AM"). Which calendar days those clocks fall on follows
/// from the kind of sleep:
///
/// * Night: the sleep that ENDED on the morning of the logged day. Bed was the
///   evening before (or after midnight), and wake-up is on the logged day. So
///   "last night" is logged on Today, which matches the page's "How well did you
///   sleep today?" and Home's "Sleep today" box.
/// * Daytime: a nap that starts on the logged day.
library;

import 'today_logic.dart';

DateTime _at(DateTime day, int dayOffset, int minutes) =>
    DateTime(day.year, day.month, day.day + dayOffset, 0, minutes);

/// When a complete sleep entry logged on [day] really happened. Null if either
/// time is unreadable or both are the same.
({DateTime start, DateTime end})? sleepWindow(
    DateTime day, bool isNight, String slept, String woke) {
  final a = parseClockMinutes(slept), b = parseClockMinutes(woke);
  if (a == null || b == null || a == b) return null;
  final wraps = b < a; // crosses midnight
  if (isNight) {
    return (start: _at(day, wraps ? -1 : 0, a), end: _at(day, 0, b));
  }
  return (start: _at(day, 0, a), end: _at(day, wraps ? 1 : 0, b));
}

/// When a bedtime alone falls, before a wake-up time is picked. For a night,
/// an afternoon or evening time is the evening before [day].
DateTime? sleepStartAlone(DateTime day, bool isNight, String slept) {
  final a = parseClockMinutes(slept);
  if (a == null) return null;
  return _at(day, isNight && a >= 12 * 60 ? -1 : 0, a);
}

/// When a wake-up time alone falls.
DateTime? sleepEndAlone(DateTime day, String woke) {
  final b = parseClockMinutes(woke);
  return b == null ? null : _at(day, 0, b);
}

/// Why the times picked so far can't stand, or null if they're fine. Either
/// time may still be empty: only what's there is checked, so the person hears
/// about a future time as soon as they pick it.
String? sleepFutureProblem(
    DateTime day, bool isNight, String slept, String woke, DateTime now) {
  final window = sleepWindow(day, isNight, slept, woke);
  final start = window?.start ?? sleepStartAlone(day, isNight, slept);
  final end = window?.end ?? sleepEndAlone(day, woke);
  if (start != null && start.isAfter(now)) {
    return "That bedtime hasn't happened yet.";
  }
  if (end != null && end.isAfter(now)) {
    return "That wake-up time hasn't happened yet. Log a sleep once you're up.";
  }
  return null;
}

/// Why a sleep entry can't be saved, or null if it can.
String? sleepSaveProblem(
    DateTime day, bool isNight, String slept, String woke, DateTime now) {
  if (parseClockMinutes(slept) == null || parseClockMinutes(woke) == null) {
    return 'Pick both the time you slept and the time you woke up.';
  }
  if (sleepWindow(day, isNight, slept, woke) == null) {
    return "Bedtime and wake-up time can't be the same.";
  }
  return sleepFutureProblem(day, isNight, slept, woke, now);
}

/// "07h 30m", the style the sleep card has always shown. "00h 00m" when the
/// times are incomplete.
String sleepDurationLabel(String slept, String woke) {
  final m = sleepMinutes(slept, woke) ?? 0;
  return '${(m ~/ 60).toString().padLeft(2, '0')}h '
      '${(m % 60).toString().padLeft(2, '0')}m';
}
