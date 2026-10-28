/// Body measurements are STORED as centimetres and kilograms (one decimal) and
/// converted only for display and entry. Pure functions, no state.
library;

const double _cmPerInch = 2.54;
const double _kgPerLb = 0.45359237;

/// Hive stores the user's display unit as a string. `inch` / `ib` are the values
/// older builds wrote (`ib` was a typo for lb); both spellings are understood.
bool isFeetInches(String? heightUnit) =>
    heightUnit == 'inch' || heightUnit == 'ftin';
bool isPounds(String? weightUnit) => weightUnit == 'ib' || weightUnit == 'lb';

double round1(double v) => (v * 10).roundToDouble() / 10;

/// 175.3 cm -> (ft: 5, inches: 8.9).
({int feet, double inches}) cmToFeetInches(double cm) {
  if (cm.isNaN || cm <= 0) return (feet: 0, inches: 0);
  final totalInches = round1(cm / _cmPerInch);
  var feet = totalInches ~/ 12;
  var inches = round1(totalInches - feet * 12);
  if (inches >= 12) {
    // Rounding can land on exactly 12.0 in; carry it into the feet.
    feet += 1;
    inches = 0;
  }
  return (feet: feet, inches: inches);
}

double feetInchesToCm(int feet, double inches) =>
    round1((feet * 12 + inches) * _cmPerInch);

double kgToLb(double kg) => round1(kg / _kgPerLb);
double lbToKg(double lb) => round1(lb * _kgPerLb);

/// Inches are stored in the legacy whole-number column when a user's unit was
/// `inch` (the old UI was a single "inches" box, not feet + inches).
double legacyInchesToCm(num inches) => round1(inches * _cmPerInch);
