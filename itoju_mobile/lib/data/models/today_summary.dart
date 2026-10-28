/// What one tracked metric looks like on the Home screen today.
class MetricToday {
  const MetricToday({required this.logged, required this.headline, this.detail});

  /// Whether there is something recorded for today.
  final bool logged;

  /// The main value, e.g. "2 meals", "122/81", "Day 3". "Tap to log" if none.
  final String headline;

  /// A second, smaller line, e.g. "68 bpm · Normal" or "Next reminder 8:00 PM".
  final String? detail;
}

class TodaySummary {
  const TodaySummary({
    required this.date,
    required this.metrics,
    required this.streak,
    this.moodId,
  });

  /// yyyy-MM-dd
  final String date;

  /// Keyed by the metric's catalog name ('Food Diary', 'Sleep', …). Every known
  /// metric has an entry, whether or not the person tracks it.
  final Map<String, MetricToday> metrics;

  /// Consecutive days, ending today (or yesterday if nothing is logged yet today),
  /// with at least one entry in any tracker.
  final int streak;

  /// Today's mood (smiley catalog id 1..5), or null if none yet.
  final int? moodId;
}
