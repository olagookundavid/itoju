import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/auth/notifiers/forgot_password_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/reset_otp_page.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:toastification/toastification.dart';

/// Records code requests instead of calling the server (Dio's real timers
/// don't run on a widget test's fake clock).
class _FakeReset extends ForgotPasswordNotifier {
  _FakeReset(Ref ref) : super(ref, Dio()) {
    state = state.copyWith(email: 'tester@example.com', loadStatus: Loader.loaded);
  }
  final sent = <String>[];

  @override
  Future<ApiResponse> forgotPassword(String email) async {
    sent.add(email);
    return ApiResponse(successMessage: 'If an account exists, a code has been sent.');
  }
}

void main() {
  test('a code request sends the email without stray spaces', () async {
    final bodies = <Map>[];
    final dio = Dio()
      ..interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        bodies.add(o.data as Map);
        h.resolve(Response(
            requestOptions: o, statusCode: 200, data: {'message': 'sent'}));
      }));
    final container =
        ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
    addTearDown(container.dispose);

    await container
        .read(forgotPasswordNotifier.notifier)
        .forgotPassword(' tester@example.com ');
    expect(bodies.single['email'], 'tester@example.com');
    expect(container.read(forgotPasswordNotifier).email, 'tester@example.com',
        reason: 'verify and reset reuse the same email');
  });

  // The "Resend" link on the code screen used to do nothing at all.
  testWidgets('Resend waits out the cooldown, then asks for a new code',
      (tester) async {
    late _FakeReset fake;
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        forgotPasswordNotifier.overrideWith((ref) => fake = _FakeReset(ref)),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const ToastificationWrapper(
            child: MaterialApp(home: ResetOtp())),
      ),
    ));
    await tester.pump();

    // A code was just sent: the link counts down and can't be tapped yet.
    expect(find.text("Didn't get it? Resend in 60s"), findsOneWidget);
    await tester.tap(find.textContaining('Resend'));
    await tester.pump();
    expect(fake.sent, isEmpty);

    await tester.pump(const Duration(seconds: 60));
    expect(find.text("Didn't receive the code? Resend"), findsOneWidget);
    await tester.tap(find.text("Didn't receive the code? Resend"));
    await tester.pump();
    await tester.pump();

    expect(fake.sent, ['tester@example.com']);
    // The countdown starts again for the new code.
    expect(find.textContaining('Resend in'), findsOneWidget);

    // Let the toast and the countdown finish so no timer is left pending.
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
