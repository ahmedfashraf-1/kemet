import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  OutlineInputBorder _goldBorder({double width = 1.0}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(
      color: AppColors.mainGold.withOpacity(0.30),
      width: width,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator == null ? null : (value) => validator!(value ?? ''),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: AppColors.mainGold.withOpacity(0.30),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: AppColors.mainGold.withOpacity(0.06),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        border: _goldBorder(),
        enabledBorder: _goldBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.mainGold, width: 1),
        ),
        errorBorder: _goldBorder(),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.mainGold, width: 1),
        ),
      ),
    );
  }
}

