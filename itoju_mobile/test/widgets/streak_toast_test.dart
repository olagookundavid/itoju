import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/services/streak_celebrator.dart';
import 'package:toastification/toastification.dart';

void main() {
  testWidgets('the streak message appears in the app, over the current screen',
      (tester) async {
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => const ToastificationWrapper(
        child: MaterialApp(home: Scaffold(body: Text('Home'))),
      ),
    ));

    showStreakToast('3-day streak', "Keep it going. That's 3 days in a row.");
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('3-day streak'), findsOneWidget);
    expect(find.textContaining('Keep it going'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);

    // It goes away by itself.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('3-day streak'), findsNothing);
  });
}
