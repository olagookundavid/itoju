import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';

/// Shared "this device is linked to another account" prompt.
///
/// Shown when a sign-in/sign-up resolves to a DIFFERENT server user than the one
/// this device's health data is bound to. The user must choose: erase the
/// previous account's local data and continue, or cancel. Without this, two
/// people's health records could mix on a shared device.
///
/// Returns true when the user chose to erase and continue (the previous user's
/// local data has been wiped and the device rebound via [confirmAccountSwitch]).
/// Returns false on cancel, in which case the just-minted session is dropped and
/// the previous account's data is left untouched.
Future<bool> showAccountSwitchDialog(
    BuildContext context, WidgetRef ref) async {
  final erase = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Different account', style: TextStyle(fontSize: 20.sp)),
      content: Text(
        'This device is linked to another account. To sign in with this '
        "account, the previous account's health data on this device must be "
        'erased.',
        style: TextStyle(fontSize: 15.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Erase & continue',
              style: TextStyle(fontSize: 15.sp, color: Colors.red)),
        ),
      ],
    ),
  );
  if (erase == true) {
    await ref.read(loginNotifier.notifier).confirmAccountSwitch();
    return true;
  }
  // Cancel: drop the new session; the previous account's data stays untouched.
  await SecureStore.write(SecureKeys.token, null);
  await SecureStore.write(SecureKeys.currentServerUserId, null);
  return false;
}
