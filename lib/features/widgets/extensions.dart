import 'dart:io';

import 'package:intl/intl.dart';

extension FormatAmt on String {
  String formatAmt() {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: Platform.localeName,
      name: 'NGN',
    );
    try {
      final amount = double.parse(this);
      return formatCurrency.format(amount);
    } catch (e) {
      return this;
    }
  }
}
