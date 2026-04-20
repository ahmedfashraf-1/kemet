import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';

class LandmarkBottomNavBar extends StatelessWidget {
  const LandmarkBottomNavBar({
    super.key,
    this.activeIndex = 1,
    this.bottomInset = 0,
    this.onReviews,
    this.onAudioTap,
    this.showReviews = true,
  });

  final int activeIndex;
  final double bottomInset;
  final VoidCallback? onReviews;
  final VoidCallback? onAudioTap;
  final bool showReviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset + 12),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: const BoxConstraints(minWidth: 240),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xCC111111),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.subtleGoldBorder.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navIcon(
                    icon: Icons.forum_outlined,
                    isActive: activeIndex == 0,
                  ),
                  _primaryNavIcon(icon: Icons.map, isActive: activeIndex == 1),
                  _audioNavIcon(),
                  if (showReviews)
                    _navIcon(
                      icon: Icons.rate_review_outlined,
                      isActive: activeIndex == 3,
                      onTap: onReviews,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedScale(
          scale: isActive ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.mainGold.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.mainGold : AppColors.darkGold,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _audioNavIcon() {
    final tts = NarrationTTSController.instance;
    return AnimatedBuilder(
      animation: tts,
      builder: (context, _) {
        final isPlaying = tts.isSpeaking;
        final isPaused = tts.isPaused;

        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAudioTap,
            child: AnimatedScale(
              scale: (isPlaying || isPaused) ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: (isPlaying || isPaused)
                      ? [
                          BoxShadow(
                            color: AppColors.mainGold.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause
                      : (isPaused ? Icons.play_arrow : Icons.volume_up),
                  color: (isPlaying || isPaused)
                      ? AppColors.mainGold
                      : AppColors.darkGold,
                  size: 22,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _primaryNavIcon({required IconData icon, required bool isActive}) {
    return AnimatedScale(
      scale: isActive ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFEBC07E), Color(0xFFC59D5F)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.mainGold.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textDarkOnGold),
      ),
    );
  }
}
