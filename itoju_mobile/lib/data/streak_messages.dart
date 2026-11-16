/// The in-app message shown when someone logs for the first time on a day and
/// has a streak going. Pure Dart so it is unit-testable.
library;

/// Streak lengths that get their own message.
const List<int> kStreakMilestones = [7, 14, 30, 50, 100, 150, 200, 365];

const List<({String title, String body})> _everyday = [
  (title: '{n}-day streak', body: "Keep it going. That's {n} days in a row."),
  (title: '{n} days in a row', body: 'Nice work. Come back tomorrow to keep it going.'),
  (title: '{n}-day streak', body: 'You showed up again today. Keep it going.'),
  (title: '{n} days strong', body: 'Every log counts. See you tomorrow.'),
];

const Map<int, ({String title, String body})> _milestones = {
  7: (title: 'A full week!', body: '7 days in a row. A real habit is forming.'),
  14: (title: 'Two weeks!', body: '14 days in a row. You are building something great.'),
  30: (title: '30 days!', body: 'A whole month of tracking. Be proud of yourself.'),
  50: (title: '50 days!', body: '50 days in a row. That is real dedication.'),
  100: (title: '100 days!', body: '100 days in a row. Incredible.'),
  150: (title: '150 days!', body: '150 days in a row. Keep shining.'),
  200: (title: '200 days!', body: '200 days in a row. What a streak.'),
  365: (title: 'A whole year!', body: '365 days in a row. Amazing.'),
};

/// A streak this short isn't a streak yet, so nothing is shown for it.
const int kMinStreakToCelebrate = 2;

/// What to show for a streak of [streak] days, counting today; null when it is
/// too short to mention. Milestones get a special message, the rest rotate.
({String title, String body})? streakMessage(int streak) {
  if (streak < kMinStreakToCelebrate) return null;
  final milestone = _milestones[streak];
  if (milestone != null) return milestone;
  final m = _everyday[streak % _everyday.length];
  return (
    title: m.title.replaceAll('{n}', '$streak'),
    body: m.body.replaceAll('{n}', '$streak'),
  );
}
