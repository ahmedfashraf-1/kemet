import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';
import '../../../core/helpers/extensions.dart';
import '../../../core/routing/routes.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        children: [
          Image.asset(
            'images/onboarding1_bg.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F0D0B).withOpacity(0.2),
                  const Color(0xFF0A0E14).withOpacity(0.8),
                  const Color(0xFF1A120B).withOpacity(1.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  const Spacer(flex: 5),

                  Transform.translate(
                    offset: Offset(0, -2.h),
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        'images/image1_onboarding_screen3.png',
                        width: 200.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 0.h),

                  Text(
                    "CHAT WITH",
                    style: GoogleFonts.cormorant(
                      textStyle: TextStyle(
                        color: AppColors.mainGold,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -10.h),
                    child: Text(
                      "KEMET AI",
                      style: GoogleFonts.cormorant(
                        textStyle: TextStyle(
                          color: AppColors.mainGold,
                          fontSize: 42.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      "Deep, instant answers in your language. Discover secrets and hidden stories.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightGold.withOpacity(0.8),
                        fontSize: 16.sp,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: true),
                      _buildDot(isActive: false),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  GestureDetector(
                    onTap: () {
                      context.pushNamed(Routes.onBoardingScreen4);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 55.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: const Color(0xFFE3B06C).withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                          color: const Color(0xFFE3B06C),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  GestureDetector(
                    onTap: () {
                      //context.pushNamed(Routes.loginScreen); // register or home
                    },
                    child: Text(
                      "skip",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 35.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 14.w : 7.w,
      height: 7.h,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFC69C5D)
            : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
