import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/amounts.dart';

void main() {
  group('parseAmount', () {
    test('reads whole numbers and decimals', () {
      expect(parseAmount('500'), 500);
      expect(parseAmount(' 2.5 '), 2.5);
      expect(parseAmount('.5'), 0.5);
    });
    test('accepts a comma decimal separator', () {
      expect(parseAmount('2,5'), 2.5);
    });
    test('rounds to the three decimals the server keeps', () {
      expect(parseAmount('0.1254'), 0.125);
    });
    test('refuses non-numbers, negatives and absurd values', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('2.5.1'), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('-1'), isNull);
      expect(parseAmount('1000000'), isNull);
    });
  });

  test('formatAmount drops trailing zeros', () {
    expect(formatAmount(500), '500');
    expect(formatAmount(2.5), '2.5');
    expect(formatAmount(0.125), '0.125');
    expect(formatAmount(0.1), '0.1');
    expect(formatAmount(10), '10');
  });

  test('clampAmount keeps stored values in range', () {
    expect(clampAmount(-3), 0);
    expect(clampAmount(double.nan), 0);
    expect(clampAmount(1e9), kMaxAmount);
    expect(clampAmount(0.12549), 0.125);
  });
}
