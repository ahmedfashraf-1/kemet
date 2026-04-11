import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';

class LandmarkDescriptionSection extends StatelessWidget {
  const LandmarkDescriptionSection({super.key, required this.landmark});

  final Landmark landmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.mainGold.withOpacity(0.35)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Narrative text block.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Narrative',
                    style: GoogleFonts.notoSerif(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      color: AppColors.mainGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    landmark.description,
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Audio button (UI only).
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEBC07E), Color(0xFFC59D5F)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainGold.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up,
                color: AppColors.textDarkOnGold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
