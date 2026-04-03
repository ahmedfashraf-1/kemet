import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141108),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2810), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: trips, label: 'EXPLORED'),
          _Divider(),
          _StatItem(value: saved, label: 'FAVORITE'),
          _Divider(),
          _StatItem(value: reviews, label: 'REVIEWS'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Color(0xFFC9A84C),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 32, color: const Color(0xFF2A2A2A));
  }
}