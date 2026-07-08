import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget horizontalSpaceTiny = SizedBox(width: 5.0.w);
Widget horizontalSpaceSmall = SizedBox(width: 10.0.w);
Widget horizontalSpaceMedium = SizedBox(width: 25.0.w);

Widget verticalSpaceTiny = SizedBox(height: 5.0.h);
Widget verticalSpaceSmall = SizedBox(height: 10.0.h);
Widget verticalSpaceMedium = SizedBox(height: 25.0.h);
Widget verticalSpaceSpecial = SizedBox(height: 40.0.h);
Widget verticalSpaceLarge = SizedBox(height: 50.0.h);
Widget verticalSpaceMassive = SizedBox(height: 120.0.h);

Widget spacedDivider = Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0.h),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height.h);
Widget horizontalSpace(double width) => SizedBox(width: width.w);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0}) =>
    (screenHeight(context) - offsetBy) / dividedBy;

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0}) =>
    (screenWidth(context) - offsetBy) / dividedBy;

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double height(double height) => height.h;

double width(double width) => width.w;
