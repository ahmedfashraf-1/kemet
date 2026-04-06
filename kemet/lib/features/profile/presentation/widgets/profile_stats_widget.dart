import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStatsWidget extends StatelessWidget {
  final int trips;
  final int saved;
  final int reviews;

  const ProfileStatsWidget({
    super.key,
    required this.trips,
    required this.saved,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111008),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStat(trips, 'EXPLORED'),
          _buildDivider(),
          _buildStat(saved, 'FAVORITE'),
          _buildDivider(),
          _buildStat(reviews, 'REVIEWS'),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
        width: 0.5,
        height: 32,
        color: const Color(0xFFD4AF37).withOpacity(0.2),
      );

  Widget _buildStat(int count, String label) => Expanded(
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFD4AF37),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 9,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      );
}