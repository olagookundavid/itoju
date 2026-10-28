/// Write-boundary limits, matching the server's column sizes (see the Go
/// migrations). Postgres rejects a row with a value past these (NUMERIC(5,2),
/// SMALLINT, VARCHAR(255)/(20), CHECK 0..1) — so repositories pass user input
/// through these helpers and a too-big value is bounded here rather than stored
/// locally and then bounced by the server on every sync.
library;

/// VARCHAR(255): meals, extras, fruit, snack.
const int kMaxText = 255;

/// VARCHAR(20): time-of-day strings ("08:30 AM"), exercise start/end, etc.
const int kMaxShortText = 20;

/// SMALLINT upper bound (dosage, quantity, counts, glasses of water).
const int kSmallIntMax = 32767;

/// Cycle / period length bounds. A cycle creates one row per day, so an
/// unbounded value would generate thousands of rows.
const int kMaxCycleLength = 120;
const int kMaxPeriodLength = 31;

String clipText(String? s, int max) {
  if (s == null) return '';
  return s.length <= max ? s : s.substring(0, max);
}

int clampSmallInt(int v) => v < 0 ? 0 : (v > kSmallIntMax ? kSmallIntMax : v);

/// Severity / pain / flow sliders are stored NUMERIC(3,2) with CHECK 0..1.
double clampUnit(double v) {
  if (v.isNaN) return 0;
  return v < 0 ? 0 : (v > 1 ? 1 : v);
}

/// Urine quantity is NUMERIC(5,2): at most 999.99.
double clampQuantity(double v) {
  if (v.isNaN) return 0;
  return v < 0 ? 0 : (v > 999.99 ? 999.99 : v);
}

/// Body measurements are stored as cm / kg with one decimal (NUMERIC(5,1)).
const double kMaxHeightCm = 300;
const double kMaxWeightKg = 500;

double clampBody(double v, double max) {
  if (v.isNaN || v < 0) return 0;
  final bounded = v > max ? max : v;
  return (bounded * 10).roundToDouble() / 10;
}
