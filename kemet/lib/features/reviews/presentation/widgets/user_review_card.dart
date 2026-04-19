import 'package:flutter/material.dart';
import 'package:kemet/features/reviews/domain/entities/review.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({
    super.key,
    required this.review,
    required this.landmarkName,
    this.onTap,
    this.onLandmarkTap,
  });

  final Review review;
  final String landmarkName;
  final VoidCallback? onTap;
  final VoidCallback? onLandmarkTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B19),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF4E4539).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEBC07E).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StarsRow(rating: review.rating),
                Text(
                  _formatMonthYear(review.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFB6A695),
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFD2C4B5),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: onLandmarkTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      color: Color(0xFFEBC07E),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        landmarkName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE9E1DD),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
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

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(1, 5);
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < filled ? Icons.star : Icons.star_border,
          color: index < filled
              ? const Color(0xFFEBC07E)
              : const Color(0xFF4E4539),
          size: 16,
        ),
      ),
    );
  }
}
