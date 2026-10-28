import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/blood_pressure.dart';

void main() {
  group('classifyBp (AHA adult ranges)', () {
    BpCategory c(int s, int d) => classifyBp(s, d);

    test('normal', () {
      expect(c(110, 70), BpCategory.normal);
      expect(c(119, 79), BpCategory.normal);
      expect(c(90, 60), BpCategory.normal, reason: '90/60 is the lower edge of normal');
    });

    test('elevated is systolic 120-129 with diastolic under 80', () {
      expect(c(120, 70), BpCategory.elevated);
      expect(c(129, 79), BpCategory.elevated);
    });

    test('stage 1: 130-139 or 80-89', () {
      expect(c(130, 70), BpCategory.stage1);
      expect(c(139, 79), BpCategory.stage1);
      expect(c(118, 80), BpCategory.stage1, reason: 'diastolic alone is enough');
      expect(c(125, 89), BpCategory.stage1);
    });

    test('stage 2: 140+ or 90+', () {
      expect(c(140, 70), BpCategory.stage2);
      expect(c(125, 90), BpCategory.stage2);
      expect(c(180, 100), BpCategory.stage2, reason: '180 itself is not yet a crisis');
      expect(c(160, 120), BpCategory.stage2, reason: '120 itself is not yet a crisis');
    });

    test('very high: over 180 and/or over 120', () {
      expect(c(181, 90), BpCategory.crisis);
      expect(c(150, 121), BpCategory.crisis);
      expect(c(200, 130), BpCategory.crisis);
    });

    test('low: under 90 systolic or under 60 diastolic', () {
      expect(c(85, 55), BpCategory.low);
      expect(c(89, 70), BpCategory.low);
      expect(c(105, 59), BpCategory.low);
    });

    test('the higher band wins when systolic and diastolic disagree', () {
      expect(c(110, 95), BpCategory.stage2);
      expect(c(135, 55), BpCategory.stage1, reason: 'high systolic outranks low diastolic');
    });

    test('every category has user-facing text', () {
      for (final cat in BpCategory.values) {
        expect(cat.label, isNotEmpty);
        expect(cat.summary, isNotEmpty);
      }
    });
  });

  group('validateBp', () {
    test('accepts an ordinary reading', () {
      expect(validateBp(systolic: 120, diastolic: 80, pulse: 70), isNull);
    });

    test('all three numbers are required', () {
      expect(validateBp(systolic: 120, diastolic: 80), isNotNull);
      expect(validateBp(systolic: 120, pulse: 70), isNotNull);
      expect(validateBp(diastolic: 80, pulse: 70), isNotNull);
    });

    test('systolic must exceed diastolic - a swapped pair is caught', () {
      final msg = validateBp(systolic: 80, diastolic: 120, pulse: 70);
      expect(msg, contains('wrong way round'));
      expect(validateBp(systolic: 100, diastolic: 100, pulse: 70), isNotNull);
    });

    test('range limits are inclusive at the edges and exclusive beyond', () {
      expect(validateBp(systolic: kSystolicMin + 20, diastolic: kDiastolicMin, pulse: kPulseMin), isNull);
      expect(validateBp(systolic: kSystolicMax, diastolic: kDiastolicMax - 1, pulse: kPulseMax), isNull);
      expect(validateBp(systolic: kSystolicMax + 1, diastolic: 80, pulse: 70), isNotNull);
      expect(validateBp(systolic: kSystolicMin - 1, diastolic: 40, pulse: 70), isNotNull);
      expect(validateBp(systolic: 120, diastolic: kDiastolicMax + 1, pulse: 70), isNotNull);
      expect(validateBp(systolic: 120, diastolic: kDiastolicMin - 1, pulse: 70), isNotNull);
      expect(validateBp(systolic: 120, diastolic: 80, pulse: kPulseMin - 1), isNotNull);
      expect(validateBp(systolic: 120, diastolic: 80, pulse: kPulseMax + 1), isNotNull);
    });
  });
}
