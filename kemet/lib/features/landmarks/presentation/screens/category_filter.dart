import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class CategoryFilter extends StatefulWidget {
  final List<String> categories;
  final void Function(String selected)? onSelected;

  const CategoryFilter({super.key, required this.categories, this.onSelected});

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final all = ['All', ...widget.categories];

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        physics: const BouncingScrollPhysics(),
        itemCount: all.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final isActive = index == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onSelected?.call(all[index]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isActive ? AppColors.mainGold : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isActive
                      ? AppColors.mainGold
                      : AppColors.subtleGoldBorder,
                ),
              ),
              child: Center(
                child: Text(
                  all[index].toUpperCase(),
                  style: GoogleFonts.cinzel(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isActive
                        ? AppColors.textDarkOnGold
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
