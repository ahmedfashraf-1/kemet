import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class LandmarksFilter extends StatefulWidget {
  final List<String> categories;
  final List<String> cities;
  final String selectedCategory;
  final String selectedCity;
  final void Function(String) onCategorySelected;
  final void Function(String) onCitySelected;
  final String Function(BuildContext, String) labelBuilder;

  const LandmarksFilter({
    super.key,
    required this.categories,
    required this.cities,
    required this.selectedCategory,
    required this.selectedCity,
    required this.onCategorySelected,
    required this.onCitySelected,
    required this.labelBuilder,
  });

  @override
  State<LandmarksFilter> createState() => _FilterState();
}

class _FilterState extends State<LandmarksFilter> {
  static const Color _gold = Color(0xFFD4AF37);

  void _showCityPicker() {
    final allCities = ['All', ...widget.cities];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(color: _gold.withOpacity(0.18)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'SELECT CITY',
                style: GoogleFonts.cinzel(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 12.h),
              ...allCities.map((city) {
                final isActive = city == 'All'
                    ? widget.selectedCity.isEmpty
                    : widget.selectedCity == city;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onCitySelected(city);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _gold.withOpacity(0.12)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isActive
                            ? _gold.withOpacity(0.5)
                            : Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.labelBuilder(context, city),
                            style: GoogleFonts.cinzel(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isActive ? _gold : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (isActive)
                          Icon(Icons.check_rounded, color: _gold, size: 18.sp),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ['All', ...widget.categories];
    final activeCityLabel = widget.selectedCity.isEmpty
        ? widget.labelBuilder(context, 'All')
        : widget.labelBuilder(context, widget.selectedCity);

    return SizedBox(
      height: 38.h,
      child: Row(
        children: [
          SizedBox(width: 24.w),

          // ── City Dropdown ──
          GestureDetector(
            onTap: _showCityPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              height: 38.h,
              decoration: BoxDecoration(
                color: widget.selectedCity.isEmpty
                    ? AppColors.cardBackground
                    : _gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: widget.selectedCity.isEmpty
                      ? AppColors.subtleGoldBorder
                      : _gold.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13.sp,
                    color: widget.selectedCity.isEmpty
                        ? AppColors.textSecondary
                        : _gold,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    activeCityLabel.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: widget.selectedCity.isEmpty
                          ? AppColors.textSecondary
                          : _gold,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14.sp,
                    color: widget.selectedCity.isEmpty
                        ? AppColors.textSecondary
                        : _gold,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 10.w),

          // ── Category Chips ──
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: allCategories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final cat = allCategories[index];
                final isActive = cat == 'All'
                    ? widget.selectedCategory.isEmpty
                    : widget.selectedCategory == cat;

                return GestureDetector(
                  onTap: () => widget.onCategorySelected(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.mainGold
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isActive
                            ? AppColors.mainGold
                            : AppColors.subtleGoldBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.labelBuilder(context, cat).toUpperCase(),
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
          ),

          SizedBox(width: 24.w),
        ],
      ),
    );
  }
}