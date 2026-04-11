import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
            title: PremiumHeader(title: context.tr('notifications').toUpperCase()),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            children: [
              PremiumCard(
                children: [
                  PremiumSwitchTile(
                    icon: Icons.notifications_outlined,
                    title: context.tr('push_notifications'),
                    subtitle: context.tr('push_notifications_subtitle'),
                    value: state.pushNotificationsEnabled,
                    onChanged: (value) => context.read<SettingsCubit>().setPushNotifications(value),
                  ),
                  const PremiumDivider(),
                  PremiumSwitchTile(
                    icon: Icons.mark_email_unread_outlined,
                    title: context.tr('email_updates'),
                    subtitle: context.tr('email_updates_subtitle'),
                    value: state.emailUpdatesEnabled,
                    onChanged: (value) => context.read<SettingsCubit>().setEmailUpdates(value),
                  ),
                  const PremiumDivider(),
                  PremiumSwitchTile(
                    icon: Icons.volume_up_outlined,
                    title: context.tr('sound'),
                    subtitle: context.tr('sound_subtitle'),
                    value: state.soundEnabled,
                    onChanged: (value) => context.read<SettingsCubit>().setSoundEnabled(value),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

