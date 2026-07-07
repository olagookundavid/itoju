import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/main.dart';
import 'package:toastification/toastification.dart';

class AlertFlushbar {
  static void showNotification({
    bool isWarning = false,
    String message = '',
  }) {
    final context = navigatorKey.currentContext;
    context != null
        ? Flushbar(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            margin: EdgeInsets.all(8.r),
            borderRadius: BorderRadius.circular(8.r),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            reverseAnimationCurve: Curves.decelerate,
            forwardAnimationCurve: Curves.elasticOut,
            backgroundColor:
                isWarning ? Colors.red : AppColors.primaryColorPurple,
            isDismissible: true,
            duration: const Duration(seconds: 4),
            showProgressIndicator: false,
            boxShadows: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                offset: const Offset(0.0, 2.0),
                blurRadius: 3.0,
              ),
            ],
            icon: isWarning
                ? Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        color: Colors.transparent,
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
            message: message,
            messageColor: Colors.white,
            messageSize: 18,
          ).show(context)
        : 0.ph;
  }
}

getAlert(String msg, {bool isWarning = true}) {
  AlertService.show(msg,
      type: isWarning ? ToastificationType.error : ToastificationType.success);
}

class AlertService {
  static void show(String message,
      {ToastificationType type = ToastificationType.success}) {
    var isWarning = type == ToastificationType.error;
    toastification.show(
      type: type,
      style: ToastificationStyle.fillColored, // sleek look
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(
        isWarning ? "Error" : "Success",
        style: TextStyle(fontSize: 15.sp),
      ),
      description: Text(message, style: TextStyle(fontSize: 16.sp)),
      alignment: Alignment.topCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      icon: isWarning
          ? Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.transparent,
                  shape: BoxShape.circle),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
      showIcon: true,
      primaryColor: isWarning ? Colors.red : AppColors.primaryColorPurple,
      // backgroundColor: isWarning ? Colors.red : AppColors.primaryColorPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          offset: const Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      ],
    );
  }
}

// Usage
// AlertService.show(context, "Saved successfully");
// AlertService.show(context, "Network Error", type: ToastificationType.error);

/*

class AlertService {
  static void show(String message, {bool isError = false}) {
    showSimpleNotification(
      Text(message),
      background: isError ? Colors.red : Colors.purple, // Your AppColor
      elevation: 2,
      duration: const Duration(seconds: 4),
      slideDismissDirection: DismissDirection.up,
      contentPadding: const EdgeInsets.all(16),
      leading: isError
          ? const Icon(Icons.close, color: Colors.white)
          : const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}


*/

// Usage (Notice: No context needed!)
// AlertService.show("Data saved!");
// AlertService.show("Server Error", isError: true);
