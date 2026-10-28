/// Pure helpers behind the Home screen's "today" boxes: no database, no Flutter.
library;

import 'package:intl/intl.dart';

/// Minutes since midnight for a stored clock string like "10:30 PM". Tolerates
/// the narrow no-break space newer ICU data puts before AM/PM, stray spacing, and
/// lower case. Null if it isn't a 12 h time.
int? parseClockMinutes(String s) {
  final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])\s*$')
      .firstMatch(s.replaceAll(' ', ' ').replaceAll(' ', ' '));
  if (m == null) return null;
  var h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  if (h < 1 || h > 12 || min > 59) return null;
  final pm = m.group(3)!.toLowerCase() == 'pm';
  if (h == 12) h = 0;
  return (pm ? h + 12 : h) * 60 + min;
}

/// Minutes asleep between going to bed and waking, wrapping past midnight
/// ("11:00 PM" -> "6:30 AM" = 450). Null if either time is unreadable, or if both
/// are the same (nothing meaningful to show).
int? sleepMinutes(String slept, String woke) {
  final a = parseClockMinutes(slept), b = parseClockMinutes(woke);
  if (a == null || b == null || a == b) return null;
  return b > a ? b - a : b + 24 * 60 - a;
}

/// "7h 20m", "8h", "45m".
String formatDuration(int minutes) {
  final h = minutes ~/ 60, m = minutes % 60;
  if (h == 0) return '${m}m';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// Whole calendar days from [from] to [to], ignoring the time of day. Done on UTC
/// dates because a local day is 23 or 25 hours long across a daylight-saving
/// change, so `difference().inDays` would come out one short (or long).
int calendarDaysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// [d]'s calendar date plus [days] days, at midnight. Built from date fields, not
/// by adding 24-hour Durations (which drift by an hour across DST).
DateTime addCalendarDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

String plural(int n, String one, [String? many]) => '$n ${n == 1 ? one : (many ?? '${one}s')}';

/// Consecutive logging days ending [today]. A day with entries is any date in
/// [loggedDates] ('yyyy-MM-dd'). If today has nothing yet the streak is still
/// alive as long as yesterday has — it only breaks once a whole day is missed.
int computeStreak(Set<String> loggedDates, DateTime today) {
  final fmt = DateFormat('yyyy-MM-dd');
  DateTime day(int back) => DateTime(today.year, today.month, today.day - back);
  var offset = loggedDates.contains(fmt.format(day(0))) ? 0 : 1;
  var streak = 0;
  while (loggedDates.contains(fmt.format(day(offset)))) {
    streak++;
    offset++;
  }
  return streak;
}

/// "today", "yesterday", "3 days ago", or the date for older ones.
String relativeDay(String isoDate, DateTime today) {
  final d = DateTime.tryParse(isoDate);
  if (d == null) return isoDate;
  final diff = calendarDaysBetween(d, today);
  if (diff <= 0) return 'today';
  if (diff == 1) return 'yesterday';
  if (diff < 14) return '$diff days ago';
  return DateFormat('d MMM').format(d);
}
