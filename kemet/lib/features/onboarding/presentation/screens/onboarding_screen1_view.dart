import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/widgets/animated_gold_button.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../../core/routing/routes.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B),
      body: Stack(
        children: [
          // 1 background
          Image.asset(
            'images/onboarding1_bg.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          //////////////////////////////////////////// 2 Gradienttttttttttttt
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

          // 3 safe area
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 5.h),
                  const Spacer(flex: 5),

                  // logo
                  Transform.translate(
                    offset: Offset(0, 10.h),
                    child: Opacity(
                      opacity: 0.7,
                      child: Image.asset(
                        'images/logo.png',
                        width: 230.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    "KEMET",
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      "Step into the land where history, culture, and civilization began",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.lightGold,
                        fontSize: 16.sp,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: true),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  AnimatedGoldButton(
                    text: "EXPLORE",
                    onTap: () {
                      context.pushNamed(Routes.onBoardingScreen2);
                    },
                  ),

                  SizedBox(height: 30.h),

                  // skip
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(Routes.LoginView); 
                    },
                    child: Text(
                      "skip",
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          248,
                          224,
                          169,
                        ).withOpacity(0.5),
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

  // dots
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
