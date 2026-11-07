/// Medication amounts (dose, quantity): decimals such as 0.5 mg, 0.125 mg or
/// half a tablet. Pure: no database, no Flutter.
///
/// The server keeps three decimals (NUMERIC(9,3), migration 045), so input is
/// rounded to that here and the phone never holds a value the server would
/// store differently.
library;

/// Upper bound for a dose or quantity. Far above any real one; it only keeps
/// a stray keypress from producing a number the server would refuse.
const double kMaxAmount = 99999;

double _round3(double v) => (v * 1000).round() / 1000;

/// Reads a typed amount: "2.5", "2,5" (comma-decimal keyboards), " 500 ".
/// Null if it isn't a number, is negative, or is too large.
double? parseAmount(String s) {
  final v = double.tryParse(s.trim().replaceAll(',', '.'));
  if (v == null || !v.isFinite || v < 0 || v > kMaxAmount) return null;
  return _round3(v);
}

/// Keeps a stored amount in range and to three decimals.
double clampAmount(double v) =>
    !v.isFinite || v < 0 ? 0 : _round3(v > kMaxAmount ? kMaxAmount : v);

/// "2.5", "500", "0.125": no trailing zeros and no ".0" on whole numbers.
String formatAmount(double v) {
  final s = _round3(v).toStringAsFixed(3);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}
