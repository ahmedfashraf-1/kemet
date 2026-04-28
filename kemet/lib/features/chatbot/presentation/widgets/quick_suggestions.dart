import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class QuickSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const QuickSuggestions({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(suggestion),
              borderRadius: BorderRadius.circular(999.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF26201B),
                      AppColors.cardBackground.withOpacity(0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.mainGold.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 13.sp,
                      color: AppColors.mainGold.withOpacity(0.92),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      suggestion,
                      style: GoogleFonts.cinzel(
                        color: AppColors.mainGold,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

