import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kemet/features/settings/presentation/widgets/settings_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = <Map<String, String>>[
      {
        'q': context.tr('help_faq_q1'),
        'a': context.tr('help_faq_a1'),
      },
      {
        'q': context.tr('help_faq_q2'),
        'a': context.tr('help_faq_a2'),
      },
      {
        'q': context.tr('help_faq_q3'),
        'a': context.tr('help_faq_a3'),
      },
    ];

    return Scaffold(
      backgroundColor: SettingsVisuals.pageBackground,
      appBar: AppBar(
        backgroundColor: SettingsVisuals.pageBackground,
        elevation: 0,
        centerTitle: true,
        title: PremiumHeader(title: context.tr('help_support').toUpperCase()),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        children: [
          PremiumCard(
            children: [
              for (var i = 0; i < faqs.length; i++) ...[
                ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  collapsedIconColor: Colors.white70,
                  iconColor: const Color(0xFFC9A34E),
                  title: Text(
                    faqs[i]['q']!,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                      child: Text(
                        faqs[i]['a']!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12.sp, height: 1.6),
                      ),
                    ),
                  ],
                ),
                if (i != faqs.length - 1) const PremiumDivider(),
              ],
            ],
          ),
          SizedBox(height: 18.h),
          PremiumCard(
            children: [
              PremiumListTile(
                icon: Icons.email_outlined,
                title: context.tr('email_support'),
                subtitle: 'support@kemet.travel',
                onTap: () => _launchMail(),
              ),
              const PremiumDivider(),
              PremiumListTile(
                icon: Icons.chat_bubble_outline,
                title: context.tr('live_chat'),
                subtitle: context.tr('live_chat_subtitle'),
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchMail(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A34E),
                foregroundColor: const Color(0xFF151008),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              icon: const Icon(Icons.support_agent_outlined),
              label: Text(context.tr('contact_support')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMail() async {
    final uri = Uri.parse('mailto:support@kemet.travel?subject=Kemet%20Support');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

