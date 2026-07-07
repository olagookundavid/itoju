import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension EmptyPadding on num {
  SizedBox get sbh => SizedBox(height: toDouble().h);
  SizedBox get sbw => SizedBox(width: toDouble().w);
}

bool isEmailValid(String email) {
  // Define a regex pattern for a valid email address
  const String emailPattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
  final RegExp regex = RegExp(emailPattern);
  return regex.hasMatch(email);
}

V? getHighestMapValue<K, V extends num>(Map<K, V> map) {
  if (map.isEmpty) return null;
  return map.values.reduce((curr, next) => curr > next ? curr : next);
}

getHighestListValue(List list) {
  if (list.isEmpty) return 0;
  final a = list.reduce((curr, next) => curr > next ? curr : next);
  return a + 10;
}
