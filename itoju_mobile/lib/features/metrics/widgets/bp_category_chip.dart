import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/data/blood_pressure.dart';

/// A blood-pressure category as colour + icon + words, so it never relies on
/// colour alone. The text is dark ink; colour sits in the icon and the tint.
class BpCategoryChip extends StatelessWidget {
  const BpCategoryChip(this.category, {super.key});
  final BpCategory category;

  static Color colorOf(BpCategory c) => switch (c) {
        BpCategory.low => const Color(0xff5464D5),
        BpCategory.normal => const Color(0xff2A9341),
        BpCategory.elevated => const Color(0xffC98500),
        BpCategory.stage1 => const Color(0xffEB6834),
        BpCategory.stage2 => const Color(0xffD72727),
        BpCategory.crisis => const Color(0xff9B1C1C),
      };

  static IconData iconOf(BpCategory c) => switch (c) {
        BpCategory.low => Icons.arrow_downward_rounded,
        BpCategory.normal => Icons.check_circle_outline,
        BpCategory.elevated => Icons.trending_up_rounded,
        BpCategory.stage1 => Icons.warning_amber_rounded,
        BpCategory.stage2 => Icons.warning_amber_rounded,
        BpCategory.crisis => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(category);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconOf(category), size: 14.r, color: c),
          4.horizontalSpace,
          Text(category.label,
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff3A3A3A))),
        ],
      ),
    );
  }
}
