import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D0B), 
      body: Stack(
        children: [
          // 1. Background Image
          Image.asset(
            'images/onboarding1_bg.png',
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // 2. Gradient
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

          // 3. Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w), 
              child: Column(
                children: [
                  const Spacer(flex: 4),

                
                  Opacity(
                    opacity: 0.5, 
                    child: Image.asset(
                      'images/headphone.png',
                      width: 200.w, 
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Text(
                    "IMMERSE\nIN HISTORY",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant( // feeeh kteer cizel w hgat kda srasho 
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDAAB5F),
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 15.h),

                  Text(
                    "Experience the chronicles of the Pharaohs through sound.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(isActive: false),
                      _buildDot(isActive: true),
                      _buildDot(isActive: false),
                      _buildDot(isActive: false),
                    ],
                  ),

                  SizedBox(height: 30.h),

                
                  GestureDetector(
                    onTap: () {
                      // onboarding 3 y marieeeeeeeeeeeeeem
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

                  // Skip Button
                  GestureDetector(
                    onTap: () {
                      // login p2aaaa
                    },
                    child: Text(
                      "skip",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
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
      width: isActive ? 12.w : 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFC69C5D) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}