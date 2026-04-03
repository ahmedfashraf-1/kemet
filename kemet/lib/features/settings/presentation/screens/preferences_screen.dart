import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SettingsVisuals.pageBackground,
          appBar: AppBar(
            backgroundColor: SettingsVisuals.pageBackground,
            elevation: 0,
            centerTitle: true,
            title: PremiumHeader(title: context.tr('preferences').toUpperCase()),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            children: [
              PremiumCard(
                children: [
                  PremiumSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: context.tr('dark_mode'),
                    subtitle: context.tr('instant_theme_update'),
                    value: state.darkModeEnabled,
                    onChanged: (value) => context.read<SettingsCubit>().setDarkMode(value),
                  ),
                  const PremiumDivider(),
                  _languageTile(context, state.localeCode),
                  const PremiumDivider(),
                  PremiumSwitchTile(
                    icon: Icons.location_on_outlined,
                    title: context.tr('location_access'),
                    subtitle: context.tr('location_access_subtitle'),
                    value: state.locationAccessEnabled,
                    isLoading: state.isRequestingLocation,
                    onChanged: (value) async => context.read<SettingsCubit>().setLocationAccess(value),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(BuildContext context, String localeCode) {
    return PremiumTileShell(
      child: Row(
        children: [
          Icon(Icons.language_outlined, size: 21.sp, color: Colors.white.withValues(alpha: 0.85)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              context.tr('language'),
              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white24, width: 0.6),
            ),
            child: Row(
              children: [
                _chip(context, label: 'EN', selected: localeCode == 'en', locale: 'en'),
                _chip(context, label: 'AR', selected: localeCode == 'ar', locale: 'ar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, {required String label, required bool selected, required String locale}) {
    return GestureDetector(
      onTap: () => context.read<SettingsCubit>().setLocale(locale),
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
}

