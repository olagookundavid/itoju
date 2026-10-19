/// Cycle-day layout rules shared (by test vector) with the backend.
library;

/// Inclusive 0-based day indexes of the fertile window within a cycle.
typedef FertileWindow = ({int start, int end});

/// Ovulation falls about 14 days before the next period starts (the luteal phase
/// is fairly constant), i.e. at index `cycleLen - 15`; sperm survive ~5 days, so
/// the fertile window is those 5 days plus the ovulation day (6 days). It never
/// overlaps the period. Returns null when the cycle leaves no room after the
/// period.
///
/// MUST stay identical to `ovulationWindow` in the backend's
/// internal/models/period_cycle.go — both are tested against the same vectors.
FertileWindow? ovulationWindow(int periodLen, int cycleLen) {
  var ov = cycleLen - 15;
  if (ov < periodLen) ov = periodLen;
  if (ov >= cycleLen) return null;
  var start = ov - 5;
  if (start < periodLen) start = periodLen;
  return (start: start, end: ov);
}
