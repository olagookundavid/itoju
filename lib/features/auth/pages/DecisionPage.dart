// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/pages/oauth_signup.dart';
import 'package:itoju_mobile/features/auth/pages/signUp_Page.dart.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/components/asset/constants/images.dart';
import 'package:itoju_mobile/features/widgets/coming_soon_dialog.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';

class DecisionPage extends StatefulWidget {
  const DecisionPage({Key? key}) : super(key: key);

  @override
  _DecisionPageState createState() => _DecisionPageState();
}

class _DecisionPageState extends State<DecisionPage> {
  @override
  Widget build(BuildContext context) {
    // final chooseLoginModel = Provider.of<ChooseLoginViewModel>(context);
    // final authModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: 320.w,
            height: 180.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage(Images.DecisionPage),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                    const Color(0xff5142AB).withOpacity(0.50),
                    BlendMode.hardLight),
              ),
            ),
          ),
          Positioned(
            top: 370.h,
            left: 15.w,
            right: 15.w,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      "Welcome to Itoju",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    )
                  ],
                ),
                verticalSpaceTiny,
                SizedBox(
                  height: 40.h,
                  width: 280.w,
                  child: CustomText(
                    "You are only a few steps from tracking your health",
                    fontSize: 12.sp,
                    textAlign: TextAlign.center,
                  ),
                ),
                verticalSpaceMedium,
                CustomButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()));
                    // chooseLoginModel.moveToSignUp();
                  },
                  buttonStyle: buttonStyle(buttonWidth: 176.w, radius: 10),
                  child: CustomText(
                    "Create Account",
                    fontSize: 14.sp,
                  ),
                ),
                verticalSpaceMedium,
                CustomText(
                  "Or Sign Up using your",
                  fontSize: 12.sp,
                  textAlign: TextAlign.center,
                ),
                verticalSpaceMedium,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const OauthSignUpPage(
                                auth: Oauth.Google,
                              );
                            },
                          ));
                        },
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            "asset/png/Google.png",
                            height: 30.h,
                            width: 20.w,
                          ),
                        ),
                      ),
                      horizontalSpaceMedium,
                      InkWell(
                        onTap: () => showComingSoonDialog(context, 'Facebook'),
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.asset(
                              "asset/png/Facebook.png",
                            ),
                          ),
                        ),
                      ),
                      horizontalSpaceMedium,
                      InkWell(
                        onTap: () => showComingSoonDialog(context, 'Apple'),
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white),
                          child: Center(
                            child: Icon(
                              Icons.apple,
                              size: 30.r,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      "Already have an account? ",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInPage()));
                      },
                      child: CustomText(
                        " Log In",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
