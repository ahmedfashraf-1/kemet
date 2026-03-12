import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/extensions.dart';
import '../../core/routing/routes.dart';


class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                stops: const [0.0, 0.5,1.0],
                colors: [
                  Colors.black.withOpacity(0.2),
                  //  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.95),
                ],
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
                        width: 275.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),


                  SizedBox(height: 0.h),

                  Text(
                    "CHAT WITH",
                    style: GoogleFonts.cormorant(
                      textStyle: TextStyle(
                        color: const Color.fromARGB(255, 218, 171, 95),
                        fontSize: 46.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -10.h),
                    child:
                      Text(
                        "KEMET AI",
                        style: GoogleFonts.cormorant(
                          textStyle: TextStyle(
                            color: const Color.fromARGB(255, 218, 171, 95),
                            fontSize: 46.sp,
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
                        color: const Color.fromARGB(255, 234, 197, 141).withOpacity(0.8),
                        fontSize: 16.sp,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: true),
                      _buildDot(isActive: false),
                    ],
                  ),

                  SizedBox(height: 20.h),

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

                  SizedBox(height: 20.h),

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


                  SizedBox(height: 15.h),
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
        color: isActive ? const Color(0xFFC69C5D) : Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}