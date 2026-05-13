import 'package:flutter/material.dart';

class ExploredStatsCard extends StatelessWidget {
  final int totalExplored;
  final Map<String, int> categoryStats;

  const ExploredStatsCard({
    super.key,
    required this.totalExplored,
    required this.categoryStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B19),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Stat
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalExplored.toString(),
                style: const TextStyle(
                  fontSize: 56,
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Explored',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD0C5AF),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFD4AF37).withOpacity(0.15),
          ),
          const SizedBox(height: 24),

          // Category Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ..._buildCategoryStats(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats() {
    final entries = categoryStats.entries.toList();
    return List.generate(
      entries.length * 2 - 1,
      (index) {
        if (index.isEven) {
          final entry = entries[index ~/ 2];
          return _StatItem(value: entry.value.toString(), label: entry.key);
        } else {
          return _SectionDivider();
        }
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFD0C5AF),
            letterSpacing: 0.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFD4AF37).withOpacity(0.15),
    );
  }
}

