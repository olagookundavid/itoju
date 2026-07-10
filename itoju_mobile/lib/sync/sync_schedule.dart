/// Pure scheduling logic for catch-up-on-open cloud sync.
///
/// Mobile OSes won't reliably run a task at an exact wall-clock time while the
/// app is closed, so instead of a background alarm we decide *on each app
/// open/resume/reconnect* whether a periodic sync is due. This keeps the logic
/// dependency-free and unit-testable.
class SyncSchedule {
  static const off = 'off';
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const monthly = 'monthly';

  static const all = [off, daily, weekly, monthly];

  /// Whether a sync should run now given the chosen [cadence], the [last]
  /// successful sync time (null = never synced), and — for [daily] — the
  /// preferred [dailyHour] (0-23, e.g. 17 for 5 PM).
  ///
  /// - off      -> never automatic.
  /// - never synced -> due immediately (once entitled).
  /// - daily    -> due once we're past today's [dailyHour] boundary and haven't
  ///   synced since it (before the boundary, the reference is yesterday's).
  /// - weekly   -> due when >= 7 days since [last].
  /// - monthly  -> due when >= 30 days since [last].
  static bool isDue(DateTime now, DateTime? last, String cadence, int dailyHour) {
    if (cadence == off) return false;
    if (last == null) return true;
    switch (cadence) {
      case daily:
        final todayBoundary =
            DateTime(now.year, now.month, now.day, dailyHour);
        final boundary = now.isBefore(todayBoundary)
            ? todayBoundary.subtract(const Duration(days: 1))
            : todayBoundary;
        return last.isBefore(boundary);
      case weekly:
        return now.difference(last) >= const Duration(days: 7);
      case monthly:
        return now.difference(last) >= const Duration(days: 30);
      default:
        return false;
    }
  }
}
