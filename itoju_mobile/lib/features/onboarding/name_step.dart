import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';

/// Local-first onboarding: ask only for a name so the user can start using the
/// app immediately, with no account and no network. The name is stored locally
/// (Hive) and later prefills sign-up if they choose to enable cloud sync.
class NameStep extends StatefulWidget {
  const NameStep({super.key});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = HiveStorage.get(HiveKeys.localName) as String?;
    if (existing != null) _controller.text = existing;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      await HiveStorage.put(HiveKeys.localName, name);
    }
    _goToApp();
  }

  void _goToApp() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
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
                'No account needed — you can start tracking right away. '
                'You can sign in later to back up and sync your data.',
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
              SizedBox(height: 8.h),
              Center(
                child: TextButton(
                  onPressed: _goToApp,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.textGrey),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
