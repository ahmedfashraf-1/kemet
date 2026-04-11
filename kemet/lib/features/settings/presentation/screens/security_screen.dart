import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/settings/presentation/cubit/password_reset_cubit.dart';
import 'package:kemet/features/settings/presentation/cubit/security_cubit.dart';
import 'package:kemet/features/settings/presentation/screens/change_password_screen.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SettingsVisuals.pageBackground,
          appBar: AppBar(
            backgroundColor: SettingsVisuals.pageBackground,
            elevation: 0,
            centerTitle: true,
            title: PremiumHeader(title: context.tr('security').toUpperCase()),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            children: [
              PremiumCard(
                children: [
                  PremiumListTile(
                    icon: Icons.lock_outline,
                    title: context.tr('change_password'),
                    subtitle: context.tr('change_password_subtitle'),
                    onTap: () => pushPremiumPage(
                      context,
                      BlocProvider(
                        create: (_) => PasswordResetCubit(),
                        child: const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                context.tr('active_sessions').toUpperCase(),
                style: TextStyle(
                  color: AppColors.mainGold,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: 10.h),
              if (state.sessions.isEmpty)
                PremiumCard(
                  children: [
                    PremiumTileShell(
                      child: Text(
                        context.tr('no_active_sessions'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                )
              else
                PremiumCard(
                  children: state.sessions
                      .map(
                        (session) => Column(
                          children: [
                            PremiumTileShell(
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.w,
                                    height: 44.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14.r),
                                      color: Colors.white.withValues(alpha: 0.05),
                                      border: Border.all(color: const Color(0x22C9A34E)),
                                    ),
                                    child: Icon(Icons.devices_outlined, color: AppColors.mainGold, size: 21.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.device,
                                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '${context.tr('location')}: ${session.location}',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 12.sp),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          '${context.tr('last_active')}: ${_formatLastActive(session.lastActive)}',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 12.sp),
                                        ),
                                        if (session.isCurrent) ...[
                                          SizedBox(height: 6.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: AppColors.mainGold.withValues(alpha: 0.18),
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(color: AppColors.mainGold.withValues(alpha: 0.5)),
                                            ),
                                            child: Text(
                                              context.tr('current_device'),
                                              style: TextStyle(
                                                color: AppColors.mainGold,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (session != state.sessions.last) const PremiumDivider(),
                          ],
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isClearingSessions ? null : () => _confirmClearSessions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsVisuals.dangerColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: state.isClearingSessions
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Text(context.tr('logout_all_devices')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastActive(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _confirmClearSessions(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SettingsVisuals.cardBackground,
        title: Text(context.tr('logout_all_devices_title')),
        content: Text(context.tr('logout_all_devices_message')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: SettingsVisuals.dangerColor),
            child: Text(context.tr('logout_all')),
          ),
        ],
      ),
    );

    if (shouldClear == true && context.mounted) {
      await context.read<SecurityCubit>().clearOtherSessions();
    }
  }
}

