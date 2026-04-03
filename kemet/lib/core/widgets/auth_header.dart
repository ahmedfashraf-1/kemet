import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, 10.h),
          child: Opacity(
            opacity: 0.7,
            child: Image.asset(
              'images/KEMET Logo.png',
              width: 170.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'KEMET',
          style: GoogleFonts.cormorant(
            textStyle: TextStyle(
              color: AppColors.mainGold,
              fontSize: 46.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(0, 5),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'BEGIN YOUR JOURNEY THROUGH HISTORY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.lightGold,
            fontSize: 13.sp,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

