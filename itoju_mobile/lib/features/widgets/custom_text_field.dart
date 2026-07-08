// ignore_for_file: library_private_types_in_public_api

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';

import 'custom_text.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? title, hintText, initialValue;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final bool filled;
  final Function(String)? onChanged;
  final FormFieldValidator<String?>? valdator;
  final double titleFontSize;
  final double width;
  const CustomTextField(
      {Key? key,
      this.title,
      this.obscure = false,
      this.controller,
      this.inputType,
      this.hintText,
      this.filled = false,
      this.valdator,
      this.titleFontSize = 16,
      this.initialValue,
      this.width = double.infinity,
      this.onChanged})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.title == null ? 60.h : 100.h,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: !(widget.title == null),
            child: Column(
              children: [
                CustomText(
                  widget.title,
                  fontSize: widget.titleFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColorPurple,
                ),
                verticalSpaceTiny,
              ],
            ),
          ),
          SizedBox(
            height: 60.h,
            width: double.infinity,
            child: Center(
              child: TextFormField(
                initialValue: widget.initialValue,
                keyboardType: widget.inputType,
                controller: widget.controller,
                obscureText: !isPasswordVisible && widget.obscure,
                validator: widget.valdator,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  filled: widget.filled,
                  fillColor: AppColors.primaryColorPurple.withOpacity(0.1),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                      color: AppColors.hintGrey,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                  suffixIcon: widget.obscure
                      ? IconButton(
                          icon: Icon(isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          color: AppColors.primaryColorPurple)
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primaryColorPurple),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.primaryColorPurple),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
