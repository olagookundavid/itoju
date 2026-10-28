import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/body_units.dart';

void main() {
  test('cm -> feet + inches (one decimal)', () {
    expect(cmToFeetInches(175.3), (feet: 5, inches: 9.0));
    expect(cmToFeetInches(177.8), (feet: 5, inches: 10.0));
    expect(cmToFeetInches(152.4), (feet: 5, inches: 0.0));
    expect(cmToFeetInches(0), (feet: 0, inches: 0));
    expect(cmToFeetInches(double.nan), (feet: 0, inches: 0));
  });

  test('inches rounding to 12 carries into feet instead of showing 12 in', () {
    // 182.8 cm = 71.97 in -> 72.0 in -> 6 ft 0 in (never "5 ft 12 in")
    expect(cmToFeetInches(182.8), (feet: 6, inches: 0.0));
  });

  test('feet + inches -> cm', () {
    expect(feetInchesToCm(5, 8.5), 174.0);
    expect(feetInchesToCm(6, 0), 182.9);
    expect(feetInchesToCm(0, 0), 0);
  });

  test('kg <-> lb', () {
    expect(kgToLb(68.5), 151.0);
    expect(lbToKg(150), 68.0);
    expect(lbToKg(kgToLb(70)), closeTo(70, 0.1));
  });

  test('both historic spellings of pounds / inches are understood', () {
    expect(isPounds('ib'), isTrue); // what older builds wrote
    expect(isPounds('lb'), isTrue);
    expect(isPounds('kg'), isFalse);
    expect(isPounds(null), isFalse);
    expect(isFeetInches('inch'), isTrue);
    expect(isFeetInches('cm'), isFalse);
    expect(isFeetInches(null), isFalse);
  });

  test('a cm value survives a round trip through ft+in within rounding', () {
    for (final cm in [150.0, 163.5, 172.0, 181.2, 190.5, 201.9]) {
      final fi = cmToFeetInches(cm);
      expect(feetInchesToCm(fi.feet, fi.inches), closeTo(cm, 0.3),
          reason: '$cm');
    }
  });
}
