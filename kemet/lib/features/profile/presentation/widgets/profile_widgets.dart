import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

// Section Label
class ProfileSectionLabel extends StatelessWidget {
  final String label;
  const ProfileSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: const Color(0xFFD4AF37).withOpacity(0.18),
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFC9A84C),
                fontSize: 10,
                letterSpacing: 2.5,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: const Color(0xFFD4AF37).withOpacity(0.18),
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


// Trip Card (horizontal scroll)
class ProfileTripCard extends StatelessWidget {
  final String name;
  final String city;
  final List<Color> gradientColors;

  const ProfileTripCard({
    super.key,
    required this.name,
    required this.city,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        border: Border.all(color: const Color(0xFF2E2810), width: 0.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            city,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}


// Review Item

class ProfileReviewItem extends StatelessWidget {
  final String? place;
  final double? rating;
  final String? date;

  const ProfileReviewItem({super.key, this.place, this.rating, this.date});

  @override
  Widget build(BuildContext context) {
    final safePlace = place ?? '';
    final safeDate = date ?? '';
    final safeRating = rating ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safePlace,
                  style: GoogleFonts.cormorant(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < safeRating.floor() ? Icons.star : Icons.star_border,
                      color: const Color(0xFFD4AF37),
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            safeDate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


// Saved Item

class ProfileSavedItem extends StatelessWidget {
  final String icon;
  final String name;
  final String location;

  const ProfileSavedItem({
    super.key,
    required this.icon,
    required this.name,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0C06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.08),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cormorant(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Sign Out Button

class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0E0E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A1A1A), width: 0.5),
        ),
        child: const Center(
          child: Text(
            'SIGN OUT',
            style: TextStyle(
              color: Color(0xFFC04040),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await context.read<SettingsCubit>().clearProfileAvatar();
  await FirebaseAuth.instance.signOut();

  Navigator.pushNamedAndRemoveUntil(
    context,
    Routes.LoginView,
    (route) => false,
  );
}


// Compact Review Preview Card

class ProfileReviewPreviewCard extends StatelessWidget {
  const ProfileReviewPreviewCard({
    super.key,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.onTap,
  });

  final double rating;
  final String comment;
  final DateTime createdAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0C0A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PreviewStars(rating: rating),
                Text(
                  _formatMonthYear(createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              comment,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    return '$month ${date.year}';
  }
}

class _PreviewStars extends StatelessWidget {
  const _PreviewStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(1, 5);
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < filled ? Icons.star : Icons.star_border,
          color: const Color(0xFFD4AF37),
          size: 12,
        ),
      ),
    );
  }
}
