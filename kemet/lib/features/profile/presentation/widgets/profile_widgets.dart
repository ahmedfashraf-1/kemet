import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────
class ProfileSectionLabel extends StatelessWidget {
  final String label;
  const ProfileSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC9A84C),
          fontSize: 10,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Trip Card (horizontal scroll)
// ─────────────────────────────────────────
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

// ─────────────────────────────────────────
// Review Item
// ─────────────────────────────────────────
class ProfileReviewItem extends StatelessWidget {
  final String? place;
  final double? rating;
  final String? date;

  const ProfileReviewItem({super.key, this.place, this.rating, this.date});

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(5, (i) => i < rating! ? '★' : '☆').join();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141108),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2810), width: 0.5),
      ),
      child: Row(
        children: [
          // icon box
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3A3010), width: 0.5),
            ),
            //child: Center(
            //child: Text(icon, style: const TextStyle(fontSize: 16)),
            //),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place!,
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stars,
                  style: const TextStyle(
                    color: Color(0xFFC9A84C),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date!,
            style: const TextStyle(color: Color(0xFF555555), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Saved Item
// ─────────────────────────────────────────
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141108),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E2810), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A0A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3A3010), width: 0.5),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFFDDDDDD),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '♥',
            style: TextStyle(color: Color(0xFFC04040), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Sign Out Button
// ─────────────────────────────────────────
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
  await FirebaseAuth.instance.signOut();

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/onLoginScreen',
    (route) => false,
  );
}
