import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class SettingsDocumentScreen extends StatelessWidget {
  const SettingsDocumentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsVisuals.pageBackground,
      appBar: AppBar(
        backgroundColor: SettingsVisuals.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: PremiumHeader(title: title),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        children: [
          PremiumCard(
            children: [
              Padding(
                padding: EdgeInsets.all(18.r),
                child: Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 14.sp,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

