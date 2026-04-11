import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:kemet/features/auth/domain/repositories/auth_repository.dart';
import 'package:kemet/features/landmarks/presentation/screens/home_screen.dart';
import 'package:kemet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:kemet/features/profile/presentation/screens/profile_screen.dart';
import 'package:kemet/features/settings/presentation/cubit/payment_methods_cubit.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:kemet/features/settings/presentation/cubit/security_cubit.dart';
import 'package:kemet/features/settings/presentation/screens/about_screen.dart';
import 'package:kemet/features/settings/presentation/screens/help_support_screen.dart';
import 'package:kemet/features/settings/presentation/screens/payment_methods_screen.dart';
import 'package:kemet/features/settings/presentation/screens/rate_us_screen.dart';
import 'package:kemet/features/settings/presentation/screens/security_screen.dart';
import 'package:kemet/features/settings/presentation/screens/settings_document_screen.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color _pageBackground = Color(0xFF0B0B0B);
  static const Color _dangerColor = Color(0xFFD34B4B);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          backgroundColor: _pageBackground,
          appBar: AppBar(
            backgroundColor: _pageBackground,
            elevation: 0,
            centerTitle: true,
            title: Text(
              context.tr('settings').toUpperCase(),
              style: GoogleFonts.cinzel(
                color: AppColors.mainGold,
                fontSize: 18.sp,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(context.tr('account')),
                  SizedBox(height: 10.h),
                  _card(
                    children: [
                      _navigableRow(
                        icon: Icons.person_outline,
                        title: context.tr('profile'),
                        subtitle: context.tr('profile_subtitle'),
                        onTap: () {
                            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => getIt<ProfileCubit>(),
                                  child: ProfileScreen(userId: userId),
                                ),
                              ),
                            );
                          },
                      ),
                      _divider(),
                      _navigableRow(
                        icon: Icons.credit_card_outlined,
                        title: context.tr('payment_methods'),
                        subtitle: context.tr('payment_methods_subtitle'),
                        onTap: () => pushPremiumPage(
                          context,
                          BlocProvider(
                            create: (_) => PaymentMethodsCubit(
                              sharedPreferences:
                                  context.read<SettingsCubit>().sharedPreferences,
                            ),
                            child: const PaymentMethodsScreen(),
                          ),
                        ),
                      ),
                      _divider(),
                      _navigableRow(
                        icon: Icons.shield_outlined,
                        title: context.tr('security'),
                        subtitle: context.tr('security_subtitle'),
                        onTap: () => pushPremiumPage(
                          context,
                          BlocProvider(
                          create: (context) => SecurityCubit(),
                            child: const SecurityScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),
                  _sectionTitle(context.tr('notifications')),
                  SizedBox(height: 10.h),
                  _card(
                    children: [
                      _toggleRow(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: context.tr('push_notifications'),
                        subtitle: context.tr('push_notifications_subtitle'),
                        value: settingsState.pushNotificationsEnabled,
                        onChanged: (value) {
                          context.read<SettingsCubit>().setPushNotifications(value);
                        },
                      ),
                      _divider(),
                      _toggleRow(
                        context: context,
                        icon: Icons.mark_email_unread_outlined,
                        title: context.tr('email_updates'),
                        subtitle: context.tr('email_updates_subtitle'),
                        value: settingsState.emailUpdatesEnabled,
                        onChanged: (value) {
                          context.read<SettingsCubit>().setEmailUpdates(value);
                        },
                      ),
                      _divider(),
                      _toggleRow(
                        context: context,
                        icon: Icons.volume_up_outlined,
                        title: context.tr('sound'),
                        subtitle: context.tr('sound_subtitle'),
                        value: settingsState.soundEnabled,
                        onChanged: (value) {
                          context.read<SettingsCubit>().setSoundEnabled(value);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),
                  _sectionTitle(context.tr('preferences')),
                  SizedBox(height: 10.h),
                  _card(
                    children: [
                      _toggleRow(
                        context: context,
                        icon: Icons.dark_mode_outlined,
                        title: context.tr('dark_mode'),
                        value: settingsState.darkModeEnabled,
                        onChanged: (value) {
                          context.read<SettingsCubit>().setDarkMode(value);
                        },
                      ),
                      _divider(),
                      _languageRow(context, settingsState),
                      _divider(),
                      _toggleRow(
                        context: context,
                        icon: Icons.location_on_outlined,
                        title: context.tr('location_access'),
                        subtitle: context.tr('location_access_subtitle'),
                        value: settingsState.locationAccessEnabled,
                        isLoading: settingsState.isRequestingLocation,
                        onChanged: (value) async {
                          final granted = await context
                              .read<SettingsCubit>()
                              .setLocationAccess(value);
                          if (!granted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('location_permission_required')),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),
                  _sectionTitle(context.tr('privacy')),
                  SizedBox(height: 10.h),
                  _card(
                    children: [
                      _navigableRow(
                        icon: Icons.privacy_tip_outlined,
                        title: context.tr('privacy_policy'),
                        onTap: () => pushPremiumPage(
                          context,
                          SettingsDocumentScreen(
                            title: context.tr('privacy_policy').toUpperCase(),
                            body: context.tr('privacy_policy_body'),
                          ),
                        ),
                      ),
                      _divider(),
                      _navigableRow(
                        icon: Icons.tune_outlined,
                        title: context.tr('data_personalization'),
                        onTap: () => pushPremiumPage(
                          context,
                          SettingsDocumentScreen(
                            title: context.tr('data_personalization').toUpperCase(),
                            body: context.tr('data_personalization_body'),
                          ),
                        ),
                      ),
                      _divider(),
                      _navigableRow(
                        icon: Icons.gavel_outlined,
                        title: context.tr('terms_of_service'),
                        onTap: () => pushPremiumPage(
                          context,
                          SettingsDocumentScreen(
                            title: context.tr('terms_of_service').toUpperCase(),
                            body: context.tr('terms_of_service_body'),
                          ),
                        ),
                      ),
                      _divider(),
                      _dangerRow(
                        icon: Icons.delete_outline,
                        title: context.tr('delete_account'),
                        onTap: () => _showDeleteAccountDialog(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),
                  _sectionTitle(context.tr('about')),
                  SizedBox(height: 10.h),
                  _card(
                    children: [
                      _appVersionRow(context),
                      _divider(),
                      _navigableRow(
                        icon: Icons.star_border_outlined,
                        title: context.tr('rate_us'),
                        subtitle: context.tr('rate_us_subtitle'),
                        onTap: () => pushPremiumPage(context, const RateUsScreen()),
                      ),
                      _divider(),
                      _navigableRow(
                        icon: Icons.support_agent_outlined,
                        title: context.tr('help_support'),
                        onTap: () => pushPremiumPage(context, const HelpSupportScreen()),
                      ),
                    ],
                  ),

                  SizedBox(height: 34.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        context.tr('logout'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Text(
                      context.tr('kemet_tagline'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11.sp,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
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

  Widget _card({required List<Widget> children}) {
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
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 14.w,
      endIndent: 14.w,
      color: SettingsVisuals.dividerColor,
    );
  }

  Widget _navigableRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 21.sp, color: Colors.white.withOpacity(0.85)),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
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
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: Colors.white.withOpacity(0.65),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dangerRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 21.sp, color: _dangerColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _dangerColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 22.sp, color: Colors.white.withOpacity(0.65)),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        child: Row(
          children: [
            Icon(icon, size: 21.sp, color: Colors.white.withOpacity(0.85)),
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
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.62),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFC9A34E),
                  ),
                  backgroundColor: Colors.white12,
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
      ),
    );
  }

  Widget _languageRow(BuildContext context, SettingsState settingsState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            Icons.language_outlined,
            size: 21.sp,
            color: Colors.white.withOpacity(0.85),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24, width: 0.6),
            ),
            child: Row(
              children: [
                _languageChip(
                  label: 'EN',
                  selected: settingsState.localeCode == 'en',
                  onTap: () => context.read<SettingsCubit>().setLocale('en'),
                ),
                _languageChip(
                  label: 'AR',
                  selected: settingsState.localeCode == 'ar',
                  onTap: () => context.read<SettingsCubit>().setLocale('ar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.all(3.r),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC9A34E) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1A1408) : Colors.white70,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _appVersionRow(BuildContext context) {
    return _navigableRow(
      icon: Icons.info_outline,
      title: context.tr('app_version'),
      subtitle: context.tr('app_version_value'),
      onTap: () => pushPremiumPage(context, const AboutScreen()),
    );
  }
Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final shouldDelete = await showPremiumDeleteAccountDialog(context);

    if (!shouldDelete || !context.mounted) return;

    // ✅ بنعمل loading indicator عشان الـ user يعرف إن في حاجة بتحصل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFC9A34E)),
      ),
    );

    try {
      // ✅ بنستدعي الـ deleteAccount من الـ AuthRepository مباشرة
      // (مش محتاجين AuthCubit عشان مش فيه delete account use case فيه)
      final repository = context.read<AuthRepository>();
      await repository.deleteAccount();

      if (!context.mounted) return;

      // ✅ بنقفل الـ loading dialog
      Navigator.of(context).pop();

      //  بنروح لصفحة اللوجين ونمسح كل الـ routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.LoginView,
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      // ✅ بنقفل الـ loading dialog
      Navigator.of(context).pop();

      // ✅ بنعرض الـ error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A0E0E),
          content: Text(
            'Failed to delete account. Please try again.',
            style: const TextStyle(color: Color(0xFFC04040)),
          ),
        ),
      );
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: Text(context.tr('logout_confirm_title')),
          content: Text(context.tr('logout_confirm_message')),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: TextStyle(
            color: Colors.white.withOpacity(0.74),
            fontSize: 14,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
              ),
              child: Text(context.tr('logout')),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.LoginView, (route) => false);
      }
    }
  }
}

