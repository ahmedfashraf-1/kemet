import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';

class SettingsVisuals {
  static const Color pageBackground = Color(0xFF0B0B0B);
  static const Color cardBackground = Color(0xFF171717);
  static const Color borderColor = Color(0x22FFFFFF);
  static const Color dividerColor = Color(0x1FFFFFFF);
  static const Color dangerColor = Color(0xFFD34B4B);
  static const Color mutedText = Color(0x99FFFFFF);
}

class PremiumSectionTitle extends StatelessWidget {
  const PremiumSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFFC9A34E),
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? EdgeInsets.symmetric(vertical: 4.h);

    return Container(
      decoration: BoxDecoration(
        color: SettingsVisuals.cardBackground,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SettingsVisuals.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: resolvedPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class PremiumDivider extends StatelessWidget {
  const PremiumDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 14.w,
      endIndent: 14.w,
      color: SettingsVisuals.dividerColor,
    );
  }
}

class PremiumTileShell extends StatelessWidget {
  const PremiumTileShell({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: child,
      ),
    );
  }
}

class PremiumListTile extends StatelessWidget {
  const PremiumListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return PremiumTileShell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 21.sp, color: iconColor ?? Colors.white.withValues(alpha: 0.85)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor ?? Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: subtitleColor ?? Colors.white.withValues(alpha: 0.62),
                      fontSize: 12.sp,
                    ),
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
          trailing ?? Icon(Icons.chevron_right_rounded, size: 22.sp, color: Colors.white.withValues(alpha: 0.65)),
        ],
      ),
    );
  }
}

class PremiumSwitchTile extends StatelessWidget {
  const PremiumSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PremiumTileShell(
      child: Row(
        children: [
          Icon(icon, size: 21.sp, color: Colors.white.withValues(alpha: 0.85)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 12.sp,
                    ),
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC9A34E)),
              ),
            )
          else
            Switch.adaptive(
              value: value,
              activeThumbColor: const Color(0xFFC9A34E),
              activeTrackColor: const Color(0x66C9A34E),
              inactiveThumbColor: Colors.white70,
              inactiveTrackColor: Colors.white24,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

class PremiumHeader extends StatelessWidget {
  const PremiumHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            color: AppColors.mainGold,
            fontSize: 18.sp,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }
}

Future<T?> pushPremiumPage<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, animation, secondaryAnimation) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(0.16, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: animation.drive(slide), child: child),
        );
      },
    ),
  );
}

Future<bool> showPremiumDeleteAccountDialog(BuildContext context) async {
  HapticFeedback.selectionClick();

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierLabel: context.tr('delete_account'),
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 420.w),
                  padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xCC1F1F1F), Color(0xB3121212)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('delete_account_confirm_title'),
                        style: TextStyle(
                          color: const Color(0xFFC9A34E),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        context.tr('delete_account_confirm_message'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13.sp,
                          height: 1.55,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: 22.h),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(dialogContext).pop(false);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFC9A34E),
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                            ),
                            child: Text(
                              context.tr('cancel'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: const Color(0xFFD34B4B),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 11.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              context.tr('delete'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  return result ?? false;
}

