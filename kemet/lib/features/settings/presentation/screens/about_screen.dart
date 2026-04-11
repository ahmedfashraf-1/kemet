import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsVisuals.pageBackground,
      appBar: AppBar(
        backgroundColor: SettingsVisuals.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.tr('about'),
          style: TextStyle(
            color: const Color(0xFFC9A34E),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 18.h),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'images/log11o.png',
                          width: 92.w,
                          height: 92.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Kemet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      context.tr('about_tagline'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 13.sp,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      context.tr('version'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      context.tr('last_updated'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      context.tr('developed_by'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _checkForUpdates,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFC9A34E),
                          foregroundColor: const Color(0xFF1A1408),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        icon: const Icon(Icons.system_update_alt_rounded),
                        label: Text(context.tr('check_updates')),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _rateApp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC9A34E),
                          side: BorderSide(
                            color: const Color(0xFFC9A34E).withValues(alpha: 0.55),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        icon: const Icon(Icons.star_border_rounded),
                        label: Text(context.tr('rate_app')),
                      ),
                    ),
                    const Spacer(flex: 3),
                    Text(
                      context.tr('copyright'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    final uri = Uri.parse('https://example.com/kemet/updates');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _rateApp() async {
    final uri = Uri.parse('https://example.com/kemet/rate');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

