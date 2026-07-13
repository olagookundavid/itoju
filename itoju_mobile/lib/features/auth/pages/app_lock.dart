import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/core/helpers/biometric_helper.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';

/// AppLockScreen gates access to the app behind a biometric / device-passcode
/// check. Two modes:
///  - startup gate: pass [child]; once unlocked it renders [child] in place.
///  - resume overlay: pass [onUnlocked]; once unlocked it invokes the callback
///    (typically to pop itself off the navigator).
class AppLockScreen extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onUnlocked;
  const AppLockScreen({super.key, this.child, this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _unlocked = false;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attempt());
  }

  Future<void> _attempt() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    final ok = await LocalAuthApi.unlockApp();
    if (!mounted) return;
    if (ok) {
      if (widget.onUnlocked != null) {
        widget.onUnlocked!();
      } else {
        setState(() => _unlocked = true);
      }
    } else {
      setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked && widget.child != null) return widget.child!;

    // The lock must not be dismissible via the system back button/gesture.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 64.r, color: AppColors.primaryColorPurple),
                verticalGap(20),
                CustomText(
                  'Itoju is locked',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColorPurple,
                ),
                verticalGap(8),
                const CustomText(
                  'Unlock with your fingerprint, face, or device passcode to continue.',
                  textAlign: TextAlign.center,
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  maxline: 3,
                ),
                verticalGap(28),
                _authenticating
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _attempt,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Unlock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColorPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 12.h),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget verticalGap(double h) => SizedBox(height: h.h);
}
