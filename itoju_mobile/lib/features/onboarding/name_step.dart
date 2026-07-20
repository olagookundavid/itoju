import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

/// The last onboarding step: "What should we call you?" — shown on every path.
/// Anonymous users type a name (stored locally); signed-in users see the field
/// prefilled from their account (alias, falling back to first name) and can
/// proceed or change it. Saving marks onboarding done, so relaunching can only
/// reach the dashboard once this step completes.
class NameStep extends ConsumerStatefulWidget {
  const NameStep({super.key});

  @override
  ConsumerState<NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<NameStep> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = HiveStorage.get(HiveKeys.localName) as String?;
    if (existing != null && existing.isNotEmpty) {
      _controller.text = existing;
    } else {
      _prefillFromAccount();
    }
  }

  /// Signed-in users (they logged in / signed up just before this step) get the
  /// field prefilled from their account: alias if they've set one before, else
  /// the first name they registered with. Best-effort — offline just leaves the
  /// field empty.
  Future<void> _prefillFromAccount() async {
    if (!await Session.hasToken()) return;
    await ref.read(profileProvider.notifier).getProfile();
    if (!mounted || _controller.text.isNotEmpty) return;
    final user = ref.read(profileProvider).userModel;
    final name = (user?.alias?.isNotEmpty == true)
        ? user!.alias!
        : (user?.firstName ?? '');
    if (name.isNotEmpty) _controller.text = name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    // A name is required — the app greets the user by it everywhere, so there
    // is no skip path out of this step.
    if (name.isEmpty) {
      getAlert('Please enter your name to continue');
      return;
    }
    await HiveStorage.put(HiveKeys.localName, name);
    // Roam the display name with the account (no-op offline/anonymous).
    if (await Session.hasToken()) {
      ref.read(profileProvider.notifier).updateAlias(name);
    }
    await _goToApp();
  }

  Future<void> _goToApp() async {
    // Name is done — advance to the health setup steps (what to track, then
    // diagnosed conditions). The dashboard is reached only once those finish,
    // so a kill here resumes at the tracking step.
    await OnboardingStage.set(OnboardingStage.setup);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AddTrackedMetrics()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              Text(
                'What should we call you?',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This is how the app greets you. You can change it anytime.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                ),
              ),
              SizedBox(height: 32.h),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _continue(),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColorPurple, width: 2),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColorPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
