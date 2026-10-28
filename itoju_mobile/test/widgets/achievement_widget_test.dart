import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/features/dashboard/widgets/achievement_widget.dart';

Widget _host(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) =>
          MaterialApp(home: Scaffold(body: Center(child: child))),
    );

void main() {
  testWidgets('tapping a badge opens the points info sheet', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(const AchievementWidget(
        text1: '42', text2: 'Week Points', kind: PointsKind.week)));

    expect(find.text('How points are earned'), findsNothing);
    await tester.tap(find.text('42'));
    await tester.pumpAndSettle();

    expect(find.text('Week Points'), findsWidgets);
    expect(find.text('How points are earned'), findsOneWidget);
    expect(find.textContaining('since Monday'), findsOneWidget);
    expect(find.text('+10'), findsWidgets);
  });
}
