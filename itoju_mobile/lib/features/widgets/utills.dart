import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Pallete {
  static const Color primaryColor = Color(0xff08CB7B);
  static const Color ascentColor = Color(0xff5464D5);
  static const Color secondaryColor = Color(0xff080B4D);
  static const Color success = Color(0xff2A9341);
  static const Color failure = Color(0xffD72727);
  static const Color appBar = Color(0xff292D61);
  static const Color lightPink = Color(0xffEDEBF8);
  static const Color purple = Color(0xff9954D5);
}
//  AppWidget.showViewDialog(
//                         context: context,
//                         dismissible: true,
//                         dialog: AppDialog(
//                           context: context,
//                           title: "Success",
//                           icon: const AppImage(
//                               path: AppAssets.successIcon, isNetwork: false),
//                           buttonAction: () {
//                             Navigator.of(context).pop();
//                             Navigator.of(context).pop();
//                             Navigator.of(context).pop();
//                             Navigator.of(context).pop();
//                           },
//                           message: response.successMessage,
//                         ));

class AppWidget {
  static Future showViewDialog({
    required BuildContext context,
    required Widget dialog,
    bool dismissible = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (ctx) {
        return dialog;
      },
    );
  }
}

extension EmptyPadding on num {
  SizedBox get ph => SizedBox(
        height: toDouble().h,
      );

  SizedBox get pw => SizedBox(
        width: toDouble().w,
      );
}

String assets(String name, [String? type]) {
  return type == null ? 'assets/images/$name.png' : 'assets/images/$name.$type';
}

List<String> removeDuplicates(List<String> list) {
  Set<String> set = Set.from(list);
  return set.toList();
}
