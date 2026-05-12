import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';

class StoreHeroSlider extends StatefulWidget {
  const StoreHeroSlider({super.key});

  @override
  State<StoreHeroSlider> createState() => _StoreHeroSliderState();
}

class _StoreHeroSliderState extends State<StoreHeroSlider>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  final List<Map<String, String>> _slides = [
    {
      'image': 'images/store_hero1.png',
      'titleKey': 'hero_slide_1_title',
      'subtitleKey': 'hero_slide_1_subtitle',
    },
    {
      'image': 'images/store_hero2.png',
      'titleKey': 'hero_slide_2_title',
      'subtitleKey': 'hero_slide_2_subtitle',
    },
    {
      'image': 'images/store_hero3.png',
      'titleKey': 'hero_slide_3_title',
      'subtitleKey': 'hero_slide_3_subtitle',
    },
  ];

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
        CurvedAnimation(parent: _zoomController, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _zoomController.forward();
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _zoomController.reset();
    _zoomController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 150.h, // أصغر من الـ home (220.h)
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Stack(
                    children: [
                      // ── Image + Zoom ──
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _zoomAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: index == _currentIndex
                                  ? _zoomAnimation.value
                                  : 1.0,
                              child: child,
                            );
                          },
                          child: Image.asset(
                            slide['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.cardBackground,
                                    AppColors.inputBackground,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.storefront_outlined,
                                  color: AppColors.mainGold.withOpacity(0.4),
                                  size: 40.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ── Gradient ──
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.screenBackground.withOpacity(0.8),
                              ],
                              stops: const [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // ── Text ──
                        PositionedDirectional(
                          bottom: 14.h,
                          start: 16.w,
                          end: 16.w,
                          child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: index == _currentIndex ? 1.0 : 0.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide['titleKey'] != null
                                    ? context.tr(slide['titleKey']!)
                                    : (slide['title'] ?? ''),
                                style: GoogleFonts.cormorant(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainGold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.textSecondary,
                                    size: 10.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    slide['subtitleKey'] != null
                                        ? context.tr(slide['subtitleKey']!)
                                        : (slide['subtitle'] ?? ''),
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // ── Dots ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 12.w : 5.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.mainGold
                    : AppColors.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}