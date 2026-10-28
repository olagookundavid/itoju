import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

/// Which points figure a badge shows; decides what its info sheet explains.
enum PointsKind { today, week, total }

/// What each tracked entry is worth. Mirrors the awards in the repositories and
/// PointsRepository._backfillScopes — keep the three in step.
const List<({String label, int points})> kPointsTable = [
  (label: 'Log a symptom', points: 10),
  (label: 'Create your account', points: 10),
  (label: 'Log food, sleep, bowel, urine, exercise or medication', points: 2),
];

String _kindTitle(PointsKind k) => switch (k) {
      PointsKind.today => 'Today Points',
      PointsKind.week => 'Week Points',
      PointsKind.total => 'Total Points',
    };

String _kindExplain(PointsKind k) => switch (k) {
      PointsKind.today => 'Everything you earned today. It starts again at '
          'midnight, so log something early to get on the board.',
      PointsKind.week => 'Everything you earned since Monday. The count '
          'resets each Monday.',
      PointsKind.total => 'Every point you have earned since you started. '
          'Points never expire, and a restored device shows the same total.',
    };

Future<void> showPointsInfoSheet(BuildContext context,
    {required PointsKind kind, required String value}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.ph,
            Row(
              children: [
                Text(
                  _kindTitle(kind),
                  style: TextStyle(
                      color: AppColors.primaryColorPurple,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                      color: AppColors.primaryColorPurple,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
            8.ph,
            Text(
              _kindExplain(kind),
              style: TextStyle(
                  color: AppColors.textGrey, fontSize: 13.sp, height: 1.4),
            ),
            18.ph,
            Text(
              'How points are earned',
              style: TextStyle(
                  color: AppColors.primaryColorPurple,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700),
            ),
            8.ph,
            for (final row in kPointsTable)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(row.label,
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 13.sp)),
                    ),
                    10.pw,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.opaquePurple,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text('+${row.points}',
                          style: TextStyle(
                              color: AppColors.primaryColorPurple,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            12.ph,
            Text(
              'Mood check-ins do not earn points.',
              style: TextStyle(color: AppColors.hintGrey, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A compact points badge. Tapping it (or its (i)) opens [showPointsInfoSheet].
class AchievementWidget extends StatelessWidget {
  const AchievementWidget({
    super.key,
    required this.text1,
    required this.text2,
    this.kind = PointsKind.total,
  });
  final String text1, text2;
  final PointsKind kind;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showPointsInfoSheet(context, kind: kind, value: text1),
      child: SizedBox(
        width: 100.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 29.r,
                  backgroundColor: const Color(0xff8662FF),
                  child: CircleAvatar(
                    radius: 26.r,
                    backgroundColor: const Color(0xff5142AB),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          text1,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -2.h,
                  right: -4.w,
                  child: CircleAvatar(
                    radius: 11.r,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xff5142AB),
                      radius: 8.5.r,
                      child: SvgPicture.asset(
                        'asset/svg/i.svg',
                        width: 10.w,
                        height: 12.w,
                      ),
                    ),
                  ),
                )
              ],
            ),
            4.ph,
            Text(text2,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    overflow: TextOverflow.visible,
                    color: AppColors.primaryColorPurple,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
