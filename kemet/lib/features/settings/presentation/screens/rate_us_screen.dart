import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  double _rating = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsVisuals.pageBackground,
      appBar: AppBar(
        backgroundColor: SettingsVisuals.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: PremiumHeader(title: context.tr('rate_us').toUpperCase()),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        children: [
          PremiumCard(
            children: [
              Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome_outlined, color: const Color(0xFFC9A34E), size: 38.sp),
                    SizedBox(height: 14.h),
                    Text(
                      context.tr('rate_enjoying'),
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.tr('rate_description'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.64), fontSize: 13.sp, height: 1.5),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        final selected = star <= _rating;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star.toDouble()),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Icon(
                              selected ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 34.sp,
                              color: selected ? const Color(0xFFC9A34E) : Colors.white24,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A34E),
                foregroundColor: const Color(0xFF151008),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text(context.tr('leave_review')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.parse('https://example.com/kemet/rate');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

