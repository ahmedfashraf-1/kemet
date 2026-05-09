import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

// ─── Icon mapping لكل category محتملة ───────────────────────────────────────
IconData _iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'all':
      return Icons.grid_view_rounded;
    case 'figurines':
      return Icons.account_balance_outlined;
    case 'jewelry':
      return Icons.diamond_outlined;
    case 'home decor':
    case 'decor':
      return Icons.home_outlined;
    case 'accessories':
      return Icons.watch_outlined;
    case 'bags':
      return Icons.shopping_bag_outlined;
    case 'pottery':
      return Icons.local_florist_outlined;
    default:
      return Icons.category_outlined;
  }
}

// ─── Widget ──────────────────────────────────────────────────────────────────
class StoreCategoriesBar extends StatelessWidget {
  final List<String> categories; 
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const StoreCategoriesBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORIES',
                style: GoogleFonts.cinzel(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              GestureDetector(
                onTap: () => onCategorySelected('All'),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // ── Categories List ──
        SizedBox(
          height: 68.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isActive = selectedCategory == cat;
              return _CategoryChip(
                label: cat,
                icon: _iconForCategory(cat),
                isActive: isActive,
                onTap: () => onCategorySelected(cat),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 56.w,
        decoration: BoxDecoration(
        color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isActive ? AppColors.mainGold : AppColors.subtleGoldBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isActive ? AppColors.mainGold : AppColors.textSecondary,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 7.sp,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.mainGold
                    : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}