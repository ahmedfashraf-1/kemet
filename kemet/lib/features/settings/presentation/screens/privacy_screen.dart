import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:kemet/features/settings/presentation/screens/settings_document_screen.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsVisuals.pageBackground,
      appBar: AppBar(
        backgroundColor: SettingsVisuals.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: PremiumHeader(title: context.tr('privacy').toUpperCase()),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        children: [
          PremiumCard(
            children: [
              PremiumListTile(
                icon: Icons.privacy_tip_outlined,
                title: context.tr('privacy_policy'),
                subtitle: context.tr('privacy_policy'),
                onTap: () => pushPremiumPage(
                  context,
                  SettingsDocumentScreen(
                    title: context.tr('privacy_policy').toUpperCase(),
                    body: context.tr('privacy_policy_body'),
                  ),
                ),
              ),
              const PremiumDivider(),
              PremiumListTile(
                icon: Icons.tune_outlined,
                title: context.tr('data_personalization'),
                subtitle: context.tr('data_personalization'),
                onTap: () => pushPremiumPage(
                  context,
                  SettingsDocumentScreen(
                    title: context.tr('data_personalization').toUpperCase(),
                    body: context.tr('data_personalization_body'),
                  ),
                ),
              ),
              const PremiumDivider(),
              PremiumListTile(
                icon: Icons.gavel_outlined,
                title: context.tr('terms_of_service'),
                subtitle: context.tr('terms_of_service'),
                onTap: () => pushPremiumPage(
                  context,
                  SettingsDocumentScreen(
                    title: context.tr('terms_of_service').toUpperCase(),
                    body: context.tr('terms_of_service_body'),
                  ),
                ),
              ),
              const PremiumDivider(),
              PremiumListTile(
                icon: Icons.delete_outline,
                title: context.tr('delete_account'),
                subtitle: context.tr('delete_account_subtitle'),
                iconColor: SettingsVisuals.dangerColor,
                titleColor: SettingsVisuals.dangerColor,
                subtitleColor: SettingsVisuals.dangerColor.withValues(alpha: 0.78),
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SettingsVisuals.cardBackground,
        title: Text(context.tr('delete_account_confirm_title')),
        content: Text(context.tr('delete_account_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: SettingsVisuals.dangerColor),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('delete_account_flow_pending'))),
      );
    }
  }
}

