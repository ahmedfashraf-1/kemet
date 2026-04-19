import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileStatsWidget extends StatelessWidget {
  final int trips;
  final int saved;
  final int reviews;
  final VoidCallback? onExploredTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onReviewsTap;

  const ProfileStatsWidget({
    super.key,
    required this.trips,
    required this.saved,
    required this.reviews,
    this.onExploredTap,
    this.onFavoriteTap,
    this.onReviewsTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF15120D),
              Color(0xFF0F0C08),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: StatItem(
                value: trips,
                label: 'EXPLORED',
                onTap: onExploredTap,
              ),
            ),
            _buildDivider(),
            Expanded(
              child: StatItem(
                value: saved,
                label: 'FAVORITE',
                onTap: onFavoriteTap,
              ),
            ),
            _buildDivider(),
            Expanded(
              child: StatItem(
                value: reviews,
                label: 'REVIEWS',
                onTap: onReviewsTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(
        width: 1,
        height: 36,
        color: Colors.amber.withOpacity(0.2),
      );
}

class StatItem extends StatefulWidget {
  const StatItem({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  State<StatItem> createState() => _StatItemState();
}

class _StatItemState extends State<StatItem> {
  double _scale = 1.0;

  void _setPressed(bool isPressed) {
    if (!mounted) {
      return;
    }
    setState(() => _scale = isPressed ? 0.96 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.amber.withOpacity(0.15),
          highlightColor: Colors.amber.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.value}',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFD4AF37),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}