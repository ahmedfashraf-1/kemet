import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';

class HeroSlider extends StatefulWidget {
  const HeroSlider({super.key});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  final List<Map<String, String>> _slides = [
    {
      'image': 'images/heroScreen.png',
      'title': 'Chasing Shadows',
      'subtitle': 'Luxor, Egypt',
    },
    {
      'image': 'images/heroScreen2.png',
      'title': 'Every Stone Tells a Story',
      'subtitle': 'Valley of the Kings',
    },
    {
      'image': 'images/heroScreen3.png',
      'title': 'Walk Through History',
      'subtitle': 'Giza, Egypt',
    },
  ];

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOut),
    );
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
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              height: 220.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Stack(
                    children: [
                      // image + zoom
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
                              color: AppColors.cardBackground,
                              child: const Center(
                                child: Icon(Icons.landscape,
                                    color: AppColors.mainGold, size: 60),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.screenBackground.withOpacity(0.85),
                              ],
                              stops: const [0.3, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // text
                      Positioned(
                        bottom: 20.h,
                        left: 20.w,
                        right: 20.w,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: index == _currentIndex ? 1.0 : 0.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide['title']!,
                                style: GoogleFonts.cormorant(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainGold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: AppColors.textSecondary,
                                      size: 12.sp),
                                  SizedBox(width: 3.w),
                                  Text(
                                    slide['subtitle']!,
                                    style: TextStyle(
                                      fontSize: 12.sp,
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
        SizedBox(height: 12.h),
        // dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: isActive ? 14.w : 7.w,
              height: 7.h,
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