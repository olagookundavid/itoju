import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/menses/notifiers/menses_notifier.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class DelMensesDialog extends StatelessWidget {
  final PeriodModel period;
  const DelMensesDialog({Key? key, required this.period}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                "Warning!",
                color: AppColors.primaryColorPurple,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.primaryColorPurple,
                  ))
            ],
          ),
          verticalSpaceMedium,
          const CustomText(
            "Deleting this would remove all data and isn't reversible!!!",
            color: Colors.black,
            maxline: 3,
            fontSize: 14,
          ),
          10.ph,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  buttonStyle: buttonStyle(
                      buttonWidth: 150.w,
                      buttonHeight: 40.h,
                      radius: 10,
                      color: Colors.red),
                  child: CustomText(
                    "Delete",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
