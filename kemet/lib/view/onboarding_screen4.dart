import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/helpers/extensions.dart';
import '../../core/routing/routes.dart';
import 'package:kemet/core/animated_gold_button.dart';


class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

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

                  // logo
                  Transform.translate(
                    offset: Offset(0, -2.h),
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(
                        'images/image1_onboarding_screen4.png',
                        width: 280.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Transform.translate(
                    offset: Offset(0, -10.h),
                    child: Text(
                      "GUIDE & MAPS",
                      style: GoogleFonts.cormorant(
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 218, 171, 95),
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      "Access essential info. Opening hours, ticket prices, and routes, perfectly planned.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 234, 197, 141).withOpacity(0.8),
                        fontSize: 16.sp,
                        height: 1.4,
                      ),
                    ),
                  ),

                  SizedBox(height: 37.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoItem("Hours", "08:00 - 17:00"),
                        _buildInfoItem("Tickets", "450 EGP"),
                        _buildInfoItem("Distance", "1.2 KM"),
                      ],
                    ),
                  ),

                  SizedBox(height: 50.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: true),
                    ],
                  ),

                  SizedBox(height: 20.h),
/*
                  GestureDetector(
                    onTap: () {
                      //context.pushNamed(Routes.loginScreen); // or home
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE3B06C), Color(0xFF96703D)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "START JOURNEY",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
*/
                  AnimatedGoldButton(
                    text: "START JOURNEY",
                    onTap: () {
                      //context.pushNamed(Routes.login); // register or home
                    },
                  ),

                  SizedBox(height: 39.h),
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

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // المعين الذهبي الصغير
            Transform.rotate(
              angle: 0.8, // تدوير المربع ليصبح معين
              child: Container(
                width: 8.w,
                height: 8.w,
                color: const Color(0xFFC69C5D),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            value,
            style: TextStyle(
              //color: Colors.grey[500],
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}