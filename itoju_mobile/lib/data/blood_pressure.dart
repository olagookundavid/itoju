/// Blood-pressure rules: what a plausible reading is, and which American Heart
/// Association category it falls in. Pure functions, no Flutter, no state.
library;

/// Entry-time bounds. Deliberately wider than any healthy range (a reading outside
/// 60–250 / 30–150 is far more likely a typo than a measurement), but narrower
/// than the server's CHECKs, which are only a last-resort backstop.
const int kSystolicMin = 60, kSystolicMax = 250;
const int kDiastolicMin = 30, kDiastolicMax = 150;
const int kPulseMin = 30, kPulseMax = 220;

/// Returns a user-facing message if the reading can't be saved, else null.
String? validateBp({int? systolic, int? diastolic, int? pulse}) {
  if (systolic == null || diastolic == null || pulse == null) {
    return 'Enter systolic, diastolic and pulse';
  }
  if (systolic < kSystolicMin || systolic > kSystolicMax) {
    return 'Systolic (top number) should be between $kSystolicMin and $kSystolicMax';
  }
  if (diastolic < kDiastolicMin || diastolic > kDiastolicMax) {
    return 'Diastolic (bottom number) should be between $kDiastolicMin and $kDiastolicMax';
  }
  if (systolic <= diastolic) {
    return 'Systolic (top) must be higher than diastolic (bottom) — '
        'they may be the wrong way round';
  }
  if (pulse < kPulseMin || pulse > kPulseMax) {
    return 'Pulse should be between $kPulseMin and $kPulseMax beats per minute';
  }
  return null;
}

enum BpCategory { low, normal, elevated, stage1, stage2, crisis }

/// AHA / ACC 2017 adult ranges, with "low" added for readings under 90/60 (the
/// guidelines don't name it; most clinical references do). When systolic and
/// diastolic fall in different bands the HIGHER category wins, as in the AHA chart.
BpCategory classifyBp(int systolic, int diastolic) {
  if (systolic > 180 || diastolic > 120) return BpCategory.crisis;
  if (systolic >= 140 || diastolic >= 90) return BpCategory.stage2;
  if (systolic >= 130 || diastolic >= 80) return BpCategory.stage1;
  if (systolic >= 120) return BpCategory.elevated;
  if (systolic < 90 || diastolic < 60) return BpCategory.low;
  return BpCategory.normal;
}

extension BpCategoryText on BpCategory {
  String get label => switch (this) {
        BpCategory.low => 'Low',
        BpCategory.normal => 'Normal',
        BpCategory.elevated => 'Elevated',
        BpCategory.stage1 => 'High – Stage 1',
        BpCategory.stage2 => 'High – Stage 2',
        BpCategory.crisis => 'Very high',
      };

  String get summary => switch (this) {
        BpCategory.low =>
          'Lower than usual. If you feel dizzy or faint, speak to a doctor.',
        BpCategory.normal => 'Within the healthy range.',
        BpCategory.elevated => 'A little above the healthy range.',
        BpCategory.stage1 =>
          'High blood pressure (Stage 1). Worth discussing with a doctor.',
        BpCategory.stage2 => 'High blood pressure (Stage 2). Please see a doctor.',
        BpCategory.crisis =>
          'Very high. Rest and check again in 5 minutes. If it is still this '
              'high, or you have chest pain, a bad headache or trouble '
              'breathing, get medical help now.',
      };
}

/// Shown under any category text: these are general ranges, not a diagnosis.
const String kBpDisclaimer =
    'Ranges follow the American Heart Association guide for adults. '
    'They are a guide, not a diagnosis.';
