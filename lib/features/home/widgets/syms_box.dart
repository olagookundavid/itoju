import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/home/notifer/metrics_status_notifier.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/metrics/pages/bowel_movements.dart';
import 'package:itoju_mobile/features/metrics/pages/exercise.dart';
import 'package:itoju_mobile/features/metrics/pages/food_metric.dart';
import 'package:itoju_mobile/features/metrics/pages/medication.dart';
import 'package:itoju_mobile/features/metrics/pages/sleep.dart';
import 'package:itoju_mobile/features/metrics/pages/symptoms.dart';
import 'package:itoju_mobile/features/metrics/pages/urination.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class SyptomsBox extends ConsumerStatefulWidget {
  const SyptomsBox(
      {super.key,
      required this.metric,
      required this.onTap,
      required this.intialDate});
  final String metric;
  final Function onTap;
  final DateTime intialDate;

  @override
  ConsumerState<SyptomsBox> createState() => _SyptomsBoxState();
}

class _SyptomsBoxState extends ConsumerState<SyptomsBox> {
  String image = '';
  Color color = const Color(0xffE4E6E7);
  Widget? screen;

  @override
  Widget build(BuildContext context) {
    switch (widget.metric) {
      case 'Food Diary':
        image = 'food_diary';
        break;
      case 'Symptoms':
        image = 'cough';
        break;
      case 'Sleep':
        image = 'sleep';
        break;
      case 'Bowel Movements':
        image = 'bowel';
        break;
      case 'Medications':
        image = 'drug';
        break;
      case 'Menstruation and Ovulation':
        image = 'blood';
        break;
      case 'Urination':
        image = 'bladder';
        break;
      case 'Exercise':
        image = 'meditation';
        break;
      default:
        image = '';
    }

    Color getStatusColor() {
      Color color;

      switch (widget.metric) {
        case 'Food Diary':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.food == true
                  ? const Color(0xffFFF8E5)
                  : const Color(0xffE4E6E7);

        case 'Symptoms':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.symptoms ==
                      true
                  ? const Color(0xffEDF7F8)
                  : const Color(0xffE4E6E7);

        case 'Sleep':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.sleep == true
                  ? const Color(0xffF5EFF5)
                  : const Color(0xffE4E6E7);

        case 'Bowel Movements':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.bowel == true
                  ? const Color(0xffEDF7F8)
                  : const Color(0xffE4E6E7);

        case 'Medications':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.medication ==
                      true
                  ? const Color(0xffFFF8E5)
                  : const Color(0xffE4E6E7);

        case 'Menstruation and Ovulation':
          color = const Color(0xffFFEAE6);

        case 'Urination':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.urine == true
                  ? const Color(0xffFFEAE6)
                  : const Color(0xffE4E6E7);

        case 'Exercise':
          color =
              ref.watch(metricsStatusProvider).metricStatusModel?.exercise ==
                      true
                  ? const Color(0xffEBF9EE)
                  : const Color(0xffE4E6E7);
        default:
          color = const Color(0xffE4E6E7);
          {}
      }

      return color;
    }

    switch (widget.metric) {
      case 'Food Diary':
        screen = FoodMetric(widget.intialDate);
        break;
      case 'Symptoms':
        screen = SymptomsPage(widget.intialDate);
        break;
      case 'Sleep':
        screen = SleepWidget(widget.intialDate);
        break;
      case 'Bowel Movements':
        screen = BowelMovement(widget.intialDate);
        break;
      case 'Medications':
        screen = MedicationMovement((widget.intialDate));
        break;
      // case 'Menstruation and Ovulation':
      //   break;
      case 'Urination':
        screen = UrineMovement(widget.intialDate);
        break;
      case 'Exercise':
        screen = ExercisePage(widget.intialDate);
        break;
      default:
        screen = Container();
    }

    return InkWell(
      onTap: () {
        if (widget.metric == 'Menstruation and Ovulation') {
          //TODO: here
          ref.read(routeStateProvider).jumpToTab(3);
          return;
        }
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return screen!;
          },
        ));
        widget.onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: ref.watch(metricsStatusProvider).status == Loader.loaded
              ? getStatusColor()
              : const Color(0xffE4E6E7),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 40.w,
              height: 35.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: AppColors.splash_underlay,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'asset/svg/$image.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
            10.ph,
            CustomText(
              widget.metric,
              maxline: 2,
              color: const Color(0xff737B7D),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.r)),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15.r,
                  ),
                )
              ],
            ),
            10.ph
          ],
        ),
      ),
    );
  }
}
