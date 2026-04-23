import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/localization/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class LandmarkMapButton extends StatelessWidget {
  const LandmarkMapButton({
    super.key,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  final String city;
  final double? latitude;
  final double? longitude;

  Future<bool> openMap(double lat, double lng) {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = latitude != null && longitude != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isEnabled
                ? () async {
                    final lat = latitude;
                    final lng = longitude;
                    if (lat == null || lng == null) {
                      return;
                    }
                    final launched = await openMap(lat, lng);
                    if (!context.mounted) {
                      return;
                    }
                    if (!launched) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to open Google Maps.'),
                        ),
                      );
                    }
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.mainGold.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mainGold.withOpacity(0.1),
                    ),
                    child: Icon(Icons.map, color: AppColors.mainGold),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('landmark_map_heading'),
                          style: GoogleFonts.notoSerif(
                            fontSize: 10,
                            letterSpacing: 2.2,
                            color: AppColors.mainGold.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context
                              .tr('landmark_map_subtitle')
                              .replaceFirst('{city}', city),
                          style: GoogleFonts.notoSerif(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.mainGold.withOpacity(0.5),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
