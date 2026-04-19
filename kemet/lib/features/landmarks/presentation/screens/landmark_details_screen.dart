import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kemet/core/constants/colors.dart';
import 'package:kemet/core/widgets/join_kemet_dialog.dart';
import 'package:kemet/core/utils/share_service.dart';
import 'package:kemet/core/routing/routes.dart';
import 'package:kemet/core/services/text_to_speech_service.dart';
import 'package:kemet/features/landmarks/domain/entities/landmarks.dart';
import 'package:kemet/features/landmarks/presentation/widgets/discover_more_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_description_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_gallery.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_hero_section.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_info_card.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_map_button.dart';
import 'package:kemet/features/landmarks/presentation/widgets/landmark_bottom_nav_bar.dart';
import 'package:kemet/features/notifications/data/datasources/local_notification.dart';

class LandmarkDetailsScreen extends StatefulWidget {
  const LandmarkDetailsScreen({super.key, required this.landmark});

  final Landmark landmark;

  @override
  State<LandmarkDetailsScreen> createState() => _LandmarkDetailsScreenState();
}

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _saveToRecentTrips();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await FlutterTextToSpeechService.instance.initialize(
        defaultLanguage: 'en-US',
        speechRate: 0.46,
        pitch: 1.02,
        languageMode: TtsLanguageMode.auto,
      );
    } catch (_) {
      // Keep details page usable even if TTS setup fails on a device.
    }
  }

  Future<void> _saveToRecentTrips() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final xid = widget.landmark.id;
      if (xid.isEmpty) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'recentTrips': FieldValue.arrayUnion([xid]),
      }, SetOptions(merge: true));
      LocalNotificationService.instance.showLandmarkViewedNotification(
        landmarkName: widget.landmark.name,
        city: widget.landmark.city,
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final landmark = widget.landmark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final isGuest = firebaseUser == null || firebaseUser.isAnonymous;

    void openReviews() {
      final opened = requireAuthOrShowDialog(
        context,
        isGuest: isGuest,
        debugLabel: 'landmark-details-open-reviews',
        action: () {
          Navigator.of(context).pushNamed(
            Routes.reviewsScreen,
            arguments: landmark,
          );
        },
      );
      if (!opened) return;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final eased = Curves.easeOutCubic.transform(value);
                return Transform.translate(
                  offset: Offset(0, 16 * (1 - eased)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero section (image + overlay + top actions).
                  SliverToBoxAdapter(
                      child: LandmarkHeroSection(
                        landmark: landmark,
                        onBack: () => Navigator.of(context).pop(),
                        onShare: (context) => shareLandmark(context, landmark),
                      ),
                    ),

                  // Description section with narrative and audio button (UI only).
                  SliverToBoxAdapter(
                    child: _SectionFadeSlide(
                      child: LandmarkDescriptionSection(landmark: landmark),
                    ),
                  ),

                  // Visiting hours info card.
                  SliverToBoxAdapter(
                    child: _SectionFadeSlide(
                      child: LandmarkInfoCard(landmark: landmark),
                    ),
                  ),

                  // Map call to action (UI only).
                  SliverToBoxAdapter(
                    child: _SectionFadeSlide(
                      child: LandmarkMapButton(
                        city: landmark.city,
                        latitude: landmark.latitude,
                        longitude: landmark.longitude,
                      ),
                    ),
                  ),

                  // Horizontal gallery.
                  SliverToBoxAdapter(
                    child: LandmarkGallery(photos: landmark.photos),
                  ),

                  // Discover more cards (derived from the landmark data).
                  SliverToBoxAdapter(
                    child: DiscoverMoreSection(
                      landmark: landmark,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: barHeight + bottomInset + 24),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LandmarkBottomNavBar(
                activeIndex: 1,
                bottomInset: bottomInset,
                showReviews: true,
                        onAudioTap: () {
                          // The audio action is wired here so the bottom navigation icon can
                          // control the same landmark narration as the main description button.
                          FlutterTextToSpeechService.instance.togglePlayPause(
                            landmark.description,
                          );
                        },
                onReviews: openReviews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionFadeSlide extends StatelessWidget {
  const _SectionFadeSlide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        return Transform.translate(
          offset: Offset(0, 14 * (1 - eased)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}

