import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/constants/colors.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _items = const [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.explore_outlined, 'label': 'Maps'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: widget.child,
      floatingActionButton: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDAAB5F), Color(0xFF96703D)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mainGold.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: MaterialButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kemet AI',
                style: GoogleFonts.cinzel(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDarkOnGold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.textDarkOnGold,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.screenBackground.withOpacity(0.92),
          border: Border(
            top: BorderSide(
              color: AppColors.subtleGoldBorder.withOpacity(0.15),
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 32.w,
          right: 32.w,
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 12.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (index) {
            final isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[index]['icon'] as IconData,
                    color: isActive
                        ? AppColors.mainGold
                        : AppColors.textSecondary,
                    size: 24.sp,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _items[index]['label'] as String,
                    style: GoogleFonts.cinzel(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isActive
                          ? AppColors.mainGold
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}